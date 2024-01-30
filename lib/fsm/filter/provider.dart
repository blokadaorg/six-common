import '../../filter/channel.pg.dart';
import '../../device/device.dart';
import '../../util/di.dart';
import '../../util/trace.dart';
import '../api/api.dart';
import '../api/api.genn.dart';
import '../machine.dart';
import 'filter.dart';
import 'filter.genn.dart';

class FilterActorProvider with Dependable, TraceOrigin {
  @override
  attach(Act act) {
    depend<Get<Act>>(() async {
      return act;
    }, tag: "act");

    depend<Query<String, ApiEndpoint>>((it) async {
      return (await ApiActor().apiRequest(it)).result!;
    }, tag: "api");

    final device = dep<DeviceStore>();

    depend<Get<Set<ListHashId>>>(() async {
      return device.lists?.toSet() ?? {};
    }, tag: "getLists");

    depend<Put<Set<ListHashId>>>((it) async {
      await traceAs("setLists", (trace) async {
        await device.setLists(trace, it.toList());
      });
    }, tag: "setLists");

    FilterOps ops = FilterOps();

    final actor = FilterActor();
    actor.addOnState(FilterState.ready, "ops", (state, context) {
      final filters = context.filters
          .map((it) => Filter(
                filterName: it.filterName,
                options: it.options.map((it) => it.optionName).toList(),
              ))
          .toList();
      ops.doFiltersChanged(filters);

      final selections = context.filterSelections
          .map((it) => Filter(
                filterName: it.filterName,
                options: it.options,
              ))
          .toList();
      ops.doFilterSelectionChanged(selections);
    });

    device.addOn(deviceChanged, (trace) {
      if (actor.isState(FilterState.ready)) {
        actor.reload();
      } else {
        actor.waitForState(FilterState.ready);
        actor.reload();
      }
    });

    depend<FilterActor>(actor);
  }
}
