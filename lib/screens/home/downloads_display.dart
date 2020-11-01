import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/consumer.dart';
import 'package:yt_snatcher/widgets/downloader_view.dart';
import 'package:yt_snatcher/widgets/provider/download_process_manager.dart';

class DownloadsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadService>(
      builder: (context, inherited, child) {
        var processes = inherited.currentDownloads;
        if (processes.isEmpty)
          return Center(
              child: Text(
            "No downloads are currently active.",
            style: TextStyle(fontStyle: FontStyle.italic),
          ));
        return ListView.builder(
          itemBuilder: (context, i) {
            var process = processes[i];
            return DownloaderView(
              downloader: process.downloader,
              meta: process.meta,
            );
          },
          itemCount: processes.length,
        );
      },
    );
  }
}
