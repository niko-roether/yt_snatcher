import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_progress_bar.dart';

class VideoPlayerControls extends StatefulWidget {
  final VlcPlayerController controller;
  final double aspectRatio;
  final bool showControlsImmediately;

  VideoPlayerControls({
    @required this.controller,
    this.aspectRatio = 16 / 9,
    this.showControlsImmediately = true,
  });

  @override
  State<StatefulWidget> createState() => VideoPlayerControlsState();
}

class VideoPlayerControlsState extends State<VideoPlayerControls>
    with SingleTickerProviderStateMixin {
  static const _HIDE_DURATION = Duration(seconds: 3);
  AnimationController _showHideAnimation;
  bool _shown = false;
  bool _playing = false;
  Timer _hideTimer;

  @override
  void initState() {
    _showHideAnimation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    widget.showControlsImmediately ? _show() : _hide();
    widget.controller.addListener(_onControllerUpdate);
    super.initState();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() async {
    final playing = await widget.controller.isPlaying();
    if (!this.mounted) return;
    if (playing != _playing) {
      _playing = playing;
      if (_playing) _scheduleHide();
    }
  }

  void _show() {
    _hideTimer?.cancel();
    _shown = true;
    if (_playing) _scheduleHide();
  }

  void _hide() {
    _hideTimer?.cancel();
    _shown = false;
  }

  void _scheduleHide() {
    _hideTimer = Timer(_HIDE_DURATION, () {
      if (_playing) setState(() => _hide());
    });
  }

  void _onTap() {
    setState(() => _shown ? _hide() : _show());
  }

  @override
  Widget build(BuildContext context) {
    _showHideAnimation.animateTo(_shown ? 1 : 0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onTap(),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: AnimatedBuilder(
          animation: _showHideAnimation,
          builder: (context, child) {
            return Container(
              color: Colors.black26.withAlpha(
                (_showHideAnimation.value * 70).round(),
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              Container(),
              Align(
                child: _VideoPlayerControlsCenter(
                  controller: widget.controller,
                  visible: _shown,
                ),
                alignment: Alignment.center,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _VideoPlayerControlsBottomBar(
                  controller: widget.controller,
                  expanded: _shown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPlayerControlsCenter extends StatefulWidget {
  final VlcPlayerController controller;
  final bool visible;

  _VideoPlayerControlsCenter({@required this.controller, this.visible = true})
      : assert(visible != null);

  @override
  State<StatefulWidget> createState() => _VideoPlayerControlsCenterState();
}

class _VideoPlayerControlsCenterState
    extends State<_VideoPlayerControlsCenter> {
  VlcPlayerController _controller;
  PlayingState _state;

  @override
  void initState() {
    _controller = widget.controller;
    _state = _controller.playingState ?? PlayingState.PAUSED;
    _controller.addListener(_onControllerUpdate);
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

  Widget _buildPlayButton() {
    return IconButton(
      icon: Icon(Icons.play_arrow),
      onPressed: () => _controller.play(),
      iconSize: 40,
    );
  }

  Widget _buildPauseButton() {
    return IconButton(
      icon: Icon(Icons.pause),
      onPressed: () => _controller.pause(),
      iconSize: 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return Container();
    var center;
    if ([PlayingState.PLAYING, PlayingState.BUFFERING].contains(_state))
      center = _buildPauseButton();
    else
      center = _buildPlayButton();

    return center;
  }
}

class _VideoPlayerControlsBottomBar extends StatefulWidget {
  final Color barColor;
  final bool expanded;
  final VlcPlayerController controller;

  _VideoPlayerControlsBottomBar({
    @required this.controller,
    this.barColor,
    this.expanded = false,
  }) : assert(expanded != null);

  @override
  State<StatefulWidget> createState() => _VideoPlayerControlsBottomBarState();
}

class _VideoPlayerControlsBottomBarState
    extends State<_VideoPlayerControlsBottomBar> {
  VlcPlayerController _controller;
  Duration _position;

  @override
  void initState() {
    _controller = widget.controller;
    _controller.addListener(_onControllerUpdate);
    _position = _controller.position ?? Duration.zero;
    super.initState();
  }

  @override
  dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  double _getProgress() {
    if (_controller.duration == Duration.zero) return 0;
    return _position.inMilliseconds / _controller.duration.inMilliseconds;
  }

  String _stringifyDuration(Duration duration) {
    if (duration == null) return "0:00";
    int hours = duration.inHours.floor();
    int minutes = duration.inMinutes.floor() % 60;
    int seconds = duration.inSeconds.floor() % 60;
    // just trust me on this one
    return "${hours > 0 ? "$hours${minutes < 10 ? "0" : ""}:" : ""}$minutes:${seconds < 10 ? "0" : ""}$seconds";
  }

  void _onControllerUpdate() {
    if (_controller.position != _position)
      setState(() => _position = _controller.position);
  }

  void _onDrag(double progress) {
    final newPos = _controller.duration * progress;
    _controller.setTime(newPos.inMilliseconds);
    setState(() => _position = newPos);
  }

  Widget _buildUpperBar() {
    if (!widget.expanded) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
                "${_stringifyDuration(_position)} / ${_stringifyDuration(_controller.duration)}"),
          ),
        ),
        IconButton(
          icon: Icon(Icons.fullscreen),
          onPressed: () => null,
          visualDensity: VisualDensity.compact,
          splashRadius: 8,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        _onDrag(details.localPosition.dx / width);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUpperBar(),
          VideoProgressBar(
            progress: _getProgress(),
            draggable: widget.expanded,
          )
        ],
      ),
    );
  }
}
