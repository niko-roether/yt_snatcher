import "package:flutter/material.dart";
import 'package:yt_snatcher/router.dart';
import 'package:yt_snatcher/widgets/provider/download_process_manager.dart';
import 'package:yt_snatcher/widgets/provider/download_provider.dart';

void main() => runApp(YtSnatcher());

class YtSnatcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DownloadProvider(
      child: DownloadProcessManager(
        child: MaterialApp(
          title: "Youtube Snatcher",
          initialRoute: "/",
          routes: routes,
        ),
      ),
    );
  }
}
