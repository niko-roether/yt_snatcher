import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:yt_snatcher/services/files.dart' as fs;
import 'package:yt_snatcher/services/youtube.dart' as yt;

enum DownloadType { VIDEO, MUSIC }

class DownloadMeta {
  final yt.VideoMeta videoMeta;
  final String id;
  final String filename;
  final File metaFile;
  final DownloadType type;
  final DateTime downloadDate;
  DateTime watchDate;
  String title;
  bool complete;

  DownloadMeta({
    @required this.videoMeta,
    @required this.id,
    @required this.filename,
    @required this.metaFile,
    @required this.type,
    DateTime downloadDate,
    DateTime watchDate,
    this.title,
    this.complete = true,
  })  : assert(videoMeta != null),
        assert(id != null),
        assert(filename != null),
        assert(metaFile != null),
        assert(type != null),
        assert(complete != null),
        this.downloadDate = downloadDate ?? DateTime.now(),
        this.watchDate = watchDate ?? DateTime.now();

  String get displayTitle => title ?? videoMeta.title;

  String toJson() {
    return jsonEncode({
      "videoMeta": videoMeta.toJson(),
      "id": id,
      "filename": filename,
      "type": type.index,
      "downloadDate": downloadDate.millisecondsSinceEpoch,
      "watchDate": watchDate.millisecondsSinceEpoch,
      "name": title,
      "complete": complete
    });
  }

  Future<DownloadMeta> save() async {
    await metaFile.create();
    await metaFile.writeAsString(toJson());
    return this;
  }

  Future<void> delete() async {
    await metaFile?.delete();
  }

  factory DownloadMeta.fromJson(String json, File file) {
    assert(json != null);
    assert(file != null);
    var data = jsonDecode(json);
    return DownloadMeta(
        videoMeta: data["videoMeta"] != null
            ? yt.VideoMeta.fromJson(data["videoMeta"])
            : null,
        id: data["id"],
        filename: data["filename"],
        metaFile: file,
        type: data["type"] != null ? DownloadType.values[data["type"]] : null,
        downloadDate: data["downloadDate"] != null
            ? DateTime.fromMicrosecondsSinceEpoch(data["downloadDate"])
            : null,
        watchDate: data["watchDate"] != null
            ? DateTime.fromMicrosecondsSinceEpoch(data["watchDate"])
            : null,
        title: data["name"],
        complete: data["complete"] ?? true);
  }

  static Future<DownloadMeta> fromFile(File metaFile) async {
    var json = await metaFile.readAsString();
    return DownloadMeta.fromJson(json, metaFile);
  }
}

class Download {
  final DownloadMeta meta;
  final File mediaFile;
  // TODO thumbnail files

  Download(this.meta, this.mediaFile);

  Future<Uint8List> getMedia() async {
    var data = await mediaFile.readAsBytes();
    return data;
  }

  Future<void> delete() async {
    await Future.wait([
      meta?.delete(),
      mediaFile?.delete(),
    ]);
  }
}

class UnknownDownloadException {
  final String id;

  UnknownDownloadException(this.id);

  @override
  String toString() => "The download with id $id does not exist in this set.";
}

abstract class DownloadSet {
  final fs.FileManager _fileManager;
  final List<DownloadMeta> _meta;
  final String _mediaPath;

  DownloadSet(this._mediaPath, this._meta, this._fileManager)
      : assert(_mediaPath != null),
        assert(_meta != null),
        assert(_fileManager != null);

  List<String> get ids => _meta.map((e) => e.id).toList();

  Future<Download> getDownload(String id) async {
    assert(id != null);
    var meta = _meta.firstWhere((e) => e.id == id);
    if (meta == null) throw UnknownDownloadException(id);
    var media = await _getMedia(meta.filename);
    return Download(meta, media);
  }

  bool _validateDownload(Download d) {
    return d != null &&
        d.mediaFile != null &&
        d.mediaFile.existsSync() &&
        d.meta != null &&
        d.meta.videoMeta != null;
  }

  Future<List<Download>> getDownloads() async {
    return (await Future.wait(_meta.map((meta) async {
      return Download(meta, await _getMedia(meta.filename));
    }).toList()))
        .where((d) {
      var valid = _validateDownload(d);
      if (!valid) d.delete();
      return valid;
    }).toList();
  }

  Future<File> _getMedia(String filename) {
    if (filename == null) return null;
    return _fileManager.getExistingLocalFile(_mediaPath, filename);
  }
}

class VideoDownloadSet extends DownloadSet {
  VideoDownloadSet(List<DownloadMeta> meta, fs.FileManager fileManager)
      : super(fs.FileManager.VIDEO_PATH, meta, fileManager);
}

class MusicDownloadSet extends DownloadSet {
  MusicDownloadSet(List<DownloadMeta> meta, fs.FileManager fileManager)
      : super(fs.FileManager.MUSIC_PATH, meta, fileManager);
}

class DownloadManager {
  final _fileManager = fs.FileManager();

  static String getFilename(String name, yt.Media media) =>
      "$name.${media.container}";

  Future<List<DownloadMeta>> _extractMetaData(List<File> metaFiles) {
    return Future.wait(metaFiles
        .map((e) async => DownloadMeta.fromJson(await e.readAsString(), e))
        .toList());
  }

  Future<List<DownloadMeta>> _getMetaData(
    String path, {
    bool completeOnly = true,
  }) async {
    var metaFiles = await _fileManager.getExistingLocalFiles(path);
    return _extractMetaData(metaFiles).then((list) =>
        list.where((data) => !completeOnly || data.complete).toList());
  }

  Future<VideoDownloadSet> getVideos({bool completeOnly = true}) async {
    assert(completeOnly != null);
    return VideoDownloadSet(
      await _getMetaData(
        fs.FileManager.VIDEO_META_PATH,
        completeOnly: completeOnly,
      ),
      _fileManager,
    );
  }

  Future<MusicDownloadSet> getMusic({bool completeOnly = true}) async {
    assert(completeOnly != null);
    return MusicDownloadSet(
      await _getMetaData(
        fs.FileManager.MUSIC_META_PATH,
        completeOnly: completeOnly,
      ),
      _fileManager,
    );
  }

  Future<bool> checkDuplicate(
    String id,
    DownloadType type, {
    bool completeOnly = false,
  }) async {
    DownloadSet dlSet;
    switch (type) {
      case DownloadType.MUSIC:
        dlSet = await getMusic(completeOnly: completeOnly);
        break;
      case DownloadType.VIDEO:
        dlSet = await getVideos(completeOnly: completeOnly);
    }
    return (await dlSet.getDownloads()).any((dl) => dl.meta.id == id);
  }
}
