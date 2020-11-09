import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yt_snatcher/services/download_manager.dart';

class _AudioPlayTask extends BackgroundAudioTask {
  final AudioPlayer _player = AudioPlayer();
  final Download _download;
  bool _initialized = false;

  _AudioPlayTask(this._download)
      : assert(_download.meta.type == DownloadType.MUSIC);

  Future<void> _init() async {
    _initialized = true;
    await _player.load(DashAudioSource(_download.mediaFile.uri));
  }

  @override
  Future<void> onPlay() async {
    if (!_initialized) await _init();
    await _player.play();
    await AudioServiceBackground.setState(
      controls: [MediaControl.pause],
      processingState: AudioProcessingState.completed,
      playing: true,
    );
    await AudioServiceBackground.setMediaItem(MediaItem(
      id: _download.meta.id,
      album: _download.meta.videoMeta.channelName,
      title: _download.meta.displayTitle,
    ));
  }

  @override
  Future<void> onPause() async {
    await _player.play();
    await AudioServiceBackground.setState(
      controls: [MediaControl.play],
      processingState: AudioProcessingState.completed,
      playing: false,
    );
  }

  @override
  Future<void> onStop() async {
    await AudioServiceBackground.setMediaItem(MediaItem(
      id: null,
      album: null,
      title: null,
    ));
  }
}

class AudioPlayerController extends ChangeNotifier {}
