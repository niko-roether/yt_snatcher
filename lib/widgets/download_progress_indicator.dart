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
  final Color bgColor;
  final Animation<Color> barColor;
  final Widget trailing;
  final void Function() onCancel;

  DownloadProgressIndicator(
      {@required this.title,
      this.subtitle,
      @required this.progress,
      this.stage = "Loading",
      this.thumbnailUrl,
      this.thumbnailWidth = 100,
      this.semanticName = "content",
      this.bgColor,
      this.barColor,
      this.trailing,
      this.onCancel});

  String get _percent {
    if (progress == null) return "";
    var numeric = (progress * 100).floor();
    return "$numeric%";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Conditional.single(
        context: context,
        conditionBuilder: (context) => thumbnailUrl != null,
        widgetBuilder: (context) => Image.network(thumbnailUrl),
        fallbackBuilder: (context) => Container(),
      ),
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: Column(children: [
        Padding(
          child: LinearProgressIndicator(
            value: progress,
            semanticsLabel: "Downloading $semanticName",
            semanticsValue: _percent,
            backgroundColor: bgColor,
            valueColor: barColor,
          ),
          padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
        ),
        Align(
          child: Text(
            "${capitalize(stage)}... $_percent",
          ),
          alignment: Alignment.center,
        )
      ]),
      trailing: IconButton(
        icon: Icon(Icons.cancel),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Cancel download?"),
            content: Text("Are you shure you want to cancel this download?"),
            actions: [
              TextButton(
                onPressed: () {
                  onCancel?.call();
                  Navigator.pop(context);
                },
                child: Text("YES"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("NO"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
