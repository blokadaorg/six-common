import 'package:common/logger/logger.dart';

import '../../common/model.dart';
import '../../util/di.dart';
import '../api/api.dart';

class CustomListApi {
  late final _api = dep<Api>();
  late final _marshal = JsonCustomListMarshal();

  Future<List<JsonCustomList>> fetchForProfile(
      String profileId, Marker m) async {
    final response = await _api.request(
      ApiEndpoint.getCustomList,
      m,
      params: {ApiParam.profileId: profileId},
    );
    return _marshal.toCustomList(response);
  }

  add(String profileId, JsonCustomList entry, Marker m) async {
    await _api.request(ApiEndpoint.postCustomList, m,
        payload: _marshal.fromPayload(JsonCustomListPayload.forCreate(
          profileId: profileId,
          domainName: entry.domainName,
          action: entry.action,
        )));
  }

  delete(String profileId, JsonCustomList entry, Marker m) async {
    await _api.request(ApiEndpoint.deleteCustomList, m,
        payload: _marshal.fromPayload(JsonCustomListPayload.forDelete(
          profileId: profileId,
          domainName: entry.domainName,
        )));
  }
}
