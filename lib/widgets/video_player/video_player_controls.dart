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

class VideoPlayerControlsState extends State<VideoPlayerControls> {
  bool show;

  @override
  void initState() {
    show = widget.showControlsImmediately;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => setState(() => show = !show),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Column(
          children: [
            Container(),
            Container(),
            _VideoPlayerControlsBottomBar(
              controller: widget.controller,
              expanded: show,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
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
    _controller.addListener(() => _onControllerUpdate());
    _position = Duration.zero;
    super.initState();
  }

  @override
  dispose() {
    _controller.removeListener(() => _onControllerUpdate());
    super.dispose();
  }

  double _getProgress() {
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
