import 'dart:async';

import 'package:flutter/material.dart';

class ErrorProvider extends InheritedWidget {
  final Stream<Object> stream;
  final void Function(Object) add;

  ErrorProvider({
    Key key,
    @required this.stream,
    @required this.add,
    Widget child,
  }) : super(key: key, child: child);

  factory ErrorProvider.of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ErrorProvider>();
  }

  @override
  bool updateShouldNotify(ErrorProvider old) => stream != old.stream;
}

class ErrorProviderManager extends StatefulWidget {
  final Widget child;

  ErrorProviderManager({this.child});

  @override
  State<StatefulWidget> createState() {
    return _ErrorProviderManagerState();
  }
}

class _ErrorProviderManagerState extends State<ErrorProviderManager> {
  final _controller = StreamController<Object>();
  Stream<Object> _stream;

  _ErrorProviderManagerState() {
    _stream = _controller.stream.asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return ErrorProvider(
      stream: _stream,
      add: (e) => _controller.add(e),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
