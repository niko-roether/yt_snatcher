import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yt_snatcher/screens/video_info/video_info_screen.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/provider/orientation_provider.dart';

import 'consumer.dart';

class DownloadPlayer extends StatefulWidget {
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
  State<StatefulWidget> createState() {
    return DownloadPlayerState();
  }
}

class DownloadPlayerState extends State<DownloadPlayer> {
  BetterPlayerController _controller;
  List<BetterPlayerDataSource> _dataSources;
  int _index;

  void _playerEvent(BetterPlayerEventType type, Map<String, dynamic> args) {
    if (type == BetterPlayerEventType.CHANGED_TRACK) {
      print(args);
    }
  }

  @override
  void initState() {
    _index = widget.startAt;
    _dataSources = widget.downloads
        .map((d) => BetterPlayerDataSource(
            BetterPlayerDataSourceType.FILE, d.mediaFile.path))
        .toList();
    _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          allowedScreenSleep: widget.screenSleep,
          fullScreenByDefault: widget.defaultFullscreen,
          fit: BoxFit.contain,
          autoPlay: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            overflowMenuIconsColor: Color(0xffffffff),
            enableOverflowMenu: false,
          ),
          eventListener: (e) =>
              _playerEvent(e.betterPlayerEventType, e.parameters),
        ),
        betterPlayerDataSource:
            _dataSources[0] // TODO support mulitple data sources
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrientationProvider>(
      builder: (context, provider, child) {
        bool fullscreen = provider.orientation == Orientation.landscape;
        if (fullscreen) {
          Timer.run(() => _controller.toggleFullScreen());
        }
        return child;
      },
      child: BetterPlayer(
        controller: _controller,
      ),
    );
  }
}
