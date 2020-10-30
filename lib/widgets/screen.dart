import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';

class Screen extends StatelessWidget {
  final Widget title;
  final Widget content;
  final bool showSettings;
  final Widget navigationBar;

  Screen({
    @required this.title,
    @required this.content,
    this.navigationBar,
    this.showSettings = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SizedBox(child: content, width: MediaQuery.of(context).size.width),
      bottomNavigationBar: navigationBar,
    );
  }
}
