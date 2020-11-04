import 'dart:async';
import 'dart:isolate';

class MalformedTaskReturnError extends Error {
  final dynamic data;

  MalformedTaskReturnError(this.data);

  @override
  String toString() =>
      "Task returned malformed data: $data\n\nPlease use the static methods Task.event and task.end";
}

class TaskReturnTypeError extends TypeError {
  final Type type;

  TaskReturnTypeError(this.type) : assert(type != null);

  @override
  String toString() => "Task returned data of invalid type $type";
}

class TaskProcess<R> {
  final Task<dynamic, R> _task;
  final Future<R> _returnFuture;

  TaskProcess(this._task, this._returnFuture);

  Future<R> get done => _returnFuture;

  void cancel() => _task.stop();
}

enum TaskReturnType { END, EVENT }

class TaskReturn<T> {
  final TaskReturnType type;
  final T data;
  final String eventName;

  TaskReturn(this.type, this.data, [this.eventName])
      : assert(type != null),
        assert(data != null);
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
    assert(mainSendPort != null);
    final isolateRecievePort = ReceivePort();
    mainSendPort.send(isolateRecievePort.sendPort);
    final completer = Completer<dynamic>();
    isolateRecievePort.listen((data) => completer.complete(data));
    return completer.future.then((v) => v as T);
  }

  static void event(dynamic value, SendPort port, [String name]) {
    assert(port != null);
    port.send(TaskReturn(TaskReturnType.EVENT, value, name));
  }

  static void end<T>(T value, SendPort port) {
    assert(port != null);
    port.send(TaskReturn<T>(TaskReturnType.END, value, "return"));
  }

  Task(this._process, [this.name = "Unnamed Task"])
      : assert(_process != null),
        assert(name != null);

  void _log(String message) => print("[$name] $message");

  static void _handleResponse<R>(
    dynamic data, {
    void Function(dynamic value, String name) onEvent,
    void Function(R) onReturn,
  }) {
    if (!(data is TaskReturn)) throw MalformedTaskReturnError(data);
    if (!(data is TaskReturn<R>)) throw TaskReturnTypeError(data.runtimeType);
    TaskReturn<R> ret = data;
    switch (ret.type) {
      case TaskReturnType.EVENT:
        onEvent?.call(ret.data, ret.eventName);
        break;
      case TaskReturnType.END:
        onReturn?.call(ret.data);
    }
  }

  Future<R> _initTask(
    A arg, {
    void Function(dynamic value, String name) eventListener,
  }) {
    _mainRecievePort = ReceivePort();
    _completer = Completer<R>();
    bool recievedSendPort = false;
    _mainRecievePort.listen((data) {
      if (data is SendPort) {
        if (!recievedSendPort)
          data.send(arg);
        else
          _log("Task created more than one send port! Ignoring...");
      } else
        _handleResponse(
          data,
          onEvent: (e, n) => eventListener?.call(e, n),
          onReturn: (r) => _completer.complete(r),
        );
    });
    return _completer.future;
  }

  Future<TaskProcess<R>> execute(
    A arg, {
    Function(dynamic value, String name) eventListener,
  }) async {
    stop();
    _state = TaskState.RUNNING;
    var retFuture = _initTask(arg, eventListener: eventListener);
    _isolate = await Isolate.spawn(
      _process,
      _mainRecievePort.sendPort,
      debugName: name,
    );
    return TaskProcess(this, retFuture.then((ret) {
      _state = TaskState.DORMANT;
      stop();
      return ret;
    }));
  }

  void stop() {
    _isolate?.kill();
    _state = TaskState.DORMANT;
  }

  @override
  String toString() => name;
}

class _QueuedTask<A, R> {
  final _completer = Completer<TaskProcess<R>>();
  final A arg;
  final Function(dynamic value, String name) _listener;

  _QueuedTask(this.arg, this._listener);

  void latch(Task<A, R> task) async {
    var process = await task.execute(arg, eventListener: _listener);
    _completer.complete(process);
  }

  Future<TaskProcess<R>> process() => _completer.future;
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
  ])  : assert(process != null),
        assert(size != null),
        assert(name != null),
        _tasks = List.generate(
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

  Future<TaskProcess<R>> doTask(
    A arg, [
    void Function(dynamic value, String name) listener,
  ]) async {
    var task = _tasks.firstWhere(
      (t) => t.state == TaskState.DORMANT,
      orElse: () => null,
    );
    if (task == null) {
      _log("Queueing with argument $arg");
      var queued = _QueuedTask<A, R>(arg, listener);
      _queue.add(queued);
      return queued.process();
    }
    _log("Performing with argument $arg on ${task.name}");
    var res = await task.execute(arg, eventListener: listener);
    _next(task);
    return res;
  }
}
