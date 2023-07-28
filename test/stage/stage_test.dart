import 'dart:async';

import 'package:common/stage/channel.pg.dart';
import 'package:common/stage/stage.dart';
import 'package:common/util/async.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import '../tools.dart';
@GenerateNiceMocks([
  MockSpec<StageOps>(),
])
import 'stage_test.mocks.dart';

void main() {
  group("store", () {
    test("setBackground", () async {
      await withTrace((trace) async {
        final ops = MockStageOps();
        depend<StageOps>(ops);

        final subject = StageStore();
        await subject.setReady(trace);
        expect(subject.route.isForeground(), false);

        await subject.setRoute(trace, "home");
        expect(subject.route.isForeground(), true);

        await subject.setBackground(trace);
        expect(subject.route.isForeground(), false);
      });
    });

    test("setRoute", () async {
      await withTrace((trace) async {
        final ops = MockStageOps();
        depend<StageOps>(ops);

        final subject = StageStore();
        await subject.setReady(trace);

        await subject.setRoute(trace, "activity");
        expect(subject.route.isBecameTab(StageTab.activity), true);

        await subject.setRoute(trace, "settings");
        expect(subject.route.isBecameTab(StageTab.settings), true);

        await subject.setRoute(trace, "settings/test");
        expect(subject.route.isTab(StageTab.settings), true);
        expect(subject.route.route.payload, "test");
      });
    });

    test("showModal", () async {
      await withTrace((trace) async {
        final ops = MockStageOps();
        depend<StageOps>(ops);

        final subject = StageStore();
        expect(subject.modal, null);
        await subject.setReady(trace);
        await subject.setForeground(trace);

        _simulateConfirmation(() async {
          await subject.modalShown(trace, StageModal.plusLocationSelect);
        });

        await subject.showModal(trace, StageModal.plusLocationSelect);
        expect(subject.modal, StageModal.plusLocationSelect);

        _simulateConfirmation(() async {
          await subject.modalDismissed(trace);
        });

        await subject.dismissModal(trace);
        expect(subject.modal, null);
      });
    });

    test("advancedModalManagement", () async {
      await withTrace((trace) async {
        final ops = MockStageOps();
        depend<StageOps>(ops);

        final subject = StageStore();
        expect(subject.modal, null);
        await subject.setReady(trace);
        await subject.setForeground(trace);

        _simulateConfirmation(() async {
          await subject.modalShown(trace, StageModal.help);
        });

        await subject.showModal(trace, StageModal.help);
        expect(subject.modal, StageModal.help);

        // User having one sheet opened and opening another one
        _simulateConfirmation(() async {
          await subject.modalDismissed(trace);
          await sleepAsync(const Duration(milliseconds: 600));
          _simulateConfirmation(() async {
            await subject.modalShown(trace, StageModal.plusLocationSelect);
          });
        });
        await subject.showModal(trace, StageModal.plusLocationSelect);
        expect(subject.modal, StageModal.plusLocationSelect);

        // Same but manual dismiss
        _simulateConfirmation(() async {
          await subject.modalDismissed(trace);
        });
        await subject.dismissModal(trace);
        _simulateConfirmation(() async {
          await subject.modalShown(trace, StageModal.help);
        });
        await subject.showModal(trace, StageModal.help);
        expect(subject.modal, StageModal.help);
      });
    });
  });

  group("stageRouteState", () {
    test("basicTest", () async {
      await withTrace((trace) async {
        // Init state (background)
        dynamic route = StageRouteState.init();

        expect(route.isForeground(), false);
        expect(route.isBecameForeground(), false);
        expect(route.isTab(StageTab.home), false);
        expect(route.isBecameTab(StageTab.home), false);
        expect(route.isMainRoute(), true);

        // Opened home tab (foreground)
        route = route.newTab(StageTab.home);

        expect(route.isForeground(), true);
        expect(route.isBecameForeground(), true);
        expect(route.isTab(StageTab.home), true);
        expect(route.isBecameTab(StageTab.home), true);
        expect(route.isMainRoute(), true);

        // Another tab
        route = route.newTab(StageTab.settings);

        expect(route.isBecameForeground(), false);
        expect(route.isBecameTab(StageTab.settings), true);
        expect(route.isMainRoute(), true);

        // Deep navigation within tab
        route = route.newRoute(StageRoute.fromPath("settings/account"));

        expect(route.isBecameForeground(), false);
        expect(route.isBecameTab(StageTab.settings), false);
        expect(route.isTab(StageTab.settings), true);
        expect(route.isMainRoute(), false);
        expect(route.route.payload, "account");

        // Background
        route = route.newBg();

        expect(route.isForeground(), false);
        expect(route.isBecameForeground(), false);

        // Came back to deep navigation, should report this tab again
        route = route.newRoute(StageRoute.fromPath("settings/account"));

        expect(route.isBecameForeground(), true);
        expect(route.isBecameTab(StageTab.settings), true);
        expect(route.isMainRoute(), false);
      });
    });
  });
}

_simulateConfirmation(Function callback) {
  // Simulate the confirmation coming after a while
  Timer(const Duration(milliseconds: 1), () async {
    await callback();
  });
}
