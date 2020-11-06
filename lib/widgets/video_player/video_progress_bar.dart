import 'package:flutter/material.dart';

class VideoProgressBar extends StatefulWidget {
  final double progress;
  final bool draggable;
  final Duration animationDuration;
  final bool hideWhenNotDraggable;

  VideoProgressBar({
    this.progress,
    this.draggable = false,
    this.animationDuration = const Duration(milliseconds: 100),
    this.hideWhenNotDraggable = false,
  })  : assert(draggable != null),
        assert(hideWhenNotDraggable != null);

  @override
  State<StatefulWidget> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar>
    with SingleTickerProviderStateMixin {
  static const double _NORMAL_HEIGHT = 2;
  static const double _DRAGGABLE_HEIGHT = 5;
  AnimationController _animationController;

  @override
  initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (widget.draggable)
      _animationController.animateTo(1);
    else
      _animationController.animateTo(0);
    return CustomPaint(
      painter: _VideoProgressBarPainter(
        progress: widget.progress,
        color: Theme.of(context).colorScheme.primary,
        normalBarWidth: widget.hideWhenNotDraggable ? 0 : _NORMAL_HEIGHT,
        draggableBarWidth: _DRAGGABLE_HEIGHT,
        expand: _animationController,
      ),
      size: Size(
        width,
        widget.draggable ? _DRAGGABLE_HEIGHT : _NORMAL_HEIGHT,
      ),
    );
  }
}

class _VideoProgressBarPainter extends CustomPainter {
  static const double _CIRCLE_SIZE_FACTOR = 1.2;
  final double progress;
  final Color color;
  final double normalBarWidth;
  final double draggableBarWidth;
  final double circleRadius;
  final Animation<double> expand;

  _VideoProgressBarPainter({
    this.expand = const AlwaysStoppedAnimation(0),
    this.progress,
    this.color,
    this.normalBarWidth = 2,
    this.draggableBarWidth = 5,
  }) : circleRadius = draggableBarWidth * _CIRCLE_SIZE_FACTOR;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth =
        (draggableBarWidth - normalBarWidth) * expand.value + normalBarWidth;
    if (strokeWidth == 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    paint.color = Colors.white24;
    final lineStart = Offset(0, size.height - strokeWidth / 2);
    final valueLineEnd = Offset(
      (progress ?? 0) * size.width,
      size.height - strokeWidth / 2,
    );
    final bgLineEnd = Offset(size.width, size.height - strokeWidth / 2);

    canvas.drawLine(
      lineStart,
      bgLineEnd,
      paint,
    );

    paint.color = color;
    canvas.drawLine(lineStart, valueLineEnd, paint);
    if (expand.value == 0) return;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(valueLineEnd, circleRadius * expand.value, circlePaint);
  }

  @override
  bool shouldRepaint(_VideoProgressBarPainter old) {
    return progress != old.progress || expand.value != old.expand.value;
  }
}
