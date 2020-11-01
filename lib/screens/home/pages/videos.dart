import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/home/downloads_display.dart';
import 'package:yt_snatcher/screens/watch/watch_screen.dart';

class Videos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DownloadsDisplay(
      selector: (dlm) => dlm.getVideos(),
      onTap: (dl) => Navigator.pushNamed(
        context,
        WatchScreen.ROUTENAME,
        arguments: dl,
      ),
    );
  }
}
