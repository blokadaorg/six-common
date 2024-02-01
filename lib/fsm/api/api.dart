import 'dart:async';

import '../../account/account.dart';
import '../../http/channel.pg.dart';
import '../../http/http.dart';
import '../../util/di.dart';
import '../machine.dart';

part 'api.genn.dart';

mixin ApiContext {
  Map<String, String> queryParams = {};
  HttpRequest? request;
  String? result;
  Exception? error;
  int retries = 2;
}

class HttpRequest {
  final String url;
  final String type;
  final String? payload;
  final int retries;

  const HttpRequest({
    required this.url,
    this.type = "GET",
    this.payload,
    this.retries = 2,
  });
}

enum ApiEndpoint {
  getList("list", params: ["account_id"]);

  const ApiEndpoint(
    this.endpoint, {
    this.type = "GET",
    this.params = const [],
    this.base = "https://api.blocka.net/v2/",
  });

  final String endpoint;
  final String type;
  final String base;
  final List<String> params;

  String get template => base + endpoint + getParams;

  String get getParams {
    if (params.isEmpty) return "";
    final p = params.map((e) => "$e=($e)").join("&");
    return "?$p";
  }
}

abstract class BlockaHttpRequest extends HttpRequest {
  final String endpoint;

  BlockaHttpRequest({required this.endpoint})
      : super(url: "http://api.blocka.net/v2/$endpoint");
}

// @Machine
mixin ApiStates on StateMachineActions<ApiContext> {
  late Action<HttpRequest> _http;

  init(ApiContext c) async {}
  ready(ApiContext c) async {}

  fetch(ApiContext c) async {
    onFail(retry, saveContext: true);
    _http(c.request!);
    return waiting;
  }

  waiting(ApiContext c) async {}

  retry(ApiContext c) async {
    onFail(failure, saveContext: true);
    final error = c.error;
    if (error is HttpCodeException && !error.shouldRetry()) throw error;
    if (c.retries-- <= 0) throw error ?? Exception("unknown error");
    // await delay(3000)
    return fetch;
  }

  // @final
  Future<String> success(ApiContext c) async {
    return c.result!;
  }

  failure(ApiContext c) async {}

  onQueryParams(ApiContext c, Map<String, String> queryParams) async {
    guard(init);
    c.queryParams = queryParams;
    return ready;
  }

  onHttpOk(ApiContext c, String result) async {
    guard(waiting);
    c.result = result;
    return success;
  }

  onHttpFail(ApiContext c, Exception error) async {
    guard(waiting);
    c.error = error;
    return retry;
  }

  doRequest(ApiContext c, HttpRequest request) async {
    guard(ready);
    if (request.retries < 0) throw Exception("invalid retries param");
    c.request = request;
    c.retries = request.retries;
    c.result = null;

    return fetch;
  }

  doApiRequest(ApiContext c, ApiEndpoint e) async {
    guard(ready);
    var url = e.template;
    for (final param in e.params) {
      final value = c.queryParams[param]!;
      url = url.replaceAll("($param)", value);
    }

    log(url);

    c.request = HttpRequest(
      url: url,
      type: e.type,
    );
    c.result = null;

    return fetch;
  }
}

class ApiActor extends _$ApiActor {
  ApiActor(Act act) {
    if (act.isProd()) {
      final ops = HttpOps();
      final account = dep<AccountStore>();

      injectHttp((it) async {
        // TODO: err
        final result = await ops.doGet(it.url);
        onHttpOk(result);
      });

      try {
        // Account ID may be unavailable
        onQueryParams(
          {"account_id": account.id},
        );
      } catch (e) {
        print("ApiActor deps: $e");
      }
    }
  }
}
