import 'dart:convert';

import 'package:common/logger/logger.dart';

import '../util/di.dart';
import 'channel.act.dart';
import 'channel.pg.dart';

abstract class PersistenceService {
  Future<void> save(String key, Map<String, dynamic> value, Marker m,
      {bool isBackup});
  Future<void> saveString(String key, String value, Marker m, {bool isBackup});
  Future<String?> load(String key, Marker m, {bool isBackup});
  Future<Map<String, dynamic>> loadOrThrow(String key, Marker m,
      {bool isBackup});
  Future<void> delete(String key, Marker m, {bool isBackup});
}

abstract class SecurePersistenceService extends PersistenceService {}

/// PlatformPersistenceImpl
///
/// I decided to use native channels for the persistence, since existing
/// Flutter libraries seem rather immature for what we need, and would bring
/// potential bugs while the solution is actually reasonably easy.
///
/// What we need from the platforms is those types of simple string storage:
/// - local storage
/// - automatically backed up storage (iCloud on iOS, Google Drive on Android)
/// - encrypted storage also automatically backed up
class PlatformPersistence extends SecurePersistenceService
    with Dependable, Logging {
  final bool isSecure;

  PlatformPersistence({required this.isSecure});

  @override
  attach(Act act) {
    depend<PersistenceOps>(getOps(act));
    depend<PersistenceService>(this);
  }

  late final _ops = dep<PersistenceOps>();

  @override
  Future<Map<String, dynamic>> loadOrThrow(String key, Marker m,
      {bool isBackup = false}) async {
    log(m).log(
        msg: "loadOrThrow",
        attr: {"key": key, "isSecure": isSecure, "isBackup": isBackup});

    final result = await _ops.doLoad(key, isSecure, isBackup);
    final parsed = jsonDecode(result);
    return parsed;
  }

  @override
  Future<String?> load(String key, Marker m, {bool isBackup = false}) async {
    try {
      log(m).log(
          msg: "load",
          attr: {"key": key, "isSecure": isSecure, "isBackup": isBackup});

      return await _ops.doLoad(key, isSecure, isBackup);
    } on Exception {
      // TODO: not all exceptions mean that the key is not found
      return null;
    }
  }

  @override
  Future<void> save(String key, Map<String, dynamic> value, Marker m,
      {bool isBackup = false}) async {
    log(m).log(
        msg: "save",
        attr: {"key": key, "isSecure": isSecure, "isBackup": isBackup});

    await _ops.doSave(key, jsonEncode(value), isSecure, isBackup);
  }

  @override
  Future<void> saveString(String key, String value, Marker m,
      {bool isBackup = false}) async {
    log(m).log(
        msg: "saveString",
        attr: {"key": key, "isSecure": isSecure, "isBackup": isBackup});

    await _ops.doSave(key, value, isSecure, isBackup);
  }

  @override
  Future<void> delete(String key, Marker m, {bool isBackup = false}) async {
    log(m).log(
        msg: "delete",
        attr: {"key": key, "isSecure": isSecure, "isBackup": isBackup});

    await _ops.doDelete(key, isSecure, isBackup);
  }
}
