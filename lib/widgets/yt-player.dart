import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube.dart';

class YtPlayer extends StatefulWidget {
  final String videoId;

  YtPlayer({@required this.videoId});

  @override
  State<YtPlayer> createState() {
    return YtPlayerState(id: videoId);
  }
}

class YtPlayerState extends State<YtPlayer> {
  final _yt = new Youtube();
  final String id;
  String _url;

  YtPlayerState({@required this.id}) {
    _getUrl();
  }

  void _getUrl() async {
    var video = await _yt.getVideo(id);
    var url = video.muxed().highestResolution().url;
    setState(() => _url = url);
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_url == null) return Center(child: CircularProgressIndicator());
    return Center(
      child: BetterPlayer.network(_url),
    );
  }
}
