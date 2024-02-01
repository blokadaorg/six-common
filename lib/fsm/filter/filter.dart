// import 'dart:convert';
// import 'package:collection/collection.dart';
// import 'package:common/fsm/Providers.dart';
// import 'package:dartx/dartx.dart';
// import 'package:flutter/foundation.dart';
//
// import '../../util/di.dart';
// import '../../util/trace.dart';
// import '../api/api.dart';
// import '../machine.dart';
// import 'json.dart';
// import 'known.dart';
// import 'model.dart';
//
// part 'filter.genn.dart';
//
// /// Filter is the latest model for handling user configurations (blocklists and
// /// other blocking settings). It replaces models Pack, Deck, Shield.
//
// typedef ListTag = String;
// typedef FilterName = String;
// typedef OptionName = String;
// typedef ListHashId = String;
// typedef Enable = bool;
// typedef UserLists = Set<ListHashId>;
//
// mixin FilterContext {
//   List<JsonListItem> lists = [];
//   Set<ListHashId> listSelections = {};
//   Map<FilterConfigKey, bool> configs = {};
//   List<Filter> filters = [];
//   List<FilterSelection> filterSelections = [];
//   bool defaultsApplied = false;
//
//   Pair<FilterName, Enable>? eventEnableFilter;
//   Pair<FilterName, OptionName>? eventToggleOption;
// }
//
// // @Machine
// mixin FilterStates {
//   late Put<String> _log;
//   late Query<String, ApiEndpoint> _api;
//   late Get<UserLists> _userLists;
//   late Put<UserLists> _putUserLists;
//   late Get<Act> _act;
//
//   // @initial
//   init(FilterContext c) async {}
//
//   // @fatal
//   fatal(FilterContext c) async {}
//
//   load(FilterContext c) async {
//     final jsonLists = await _api(ApiEndpoint.getList);
//     c.lists = JsonListEndpoint.fromJson(jsonDecode(jsonLists)).lists;
//     c.listSelections = await _userLists();
//
//     // TODO: configs
//     c.configs = {};
//
//     return parse;
//   }
//
//   loadFail(FilterContext c) => init;
//
//   parse(FilterContext c) async {
//     // 1: read filters that we know about (no selections yet)
//     c.filters = getKnownFilters(await _act());
//     c.filterSelections = [];
//
//     // 2: map user selected lists to internal tags
//     // Tags are "vendor/variant", like "oisd/small"
//     List<ListTag> selection = [];
//     for (final selectedHashId in c.listSelections) {
//       final list = c.lists.firstWhereOrNull((it) => it.id == selectedHashId);
//       if (list == null) {
//         _log("User has unknown list: $selectedHashId");
//         continue;
//       }
//
//       selection += ["${list.vendor}/${list.variant}"];
//     }
//
//     // 3: find which filters are active based on the tags
//     for (final filter in c.filters) {
//       List<OptionName> active = [];
//       for (final option in filter.options) {
//         // For List actions, assume an option is active, if all lists specified
//         // for this option are active
//         if (option.action == Action.list) {
//           if (option.actionParams.every((it) => selection.contains(it))) {
//             active += [option.optionName];
//           }
//         }
//         // TODO: other options
//       }
//
//       c.filterSelections += [FilterSelection(filter.filterName, active)];
//     }
//
//     return reconfigure;
//   }
//
//   parseFail(FilterContext c) => fatal;
//
//   reconfigure(FilterContext c) async {
//     // 1. figure out how to activate each filter
//     Set<ListHashId> lists = {};
//     for (final selection in c.filterSelections) {
//       final filter = c.filters.firstWhere(
//         (it) => it.filterName == selection.filterName,
//       );
//
//       // For each filter option, perform the action depending on its type
//       for (final o in selection.options) {
//         final option = filter.options.firstWhere(
//           (it) => it.optionName == o,
//         );
//
//         // For list action, activate all lists specified by the option
//         if (option.action == Action.list) {
//           // Each tag needs to be mapped to ListHashId
//           for (final listTag in option.actionParams) {
//             final list = c.lists.firstWhereOrNull(
//               (it) => "${it.vendor}/${it.variant}" == listTag,
//             );
//
//             if (list == null) {
//               // c.log("Deprecated list, ignoring: $listTag");
//               continue;
//             }
//
//             lists.add(list.id);
//           }
//         }
//         // TODO: other actions
//       }
//     }
//
//     // 2. perform the necessary activations
//     bool needsReload = false;
//
//     // For now it's only about lists
//     // List can be empty, that's ok
//     if (!setEquals(lists, c.listSelections)) {
//       needsReload = true;
//       await _putUserLists(lists);
//     }
//
//     // TODO: other actions
//
//     if (needsReload) {
//       // Risk of loop if api misbehaves
//       //setState(FilterState.load);
//     }
//
//     return defaults;
//   }
//
//   defaults(FilterContext c) async {
//     // Do nothing if has selections
//     if (c.filterSelections.any((it) => it.options.isNotEmpty)) return ready;
//
//     // Or if already applied during this runtime
//     if (c.defaultsApplied) return ready;
//
//     _log("Applying defaults");
//     c.filterSelections = getDefaultEnabled(await _act());
//     c.defaultsApplied = true;
//     return reconfigure;
//   }
//
//   ready(FilterContext c) async {}
//
//   // @When(FilterState.enableFilter)
//   // @Next(FilterState.reconfigure)
//   // @Fail(FilterState.ready)
//   enableFilter(FilterContext c) async {
//     final filterName = c.eventEnableFilter!.first;
//     final enable = c.eventEnableFilter!.second;
//
//     final filter = c.filters.firstWhere(
//       (it) => it.filterName == filterName,
//     );
//
//     var option = [filter.options.first.optionName];
//     if (!enable) option = [];
//
//     c.filterSelections.removeWhere((it) => it.filterName == filterName);
//     c.filterSelections += [FilterSelection(filterName, option)];
//   }
//
//   // @When(FilterState.toggleOption)
//   // @Next(FilterState.reconfigure)
//   // @Fail(FilterState.ready)
//   toggleFilterOption(FilterContext c) async {
//     final filterName = c.eventToggleOption!.first;
//     final optionName = c.eventToggleOption!.second;
//
//     final filter = c.filters.firstWhere(
//       (it) => it.filterName == filterName,
//     );
//
//     // Will throw if unknown option
//     filter.options.firstWhere((it) => it.optionName == optionName);
//
//     // Get the current option selection for this filter
//     var selection = c.filterSelections.firstWhereOrNull(
//           (it) => it.filterName == filterName,
//         ) ??
//         FilterSelection(filterName, []);
//
//     // Toggle the option
//     if (selection.options.contains(optionName)) {
//       selection.options.remove(optionName);
//     } else {
//       selection.options.add(optionName);
//     }
//
//     // Save the change
//     c.filterSelections.remove(selection);
//     c.filterSelections += [selection];
//   }
// }
//
// // @Events
// mixin FilterEvents {
//   // @Guard([FilterState.init, FilterState.ready])
//   // @Next(FilterState.load)
//   // @Fail(FilterState.fatal)
//   reload(FilterContext c) async {
//     // just reload
//   }
// }
//
// class FilterActor extends _$FilterActor {}
