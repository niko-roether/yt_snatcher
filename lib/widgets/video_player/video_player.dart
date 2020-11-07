import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controls.dart';

enum VideoSourceType { FILE, NETWORK }

class VideoPlayer extends StatefulWidget {
  final String url;
  final VideoSourceType type;
  final bool autoplay;
  final Duration startAt;
  final void Function(VlcPlayerController controller) listener;
  final void Function() onBack;

  VideoPlayer({
    @required this.url,
    @required this.type,
    this.autoplay = false,
    this.listener,
    this.startAt = Duration.zero,
    this.onBack,
  })  : assert(type != null),
        assert(autoplay != null);

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  static const double _ASPECT_RATIO = 16 / 9;
  VlcPlayerController _controller;

  _VideoPlayerState() {
    _controller = VlcPlayerController(onInit: () {
      if (widget.autoplay) _controller.play();
      _controller.setTime(widget.startAt.inMilliseconds);
    });
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() async {
    widget.listener?.call(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isFullscreen = mediaQuery.orientation == Orientation.landscape;
    final deviceAspectRatio = mediaQuery.size.aspectRatio;
    final aspectRatio = isFullscreen ? deviceAspectRatio : _ASPECT_RATIO;
    final player = Stack(children: [
      VlcPlayer(
        aspectRatio: aspectRatio,
        controller: _controller,
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
        showControlsImmediately: !widget.autoplay,
        fullscreen: isFullscreen,
        onBack: () => widget.onBack?.call(),
      ),
    ]);
    return player;
  }
}
