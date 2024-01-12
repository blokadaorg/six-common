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

typedef Dep<O, I> = Future<O> Function(I);
typedef Dep2<O> = Future<O> Function();

class Machine<T> {
  final T initial;
  //final T finalState;
  //final T fatal;
  const Machine({required this.initial});
}

mixin Context<C> {
  Context<C> copy();
}

abstract class Actor<T, C extends Context<C>> {
  final _queue = <Function()>[];
  final Map<T, Map<String, Function(T)>> _stateListeners = {};

  T _state;

  C _context;
  late C _contextDraft;

  Actor(this._state, this._context) {
    updateState(_state);
  }

  C prepareContextDraft() {
    _contextDraft = _context.copy() as C;
    return _contextDraft;
  }

  updateState(T newState, {bool saveContext = true}) {
    queue(() {
      _state = newState;
      if (saveContext) _context = _contextDraft;
      onStateChanged(newState);
      onStateChangedExternal(newState);
    });
  }

  updateStateFailure(T newState, {bool saveContext = false}) {
    updateState(newState, saveContext: saveContext);
  }

  onStateChanged(T newState);

  onStateChangedExternal(T newState) {
    queue(() {
      final listeners = _stateListeners[newState]?.entries;
      if (listeners == null) return;
      for (final e in listeners) {
        final tag = e.key;
        final fn = e.value;

        queue(() {
          fn(newState);
        });
      }
    });
  }

  addOnStateChanged(T newState, String tag, Function(T) fn) {
    queue(() {
      _stateListeners[newState] ??= {};
      _stateListeners[newState]![tag] = fn;
    });
  }

  isState(T state) => _state == state;

  guard(T state) {
    if (_state != state) throw Exception("invalid state");
  }

  queue(Function() fn) {
    _queue.add(fn);
    _process();
  }

  _process() async {
    while (_queue.isNotEmpty) {
      _queue.removeAt(0)();
    }
  }
}

mixin Emitter<T> {
  Map<String, Function(T)> _handlers = {};

  void add(String tag, Function(T) handler) {
    _handlers[tag] = handler;
  }

  void emit(T event);
}
