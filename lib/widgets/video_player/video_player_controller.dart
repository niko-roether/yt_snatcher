import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player.dart';

class YtsVideoPlayerController with ChangeNotifier {
  VideoPlayerController playerController;
  Duration _dragbarPosition;
  final bool autoplay;
  bool _fullscreen;

  Duration get position => playerController.value.position ?? Duration.zero;
  Duration get duration => playerController.value.duration ?? Duration.zero;
  Duration get dragbarPosition => _dragbarPosition;
  bool get fullscreen => _fullscreen;

  void setFullscreen(bool fullscreen) {
    _fullscreen = fullscreen;
    notifyListeners();
  }

  void enterFullscreen() => setFullscreen(true);
  void exitFullscreen() => setFullscreen(false);
  void toggleFullscreen() => setFullscreen(!fullscreen);

  double get progress {
    if (duration == Duration.zero) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  double get dragbarProgress {
    if (duration == Duration.zero) return 0;
    return dragbarPosition.inMilliseconds / duration.inMilliseconds;
  }

  Future<void> setPosition(Duration position) =>
      playerController.seekTo(position);

  Future<void> play() {
    return playerController.play();
  }

  Future<void> pause() => playerController.pause();

  bool get isPlaying => playerController.value.isPlaying;

  VideoPlayerValue get playingState => playerController.value;

  void setDragbarPosition(Duration position) {
    _dragbarPosition = position;
    notifyListeners();
  }

  void _onVideoControllerUpdate() async {
    notifyListeners();
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  YtsVideoPlayerController({
    @required String path,
    @required VideoSourceType type,
    Duration initialDragbarPosition = Duration.zero,
    Duration startAt = Duration.zero,
    this.autoplay = false,
    // TODO add more options
  }) : _dragbarPosition = initialDragbarPosition {
    switch (type) {
      case VideoSourceType.FILE:
        playerController = VideoPlayerController.file(File(path));
        break;
      case VideoSourceType.NETWORK:
        playerController = VideoPlayerController.network(path);
    }
    playerController.addListener(_onVideoControllerUpdate);
    playerController.initialize().then((_) => {
          setPosition(startAt),
          if (autoplay) play(),
        });
  }

  factory YtsVideoPlayerController.file({
    @required File file,
    Duration initialDragbarPosition = Duration.zero,
    Duration startAt = Duration.zero,
    bool autoplay = false,
  }) {
    return YtsVideoPlayerController(
      path: file.path,
      type: VideoSourceType.FILE,
      initialDragbarPosition: initialDragbarPosition,
      startAt: startAt,
      autoplay: autoplay,
    );
  }
  factory YtsVideoPlayerController.network({
    @required String source,
    Duration initialDragbarPosition = Duration.zero,
    Duration startAt = Duration.zero,
    bool autoplay = false,
  }) {
    return YtsVideoPlayerController(
      path: source,
      type: VideoSourceType.NETWORK,
      initialDragbarPosition: initialDragbarPosition,
      startAt: startAt,
      autoplay: autoplay,
    );
  }
}
