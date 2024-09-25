import 'dart:math';

import 'package:common/common/model.dart';
import 'package:common/dragon/api/api.dart';
import 'package:common/util/di.dart';

class SupportApi {
  late final _api = dep<Api>();
  late final _marshal = JsonSupportMarshal();

  Future<JsonSupportSession> createSession(String language) async {
    final result = await _api.request(ApiEndpoint.postSupport,
        payload: _marshal.fromCreateSession(JsonSupportPayloadCreateSession(
          language: language,
        )));
    print("create session: $result");
    return _marshal.toSession(result);
  }

  Future<JsonSupportResponse> sendEvent(
      String sessionId, SupportEvent event) async {
    final result = await _api.request(ApiEndpoint.putSupport,
        payload: _marshal.fromMessage(JsonSupportPayloadMessage(
          sessionId: sessionId,
          event: event,
        )));
    print("send event: $result");
    return _marshal.toResponse(result);
  }

  Future<JsonSupportResponse> sendMessage(
      String sessionId, String message) async {
    final payload = _marshal.fromMessage(JsonSupportPayloadMessage(
      sessionId: sessionId,
      message: message,
    ));

    // Fail every random for testing
    if (Random().nextInt(5) == 0) {
      throw Exception("Random failure");
    }

    if (Random().nextInt(4) == 0) {
      throw HttpCodeException(400, "simulating session excp");
    }

    final result = await _api.request(ApiEndpoint.putSupport, payload: payload);
    print("send msg: $result");
    return _marshal.toResponse(result);
  }
}
