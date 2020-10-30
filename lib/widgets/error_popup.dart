import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_conditional_rendering/conditional.dart';

class ErrorPopup extends StatelessWidget {
  final String name;
  final String description;
  final StackTrace stacktrace;

  ErrorPopup({
    @required this.name,
    @required this.description,
    this.stacktrace,
  });

  factory ErrorPopup.fromError(Error e) {
    return ErrorPopup(
      name: e.runtimeType.toString(),
      description: e.toString(),
      stacktrace: e.stackTrace,
    );
  }

  factory ErrorPopup.fromException(Exception e) {
    return ErrorPopup(
      name: e.runtimeType.toString(),
      description: e.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Conditional.single(
      context: context,
      conditionBuilder: (context) => foundation.kDebugMode,
      widgetBuilder: (context) => AlertDialog(
        title: Text(name),
        content: Wrap(
          children: [
            Text(description),
            SizedBox(height: 10),
            Text(
              stacktrace?.toString() ?? "",
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      ),
      fallbackBuilder: (context) => AlertDialog(
        title: Text("An error occurred"),
        content: Text(name),
      ),
    );
  }
}
