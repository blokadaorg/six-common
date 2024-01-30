import '../../http/http.dart';
import '../machine.dart';

enum ApiState {
  init,
  fetch,
  retry,
  success,
  failure,
}

mixin ApiContext {
  late HttpRequest request;
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

// @Machine(initial: ApiState.init) // final, fatal
mixin ApiStateMachine {
  // @OnEnter(state: fetch)
  // @OnSuccess(newState: success)
  // @OnFailure(newState: retry, saveContext: true)
  // @Dep("http", tag: "Http")
  stateFetch(ApiContext c, Query<String, HttpRequest> http) async {
    try {
      c.result = await http(c.request);
    } on Exception catch (e) {
      c.error = e;
      rethrow;
    }
  }

  // @OnEnter(state: retry)
  // @OnSuccess(newState: fetch)
  // @OnFailure(newState: failure, saveState: true)
  stateRetry(ApiContext c) async {
    final error = c.error;
    if (error is HttpCodeException && !error.shouldRetry()) throw error;
    if (c.retries-- <= 0) throw error ?? Exception("unknown error");
    // await delay(3000)
  }

  // @From(state: init)
  // @OnSuccess(newState: fetch)
  // @OnFailure(newState: failure)
  eventRequest(ApiContext c, HttpRequest request) async {
    if (request.retries < 0) throw Exception("invalid retries param");
    c.request = request;
    c.retries = request.retries;
    c.result = null;
  }

  // @From(state: init)
  // @OnSuccess(newState: fetch)
  // @OnFailure(newState: failure)
  // @Dep("queryParam")
  eventApiRequest(
    ApiContext c,
    ApiEndpoint e,
    Query<String, String> queryParam,
  ) async {
    var url = e.template;
    for (final param in e.params) {
      final value = await queryParam(param);
      url = url.replaceAll("($param)", value);
    }

    print(url);

    c.request = HttpRequest(
      url: url,
      type: e.type,
    );
    c.result = null;
  }
}
