part of 'filter.dart';

class _FilterContext with FilterContext, Context<_FilterContext> {
  _FilterContext(
    List<JsonListItem> lists,
    Set<ListHashId> listSelections,
    Map<FilterConfigKey, bool> configs,
    List<Filter> filters,
    List<FilterSelection> filterSelections,
    bool defaultsApplied,
    bool listSelectionsSet,
  ) {
    this.lists = lists;
    this.listSelections = listSelections;
    this.configs = configs;
    this.filters = filters;
    this.filterSelections = filterSelections;
    this.defaultsApplied = defaultsApplied;
    this.listSelectionsSet = listSelectionsSet;
  }

  _FilterContext.empty();

  @override
  Context<_FilterContext> copy() => _FilterContext(lists, listSelections,
      configs, filters, filterSelections, defaultsApplied, listSelectionsSet);

  @override
  String toString() =>
      "FilterContext{defaultsApplied: $defaultsApplied, listSelections: $listSelections, configs: $configs, filterSelections: $filterSelections}";
}

class _$FilterStates extends StateMachine<_FilterContext>
    with StateMachineActions<FilterContext>, FilterStates {
  _$FilterStates(Act act)
      : super("init", _FilterContext.empty(), FailBehavior("fatal")) {
    states = {
      init: "init",
      fetchLists: "fetchLists",
      waiting: "waiting",
      parse: "parse",
      reconfigure: "reconfigure",
      defaults: "defaults",
      ready: "ready",
      fatal: "fatal",
    };

    onFail = (state, {saveContext = false}) =>
        failBehavior = FailBehavior(states[state]!, saveContext: saveContext);
    guard = (state) => guardState(states[state]!);
    wait = (state) => waitForState(states[state]!);
    log = (msg) => handleLog(msg);
    this.act = () => act;

    enter("init");
  }

  eventOnApiOk(String result) async {
    event("apiOk", (c) async => await onApiOk(c, result));
  }

  eventOnApiFail(Exception error) async {
    event("apiFail", (c) async => await onApiFail(c));
  }

  eventOnUserLists(UserLists lists) async {
    event("userLists", (c) async => await onUserLists(c, lists));
  }

  Future<FilterContext> eventEnableFilter(
      String filterName, bool enable) async {
    event("enableFilter",
        (c) async => await doEnableFilter(c, filterName, enable));
    await waitForState("ready");
    return getContext();
  }

  Future<FilterContext> eventToggleFilterOption(
      String filterName, String optionName) async {
    event("toggleFilterOption",
        (c) async => await toggleFilterOption(c, filterName, optionName));
    await waitForState("ready");
    return getContext();
  }

  Future<FilterContext> eventReload() async {
    event("reload", (c) async => await doReload(c));
    await waitForState("ready");
    return getContext();
  }
}

class _$FilterActor {
  late final _$FilterStates _machine;

  _$FilterActor(Act act) {
    _machine = _$FilterStates(act);
  }

  injectApi(Action<ApiEndpoint> api) {
    _machine._api = (it) async {
      Future(() {
        // TODO: try catch
        _machine.log("api: $it");
        api(it);
      });
    };
  }

  injectPutUserLists(Action<UserLists> putUserLists) {
    _machine._putUserLists = (it) async {
      Future(() {
        _machine.log("putUserLists: $it");
        putUserLists(it);
      });
    };
  }

  Future<FilterContext> doEnableFilter(String filterName, bool enable) =>
      _machine.eventEnableFilter(filterName, enable);
  Future<FilterContext> doToggleFilterOption(
          String filterName, String optionName) =>
      _machine.eventToggleFilterOption(filterName, optionName);
  Future<FilterContext> doReload() => _machine.eventReload();

  onApiOk(String result) => _machine.eventOnApiOk(result);
  onApiFail(Exception error) => _machine.eventOnApiFail(error);
  onUserLists(UserLists lists) => _machine.eventOnUserLists(lists);

  waitForState(String state) => _machine.waitForState(state);
  addOnState(String state, String tag, Function(State, FilterContext) fn) =>
      _machine.addOnState(state, tag, fn);
}
