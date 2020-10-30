import 'dart:async';
import 'dart:isolate';

class InvalidTaskReturnTypeException implements Exception {
  final Type type;

  InvalidTaskReturnTypeException(this.type);

  @override
  String toString() => "Task returned value of invalid type $type";
}

enum TaskState { DORMANT, RUNNING }

class Task<A, R> {
  Isolate _isolate;
  TaskState _state = TaskState.DORMANT;
  Completer<R> _completer;
  final void Function(SendPort) _process;
  final String name;
  final ReceivePort _mainRecievePort = ReceivePort();

  TaskState get state => _state;
  Future<void> get completed => _completer?.future;

  static Future<T> getArg<T>(SendPort mainSendPort) {
    final isolateRecievePort = ReceivePort();
    mainSendPort.send(isolateRecievePort.sendPort);
    final completer = Completer<dynamic>();
    isolateRecievePort.listen((data) => completer.complete(data));
    return completer.future.then((v) => v as T);
  }

  static Map<String, dynamic> createEvent(dynamic value, [String name]) {
    return {"type": "event", "name": name, "value": value};
  }

  Task(this._process, [this.name = "Unnamed Task"]);

  void _log(String message) => print("[$name] $message");

  Future<R> _initTask(
    A arg, [
    bool ignoreInvalidType = false,
    void Function(dynamic) listener,
  ]) {
    _completer = Completer<R>();
    bool recievedSendPort = false;
    _mainRecievePort.listen((data) {
      if (data is SendPort) {
        if (!recievedSendPort)
          data.send(arg);
        else
          _log("Task created more than one send port! Ignoring...");
      } else if (data is Map<String, dynamic> && data["type"] == "event") {
        _log("Event: $data");
        listener?.call(data["value"]);
      } else {
        if (!(data is R) && !ignoreInvalidType)
          throw InvalidTaskReturnTypeException(data.runtimeType);
        _log("Task returned value $data");
        _completer.complete(data);
      }
    });
    return _completer.future;
  }

  Future<R> execute(
    A arg, [
    bool ignoreInvalidType = false,
    Function(dynamic) listener,
  ]) async {
    _state = TaskState.RUNNING;
    var retFuture = _initTask(arg, ignoreInvalidType ?? false, listener);
    _isolate = await Isolate.spawn(
      _process,
      _mainRecievePort.sendPort,
      debugName: name,
    );
    var ret = await retFuture;
    _state = TaskState.DORMANT;
    stop();
    return ret;
  }

  void stop() => _isolate?.kill();
}

class _QueuedTask<A, R> {
  final _completer = Completer<R>();
  final A arg;
  final Function(dynamic) _listener;

  _QueuedTask(this.arg, this._listener);

  void latch(Task<A, R> task) async {
    var ret = await task.execute(arg, false, _listener);
    _completer.complete(ret);
  }

  Future<R> wait() => _completer.future;
}

class TaskPool<A, R> {
  final int size;
  final void Function(SendPort) _process;
  final List<Task<A, R>> _tasks;
  final String name;
  List<_QueuedTask<A, R>> _queue;

  TaskPool(this._process, this.size, [this.name = "Task Pool"])
      : _tasks = List.generate(
          size,
          (i) => Task(_process, "$name Worker #$i"),
        ) {
    for (Task task in _tasks) {}
  }

  void _log(String message) => print("[$name] $message");

  void _next(int taskIndex) async {
    var task = _tasks[taskIndex];
    if (task.state != TaskState.DORMANT) {
      await task.completed;
    }
    if (_queue.isEmpty) return;
    var queued = _queue.removeAt(0);
    queued.latch(task);
    await task.completed;
    _next(taskIndex);
  }

  Future<R> doTask(A arg, [Function(dynamic) listener]) {
    var task = _tasks.firstWhere(
      (t) => t.state == TaskState.DORMANT,
      orElse: () => null,
    );
    if (task == null) {
      var queued = _QueuedTask<A, R>(arg, listener);
      _queue.add(queued);
      return queued.wait();
    }
    return task.execute(arg, false, listener);
  }
}
