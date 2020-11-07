import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controller.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controls.dart';

enum VideoSourceType { FILE, NETWORK }

class YtsVideoPlayer extends StatefulWidget {
  final YtsVideoPlayerController controller;
  final void Function() onBack;
  final List<SystemUiOverlay> overlaysWhenPortrait;
  final List<SystemUiOverlay> overlaysAfterDispose;

  YtsVideoPlayer({
    @required this.controller,
    this.onBack,
    this.overlaysWhenPortrait = SystemUiOverlay.values,
    this.overlaysAfterDispose = SystemUiOverlay.values,
  }) : assert(controller != null);

  @override
  State<StatefulWidget> createState() {
    return _YtsVideoPlayerState();
  }
}

// TODO fix playing state preservation on orientation change
class _YtsVideoPlayerState extends State<YtsVideoPlayer> {
  static const double _ASPECT_RATIO = 16 / 9;
  bool _fullscreenMode;

  YtsVideoPlayerController get _controller => widget.controller;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(widget.overlaysAfterDispose);
    super.dispose();
  }

  void _adjustSystemOverlays(bool fullscreen) {
    if (fullscreen == _fullscreenMode) return;
    SystemChrome.setEnabledSystemUIOverlays(
        fullscreen ? [] : widget.overlaysWhenPortrait);
    _fullscreenMode = fullscreen;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isFullscreen = mediaQuery.orientation == Orientation.landscape;
    final deviceAspectRatio = mediaQuery.size.aspectRatio;
    final aspectRatio = isFullscreen ? deviceAspectRatio : _ASPECT_RATIO;

    _adjustSystemOverlays(isFullscreen);

    final player = AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayer(_controller.playerController),
        ),
        VideoPlayerControls(
          controller: _controller,
          showControlsImmediately: !_controller.autoplay,
          fullscreen: isFullscreen,
          onBack: () => widget.onBack?.call(),
        ),
      ]),
    );
    return player;
  }
}
