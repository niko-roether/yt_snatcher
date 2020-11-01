import "package:flutter/material.dart";
import 'package:yt_snatcher/router.dart';
import 'package:yt_snatcher/service_provider.dart';
import 'package:yt_snatcher/themes/dark.dart';

void main() => runApp(YtSnatcher());

class YtSnatcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      child: MaterialApp(
        title: "Youtube Snatcher",
        initialRoute: "/",
        routes: routes,
        theme: darkTheme,
      ),
    );
  }
}
