import 'package:common/fsm/api/api.dart';
import 'package:common/fsm/filter/filter.dart';
import 'package:common/fsm/machine.dart';
import 'package:common/tracer/collectors.dart';
import 'package:common/tracer/tracer.dart';
import 'package:common/util/act.dart';
import 'package:common/util/di.dart';
import 'package:common/util/trace.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../deck/fixtures.dart';

void main() {
  group("api", () {
    test("basic", () async {
      final act =
          ActScreenplay(ActScenario.platformIsMocked, Flavor.og, Platform.ios);

      final subject = FilterActor(act);
      subject.injectApi((it) async {
        subject.onApiOk(fixtureListEndpoint);
      });
      subject.injectPutUserLists((it) async {});

      await subject.waitForState("ready");
      // await subject.reload();

      // expect(
      //     subject
      //         .prepareContextDraft()
      //         .filterSelections
      //         .where((it) => it.options.isNotEmpty)
      //         .length,
      //     1);
    });
  });
}
