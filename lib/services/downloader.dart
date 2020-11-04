import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:yt_snatcher/services/download_manager.dart';

import 'background.dart';

import 'youtube.dart' as yt;
import 'files.dart' as fs;
import 'ffmpeg.dart';

class DownloadProcess<R extends Download> {
  final TaskProcess<R> _process;
  List<FutureOr<R> Function(R result)> _thenFunctions = [];
  final _completer = Completer<R>();

  DownloadProcess(this._process, {FutureOr<R> Function(R result) then}) {
    if (then != null) _thenFunctions.add(then);
    _process.done.then((dl) async {
      var dlProcessed = then != null ? then(dl) : dl;
      _completer.complete(dlProcessed);
    });
  }

  Future<R> get done => _completer.future;

  void cancel() => _process.cancel();
}

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

  _DownloadInstructions(this.name, this.metaJson, this.localPath)
      : assert(name != null),
        assert(metaJson != null),
        assert(localPath != null);
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
  })  : assert(video != null),
        assert(audio != null),
        assert(videoContainer != null),
        assert(audioCodec != null),
        super(name, metaJson, localPath);
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
  })  : assert(media != null),
        assert(codec != null),
        super(name, metaJson, localPath);
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
  static final _ffmpeg = FFmpeg();
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
    var filename = ins.name;
    var dl = await _createDownload(
      _downloadMusicMeta(filename, ins.getMeta(), fm),
      _downloadMusicMedia(
        filename,
        youtube.getStreamFromInfo(ins.media),
        fm,
        (p) => Task.event(p, port, "progress"),
      ),
    );
    Task.end(dl, port);
  }

  static void _videoDownloadTask(SendPort port) async {
    _VideoDownloadInstructions ins = await Task.getArg(port);
    final fm = fs.FileManager(ins.localPath);
    final youtube = yt.Youtube();
    var dl = await _createDownload(
      _downloadVideoMeta(ins.name, ins.getMeta(), fm),
      _downloadVideoMedia(
        ins.name,
        youtube.getStreamFromInfo(ins.video),
        youtube.getStreamFromInfo(ins.audio),
        fm,
        (p) => Task.event(p, port, "progress"),
      ),
    );
    Task.end(dl, port);
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

  static String _metaFileName(String id) => "$id.json";

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
    fs.FileManager fileManager, [
    void Function(int) onProgress,
  ]) async {
    var videoStream = _monitoredStream(
      video,
      (p) => onProgress(p),
    );
    var videoFileFuture = fileManager.streamTempFile(
      "video_$filename.temp",
      videoStream,
    );

    var audioStream = _monitoredStream(
      audio,
      (p) => onProgress(p),
    );
    var audioFileFuture = fileManager.streamTempFile(
      "audio_$filename.temp",
      audioStream,
    );

    var files = await Future.wait([videoFileFuture, audioFileFuture]);
    if (files.any((f) => f == null)) throw "Failed to get media files";
    return files;
  }

  static Future<File> _mergeVideoFiles(
    String filename,
    File videoFile,
    File audioFile,
    fs.FileManager fileManager,
  ) async {
    var mergedFile = await fileManager.createLocalFile(
      fs.FileManager.VIDEO_PATH,
      filename,
    );

    await _ffmpeg.run(
      [videoFile, audioFile],
      mergedFile,
      overwrite: true,
      vcodec: "copy",
      acodec: "aac",
      format: "mp4",
    );
    videoFile.delete();
    audioFile.delete();

    return mergedFile;
  }

  static Future<DownloadMeta> _downloadMeta({
    @required String path,
    @required String mediaFilename,
    @required yt.VideoMeta meta,
    @required DownloadType type,
    @required fs.FileManager fileManager,
  }) async {
    assert(path != null);
    assert(mediaFilename != null);
    assert(meta != null);
    assert(type != null);
    assert(fileManager != null);
    var filename = _metaFileName(meta.id);
    var dlMeta = DownloadMeta(
      videoMeta: meta,
      id: meta.id,
      filename: mediaFilename,
      metaFile: await fileManager.createLocalFile(path, filename),
      type: type,
      complete: false,
    );
    return dlMeta.save();
  }

  static Future<DownloadMeta> _downloadMusicMeta(
    String mediaFilename,
    yt.VideoMeta meta,
    fs.FileManager fileManager,
  ) =>
      _downloadMeta(
        path: fs.FileManager.MUSIC_META_PATH,
        mediaFilename: mediaFilename,
        meta: meta,
        type: DownloadType.MUSIC,
        fileManager: fileManager,
      );

  static Future<DownloadMeta> _downloadVideoMeta(
    String mediaFilename,
    yt.VideoMeta meta,
    fs.FileManager fileManager,
  ) =>
      _downloadMeta(
        path: fs.FileManager.VIDEO_META_PATH,
        mediaFilename: mediaFilename,
        meta: meta,
        type: DownloadType.VIDEO,
        fileManager: fileManager,
      );

  Future<DownloadProcess> downloadMusic(
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
    var process =
        await _musicDownloadTaskPool.doTask(ins, (p, n) => onProgress(p));
    return DownloadProcess(process, then: (dl) async {
      if (dl == null) {
        print("The download process returned null!");
        return;
      }
      if (await dl.mediaFile.exists()) {
        dl.meta.complete = true;
        dl.meta.save();
        return;
      }
      dl.delete();
      return null;
    });
  }

  Future<DownloadProcess> downloadVideo(
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
    final process = await _videoDownloadTaskPool
        .doTask(
          ins,
          (p, n) => onProgress(p, "Loading"),
        )
        .catchError((e) => throw e);

    return DownloadProcess<Download>(process, then: (dl) async {
      onProgress(null, "Processing");
      final _UnmergedVideoDownload unmerged = dl;
      final mergedFile = await _mergeVideoFiles(
        name,
        unmerged.videoFile,
        unmerged.audioFile,
        _fileManager,
      );

      var download = Download(unmerged.meta, mergedFile);
      if (download != null && await download.mediaFile.exists()) {
        download.meta.complete = true;
        await download.meta.save();
        return download;
      }
      throw Exception("Well something went wrong...");
    });
  }
}
