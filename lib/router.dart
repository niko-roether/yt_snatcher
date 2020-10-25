import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/downloads/download_screen.dart';
import 'package:yt_snatcher/screens/home/home_screen.dart';
import 'package:yt_snatcher/screens/video_info/video_info_screen.dart';
import 'package:yt_snatcher/widgets/screen.dart';

var routes = {
  HomeScreen.ROUTENAME: (context) => HomeScreen(),
  DownloadScreen.ROUTENAME: (context) => DownloadScreen(),
  VideoInfoScreen.ROUTENAME: (context) => VideoInfoScreen(),
  "/settings": (context) => Screen(
        title: Text("Settings"),
        content: Text("Settings"),
        showSettings: false,
      ),
};
