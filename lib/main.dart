import "package:flutter/material.dart";
import 'package:yt_snatcher/router.dart';

void main() => runApp(YtSnatcher());

class YtSnatcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Youtube Snatcher",
      initialRoute: "/",
      routes: routes,
    );
  }
}
