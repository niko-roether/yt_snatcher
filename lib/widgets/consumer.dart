import 'package:flutter/material.dart';

class Consumer<W extends InheritedWidget> extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, W inherited, Widget child)
      builder;

  Consumer({@required this.builder, this.child});

  @override
  State<StatefulWidget> createState() => ConsumerState<W>();
}

class ConsumerState<W extends InheritedWidget> extends State<Consumer<W>> {
  W inherited;

  @override
  void didChangeDependencies() {
    setState(() => inherited = context.dependOnInheritedWidgetOfExactType<W>());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, inherited, widget.child);
  }
}
