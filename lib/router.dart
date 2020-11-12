import 'package:audio_service/audio_service.dart';
import 'package:yt_snatcher/screens/download/download_screen.dart';
import 'package:yt_snatcher/screens/home/home_screen.dart';
import 'package:yt_snatcher/screens/listen/listen_screen.dart';
import 'package:yt_snatcher/screens/video_info/video_info_screen.dart';
import 'package:yt_snatcher/screens/watch/watch_screen.dart';
import 'package:yt_snatcher/screens/settings/settings_screen.dart';

var routes = {
  HomeScreen.ROUTENAME: (context) => AudioServiceWidget(child: HomeScreen()),
  VideoInfoScreen.ROUTENAME: (context) => VideoInfoScreen(),
  DownloadScreen.ROUTENAME: (context) => DownloadScreen(),
  WatchScreen.ROUTENAME: (context) => WatchScreen(),
  SettingsScreen.ROUTENAME: (context) => SettingsScreen(),
  ListenScreen.ROUTENAME: (context) => ListenScreen(),
};
