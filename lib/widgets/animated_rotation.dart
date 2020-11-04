import 'dart:math';

import 'package:flutter/cupertino.dart';

class AnimatedRotation extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  AnimatedRotation({this.controller, this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          return Transform.rotate(
            angle: controller.value * 2 * pi,
            child: child,
          );
        });
  }
}
