import 'package:flutter/material.dart';

class OrientationProvider extends InheritedWidget {
  final Orientation orientation;

  OrientationProvider({@required this.orientation, @required Widget child})
      : super(child: child);

  factory OrientationProvider.of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OrientationProvider>();
  }

  @override
  bool updateShouldNotify(OrientationProvider old) =>
      orientation != old.orientation;
}

class OrientationProviderManager extends StatefulWidget {
  final Widget child;

  OrientationProviderManager({@required this.child});

  @override
  State<StatefulWidget> createState() => OrientationProviderManagerState();
}

class OrientationProviderManagerState
    extends State<OrientationProviderManager> {
  Orientation _orientation;

  @override
  void didChangeDependencies() {
    setState(() => _getOrientation(context));
    super.didChangeDependencies();
  }

  void _getOrientation(BuildContext context) {
    _orientation = MediaQuery.of(context).orientation;
  }

  @override
  Widget build(BuildContext context) {
    if (_orientation == null) _getOrientation(context);
    return OrientationProvider(orientation: _orientation, child: widget.child);
  }
}
