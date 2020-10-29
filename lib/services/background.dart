import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

class ThreadPool {
  static List<String> _registeredNames = [];
  final int size;
  final String name;
  bool _open = true;
  bool _initialized = false;
  MethodChannel _channel;

  static String _getUnusedName() => "Thread Pool #${_registeredNames.length}";

  void _checkOpen() {
    if (!_open) throw StateError("This thread pool has been closed");
  }

  void _checkInitialized() {
    if (!_initialized)
      throw StateError("This thread pool has not been initialized");
  }

  ThreadPool(
    this.size, [
    String name,
  ]) : this.name = name ?? _getUnusedName() {
    _channel = MethodChannel(this.name);
  }

  Future<void> initialize(Function callback) {}

  Future<T> run<T, A>(
    FutureOr<T> Function(A) process,
    A arg, {
    int load,
  }) async {
    _checkOpen();
    _checkInitialized();
    final handle = PluginUtilities.getCallbackHandle(process);
    if (handle == null)
      throw ArgumentError(
          "Thread poll callback must be a static or top-level function");
    _channel.invokeMethod<T>(
      "",
    );
  }

  Future<void> close() async {
    _open = false;
    // closing stuff
  }
}
