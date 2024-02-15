import 'package:common/via/util.dart';
import 'package:vistraced/via.dart';

import '../../common/model.dart';
import '../../fsm/device/device.dart';
import '../../fsm/device/json.dart';
import '../../fsm/profile/json.dart';
import '../actions.dart';

part 'device.g.dart';

@ViaInjected()
class DeviceMachine {
  final _devices = Via.list<JsonDevice>(doApi);
  final _profiles = Via.list<JsonProfile>(doApi);
  final _thisDevice = Via.as<JsonDevice?>(doPersistence);
  final _nextAlias = Via.as<DeviceAlias>(doGenerator);
  final _userConfig = Via.as<UserFilterConfig?>(doDirect);

  JsonDevice? _selectedDevice;
  JsonProfile? _selectedProfile;

  DeviceMachine() {
    _userConfig.onSet(_updateProfileConfig);
  }

  reload() async {
    final devices = await _devices.get();
    final d = await _thisDevice.get();

    final tag = d?.deviceTag;
    final alias = d?.alias ?? await _nextAlias.get();
    final existing = devices.find((it) => it.deviceTag == tag);

    // A new device needs to be created
    if (tag == null || existing == null) {
      // Create a new profile for this device
      final p = await _profiles.add(JsonProfile.create(
        alias: alias,
      ));

      // Create a new device with that profile
      final newDevice = await _devices.add(JsonDevice.create(
        alias: alias,
        profileId: p.profileId,
      ));

      await _thisDevice.set(newDevice);
      // reload?
    }
  }

  selectDevice(DeviceTag tag) async {
    final devices = await _devices.get();
    final profiles = await _profiles.get();

    _selectedDevice = devices.find((it) => it.deviceTag == tag);
    if (_selectedDevice == null) throw Exception("Device $tag not found");

    final pId = _selectedProfile?.profileId;
    final p = profiles.find((it) => it.profileId == pId);
    if (p == null) throw Exception("Profile $pId not found");
    _selectedProfile = p;

    final userConfig = UserFilterConfig(p.lists.toSet(), {
      FilterConfigKey.safeSearch: p.safeSearch,
    });
    await _userConfig.set(userConfig);
  }

  _updateProfileConfig() async {
    final userConfig = await _userConfig.get();
    if (userConfig == null) throw Exception("No user config");

    final p = _selectedProfile;
    if (p == null) throw Exception("No profile selected");

    final newProfile = p.copy(
      lists: userConfig.lists.toList(),
      safeSearch: userConfig.configs[FilterConfigKey.safeSearch] ?? false,
    );

    //await _profiles.update(newProfile);
  }
}
