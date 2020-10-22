import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  final YTConnection yt = YTConnection();
  Stream<List<int>> stream;
  String content = "";

  HomeState() {
    stream = yt.getVideoStream(
      "fIJwDg_EP2Y",
      YTVideoQuality(Quality.HIGHEST_QUALITY),
    )..listen((event) {
        this.setState(() => content += event.join(", "));
      });
  }

  @override
  Widget build(BuildContext context) {
    if (content == null) {
      stream.join(", ").then((s) => setState(() => content = s));
      return Center(child: CircularProgressIndicator());
    }
    return Center(child: Text(content));
  }
}
