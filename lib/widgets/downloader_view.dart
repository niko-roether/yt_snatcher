import 'dart:html';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube-dl.dart';
import 'package:yt_snatcher/services/youtube.dart';
import 'package:yt_snatcher/widgets/download_progress_indicator.dart';

class DownloaderView extends StatefulWidget {
  final Downloader downloader;
  final VideoMeta meta;
  final bool pending;

  DownloaderView({
    @required this.downloader,
    @required this.meta,
    this.pending = false,
  });

  @override
  State<StatefulWidget> createState() {
    return DownloaderViewState(downloader, meta, pending);
  }
}

class DownloaderViewState extends State<DownloaderView> {
  final Downloader _downloader;
  final VideoMeta _meta;
  final bool _pending;
  double _progress = 0;
  String _stage = "Preparing";

  DownloaderViewState(this._downloader, this._meta, this._pending) {
    if (_downloader == null) return;
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
        title: _meta.title ?? "Loading...",
        subtitle: _meta.channelName ?? "",
        progress: _pending ? null : _progress,
        stage: _pending ? "Pending" : _stage,
        thumbnailUrl: _meta.thumbnails?.mediumRes ?? null,
        semanticName: _meta.title ?? "content",
        bgColor: _pending ? Colors.grey : null,
      ),
      padding: EdgeInsets.all(4),
    );
  }
}
