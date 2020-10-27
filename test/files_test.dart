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
  return Stream.fromIterable(packets);
}

Future<T> validFuture<T>(Future<T> future) async {
  expect(future, completes);
  return future;
}

void main() {
  group("FileManager", () {
    const TEST_DIR = "/test";
    test("streaming temporary files", () async {
      final fmgr = FileManager();
      final data = [1, 4, 5, 6, 3, 5, 6, 7, 5, 4];
      final stream = packeterize(data, 3);
      final file = await validFuture(fmgr.streamTempFile("test.data", stream));
      var fileData = (await validFuture(file.readAsBytes())).toList();
      expect(fileData, isA<List<int>>());
      expect(fileData, equals(data));
    });
    test("creating local files", () async {
      final fmgr = FileManager();
      var file = await fmgr.createLocalFile(TEST_DIR, "create_test.txt");
      validateFile(file, "$TEST_DIR/create_test.txt");
      file.delete();
    });
    test("streaming local files", () async {
      final fmgr = FileManager();
      final data = [3, 5, 3, 5, 43, 2, 54];
      final stream = packeterize(data, 3);
      final file = await validFuture(fmgr.streamLocalFile(
        TEST_DIR,
        "stream_test.data",
        stream,
      ));
      validateFile(file, "$TEST_DIR/stream_test.data");
      expect((await validFuture(file.readAsBytes())).toList(), equals(data));
      file.delete();
    });
    test("writing local files", () async {
      final fmgr = FileManager();
      final content = "This is test content.";
      final file = await validFuture(fmgr.writeLocalFile(
        TEST_DIR,
        "write_test.txt",
        content,
      ));
      validateFile(file, "$TEST_DIR/write_test.txt");
      expect(await file.readAsString(), equals(content));
      file.delete();
    });

    test("getting an existing local file", () async {
      final fmgr = FileManager();
      final content = "tempowawy test fiwe OwO";
      final file = await fmgr.writeLocalFile(
        TEST_DIR,
        "get_file_test.txt",
        content,
      );
      final gotFile = await validFuture(fmgr.getExistingLocalFile(
        TEST_DIR,
        "get_file_test.txt",
      ));
      validateFile(gotFile, "$TEST_DIR/get_file_test.txt");
      expect(await gotFile.readAsString(), equals(content));
      file.delete();
    });
    test("getting all existing local files", () async {
      final fmgr = FileManager();
      final numFiles = 5;
      final getContent = (int i) => "file content $i";
      final getName = (int i) => "get_files_test_$i.txt";
      await Future.wait(List.generate(
        numFiles,
        (i) => fmgr.writeLocalFile(TEST_DIR, getName(i), getContent(i)),
      ));
      final gotFiles = await fmgr.getExistingLocalFiles(TEST_DIR);
      gotFiles.asMap().forEach((i, f) async {
        validateFile(f, getName(i));
        expect(await f.readAsString(), equals(getContent(i)));
      });
    });
  });
}
