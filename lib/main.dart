import "package:flutter/material.dart";
import 'package:yt_snatcher/router.dart';
import 'package:yt_snatcher/widgets/provider/download_process_manager.dart';

void main() => runApp(YtSnatcher());

class YtSnatcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DownloadProcessManager(
      child: MaterialApp(
        title: "Youtube Snatcher",
        initialRoute: "/",
        routes: routes,
      ),
    );
  }
}
