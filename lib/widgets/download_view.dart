import 'package:flutter/material.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/overflow_menu.dart';

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
      trailing: OverflowMenu(items: [
        OverflowMenuItem(
          icon: Icon(Icons.delete),
          name: "Delete",
          onPressed: () async {
            showDialog(
              context: context,
              child: AlertDialog(
                title: Text("Delete Download?"),
                content: Text("Are you sure you want to delete this download?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("NO"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await download.delete();
                      onChange?.call();
                    },
                    child: Text("YES"),
                  )
                ],
              ),
            );
          },
        )
      ]),
      onTap: () => onTap?.call(),
    );
  }
}
