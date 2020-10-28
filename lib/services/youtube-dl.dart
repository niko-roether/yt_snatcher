import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube.dart' as yt;
import 'package:yt_snatcher/services/download.dart' as dl;

class DownloadProgress {
  final double progress;
  final String stage;

  DownloadProgress(this.progress, this.stage);
}

abstract class Downloader {
  dl.DownloadManager _dlManager;
  yt.VideoMeta _meta;
  int _byteCount = 0;
  final StreamController<DownloadProgress> _progressStreamController =
      StreamController.broadcast();

  Downloader(this._meta, this._dlManager);

  Stream<DownloadProgress> get progressStream =>
      _progressStreamController.stream;

  void _progressEvent(double progress, String stage) {
    var evt = DownloadProgress(progress, stage);
    _progressStreamController.add(evt);
  }

  Future<dl.Download> download();

  @mustCallSuper
  void _completed() {
    _progressStreamController.close();
  }
}

class VideoDownloader extends Downloader {
  yt.VideoMedia _video;
  yt.AudioMedia _audio;

  VideoDownloader(
    yt.VideoMeta meta,
    this._video,
    this._audio,
    dl.DownloadManager dlManager,
  ) : super(meta, dlManager);

  @override
  Future<dl.Download> download() async {
    var dl = await _dlManager.downloadVideo(
      _meta.id,
      _meta,
      _video,
      _audio,
      (int bytes, String stage) {
        if (bytes == null) {
          if (bytes == null && _byteCount != null)
            _progressEvent(_byteCount = null, stage);
          return;
        }
        _byteCount += bytes;
        _progressEvent(_byteCount / (_video.size + _audio.size), stage);
      },
    );
    _completed();
    return dl;
  }
}

class MusicDownloader extends Downloader {
  yt.AudioMedia _media;
  MusicDownloader(yt.VideoMeta meta, this._media, dl.DownloadManager dlManager)
      : super(meta, dlManager);

  @override
  Future<dl.Download> download() async {
    var dl =
        await _dlManager.downloadMusic(_meta.id, _meta, _media, (int bytes) {
      _byteCount += bytes;
      _progressEvent(_byteCount / (_media.size), "Loading");
    });
    _completed();
    return dl;
  }
}

abstract class DownloaderSet<D extends Downloader> {
  final yt.Video video;
  final dl.DownloadManager _dlManager;

  DownloaderSet(this.video, this._dlManager);

  D best([String maxRes]); // TODO [String maxRes]
  D smallest([String minRes]); // TODO [String minRes]
}

class VideoDownloaderSet extends DownloaderSet<VideoDownloader> {
  VideoDownloaderSet(yt.Video video, dl.DownloadManager dlManager)
      : super(video, dlManager);

  @override
  VideoDownloader best([String maxRes]) {
    return VideoDownloader(
      video,
      video.videoStreams.highestResolution(),
      video.audioStreams.highestBitrate(),
      _dlManager,
    );
  }

  @override
  VideoDownloader smallest([String minRes]) {
    return VideoDownloader(
      video,
      video.videoStreams.smallestSize(),
      video.audioStreams.smallestSize(),
      _dlManager,
    );
  }
}

class MusicDownloaderSet extends DownloaderSet<MusicDownloader> {
  MusicDownloaderSet(yt.Video video, dl.DownloadManager dlManager)
      : super(video, dlManager);

  @override
  MusicDownloader best([String maxRes]) {
    return MusicDownloader(
      video,
      video.audioStreams.highestBitrate(),
      _dlManager,
    );
  }

  @override
  MusicDownloader smallest([String minRes]) {
    return MusicDownloader(
      video,
      video.audioStreams.smallestSize(),
      _dlManager,
    );
  }
}

class PreDownload {
  String id;
  yt.Youtube _yt;
  dl.DownloadManager _dlManager;

  PreDownload(this.id, this._yt, this._dlManager);

  Future<yt.Video> _getVideo() => _yt.getVideo(id);

  Future<DownloaderSet> asVideo() async {
    return VideoDownloaderSet(await _getVideo(), _dlManager);
  }

  Future<DownloaderSet> asMusic() async {
    return MusicDownloaderSet(await _getVideo(), _dlManager);
  }
}

class YoutubeDL {
  final _yt = yt.Youtube();
  final _dlManager = dl.DownloadManager();

  PreDownload prepare(String id) => PreDownload(id, _yt, _dlManager);

  void close() => _yt.close();
}
