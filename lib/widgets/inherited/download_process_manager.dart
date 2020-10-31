import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_magager.dart';
import 'package:yt_snatcher/services/youtube-dl.dart';
import 'package:yt_snatcher/services/youtube.dart';

class DownloadProcess {
  final Downloader downloader;
  final VideoMeta meta;

  DownloadProcess(this.meta, this.downloader);

  Future<Download> start() => downloader.download();
}

class DownloadService extends InheritedWidget {
  static final _ytdl = YoutubeDL();
  final void Function(DownloadProcess process) add;
  final void Function(DownloadProcess process) remove;
  final List<DownloadProcess> currentDownloads;

  DownloadService({
    Key key,
    @required Widget child,
    @required this.add,
    @required this.remove,
    this.currentDownloads = const [],
  })  : assert(currentDownloads != null),
        assert(add != null),
        assert(remove != null),
        super(key: key, child: child);

  Future<Download> _download<D extends Downloader>(
    DownloaderSet dlset, [
    FutureOr<D> Function(DownloaderSet<D>) selector,
  ]) async {
    var downloader = await selector?.call(dlset) ?? dlset.best();
    var process = DownloadProcess(dlset.video, downloader);
    add(process);
    var dl = await downloader.download();
    remove(process);
    return dl;
  }

  Future<Download> downloadVideo(
    String id, [
    FutureOr<VideoDownloader> Function(VideoDownloaderSet) selector,
  ]) async =>
      _download<VideoDownloader>(await _ytdl.prepare(id).asVideo(), selector);

  Future<Download> downloadMusic(
    String id, [
    FutureOr<MusicDownloader> Function(MusicDownloaderSet) selector,
  ]) async =>
      _download<MusicDownloader>(await _ytdl.prepare(id).asMusic(), selector);

  @override
  bool updateShouldNotify(DownloadService old) {
    return old.currentDownloads != currentDownloads;
  }

  static DownloadService of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DownloadService>();
  }
}

class DownloadProcessManager extends StatefulWidget {
  final Widget child;
  final Key serviceKey;

  DownloadProcessManager({Key key, this.serviceKey, @required this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DownloadProcessManagerState();
  }
}

class DownloadProcessManagerState extends State<DownloadProcessManager> {
  List<DownloadProcess> _processes = [];

  void _add(DownloadProcess process) => setState(() => _processes.add(process));
  void _remove(DownloadProcess process) =>
      setState(() => _processes.remove(process));

  @override
  Widget build(BuildContext context) {
    return DownloadService(
      key: widget.serviceKey,
      child: widget.child,
      add: (p) => _add(p),
      remove: (p) => _remove(p),
      currentDownloads: _processes,
    );
  }
}
