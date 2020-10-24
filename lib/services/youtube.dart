// yt.getVideo("dfsdghdfg").muxed.highestQuality();

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_snatcher/util.dart';

class YoutubeThumbnailSet {
  final ThumbnailSet _thumbnailSet;

  YoutubeThumbnailSet(this._thumbnailSet);

  String get lowRes => _thumbnailSet.lowResUrl;
  String get mediumRes => _thumbnailSet.mediumResUrl;
  String get highRes => _thumbnailSet.highResUrl;
  String get maxRes => _thumbnailSet.maxResUrl;
  String get standartRes => _thumbnailSet.standardResUrl;
}

class YoutubeMedia<I extends StreamInfo> {
  final YoutubeExplode _yt;
  final I _info;

  YoutubeMedia(this._info, this._yt);

  int get tag => _info.tag;
  String get url => _info.url.path;
  String get container => _info.container.name;
  int get size => _info.size.totalBytes;
  int get bitrate => _info.bitrate.bitsPerSecond;

  Stream<List<int>> getStream() => _yt.videos.streamsClient.get(_info);
}

class YoutubeAudioMedia extends YoutubeMedia<AudioStreamInfo> {
  YoutubeAudioMedia(AudioStreamInfo info, YoutubeExplode yt) : super(info, yt);

  String get audioCodec => _info.audioCodec;
}

class YoutubeVideoMedia extends YoutubeMedia<VideoStreamInfo> {
  YoutubeVideoMedia(VideoStreamInfo info, YoutubeExplode yt) : super(info, yt);

  String get videoCodec => _info.videoCodec;
  String get videoQuality => _info.videoQualityLabel;
  Dimension get resolution =>
      Dimension(_info.videoResolution.width, _info.videoResolution.height);
  num get framerate => _info.framerate.framesPerSecond;
}

class YoutubeMuxedMedia extends YoutubeMedia<MuxedStreamInfo> {
  YoutubeMuxedMedia(MuxedStreamInfo info, YoutubeExplode yt) : super(info, yt);

  // FIXME code repetition here.
  String get videoCodec => _info.videoCodec;
  String get videoQualityLabel => _info.videoQualityLabel;
  Dimension get resolution =>
      Dimension(_info.videoResolution.width, _info.videoResolution.height);
  num get framerate => _info.framerate.framesPerSecond;
  String get audioCodec => _info.audioCodec;
}

class YoutubeMediaSet<M extends YoutubeMedia> extends Iterable<M> {
  static final HIGHEST_BITRATE =
      (YoutubeMedia a, YoutubeMedia b) => a.bitrate.compareTo(b.bitrate);
  static final LARGEST_SIZE =
      (YoutubeMedia a, YoutubeMedia b) => a.size.compareTo(b.size);
  final List<M> _media;

  YoutubeMediaSet(this._media);

  void sortByBitrate() => _media.sort((a, b) => a.bitrate.compareTo(b.bitrate));

  M highestBitrate() {
    return listSort(_media, HIGHEST_BITRATE).last;
  }

  M smallestSize() {
    return listSort(_media, LARGEST_SIZE).first;
  }

  @override
  Iterator<M> get iterator => _media.iterator;
}

class YoutubeVideoMediaSet extends YoutubeMediaSet<YoutubeVideoMedia> {
  static final HIGHEST_RESOLUTION = (YoutubeVideoMedia a, YoutubeVideoMedia b) {
    return a.resolution.compareTo(b.resolution);
  };
  YoutubeVideoMediaSet(List<YoutubeVideoMedia> media) : super(media);

  YoutubeVideoMedia highestResolution() {
    return listSort(_media, HIGHEST_RESOLUTION).last;
  }
}

class YoutubeAudioMediaSet extends YoutubeMediaSet<YoutubeAudioMedia> {
  YoutubeAudioMediaSet(List<YoutubeAudioMedia> media) : super(media);

  // Additional sorting options if they present themselves in the future
}

class YoutubeMuxedMediaSet extends YoutubeMediaSet<YoutubeMuxedMedia> {
  static final HIGHEST_RESOLUTION = (YoutubeMuxedMedia a, YoutubeMuxedMedia b) {
    return a.resolution.compareTo(b.resolution);
  };
  YoutubeMuxedMediaSet(List<YoutubeMuxedMedia> media) : super(media);

  // FIXME Code repetition again...
  YoutubeMuxedMedia highestResolution() {
    return listSort(_media, HIGHEST_RESOLUTION).last;
  }
}

class YoutubeVideoMeta {
  final Video _video;

  YoutubeVideoMeta(this._video);

  String get title => _video.title;
  String get youtubeUrl => _video.url;
  String get description => _video.description;
  String get channelName => _video.author;
  String get channelId => _video.channelId.value;
  Duration get duration => _video.duration;
  YoutubeThumbnailSet get thumbnails => YoutubeThumbnailSet(_video.thumbnails);
  DateTime get uploadDate => _video.uploadDate;
}

