import 'dart:async';
import 'package:http/http.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:yt_snatcher/services/youtube.dart';

const _TEST_ID = "SXJxyUBtguY";

void expectCorrectMetadata(VideoMeta meta) {
  expect(
    meta.id,
    equals(_TEST_ID),
    reason: "The video Id should match the one provided",
  );
  expect(
    meta.title,
    equals("Wir werden gewinnen!!!- Minecraft Varo.2  #1"),
    reason: "The title of the video should be correct",
  );
  expect(
    meta.description,
    equals(
      "Die erste Folge von Minecraft Varo.2  :D!\n"
      "Viel Spaß!\n"
      "\n"
      "Informationen zum Urheberrecht am Projekt im Video\n"
      "\n"
      "Credits:\n"
      "Bensound\n"
      "GermanLetsPlay\n"
      "DJ AG (https://soundcloud.com/djag-4)",
    ),
    reason: "The description of the video should be correct",
  );
  expect(
    meta.channelName,
    equals("Phantom"),
    reason: "The channel name should be correct",
  );
  expect(
    meta.channelId,
    equals("UCZnEoffLZRoLT0iALfJxIuw"),
    reason: "The channel ID should be correct",
  );
  expect(
    meta.duration,
    equals(Duration(minutes: 17, seconds: 14)),
    reason: "The video duration should be correct",
  );
  expect(
    meta.uploadDate,
    equals(DateTime(2017, 3, 31)),
    reason: "The video upload date should be correct",
  );
  expect(
    meta.thumbnails,
    equals(ThumbnailSet.fromId(_TEST_ID)),
    reason: "The video thumbnails should be correct",
  );
  expect(
    meta.youtubeUrl,
    "https://www.youtube.com/watch?v=$_TEST_ID",
    reason: "The youtube url should be correct",
  );
}

void main() {
  group("Youtube", () {
    test("getting video metadata", () async {
      final yt = Youtube();
      final meta = await yt.getVideoMeta(_TEST_ID);
      expectCorrectMetadata(meta);
    });
    test("getting youtube video", () async {
      final yt = Youtube();
      final video = await yt.getVideo(_TEST_ID);
      expectCorrectMetadata(video);
      expect(
        video.videoStreams,
        isNotEmpty,
        reason: "Videos should provide video streams",
      );
      expect(
        video.audioStreams,
        isNotEmpty,
        reason: "Videos should provide audio streams",
      );
      expect(
        video.muxedStreams,
        isNotEmpty,
        reason: "Videos should provide muxed streams",
      );
      var client = Client();
      await Future.wait(video.streams.map((stream) async {
        var res = await client.head(stream.url);
        expect(
          res.headers.keys,
          contains("content-length"),
          reason:
              "The HTTP-response for all stream urls should provide a content length",
        );
        expect(
          res.headers.keys,
          contains("content-type"),
          reason:
              "The HTTP-response for all stream urls should provide a content type",
        );
        expect(
          int.parse(res.headers["content-length"]),
          equals(stream.size),
          reason:
              "The data provided by the url should be the same size as the stream",
        );
        expect(
          res.headers["content-type"].split("/").last,
          equals(stream.container),
          reason:
              "The data provided by the url should have the same container as the stream",
        );
      }).toList());
    });
  });
}
