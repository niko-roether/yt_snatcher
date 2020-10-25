import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/youtube.dart';

class YTVideoInfo extends StatelessWidget {
  final YoutubeVideoMeta videoMeta;

  YTVideoInfo(this.videoMeta);

  Map<String, String> get infoMap => {
        "Title": videoMeta.title,
        "Description": videoMeta.description,
        "Upload Date": videoMeta.uploadDate.toString(),
        "Duration": videoMeta.duration.toString(),
        "Youtube-URL": videoMeta.youtubeUrl,
        "Channel Name": videoMeta.channelName,
        "Channel ID": videoMeta.channelId
      };

  @override
  Widget build(BuildContext context) {
    var getTableCell = (String text) => TableCell(
          child: Container(
            child: Text(text),
            padding: EdgeInsets.all(5),
          ),
        );
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Table(
        children: infoMap.entries
            .map(
              (e) => TableRow(
                key: ValueKey(e.key),
                children: [getTableCell(e.key), getTableCell(e.value)],
              ),
            )
            .toList(),
      ),
    );
  }
}
