import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileDoesNotExistException implements Exception {
  String path;

  FileDoesNotExistException(this.path);

  @override
  String toString() => "The file at $path does not exist.";
}

class FileManager {
  static final _tempPath = "${Directory.systemTemp.path}/yt-snatcher";
  static const _META_SUBDIR = "/meta";
  static const _THUMBNAIL_SUBDIR = "/thumbnails";
  static const VIDEO_PATH = "/videos";
  static const VIDEO_META_PATH = VIDEO_PATH + _META_SUBDIR;
  static const VIDEO_THUMBNAIL_PATH = VIDEO_PATH + _THUMBNAIL_SUBDIR;
  static const MUSIC_PATH = "/music";
  static const MUSIC_META_PATH = MUSIC_PATH + _META_SUBDIR;
  static const MUSIC_THUMBNAIL_PATH = MUSIC_PATH + _THUMBNAIL_SUBDIR;
  FutureOr<String> _localPath;

  Future<String> getLocalPath() => _localPath;

  FileManager([this._localPath]) {
    if (_localPath == null)
      _localPath = getApplicationSupportDirectory().then((dir) => dir.path);
  }

  Future<File> _getLocalFile(String path) async {
    var localPath = await _localPath;
    return File("$localPath$path");
  }

  Future<File> _streamFile(File file, Stream<List<int>> stream) async {
    if (!(await file.exists())) return null;
    var fstream = file.openWrite();
    await stream.pipe(fstream);
    await fstream.close();
    return file;
  }

  Future<File> streamTempFile(String name, Stream<List<int>> stream) async {
    var targetFile = File("$_tempPath/$name");
    await targetFile.create(recursive: true);
    return _streamFile(targetFile, stream);
  }

  Future<File> createLocalFile(
    String dir,
    String name, [
    bool recursive = true,
  ]) async {
    var targetFile = await _getLocalFile("$dir/$name");
    return targetFile.create(recursive: recursive);
  }

  Future<File> streamLocalFile(
    String dir,
    String name,
    Stream<List<int>> stream,
  ) async {
    var targetFile = await createLocalFile(dir, name);
    return _streamFile(targetFile, stream);
  }

  Future<File> writeLocalFile(String dir, String name, String content) async {
    var targetFile = await createLocalFile(dir, name);
    return targetFile.writeAsString(content);
  }

  Future<File> _getExistingFile(String filepath) async {
    var file = await _getLocalFile(filepath);
    if (await file.exists()) return file;
    return null;
  }

  Future<File> getExistingLocalFile(String dir, String filename) =>
      _getExistingFile("$dir/$filename");

  Future<List<File>> getExistingLocalFiles(String dir) async {
    var localPath = await _localPath;
    var entities = await Directory("$localPath$dir").list().toList();
    return entities.map((e) => File.fromUri(e.uri)).toList();
  }
}
