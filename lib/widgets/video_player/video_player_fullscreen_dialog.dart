import 'package:flutter/cupertino.dart';
import 'package:yt_snatcher/widgets/video_player/video_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controller.dart';

class VideoPlayerFullscreenDialog extends StatelessWidget {
  final YtsVideoPlayer player;
  final void Function() exit;
  final YtsVideoPlayerController controller;

  VideoPlayerFullscreenDialog({@required this.player, this.exit})
      : controller = player.controller;

  void _checkShouldExit() {
    if (!controller.fullscreen) exit?.call();
  }

  @override
  Widget build(BuildContext context) {
    _checkShouldExit();
    controller.addListener(_checkShouldExit);
    final landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return RotatedBox(
      quarterTurns: landscape ? 0 : 2,
      child: Builder(builder: (context) {
        final aspectRatio = MediaQuery.of(context).size.aspectRatio;
        return AspectRatio(aspectRatio: aspectRatio, child: player);
      }),
    );
  }
}
