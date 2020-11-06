import 'package:flutter/material.dart';

class VideoProgressBar extends StatelessWidget {
  static const double _NORMAL_HEIGHT = 2;
  static const double _DRAGGABLE_BAR_HEIGHT = 5;
  static const double _DRAGGABLE_DRAW_HEIGHT = 9;
  final double progress;
  final bool draggable;
  final void Function(double newProgress) onDrag;

  VideoProgressBar({this.progress, this.draggable = false, this.onDrag})
      : assert(draggable != null);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        onDrag(details.localPosition.dx / width);
      },
      // child: OverflowBox(
      //   maxHeight: draggable ? _DRAGGABLE_BAR_HEIGHT : _NORMAL_HEIGHT,
      child: CustomPaint(
        painter: _VideoProgressBarPainter(
          progress,
          draggable,
          Theme.of(context).colorScheme.primary,
        ),
        size: Size(
          width,
          draggable ? _DRAGGABLE_DRAW_HEIGHT : _NORMAL_HEIGHT,
        ),
      ),
      // ),
    );
  }
}

class _VideoProgressBarPainter extends CustomPainter {
  static const double _NORMAL_BAR_WIDTH = VideoProgressBar._NORMAL_HEIGHT;
  static const double _DRAGGABLE_BAR_WIDTH =
      VideoProgressBar._DRAGGABLE_BAR_HEIGHT;
  static const double _DRAG_CIRCLE_DIAMETER =
      VideoProgressBar._DRAGGABLE_DRAW_HEIGHT;
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
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(_progress * size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_VideoProgressBarPainter old) {
    return _progress != old._progress || _draggable != old._draggable;
  }
}
