import 'dart:async';

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
  final _queue = <Function()>[];

  final Map<String, Function(State, C)> _anyStateListeners = {};
  final Map<State, Map<String, Function(State, C)>> _stateListeners = {};
  final Map<State, List<Completer<C>>> _waitingForState = {};

  State _state;
  State? _entering;
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

  enter(String state) async {
    handleLog("enter: $state");
    _state = state;
    await notify(state);
  }

  C startEntering(String state) {
    if (_state != state) {
      throw Exception("invalid state: $_state, exp: $state");
    }
    if (_entering != null) {
      throw Exception("already entering state: $_entering");
    }
    // handleLog("entering: $state");
    failBehavior = _commonFailBehavior;
    _entering = state;
    _enteringCompleter = Completer<void>();
    _draft = _context.copy() as C;
    return _draft;
  }

  doneEntering(String state) {
    if (_entering != state) {
      throw Exception("doneEntering: $_entering, exp: $state");
    }
    // handleLog("done entering: $state");
    _entering = null;
    _enteringCompleter?.complete();
    _enteringCompleter = null;
    //_state = state;
    _context = _draft;
    //notify(state);
  }

  failEntering(Object e, StackTrace s) {
    print("fail entering [$runtimeType] error($_state): $e");
    print(s);

    _entering = null;
    _enteringCompleter?.complete();
    _enteringCompleter = null;
    _state = failBehavior.state;
    if (failBehavior.saveContext) {
      _context = _draft;
    }

    // Also fail the waiting completers
    queue(() {
      for (final completers in _waitingForState.values) {
        for (final c in completers) {
          queue(() {
            c.completeError(e, s);
          });
        }
      }
      _waitingForState.clear();
    });
  }

  Future<C> startEvent(String name) async {
    if (_enteringCompleter != null) {
      await _enteringCompleter?.future;
    }
    // handleLog("start event: $name");
    failBehavior = _commonFailBehavior;
    _draft = _context.copy() as C;
    return _draft;
  }

  doneEvent(String name) {
    handleLog("done event: $name");
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

  notify(State state) async {
    await onStateChanged(state);
    queue(() {
      onStateChangedExternal(state);
    });
  }

  C getContext() {
    if (_entering != null) {
      throw Exception("currently entering state: $_entering");
    }
    return _context;
  }

  onStateChanged(State state);

  onStateChangedExternal(State state) {
    queue(() {
      final completers = _waitingForState[state];
      if (completers != null) {
        for (final c in completers) {
          queue(() {
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

          queue(() {
            fn(state, _context);
          });
        }
      }

      final anyListeners = _anyStateListeners.entries;
      for (final e in anyListeners) {
        final tag = e.key;
        final fn = e.value;

        queue(() {
          fn(state, _context);
        });
      }
    });
  }

  addOnState(State state, String tag, Function(State, C) fn) {
    queue(() {
      _stateListeners[state] ??= {};
      _stateListeners[state]![tag] = fn;
    });
  }

  addOnStateChange(String tag, Function(State, C) fn) {
    queue(() {
      _anyStateListeners[tag] = fn;
    });
  }

  Future<C> waitForState(State state) async {
    if (_state == state) return _context;
    final c = Completer<C>();
    queue(() {
      _waitingForState[state] ??= [];
      _waitingForState[state]!.add(c);
    });
    return c.future;
  }

  queue(Function() fn) {
    _queue.add(fn);
    _process();
  }

  _process() {
    Future(() {
      while (_queue.isNotEmpty) {
        _queue.removeAt(0)();
      }
    });
  }
}
