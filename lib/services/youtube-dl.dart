import 'package:yt_snatcher/services/youtube.dart' as yt;
import 'package:yt_snatcher/services/download.dart' as dl;

abstract class Downloader {
  dl.DownloadManager _dlManager;
  yt.VideoMeta _meta;
  int _byteCount = 0;

  Downloader(this._meta, this._dlManager);

  Future<dl.Download> download([void Function(double) onProgress]);
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
  Future<dl.Download> download([
    void Function(double) onProgress,
  ]) {
    return _dlManager.downloadVideo(_meta.id, _meta, _video, _audio,
        (int bytes) {
      _byteCount += bytes;
      onProgress?.call(_byteCount / (_video.size + _audio.size));
    });
  }
}

class MusicDownloader extends Downloader {
  yt.AudioMedia _media;
  MusicDownloader(yt.VideoMeta meta, this._media, dl.DownloadManager dlManager)
      : super(meta, dlManager);

  @override
  Future<dl.Download> download([
    void Function(double) onProgress,
  ]) {
    return _dlManager.downloadMusic(_meta.id, _meta, _media, (int bytes) {
      _byteCount += bytes;
      onProgress(_byteCount / (_media.size));
    });
  }
}

abstract class DownloaderSet<D extends Downloader> {
  yt.Video _video;
  dl.DownloadManager _dlManager;

  DownloaderSet(this._video, this._dlManager);

  D best(); // TODO [String maxRes]
  D smallest(); // TODO [String minRes]
}

class VideoDownloaderSet extends DownloaderSet<VideoDownloader> {
  VideoDownloaderSet(yt.Video video, dl.DownloadManager dlManager)
      : super(video, dlManager);

  @override
  VideoDownloader best() {
    return VideoDownloader(
      _video,
      _video.videoStreams.highestResolution(),
      _video.audioStreams.highestBitrate(),
      _dlManager,
    );
  }

  @override
  VideoDownloader smallest() {
    return VideoDownloader(
      _video,
      _video.videoStreams.smallestSize(),
      _video.audioStreams.smallestSize(),
      _dlManager,
    );
  }
}

class MusicDownloaderSet extends DownloaderSet<MusicDownloader> {
  MusicDownloaderSet(yt.Video video, dl.DownloadManager dlManager)
      : super(video, dlManager);

  @override
  MusicDownloader best() {
    return MusicDownloader(
      _video,
      _video.audioStreams.highestBitrate(),
      _dlManager,
    );
  }

  @override
  MusicDownloader smallest() {
    return MusicDownloader(
      _video,
      _video.audioStreams.smallestSize(),
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
