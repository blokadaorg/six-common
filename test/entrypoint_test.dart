import 'package:flutter_test/flutter_test.dart';

void main() {
  group("binder", () {
    //   test("onNavPathChanged", () async {
    //     await withTrace((m) async {
    //       final store = MockStageStore();
    //       DI.register<StageStore>(store);
    //
    //       final subject = Entrypoint.forTesting();
    //
    //       await subject.onNavPathChanged("activity");
    //       verify(store.setActiveTab(any, StageTab.activity)).called(1);
    //
    //       await subject.onNavPathChanged("Settings/restore");
    //       verify(store.setActiveTab(any, StageTab.settings)).called(1);
    //       verify(store.setTabPayload(any, "restore")).called(1);
    //     });
    //   });
    //
    //   test("onForeground", () async {
    //     await withTrace((m) async {
    //       final store = MockStageStore();
    //       DI.register<StageStore>(store);
    //
    //       final subject = Entrypoint.forTesting();
    //
    //       await subject.onForeground(true);
    //       verify(store.setForeground(any, true)).called(1);
    //
    //       await subject.onForeground(false);
    //       verify(store.setForeground(any, false)).called(1);
    //     });
    //   });
    //
    //   test("onModalDismissed", () async {
    //     await withTrace((m) async {
    //       final store = MockStageStore();
    //       DI.register<StageStore>(store);
    //
    //       final subject = Entrypoint.forTesting();
    //
    //       await subject.onModalDismissedByUser();
    //       verify(store.dismissModal(any)).called(1);
    //     });
    //   });
    //
    //   test("onModal", () async {
    //     await withTrace((m) async {
    //       final store = StageStore();
    //       DI.register<StageStore>(store);
    //
    //       final ops = MockStageOps();
    //       DI.register<StageOps>(ops);
    //
    //       final subject = StageBinder();
    //
    //       verify(ops.doShowModal("none")).called(1);
    //
    //       store.showModal(StageModal.accountInitFailed);
    //       verify(ops.doShowModal("accountInitFailed")).called(1);
    //     });
    //   });
  });
}

// app pause
// group("binder", () {
// test("onStartApp", () async {
//   await withTrace((m) async {
//     DI.register<TimerService>(MockTimerService());
//
//     final app = MockAppStore();
//     DI.register<AppStore>(app);
//
//     final accountRefreshStore = MockAccountRefreshStore();
//     DI.register<AccountRefreshStore>(accountRefreshStore);
//
//     final stage = StageStore();
//     DI.register<StageStore>(stage);
//
//     final store = MockAppPauseStore();
//     DI.register<AppPauseStore>(store);
//
//     final subject = AppPauseBinder.forTesting();
//
//     verifyNever(app.initStarted(any));
//
//     await subject.onStartApp();
//     verify(app.initStarted(any)).called(1);
//     verify(app.initCompleted(any)).called(1);
//   });
// });

// test("onRetryInit", () async {
//   await withTrace((m) async {
//     DI.register<StageStore>(StageStore());
//     DI.register<TimerService>(MockTimerService());
//
//     final app = MockAppStore();
//     DI.register<AppStore>(app);
//
//     final store = MockAppPauseStore();
//     DI.register<AppPauseStore>(store);
//
//     final ops = MockAppPauseOps();
//     DI.register<AppPauseOps>(ops);
//
//     final refresh = MockAccountRefreshStore();
//     int callCounter = 0;
//     when(refresh.init(any)).thenAnswer((_) async {
//       if (callCounter++ < 2) {
//         throw Exception("Failed to init");
//       }
//     });
//     DI.register<AccountRefreshStore>(refresh);
//
//     // Initial state
//     final subject = AppPauseBinder.forTesting();
//
//     // Do init (should retry on failing init)
//     await subject.onRetryInit();
//     verify(refresh.init(any)).called(3);
//   });
// });

