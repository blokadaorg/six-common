import 'package:common/custom/channel.pg.dart';
import 'package:common/custom/custom.dart';
import 'package:common/custom/json.dart';
import 'package:common/stage/stage.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tools.dart';
@GenerateNiceMocks([
  MockSpec<CustomStore>(),
  MockSpec<CustomOps>(),
  MockSpec<CustomJson>(),
  MockSpec<StageStore>(),
])
import 'custom_test.mocks.dart';
import 'fixtures.dart';

void main() {
  group("store", () {
    test("willSplitEntriesByType", () async {
      await withTrace((m) async {
        depend<StageStore>(MockStageStore());

        final json = MockCustomJson();
        when(json.getEntries(any))
            .thenAnswer((_) => Future.value(fixtureCustomEntries));
        depend<CustomJson>(json);

        final ops = MockCustomOps();
        depend<CustomOps>(ops);

        final subject = CustomStore();
        await subject.fetch(m);

        expect(subject.allowed.length, 3);
        expect(subject.allowed.first, "abc.example.com");
        expect(subject.denied.length, 4);
        expect(subject.denied.first, "abc.sth.io");
      });
    });

    test("allowAndOthers", () async {
      await withTrace((m) async {
        depend<StageStore>(MockStageStore());

        final json = MockCustomJson();
        when(json.getEntries(any))
            .thenAnswer((_) => Future.value(fixtureCustomEntries));
        depend<CustomJson>(json);

        final ops = MockCustomOps();
        depend<CustomOps>(ops);

        final subject = CustomStore();

        // Will post entry and refresh
        await subject.allow("test.com", m);
        verify(json.postEntry(any, any)).called(1);
        verify(json.getEntries(any)).called(1);

        await subject.deny("test.com", m);
        verify(json.postEntry(any, any)).called(1);
        verify(json.getEntries(any)).called(1);

        await subject.delete("test.com", m);
        verify(json.deleteEntry(any, any)).called(1);
        verify(json.getEntries(any)).called(1);
      });
    });

    test("willRefreshWhenNeeded", () async {
      await withTrace((m) async {
        final json = MockCustomJson();
        depend<CustomJson>(json);

        final route = StageRouteState.init().newTab(StageTab.activity);
        final stage = MockStageStore();
        depend<StageStore>(stage);

        final ops = MockCustomOps();
        depend<CustomOps>(ops);

        final subject = CustomStore();
        verifyNever(json.getEntries(any));

        await subject.onRouteChanged(route, m);
        verify(json.getEntries(any));
      });
    });
  });
}
