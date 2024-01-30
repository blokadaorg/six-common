part of 'filter.dart';

class _FilterContext with FilterContext, Context<_FilterContext> {
  _FilterContext(
    List<JsonListItem> lists,
    Set<ListHashId> listSelections,
    Map<FilterConfigKey, bool> configs,
    List<Filter> filters,
    List<FilterSelection> filterSelections,
  ) {
    this.lists = lists;
    this.listSelections = listSelections;
    this.configs = configs;
    this.filters = filters;
    this.filterSelections = filterSelections;
  }

  _FilterContext.empty();

  @override
  Context<_FilterContext> copy() =>
      _FilterContext(lists, listSelections, configs, filters, filterSelections);

  @override
  String toString() =>
      "FilterContext{listSelections: $listSelections, configs: $configs, filterSelections: $filterSelections}";
}

class FilterActor extends Actor<FilterState, _FilterContext>
    with FilterStateMachine {
  FilterActor() : super(FilterState.init, _FilterContext.empty());

  enableFilter(String filterName, {bool enable = true}) async {
    guard(FilterState.ready);

    final c = prepareContextDraft();
    try {
      await super.eventEnableFilter(c, filterName, enable: enable);
      updateState(FilterState.reconfigure);
      return await waitForState(FilterState.ready);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.ready);
      rethrow;
    }
  }

  toggleFilterOption(String filterName, String optionName) async {
    guard(FilterState.ready);

    final c = prepareContextDraft();
    try {
      await super.eventToggleFilterOption(c, filterName, optionName);
      updateState(FilterState.reconfigure);
      return await waitForState(FilterState.ready);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.ready);
      rethrow;
    }
  }

  reload() async {
    //guard(FilterState.ready);

    final c = prepareContextDraft();
    try {
      await super.eventReload(c);
      updateState(FilterState.load);
      return await waitForState(FilterState.ready);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.fatal);
      rethrow;
    }
  }

  _stateLoad() async {
    guard(FilterState.load);

    final api = dep<Query<String, ApiEndpoint>>(instanceName: "api");
    final userLists = dep<Get<Set<ListHashId>>>(instanceName: "getLists");

    final c = prepareContextDraft();
    try {
      await super.stateLoad(c, api, userLists);
      updateState(FilterState.parse);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.init);
    }
  }

  _stateParse() async {
    guard(FilterState.parse);

    final act = dep<Get<Act>>(instanceName: "act");

    final c = prepareContextDraft();
    try {
      await super.stateParse(c, act);
      updateState(FilterState.reconfigure);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.fatal);
    }
  }

  _stateReconfigure() async {
    guard(FilterState.reconfigure);

    final setLists =
        dep<Query<void, Set<ListHashId>>>(instanceName: "setLists");

    final c = prepareContextDraft();
    try {
      await super.stateReconfigure(c, setLists);
      updateState(FilterState.defaults);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.fatal);
    }
  }

  _stateDefaults() async {
    guard(FilterState.defaults);

    final act = dep<Get<Act>>(instanceName: "act");

    final c = prepareContextDraft();
    try {
      final result = await super.whenDefaults(c, act);
      if (result is FilterState) {
        updateState(result);
      } else {
        updateState(FilterState.ready);
      }
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.fatal);
      rethrow;
    }
  }

  @override
  onStateChanged(FilterState newState) {
    if (newState == FilterState.load) {
      _stateLoad();
    } else if (newState == FilterState.parse) {
      _stateParse();
    } else if (newState == FilterState.reconfigure) {
      _stateReconfigure();
    } else if (newState == FilterState.defaults) {
      _stateDefaults();
    }
  }
}
