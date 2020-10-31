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
  ReceivePort _mainRecievePort;

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
    _mainRecievePort = ReceivePort();
    _completer = Completer<R>();
    bool recievedSendPort = false;
    _mainRecievePort.listen((data) {
      if (data is SendPort) {
        if (!recievedSendPort)
          data.send(arg);
        else
          _log("Task created more than one send port! Ignoring...");
      } else if (data is Map<String, dynamic> && data["type"] == "event") {
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
    stop();
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

  void stop() {
    _isolate?.kill();
    _state = TaskState.DORMANT;
  }

  @override
  String toString() => name;
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
  final List<Task<A, R>> _tasks;
  final String name;
  List<_QueuedTask<A, R>> _queue = [];

  TaskPool(
    void Function(SendPort) process,
    this.size, [
    this.name = "Task Pool",
  ]) : _tasks = List.generate(
          size,
          (i) => Task(process, "$name Worker #$i"),
        );

  void _log(String message) => print("[$name] $message");

  void _next(Task task) async {
    if (task.state != TaskState.DORMANT) {
      await task.completed;
    }
    if (_queue.isEmpty) return;
    var queued = _queue.removeAt(0);
    _log("Performing queued task with argument ${queued.arg} on ${task.name}");
    queued.latch(task);
    await task.completed;
    _next(task);
  }

  Future<R> doTask(A arg, [Function(dynamic) listener]) async {
    var task = _tasks.firstWhere(
      (t) => t.state == TaskState.DORMANT,
      orElse: () => null,
    );
    if (task == null) {
      _log("Queueing with argument $arg");
      var queued = _QueuedTask<A, R>(arg, listener);
      _queue.add(queued);
      return queued.wait();
    }
    _log("Performing with argument $arg on ${task.name}");
    var res = await task.execute(arg, false, listener);
    _next(task);
    return res;
  }
}
