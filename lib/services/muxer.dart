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

  Future<File> mux(String file1, String file2, String out) async {
    File(out).create(recursive: true);
    int errcode = await _ffmpeg.execute("-y -i $file1 -i $file2 $out");
    switch (errcode) {
      case 0:
        return Future.delayed(Duration(milliseconds: 100), () => File(out));
      case 255:
        throw MuxerUserCancelException();
      default:
        throw MuxerException(errcode);
    }
  }
}
