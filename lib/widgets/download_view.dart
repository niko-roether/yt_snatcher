import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';

class DownloadView extends StatelessWidget {
  final Download download;
  final Key key;
  final void Function() onTap;
  final void Function() onChange;

  DownloadView({@required this.download, this.key, this.onTap, this.onChange});

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
      trailing: OverflowBar(children: [
        IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await download.delete();
              onChange?.call();
            })
      ]),
      onTap: () => onTap?.call(),
    );
  }
}
