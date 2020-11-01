import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/home/downloads_display.dart';

class Music extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DownloadsDisplay(selector: (dlm) => dlm.getMusic());
  }
}
