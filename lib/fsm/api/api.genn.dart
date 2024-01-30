import 'dart:async';

import '../../util/di.dart';
import '../machine.dart';
import 'api.dart';

class _ApiContext with ApiContext, Context<_ApiContext> {
  _ApiContext(HttpRequest request, String? result, Exception? error,
      {int retries = 3}) {
    this.request = request;
    this.result = result;
    this.error = error;
    this.retries = retries;
  }

  _ApiContext.empty();

  @override
  Context<_ApiContext> copy() =>
      _ApiContext(request, result, error, retries: retries);

  @override
  String toString() =>
      "ApiContext{request: $request, result: $result, error: $error, retries: $retries}";
}

class ApiActor extends Actor<ApiState, _ApiContext> with ApiStateMachine {
  Completer<String>? _completer;

  ApiActor() : super(ApiState.init, _ApiContext.empty());

  Future<ApiContext> request(HttpRequest request) async {
    guard(ApiState.init);

    final c = prepareContextDraft();
    try {
      await super.eventRequest(c, request);
      updateState(ApiState.fetch);
      return await waitForState(ApiState.success);
    } catch (e, s) {
      updateStateFailure(e, s, ApiState.failure);
      rethrow;
    }
  }

  Future<ApiContext> apiRequest(ApiEndpoint endpoint) async {
    guard(ApiState.init);

    final queryParam = dep<Query<String, String>>(instanceName: "queryParam");

    final c = prepareContextDraft();
    try {
      await super.eventApiRequest(c, endpoint, queryParam);
      updateState(ApiState.fetch);
      return await waitForState(ApiState.success);
    } catch (e, s) {
      updateStateFailure(e, s, ApiState.failure);
      rethrow;
    }
  }

  _stateFetch() async {
    guard(ApiState.fetch);

    final http = dep<Query<String, HttpRequest>>(instanceName: "http");

    final c = prepareContextDraft();
    try {
      await super.stateFetch(c, http);
      updateState(ApiState.success);
    } catch (e, s) {
      updateStateFailure(e, s, ApiState.retry, saveContext: true);
    }
  }

  _stateRetry() async {
    guard(ApiState.retry);

    final c = prepareContextDraft();
    try {
      await super.stateRetry(c);
      updateState(ApiState.fetch);
    } catch (e, s) {
      updateStateFailure(e, s, ApiState.failure, saveContext: true);
    }
  }

  @override
  onStateChanged(ApiState newState) {
    if (newState == ApiState.fetch) {
      _stateFetch();
    } else if (newState == ApiState.retry) {
      _stateRetry();
    } else if (newState == ApiState.success) {
      _completer?.complete(prepareContextDraft().result);
    } else if (newState == ApiState.failure) {
      _completer?.completeError(prepareContextDraft().error!);
    }
  }
}

// Future<String> actualHttp(HttpRequest r) async {
//   final HttpOps client = dep();
//   return await client.doGet(r.url);
// }
