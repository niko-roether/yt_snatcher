import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class _AudioPlayerTask extends BackgroundAudioTask {
  final _player = AudioPlayer();
  List<MediaItem> _queue = [];
  Timer _seeker;
  StreamSubscription<PlaybackEvent> _playerEventSubscription;
  AudioProcessingState _stateOverride;

  Future<void> _seekRelative(Duration amount) {
    var pos = _player.duration + amount;
    if (pos < Duration.zero) pos = Duration.zero;
    if (pos > _player.duration) pos = _player.duration;
    return _player.seek(pos);
  }

  void _seekContinuous(bool begin, int direction) {
    _seeker?.cancel();
    if (!begin) return;
    _seeker = Timer.periodic(Duration(seconds: 1), (_) {
      _seekRelative(Duration(seconds: 10 * direction));
    });
  }

  AudioProcessingState get _processingState {
    if (_stateOverride != null) return _stateOverride;
    switch (_player.processingState) {
      case ProcessingState.none:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("${_player.processingState} is not a valid state");
    }
  }

  Future<void> _onStateChange() {
    return AudioServiceBackground.setState(
      controls: [
        if (_player.hasPrevious) MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.pause,
        if (_player.hasNext) MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _processingState,
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final session = await AudioSession.instance;
    session.configure(AudioSessionConfiguration.music());

    _player.currentIndexStream.listen((i) {
      if (i != null) AudioServiceBackground.setMediaItem(_queue[i]);
    });
    _playerEventSubscription = _player.playbackEventStream.listen((_) {
      _onStateChange();
    });
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          onStop();
          break;
        case ProcessingState.ready:
          _stateOverride = null;
          break;
        default:
      }
    });

    AudioServiceBackground.setQueue(_queue);
    try {
      await _player.load(ConcatenatingAudioSource(
        children:
            _queue.map((item) => AudioSource.uri(Uri.file(item.id))).toList(),
      ));
      onPlay();
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  @override
  Future<void> onStop() async {
    await _playerEventSubscription.cancel();
    await _player.pause();
    await _player.dispose();
    await _onStateChange();
    return super.onStop();
  }

  @override
  Future<void> onAddQueueItem(MediaItem item) async => _queue.add(item);

  @override
  Future<void> onAddQueueItemAt(MediaItem mediaItem, int index) async {
    _queue.insert(index, mediaItem);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final index = _queue.indexWhere((item) => item.id == mediaId);
    if (index == -1) return;
    _stateOverride = index > _player.currentIndex
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuous(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuous(begin, -1);

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(rewindInterval);
}

void audioTaskEntryPoint() async {
  AudioServiceBackground.run(() => _AudioPlayerTask());
}
