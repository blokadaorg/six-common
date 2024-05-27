import 'package:common/common/model.dart';
import 'package:common/device/device.dart';
import 'package:common/dragon/account/controller.dart';
import 'package:common/dragon/device/current_config.dart';
import 'package:common/dragon/filter/controller.dart';
import 'package:common/dragon/filter/selected_filters.dart';
import 'package:common/filter/channel.pg.dart' as channel;
import 'package:common/util/di.dart';
import 'package:common/util/trace.dart';

// This is a legacy layer that brings the new Filter concept
// to the existing platform code that used Decks/Packs.

// Initially, the app was hybrid with the business logic in Flutter,
// and UI made separately for each platform in SwiftUI / Kotlin.
// Now, we are moving to UI being made fully in Flutter.

// However, we wanted the new Filters faster since the old concept
// was problematic and buggy. So this class exposes it to for old code.
class FilterLegacy with Traceable {
  late final _controller = dep<FilterController>();
  late final _device = dep<DeviceStore>();
  late final _userConfig = dep<CurrentConfig>();
  late final _selectedFilters = dep<SelectedFilters>();
  late final _knownFilters = dep<KnownFilters>();
  late final _ops = dep<channel.FilterOps>();
  late final _acc = dep<AccountController>();

  FilterLegacy() {
    _device.addOn(deviceChanged, onDeviceChanged);
    _selectedFilters.onChange.listen((it) => onSelectedFiltersChanged(it));
    // todo: handling commands
    // todo: default value at first start of new account
  }

  Future<void> onDeviceChanged(Trace parentTrace) async {
    return await traceWith(parentTrace, "onDeviceChangedLegacy", (trace) async {
      final lists = _device.lists;
      if (lists != null) {
        _acc.start();
        // Read user config from device v2 when it is ready
        // Set it and it will reload FilterController
        // That one will update SelectedFilters
        _userConfig.now = UserFilterConfig(lists.toSet(), {});
      }
    });
  }

  // Push it to pigeon, together with KnownFilters converted and the tags
  onSelectedFiltersChanged(List<FilterSelection> selected) {
    print("updating filters legacy, selected: ${selected.length}");

    _ops.doFiltersChanged(_knownFilters.get().map((it) {
      return channel.Filter(
        filterName: it.filterName,
        options: it.options.map((e) => e.optionName).toList(),
      );
    }).toList());

    _ops.doFilterSelectionChanged(selected.map((it) {
      return channel.Filter(
        filterName: it.filterName,
        options: it.options,
      );
    }).toList());

    _ops.doListToTagChanged(_controller.getListsToTags().map((key, value) {
      return MapEntry(key, value);
    }));
  }
}
