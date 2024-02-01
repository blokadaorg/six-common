// part of 'filter.dart';
//
// class _FilterContext with FilterContext, Context<_FilterContext> {
//   _FilterContext(
//     List<JsonListItem> lists,
//     Set<ListHashId> listSelections,
//     Map<FilterConfigKey, bool> configs,
//     List<Filter> filters,
//     List<FilterSelection> filterSelections,
//     bool defaultsApplied,
//   ) {
//     this.lists = lists;
//     this.listSelections = listSelections;
//     this.configs = configs;
//     this.filters = filters;
//     this.filterSelections = filterSelections;
//     this.defaultsApplied = defaultsApplied;
//   }
//
//   _FilterContext.empty();
//
//   @override
//   Context<_FilterContext> copy() => _FilterContext(lists, listSelections,
//       configs, filters, filterSelections, defaultsApplied);
//
//   @override
//   String toString() =>
//       "FilterContext{defaultsApplied: $defaultsApplied, listSelections: $listSelections, configs: $configs, filterSelections: $filterSelections}";
// }
//
// class _$FilterStates with FilterStates {
//   _$FilterStates(
//     Put<String> log,
//     Query<String, ApiEndpoint> api,
//     Get<UserLists> userLists,
//     Put<UserLists> putUserLists,
//     Get<Act> act,
//   ) {
//     _log = log;
//     _api = api;
//     _userLists = userLists;
//     _putUserLists = putUserLists;
//     _act = act;
//   }
// }
//
// class _$FilterActor extends Actor<String, _FilterContext> {
//   late final _trace = dep<TraceFactory>();
//
//   late final _$FilterStates _states;
//
//   _$FilterActor() : super("init", _FilterContext.empty()) {
//     // _states = _$FilterStates(handleLog, api(handleLog), userLists());
//   }
//
//   // enableFilter(String filterName, {bool enable = true}) async {
//   //   guard(FilterState.ready);
//   //
//   //   final c = prepareContextDraft();
//   //   try {
//   //     await _events.enableFilter(c, filterName, enable: enable);
//   //     updateState(FilterState.reconfigure);
//   //     return await waitForState(FilterState.ready);
//   //   } catch (e, s) {
//   //     updateStateFailure(e, s, FilterState.ready);
//   //     rethrow;
//   //   }
//   // }
//   //
//   // toggleFilterOption(String filterName, String optionName) async {
//   //   guard(FilterState.ready);
//   //
//   //   final c = prepareContextDraft();
//   //   try {
//   //     await _events.toggleFilterOption(c, filterName, optionName);
//   //     updateState(FilterState.reconfigure);
//   //     return await waitForState(FilterState.ready);
//   //   } catch (e, s) {
//   //     updateStateFailure(e, s, FilterState.ready);
//   //     rethrow;
//   //   }
//   // }
//   //
//   // reload() async {
//   //   trace = _trace.newTrace(runtimeType.toString(), "reload");
//   //   //guard(FilterState.ready);
//   //
//   //   final c = prepareContextDraft();
//   //   try {
//   //     await _events.reload(c);
//   //     updateState(FilterState.load);
//   //     final ret = await waitForState(FilterState.ready);
//   //     await trace.end();
//   //     return ret;
//   //   } catch (e, s) {
//   //     updateStateFailure(e, s, FilterState.fatal);
//   //     await trace.endWithFailure(e as Exception, s);
//   //     rethrow;
//   //   }
//   // }
//
//   Map<Function(FilterContext), Function()> maps = {};
//   Map<Function(FilterContext), String> names = {};
//
//   doMaps() {
//     maps = {
//       _states.load: _whenLoad,
//       _states.parse: _whenParse,
//       _states.reconfigure: _whenReconfigure,
//       _states.defaults: _whenDefaults,
//     };
//     names = {
//       _states.init: "init",
//       _states.load: "load",
//       _states.parse: "parse",
//       _states.reconfigure: "reconfigure",
//       _states.defaults: "defaults",
//       _states.ready: "ready",
//       _states.fatal: "fatal",
//     };
//   }
//
//   _whenLoad() async {
//     guard(names[_states.load]!);
//     try {
//       final c = prepareContextDraft();
//       final next = await _states.load(c);
//       updateState(names[next]!);
//     } catch (e, s) {
//       // updateStateFailure(e, s, "init");
//     }
//   }
//
//   _whenParse() async {
//     guard("parse");
//     try {
//       final c = prepareContextDraft();
//       await _states.parse(c);
//       updateState("reconfigure");
//     } catch (e, s) {
//       // updateStateFailure(e, s, "fatal");
//     }
//   }
//
//   _whenReconfigure() async {
//     guard("reconfigure");
//     try {
//       final c = prepareContextDraft();
//       await _states.reconfigure(c);
//       updateState("defaults");
//     } catch (e, s) {
//       // updateStateFailure(e, s, "fatal");
//     }
//   }
//
//   _whenDefaults() async {
//     guard("defaults");
//
//     try {
//       final c = prepareContextDraft();
//       final next = await _states.defaults(c);
//       updateState(names[next]!);
//     } catch (e, s) {
//       // updateStateFailure(e, s, "fatal");
//       rethrow;
//     }
//   }
//
//   @override
//   onStateChanged(String newState) {
//     if (newState == "load") {
//       _whenLoad();
//     } else if (newState == "parse") {
//       _whenParse();
//     } else if (newState == "reconfigure") {
//       _whenReconfigure();
//     } else if (newState == "defaults") {
//       _whenDefaults();
//     }
//   }
// }
