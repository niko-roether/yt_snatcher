// yt.getVideo("dfsdghdfg").muxed.highestQuality();

import 'dart:convert';

import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yte;
import 'package:yt_snatcher/util.dart';

class ThumbnailSet {
  final yte.ThumbnailSet _thumbnailSet;

  ThumbnailSet(this._thumbnailSet);

  String get lowRes => _thumbnailSet.lowResUrl;
  String get mediumRes => _thumbnailSet.mediumResUrl;
  String get highRes => _thumbnailSet.highResUrl;
  String get maxRes => _thumbnailSet.maxResUrl;
  String get standartRes => _thumbnailSet.standardResUrl;
}

class Media<I extends yte.StreamInfo> {
  final yte.YoutubeExplode _yt;
  final I _info;

  Media(this._info, this._yt);

  int get tag => _info.tag;
  String get url => _info.url.toString();
  String get container => _info.container.name;
  int get size => _info.size.totalBytes;
  int get bitrate => _info.bitrate.bitsPerSecond;

  Stream<List<int>> getStream() =>
      _yt.videos.streamsClient.get(_info).asBroadcastStream();
}

class AudioMedia extends Media<yte.AudioStreamInfo> {
  AudioMedia(yte.AudioStreamInfo info, yte.YoutubeExplode yt) : super(info, yt);

  String get audioCodec => _info.audioCodec;
}

class VideoMedia extends Media<yte.VideoStreamInfo> {
  VideoMedia(yte.VideoStreamInfo info, yte.YoutubeExplode yt) : super(info, yt);

  String get videoCodec => _info.videoCodec;
  String get videoQuality => _info.videoQualityLabel;
  Dimension get resolution =>
      Dimension(_info.videoResolution.width, _info.videoResolution.height);
  num get framerate => _info.framerate.framesPerSecond;
}

class MuxedMedia extends Media<yte.MuxedStreamInfo> {
  MuxedMedia(yte.MuxedStreamInfo info, yte.YoutubeExplode yt) : super(info, yt);

  // FIXME code repetition here.
  String get videoCodec => _info.videoCodec;
  String get videoQualityLabel => _info.videoQualityLabel;
  Dimension get resolution =>
      Dimension(_info.videoResolution.width, _info.videoResolution.height);
  num get framerate => _info.framerate.framesPerSecond;
  String get audioCodec => _info.audioCodec;
}

class MediaSet<M extends Media> extends Iterable<M> {
  static final sortByBitrate =
      (Media a, Media b) => a.bitrate.compareTo(b.bitrate);
  static final sortBySize = (Media a, Media b) => a.size.compareTo(b.size);
  final List<M> _media;

  MediaSet(this._media);

  M highestBitrate() {
    return listSort(_media, sortByBitrate).last;
  }

  M smallestSize() {
    return listSort(_media, sortBySize).first;
  }

  @override
  Iterator<M> get iterator => _media.iterator;
}

class VideoMediaSet extends MediaSet<VideoMedia> {
  static final sortByResolution =
      (VideoMedia a, VideoMedia b) => a.resolution.compareTo(b.resolution);

  VideoMediaSet(List<VideoMedia> media) : super(media);

  VideoMedia highestResolution() {
    return listSort(_media, sortByResolution).last;
  }
}

class AudioMediaSet extends MediaSet<AudioMedia> {
  AudioMediaSet(List<AudioMedia> media) : super(media);

  // Additional sorting options if they present themselves in the future
}

class MuxedMediaSet extends MediaSet<MuxedMedia> {
  static final sortByResolution =
      (MuxedMedia a, MuxedMedia b) => a.resolution.compareTo(b.resolution);

  MuxedMediaSet(List<MuxedMedia> media) : super(media);

  // FIXME Code repetition again...
  MuxedMedia highestResolution() {
    return listSort(_media, sortByResolution).last;
  }
}

class VideoMeta {
  final yte.Video _video;

  VideoMeta(this._video);

  String get id => _video.id.value;
  String get title => _video.title;
  String get youtubeUrl => _video.url;
  String get description => _video.description;
  String get channelName => _video.author;
  String get channelId => _video.channelId.value;
  Duration get duration => _video.duration;
  ThumbnailSet get thumbnails => ThumbnailSet(_video.thumbnails);
  DateTime get uploadDate => _video.uploadDate;

  String toJson() => jsonEncode({
        "id": id,
        "title": title,
        "description": description,
        "channelName": channelName,
        "channelId": channelId,
        "duration": duration.toString(),
        "uploadDate": uploadDate.millisecondsSinceEpoch,
      });

  factory VideoMeta.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    var video = yte.Video(
      yte.VideoId(data["id"]),
      data["title"],
      data["channelName"],
      yte.ChannelId(data["channelId"]),
      DateTime.fromMicrosecondsSinceEpoch(data["uploadDate"]),
      data["description"],
      parseDuration(data["duration"]),
      yte.ThumbnailSet(data["id"]),
      null,
      null,
    );
    return VideoMeta(video);
  }
}

class Video extends VideoMeta {
  final yte.YoutubeExplode _yt;
  final yte.StreamManifest _manifest;

  Video(yte.Video video, this._manifest, this._yt) : super(video);

  // Streams
  MediaSet get streams {
    return MediaSet(
      _manifest.streams.map((e) => Media(e, _yt)).toList(),
    );
  }

  VideoMediaSet get videoStreams {
    return VideoMediaSet(
      _manifest.videoOnly.map((e) => VideoMedia(e, _yt)).toList(),
    );
  }

  AudioMediaSet get audioStreams {
    return AudioMediaSet(
      _manifest.audioOnly.map((e) => AudioMedia(e, _yt)).toList(),
    );
  }

  MuxedMediaSet get muxedStreams {
    return MuxedMediaSet(
      _manifest.muxed.map((e) => MuxedMedia(e, _yt)).toList(),
    );
  }
}

class Youtube {
  final yte.YoutubeExplode _yt = yte.YoutubeExplode();

  Future<VideoMeta> getVideoMeta(String id) async {
    return VideoMeta(await retry(() => _yt.videos.get(id), 10));
  }

  Future<Video> getVideo(String id) async {
    return Video(
      await retry(() => _yt.videos.get(id), 10),
      await retry(() => _yt.videos.streamsClient.getManifest(id), 10),
      _yt,
    );
  }

  void close() {
    _yt.close();
  }
}
