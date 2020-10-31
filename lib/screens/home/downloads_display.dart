import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/consumer.dart';
import 'package:yt_snatcher/widgets/downloader_view.dart';
import 'package:yt_snatcher/widgets/inherited/download_process_manager.dart';

class DownloadsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProcessManager>(
      builder: (context, inherited, child) {
        var processes = inherited.currentDownloads;
        if (processes.isEmpty) return Container();
        return ListView.builder(itemBuilder: (context, i) {
          var process = processes[i];
          return DownloaderView(
            downloader: process.downloader,
            meta: process.meta,
          );
        });
      },
    );
  }
}
