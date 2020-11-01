import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_magager.dart';

class DownloadView extends StatelessWidget {
  final Download download;
  final Key key;

  DownloadView({@required this.download, this.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      leading: Image.network(
        download.meta.videoMeta.thumbnails.lowRes,
        width: 100,
      ),
      title: Text(download.meta.displayTitle, overflow: TextOverflow.ellipsis),
      subtitle: Text(download.meta.videoMeta.channelName),
      trailing: OverflowBar(),
    );
  }
}
