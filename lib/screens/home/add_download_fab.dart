import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/download/download_screen.dart';

class AddDownloadFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, DownloadScreen.ROUTENAME),
      child: Icon(Icons.add),
    );
  }
}