class YoutubeVideo extends YoutubeVideoMeta {
  final YoutubeExplode _yt;
  final StreamManifest _manifest;

  YoutubeVideo(Video video, this._manifest, this._yt) : super(video);

  // Streams
  YoutubeMediaSet get streams {
    return YoutubeMediaSet(
      _manifest.streams.map((e) => YoutubeMedia(e, _yt)).toList(),
    );
  }

  YoutubeVideoMediaSet withVideo() {
    return YoutubeVideoMediaSet(
      _manifest.video.map((e) => YoutubeVideoMedia(e, _yt)).toList(),
    );
  }

  YoutubeVideoMediaSet videoOnly() {
    return YoutubeVideoMediaSet(
      _manifest.videoOnly.map((e) => YoutubeVideoMedia(e, _yt)).toList(),
    );
  }

  YoutubeAudioMediaSet withAudio() {
    return YoutubeAudioMediaSet(
      _manifest.audio.map((e) => YoutubeAudioMedia(e, _yt)).toList(),
    );
  }

  YoutubeAudioMediaSet audioOnly() {
    return YoutubeAudioMediaSet(
      _manifest.audio.map((e) => YoutubeAudioMedia(e, _yt)).toList(),
    );
  }

  YoutubeMuxedMediaSet muxed() {
    return YoutubeMuxedMediaSet(
      _manifest.muxed.map((e) => YoutubeMuxedMedia(e, _yt)).toList(),
    );
  }
}

class Youtube {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<YoutubeVideoMeta> getVideoMeta(String id) async {
    return YoutubeVideoMeta(await _yt.videos.get(id));
  }

  Future<YoutubeVideo> getVideo(String id) async {
    return YoutubeVideo(
      await _yt.videos.get(id),
      await _yt.videos.streamsClient.getManifest(id),
      _yt,
    );
  }

  void close() {
    _yt.close();
  }
}

// --- Previous Implementation ---

// import 'dart:async';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// // Youtube.getManifest("dsfadsf").stream(info);

// class YoutubeMedia<I extends StreamInfo> {
//   final YoutubeExplode _yt;
//   final I _info;
//   YoutubeMedia(this._info, this._yt);

//   Stream<List<int>> getDataStream() {
//     return _yt.videos.streamsClient.get(_info);
//   }

//   String get url {
//     return _info.url.path;
//   }

//   void close() {
//     _yt.close();
//   }
// }

// class YoutubeMediaSet<I extends StreamInfo> {
//   final YoutubeExplode _yt;
//   final Iterable<I> _streams;
//   YoutubeMediaSet(this._streams, this._yt);

//   YoutubeMedia<RI> _getYoutubeMedia<RI extends StreamInfo>(RI info) {
//     return YoutubeMedia<RI>(info, _yt);
//   }

//   List<YoutubeMedia<I>> get streams => _streams.map((e) => _getYoutubeMedia(e));

//   YoutubeMedia<I> get highestBitrate {
//     return _getYoutubeMedia(_streams.withHighestBitrate());
//   }

//   YoutubeMedia<VideoStreamInfo> get highestQuality {
//     if (I is VideoStreamInfo) {
//       return _getYoutubeMedia(
//         (_streams as List<VideoStreamInfo>).sortByVideoQuality().last,
//       );
//     }
//     throw "This media set does not contain any video streams";
//   }
// }

// class YoutubeManifest {
//   final YoutubeExplode _yt;
//   final StreamManifest manifest;
//   YoutubeManifest(this.manifest, this._yt);

//   YoutubeMediaSet<AudioStreamInfo> get audio {
//     return YoutubeMediaSet(manifest.audio, _yt);
//   }

//   YoutubeMediaSet<AudioOnlyStreamInfo> get audioOnly {
//     return YoutubeMediaSet(manifest.audioOnly, _yt);
//   }

//   YoutubeMediaSet<MuxedStreamInfo> get muxed {
//     return YoutubeMediaSet(manifest.muxed, _yt);
//   }

//   YoutubeMediaSet<VideoStreamInfo> get video {
//     return YoutubeMediaSet(manifest.video, _yt);
//   }

//   YoutubeMediaSet<VideoOnlyStreamInfo> get videoOnly {
//     return YoutubeMediaSet(manifest.videoOnly, _yt);
//   }

//   YoutubeMediaSet<StreamInfo> get all {
//     return YoutubeMediaSet(manifest.streams, _yt);
//   }
// }

// class Youtube {
//   final _yt = YoutubeExplode();

//   Future<YoutubeManifest> getManifest(String videoId) async {
//     return YoutubeManifest(
//       await _yt.videos.streamsClient.getManifest(videoId),
//       _yt,
//     );
//   }

//   void close() {
//     _yt.close();
//   }
// }
