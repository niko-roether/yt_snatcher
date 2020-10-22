import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/home/nav_bar.dart';
import 'package:yt_snatcher/screens/home/pages/home.dart';
import 'package:yt_snatcher/screens/home/pages/music.dart';
import 'package:yt_snatcher/screens/home/pages/videos.dart';
import 'package:yt_snatcher/widgets/screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  static final _pages = [
    Home(),
    Videos(),
    Music(),
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: Text("Youtube Snatcher"),
      content: _pages[_pageIndex],
      navigationBar: NavBar(currentIndex: _pageIndex, onTap: _onTapNavItem),
    );
  }

  void _onTapNavItem(int index) {
    this.setState(() => _pageIndex = index);
  }
}
