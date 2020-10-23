// FIXME this doesn't work, but I decided to keep it nonetheless so that I don't forget how the VideoPlayer works

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
    _getManifest();
  }

  void _getManifest() async {
    final url = await _yt.getVideoURL(id);
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
