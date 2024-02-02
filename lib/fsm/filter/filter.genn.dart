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
  late final Map<Function(FilterContext), String> stateFromMethod;
  late final Map<String, Function()> enterState;

  _$FilterStates(Act act)
      : super("init", _FilterContext.empty(), FailBehavior("fatal")) {
    stateFromMethod = {
      init: "init",
      fetchLists: "fetchLists",
      waiting: "waiting",
      parse: "parse",
      reconfigure: "reconfigure",
      defaults: "defaults",
      ready: "ready",
      fatal: "fatal",
    };
    enterState = {
      "init": enterInit,
      "fetchLists": enterFetchLists,
      "waiting": enterWaiting,
      "parse": enterParse,
      "reconfigure": enterReconfigure,
      "defaults": enterDefaults,
      "ready": enterReady,
      "fatal": enterFatal,
    };

    onFail = (state, {saveContext = false}) => failBehavior =
        FailBehavior(stateFromMethod[state]!, saveContext: saveContext);
    guard = (state) => guardState(stateFromMethod[state]!);
    wait = (state) => waitForState(stateFromMethod[state]!);
    log = (msg) => handleLog(msg);
    this.act = () => act;

    enter("init");
  }

  @override
  onStateChanged(String newState) async {
    final next = await enterState[newState]!();
    final known = stateFromMethod[next];
    if (known != null) await enter(known);
  }

  enterInit() async {
    try {
      final c = startEntering("init");
      final next = await super.init(c);
      doneEntering("init");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterFetchLists() async {
    try {
      final c = startEntering("fetchLists");
      final next = await super.fetchLists(c);
      doneEntering("fetchLists");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterWaiting() async {
    try {
      final c = startEntering("waiting");
      final next = await super.waiting(c);
      doneEntering("waiting");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterParse() async {
    try {
      final c = startEntering("parse");
      final next = await super.parse(c);
      doneEntering("parse");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterReconfigure() async {
    try {
      final c = startEntering("reconfigure");
      final next = await super.reconfigure(c);
      doneEntering("reconfigure");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterDefaults() async {
    try {
      final c = startEntering("defaults");
      final next = await super.defaults(c);
      doneEntering("defaults");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterReady() async {
    try {
      final c = startEntering("ready");
      final next = await super.ready(c);
      doneEntering("ready");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  enterFatal() async {
    try {
      final c = startEntering("fatal");
      final next = await super.fatal(c);
      doneEntering("fatal");
      return next;
    } catch (e, s) {
      failEntering(e, s);
    }
  }

  eventOnApiOk(String result) async {
    try {
      final c = await startEvent("onApiOk");
      final next = await super.onApiOk(c, result);
      doneEvent("onApiOk");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
      return next;
    } catch (e, s) {
      failEvent(e, s);
    }
  }

  eventOnApiFail(Exception error) async {
    try {
      final c = await startEvent("onApiFail");
      final next = await super.onApiFail(c);
      doneEvent("onApiFail");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
    } catch (e, s) {
      failEvent(e, s);
    }
  }

  eventOnUserLists(UserLists lists) async {
    try {
      final c = await startEvent("onUserLists");
      final next = await super.onUserLists(c, lists);
      doneEvent("onUserLists");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
    } catch (e, s) {
      failEvent(e, s);
    }
  }

  Future<FilterContext> eventEnableFilter(
      String filterName, bool enable) async {
    try {
      final c = await startEvent("enableFilter");
      final next = await super.doEnableFilter(c, filterName, enable);
      doneEvent("enableFilter");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
      await waitForState("ready");
      return getContext();
    } catch (e, s) {
      failEvent(e, s);
      return getContext();
    }
  }

  Future<FilterContext> eventToggleFilterOption(
      String filterName, String optionName) async {
    try {
      final c = await startEvent("toggleFilterOption");
      final next = await super.toggleFilterOption(c, filterName, optionName);
      doneEvent("toggleFilterOption");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
      await waitForState("ready");
      return getContext();
    } catch (e, s) {
      failEvent(e, s);
      return getContext();
    }
  }

  Future<FilterContext> eventReload() async {
    try {
      final c = await startEvent("reload");
      final next = await super.doReload(c);
      doneEvent("reload");
      final known = stateFromMethod[next];
      if (known != null) await enter(known);
      await waitForState("ready");
      return getContext();
    } catch (e, s) {
      failEvent(e, s);
      return getContext();
    }
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
        _machine.log("api");
        api(it);
      });
    };
  }

  injectPutUserLists(Action<UserLists> putUserLists) {
    _machine._putUserLists = (it) async {
      Future(() {
        _machine.log("putUserLists");
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
