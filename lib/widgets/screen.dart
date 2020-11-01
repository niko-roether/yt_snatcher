import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';

class Screen extends StatelessWidget {
  final Widget title;
  final Widget content;
  final bool showSettings;
  final Widget navigationBar;
  final Key key;
  final Widget fab;

  Screen({
    @required this.title,
    @required this.content,
    this.navigationBar,
    this.showSettings = true,
    this.key,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(title: this.title, actions: [
        Conditional.single(
          context: context,
          conditionBuilder: (context) => this.showSettings,
          widgetBuilder: (context) => (IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, "/settings"),
          )),
          fallbackBuilder: (context) => Container(),
        ),
      ]),
      body: content,
      bottomNavigationBar: navigationBar,
      floatingActionButton: fab,
    );
  }
}
