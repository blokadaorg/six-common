import 'package:common/core/core.dart';
import 'package:common/platform/http/channel.pg.dart';
import 'package:flutter/services.dart';

part 'endpoint.dart';
part 'error.dart';
part 'http.dart';
part 'value.dart';

class Api {
  late final _http = DI.get<Http>();

  Future<JsonString> get(
    ApiEndpoint endpoint,
    Marker m, {
    QueryParams? params,
  }) async {
    return await _http.call(HttpRequest(endpoint), m, params: params);
  }

  Future<String> request(
    ApiEndpoint endpoint,
    Marker m, {
    QueryParams? params,
    JsonString? payload,
    Headers headers = const {},
  }) {
    return _http.call(
      HttpRequest(endpoint, payload: payload),
      m,
      params: params,
      headers: headers,
    );
  }
}

class ApiModule with Module {
  @override
  onCreateModule(Act act) async {
    await register(BaseUrl(act));
    await register(UserAgent());
    await register(ApiRetryDuration(act));

    await register(AccountId());
    await register(Http());

    await register(Api());
  }
}
