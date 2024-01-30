import 'dart:async';

import '../util/di.dart';

class OnEnter<T> {
  final T state;
  const OnEnter({required this.state});
}

class OnFailure<T> {
  final T newState;
  final bool saveContext;
  const OnFailure({required this.newState, this.saveContext = false});
}

class Dependency<I> {
  final String name;
  final String tag;

  const Dependency({required this.name, required this.tag});
}

typedef Query<O, I> = Future<O> Function(I);
typedef Get<O> = Future<O> Function();
typedef Put<I> = Future<void> Function(I);

class Machine<T> {
  final T initial;
  //final T finalState;
  //final T fatal;
  const Machine({required this.initial});
}

mixin Context<C> {
  Context<C> copy();
}

class ActAware {
  late Act act;
}

abstract class Actor<T, C extends Context<C>> {
  final _queue = <Function()>[];
  final Map<String, Function(T, C)> _anyStateListeners = {};
  final Map<T, Map<String, Function(T, C)>> _stateListeners = {};
  final Map<T, List<Completer<C>>> _waitingForState = {};

  T _state;

  C _context;
  late C _contextDraft;
  bool initialized = false;

  Actor(this._state, this._context) {
    updateState(_state, saveContext: false);
  }

  C prepareContextDraft() {
    if (!initialized) {
      _contextDraft = _context;
    } else {
      _contextDraft = _context.copy() as C;
    }
    return _contextDraft;
  }

  updateState(T newState, {bool saveContext = true}) {
    queue(() {
      _state = newState;
      print("[$runtimeType] state: $_state");

      if (saveContext) {
        _context = _contextDraft;
        initialized = true;
        //print("[$runtimeType] context changed: $_context");
      }

      onStateChanged(newState);
      onStateChangedExternal(newState);
    });
  }

  updateStateFailure(Object e, StackTrace s, T newState,
      {bool saveContext = false}) {
    print("[$runtimeType] error($_state): $e");
    print(s);
    updateState(newState, saveContext: saveContext);
  }

  onStateChanged(T newState);

  onStateChangedExternal(T newState) {
    queue(() {
      final completers = _waitingForState[newState];
      if (completers != null) {
        for (final c in completers) {
          queue(() {
            c.complete(_context);
          });
        }
        _waitingForState[newState] = [];
      }

      final listeners = _stateListeners[newState]?.entries;
      if (listeners != null) {
        for (final e in listeners) {
          final tag = e.key;
          final fn = e.value;

          queue(() {
            fn(newState, _context);
          });
        }
      }

      final anyListeners = _anyStateListeners.entries;
      for (final e in anyListeners) {
        final tag = e.key;
        final fn = e.value;

        queue(() {
          fn(newState, _context);
        });
      }
    });
  }

  addOnState(T newState, String tag, Function(T, C) fn) {
    queue(() {
      _stateListeners[newState] ??= {};
      _stateListeners[newState]![tag] = fn;
    });
  }

  addOnStateChange(String tag, Function(T, C) fn) {
    queue(() {
      _anyStateListeners[tag] = fn;
    });
  }

  Future<C> waitForState(T newState) async {
    final c = Completer<C>();
    queue(() {
      _waitingForState[newState] ??= [];
      _waitingForState[newState]!.add(c);
    });
    return await c.future;
  }

  isState(T state) => _state == state;

  guard(T state) {
    if (_state != state) throw Exception("invalid state: $_state, exp: $state");
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
