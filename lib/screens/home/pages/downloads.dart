import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/download/download_screen.dart';
import 'package:yt_snatcher/screens/home/download_processes_display.dart';

class Downloads extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(child: DownloadProcessesDisplay()),
      Align(
        child: Padding(
          child: FloatingActionButton(
            onPressed: () =>
                Navigator.pushNamed(context, DownloadScreen.ROUTENAME),
            child: Icon(Icons.add),
          ),
          padding: EdgeInsets.all(16),
        ),
        alignment: Alignment.bottomRight,
      ),
    ]);
  }
}
