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
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  Future<File> mux(
    String file1,
    String file2,
    String out, [
    void Function(int) onProgress,
  ]) async {
    var outFile = File(out);
    outFile.create(recursive: true);
    var progressTimer = Timer.periodic(Duration(seconds: 1), (i) async {
      // var size = await outFile.length();
      // onProgress?.call(size);
      // TODO somehow get progress here????
      onProgress(null);
    });
    int errcode =
        await _ffmpeg.execute("-y -i $file1 -i $file2 $out -vcodec copy");
    progressTimer.cancel();
    switch (errcode) {
      case 0:
        return File(out);
      case 255:
        throw MuxerUserCancelException();
      default:
        throw MuxerException(errcode);
    }
  }
}
