import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube.dart';
import 'package:yt_snatcher/widgets/screen.dart';
import 'package:yt_snatcher/widgets/video_info_view.dart';

class VideoInfoScreen extends StatelessWidget {
  static const ROUTENAME = "/videoInfo";

  @override
  Widget build(BuildContext context) {
    VideoMeta video = ModalRoute.of(context).settings.arguments;
    return Screen(
      title: Text("Video Information"),
      content: VideoInfoView(video),
      showSettings: false,
    );
  }
}
