import 'package:flutter/cupertino.dart';
import 'package:yt_snatcher/services/download_manager.dart';

class DownloadProvider extends InheritedWidget {
  final service = DownloadManager();

  DownloadProvider({@required Widget child}) : super(child: child);

  static DownloadProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DownloadProvider>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
