import 'package:common/common/model.dart';
import 'package:common/dragon/api/api.dart';
import 'package:common/logger/logger.dart';
import 'package:common/util/di.dart';

class AuthApi {
  late final _api = dep<Api>();
  late final _marshal = JsonAuthMarshal();

  Future<JsonAuthEndpoint> auth(
      String accountId, DeviceTag deviceTag, Marker m) async {
    final response = await _api.request(
      ApiEndpoint.postToken,
      m,
      payload: _marshal.fromPayload(
          JsonAuthPayload(accountId: accountId, deviceTag: deviceTag)),
    );
    return _marshal.toEndpoint(response);
  }

  Future<JsonAuthEndpoint> refresh(String token, Marker m) async {
    final response = await _api.request(
      ApiEndpoint.postTokenRefresh,
      m,
      headers: {"Authorization": "Bearer $token"},
    );
    return _marshal.toEndpoint(response);
  }

  Future<JsonAuthEndpoint> getInfo(String token, Marker m) async {
    final response = await _api.request(
      ApiEndpoint.getTokenInfo,
      m,
      headers: {"Authorization": "Bearer $token"},
    );
    return _marshal.toEndpoint(response);
  }

  sendHeartbeat(String token, Marker m) async {
    await _api.request(
      ApiEndpoint.postHeartbeat,
      m,
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
