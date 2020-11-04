import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/download_player.dart';
import 'package:yt_snatcher/widgets/screen.dart';
import 'package:yt_snatcher/widgets/video_info_view.dart';

class WatchScreen extends StatelessWidget {
  static const ROUTENAME = "/watch";

  @override
  Widget build(BuildContext context) {
    Download dl = ModalRoute.of(context).settings.arguments;
    Widget content;
    if (dl == null || dl.meta.type == DownloadType.MUSIC)
      content = Center(child: Text("No video found"));
    content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DownloadPlayer(downloads: [dl, dl, dl]),
        VideoInfoView(dl.meta.videoMeta),
        // TODO playlists, recommendations, ...
      ],
    );
    return Screen(
      title: Text(
        dl.meta.type == DownloadType.VIDEO ? "Watch Video" : "Listen to Music",
      ),
      content: content,
    );
  }
}
