part of 'common.dart';

abstract class CommonChannel with RateChannel, EnvChannel, LinkChannel {}

class PlatformCommonChannel extends CommonChannel {
  late final _ops = CommonOps();

  @override
  Future<void> doShowRateDialog() => _ops.doShowRateDialog();

  @override
  Future<EnvInfo> doGetEnvInfo() async {
    final e = await _ops.doGetEnvInfo();
    return EnvInfo(
      e.appVersion,
      e.osVersion,
      e.buildFlavor,
      e.buildType,
      e.cpu,
      e.deviceBrand,
      e.deviceModel,
      e.deviceName,
    );
  }

  @override
  Future<void> doLinksChanged(Map<LinkId, String> links) async =>
      await _ops.doLinksChanged(
        links.entries
            .map((e) => OpsLink(id: e.key.name, url: e.value))
            .toList(),
      );
}

class NoOpCommonChannel extends CommonChannel {
  @override
  Future<void> doShowRateDialog() => Future.value();

  @override
  Future<EnvInfo> doGetEnvInfo() async => EnvInfo(
        "mockVersion",
        "mockOsVersion",
        "mockBuildFlavor",
        "mockBuildType",
        "mockCpu",
        "mockDeviceBrand",
        "mockDeviceModel",
        "mockDevice",
      );

  @override
  Future<void> doLinksChanged(Map<LinkId, String> links) => Future.value();
}
