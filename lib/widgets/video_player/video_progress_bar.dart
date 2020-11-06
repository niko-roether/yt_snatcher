import 'package:flutter/material.dart';

class VideoProgressBar extends StatelessWidget {
  static const double _NORMAL_HEIGHT = 2;
  static const double _DRAGGABLE_HEIGHT = 5;
  final double progress;
  final bool draggable;

  VideoProgressBar({this.progress, this.draggable = false})
      : assert(draggable != null);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return CustomPaint(
      painter: _VideoProgressBarPainter(
        progress,
        draggable,
        Theme.of(context).colorScheme.primary,
      ),
      size: Size(
        width,
        draggable ? _DRAGGABLE_HEIGHT : _NORMAL_HEIGHT,
      ),
    );
  }
}

class _VideoProgressBarPainter extends CustomPainter {
  static const double _NORMAL_BAR_WIDTH = VideoProgressBar._NORMAL_HEIGHT;
  static const double _DRAGGABLE_BAR_WIDTH = VideoProgressBar._DRAGGABLE_HEIGHT;
  final double _progress;
  final bool _draggable;
  final Color _color;

  _VideoProgressBarPainter(this._progress, this._draggable, this._color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _draggable ? _DRAGGABLE_BAR_WIDTH : _NORMAL_BAR_WIDTH;
    paint.color = _color;
    final lineStart = Offset(0, size.height / 2);
    final lineEnd = Offset((_progress ?? 0) * size.width, size.height / 2);
    canvas.drawLine(
      lineStart,
      lineEnd,
      paint,
    );
    if (!_draggable) return;
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _color;
    canvas.drawCircle(lineEnd, _DRAGGABLE_BAR_WIDTH * 1.2, circlePaint);
  }

  @override
  bool shouldRepaint(_VideoProgressBarPainter old) {
    return _progress != old._progress || _draggable != old._draggable;
  }
}
