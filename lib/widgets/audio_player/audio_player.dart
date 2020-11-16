// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:yt_snatcher/services/download_manager.dart';
// import 'package:yt_snatcher/widgets/audio_player/audio_player_controller.dart';

// class YtsAudioPlayer extends StatefulWidget {
//   final List<Download> downloads;
//   final int startIndex;
//   final AudioController controller;

//   YtsAudioPlayer({
//     @required this.controller,
//     @required this.downloads,
//     this.startIndex = 0,
//   })  : assert(downloads != null),
//         assert(startIndex != null);

//   @override
//   State<StatefulWidget> createState() => YtsAudioPlayerState();
// }

// class YtsAudioPlayerState extends State<YtsAudioPlayer> {
//   static MediaItem _dlToMediaItem(Download dl) {
//     return MediaItem(
//       id: dl.mediaFile.path,
//       album: "Youtube Music", // TODO change this when playlists are implemented
//       title: dl.meta.displayTitle,
//       artist: dl.meta.videoMeta.channelName,
//       // TODO change this when thumbnails are being downloaded
//       artUri: dl.meta.videoMeta.thumbnails.highRes,
//       duration: dl.meta.videoMeta.duration,
//       playable: dl.meta.complete,
//       displayDescription: dl.meta.videoMeta.description,
//     );
//   }

//   @override
//   void initState() {
//     widget.controller
//         .setQueue(widget.downloads.map((dl) => _dlToMediaItem(dl)).toList());
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Future(() => widget.controller.init());
//     return StreamBuilder(
//       stream: AudioService.runningStream,
//       builder: (context, snapshot) {
//         if (snapshot.data == null ? true : !snapshot.data)
//           return CircularProgressIndicator();
//         return StreamBuilder<MediaItem>(
//           stream: AudioService.currentMediaItemStream,
//           builder: (context, snapshot) {
//             if (!snapshot.hasData)
//               return _YtsAudioPlayerControls(
//                 active: false,
//               );
//             final item = snapshot.data;
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [Image.network(item.artUri), _YtsAudioPlayerControls()],
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class _YtsAudioPlayerControls extends StatefulWidget {
//   final bool active;

//   _YtsAudioPlayerControls({this.active = true});

//   @override
//   State<StatefulWidget> createState() => _YtsAudioPlayerControlsState();
// }

// class _YtsAudioPlayerControlsState extends State<_YtsAudioPlayerControls>
//     with SingleTickerProviderStateMixin {
//   Set<MediaAction> _actions;
//   AnimationController _playPauseAnimation;

//   @override
//   void initState() {
//     _playPauseAnimation = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 100),
//     );
//     if (widget.active) {
//       AudioService.playbackStateStream.listen((event) {
//         if (_actions != event.actions) setState(() => _actions = event.actions);
//       });
//     }
//     super.initState();
//   }

//   Widget _buildSkipToPrevButton() {
//     return IconButton(
//       icon: Icon(Icons.skip_previous),
//       onPressed: () => AudioService.skipToPrevious(),
//       visualDensity: VisualDensity.compact,
//     );
//   }

//   Widget _buildSkipToNextButton() {
//     return IconButton(
//       icon: Icon(Icons.skip_next),
//       onPressed: () => AudioService.skipToNext(),
//       visualDensity: VisualDensity.compact,
//     );
//   }

//   Widget _buildPlayPauseButton(void Function() onPressed) {
//     return IconButton(
//       icon: AnimatedIcon(
//         icon: AnimatedIcons.play_pause,
//         progress: _playPauseAnimation,
//       ),
//       onPressed: onPressed,
//     );
//   }

//   Widget _buildPlayButton() {
//     return _buildPlayPauseButton(() => AudioService.play());
//   }

//   Widget _buildPauseButton() {
//     return _buildPlayPauseButton(() => AudioService.pause());
//   }

//   Widget _buildNoCenterActionButton() {
//     return IconButton(icon: Icon(Icons.play_arrow), onPressed: null);
//   }

//   Widget _wrapInCircle(Widget child, Color color) {
//     return DecoratedBox(
//       decoration: ShapeDecoration(shape: CircleBorder(), color: color),
//       child: child,
//     );
//   }

//   @override
//   void dispose() {
//     AudioService.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (!widget.active) return _buildPlayButton();

//     Widget leftControl = _actions.contains(MediaAction.skipToPrevious)
//         ? _buildSkipToPrevButton()
//         : Container();
//     Widget centerControl;
//     if (_actions.contains(MediaAction.play)) {
//       centerControl = _buildPlayButton();
//       _playPauseAnimation.animateTo(0);
//     } else if (_actions.contains(MediaAction.pause)) {
//       centerControl = _buildPauseButton();
//       _playPauseAnimation.animateTo(1);
//     } else {
//       centerControl = _buildNoCenterActionButton();
//     }
//     Widget rightControl = _actions.contains(MediaAction.skipToNext)
//         ? _buildSkipToNextButton()
//         : Container();

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _wrapInCircle(leftControl, theme.colorScheme.primary),
//         _wrapInCircle(centerControl, theme.colorScheme.secondary),
//         _wrapInCircle(rightControl, theme.colorScheme.primary),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/audio_player/audio_player_controller.dart';

class YtsAudioPlayer extends StatelessWidget {
  final List<Download> downloads;

  YtsAudioPlayer({@required this.downloads});

  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(child: _AudioPlayer(downloads));
  }
}

class _AudioPlayer extends StatefulWidget {
  final List<Download> downloads;

  _AudioPlayer(this.downloads);

  @override
  State<StatefulWidget> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  final _controller = AudioController();

  static MediaItem _dlToMediaItem(Download dl) {
    return MediaItem(
      id: dl.mediaFile.path,
      album: "Youtube Music", // TODO change this when playlists are implemented
      title: dl.meta.displayTitle,
      artist: dl.meta.videoMeta.channelName,
      // TODO change this when thumbnails are being downloaded
      artUri: dl.meta.videoMeta.thumbnails.highRes,
      duration: dl.meta.videoMeta.duration,
      playable: dl.meta.complete,
      displayDescription: dl.meta.videoMeta.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () => _controller.init());
    return StreamBuilder(
      stream: _controller.runningStream,
      builder: (context, snapshot) {
        if (snapshot.data != true) return CircularProgressIndicator();
        _controller.setQueue(
            widget.downloads.map((dl) => _dlToMediaItem(dl)).toList());
        return StreamBuilder<MediaItem>(
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return Text(jsonEncode(snapshot.data));
          },
        );
      },
    );
  }
}
