import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/video_player/video_player_controller.dart';
import 'package:yt_snatcher/widgets/video_player/video_progress_bar.dart';

import '../../util.dart';

class VideoPlayerControlsBottom extends StatelessWidget {
  static const double BAR_PADDING_FULLSCREEN = 16;

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

  void _onDrag(DragUpdateDetails details, double width) async {
    final padding = fullscreen ? BAR_PADDING_FULLSCREEN : 0;
    final progress = numInRange(
        (details.localPosition.dx - padding) / (width - 2 * padding), 0, 1);

    final newPos = controller.duration * progress;
    if (newPos.inMilliseconds != controller.dragbarPosition.inMilliseconds)
      controller.setDragbarPosition(newPos);
  }

  void _onDragStart() {
    onDragStart?.call();
  }

  void _onDragEnd() {
    controller.setPosition(controller.dragbarPosition);
    onDragEnd?.call();
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
            controller: controller,
            expanded: expanded,
          ),
          Padding(
            padding: EdgeInsets.all(fullscreen ? BAR_PADDING_FULLSCREEN : 0)
                .copyWith(top: 0),
            child: VideoProgressBar(
              controller: controller,
              draggable: expanded,
              animationDuration: animationDuration,
              hideWhenNotDraggable: fullscreen,
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

  _UpperBar({@required this.controller, this.expanded = true});

  @override
  State<StatefulWidget> createState() => _UpperBarState();
}

class _UpperBarState extends State<_UpperBar> {
  VideoPlayerController get _controller => widget.controller;
  Duration _position;

  @override
  void initState() {
    _controller.addListener(_onControllerUpdate);
    super.initState();
  }

  void _onControllerUpdate() {
    var newPos = _controller.position;
    if (newPos.inSeconds != _position) setState(() => _position = newPos);
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
                "${stringifyDuration(_position)} / ${stringifyDuration(_controller.duration)}"),
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
}
