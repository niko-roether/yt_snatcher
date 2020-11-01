import 'package:flutter/material.dart';

final _headingStyle = TextStyle(fontFamily: "Nunito Sans");
final _blockStyle = TextStyle(fontFamily: "Open Sans");

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
  textTheme: Typography.material2018().white.copyWith(
        headline1: _headingStyle,
        headline2: _headingStyle,
        headline3: _headingStyle,
        headline4: _headingStyle,
        headline5: _headingStyle,
        headline6: _headingStyle,
        subtitle1: _headingStyle,
        subtitle2: _headingStyle,
        bodyText1: _blockStyle,
        bodyText2: _blockStyle,
        caption: _blockStyle,
        button: _blockStyle,
        overline: _blockStyle,
      ),
);
