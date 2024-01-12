import 'dart:convert';

import 'package:common/account/account.dart';
import 'package:common/http/http.dart';

import '../stage/machine.dart';
import 'json.dart';

typedef Json = Map<String, dynamic>;

class PersistenceRequest {
  final String key;
  final bool secure;
  const PersistenceRequest({required this.key, this.secure = false});
}

enum AccountState {
  load,
  create,
  stale,
  retry,
  retryCreate,
  fresh,
  ready,
  fatal,
}

class AccountContext {
  late JsonAccount account;
  DateTime lastRefresh = DateTime(0);
  int refreshErrors = 0;

  id() => account.id;
  type() => accountTypeFromName(account.type);
}

@Machine(initial: AccountState.load)
mixin Account {
  //@OnEnter(state: load)
  // @OnSuccess(newState: stale)
  // @OnFailure(newState: create)
  @Dependency(name: "load", tag: "Persistence")
  doLoad(AccountContext c, Dep<Json, PersistenceRequest> load) async {
    final json = await load(const PersistenceRequest(key: "account"));
    c.account = JsonAccount.fromJson(json);
    // ensurevalid
    c.refreshErrors = 0;
    //state.context.lastRefresh = 0;
  }

  // @OnEnter(state: create)
  // @OnSuccess(newState: fresh)
  @OnFailure(newState: AccountState.retryCreate, saveContext: true)
  @Dependency(name: "api", tag: "Api")
  doCreate(AccountContext c, Dep<String, HttpRequest> api) async {
    try {
      final json = await api(const HttpRequest(url: "/account", type: "POST"));
      c.account = JsonAccount.fromJson(jsonDecode(json)["account"]);
      c.refreshErrors = 0;
      c.lastRefresh = DateTime.now();
    } catch (e) {
      c.refreshErrors++;
      rethrow;
    }
  }

  // @OnEnter(state: stale)
  // @OnSuccess(newState: fresh)
  @OnFailure(newState: AccountState.retry, saveContext: true)
  @Dependency(name: "api", tag: "Api")
  doFetch(AccountContext c, Dep<String, HttpRequest> api) async {
    try {
      final json = await api(HttpRequest(url: "/account?account_id=${c.id()}"));
      c.account = JsonAccount.fromJson(jsonDecode(json)["account"]);
      c.refreshErrors = 0;
      c.lastRefresh = DateTime.now();
    } catch (e) {
      c.refreshErrors++;
      rethrow;
    }
  }

  // @OnEnter(state: retry)
  // @OnSuccess(newState: stale)
  // @OnFailure(newState: fatal)
  doRetry(AccountContext c) async {
    if (c.refreshErrors >= 3) throw Exception("too many errors");
    // await delay(3000)
  }

  // @OnEnter(state: retryCreate)
  // @OnSuccess(newState: create)
  // @OnFailure(newState: fatal)
  doRetryCreate(AccountContext c) async {
    if (c.refreshErrors >= 3) throw Exception("too many errors");
    // await delay(3000)
  }

  // @OnEnter(state: fresh)
  // @OnSuccess(newState: ready)
  // @OnFailure(newState: fatal)
  doPersist(AccountContext c, Future Function(String) persist) async {
    await persist(c.account!);
    // refresh account logic kicking after some time
  }

  // @From(state: ready)
  // @OnSuccess(newState: fresh)
  // @Dep(getUser, type: Http, params: {url: "/account?accountId=@accountId"})
  // No context changes are persisted on exception
  restore(AccountContext c,
      Future<String> Function(Map<String, String>) getUser, String id) async {
    c.account = await getUser({"accountId": id});
    c.refreshErrors = 0;
    c.lastRefresh = DateTime.now();
  }
}

enum ApiState {
  init,
  fetch,
  retry,
  success,
  failure,
}

class ApiContext with Context<ApiContext> {
  late HttpRequest request;
  String? payload;
  String? result;
  Exception? error;
  int retries = 3;

  @override
  Context<ApiContext> copy() {
    final c = ApiContext();
    c.request = request;
    c.payload = payload;
    c.result = result;
    c.error = error;
    c.retries = retries;
    return c;
  }
}

class HttpRequest {
  final String url;
  final String type;
  final int retries;
  const HttpRequest({required this.url, this.type = "GET", this.retries = 3});
}

@Machine(initial: ApiState.init) // final, fatal
mixin Api {
  // @From(state: init)
  // @OnSuccess(newState: fetch)
  // @OnFailure(newState: failure)
  doRequest(ApiContext c, HttpRequest request) async {
    if (request.retries < 0) throw Exception("invalid retries param");
    c.request = request;
    c.retries = request.retries;
    c.result = null;
  }

  // @OnEnter(state: fetch)
  // @OnSuccess(newState: success)
  // @OnFailure(newState: retry, saveContext: true)
  // @Dep("http", tag: "Http")
  doFetch(ApiContext c, Fun<String, HttpRequest> http) async {
    try {
      c.result = await http(c.request);
    } on Exception catch (e) {
      c.error = e;
    }
  }

  // @OnEnter(state: retry)
  // @OnSuccess(newState: fetch)
  // @OnFailure(newState: failure, saveState: true)
  doRetry(ApiContext c) async {
    final error = c.error;
    if (error is HttpCodeException && !error.shouldRetry()) throw error;
    if (c.retries-- <= 0) throw error ?? Exception("unknown error");
    // await delay(3000)
  }
}
