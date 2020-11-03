import 'dart:async';

import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class ErrorStreamProvider extends InheritedWidget {
  Stream<Object> errors;
  final StreamController<Object> _controller;

  ErrorStreamProvider({
    Key key,
    @required StreamController<Object> controller,
    @required Stream<Object> stream,
    Widget child,
  })  : _controller = controller,
        errors = stream,
        super(key: key, child: child);

  void add(Object error) => _controller.add(error);

  void close() => _controller.close();

  static ErrorStreamProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ErrorStreamProvider>();
  }

  @override
  bool updateShouldNotify(ErrorStreamProvider old) => false;
}
