import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:yt_snatcher/services/download_manager.dart';

import 'background.dart';

import 'youtube.dart' as yt;
import 'files.dart' as fs;
import 'merger.dart' as mg;

class _UnmergedVideoDownload extends Download {
  File videoFile;
  File audioFile;

  _UnmergedVideoDownload(DownloadMeta meta, this.videoFile, this.audioFile)
      : super(meta, videoFile);
}

abstract class _DownloadInstructions {
  final String name;
  final String metaJson;
  final String localPath;

  yt.VideoMeta getMeta() => yt.VideoMeta.fromJson(metaJson);

  _DownloadInstructions(this.name, this.metaJson, this.localPath);
}

class _VideoDownloadInstructions extends _DownloadInstructions {
  final yt.MediaInfo video;
  final String videoContainer;
  final yt.MediaInfo audio;
  final String audioCodec;

  _VideoDownloadInstructions({
    @required String name,
    @required String metaJson,
    @required this.video,
    @required this.audio,
    @required this.videoContainer,
    @required this.audioCodec,
    @required String localPath,
  }) : super(name, metaJson, localPath);
}

class _AudioDownloadInstructions extends _DownloadInstructions {
  final yt.MediaInfo media;
  final String codec;

  _AudioDownloadInstructions({
    @required String name,
    @required String metaJson,
    @required this.media,
    @required this.codec,
    @required String localPath,
  }) : super(name, metaJson, localPath);
}

Stream<List<int>> _monitoredStream(
  Stream<List<int>> stream,
  void Function(int) onProgress,
) {
  return stream.asyncMap((packet) {
    onProgress?.call(packet.length);
    return packet;
  });
}

class Downloader {
  static const _NUM_DOWNLOAD_THREADS = 5;
  fs.FileManager _fileManager;
  static final _merger = mg.Merger();
  static final _musicDownloadTaskPool =
      TaskPool<_AudioDownloadInstructions, Download>(
    _musicDownloadTask,
    _NUM_DOWNLOAD_THREADS,
  );
  static final _videoDownloadTaskPool =
      TaskPool<_VideoDownloadInstructions, _UnmergedVideoDownload>(
    _videoDownloadTask,
    _NUM_DOWNLOAD_THREADS,
  );

  Downloader([String localPath]) : _fileManager = fs.FileManager(localPath);

  static void _musicDownloadTask(SendPort port) async {
    _AudioDownloadInstructions ins = await Task.getArg(port);
    final fm = fs.FileManager(ins.localPath);
    final youtube = yt.Youtube();
    var filename = "${ins.name}.${ins.codec}";
    var dl = await _createDownload(
      _downloadMusicMeta(ins.name, filename, ins.getMeta(), fm),
      _downloadMusicMedia(
        filename,
        youtube.getStreamFromInfo(ins.media),
        fm,
        (p) => port.send(Task.createEvent(p)),
      ),
    );
    port.send(dl);
  }

  static void _videoDownloadTask(SendPort port) async {
    _VideoDownloadInstructions ins = await Task.getArg(port);
    final fm = fs.FileManager(ins.localPath);
    final youtube = yt.Youtube();
    var filename = _mergedFilename(ins.name, ins.videoContainer);
    var dl = await _createDownload(
      _downloadVideoMeta(ins.name, filename, ins.getMeta(), fm),
      _downloadVideoMedia(
        filename,
        youtube.getStreamFromInfo(ins.video),
        youtube.getStreamFromInfo(ins.audio),
        ins.videoContainer,
        ins.audioCodec,
        fm,
        (p) => port.send(Task.createEvent(p)),
      ),
    );
    port.send(dl);
  }

  static Future<Download> _createDownload(
    Future<DownloadMeta> metaFuture,
    Future<List<File>> mediaFilesFuture,
  ) async {
    Object error;
    var data = await Future.wait([
      metaFuture.catchError((e) => error = e),
      mediaFilesFuture.catchError((e) => error = e),
    ]);
    var meta = data[0] as DownloadMeta;
    var mediaFiles = data[1] as List<File>;

    if (error != null) {
      await meta?.delete();
      await Future.wait(mediaFiles?.map((f) => f?.delete())?.toList());
      throw error;
    }

    if (mediaFiles.length == 1)
      return Download(meta, mediaFiles[0]);
    else if (mediaFiles.length == 2)
      return _UnmergedVideoDownload(meta, mediaFiles[0], mediaFiles[1]);
    return null;
  }

  static String _metaFileName(String name) => "$name.json";
  static String _mergedFilename(String name, String container) =>
      "$name.$container";

