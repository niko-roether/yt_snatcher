import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controller.dart';

class VideoPlayerControlsCenter extends StatefulWidget {
  final YtsVideoPlayerController controller;
  final bool visible;
  final void Function() onPressed;

  VideoPlayerControlsCenter({
    @required this.controller,
    this.visible = true,
    this.onPressed,
  }) : assert(visible != null);

  @override
  State<StatefulWidget> createState() => _VideoPlayerControlsCenterState();
}

class _VideoPlayerControlsCenterState extends State<VideoPlayerControlsCenter>
    with SingleTickerProviderStateMixin {
  AnimationController _playPauseAnimation;
  VideoPlayerValue _state;

  YtsVideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    _state = _controller.playingState;
    _controller.addListener(_onControllerUpdate);
    _playPauseAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
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
        if (_controller.isPlaying)
          _controller.pause();
        else
          _controller.play();
        widget.onPressed?.call();
      },
      iconSize: 40,
    );
  }

  Widget _buildError(String description) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error, size: 50),
        Text(description),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return Container();
    var center;
    if (!_state.isBuffering && !_state.hasError) {
      center = _buildPausePlayButton();
      if (_state.isPlaying)
        _playPauseAnimation.animateTo(0);
      else
        _playPauseAnimation.animateTo(1);
    } else if (_state.isBuffering) {
      center = CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
      );
    } else {
      center = _buildError(_state.errorDescription);
    }

    return center;
  }
}
