import 'package:common/fsm/api/api.dart';
import 'package:common/fsm/filter/filter.dart';
import 'package:common/fsm/machine.dart';
import 'package:common/util/act.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../deck/fixtures.dart';

void main() {
  group("api", () {
    test("basic", () async {
      depend<Query<String, HttpRequest>>((it) async {
        return fixtureListEndpoint;
      }, tag: "api");

      depend<Get<Set<ListHashId>>>(() async {
        return {"1", "2", "3"};
      }, tag: "getLists");

      depend<Get<Act>>(() async {
        return ActScreenplay(
            ActScenario.platformIsMocked, Flavor.og, Platform.ios);
      }, tag: "act");

      depend<Put<Set<ListHashId>>>((it) async {
        //expect(it, {"1", "2", "3"});
      }, tag: "setLists");

      final subject = FilterActor();
      subject.addOnStateChange("ops", (state, context) {
        print("State now: $state, context: ${context.listSelections}");
      });
      await subject.waitForState(FilterState.ready);
      await subject.setDefaultSelection();
      expect(
          subject
              .prepareContextDraft()
              .filterSelections
              .where((it) => it.options.isNotEmpty)
              .length,
          1);
    });
  });
}
