import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/video_player/video_player.dart';

class DownloadPlayer extends StatelessWidget {
  final List<Download> downloads;
  final Duration startAt;
  final bool screenSleep;
  final bool defaultFullscreen;
  final bool autoplay;
  final void Function(VlcPlayerController controller) listener;
  final void Function() onBack;

  DownloadPlayer({
    @required this.downloads,
    this.startAt = Duration.zero,
    this.screenSleep = true,
    this.defaultFullscreen = false,
    this.autoplay = true,
    this.listener,
    this.onBack,
  })  : assert(downloads != null),
        assert(downloads.length > 0),
        assert(startAt != null),
        assert(screenSleep != null),
        assert(defaultFullscreen != null);

  factory DownloadPlayer.single({
    Download download,
    bool screenSleep = true,
    bool defaultFullscreen = false,
    void Function(VlcPlayerController controller) listener,
    Duration startAt = Duration.zero,
    bool autoplay = true,
    void Function() onBack,
  }) {
    return DownloadPlayer(
      downloads: [download],
      screenSleep: screenSleep,
      defaultFullscreen: defaultFullscreen,
      listener: listener,
      startAt: startAt,
      autoplay: autoplay,
      onBack: onBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(
      url: downloads[0].mediaFile.path,
      type: VideoSourceType.FILE,
      autoplay: autoplay,
      listener: listener,
      startAt: startAt,
      onBack: () => onBack?.call(),
    );
  }
}
