import 'package:flutter/cupertino.dart';
import 'package:yt_snatcher/services/download_manager.dart';
import 'package:yt_snatcher/widgets/download_form.dart';
import 'package:yt_snatcher/widgets/screen.dart';

class DownloadScreen extends StatelessWidget {
  static const ROUTENAME = "/download";

  @override
  Widget build(BuildContext context) {
    DownloadType type = ModalRoute.of(context).settings.arguments;
    return Screen(
      title: Text("Download Youtube Media"),
      key: Key(ROUTENAME),
      content: Padding(
        padding: EdgeInsets.only(top: 18),
        child: DownloadForm(initialDownloadType: type ?? DownloadType.VIDEO),
      ),
    );
  }
}
