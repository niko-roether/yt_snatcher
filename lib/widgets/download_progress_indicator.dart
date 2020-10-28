import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';

import '../util.dart';

class DownloadProgressIndicator extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String stage;
  final String thumbnailUrl;
  final double thumbnailWidth;
  final String semanticName;

  DownloadProgressIndicator(
      {@required this.title,
      this.subtitle,
      @required this.progress,
      this.stage = "Loading",
      this.thumbnailUrl,
      this.thumbnailWidth = 100,
      this.semanticName = "content"});

  String get _percent {
    var numeric = (progress * 100).floor();
    return "$numeric%";
  }

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: Padding(
        child: Column(
          children: [
            Text(
              this.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(this.subtitle ?? Container()),
            Padding(
              child: LinearProgressIndicator(
                value: progress,
                semanticsLabel: "Downloading $semanticName",
                semanticsValue: _percent,
              ),
              padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
            ),
            Align(
              child: Text(
                "${capitalize(stage)}... $_percent",
              ),
              alignment: Alignment.center,
            )
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
    return Conditional.single(
      context: context,
      conditionBuilder: (c) => thumbnailUrl != null,
      widgetBuilder: (c) => Row(children: [
        Image.network(thumbnailUrl, width: thumbnailWidth),
        content,
      ]),
      fallbackBuilder: (c) => content,
    );
  }
}
