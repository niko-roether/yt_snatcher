import 'dart:async';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class FFmpegUserCancelException implements Exception {
  @override
  String toString() {
    return "FFmpeg was interrupted by the user.";
  }
}

class FFmpegException extends Error {
  int errcode;

  FFmpegException(this.errcode);

  @override
  String toString() {
    return "FFmpeg ran into a problem. Error Code: $errcode";
  }
}

class FFmpeg {
  static final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  static void _evaluateErrorCode(int errcode) {
    switch (errcode) {
      case 0:
        return;
      case 255:
        throw FFmpegUserCancelException();
      default:
        throw FFmpegException(errcode);
    }
  }

  List<String> _createCommand(Map<String, dynamic> args, File output) {
    return [
      ...args.entries
          .where((e) => e.key != null && e.value != null)
          .map((e) => MapEntry("-${e.key}", e.value))
          .expand<String>((e) => e.value is Iterable
              ? e.value.expand<String>((s) => <String>[e.key, s])
              : [e.key, e.value])
          .where((a) => a != ""),
      output.path,
    ];
  }

  Future<File> run(
    List<File> input,
    File output, {
    bool overwrite = false,
    String format,
    String codec,
    String vcodec,
    String acodec,
    List<String> mappings,
    // will add more if necessary
  }) async {
    assert(overwrite != null);
    var args = <String, dynamic>{
      "i": input.map((f) => f.path).toList(),
      "y": overwrite ? "" : null,
      "f": format,
      "c": codec,
      "c:v": vcodec,
      "c:a": acodec,
      "map": mappings,
      "hide_banner": "",
    };
    var code = await _ffmpeg.executeWithArguments(_createCommand(args, output));
    _evaluateErrorCode(code);
    return output;
  }

  // TODO fix codec incompatibilities
  Future<File> mergeVideoAndAudio(
    File video,
    File audio,
    File output, {
    overwrite = false,
    String vcodec = "copy",
    String acodec = "aac",
    String format = "matroska",
  }) {
    return run(
      [video, audio],
      output,
      overwrite: overwrite,
      vcodec: vcodec,
      acodec: acodec,
      format: format,
      mappings: ["0:v:0", "1:a:0"],
    );
  }

  void cancelAll() {
    _ffmpeg.cancel();
  }
}
