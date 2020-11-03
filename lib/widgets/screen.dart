import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:yt_snatcher/widgets/provider/error_stream_provider.dart';

class Screen extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool showSettings;
  final Widget navigationBar;
  final Widget fab;

  Screen({
    @required this.title,
    @required this.content,
    this.navigationBar,
    this.showSettings = true,
    this.fab,
  });

  @override
  State<StatefulWidget> createState() {
    return ScreenState();
  }
}

class ScreenState extends State<Screen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription _subscription;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    ErrorStreamProvider.of(context).errors.listen((error) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: errorColor),
      );
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: widget.title, actions: [
        Conditional.single(
          context: context,
          conditionBuilder: (context) => widget.showSettings,
          widgetBuilder: (context) => (IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, "/settings"),
          )),
          fallbackBuilder: (context) => Container(),
        ),
      ]),
      body: widget.content,
      bottomNavigationBar: widget.navigationBar,
      floatingActionButton: widget.fab,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