// test("onPauseApp", () async {
//   await withTrace((m) async {
//     DI.register<TimerService>(MockTimerService());
//
//     final store = MockAppPauseStore();
//     DI.register<AppPauseStore>(store);
//
//     final ops = MockAppPauseOps();
//     DI.register<AppPauseOps>(ops);
//
//     DI.register<AppStore>(MockAppStore());
//
//     final subject = AppPauseBinder.forTesting();
//
//     await subject.onPauseApp(true);
//
//     verify(store.pauseAppIndefinitely(any)).called(1);
//
//     await subject.onPauseApp(false);
//
//     verify(store.pauseAppUntil(any, any)).called(1);
//   });
// });
//
// test("onUnpauseApp", () async {
//   await withTrace((m) async {
//     DI.register<TimerService>(MockTimerService());
//
//     final store = MockAppPauseStore();
//     DI.register<AppPauseStore>(store);
//
//     final ops = MockAppPauseOps();
//     DI.register<AppPauseOps>(ops);
//
//     DI.register<AppStore>(MockAppStore());
//
//     final subject = AppPauseBinder.forTesting();
//
//     await subject.onUnpauseApp();
//
//     verify(store.unpauseApp(any)).called(1);
//   });
// });
//
// test("onTimerFired", () async {
//   await withTrace((m) async {
//     final timer = TestingTimer();
//     DI.register<TimerService>(timer);
//
//     final store = MockAppPauseStore();
//     DI.register<AppPauseStore>(store);
//
//     DI.register<AppStore>(MockAppStore());
//
//     final ops = MockAppPauseOps();
//     DI.register<AppPauseOps>(ops);
//
//     final subject = AppPauseBinder.forTesting();
//
//     await timer.trigger("app:pause");
//
//     verify(store.unpauseApp(any)).called(1);
//   });
// });
//
// test("onPausedUntilChange", () async {
//   await withTrace((m) async {
//     DI.register<TimerService>(MockTimerService());
//     DI.register<AppStore>(MockAppStore());
//     DI.register<DeviceStore>(MockDeviceStore());
//     DI.register<PermStore>(MockPermStore());
//
//     final store = AppPauseStore();
//     DI.register<AppPauseStore>(store);
//
//     final ops = MockAppPauseOps();
//     DI.register<AppPauseOps>(ops);
//
//     final subject = AppPauseBinder.forTesting();
//
//     await store.pauseAppUntil(const Duration(seconds: 5));
//
//     verify(ops.doAppPauseDurationChanged(any)).called(1);
//   });

// });
// })

// journal test

