import 'dart:async';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class MuxerUserCancelException implements Exception {
  @override
  String toString() {
    return "The muxing process was interrupted by the user.";
  }
}

class MuxerException extends Error {
  int errcode;

  MuxerException(this.errcode);

  @override
  String toString() {
    return "The muxing process ran into a problem. Error Code: $errcode";
  }
}

class Muxer {
  // Taken straight from youtube-dl. Might adjust further if I find the time
  static const FFMPEG_MUXING_ARGS = ["-vcodec", "copy", "-y"];
  static final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  static void _evaluateErrorCode(int errcode) {
    switch (errcode) {
      case 0:
        return;
      case 255:
        throw MuxerUserCancelException();
      default:
        throw MuxerException(errcode);
    }
  }

  static Future<File> _execute(
    List<String> inputs,
    String output,
    List<String> args,
  ) async {
    final commandArray = <String>[
      ...inputs.expand((i) => ["-i", i]),
      ...args,
      output,
    ];
    int errcode = await _ffmpeg.executeWithArguments(commandArray);
    _evaluateErrorCode(errcode);
    return File(output);
  }

  Future<File> mux(
    String file1,
    String file2,
    String out, [
    void Function(int) onProgress,
  ]) async {
    var timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => onProgress(null),
    );
    var res = await _execute([file1, file2], out, FFMPEG_MUXING_ARGS);
    timer.cancel();
    return res;
  }
}
