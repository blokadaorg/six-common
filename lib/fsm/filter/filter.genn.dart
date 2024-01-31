part of 'filter.dart';

class _FilterContext with FilterContext, Context<_FilterContext> {
  _FilterContext(
    List<JsonListItem> lists,
    Set<ListHashId> listSelections,
    Map<FilterConfigKey, bool> configs,
    List<Filter> filters,
    List<FilterSelection> filterSelections,
    bool defaultsApplied,
  ) {
    this.lists = lists;
    this.listSelections = listSelections;
    this.configs = configs;
    this.filters = filters;
    this.filterSelections = filterSelections;
    this.defaultsApplied = defaultsApplied;
  }

  _FilterContext.empty();

  @override
  Context<_FilterContext> copy() => _FilterContext(lists, listSelections,
      configs, filters, filterSelections, defaultsApplied);

  @override
  String toString() =>
      "FilterContext{defaultsApplied: $defaultsApplied, listSelections: $listSelections, configs: $configs, filterSelections: $filterSelections}";
}

class _$FilterStates with Logging, FilterStates {
  final Function(String) handleLog;
  _$FilterStates(this.handleLog);

  @override
  log(String msg) => handleLog(msg);
}

class _$FilterEvents with FilterEvents {}

class _$FilterActor extends Actor<FilterState, _FilterContext> {
  late final _trace = dep<TraceFactory>();

  late final _$FilterStates _states;
  final _events = _$FilterEvents();

  _$FilterActor() : super(FilterState.init, _FilterContext.empty()) {
    _states = _$FilterStates(handleLog);
  }

  enableFilter(String filterName, {bool enable = true}) async {
    guard(FilterState.ready);

    final c = prepareContextDraft();
    try {
      await _events.enableFilter(c, filterName, enable: enable);
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
      await _events.toggleFilterOption(c, filterName, optionName);
      updateState(FilterState.reconfigure);
      return await waitForState(FilterState.ready);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.ready);
      rethrow;
    }
  }

  reload() async {
    trace = _trace.newTrace(runtimeType.toString(), "reload");
    //guard(FilterState.ready);

    final c = prepareContextDraft();
    try {
      await _events.reload(c);
      updateState(FilterState.load);
      final ret = await waitForState(FilterState.ready);
      await trace.end();
      return ret;
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.fatal);
      await trace.endWithFailure(e as Exception, s);
      rethrow;
    }
  }

  _whenLoad() async {
    guard(FilterState.load);

    final api = dep<Query<String, ApiEndpoint>>(instanceName: "api");
    final userLists = dep<Get<Set<ListHashId>>>(instanceName: "getLists");

    final c = prepareContextDraft();
    try {
      await _states.load(c, api, userLists);
      updateState(FilterState.parse);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.init);
    }
  }

  _whenParse() async {
    guard(FilterState.parse);

    final act = dep<Get<Act>>(instanceName: "act");

    final c = prepareContextDraft();
    try {
      await _states.parse(c, act);
      updateState(FilterState.reconfigure);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.fatal);
    }
  }

  _whenReconfigure() async {
    guard(FilterState.reconfigure);

    final setLists =
        dep<Query<void, Set<ListHashId>>>(instanceName: "setLists");

    final c = prepareContextDraft();
    try {
      await _states.reconfigure(c, setLists);
      updateState(FilterState.defaults);
    } catch (e, s) {
      updateStateFailure(e, s, FilterState.fatal);
    }
  }

  _whenDefaults() async {
    guard(FilterState.defaults);

    final act = dep<Get<Act>>(instanceName: "act");

    final c = prepareContextDraft();
    try {
      final result = await _states.defaults(c, act);
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
      _whenLoad();
    } else if (newState == FilterState.parse) {
      _whenParse();
    } else if (newState == FilterState.reconfigure) {
      _whenReconfigure();
    } else if (newState == FilterState.defaults) {
      _whenDefaults();
    }
  }
}
