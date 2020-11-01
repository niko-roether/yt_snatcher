import 'package:flutter/cupertino.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/download_player.dart';

class WatchScreen extends StatelessWidget {
  static const ROUTENAME = "/watch";

  @override
  Widget build(BuildContext context) {
    Download dl = ModalRoute.of(context).settings.arguments;
    if (dl == null) return Center(child: Text("No video found"));
    return DownloadPlayer(download: dl);
  }
}
