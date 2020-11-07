import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controller.dart';

class VideoPlayerControlsCenter extends StatefulWidget {
  final VideoPlayerController controller;
  final bool visible;

  VideoPlayerControlsCenter({@required this.controller, this.visible = true})
      : assert(visible != null);

  @override
  State<StatefulWidget> createState() => _VideoPlayerControlsCenterState();
}

class _VideoPlayerControlsCenterState extends State<VideoPlayerControlsCenter>
    with SingleTickerProviderStateMixin {
  AnimationController _playPauseAnimation;
  PlayingState _state;

  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    _state = _controller.playingState ?? PlayingState.PAUSED;
    _controller.addListener(_onControllerUpdate);
    _playPauseAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50));
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    final newState = _controller.playingState;
    if (newState != _state) setState(() => _state = newState);
  }

  Widget _buildPausePlayButton() {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.pause_play,
        progress: _playPauseAnimation,
      ),
      onPressed: () async {
        if (await _controller.isPlaying())
          _controller.pause();
        else
          _controller.play();
      },
      iconSize: 40,
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error, size: 50),
        Text("Video could not be played"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return Container();
    var center;
    if ([PlayingState.PLAYING, PlayingState.PAUSED, PlayingState.STOPPED, null]
        .contains(_state)) {
      center = _buildPausePlayButton();
      if (_state == PlayingState.PLAYING)
        _playPauseAnimation.animateTo(0);
      else
        _playPauseAnimation.animateTo(1);
    } else if (_state == PlayingState.BUFFERING) {
      center = CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
      );
    } else {
      center = _buildError();
    }

    return center;
  }
}
