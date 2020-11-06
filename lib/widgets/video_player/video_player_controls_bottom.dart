import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yt_snatcher/widgets/video_player/video_progress_bar.dart';

class VideoPlayerControlsBottom extends StatefulWidget {
  final Color barColor;
  final bool expanded;
  final VlcPlayerController controller;
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
  VlcPlayerController _controller;
  Duration _position;
  bool _dragging = false;

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
    if (!_dragging && _controller.position.inSeconds != _position.inSeconds)
      setState(() => _position = _controller.position);
  }

  void _onDrag(double progress) async {
    final newPos = _controller.duration * progress;
    setState(() => _position = newPos);
  }

  void _onDragStart() {
    _dragging = true;
    widget.onDragStart?.call();
  }

  void _onDragEnd() {
    _dragging = false;
    _controller.setTime(_position.inMilliseconds);
    widget.onDragEnd?.call();
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
      onHorizontalDragEnd: (details) => _onDragEnd(),
      onHorizontalDragStart: (details) => _onDragStart(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUpperBar(),
          Padding(
            padding:
                EdgeInsets.all(widget.fullscreen ? 16 : 0).copyWith(top: 0),
            child: VideoProgressBar(
              progress: _getProgress(),
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
