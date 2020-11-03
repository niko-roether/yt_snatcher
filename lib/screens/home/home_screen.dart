import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/home/add_download_fab.dart';
import 'package:yt_snatcher/screens/home/nav_bar.dart';
import 'package:yt_snatcher/screens/home/pages/downloads.dart';
import 'package:yt_snatcher/screens/home/pages/home.dart';
import 'package:yt_snatcher/screens/home/pages/music.dart';
import 'package:yt_snatcher/screens/home/pages/videos.dart';
import 'package:yt_snatcher/widgets/screen.dart';

class HomeScreen extends StatefulWidget {
  static const ROUTENAME = "/";

  @override
  State<HomeScreen> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  static final _pages = [Home(), Videos(), Music(), Downloads()];

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: Text("Youtube Snatcher"),
      content: _pages[_pageIndex],
      navigationBar: NavBar(currentIndex: _pageIndex, onTap: _onTapNavItem),
      // TODO there must be a better solution for this
      fab: _pageIndex == 3 ? AddDownloadFab() : null,
    );
  }

  void _onTapNavItem(int index) {
    this.setState(() => _pageIndex = index);
  }
}
