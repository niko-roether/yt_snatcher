import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileDoesNotExistException implements Exception {
  String path;

  FileDoesNotExistException(this.path);

  @override
  String toString() => "The file at $path does not exist.";
}

class FileManager {
  static final _tempPath = "${Directory.systemTemp}/yt-snatcher/";
  static final _videoPath = "videos/";
  static final _musicPath = "music/";
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

  Future<File> streamFile(File file, Stream<List<int>> stream) async {
    var fstream = file.openWrite();
    await stream.pipe(fstream);
    await fstream.close();
    return file;
  }

  Future<File> streamTempFile(String name, Stream<List<int>> stream) {
    var targetFile = File("$_tempPath/$name");
    return streamFile(targetFile, stream);
  }

  Future<File> streamVideoFile(String name, Stream<List<int>> stream) async {
    var targetFile = await _getLocalFile("$_videoPath/$name");
    return streamFile(targetFile, stream);
  }

  Future<File> streamMusicFile(String name, Stream<List<int>> stream) async {
    var targetFile = await _getLocalFile("$_musicPath/$name");
    return streamFile(targetFile, stream);
  }

  Future<File> writeVideoMetaFile(String name, String content) async {
    var targetFile = await _getLocalFile("$_videoPath/meta/$name");
    return targetFile.writeAsString(content);
  }

  Future<File> writeMusicMetaFile(String name, String content) async {
    var targetFile = await _getLocalFile("$_musicPath/meta/$name");
    return targetFile.writeAsString(content);
  }

  Future<File> _getExistingFile(String filepath) async {
    var file = await _getLocalFile(filepath);
    if (await file.exists()) return file;
    throw FileDoesNotExistException(file.path);
  }

  Future<File> getVideoFile(String filename) =>
      _getExistingFile("$_videoPath/$filename");

  Future<File> getMusicFile(String filename) =>
      _getExistingFile("$_musicPath/$filename");

  Future<File> getVideoMetaFile(String filename) =>
      getVideoFile("meta/$filename");
  Future<File> getMusicMetaFile(String filename) =>
      getMusicFile("meta/$filename");

  Future<List<File>> getVideoFiles() async {
    var entities = await Directory(_videoPath).list().toList();
    return entities.map((e) => File.fromUri(e.uri));
  }

  Future<List<File>> getMusicFiles() async {
    var entities = await Directory(_musicPath).list().toList();
    return entities.map((e) => File.fromUri(e.uri));
  }

  Future<List<File>> getVideoMetaFiles() async {
    var entities = await Directory("$_videoPath/meta").list().toList();
    return entities.map((e) => File.fromUri(e.uri));
  }

  Future<List<File>> getMusicMetaFiles() async {
    var entities = await Directory("$_musicPath/meta").list().toList();
    return entities.map((e) => File.fromUri(e.uri));
  }
}
