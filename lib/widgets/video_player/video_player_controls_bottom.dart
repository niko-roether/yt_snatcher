import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controller.dart';
import 'package:yt_snatcher/widgets/video_player/video_progress_bar.dart';

import '../../util.dart';

class VideoPlayerControlsBottom extends StatefulWidget {
  final Color barColor;
  final bool expanded;
  final VideoPlayerController controller;
  final Duration animationDuration;
  final bool fullscreen;
  final void Function() onDragStart;
  final void Function() onDragEnd;

  VideoPlayerControlsBottom({
    @required this.controller,
    this.barColor,
    this.expanded = false,
    this.animationDuration = const Duration(milliseconds: 100),
    this.fullscreen = false,
    this.onDragStart,
    this.onDragEnd,
  }) : assert(expanded != null);

  @override
  State<StatefulWidget> createState() => _VideoPlayerControlsBottomState();
}

class _VideoPlayerControlsBottomState extends State<VideoPlayerControlsBottom> {
  static const double _BAR_PADDING_FULLSCREEN = 16;

  bool _dragging = false;

  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    _controller.addListener(_onControllerUpdate);
    super.initState();
  }

  void _onControllerUpdate() {
    if (!_dragging && _controller.position != _controller.dragbarPosition)
      _controller.setDragbarPosition(_controller.position);
  }

  void _onDrag(DragUpdateDetails details, double width) async {
    final padding = widget.fullscreen ? _BAR_PADDING_FULLSCREEN : 0;
    final progress = numInRange(
        (details.localPosition.dx - padding) / (width - 2 * padding), 0, 1);

    final newPos = _controller.duration * progress;
    if (newPos.inMilliseconds != _controller.dragbarPosition.inMilliseconds)
      _controller.setDragbarPosition(newPos);
  }

  void _onDragStart() {
    _dragging = true;
    widget.onDragStart?.call();
  }

  void _onDragEnd() {
    _controller.setPosition(_controller.dragbarPosition);
    _dragging = false;
    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) => _onDrag(details, width),
      onHorizontalDragEnd: (details) => _onDragEnd(),
      onHorizontalDragStart: (details) => _onDragStart(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UpperBar(
            controller: _controller,
            expanded: widget.expanded,
            fullscreen: widget.fullscreen,
          ),
          Padding(
            padding:
                EdgeInsets.all(widget.fullscreen ? _BAR_PADDING_FULLSCREEN : 0)
                    .copyWith(top: 0),
            child: VideoProgressBar(
              controller: _controller,
              draggable: widget.expanded,
              animationDuration: widget.animationDuration,
              hideWhenNotDraggable: widget.fullscreen,
            ),
          )
        ],
      ),
    );
  }
}

class _UpperBar extends StatefulWidget {
  final VideoPlayerController controller;
  final bool expanded;
  final bool fullscreen;

  _UpperBar({
    @required this.controller,
    this.expanded = true,
    this.fullscreen = false,
  });

  @override
  State<StatefulWidget> createState() => _UpperBarState();
}

class _UpperBarState extends State<_UpperBar> {
  static const _FULLSCREEN_ORIENTATIONS = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
  VideoPlayerController get _controller => widget.controller;
  Duration _position;
  Duration _duration;

  @override
  void initState() {
    _controller.addListener(_onControllerUpdate);
    _position = _controller.dragbarPosition;
    _duration = _controller.duration;
    super.initState();
  }

  void _onControllerUpdate() {
    var newPos = _controller.dragbarPosition;
    if (newPos.inSeconds != _position.inSeconds)
      setState(() => _position = newPos);
    if (_controller.duration != _duration)
      setState(() => _duration = _controller.duration);
  }

  void toggleFullscreen() {
    // TODO somehow let users into non-fullscreen mode in landscape mode
    SystemChrome.setPreferredOrientations(
      widget.fullscreen ? DeviceOrientation.values : _FULLSCREEN_ORIENTATIONS,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.expanded) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
                "${stringifyDuration(_position)} / ${stringifyDuration(_duration)}"),
          ),
        ),
        IconButton(
          icon: Icon(
              widget.fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
          onPressed: () => toggleFullscreen(),
          visualDensity: VisualDensity.compact,
          splashRadius: 8,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
