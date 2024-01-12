import 'dart:async';

import '../http/channel.pg.dart';
import '../util/di.dart';
import 'accountmachine.dart';
import '../stage/machine.dart';

class ApiActor extends Actor<ApiState, ApiContext> with Api {
  Completer<String>? _completer;

  ApiActor() : super(ApiState.init, ApiContext());

  Future<String> api(HttpRequest r) async {
    await request(r);
    return await _completer!.future;
  }

  request(HttpRequest request) async {
    guard(ApiState.init);
    _completer = Completer();
    final c = prepareContextDraft();
    try {
      await super.doRequest(c, request);
      updateState(ApiState.fetch);
    } catch (e) {
      updateStateFailure(ApiState.failure);
    }
  }

  fetch() async {
    guard(ApiState.fetch);
    final http = dep<Dep<String, HttpRequest>>(); // tag
    //final fetcher = _mockFetcher;
    final c = prepareContextDraft();
    try {
      await super.doFetch(c, http);
      updateState(ApiState.success);
    } catch (e) {
      updateStateFailure(ApiState.retry, saveContext: true);
    }
  }

  _updateState(ApiState newState) {
    // queue
    _state = newState;
    if (_state == ApiState.fetch) {
      fetch();
    } else if (_state == ApiState.retry) {
      _doRetry();
    } else if (_state == ApiState.success) {
      _completer?.complete(_context.result);
    } else if (_state == ApiState.failure) {
      _completer?.completeError(_context.error!);
    }
  }
}

// DI registrations elsewhere
// register("HttpClient", (c) => HttpClient());

Future<String> _mockFetcher(ApiContext c) async {
  if (c.url == "fail") throw Exception("failed");
  return "success";
}

Future<String> actualHttp(HttpRequest r) async {
  final HttpOps client = dep();
  return await client.doGet(r.url);
}

Future<String> actualApi(HttpRequest r) async {
  final ApiActor api = ApiActor();
  return await api.api(r);
}
