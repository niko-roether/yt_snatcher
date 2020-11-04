import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yt_snatcher/screens/video_info/video_info_screen.dart';
import 'package:yt_snatcher/services/download_manager.dart';

// class DownloadPlayer extends StatelessWidget {
//   final Download download;
//   final bool screenSleep;
//   final bool defaultFullscreen;

//   DownloadPlayer({
//     @required this.download,
//     this.screenSleep = true,
//     this.defaultFullscreen = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final controlsConfig = BetterPlayerControlsConfiguration(
//       overflowMenuIconsColor: Theme.of(context).iconTheme.color,
//       overflowMenuCustomItems: [
//         BetterPlayerOverflowMenuItem(
//           Icons.info,
//           "Info",
//           () => Navigator.pushNamed(
//             context,
//             VideoInfoScreen.ROUTENAME,
//             arguments: download.meta.videoMeta,
//           ),
//         ),
//       ],
//     );
//     return BetterPlayer.file(
//       download.mediaFile.path,
//       betterPlayerConfiguration: BetterPlayerConfiguration(
//         allowedScreenSleep: screenSleep,
//         fullScreenByDefault: defaultFullscreen,
//         deviceOrientationsAfterFullScreen: [
//           DeviceOrientation.landscapeLeft,
//           DeviceOrientation.landscapeLeft,
//           DeviceOrientation.portraitUp,
//           DeviceOrientation.portraitDown,
//         ],
//         autoPlay: true,
//         fit: BoxFit.contain,
//         controlsConfiguration: controlsConfig,
//       ),
//     );
//   }
// }

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
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class DownloadPlayerState extends State<DownloadPlayer> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
