import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Youtube.getManifest("dsfadsf").stream(info);

class YoutubeStream<I extends StreamInfo> {
  final YoutubeExplode _yt;
  final I info;
  YoutubeStream(this.info, this._yt);

  Stream<List<int>> getDataStream() {
    return _yt.videos.streamsClient.get(info);
  }

  void close() {
    _yt.close();
  }
}

class YoutubeStreamSet<I extends StreamInfo> {
  final List<YoutubeStream<I>> streams;
  YoutubeStreamSet(this.streams);

  factory YoutubeStreamSet.from(Iterable<I> streams, YoutubeExplode yt) {
    return YoutubeStreamSet(streams.map((e) => YoutubeStream(e, yt)));
  }
}

class YoutubeManifest {
  final YoutubeExplode _yt;
  final StreamManifest manifest;
  YoutubeManifest(this.manifest, this._yt);

  YoutubeStreamSet<AudioStreamInfo> get audio {
    return YoutubeStreamSet.from(manifest.audio, _yt);
  }

  YoutubeStreamSet<AudioOnlyStreamInfo> get audioOnly {
    return YoutubeStreamSet.from(manifest.audioOnly, _yt);
  }

  YoutubeStreamSet<MuxedStreamInfo> get muxed {
    return YoutubeStreamSet.from(manifest.muxed, _yt);
  }

  YoutubeStreamSet<VideoStreamInfo> get video {
    return YoutubeStreamSet.from(manifest.video, _yt);
  }

  YoutubeStreamSet<VideoOnlyStreamInfo> get videoOnly {
    return YoutubeStreamSet.from(manifest.videoOnly, _yt);
  }

  YoutubeStreamSet<StreamInfo> get all {
    return YoutubeStreamSet.from(manifest.streams, _yt);
  }
}

class Youtube {
  final _yt = YoutubeExplode();

  Future<YoutubeManifest> getManifest(String videoId) async {
    return YoutubeManifest(
      await _yt.videos.streamsClient.getManifest(videoId),
      _yt,
    );
  }

  Future<String> getVideoURL(String videoId) {
    return _yt.videos.streamsClient.getHttpLiveStreamUrl(VideoId(videoId));
  }

  void close() {
    _yt.close();
  }
}

// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:yt_snatcher/util.dart';

// class Quality {
//   static const HIGHEST_BITRATE = "highest_bitrate";
//   static const LOWEST_BITRATE = "lowest_bitrate";
//   static const HIGHEST_QUALITY = "highest_quality";
//   static const LOWEST_QUALITY = "lowest_quality";
// }

// abstract class YTQuality<T extends StreamInfo> {
//   final String quality;

//   YTQuality(this.quality);

//   T getStreamInfo(Iterable<T> options) {
//     switch (quality) {
//       case Quality.HIGHEST_BITRATE:
//         return options.withHighestBitrate();
//       case Quality.LOWEST_BITRATE:
//         return options.sortByBitrate().first;
//       default:
//         throw "Invalid quality string '$quality' ";
//     }
//   }
// }

// class YTVideoQuality extends YTQuality<MuxedStreamInfo> {
//   YTVideoQuality(String quality) : super(quality);

//   @override
//   MuxedStreamInfo getStreamInfo(Iterable<MuxedStreamInfo> options) {
//     if (options.getAllVideoQualitiesLabel().contains(options))
//       return options
//           .firstWhere((element) => element.videoQualityLabel == quality);
//     switch (quality) {
//       case Quality.HIGHEST_QUALITY:
//         return options.sortByVideoQuality().last;
//       case Quality.LOWEST_QUALITY:
//         return options.sortByVideoQuality().first;
//       default:
//         return super.getStreamInfo(options);
//     }
//   }
// }

// class YTConnection {
//   YoutubeExplode _yt;

//   YTConnection() {
//     _yt = YoutubeExplode();
//   }

//   Future<StreamManifest> _getManifest(String id) {
//     return _yt.videos.streamsClient.getManifest(id);
//   }

//   Stream<List<int>> _getStreamFromInfo(StreamInfo streamInfo) {
//     return _yt.videos.streamsClient.get(streamInfo);
//   }

//   Stream<List<int>> getVideoStream(String id, YTQuality quality) {
//     var streamFuture = _getManifest(id).then((manifest) {
//       var info = quality.getStreamInfo(manifest.muxed);
//       return _getStreamFromInfo(info);
//     });
//     return futureIntoStream(streamFuture);
//   }

//   Stream<List<int>> getAudioStream(String id, YTQuality quality) {
//     var streamFuture = _getManifest(id).then((manifest) {
//       var info = quality.getStreamInfo(manifest.audioOnly);
//       return _getStreamFromInfo(info);
//     });
//     return futureIntoStream(streamFuture);
//   }

//   void close() {
//     _yt.close();
//   }
// }
