import 'dart:async';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class MergerUserCancelException implements Exception {
  @override
  String toString() {
    return "The merging process was interrupted by the user.";
  }
}

class MergerException extends Error {
  int errcode;

  MergerException(this.errcode);

  @override
  String toString() {
    return "The merging process ran into a problem. Error Code: $errcode";
  }
}

class Merger {
  // Taken straight from youtube-dl. Might adjust further if I find the time
  static const FFMPEG_MERGING_ARGS = ["-vcodec", "copy", "-y"];
  static final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  static void _evaluateErrorCode(int errcode) {
    switch (errcode) {
      case 0:
        return;
      case 255:
        throw MergerUserCancelException();
      default:
        throw MergerException(errcode);
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

  Future<File> merge(
    String file1,
    String file2,
    String out, [
    void Function(int) onProgress,
  ]) async {
    var timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => onProgress(null),
    );
    var res = await _execute([file1, file2], out, FFMPEG_MERGING_ARGS);
    timer.cancel();
    return res;
  }
}
