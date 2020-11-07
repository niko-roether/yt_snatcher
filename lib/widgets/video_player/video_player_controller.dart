import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
export 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoPlayerController with ChangeNotifier {
  VlcPlayerController vlcController;
  Duration _dragbarPosition;
  final bool autoplay;

  Duration get position => vlcController.position;
  Duration get duration => vlcController.duration;
  Duration get dragbarPosition => _dragbarPosition;
  double get progress => position.inMilliseconds / duration.inMilliseconds;
  double get dragbarProgress =>
      dragbarPosition.inMilliseconds / duration.inMilliseconds;

  Future<void> setPosition(Duration position) =>
      vlcController.setTime(position.inMilliseconds);

  Future<void> play() {
    return vlcController.play();
  }

  Future<void> pause() => vlcController.pause();

  Future<bool> isPlaying() => vlcController.isPlaying();

  PlayingState get playingState => vlcController.playingState;

  void setDragbarPosition(Duration position) {
    _dragbarPosition = position;
    notifyListeners();
  }

  void _onVlcControllerUpdate() async {
    notifyListeners();
  }

  VideoPlayerController({
    Duration initialDragbarPosition = Duration.zero,
    Duration startAt = Duration.zero,
    this.autoplay = false,
    // TODO add more options
  }) : _dragbarPosition = initialDragbarPosition {
    vlcController = VlcPlayerController(onInit: () {
      if (autoplay) play();
    });
    vlcController.addListener(_onVlcControllerUpdate);
    setPosition(startAt);
  }
}
