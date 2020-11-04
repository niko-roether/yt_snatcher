import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/download_player.dart';
import 'package:yt_snatcher/widgets/screen.dart';
import 'package:yt_snatcher/widgets/video_info_view.dart';

class PlayScreen extends StatelessWidget {
  static const ROUTENAME = "/play";

  @override
  Widget build(BuildContext context) {
    Download dl = ModalRoute.of(context).settings.arguments;
    // return OrientationBuilder(builder: (context, orientation) {
    //   var fullscreen = orientation == Orientation.landscape;
    Widget content;
    if (dl == null) content = Center(child: Text("No video found"));
    content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DownloadPlayer(
          download: dl, /*defaultFullscreen: fullscreen*/
        ),
        VideoInfoView(dl.meta.videoMeta),
        // TODO playlists, recommendations, ...
      ],
    );
    return Screen(
      title: Text(
        dl.meta.type == DownloadType.VIDEO ? "Watch Video" : "Listen to Music",
      ),
      // showAppBar: !fullscreen,
      content: content,
    );
    // });
  }
}
