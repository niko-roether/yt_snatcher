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

class DownloadProcessManager extends InheritedWidget {
  static final _ytdl = YoutubeDL();
  final List<DownloadProcess> _currentDownloads = [];

  DownloadProcessManager({Key key, @required Widget child})
      : super(key: key, child: child);

  List<DownloadProcess> get currentDownloads => _currentDownloads;

  Future<Download> _download<D extends Downloader>(
    DownloaderSet dlset, [
    FutureOr<D> Function(DownloaderSet<D>) selector,
  ]) async {
    var downloader = await selector?.call(dlset) ?? dlset.best();
    var process = DownloadProcess(dlset.video, downloader);
    _currentDownloads.add(process);
    var dl = await downloader.download();
    _currentDownloads.remove(process);
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
  bool updateShouldNotify(DownloadProcessManager old) {
    return old._currentDownloads != _currentDownloads;
  }

  static DownloadProcessManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DownloadProcessManager>();
  }
}
