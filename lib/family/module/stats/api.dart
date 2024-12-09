part of 'stats.dart';

class StatsApi {
  late final _api = DI.get<Api>();
  late final _accountId = DI.get<AccountId>();
  late final _marshal = JsonStatsMarshall();

  Future<JsonStatsEndpoint> fetch(
      Marker m, DeviceTag tag, String since, String downsample) async {
    final response = await _api.get(ApiEndpoint.getStats, m, params: {
      ApiParam.accountId: await _accountId.now(),
      ApiParam.deviceTag: tag.toString(),
      ApiParam.statsSince: since,
      ApiParam.statsDownsample: downsample,
    });
    return _marshal.toEndpoint(response);
  }
}
