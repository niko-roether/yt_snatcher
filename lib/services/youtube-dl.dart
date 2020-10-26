import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:yt_snatcher/services/download.dart';
import 'package:yt_snatcher/services/youtube.dart';

/// Represents the download process of media, i. e. Video or Music
abstract class YoutubeMediaDownload {
  DownloadManager _dl;

  YoutubeMediaDownload(_dl);

  Future<File> download(String filename);
}

/// Represents a Music media download
class YoutubeMusicMediaDownload extends YoutubeMediaDownload {
  YoutubeAudioMedia _audio;
  YoutubeMusicMediaDownload(this._audio, DownloadManager dl) : super(dl);

  @override
  Future<File> download(String filename) => _dl.downloadMusic(filename, _audio);
}

/// Represents a Video (and Audio) media download
class YoutubeVideoMediaDownload extends YoutubeMediaDownload {
  YoutubeVideoMedia _video;
  YoutubeAudioMedia _audio;
  YoutubeVideoMediaDownload(this._video, this._audio, DownloadManager dl)
      : super(dl);

  @override
  Future<File> download(String filename) =>
      _dl.downloadVideo(filename, _video, _audio);
}

/// Represents a download which includes both media and metadata
abstract class YoutubeDownload<M extends YoutubeMediaDownload> {
  final DownloadManager _dl;
  final YoutubeVideoMeta _meta;
  final M _mediaDownload;

  YoutubeDownload(this._meta, this._mediaDownload, this._dl);

  @mustCallSuper
  Future<void> download() {
    _dl.
  }
}

class YoutubeMusicDownload extends YoutubeDownload<YoutubeMusicMediaDownload> {
  YoutubeMusicDownload(YoutubeVideoMeta meta, YoutubeMusicMediaDownload mediaDownload, DownloadManager dl) : super(meta, mediaDownload, dl);

  @override
  Future<void> download() {
    // TODO: implement download
    throw UnimplementedError();
  }
}

/// A set of downloads of a given type
abstract class YoutubeDownloadSet<D extends YoutubeDownload> {
  final DownloadManager _dl;
  final YoutubeVideoMeta _meta;

  YoutubeDownloadSet(this._meta, this._dl);

  D smallest();
  D best();
}

class YoutubeVideoDownloadSet extends YoutubeDownloadSet<Youtube> {
  YoutubeVideoMediaSet _mediaSet;
  YoutubeVideoDownloadSet(
    YoutubeVideoMeta meta,
    this._mediaSet,
    DownloadManager dl,
  ) : super(meta, dl);

  @override
  YoutubeVideoMediaDownload best() {
    // TODO: implement best
    throw UnimplementedError();
  }

  @override
  YoutubeDownload<YoutubeVideoMedia> smallest() {
    // TODO: implement smallest
    throw UnimplementedError();
  }
}

class YoutubeMusicDownloadSet
    extends YoutubeDownloadSet<YoutubeAudioMedia, YoutubeAudioMediaSet> {
  YoutubeMusicDownloadSet(
    YoutubeVideoMeta meta,
    YoutubeAudioMediaSet mediaSet,
    DownloadManager dl,
  ) : super(meta, mediaSet, dl);
}

class YoutubePreDownload {
  final String _id;
  final Youtube _yt;
  final DownloadManager _dl;

  YoutubePreDownload(this._id, this._yt, this._dl);

  Future<YoutubeVideo> _getVideo() => _yt.getVideo(_id);

  Future<YoutubeVideoDownloadSet> asVideo() async {
    var video = await _getVideo();
    return YoutubeVideoDownloadSet(video, video.videoStreams, _dl);
  }

  Future<YoutubeMusicDownloadSet> asMusic() async {
    var video = await _getVideo();
    return YoutubeMusicDownloadSet(video, video.audioStreams, _dl);
  }
}

class YoutubeDL {
  final _dl = DownloadManager();
  final _yt = Youtube();

  void close() {
    _yt.close();
  }

  YoutubePreDownload prepare(String id) => YoutubePreDownload(id, _yt, _dl);
}
