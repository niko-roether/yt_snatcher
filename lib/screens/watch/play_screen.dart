import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/download_player.dart';
import 'package:yt_snatcher/widgets/screen.dart';

class PlayScreen extends StatelessWidget {
  static const ROUTENAME = "/play";

  @override
  Widget build(BuildContext context) {
    Download dl = ModalRoute.of(context).settings.arguments;
    Widget content;
    if (dl == null) content = Center(child: Text("No video found"));
    content = DownloadPlayer(download: dl);
    return Screen(
      title: Text(
        dl.meta.type == DownloadType.VIDEO ? "Watch Video" : "Listen to Music",
      ),
      content: content,
      key: Key(ROUTENAME),
    );
  }
}
