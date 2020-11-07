import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoPlayerControlsTop extends StatelessWidget {
  final void Function() onBack;
  final bool visible;
  final bool fullscreen;
  final Animation<double> animation;

  VideoPlayerControlsTop({
    this.visible = true,
    this.fullscreen = false,
    this.onBack,
    @required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => onBack?.call(),
      visualDensity: VisualDensity.compact,
    );
    Widget widget;
    if (fullscreen) {
      widget = visible
          ? Align(
              child: button,
              alignment: Alignment.topLeft,
            )
          : Container();
    } else {
      widget = Row(
        children: [
          AnimatedBuilder(
            animation: fullscreen ? AlwaysStoppedAnimation(0) : animation,
            builder: (context, child) {
              return DecoratedBox(
                decoration: ShapeDecoration(
                  color:
                      Colors.black.withAlpha((animation.value * 100).floor()),
                  shape: CircleBorder(),
                ),
                child: child,
              );
            },
            child: button,
          ),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.all(8).copyWith(bottom: 0),
      child: widget,
    );
  }
}
