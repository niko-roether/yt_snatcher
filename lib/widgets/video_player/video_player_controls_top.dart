import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoPlayerControlsTop extends StatelessWidget {
  final void Function() onBack;
  final bool visible;

  VideoPlayerControlsTop({this.visible = true, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => onBack?.call(),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
