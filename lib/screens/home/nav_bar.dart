import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;

  NavBar({this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_collection),
          label: "Videos",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: "Music",
        )
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
