import 'dart:io';

import 'package:yt_snatcher/services/files.dart';
import 'package:yt_snatcher/services/muxer.dart';
import 'package:yt_snatcher/services/youtube.dart';

class AlreadyExistsException implements Exception {
  String name;

  @override
  String toString() {
    return "The download $name already exists";
  }
}

class Download {
  File meta;
  File media;
}

class DownloadManager {
  var _fileManager = FileManager();
  var _muxer = Muxer();

  static String getFilename(String name, YoutubeMedia media) =>
      "$name.${media.container}";

  Future<File> downloadMusic(String filename, YoutubeAudioMedia media) {
    return _fileManager.streamMusicFile(filename, media.getStream());
  }

  Future<File> downloadVideo(
    String filename,
    YoutubeVideoMedia video,
    YoutubeAudioMedia audio,
  ) async {
    var videoFileFuture =
        _fileManager.streamTempFile("video_$filename", video.getStream());
    var audioFileFuture =
        _fileManager.streamTempFile("audio_$filename", audio.getStream());
    var files = await Future.wait([videoFileFuture, audioFileFuture]);

    var muxedFile = await _muxer.mux(files[0], files[1], "muxed_$filename");

    files.forEach((f) => f.delete());

    var file = await muxedFile.copy(filename);
    muxedFile.delete();
    return file;
  }
}
