import 'package:flutter/material.dart';
import 'package:yt_snatcher/screens/home/home_screen.dart';
import 'package:yt_snatcher/widgets/screen.dart';

var routes = {
  "/": (context) => HomeScreen(),
  "/settings": (context) => Screen(
        title: Text("Settings"),
        content: Text("Settings"),
        showSettings: false,
      )
};
