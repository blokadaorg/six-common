import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:mobx/mobx.dart';

import '../account/account.dart';
import '../app/app.dart';
import '../app/start/start.dart';
import '../device/device.dart';
import '../journal/journal.dart';
import '../lock/lock.dart';
import '../perm/perm.dart';
import '../persistence/persistence.dart';
import '../stage/channel.pg.dart';
import '../stage/stage.dart';
import '../stats/refresh/refresh.dart';
import '../stats/stats.dart';
import '../util/di.dart';
import '../util/mobx.dart';
import '../util/trace.dart';
import 'channel.act.dart';
import 'channel.pg.dart';
import 'json.dart';
import 'model.dart';

part 'family.g.dart';

const String _key = "familyDevice:devices";
const familyLinkBase = "https://go.blokada.org/family/link_device";
const linkTemplate = "$familyLinkBase?tag=TAG&name=NAME";

class FamilyStore = FamilyStoreBase with _$FamilyStore;

abstract class FamilyStoreBase
    with Store, Traceable, TraceOrigin, Dependable, Startable {
  late final _ops = dep<FamilyOps>();
  late final _persistence = dep<PersistenceService>();
  late final _stage = dep<StageStore>();
  late final _account = dep<AccountStore>();
  late final _start = dep<AppStartStore>();
  late final _lock = dep<LockStore>();
  late final _cloudDevice = dep<DeviceStore>();
  late final _journal = dep<JournalStore>();
  late final _device = dep<DeviceStore>();
  late final _app = dep<AppStore>();
  late final _stats = dep<StatsStore>();
  late final _statsRefresh = dep<StatsRefreshStore>();
  late final _perm = dep<PermStore>();

  FamilyStoreBase() {
    _account.addOn(accountChanged, postActivationOnboarding);
    _lock.addOnValue(lockChanged, updatePhaseFromLock);
    _app.addOn(appStatusChanged, addThisDevice);
    _device.addOn(deviceChanged, syncLinkedMode);

    // TODO: this pattern is probably unwanted
    _onJournalChanges();
    _onStatsChanges();
    _onThisDeviceNameChange();
    _onDnsPermChanges();
    _onPhaseShowNavbar();
  }

  @override
  attach(Act act) {
    depend<FamilyOps>(getOps(act));
    depend<FamilyStore>(this as FamilyStore);
  }

  @observable
  FamilyPhase phase = FamilyPhase.starting;

  @observable
  bool? accountActive;

  @observable
  bool appActive = false;

  @observable
  bool appLocked = false;

  @observable
  bool linkedMode = false;

  @observable
  List<FamilyDevice> devices = [];

  @observable
  int devicesChanges = 0;

  @observable
  bool? hasDevices;

  @observable
  bool hasThisDevice = false;

  String? _waitingForDevice;

  _onJournalChanges() {
    reactionOnStore((_) => _journal.allEntries, (entries) async {
      return await traceAs("onJournalChanged", (trace) async {
        await discoverEntries(trace);
      });
    });
  }

  // React to stats updates for devices
  _onStatsChanges() {
    reactionOnStore((_) => _stats.deviceStatsChangesCounter, (_) async {
      for (final entry in _stats.deviceStats.entries) {
        final d =
            IterableExtension(devices.where((e) => e.deviceName == entry.key))
                .firstOrNull;
        if (d == null) continue;

        final updated = devices;
        updated[devices.indexOf(d)] = FamilyDevice(
          deviceName: d.deviceName,
          deviceDisplayName: d.deviceDisplayName,
          stats: entry.value,
          thisDevice: d.thisDevice,
        );
        _updateDevices(updated);
      }
    });
  }

  // React to this device name changes
  _onThisDeviceNameChange() {
    reactionOnStore((_) => _device.deviceAlias, (alias) async {
      final d =
          IterableExtension(devices.where((e) => e.thisDevice)).firstOrNull;
      if (d == null) return;

      final updated = devices;
      updated[devices.indexOf(d)] = FamilyDevice(
        deviceName: d.deviceName,
        deviceDisplayName: d.deviceDisplayName,
        stats: d.stats,
        thisDevice: true,
      );
      _updateDevices(updated);
    });
  }

  // Try activating the app whenever DNS perms are granted
  _onDnsPermChanges() {
    reactionOnStore((_) => _perm.privateDnsEnabledFor, (enabled) async {
      if (linkedMode) {
        return await traceAs("familyLinkedPermCheck", (trace) async {
          appActive = _perm.isPrivateDnsEnabled;
          trace.addAttribute("permEnabled", appActive);
        });
      } else if (accountActive == true) {
        if (_perm.isPrivateDnsEnabled) {
          _updatePhaseNow(true);
          return await traceAs("familyAutoUnpause", (trace) async {
            await _start.unpauseApp(trace);
          });
        }
      }
    });
  }

  _onPhaseShowNavbar() {
    reactionOnStore((_) => phase, (phase) async {
      return await traceAs("onPhaseShowNavbar", (trace) async {
        await _stage.setShowNavbar(trace, !phase.isLocked());
      });
    });
  }

  @override
  @action
  Future<void> start(Trace parentTrace) async {
    if (!act.isFamily()) return;
    return await traceWith(parentTrace, "start", (trace) async {
      await load(trace);
    });
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

      hasThisDevice = devices.firstWhereOrNull((e) => e.thisDevice) != null;

      await _statsRefresh.setMonitoredDevices(
          trace,
          devices
              .filter((e) => e.deviceName.isNotEmpty)
              .map((e) => e.deviceName)
              .toList());

      _updateDnsForward(devices);
    });
  }

  _savePersistence(Trace trace) async {
    await _persistence.save(
        trace, _key, JsonFamilyDevices.fromList(devices).toJson());
  }

  // Links a supervised device to the account
  @action
  Future<void> link(Trace parentTrace, String tag, String name) async {
    if (!act.isFamily()) return;
    return await traceWith(parentTrace, "link", (trace) async {
      if (!phase.isLinkable()) throw Exception("Device not linkable anymore");
      _updatePhase(loading: true);
      await _cloudDevice.setDeviceAlias(trace, name);
      await _cloudDevice.setLinkedTag(trace, tag);
      await _stage.showModal(trace, StageModal.lock);
    });
  }

  @action
  Future<void> unlink(Trace parentTrace) async {
    if (!act.isFamily()) return;
    return await traceWith(parentTrace, "unlink", (trace) async {
      if (phase != FamilyPhase.linkedUnlocked) throw Exception("Cannot unlink");
      _updatePhase(loading: true);
      await _cloudDevice.setLinkedTag(trace, null);
    });
  }

  @action
  Future<void> addDevice(
      Trace parentTrace, String deviceAlias, UiStats stats) async {
    return await traceWith(parentTrace, "addDevice", (trace) async {
      _waitingForDevice = null;
      final d = devices;
      d.add(_newDevice(deviceAlias, stats));
      _updateDevices(d);
      await _savePersistence(trace);
      await _journal.updateJournalFreq(trace); // To refresh immediately
    });
  }

  @action
  Future<void> deleteDevice(Trace parentTrace, String deviceAlias,
      {bool isRename = false}) async {
    return await traceWith(parentTrace, "deleteDevice", (trace) async {
      _waitingForDevice = null;
      final d = devices;
      final device = d.firstWhere((e) => e.deviceName == deviceAlias);
      d.remove(device);

      // Disable cloud for this device, since user deleted it from the list
      if (device.thisDevice) {
        hasThisDevice = false;
        if (!isRename) {
          await _device.setCloudEnabled(parentTrace, false);
          await _lock.removeLock(trace);
        }
      }

      _updateDevices(d);
      await _savePersistence(trace);
      await _statsRefresh.setMonitoredDevices(
          trace, devices.map((e) => e.deviceName).toList());
    });
  }

  @action
  Future<void> deleteAllDevices(Trace parentTrace) async {
    return await traceWith(parentTrace, "deleteAllDevices", (trace) async {
      _waitingForDevice = null;
      _updateDevices([]);
      await _savePersistence(trace);
      await _statsRefresh.setMonitoredDevices(trace, []);
    });
  }

  @action
  Future<void> syncLinkedMode(Trace parentTrace) async {
    return await traceWith(parentTrace, "syncLinkedMode", (trace) async {
      final tag = _cloudDevice.deviceTag;
      if (tag == null) return;
      final link = linkTemplate.replaceAll("TAG", tag);
      await _ops.doFamilyLinkTemplateChanged(link);
      linkedMode = _cloudDevice.tagOverwritten;
      _updatePhase();
      await _maybeShowOnboardOnStart(trace);
    });
  }

  // React to account changes to show the proper onboarding
  @action
  Future<void> postActivationOnboarding(Trace parentTrace) async {
    accountActive = _account.type.isActive();
    _updatePhase();

    if (!act.isFamily()) {
      if (!_account.type.isActive()) return;
      // Old flow for the main flavor, just show the onboarding modal
      // TODO: move elsewhere, it's notfamily
      return await traceWith(parentTrace, "onboardProceed", (trace) async {
        await _stage.showModal(trace, StageModal.perms);
      });
    } else {
      if (_stage.route.modal == StageModal.payment) {
        await traceWith(parentTrace, "dismissModalAfterAccountIdChange",
            (trace) async {
          await _stage.dismissModal(trace);
        });
      }
    }
  }

  @action
  Future<void> updatePhaseFromLock(Trace parentTrace, bool isLocked) async {
    if (!act.isFamily()) return;
    _updatePhase(loading: true);
    appLocked = isLocked;

    if (isLocked) {
      // Locking means that this device is supposed to be active.
      // Pop up the perms modal if perms are not granted.
      if (!_perm.isPrivateDnsEnabled) {
        await _stage.showModal(parentTrace, StageModal.perms);
      }

      // Make sure cloud is enabled for this device
      // This will set appStatus to active and add "this device" to the list
      if (_device.cloudEnabled == false && accountActive == true) {
        await _device.setCloudEnabled(parentTrace, true);
      }
    }
    _updatePhase();
  }

  // The "this device" is special and is added dynamically if current device has
  // the private dns set correctly
  @action
  Future<void> addThisDevice(Trace parentTrace) async {
    appActive = _app.status.isActive() || linkedMode && appActive;
    _updatePhase();

    if (!_app.status.isActive()) return;
    if (devices.where((e) => e.thisDevice).isNotEmpty) return;

    return await traceWith(parentTrace, "addThisDevice", (trace) async {
      final stats = _stats.deviceStats[_device.deviceAlias];
      _updateDevices([_newDevice(_device.deviceAlias, stats)] + devices);
      hasThisDevice = true;
      await _savePersistence(trace);
      await _statsRefresh.setMonitoredDevices(
          trace, devices.map((e) => e.deviceName).toList());
    });
  }

  @action
  Future<void> renameThisDevice(Trace parentTrace, String newDeviceName) async {
    return await traceWith(parentTrace, "renameThisDevice", (trace) async {
      final name = newDeviceName.trim();
      if (name.isEmpty) throw Exception("Name cannot be empty");
      trace.addAttribute("name", name);

      await deleteDevice(trace, _device.deviceAlias, isRename: true);
      await _device.setDeviceAlias(trace, name);
      await addThisDevice(trace);
      await _stage.setRoute(trace, "home"); // Reset to main tab
    });
  }

  @action
  Future<void> setWaitingForDevice(Trace parentTrace, String deviceName) async {
    return await traceWith(parentTrace, "setWaitingForDevice", (trace) async {
      _waitingForDevice = deviceName.trim();
    });
  }

  // Show the welcome screen on the first start (family only)
  _maybeShowOnboardOnStart(Trace parentTrace) async {
    if (_account.type.isActive()) return;
    if (hasDevices == true) return;
    if (linkedMode) return;

    return await traceWith(parentTrace, "showOnboard", (trace) async {
      await _stage.showModal(trace, StageModal.onboardingFamily);
    });
  }

  Future<void> discoverEntries(Trace parentTrace) async {
    return await traceWith(parentTrace, "discoverEntries", (trace) async {
      // Sync stats for already known devices
      final existing = devices.map((e) => e.deviceName);
      final known = _journal.devices
          .filter((e) => e != _device.deviceAlias)
          .filter((e) => existing.contains(e));

      final d = devices;
      for (final device in known) {
        final stats = _stats.deviceStats[device];
        final index =
            devices.indexOf(devices.firstWhere((e) => e.deviceName == device));
        d[index] = _newDevice(device, stats);
      }

      // Discover a new device in stats, if we are expecting one
      final newDeviceName = _waitingForDevice;
      if (newDeviceName != null) {
        final unknown = _journal.devices
            .filter((e) => e != _device.deviceAlias)
            .filter((e) => !existing.contains(e));
        final discovered = unknown.firstWhereOrNull((e) => e == newDeviceName);

        if (discovered != null) {
          final stats =
              _stats.deviceStats[_waitingForDevice] ?? UiStats.empty();
          await addDevice(trace, newDeviceName, stats);

          // We are waiting on the accountLink sheet, close it
          await _stage.dismissModal(trace);
        }
      }

      _updateDevices(d);
      await _statsRefresh.setMonitoredDevices(
          trace, devices.map((e) => e.deviceName).toList());
    });
  }

  FamilyDevice _newDevice(String? deviceName, UiStats? stats) {
    var displayName = deviceName ?? "...";
    var thisDevice = false;

    if (deviceName != null && deviceName == _device.deviceAlias) {
      //displayName = "$deviceName (this device)";
      displayName = "This device ($deviceName)";
      thisDevice = true;
    }

    return FamilyDevice(
      deviceName: deviceName ?? "",
      deviceDisplayName: displayName,
      stats: stats ?? UiStats.empty(),
      thisDevice: thisDevice,
    );
  }

  _updateDevices(List<FamilyDevice> d) {
    devices = d;
    hasDevices = d.isNotEmpty;
    devicesChanges++;
    _updatePhase();
    _updateDnsForward(d);
  }

  _updateDnsForward(List<FamilyDevice> d) {
    // If "this device" is used for blocking, use proper dns
    // Otherwise use forward dns
    final shouldForward = d.firstWhereOrNull((e) => e.thisDevice) == null;
    if (shouldForward == _perm.isForwardDns) return;

    traceAs("updateDnsForward", (trace) async {
      trace.addAttribute("forward", shouldForward);
      await _perm.setForwardDns(trace, shouldForward);
    });
  }

  Timer? timer;

  // To avoid UI jumping on the state changing quickly with timer
  _updatePhase({bool loading = false}) {
    timer?.cancel();
    if (loading) _updatePhaseNow(true);
    timer = Timer(const Duration(seconds: 1), () => _updatePhaseNow(false));
  }

  _updatePhaseNow(bool loading) {
    if (loading) {
      phase = FamilyPhase.starting;
    } else if (accountActive == null) {
      phase = FamilyPhase.starting;
    } else if (linkedMode && appActive && appLocked) {
      phase = FamilyPhase.linkedActive;
    } else if (linkedMode && appActive) {
      phase = FamilyPhase.linkedUnlocked;
    } else if (linkedMode && !appLocked) {
      phase = FamilyPhase.linkedNoPerms;
    } else if (linkedMode && accountActive == false) {
      // Special case, app is setup in linked mode, but account got expired
      // This is parent account, so child device cannot do much about it.
      // Just display as active on child device.
      phase = FamilyPhase.linkedActive;
    } else if (linkedMode) {
      phase = FamilyPhase.linkedNoPerms;
    } else if (appLocked && appActive) {
      phase = FamilyPhase.lockedActive;
    } else if (appLocked && accountActive == false) {
      phase = FamilyPhase.lockedNoAccount;
    } else if (appLocked) {
      phase = FamilyPhase.lockedNoPerms;
    } else if (accountActive == false) {
      phase = FamilyPhase.fresh;
    } else if (!appActive && hasThisDevice) {
      phase = FamilyPhase.noPerms;
    } else if (hasDevices == true) {
      phase = FamilyPhase.parentHasDevices;
    } else if (hasDevices == false) {
      phase = FamilyPhase.parentNoDevices;
    } else {
      phase = FamilyPhase.starting;
    }

    traceAs("updatePhase", (trace) async {
      trace.addAttribute("phase", phase);
    });
  }
}