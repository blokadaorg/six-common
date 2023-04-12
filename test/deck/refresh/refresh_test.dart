import 'package:common/deck/deck.dart';
import 'package:common/deck/refresh/refresh.dart';
import 'package:common/stage/stage.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../tools.dart';

import '../../fixtures.dart';
@GenerateNiceMocks([
  MockSpec<DeckStore>(),
  MockSpec<DeckRefreshStore>(),
])
import 'refresh_test.mocks.dart';

void main() {
  group("store", () {
    test("willRefreshWhenNeeded", () async {
      await withTrace((trace) async {
        final store = MockDeckStore();
        di.registerSingleton<DeckStore>(store);

        final subject = DeckRefreshStore();
        verifyNever(store.fetch(any));

        // Initially will refresh
        await subject.maybeRefresh(trace);
        verify(store.fetch(any)).called(1);

        // Then it wont refresh (until cooldown time passed)
        await subject.maybeRefresh(trace);
        verifyNever(store.fetch(any));

        // Imagine cooldown passed, should refresh again
        subject.lastRefresh =
            DateTime.now().subtract(const Duration(minutes: 10));
        await subject.maybeRefresh(trace);
        verify(store.fetch(any)).called(1);
      });
    });
  });

  group("binder", () {
    test("onAdvancedTab", () async {
      await withTrace((trace) async {
        final stage = StageStore();
        di.registerSingleton<StageStore>(stage);

        final store = MockDeckRefreshStore();
        di.registerSingleton<DeckRefreshStore>(store);

        final subject = DeckRefreshBinder();
        verifyNever(store.maybeRefresh(any));

        // When the tab is on, should refresh immediately
        stage.setReady(trace, true);
        await stage.setActiveTab(trace, StageTab.advanced);
        verify(store.maybeRefresh(any)).called(1);
      });
    });
  });
}
