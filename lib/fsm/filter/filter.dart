import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../util/di.dart';
import '../api/api.dart';
import '../machine.dart';
import 'json.dart';
import 'known.dart';
import 'model.dart';

/// Filter is the latest model for handling user configurations (blocklists and
/// other blocking settings). It replaces models Pack, Deck, Shield.

enum FilterState { init, load, parse, ready, reconfigure, fatal }

typedef ListHashId = String;
typedef ListTag = String;
typedef OptionName = String;

mixin FilterContext {
  List<JsonListItem> lists = [];
  Set<ListHashId> listSelections = {};
  Map<FilterConfigKey, bool> configs = {};
  List<Filter> filters = [];
  List<FilterSelection> filterSelections = [];
}

// @Machine(initial: FilterState.init)
mixin FilterStateMachine {
  // @OnEnter(state: FilterState.load)
  // @OnSuccess(newState: FilterState.parse)
  // @OnFailure(newState: FilterState.init)
  // @Dependency(name: "api", tag: "Api")
  // @Dependency(name: "userLists", tag: "getLists")
  stateLoad(
    FilterContext c,
    Query<String, ApiEndpoint> api,
    Get<Set<ListHashId>> userLists,
  ) async {
    final jsonLists = await api(ApiEndpoint.getList);
    c.lists = JsonListEndpoint.fromJson(jsonDecode(jsonLists)).lists;
    c.listSelections = await userLists();

    // TODO: configs
    c.configs = {};
  }

  // @OnEnter(state: FilterState.parse)
  // @OnSuccess(newState: FilterState.reconfigure)
  // @OnFailure(newState: FilterState.fatal)
  // @Dependency(name: "act", tag: "act")
  stateParse(FilterContext c, Get<Act> act) async {
    // 1: read filters that we know about (no selections yet)
    c.filters = getKnownFilters(await act());
    c.filterSelections = [];

    // 2: map user selected lists to internal tags
    // Tags are "vendor/variant", like "oisd/small"
    List<ListTag> selection = [];
    for (final selectedHashId in c.listSelections) {
      final list = c.lists.firstWhereOrNull((it) => it.id == selectedHashId);
      if (list == null) {
        // c.log("User has unknown list: $selectedHashId");
        continue;
      }

      selection += ["${list.vendor}/${list.variant}"];
    }

    // 3: find which filters are active based on the tags
    for (final filter in c.filters) {
      List<OptionName> active = [];
      for (final option in filter.options) {
        // For List actions, assume an option is active, if all lists specified
        // for this option are active
        if (option.action == Action.list) {
          if (option.actionParams.every((it) => selection.contains(it))) {
            active += [option.optionName];
          }
        }
        // TODO: other options
      }

      c.filterSelections += [FilterSelection(filter.filterName, active)];
    }
  }

  // @OnEnter(state: FilterState.reconfigure)
  // @OnSuccess(newState: FilterState.ready)
  // @OnFailure(newState: FilterState.fatal)
  // @Dependency(name: "setLists", tag: "Device")
  stateReconfigure(
    FilterContext c,
    Put<Set<ListHashId>> setLists,
  ) async {
    // 1. figure out how to activate each filter
    Set<ListHashId> lists = {};
    for (final selection in c.filterSelections) {
      final filter = c.filters.firstWhere(
        (it) => it.filterName == selection.filterName,
      );

      // For each filter option, perform the action depending on its type
      for (final o in selection.options) {
        final option = filter.options.firstWhere(
          (it) => it.optionName == o,
        );

        // For list action, activate all lists specified by the option
        if (option.action == Action.list) {
          // Each tag needs to be mapped to ListHashId
          for (final listTag in option.actionParams) {
            final list = c.lists.firstWhereOrNull(
              (it) => "${it.vendor}/${it.variant}" == listTag,
            );

            if (list == null) {
              // c.log("Deprecated list, ignoring: $listTag");
              continue;
            }

            lists.add(list.id);
          }
        }
        // TODO: other actions
      }
    }

    // 2. perform the necessary activations
    bool needsReload = false;

    // For now it's only about lists
    // List can be empty, that's ok
    if (!setEquals(lists, c.listSelections)) {
      needsReload = true;
      await setLists(lists);
    }

    // TODO: other actions

    if (needsReload) {
      // Risk of loop if api misbehaves
      //setState(FilterState.load);
    }
  }

  // @From(state: FilterState.ready)
  // @OnSuccess(newState: FilterState.reconfigure)
  // @OnFailure(newState: FilterState.fatal)
  // @Dependency(name: "act", tag: "act")
  eventSetDefaultSelection(FilterContext c, Get<Act> act) async {
    c.filterSelections = getDefaultEnabled(await act());
  }

  // @From(state: FilterState.ready)
  // @OnSuccess(newState: FilterState.reconfigure)
  // @OnFailure(newState: FilterState.ready)
  eventEnableFilter(FilterContext c, String filterName,
      {bool enable = true}) async {
    final filter = c.filters.firstWhere(
      (it) => it.filterName == filterName,
    );

    var option = [filter.options.first.optionName];
    if (!enable) option = [];

    c.filterSelections.removeWhere((it) => it.filterName == filterName);
    c.filterSelections += [FilterSelection(filterName, option)];
  }

  // @From(state: FilterState.ready)
  // @OnSuccess(newState: FilterState.reconfigure)
  // @OnFailure(newState: FilterState.ready)
  eventToggleFilterOption(
      FilterContext c, String filterName, String optionName) async {
    final filter = c.filters.firstWhere(
      (it) => it.filterName == filterName,
    );

    // Will throw if unknown option
    filter.options.firstWhere((it) => it.optionName == optionName);

    // Get the current option selection for this filter
    var selection = c.filterSelections.firstWhereOrNull(
          (it) => it.filterName == filterName,
        ) ??
        FilterSelection(filterName, []);

    // Toggle the option
    if (selection.options.contains(optionName)) {
      selection.options.remove(optionName);
    } else {
      selection.options.add(optionName);
    }

    // Save the change
    c.filterSelections.remove(selection);
    c.filterSelections += [selection];
  }

  // @From(state: FilterState.ready) // or init
  // @OnSuccess(newState: FilterState.load)
  // @OnFailure(newState: FilterState.fatal)
  eventReload(FilterContext c) async {
    // just reload
  }
}
