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
  late final Map<Function(ApiContext), String> stateFromMethod;
  late final Map<String, Function()> enterState;

  _$ApiStates(Act act)
      : super("init", _ApiContext.empty(), FailBehavior("failure")) {
    stateFromMethod = {
      init: "init",
      ready: "ready",
      fetch: "fetch",
      waiting: "waiting",
      retry: "retry",
      failure: "failure",
      success: "success",
    };
    enterState = {
      "init": enterInit,
      "ready": enterReady,
      "fetch": enterFetch,
      "waiting": enterWaiting,
      "retry": enterRetry,
      "failure": enterFailure,
      "success": enterSuccess,
    };

    onFail = (state, {saveContext = false}) => failBehavior =
        FailBehavior(stateFromMethod[state]!, saveContext: saveContext);
    guard = (state) => guardState(stateFromMethod[state]!);
    wait = (state) => waitForState(stateFromMethod[state]!);
    log = (msg) => handleLog(msg);
    this.act = () => act;

    enter("init");
  }

  @override
  onStateChanged(String newState) async {
    final next = await enterState[newState]!();
    final known = stateFromMethod[next];
    if (known != null) await enter(known);
  }

  enterInit() async {
    try {
      final c = startEntering("init");
      final next = await super.init(c);
      doneEntering("init");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterReady() async {
    try {
      final c = startEntering("ready");
      final next = await super.ready(c);
      doneEntering("ready");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterFetch() async {
    try {
      final c = startEntering("fetch");
      final next = await super.fetch(c);
      doneEntering("fetch");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterWaiting() async {
    try {
      final c = startEntering("waiting");
      final next = await super.waiting(c);
      doneEntering("waiting");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterRetry() async {
    try {
      final c = startEntering("retry");
      final next = await super.retry(c);
      doneEntering("retry");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterFailure() async {
    try {
      final c = startEntering("failure");
      final next = await super.failure(c);
      doneEntering("failure");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterSuccess() async {
    try {
      final c = startEntering("success");
      final next = await super.success(c);
      doneEntering("success");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  eventOnQueryParams(Map<String, String> queryParams) async {
    try {
      final c = await startEvent("queryParams");
      final next = await super.onQueryParams(c, queryParams);
      doneEvent("queryParams");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
    } catch (e, s) {
      failEvent(e, s);
    }
  }

  eventOnHttpOk(String result) async {
    try {
      final c = await startEvent("onHttpOk");
      final next = await super.onHttpOk(c, result);
      doneEvent("onHttpOk");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
    } catch (e, s) {
      failEvent(e, s);
    }
  }

  eventOnHttpFail(Exception error) async {
    try {
      final c = await startEvent("onHttpFail");
      final next = await super.onHttpFail(c, error);
      doneEvent("onHttpFail");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
    } catch (e, s) {
      failEvent(e, s);
    }
  }

  Future<ApiContext> eventRequest(HttpRequest request) async {
    try {
      final c = await startEvent("request");
      final next = await super.doRequest(c, request);
      doneEvent("request");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
      await waitForState("success");
      return getContext();
    } catch (e, s) {
      failEvent(e, s);
      return getContext();
    }
  }

  Future<ApiContext> eventApiRequest(ApiEndpoint e) async {
    try {
      final c = await startEvent("apiRequest");
      final next = await super.doApiRequest(c, e);
      doneEvent("apiRequest");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
      await waitForState("success");
      return getContext();
    } catch (e, s) {
      failEvent(e, s);
      return getContext();
    }
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
