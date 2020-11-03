import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/provider/download_process_manager.dart';
import 'package:yt_snatcher/widgets/provider/download_provider.dart';
import 'package:yt_snatcher/widgets/provider/error_provider.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;

  ServiceProvider({@required this.child});

  @override
  Widget build(BuildContext context) {
    return ErrorProviderManager(
      child: DownloadProvider(
        child: DownloadProcessManager(
          child: child,
        ),
      ),
    );
  }
}
