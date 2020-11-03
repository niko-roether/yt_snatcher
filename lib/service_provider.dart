import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yt_snatcher/widgets/provider/download_process_manager.dart';
import 'package:yt_snatcher/widgets/provider/download_provider.dart';
import 'package:yt_snatcher/widgets/provider/error_stream_provider.dart';

class ServiceProvider extends StatefulWidget {
  final Widget child;

  ServiceProvider({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return ServiceProviderState();
  }
}

class ServiceProviderState extends State<ServiceProvider> {
  final _errorStreamController = StreamController<Object>();
  Stream<Object> _errorStream;

  ServiceProviderState() {
    _errorStream = _errorStreamController.stream.asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return ErrorStreamProvider(
        child: DownloadProvider(
          child: DownloadProcessManager(
            child: widget.child,
          ),
        ),
        controller: _errorStreamController,
        stream: _errorStream);
  }

  @override
  void dispose() {
    _errorStreamController.close();
    super.dispose();
  }
}
