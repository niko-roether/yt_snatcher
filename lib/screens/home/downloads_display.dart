import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/watch/watch_screen.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/screens/home/download_view.dart';
import 'package:yt_snatcher/widgets/provider/download_provider.dart';

class DownloadsDisplay extends StatefulWidget {
  final FutureOr<DownloadSet> Function(DownloadManager dlm) selector;
  DownloadsDisplay({@required this.selector}) : assert(selector != null);

  @override
  State<StatefulWidget> createState() {
    return _DownloadsDisplayState();
  }
}

class _DownloadsDisplayState extends State<DownloadsDisplay> {
  DownloadManager _dlm;
  List<Download> _downloads;
  StreamSubscription<List<Download>> _refreshStreamSubscription;

  Future<List<Download>> _update() async {
    return Future.value(widget.selector(_dlm))
        .then((dlset) => dlset.getDownloads());
  }

  void _init() {
    _dlm = DownloadProvider.of(context).service;
  }

  Future<void> _refresh() async {
    _refreshStreamSubscription = _update().asStream().listen((dlset) {
      setState(() => _downloads = dlset);
    });
  }

  @override
  void dispose() {
    _refreshStreamSubscription?.cancel();
    super.dispose();
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
      backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        itemBuilder: (context, i) {
          var download = _downloads[i];
          return DownloadView(
            download: download,
            onTap: () => Navigator.pushNamed(
              context,
              WatchScreen.ROUTENAME,
              arguments: download,
            ),
            onChange: () => _refresh(),
          );
        },
        itemCount: _downloads.length,
      ),
      onRefresh: () => _refresh(),
    );
  }
}
