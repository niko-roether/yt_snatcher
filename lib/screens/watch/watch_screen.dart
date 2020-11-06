import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/screens/watch/download_player.dart';
import 'package:yt_snatcher/widgets/screen.dart';
import 'package:yt_snatcher/widgets/video_info_view.dart';

class WatchScreen extends StatefulWidget {
  static const ROUTENAME = "/watch";

  @override
  State<StatefulWidget> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Download dl = ModalRoute.of(context).settings.arguments;
    Widget content;
    if (dl == null || dl.meta.type == DownloadType.MUSIC)
      content = Center(child: Text("No video found"));
    content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DownloadPlayer.single(download: dl),
        Expanded(
          child: SingleChildScrollView(child: VideoInfoView(dl.meta.videoMeta)),
        ),
        // TODO playlists, recommendations, ...
      ],
    );
    return Screen(
      title: Text("Watch Video"),
      showAppBar: false,
      content: content,
    );
  }
}