// group("binder", () {
//   test("onSearch", () async {
//     await withTrace((m) async {
//       final store = MockJournalStore();
//       DI.register<JournalStore>(store);
//
//       final subject = JournalBinder.forTesting();
//
//       verifyNever(store.updateFilter);
//       await subject.onSearch("foo");
//       verify(store.updateFilter(
//         any,
//         searchQuery: "foo",
//       )).called(1);
//     });
//   });
//
//   test("onShowForDevice", () async {
//     await withTrace((m) async {
//       final store = MockJournalStore();
//       DI.register<JournalStore>(store);
//
//       final subject = JournalBinder.forTesting();
//
//       verifyNever(store.updateFilter);
//       await subject.onShowForDevice("deviceName");
//       verify(store.updateFilter(
//         any,
//         deviceName: "deviceName",
//       )).called(1);
//     });
//   });
//
//   test("onShowOnly", () async {
//     await withTrace((m) async {
//       final store = MockJournalStore();
//       DI.register<JournalStore>(store);
//
//       final subject = JournalBinder.forTesting();
//
//       verifyNever(store.updateFilter);
//
//       await subject.onShowOnly(true, false); // blocked, passed
//       verify(store.updateFilter(
//         any,
//         showOnly: JournalFilterType.showBlocked,
//       )).called(1);
//
//       await subject.onShowOnly(false, true); // blocked, passed
//       verify(store.updateFilter(
//         any,
//         showOnly: JournalFilterType.showPassed,
//       )).called(1);
//
//       await subject.onShowOnly(true, true); // blocked, passed
//       verify(store.updateFilter(
//         any,
//         showOnly: JournalFilterType.showAll,
//       )).called(1);
//
//       await subject.onShowOnly(false, false); // blocked, passed
//       verify(store.updateFilter(
//         any,
//         showOnly: JournalFilterType.showPassed,
//       )).called(1);
//     });
//   });
//
//   test("onJournalChanged", () async {
//     await withTrace((m) async {
//       final env = EnvStore();
//       env.setDeviceTag("deviceName");
//       DI.register<EnvStore>(env);
//
//       final json = MockJournalJson();
//       when(json.getEntries(any))
//           .thenAnswer((_) => Future.value(fixtureJournalEntries));
//       DI.register<JournalJson>(json);
//
//       final store = JournalStore();
//       DI.register<JournalStore>(store);
//
//       final ops = MockJournalOps();
//       DI.register<JournalOps>(ops);
//
//       final subject = JournalBinder.forTesting();
//
//       // Should notify entries changed after fetching
//       verifyNever(ops.doReplaceEntries(any));
//       await store.fetch;
//       verify(ops.doReplaceEntries(any)).called(1);
//
//       // Should notify entries changed after filter change
//       await store.updateFilter(sortNewestFirst: false);
//       verify(ops.doReplaceEntries(any)).called(1);
//
//       await store.updateFilter(sortNewestFirst: true);
//       verify(ops.doReplaceEntries(any)).called(1);
//
//       await store.updateFilter(searchQuery: "foo");
//       verify(ops.doReplaceEntries(any)).called(1);
//     });
//   });
//
//   test("onFilterChanged", () async {
//     await withTrace((m) async {
//       final env = EnvStore();
//       env.setDeviceTag("deviceName");
//       DI.register<EnvStore>(env);
//
//       final json = MockJournalJson();
//       when(json.getEntries(any))
//           .thenAnswer((_) => Future.value(fixtureJournalEntries));
//       DI.register<JournalJson>(json);
//
//       final ops = MockJournalOps();
//       DI.register<JournalOps>(ops);
//
//       final store = JournalStore();
//       DI.register<JournalStore>(store);
//
//       final subject = JournalBinder.forTesting();
//       verifyNever(ops.doFilterChanged(any));
//
//       await store.fetch;
//       verifyNever(ops.doFilterChanged(any));
//
//       await store.updateFilter(searchQuery: "foo");
//       verify(ops.doFilterChanged(any)).called(1);
//
//       // Setting up exactly same filter should not trigger the callback
//       await store.updateFilter(searchQuery: "foo");
//       verifyNever(ops.doFilterChanged(any));
//
//       await store.updateFilter(trace,
//           searchQuery: null, sortNewestFirst: false);
//       verify(ops.doFilterChanged(any)).called(1);
//
//       await store.updateFilter(sortNewestFirst: false);
//       verifyNever(ops.doFilterChanged(any));
//
//       await store.updateFilter(sortNewestFirst: true);
//       verify(ops.doFilterChanged(any)).called(1);
//     });
//   });
// });

// journal refresh

// group("binder", () {
//   test("onJournalTab", () async {
//     await withTrace((m) async {
//       final stage = StageStore();
//       DI.register<StageStore>(stage);
//
//       final timer = MockTimerService();
//       DI.register<TimerService>(timer);
//
//       final store = MockJournalRefreshStore();
//       DI.register<JournalRefreshStore>(store);
//
//       final subject = JournalRefreshBinder();
//       verifyNever(store.maybeRefresh(any));
//
//       // When the tab is on, should refresh immediately and with interval
//       stage.setReady(true);
//       await stage.setActiveTab(StageTab.activity);
//       verify(store.maybeRefresh(any)).called(1);
//       verify(timer.set(any, any)).called(1);
//
//       // When another tab is on, should stop refreshing
//       await stage.setActiveTab(StageTab.settings);
//       verify(timer.unset(any)).called(1);
//     });
//   });
//
//   test("onBackground", () async {
//     await withTrace((m) async {
//       final stage = StageStore();
//       DI.register<StageStore>(stage);
//
//       final timer = MockTimerService();
//       DI.register<TimerService>(timer);
//
//       final store = MockJournalRefreshStore();
//       DI.register<JournalRefreshStore>(store);
//
//       final subject = JournalRefreshBinder();
//       verifyNever(store.maybeRefresh(any));
//
//       // When the app is in background, stop refreshing
//       stage.setReady(true);
//       await stage.setForeground(true);
//       await stage.setForeground(false);
//       verify(timer.unset(any)).called(1);
//     });
//   });
//
//   test("onTimerFired", () async {
//     await withTrace((m) async {
//       final timer = MockTimerService();
//       dynamic callback;
//       when(timer.addHandler(any, any))
//           .thenAnswer((p) => callback = p.positionalArguments[1]);
//       DI.register<TimerService>(timer);
//
//       final store = MockJournalRefreshStore();
//       DI.register<JournalRefreshStore>(store);
//
//       final subject = JournalRefreshBinder();
//
//       // Will register the timer handler
//       verify(timer.addHandler(any, any)).called(1);
//
//       // Will re-schedule timer when called from the timer
//       await callback();
//       verify(timer.set(any, any)).called(1);
//     });
//   });
//
//   test("onRetentionChanged", () async {
//     await withTrace((m) async {
//       final device = DeviceStore();
//       DI.register<DeviceStore>(device);
//
//       final store = MockJournalRefreshStore();
//       DI.register<JournalRefreshStore>(store);
//
//       final timer = MockTimerService();
//       DI.register<TimerService>(timer);
//
//       final subject = JournalRefreshBinder();
//
//       device.retention = "24h";
//       verify(store.enableRefresh(any, true)).called(1);
//
//       device.retention = "";
//       verify(store.enableRefresh(any, false)).called(1);
//
//       device.retention = null;
//       verify(store.enableRefresh(any, false)).called(1);
//     });
//   });
// });

