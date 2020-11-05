import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

enum VideoSourceType { FILE, NETWORK }

class VideoPlayer extends StatefulWidget {
  final String url;
  final VideoSourceType type;

  VideoPlayer({@required this.url, @required this.type}) : assert(type != null);

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  final _playerSize = Size(640, 360);
  VlcPlayerController _controller;

  _VideoPlayerState() {
    _controller = VlcPlayerController(onInit: () {
      _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: _playerSize,
      child: VlcPlayer(
        aspectRatio: 16 / 9,
        controller: _controller,
        url: widget.url,
        isLocalMedia: widget.type == VideoSourceType.FILE,
        placeholder: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
