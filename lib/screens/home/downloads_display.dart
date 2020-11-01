import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/watch/play_screen.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/download_view.dart';
import 'package:yt_snatcher/widgets/provider/download_provider.dart';

class DownloadsDisplay extends StatefulWidget {
  final FutureOr<DownloadSet> Function(DownloadManager dlm) selector;
  DownloadsDisplay({@required this.selector});

  @override
  State<StatefulWidget> createState() {
    return DownloadsDisplayState();
  }
}

class DownloadsDisplayState extends State<DownloadsDisplay> {
  DownloadManager _dlm;
  List<Download> _downloads;

  Future<List<Download>> _update() async {
    return Future.value(widget.selector(_dlm))
        .then((dlset) => dlset.getDownloads());
  }

  void _init() {
    _dlm = DownloadProvider.of(context).service;
  }

  Future<void> _refresh() async {
    var dlset = await _update();
    setState(() => _downloads = dlset);
  }

  @override
  Widget build(BuildContext context) {
    final loading = Center(child: CircularProgressIndicator());
    if (_dlm == null) _init();
    if (_downloads == null) {
      _refresh();
      return loading;
    }
    return RefreshIndicator(
      child: ListView.builder(
        itemBuilder: (context, i) {
          var download = _downloads[i];
          return DownloadView(
            download: download,
            onTap: () => Navigator.pushNamed(
              context,
              PlayScreen.ROUTENAME,
              arguments: download,
            ),
          );
        },
        itemCount: _downloads.length,
      ),
      onRefresh: () => _refresh(),
    );
  }
}
