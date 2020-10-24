import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static final _TEMP_PATH = "${Directory.systemTemp}/yt-snatcher/";
  static final _VIDEO_PATH = "videos/";
  static final _MUSIC_PATH = "music/";
  static Directory __localPath;

  Future<Directory> _localPath() async {
    if (__localPath == null)
      return __localPath = await getApplicationDocumentsDirectory();
    return __localPath;
  }

  Future<File> _getFile(String dir, {bool recursive = true}) async {
    return await File(dir).create(recursive: recursive);
  }

  Future<File> _getLocalFile(String path, {bool recursive = true}) async {
    var localPath = await _localPath();
    return _getFile("$localPath/$path", recursive: recursive);
  }

  Future<void> streamFile(File file, Stream<List<int>> stream) async {
    var fstream = file.openWrite();
    await stream.pipe(fstream);
    await fstream.close();
  }

  Future<void> streamTempFile(String path, Stream<List<int>> stream) {
    var targetFile = File("$_TEMP_PATH/$path");
    return streamFile(targetFile, stream);
  }

  Future<void> streamVideoFile(String path, Stream<List<int>> stream) async {
    var targetFile = await _getLocalFile("$_VIDEO_PATH/$path");
    return streamFile(targetFile, stream);
  }

  Future<void> streamMusicFile(String path, Stream<List<int>> stream) async {
    var targetFile = await _getLocalFile("$_MUSIC_PATH/$path");
    return streamFile(targetFile, stream);
  }
}
