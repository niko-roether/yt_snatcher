import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube-dl.dart';
import 'package:yt_snatcher/services/youtube.dart';
import 'package:yt_snatcher/widgets/download_progress_indicator.dart';

class MediaDownloaderView extends StatefulWidget {
  final MediaDownloader downloader;
  final VideoMeta meta;
  final bool pending;

  MediaDownloaderView({
    @required this.downloader,
    @required this.meta,
    this.pending = false,
  });

  @override
  State<StatefulWidget> createState() {
    return MediaDownloaderViewState();
  }
}

class MediaDownloaderViewState extends State<MediaDownloaderView> {
  double _progress;
  String _stage = "Preparing";
  StreamSubscription _subscription;

  @override
  initState() {
    _progress = widget.downloader.progress;
    _stage = widget.downloader.stage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.downloader != null) {
      _subscription?.cancel();
      _subscription = widget.downloader.progressStream.listen(
        (event) => setState(() {
          _progress = event.progress;
          _stage = event.stage;
        }),
      );
    }
    return Padding(
      child: DownloadProgressIndicator(
        title: widget.meta?.title ?? "Loading...",
        subtitle: widget.meta?.channelName ?? "",
        progress: widget.pending ? null : _progress,
        stage: widget.pending ? "Pending" : _stage,
        thumbnailUrl: widget.meta?.thumbnails?.lowRes ?? null,
        semanticName: widget.meta?.title ?? "content",
        bgColor: widget.pending ? Colors.grey : null,
        onCancel: () => widget.downloader.process.cancel(),
      ),
      padding: EdgeInsets.all(4),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
