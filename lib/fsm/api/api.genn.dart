part of 'api.dart';

class _ApiContext with ApiContext, Context<_ApiContext> {
  _ApiContext(Map<String, String> queryParams, HttpRequest? request,
      String? result, Exception? error,
      {int retries = 3}) {
    this.queryParams = queryParams;
    this.request = request;
    this.result = result;
    this.error = error;
    this.retries = retries;
  }

  _ApiContext.empty();

  @override
  Context<_ApiContext> copy() =>
      _ApiContext(queryParams, request, result, error, retries: retries);

  @override
  String toString() =>
      "ApiContext{request: $request, result: $result, error: $error, retries: $retries}";
}

class _$ApiStates extends StateMachine<_ApiContext>
    with StateMachineActions<ApiContext>, ApiStates {
  _$ApiStates(Act act)
      : super("init", _ApiContext.empty(), FailBehavior("failure")) {
    states = {
      init: "init",
      ready: "ready",
      fetch: "fetch",
      waiting: "waiting",
      retry: "retry",
      failure: "failure",
      success: "success",
    };

    onFail = (state, {saveContext = false}) =>
        failBehavior = FailBehavior(states[state]!, saveContext: saveContext);
    guard = (state) => guardState(states[state]!);
    wait = (state) => waitForState(states[state]!);
    log = (msg) => handleLog(msg);
    this.act = () => act;

    enter("init");
  }

  eventOnQueryParams(Map<String, String> queryParams) async {
    event("queryParams", (c) async => await onQueryParams(c, queryParams));
  }

  eventOnHttpOk(String result) async {
    event("httpOk", (c) async => await onHttpOk(c, result));
  }

  eventOnHttpFail(Exception error) async {
    event("httpFail", (c) async => await onHttpFail(c, error));
  }

  Future<ApiContext> eventRequest(HttpRequest request) async {
    event("request", (c) async => await doRequest(c, request));
    await waitForState("success");
    return getContext();
  }

  Future<ApiContext> eventApiRequest(ApiEndpoint e) async {
    event("apiRequest", (c) async => await doApiRequest(c, e));
    await waitForState("success");
    return getContext();
  }
}

class _$ApiActor {
  late final _$ApiStates _machine;

  _$ApiActor(Act act) {
    _machine = _$ApiStates(act);
  }

  injectHttp(Action<HttpRequest> http) {
    _machine._http = (it) async {
      Future(() {
        http(it);
      });
    };
  }

  Future<ApiContext> doRequest(HttpRequest request) =>
      _machine.eventRequest(request);

  Future<ApiContext> doApiRequest(ApiEndpoint endpoint) =>
      _machine.eventApiRequest(endpoint);

  onQueryParams(Map<String, String> queryParams) =>
      _machine.eventOnQueryParams(queryParams);

  onHttpOk(String result) => _machine.eventOnHttpOk(result);

  onHttpFail(Exception error) => _machine.eventOnHttpFail(error);

  waitForState(String state) => _machine.waitForState(state);
}
