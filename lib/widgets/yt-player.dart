// FIXME this doesn't work, but I decided to keep it nonetheless so that I don't forget how the VideoPlayer works

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtPlayer extends StatefulWidget {
  final String videoId;

  YtPlayer({@required this.videoId});

  @override
  State<YtPlayer> createState() {
    return YtPlayerState(id: videoId);
  }
}

class YtPlayerState extends State<YtPlayer> {
  final YoutubeExplode _yt = YoutubeExplode();
  final String id;
  StreamManifest _manifest;

  YtPlayerState({@required this.id}) {
    _getManifest();
  }

  void _getManifest() async {
    final manifest = await _yt.videos.streamsClient.getManifest(id);
    setState(() => _manifest = manifest);
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_manifest == null) return Center(child: CircularProgressIndicator());
    var stream = _manifest.muxed.sortByVideoQuality().last;
    return Center(
      child: BetterPlayer.network(stream.url.toString()),
    );
  }
}
