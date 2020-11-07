import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controller.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controls.dart';

enum VideoSourceType { FILE, NETWORK }

class VideoPlayer extends StatefulWidget {
  final String url;
  final VideoSourceType type;
  final VideoPlayerController controller;
  final void Function() onBack;
  final List<SystemUiOverlay> overlaysWhenPortrait;
  final List<SystemUiOverlay> overlaysAfterDispose;

  VideoPlayer({
    @required this.url,
    @required this.type,
    @required this.controller,
    this.onBack,
    this.overlaysWhenPortrait = SystemUiOverlay.values,
    this.overlaysAfterDispose = SystemUiOverlay.values,
  })  : assert(type != null),
        assert(controller != null);

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

// TODO fix playing state preservation on orientation change
class _VideoPlayerState extends State<VideoPlayer> {
  static const double _ASPECT_RATIO = 16 / 9;
  bool _fullscreenMode;

  VideoPlayerController get _controller => widget.controller;

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

    final player = Stack(children: [
      VlcPlayer(
        aspectRatio: aspectRatio,
        controller: _controller.vlcController,
        url: widget.url,
        isLocalMedia: widget.type == VideoSourceType.FILE,
        placeholder: Container(
          alignment: Alignment.center,
          color: Color(0xff000000),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
          ),
        ),
      ),
      VideoPlayerControls(
        controller: _controller,
        aspectRatio: aspectRatio,
        showControlsImmediately: !_controller.autoplay,
        fullscreen: isFullscreen,
        onBack: () => widget.onBack?.call(),
      ),
    ]);
    return player;
  }
}
