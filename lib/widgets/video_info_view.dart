import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:yt_snatcher/services/youtube.dart';
import 'package:yt_snatcher/widgets/animated_rotation.dart';

class VideoInfoView extends StatefulWidget {
  final VideoMeta videoMeta;

  VideoInfoView(this.videoMeta);

  @override
  State<StatefulWidget> createState() {
    return VideoInfoViewState();
  }
}

class VideoInfoViewState extends State<VideoInfoView>
    with SingleTickerProviderStateMixin {
  static AnimationController _dropdownAnim;
  bool _showDescription = false;

  VideoInfoViewState() {
    _dropdownAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      upperBound: 0.5,
    );
  }

  void _onDropdown() async {
    await (_showDescription
        ? _dropdownAnim.reverse()
        : _dropdownAnim.forward());
    // TODO fix this
    setState(() {
      _showDescription = !_showDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Column(
                children: [
                  Text(widget.videoMeta.title,
                      style: theme.textTheme.subtitle1),
                  Text(
                    widget.videoMeta.channelName,
                    style: theme.textTheme.caption,
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            IconButton(
              icon: AnimatedRotation(
                child: Icon(Icons.arrow_drop_down),
                controller: _dropdownAnim,
              ),
              onPressed: () => _onDropdown(),
              padding: EdgeInsets.zero,
            )
          ]),
          Padding(
            child: Divider(),
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          Conditional.single(
            context: context,
            conditionBuilder: (context) => _showDescription,
            widgetBuilder: (context) {
              return Text(widget.videoMeta.description);
            },
            fallbackBuilder: (context) => Container(),
          )
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
