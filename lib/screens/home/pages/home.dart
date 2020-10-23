import 'package:flutter/material.dart';
import '../../../widgets/yt-player.dart';
// import 'package:yt_snatcher/services/youtube.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return YtPlayer(videoId: "fIJwDg_EP2Y");
  }
}

// class HomeState extends State<Home> {
//   final YTConnection yt = YTConnection();
//   Stream<List<int>> stream;
//   String content = "";

//   HomeState() {
//     stream = yt.getVideoStream(
//       "fIJwDg_EP2Y",
//       YTVideoQuality(Quality.HIGHEST_QUALITY),
//     )..listen((event) {
//         this.setState(() => content += "*");
//       });
//   }

//   @override
//   Widget build(BuildContext context) {<<<
//     if (content == null) {
//       stream.join(", ").then((s) => setState(() => content = s));
//       return Center(child: CircularProgressIndicator());
//     }
//     return Center(child: Text(content));
//   }
// }
