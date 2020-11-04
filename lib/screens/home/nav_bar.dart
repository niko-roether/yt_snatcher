import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;

  NavBar({@required this.currentIndex, this.onTap})
      : assert(currentIndex != null);

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
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.file_download),
          label: "Downloads",
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
