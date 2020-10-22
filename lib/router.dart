import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/screen.dart';

var routes = {
  "/": (context) =>
      Screen(title: Text("Youtube Snatcher"), content: Text("Home")),
  "/settings": (context) => Screen(
        title: Text("Settings"),
        content: Text("Settings"),
        showSettings: false,
      )
};
