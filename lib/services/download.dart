import 'dart:io';
import 'dart:typed_data';

import 'package:yt_snatcher/services/files.dart' as fs;
import 'package:yt_snatcher/services/muxer.dart' as mx;
import 'package:yt_snatcher/services/youtube.dart' as yt;

// var download =

class AlreadyExistsException implements Exception {
  String name;

  @override
  String toString() {
    return "The download $name already exists";
  }
}

class Download {
  final File metaFile;
  final File mediaFile;

  Download(this.metaFile, this.mediaFile);

  Future<yt.VideoMeta> getMeta() async {
    var json = await metaFile.readAsString();
    return yt.VideoMeta.fromJson(json);
  }

  Future<Uint8List> getMedia() async {
    var data = await metaFile.readAsBytes();
    return data;
  }
}

class DownloadManager {
  var _fileManager = fs.FileManager();
  var _muxer = mx.Muxer();

  static String getFilename(String name, yt.Media media) =>
      "$name.${media.container}";

  int _getPacketSize(List<int> packet) =>
      packet.length; // TODO is this correct???

  void _monitorStreamProgress(
    Stream<List<int>> stream,
    void Function(int) onProgress,
  ) {
    stream.listen((packet) => onProgress(packet.length));
  }

  Future<File> _downloadMusicMedia(
    String filename,
    yt.AudioMedia media, [
    void Function(int) onProgress,
  ]) {
    var audioStream = media.getStream();
    _monitorStreamProgress(audioStream, onProgress);
    return _fileManager.streamMusicFile(filename, media.getStream());
  }

  Future<File> _downloadVideoMedia(
    String filename,
    yt.VideoMedia video,
    yt.AudioMedia audio, [
    void Function(int) onProgress,
  ]) async {
    var videoStream = video.getStream();
    _monitorStreamProgress(videoStream, onProgress);
    var videoFileFuture =
        _fileManager.streamTempFile("video_$filename", videoStream);

    var audioStream = audio.getStream();
    _monitorStreamProgress(audioStream, onProgress);
    var audioFileFuture =
        _fileManager.streamTempFile("audio_$filename", audioStream);

    var files = await Future.wait([videoFileFuture, audioFileFuture]);

    var muxedFile = await _muxer.mux(files[0], files[1], "muxed_$filename");

    files.forEach((f) => f.delete());

    var file = await muxedFile.copy(filename);
    muxedFile.delete();
    return file;
  }

  String _metaFileName(String name) => name + ".json";

  Future<File> _downloadMusicMeta(String name, yt.VideoMeta meta) {
    return _fileManager.writeMusicMetaFile(_metaFileName(name), meta.toJson());
  }

  Future<File> _downloadVideoMeta(String name, yt.VideoMeta meta) {
    return _fileManager.writeVideoMetaFile(_metaFileName(name), meta.toJson());
  }

  Future<File> _getMusicMeta(String name) =>
      _fileManager.getMusicMetaFile(_metaFileName(name));

  Future<File> _getVideoMeta(String name) =>
      _fileManager.getVideoMetaFile(_metaFileName(name));

  Future<Download> downloadMusic(
    String name,
    yt.VideoMeta meta,
    yt.AudioMedia media, [
    void Function(int) onProgress,
  ]) {
    return _getDownload(
      _downloadMusicMeta(name, meta),
      _downloadMusicMedia(name, media, onProgress),
    );
  }

  Future<Download> downloadVideo(
    String name,
    yt.VideoMeta meta,
    yt.VideoMedia video,
    yt.AudioMedia audio, [
    void Function(int) onProgress,
  ]) {
    return _getDownload(
      _downloadVideoMeta(name, meta),
      _downloadVideoMedia(name, video, audio, onProgress),
    );
  }

  Future<Download> _getDownload(
    Future<File> metaFileFuture,
    Future<File> mediaFileFuture,
  ) async {
    var files = await Future.wait([metaFileFuture, mediaFileFuture]);
    return Download(files[0], files[1]);
  }

  Future<Download> getMusic(String name) {
    // TODO error checking
    return _getDownload(
      _getMusicMeta(name),
      _fileManager.getMusicFile(name),
    );
  }

  Future<Download> getVideo(String name) {
    return _getDownload(
      _getVideoMeta(name),
      _fileManager.getVideoFile(name),
    );
  }
}
