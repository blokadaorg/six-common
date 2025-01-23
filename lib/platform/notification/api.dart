import 'dart:convert';

import 'package:common/common/module/api/api.dart';
import 'package:common/core/core.dart';

import '../account/account.dart';
import '../plus/keypair/keypair.dart';

class JsonAppleNotificationPayload {
  late String publicKey;
  late String appleToken;

  JsonAppleNotificationPayload({
    required this.publicKey,
    required this.appleToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account_id'] = ApiParam.accountId.placeholder;
    data['public_key'] = publicKey;
    data['device_token'] = appleToken;
    return data;
  }
}

class NotificationMarshal {
  JsonString fromPayload(JsonAppleNotificationPayload payload) {
    return jsonEncode(payload.toJson());
  }
}

class NotificationApi {
  late final _api = Core.get<Api>();
  late final _account = Core.get<AccountStore>();
  late final _keypair = Core.get<PlusKeypairStore>();
  late final _marshal = NotificationMarshal();

  Future<void> postToken(String appleToken, Marker m) async {
    final payload = JsonAppleNotificationPayload(
      publicKey: _keypair.currentKeypair!.publicKey,
      appleToken: appleToken,
    );

    await _api.request(ApiEndpoint.postNotificationToken, m,
        payload: _marshal.fromPayload(payload));
  }
}
