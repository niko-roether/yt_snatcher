import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:yt_snatcher/screens/settings/settings_screen.dart';
import 'package:yt_snatcher/widgets/provider/error_provider.dart';
import 'package:yt_snatcher/widgets/provider/orientation_provider.dart';

class Screen extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool showSettings;
  final Widget navigationBar;
  final Widget fab;
  final bool showAppBar;

  Screen({
    @required this.title,
    @required this.content,
    this.navigationBar,
    this.showSettings = true,
    this.fab,
    this.showAppBar = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _ScreenState();
  }
}

class _ScreenState extends State<Screen> {
  static final List<GlobalKey<ScaffoldState>> _scaffoldKeys = [];
  static StreamSubscription _subscription;

  static onError(Object error, ThemeData theme) {
    _scaffoldKeys.last.currentState.showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  void _initSubscription() {
    final theme = Theme.of(context);
    _subscription =
        ErrorProvider.of(context).stream.listen((e) => onError(e, theme));
  }

  @override
  Widget build(BuildContext context) {
    var key = GlobalKey<ScaffoldState>();
    _scaffoldKeys.add(key);
    if (_subscription == null) _initSubscription();
    return OrientationProviderManager(
      child: Scaffold(
        key: key,
        appBar: widget.showAppBar
            ? AppBar(title: widget.title, actions: [
                Conditional.single(
                  context: context,
                  conditionBuilder: (context) => widget.showSettings,
                  widgetBuilder: (context) => (IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      SettingsScreen.ROUTENAME,
                    ),
                  )),
                  fallbackBuilder: (context) => Container(),
                ),
              ])
            : null,
        body: widget.content,
        bottomNavigationBar: widget.navigationBar,
        floatingActionButton: widget.fab,
      ),
    );
  }

  @override
  void dispose() {
    _scaffoldKeys.removeLast();
    if (_scaffoldKeys.length == 0) _subscription?.cancel();
    super.dispose();
  }
}
