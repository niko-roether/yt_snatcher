import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class MuxerUserCancelException implements Exception {
  @override
  String toString() {
    return "The muxing process was interrupted by the user.";
  }
}

class MuxerException implements Exception {
  int errcode;

  MuxerException(this.errcode);

  @override
  String toString() {
    return "The muxing process ran into a problem. Error Code: $errcode";
  }
}

class Muxer {
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  Future<File> mux(File file1, File file2, String out) async {
    int errcode = await _ffmpeg.execute("-i $file1 -i $file2 $out");
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
