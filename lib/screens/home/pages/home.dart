import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download.dart';
import 'package:yt_snatcher/services/youtube-dl.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  final _dl = DownloadManager();
  final _ytdl = YoutubeDL();
  List<Download> _downloads;

  HomeState() {
    _init();
  }

  void _init() async {
    var preDl = await _ytdl.prepare("fad_0eQIlVo").asVideo();
    var dl = await preDl.best().download((pr) => print(pr));
    print(dl.meta.filename);
    var videos = await _dl.getVideos();
    var dls = await videos.getDownloads();
    setState(() => _downloads = dls);
  }

  @override
  Widget build(BuildContext context) {
    if (_downloads == null) return Center(child: CircularProgressIndicator());
    return BetterPlayer.file(_downloads[0].mediaFile.path);
  }
}
