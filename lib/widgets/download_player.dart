import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/video_info/video_info_screen.dart';
import 'package:yt_snatcher/services/download_manager.dart';

class DownloadPlayer extends StatelessWidget {
  final Download download;

  DownloadPlayer({@required this.download});

  @override
  Widget build(BuildContext context) {
    return BetterPlayer.file(
      download.mediaFile.path,
      betterPlayerConfiguration: BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9, // TODO support different aspect ratios
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          overflowMenuCustomItems: [
            BetterPlayerOverflowMenuItem(
              Icons.info,
              "Info",
              () => Navigator.pushNamed(
                context,
                VideoInfoScreen.ROUTENAME,
                arguments: download.meta.videoMeta,
              ),
            )
          ],
        ),
      ),
    );
  }
}
