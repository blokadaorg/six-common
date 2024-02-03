import 'dart:async';

import 'package:collection/collection.dart';

import '../tracer/collectors.dart';
import '../tracer/tracer.dart';
import '../util/di.dart';
import '../util/trace.dart';

typedef Action<I> = Future<void> Function(I);

const machine = Machine();

class Machine {
  const Machine();
}

mixin Context<C> {
  Context<C> copy();
}

typedef State = String;

class FailBehavior {
  final String state;
  final bool saveContext;

  FailBehavior(this.state, {this.saveContext = false});
}

mixin StateMachineActions<T> {
  late final Act Function() act;
  late final Function(String) log;
  late final Function(Function(T)) guard;
  late final Future<T> Function(Function(T)) wait;
  late final Function(Function(T), {bool saveContext}) onFail;
}

abstract class StateMachine<C extends Context<C>> {
  final _queue = <Future Function()>[];

  final Map<String, Function(State, C)> _anyStateListeners = {};
  final Map<State, Map<String, Function(State, C)>> _stateListeners = {};
  final Map<State, List<Completer<C>>> _waitingForState = {};

  late final Map<Function(C), String> states;

  State _state;
  Completer<void>? _enteringCompleter;

  FailBehavior failBehavior;
  late FailBehavior _commonFailBehavior;

  C _context;
  late C _draft;

  late Trace trace;

  StateMachine(this._state, this._context, this.failBehavior) {
    // trace = DefaultTrace.as(
    //     generateTraceId(8), "machine", runtimeType.toString(),
    //     important: false);
    _commonFailBehavior = failBehavior;
  }

  enter(State state) async {
    queue(() async {
      await _enter(state);
    });
  }

  _enter(State state) async {
    handleLog("enter: $state");
    _state = state;

    // Execute entering action
    final action =
        states.entries.firstWhereOrNull((it) => it.value == state)?.key;

    if (action != null) {
      try {
        handleLog("action: $state");
        failBehavior = _commonFailBehavior;
        //_enteringCompleter = Completer<void>();
        _draft = _context.copy() as C;

        final next = await action(_draft);

        handleLog("done action: $state");
        _context = _draft;

        final nextState = states[next];
        if (nextState != null) _enter(nextState);
      } catch (e, s) {
        failEntering(e, s);
      }
    }
    onStateChangedExternal(state);
  }

  event(String name, Function(C) fn) async {
    queue(() async {
      await _event(name, fn);
    });
  }

  _event(String name, Function(C) fn) async {
    try {
      handleLog("start event: $name");
      failBehavior = _commonFailBehavior;
      _draft = _context.copy() as C;

      final next = await fn(_draft);

      handleLog("done event: $name");
      _context = _draft;

      final nextState = states[next];
      if (nextState != null) _enter(nextState);
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  Future<C> startEntering(State state) async {
    if (_state != state) {
      throw Exception("invalid state: $_state, exp: $state");
    }
    if (_enteringCompleter != null) {
      handleLog("start entering: waiting for completer");
      await _enteringCompleter?.future;
    }
    return _draft;
  }

  doneEntering(State state) {
    if (_enteringCompleter == null) {
      throw Exception("doneEntering: no waiting completer");
    }
    handleLog("done entering: $state");
    _enteringCompleter?.complete();
    _enteringCompleter = null;
    //_state = state;
    _context = _draft;
    //notify(state);
  }

  failEntering(Object e, StackTrace s) {
    print("fail entering [$runtimeType] error($_state): $e");
    print(s);

    _state = failBehavior.state;
    if (failBehavior.saveContext) {
      _context = _draft;
    }
    _enter(_state);

    // Also fail the waiting completers
    for (final completers in _waitingForState.values) {
      for (final c in completers) {
        queue(() async {
          c.completeError(e, s);
        });
      }
    }
    _waitingForState.clear();
  }

  Future<C> startEvent(String name) async {
    if (_enteringCompleter != null) {
      handleLog("start event: waiting for completer");
      await _enteringCompleter?.future;
    }
    _enteringCompleter = Completer<void>();
    handleLog("start event: $name");
    failBehavior = _commonFailBehavior;
    _draft = _context.copy() as C;
    return _draft;
  }

  doneEvent(String name) {
    if (_enteringCompleter == null) {
      throw Exception("failEntering: no waiting completer");
    }
    handleLog("done event: $name");
    _enteringCompleter?.complete();
    _enteringCompleter = null;
    _context = _draft;
  }

  failEvent(Object e, StackTrace s) => failEntering(e, s);

  guardState(State state) {
    if (_state != state) throw Exception("invalid state: $_state, exp: $state");
  }

  Future<void> handleLog(String msg) async {
    print("[$runtimeType] [$_state] $msg");
    //trace.addEvent(msg);
    //trace.addAttribute("state", _state);
  }

  C getContext() {
    if (_enteringCompleter != null) {
      throw Exception("currently entering state");
    }
    return _context;
  }

  onStateChangedExternal(State state) {
    final completers = _waitingForState[state];
    if (completers != null) {
      for (final c in completers) {
        queue(() async {
          c.complete(_context);
        });
      }
      _waitingForState[state] = [];
    }

    final listeners = _stateListeners[state]?.entries;
    if (listeners != null) {
      for (final e in listeners) {
        final tag = e.key;
        final fn = e.value;

        queue(() async {
          fn(state, _context);
        });
      }
    }

    final anyListeners = _anyStateListeners.entries;
    for (final e in anyListeners) {
      final tag = e.key;
      final fn = e.value;

      queue(() async {
        fn(state, _context);
      });
    }
  }

  addOnState(State state, String tag, Function(State, C) fn) {
    _stateListeners[state] ??= {};
    _stateListeners[state]![tag] = fn;
  }

  addOnStateChange(String tag, Function(State, C) fn) {
    _anyStateListeners[tag] = fn;
  }

  Future<C> waitForState(State state) async {
    if (_state == state) return _context;
    final c = Completer<C>();
    _waitingForState[state] ??= [];
    _waitingForState[state]!.add(c);
    return c.future;
  }

  queue(Future Function() fn) {
    _queue.add(fn);
    _process();
  }

  _process() async {
    await Future(() async {
      while (_queue.isNotEmpty) {
        await _queue.removeAt(0)();
      }
    });
  }
}
