import 'trace.dart';

mixin Emitter {
  final Map<EmitterEvent, List<Function(Trace)>> _valueListeners = {};

  willAcceptOn(List<EmitterEvent> events) {
    _valueListeners.clear();
    _valueListeners.addEntries(events.map((it) => MapEntry(it, [])));
  }

  addOn(EmitterEvent on, Function(Trace) listener) {
    final listeners = _valueListeners[on];
    if (listeners == null) throw Exception("Unknown event");
    listeners.add(listener);
  }

  removeOn(EmitterEvent on, dynamic listener) {
    _valueListeners[on]?.remove(listener);
  }

  emit<T>(EmitterEvent<T> on, Trace trace, T value) async {
    trace.addEvent("emit event: $on");
    final listeners = _valueListeners[on];
    if (listeners == null) throw Exception("Unknown event");
    for (final listener in listeners.toList()) {
      // Ignore any listener errors
      try {
        await listener(trace);
      } catch (e) {
        trace.addEvent("listener threw error: ${e.runtimeType}");
        trace.addEvent("listener threw error, detail: $e");
      }
    }
  }
}

mixin ValueEmitter<T> {
  final List<Function(Trace, T)> _listeners = [];
  final executor = CallbackExecutor();
  late EmitterEvent<T> event;

  willAcceptOnValue(EmitterEvent<T> event) {
    this.event = event;
    _listeners.clear();
  }

  addOnValue(EmitterEvent<T> on, Function(Trace, T) listener) {
    if (on != event) throw Exception("Unknown event");
    _listeners.add(listener);
  }

  removeOnValue(EmitterEvent<T> on, dynamic listener) {
    _listeners.remove(listener);
  }

  emitValue(EmitterEvent<T> on, Trace trace, T value) async {
    if (on != event) throw Exception("Unknown event");
    for (final listener in _listeners.toList()) {
      await executor.callListener(on, listener, value);
    }
  }

  _callListener(Trace trace, Function(Trace, T) listener, T value) async {
    try {
      trace.addEvent("listener call");
      await listener(trace, value);
      trace.addEvent("listener done");
    } catch (e) {
      trace.addEvent("listener threw error: ${e.runtimeType}");
      trace.addEvent("listener threw error, detail: $e");
    }
  }
}

class EmitterEvent<T> {
  final String name;

  EmitterEvent(this.name);

  @override
  String toString() => name;
}

class CallbackExecutor with TraceOrigin {
  callListener<T>(
      EmitterEvent<T> on, Function(Trace, T) listener, T value) async {
    // Ignore any listener errors
    // Don't wait for finish to not block other events
    traceAs("on:$on", (trace) async {
      await listener(trace, value);
    });
  }
}