// lease

//   group("binder", () {
//     test("onForeground", () async {
//       await withTrace((m) async {
//         final store = MockPlusRefreshStore();
//         DI.register<PlusRefreshStore>(store);
//
//         final plus = MockPlusStore();
//         DI.register<PlusStore>(plus);
//
//         final gateway = MockPlusGatewayStore();
//         DI.register<PlusGatewayStore>(gateway);
//
//         final lease = PlusLeaseStore();
//         DI.register<PlusLeaseStore>(lease);
//
//         final vpn = MockPlusVpnStore();
//         DI.register<PlusVpnStore>(vpn);
//
//         final keypair = PlusKeypairStore();
//         DI.register<PlusKeypairStore>(keypair);
//
//         final app = MockAppStore();
//         DI.register<AppStore>(app);
//
//         final stage = StageStore();
//         DI.register<StageStore>(stage);
//
//         final env = EnvStore();
//         DI.register<EnvStore>(env);
//
//         final subject = PlusRefreshBinder();
//         verifyNever(store.maybeRefreshLease(any));
//
//         // When in foreground, should try to refresh
//         await stage.setReady(true);
//         await stage.setForeground(true);
//         verify(store.maybeRefreshLease(any)).called(1);
//       });
//     });
//
//     test("onCurrentLease", () async {
//       await withTrace((m) async {
//         final store = MockPlusRefreshStore();
//         DI.register<PlusRefreshStore>(store);
//
//         final plus = PlusStore();
//         DI.register<PlusStore>(plus);
//
//         final gateway = PlusGatewayStore();
//         DI.register<PlusGatewayStore>(gateway);
//
//         final lease = PlusLeaseStore();
//         DI.register<PlusLeaseStore>(lease);
//
//         final vpn = MockPlusVpnStore();
//         DI.register<PlusVpnStore>(vpn);
//
//         final keypair = PlusKeypairStore();
//         DI.register<PlusKeypairStore>(keypair);
//
//         final app = AppStore();
//         DI.register<AppStore>(app);
//
//         final stage = StageStore();
//         DI.register<StageStore>(stage);
//
//         final env = EnvStore();
//         DI.register<EnvStore>(env);
//
//         final subject = PlusRefreshBinder();
//         verifyNever(vpn.setConfig(any, any));
//
//         // No calls when not all params are available yet
//         lease.currentLease = fixtureLeaseEntries.first.toLease;
//         verifyNever(vpn.setConfig(any, any));
//
//         keypair.currentKeypair = PlusKeypair(publicKey: "pk", privateKey: "sk");
//         gateway.currentGateway = fixtureGatewayEntries.first.toGateway;
//         env.setDeviceTag("device tag");
//         plus.plusEnabled = true;
//         app.status = AppStatus.activatedCloud;
//
//         lease.currentLease = fixtureLeaseEntries.first.toLease;
//         verify(vpn.setConfig(any, any)).called(1);
//       });
//     });
//   });
