import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controls.dart';
import 'package:yt_snatcher/widgets/video_player/video_progress_bar.dart';

// class VideoPlayerControls extends StatefulWidget {
//   final VlcPlayerController controller;
//   final double aspectRatio;

//   VideoPlayerControls({
//     @required this.controller,
//     @required this.aspectRatio,
//   });

//   @override
//   State<StatefulWidget> createState() => _VideoPlayerControlsState();
// }

// class _VideoPlayerControlsState extends State<VideoPlayerControls>
//     with TickerProviderStateMixin {
//   PlayingState _state;
//   AnimationController _centerIconAnimationController;

//   _VideoPlayerControlsState() {
//     _centerIconAnimationController = AnimationController(
//       duration: Duration(milliseconds: 100),
//       vsync: this,
//     );
//   }

//   @override
//   initState() {
//     _state = widget.controller.playingState;
//     widget.controller.addListener(() {
//       if (widget.controller.playingState != _state)
//         setState(() => _state = widget.controller.playingState);
//     });
//     super.initState();
//   }

//   bool _isPlaying() => [PlayingState.PLAYING, PlayingState.BUFFERING]
//       .contains(widget.controller.playingState);

//   bool _isPaused() => [PlayingState.PAUSED, PlayingState.STOPPED, null]
//       .contains(widget.controller.playingState);

//   Widget _getPlayPauseIcon() {
//     return AnimatedIcon(
//       icon: AnimatedIcons.play_pause,
//       progress: _centerIconAnimationController,
//       size: 50,
//     );
//   }

//   void _togglePlaying() {
//     if ([PlayingState.PLAYING, PlayingState.BUFFERING]
//         .contains(widget.controller.playingState))
//       widget.controller.pause();
//     else if ([PlayingState.PAUSED, PlayingState.STOPPED, null]
//         .contains(widget.controller.playingState)) widget.controller.play();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget center;
//     if (_isPaused()) {
//       _centerIconAnimationController.animateTo(0);
//       center = _getPlayPauseIcon();
//     } else if (_isPlaying()) {
//       _centerIconAnimationController.animateTo(1);
//       center = _getPlayPauseIcon();
//     } else {
//       center = Column(
//         children: [Icon(Icons.error), Text("Failed to load video")],
//         mainAxisSize: MainAxisSize.min,
//       );
//     }
//     return InkWell(
//       onTap: () => _togglePlaying(),
//       child: AspectRatio(
//         aspectRatio: widget.aspectRatio,
//         child: Column(
//           children: [
//             Container(),
//             center,
//             VlcControllerProgressIndicator(
//               _controller: widget.controller,
//             ),
//           ],
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           mainAxisSize: MainAxisSize.max,
//         ),
//       ),
//     );
//   }
// }

enum VideoSourceType { FILE, NETWORK }

class VideoPlayer extends StatefulWidget {
  final String url;
  final VideoSourceType type;
  final bool autoplay;

  VideoPlayer({@required this.url, @required this.type, this.autoplay = false})
      : assert(type != null),
        assert(autoplay != null);

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  static const double _ASPECT_RATIO = 16 / 9;
  VlcPlayerController _controller;

  _VideoPlayerState() {
    _controller = VlcPlayerController(onInit: () {
      if (widget.autoplay) _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      VlcPlayer(
        aspectRatio: _ASPECT_RATIO,
        controller: _controller,
        url: widget.url,
        isLocalMedia: widget.type == VideoSourceType.FILE,
        placeholder: Center(child: CircularProgressIndicator()),
      ),
      VideoPlayerControls(
        controller: _controller,
        aspectRatio: _ASPECT_RATIO,
      ),
    ]);
  }
}
