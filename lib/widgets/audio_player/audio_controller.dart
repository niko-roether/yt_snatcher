import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class _AudioPlayTask extends BackgroundAudioTask {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> onPlay() async {
    _player.play();
    await AudioServiceBackground.setState(
      controls: [MediaControl.pause],
      processingState: AudioProcessingState.completed,
      playing: true,
    );
    await AudioServiceBackground.setMediaItem(
        MediaItem(id: null, album: null, title: null));
  }
}
