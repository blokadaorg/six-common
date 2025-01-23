part of 'core.dart';

abstract class CoreChannel with PersistenceChannel {}

class PlatformCoreChannel extends CoreChannel {
  late final _ops = CoreOps();

  @override
  Future<JsonString> doLoad(String key, bool isSecure, bool isBackup) =>
      _ops.doLoad(key, isSecure, isBackup);

  @override
  Future<void> doSave(
          String key, JsonString value, bool isSecure, bool isBackup) =>
      _ops.doSave(key, value, isSecure, isBackup);

  @override
  Future<void> doDelete(String key, bool isSecure, bool isBackup) =>
      _ops.doDelete(key, isSecure, isBackup);
}

// Used only in mocked builds that do not interact with platform
class RuntimeCoreChannel extends CoreChannel {
  final Map<String, String> _map = {};

  @override
  Future<void> doDelete(String key, bool isSecure, bool isBackup) async {}

  @override
  Future<String> doLoad(String key, bool isSecure, bool isBackup) async {
    if (!_map.containsKey(key)) {
      throw Exception("No (mocked) persistence for: $key");
    }
    return _map[key] ?? '';
  }

  @override
  Future<void> doSave(
      String key, String value, bool isSecure, bool isBackup) async {
    _map[key] = value;
  }
}
