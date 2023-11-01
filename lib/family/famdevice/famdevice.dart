import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:mobx/mobx.dart';

import '../../app/app.dart';
import '../../device/device.dart';
import '../../journal/journal.dart';
import '../../persistence/persistence.dart';
import '../../stats/refresh/refresh.dart';
import '../../stats/stats.dart';
import '../../util/di.dart';
import '../../util/mobx.dart';
import '../../util/trace.dart';
import 'json.dart';

part 'famdevice.g.dart';

class FamilyDevice {
  final String deviceName;
  final String deviceDisplayName;
  final UiStats stats;
  final bool thisDevice;

  FamilyDevice({
    required this.deviceName,
    required this.deviceDisplayName,
    required this.stats,
    required this.thisDevice,
  });
}

const String _key = "famdevice:devices";

class FamilyDeviceStore = FamilyDeviceStoreBase with _$FamilyDeviceStore;

abstract class FamilyDeviceStoreBase
    with Store, Traceable, TraceOrigin, Dependable {
  late final _journal = dep<JournalStore>();
  late final _device = dep<DeviceStore>();
  late final _app = dep<AppStore>();
  late final _stats = dep<StatsStore>();
  late final _statsRefresh = dep<StatsRefreshStore>();
  late final _persistence = dep<PersistenceService>();

  FamilyDeviceStoreBase() {
    _app.addOn(appStatusChanged, onAppStatusChanged);

    // TODO: this pattern is probably unwanted
    reactionOnStore((_) => _journal.allEntries, (entries) async {
      return await traceAs("discoverEntries", (trace) async {
        await discoverEntries(trace);
      });
    });

    // React to stats updates for this device
    reactionOnStore((_) => _stats.deviceStatsChangesCounter, (_) async {
      final d = devices.where((e) => e.thisDevice).firstOrNull;
      if (d == null) return;

      final stats = _stats.deviceStats[d.deviceName];
      if (stats != null) {
        final updated = devices;
        updated[devices.indexOf(d)] = FamilyDevice(
          deviceName: d.deviceName,
          deviceDisplayName: d.deviceDisplayName,
          stats: stats,
          thisDevice: true,
        );
        devices = updated;
      }
    });

    // React to this device name changes
    reactionOnStore((_) => _device.deviceAlias, (alias) async {
      final d = devices.where((e) => e.thisDevice).firstOrNull;
      if (d == null) return;

      final updated = devices;
      updated[devices.indexOf(d)] = FamilyDevice(
        deviceName: d.deviceName,
        deviceDisplayName: d.deviceDisplayName,
        stats: UiStats.empty(),
        thisDevice: true,
      );
      devices = updated;
    });
  }

  @observable
  List<FamilyDevice> devices = [];

  @observable
  int devicesChanges = 0;

  @override
  attach(Act act) {
    depend<FamilyDeviceStore>(this as FamilyDeviceStore);
  }

  @action
  Future<void> load(Trace parentTrace) async {
    return await traceWith(parentTrace, "load", (trace) async {
      final json = await _persistence.load(trace, _key);
      if (json == null) return;

      devices = JsonFamilyDevices.fromJson(jsonDecode(json))
          .devices
          .map((e) => _newDevice(e, null))
          .toList();

      await _statsRefresh.setMonitoredDevices(
          trace, devices.map((e) => e.deviceName).toList());
    });
  }

  _savePersistence(Trace trace) async {
    await _persistence.save(
        trace, _key, JsonFamilyDevices.fromList(devices).toJson());
  }

  @action
  Future<void> addDevice(Trace parentTrace) async {
    return await traceWith(parentTrace, "addDevice", (trace) async {
      final d = devices;
      d.add(_newDevice(null, null));
      devices = d;
      await _savePersistence(trace);
      devicesChanges++;
    });
  }

  @action
  Future<void> deleteDevice(Trace parentTrace, String deviceAlias) async {
    return await traceWith(parentTrace, "deleteDevice", (trace) async {
      final d = devices;
      d.removeWhere((e) => e.deviceName == deviceAlias);
      devices = d;
      devicesChanges++;
      await _savePersistence(trace);
      await _statsRefresh.setMonitoredDevices(
          trace, devices.map((e) => e.deviceName).toList());
    });
  }

  // The "this device" is special and is added dynamically if current device has
  // the private dns set correctly
  @action
  Future<void> onAppStatusChanged(Trace parentTrace) async {
    if (!_app.status.isActive()) return;
    if (devices.where((e) => e.thisDevice).isNotEmpty) return;

    return await traceWith(parentTrace, "addThisDevice", (trace) async {
      final stats = _stats.deviceStats[_device.deviceAlias];
      devices = [_newDevice(_device.deviceAlias, stats)] + devices;
      devicesChanges++;
    });
  }

  Future<void> discoverEntries(Trace parentTrace) async {
    return await traceWith(parentTrace, "discoverEntries", (trace) async {
      final existing = devices.map((e) => e.deviceName);
      final known = _journal.devices
          .filter((e) => e != _device.deviceAlias)
          .filter((e) => existing.contains(e));
      final unknown = _journal.devices
          .filter((e) => e != _device.deviceAlias)
          .filter((e) => !existing.contains(e));
      final waiting =
          devices.filter((e) => e.deviceName.isEmpty).map((e) => e.deviceName);

      final d = devices;
      for (final device in known) {
        final stats = _stats.deviceStats[device];
        final index =
            devices.indexOf(devices.firstWhere((e) => e.deviceName == device));
        d[index] = _newDevice(device, stats);
      }

      var i = 0;
      for (final device in waiting) {
        final stats = _stats.deviceStats[device];
        final discovered = unknown.elementAtOrNull(i);
        if (discovered != null) {
          final index = devices
              .indexOf(devices.firstWhere((e) => e.deviceName == device));
          d[index] = _newDevice(discovered, stats);
        }
      }
      devices = d;
      devicesChanges++;
      await _statsRefresh.setMonitoredDevices(
          trace, devices.map((e) => e.deviceName).toList());
    });
  }

  FamilyDevice _newDevice(String? deviceName, UiStats? stats) {
    var displayName = deviceName ?? "...";
    var thisDevice = false;

    if (deviceName != null && deviceName == _device.deviceAlias) {
      displayName = "${deviceName.split('(').first}(this device)";
      thisDevice = true;
    }

    return FamilyDevice(
      deviceName: deviceName ?? "",
      deviceDisplayName: displayName,
      stats: stats ?? UiStats.empty(),
      thisDevice: thisDevice,
    );
  }
}