  static Future<List<File>> _downloadMusicMedia(
    String filename,
    Stream<List<int>> media,
    fs.FileManager fileManager, [
    void Function(int) onProgress,
  ]) {
    var audioStream = _monitoredStream(media, onProgress);
    return fileManager
        .streamLocalFile(
          fs.FileManager.MUSIC_PATH,
          filename,
          audioStream,
        )
        .then((f) => [f]);
  }

  static Future<List<File>> _downloadVideoMedia(
    String filename,
    Stream<List<int>> video,
    Stream<List<int>> audio,
    String videoContainer,
    String audioCodec,
    fs.FileManager fileManager, [
    void Function(int) onProgress,
  ]) async {
    var videoStream = _monitoredStream(
      video,
      (p) => onProgress(p),
    );
    var videoFileFuture = fileManager.streamTempFile(
      "video_$filename.$videoContainer",
      videoStream,
    );

    var audioStream = _monitoredStream(
      audio,
      (p) => onProgress(p),
    );
    var audioFileFuture = fileManager.streamTempFile(
      "audio_$filename.$audioCodec",
      audioStream,
    );

    var files = await Future.wait([videoFileFuture, audioFileFuture]);
    if (files.any((f) => f == null)) throw "Failed to get media files";
    return files;
  }

  static Future<File> _mergeVideoFiles(
    String filename,
    String videoFile,
    String audioFile,
    Function(int) onProgress,
    fs.FileManager fileManager,
  ) async {
    var mergedFile = await fileManager.createLocalFile(
      fs.FileManager.VIDEO_PATH,
      filename,
    );

    await _merger.merge(videoFile, audioFile, mergedFile.path, onProgress);
    File(videoFile).delete();
    File(audioFile).delete();

    return mergedFile;
  }

  static Future<DownloadMeta> _downloadMeta({
    @required String path,
    @required String name,
    @required String mediaFilename,
    @required yt.VideoMeta meta,
    @required DownloadType type,
    @required fs.FileManager fileManager,
  }) async {
    var filename = _metaFileName(name);
    var dlMeta = DownloadMeta(
      videoMeta: meta,
      id: name,
      filename: mediaFilename,
      metaFile: await fileManager.createLocalFile(path, filename),
      type: type,
      complete: false,
    );
    return dlMeta.save();
  }

  static Future<DownloadMeta> _downloadMusicMeta(
    String name,
    String mediaFilename,
    yt.VideoMeta meta,
    fs.FileManager fileManager,
  ) =>
      _downloadMeta(
        path: fs.FileManager.MUSIC_META_PATH,
        name: name,
        mediaFilename: mediaFilename,
        meta: meta,
        type: DownloadType.MUSIC,
        fileManager: fileManager,
      );

  static Future<DownloadMeta> _downloadVideoMeta(
    String name,
    String mediaFilename,
    yt.VideoMeta meta,
    fs.FileManager fileManager,
  ) =>
      _downloadMeta(
        path: fs.FileManager.VIDEO_META_PATH,
        name: name,
        mediaFilename: mediaFilename,
        meta: meta,
        type: DownloadType.VIDEO,
        fileManager: fileManager,
      );

  Future<Download> downloadMusic(
    String name,
    yt.VideoMeta meta,
    yt.AudioMedia media, [
    void Function(int) onProgress,
  ]) async {
    var ins = _AudioDownloadInstructions(
      codec: media.audioCodec,
      media: media.getInfo(),
      metaJson: meta.toJson(),
      name: name,
      localPath: await _fileManager.getLocalPath(),
    );
    var download =
        await _musicDownloadTaskPool.doTask(ins, (p) => onProgress(p));
    if (download != null && await download.mediaFile.exists()) {
      download.meta.complete = true;
      download.meta.save();
    }
    return download;
  }

  Future<Download> downloadVideo(
    String name,
    yt.VideoMeta meta,
    yt.VideoMedia video,
    yt.AudioMedia audio, [
    void Function(int, String) onProgress,
  ]) async {
    var ins = _VideoDownloadInstructions(
      audio: audio.getInfo(),
      audioCodec: audio.audioCodec,
      metaJson: meta.toJson(),
      name: name,
      video: video.getInfo(),
      videoContainer: video.container,
      localPath: await _fileManager.getLocalPath(),
    );
    var unmerged = await _videoDownloadTaskPool
        .doTask(
          ins,
          (p) => onProgress(p, "Loading"),
        )
        .catchError((e) => throw e);
    var mergedFile = await _mergeVideoFiles(
      _mergedFilename(name, video.container),
      unmerged.videoFile.path,
      unmerged.audioFile.path,
      (p) => onProgress(p, "Processing"),
      _fileManager,
    );

    var download = Download(unmerged.meta, mergedFile);
    if (download != null && await download.mediaFile.exists()) {
      download.meta.complete = true;
      await download.meta.save();
      return download;
    }
    throw Exception("Well something went wrong...");
  }
}
