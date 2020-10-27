import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yt_snatcher/services/files.dart';

Future<void> validateFile(File file, String expectedPath) async {
  expect(file, isNotNull);
  expect(file.path, endsWith(expectedPath));
  expect(await file.exists(), isTrue);
}

Stream<List<T>> packeterize<T>(List<T> data, packetSize) {
  final packets = List.filled((data.length / packetSize).ceil(), <T>[]);
  for (int i = 0; i < packets.length; i++) {
    var end = min(3 * (i + 1), data.length);
    packets[i] = data.sublist(3 * i, end);
  }
  print(data);
  print(packets);
  return Stream.fromIterable(packets);
}

Future<T> validFuture<T>(Future<T> future) async {
  expect(future, completes);
  return future;
}

void main() {
  group("FileManager", () {
    test("Stream Temporary File", () async {
      final fmgr = FileManager();
      final data = [1, 4, 5, 6, 3, 5, 6, 7, 5, 4];
      final stream = packeterize(data, 3);
      final file = await validFuture(fmgr.streamTempFile("test.data", stream));
      var fileData = (await validFuture(file.readAsBytes())).toList();
      expect(fileData, isA<List<int>>());
      expect(fileData, equals(data));
    });
    test("Create Local File", () async {
      final fmgr = FileManager();
      var file = await fmgr.createLocalFile("/test", "create_test.txt");
      validateFile(file, "/test/create_test.txt");
      file.delete();
    });
    test("Stream Local File", () async {
      final fmgr = FileManager();
      final data = [3, 5, 3, 5, 43, 2, 54];
      final stream = packeterize(data, 3);
      final file = await validFuture(fmgr.streamLocalFile(
        "/test",
        "stream_test.data",
        stream,
      ));
      validateFile(file, "/test/stream_test.data");
      expect((await validFuture(file.readAsBytes())).toList(), equals(data));
    });
  });
}
