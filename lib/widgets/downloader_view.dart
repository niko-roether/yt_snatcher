import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube-dl.dart';
import 'package:yt_snatcher/services/youtube.dart';
import 'package:yt_snatcher/widgets/download_progress_indicator.dart';

class DownloaderView extends StatefulWidget {
  final Downloader downloader;
  final VideoMeta meta;

  DownloaderView({@required this.downloader, @required this.meta});

  @override
  State<StatefulWidget> createState() {
    return DownloaderViewState(downloader, meta);
  }
}

class DownloaderViewState extends State<DownloaderView> {
  final Downloader _downloader;
  final VideoMeta _meta;
  double _progress = 0;
  String _stage = "Preparing";

  DownloaderViewState(this._downloader, this._meta) {
    _downloader.progressStream.listen(
      (event) => setState(() {
        _progress = event.progress;
        _stage = event.stage;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: DownloadProgressIndicator(
        title: _meta.title,
        subtitle: _meta.channelName,
        progress: _progress,
        stage: _stage,
        thumbnailUrl: _meta.thumbnails.mediumRes,
        semanticName: _meta.title,
      ),
      padding: EdgeInsets.all(4),
    );
  }
}
