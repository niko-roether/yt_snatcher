import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/video_player.dart';

class DownloadPlayer extends StatelessWidget {
  final List<Download> downloads;
  final int startAt;
  final bool screenSleep;
  final bool defaultFullscreen;

  DownloadPlayer({
    @required this.downloads,
    this.startAt = 0,
    this.screenSleep = true,
    this.defaultFullscreen = false,
  })  : assert(downloads != null),
        assert(downloads.length > 0),
        assert(startAt != null),
        assert(0 <= startAt && startAt <= downloads.length),
        assert(screenSleep != null),
        assert(defaultFullscreen != null);

  factory DownloadPlayer.single({
    Download download,
    bool screenSleep = true,
    bool defaultFullscreen = false,
  }) {
    return DownloadPlayer(
      downloads: [download],
      screenSleep: screenSleep,
      defaultFullscreen: defaultFullscreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(
      url: downloads[0].mediaFile.path,
      type: VideoSourceType.FILE,
    );
  }
}
