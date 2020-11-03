import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/provider/error_provider.dart';
import 'package:yt_snatcher/widgets/screen.dart';

class SettingsScreen extends StatelessWidget {
  static const ROUTENAME = "/settings";

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: Text("Settings"),
      showSettings: false,
      content: Center(
        child: ElevatedButton(
          onPressed: () async {
            var errors = ErrorProvider.of(context);
            await Future.delayed(Duration(seconds: 3));
            errors.add(Exception("Test test test test"));
          },
          child: Text("Error test"),
        ),
      ),
    );
  }
}
