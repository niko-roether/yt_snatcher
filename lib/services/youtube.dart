import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_snatcher/util.dart';

class Quality {
  static const HIGHEST_BITRATE = "highest_bitrate";
  static const LOWEST_BITRATE = "lowest_bitrate";
  static const HIGHEST_QUALITY = "highest_quality";
  static const LOWEST_QUALITY = "lowest_quality";
}

abstract class YTQuality<T extends StreamInfo> {
  final String quality;

  YTQuality(this.quality);

  T getStreamInfo(Iterable<T> options) {
    switch (quality) {
      case Quality.HIGHEST_BITRATE:
        return options.withHighestBitrate();
      case Quality.LOWEST_BITRATE:
        return options.sortByBitrate().first;
      default:
        throw "Invalid quality string '$quality' ";
    }
  }
}

class YTVideoQuality extends YTQuality<MuxedStreamInfo> {
  YTVideoQuality(String quality) : super(quality);

  @override
  MuxedStreamInfo getStreamInfo(Iterable<MuxedStreamInfo> options) {
    if (options.getAllVideoQualitiesLabel().contains(options))
      return options
          .firstWhere((element) => element.videoQualityLabel == quality);
    switch (quality) {
      case Quality.HIGHEST_QUALITY:
        return options.sortByVideoQuality().last;
      case Quality.LOWEST_QUALITY:
        return options.sortByVideoQuality().first;
      default:
        return super.getStreamInfo(options);
    }
  }
}

class YTConnection {
  YoutubeExplode _yt;

  YTConnection() {
    _yt = YoutubeExplode();
  }

  Future<StreamManifest> _getManifest(String id) {
    return _yt.videos.streamsClient.getManifest(id);
  }

  Stream<List<int>> _getStreamFromInfo(StreamInfo streamInfo) {
    return _yt.videos.streamsClient.get(streamInfo);
  }

  Stream<List<int>> getVideoStream(String id, YTQuality quality) {
    var streamFuture = _getManifest(id).then((manifest) {
      var info = quality.getStreamInfo(manifest.muxed);
      return _getStreamFromInfo(info);
    });
    return futureIntoStream(streamFuture);
  }

  Stream<List<int>> getAudioStream(String id, YTQuality quality) {
    var streamFuture = _getManifest(id).then((manifest) {
      var info = quality.getStreamInfo(manifest.audioOnly);
      return _getStreamFromInfo(info);
    });
    return futureIntoStream(streamFuture);
  }

  void close() {
    _yt.close();
  }
}
