import 'dart:async';

import 'package:isolate/isolate.dart';

class ThreadPool {
  final int size;
  bool _open = true;
  Future<LoadBalancer> _poolFuture;

  ThreadPool(this.size) {
    _poolFuture = LoadBalancer.create(size, IsolateRunner.spawn);
  }

  Future<T> run<T, A>(
    FutureOr<T> Function(A) process,
    A arg, {
    int load,
  }) async {
    if (!_open) throw StateError("This thread pool has been closed");
    var pool = await _poolFuture;
    return pool.run(process, arg, load: load);
  }

  Future<void> close() async {
    _open = false;
    (await _poolFuture).close();
  }
}
