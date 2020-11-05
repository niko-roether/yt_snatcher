import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/home/download_progress_indicator.dart';
import 'package:yt_snatcher/widgets/provider/download_process_manager.dart';

class OngoingDownloadView extends StatefulWidget {
  final OngoingDownload ongoingDownload;
  final bool pending;

  OngoingDownloadView({
    @required this.ongoingDownload,
    this.pending = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _OngoingDownloadViewState();
  }
}

class _OngoingDownloadViewState extends State<OngoingDownloadView> {
  double _progress;
  String _stage = "Preparing";
  StreamSubscription _subscription;

  @override
  initState() {
    _progress = widget.ongoingDownload.downloader.progress;
    _stage = widget.ongoingDownload.downloader.stage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final downloader = widget.ongoingDownload.downloader;
    final meta = widget.ongoingDownload.meta;
    if (downloader != null) {
      _subscription?.cancel();
      _subscription = downloader.progressStream.listen(
        (event) => setState(() {
          _progress = event.progress;
          _stage = event.stage;
        }),
      );
    }
    return Padding(
      child: DownloadProgressIndicator(
        title: meta?.title ?? "Loading...",
        subtitle: meta?.channelName ?? "",
        progress: widget.pending ? null : _progress,
        stage: widget.pending ? "Pending" : _stage,
        thumbnailUrl: meta?.thumbnails?.lowRes ?? null,
        semanticName: meta?.title ?? "content",
        bgColor: widget.pending ? Colors.grey : null,
        onCancel: () => widget.ongoingDownload.cancel(),
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
