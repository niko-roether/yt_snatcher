import "package:flutter/material.dart";

void main() => runApp(YtSnatcher());

class YtSnatcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "YT Snatcher",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Youtube Snatcher"),
        ),
        body: Center(
          child: Text("stuff and things"),
        ),
      ),
    );
  }
}
