import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controls.dart';
import 'package:yt_snatcher/widgets/video_player/video_progress_bar.dart';

enum VideoSourceType { FILE, NETWORK }

class VideoPlayer extends StatefulWidget {
  final String url;
  final VideoSourceType type;
  final bool autoplay;

  VideoPlayer({@required this.url, @required this.type, this.autoplay = false})
      : assert(type != null),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      VlcPlayer(
          aspectRatio: _ASPECT_RATIO,
          controller: _controller,
          url: widget.url,
          isLocalMedia: widget.type == VideoSourceType.FILE,
          placeholder: Container(
            color: Color(0xff000000),
            child: Center(child: CircularProgressIndicator()),
          )),
      VideoPlayerControls(
        controller: _controller,
        aspectRatio: _ASPECT_RATIO,
      ),
    ]);
  }
}
