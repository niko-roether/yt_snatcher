import 'package:flutter/material.dart';

final darkTheme = ThemeData.from(
  colorScheme: ColorScheme.dark(
    background: Color(0xff001321),
    onBackground: Colors.white,
    surface: Color(0xff001524),
    onSurface: Colors.white,
    primary: Color(0xffdb504a),
    primaryVariant: Color(0xffd72638),
    onPrimary: Colors.white,
    secondary: Color(0xff119da4),
    secondaryVariant: Color(0xff0c7489),
    onSecondary: Colors.white,
  ),
  textTheme: Typography.material2018().white,
);
