import 'dart:convert';

import 'package:common/core/core.dart';
import 'package:common/platform/account/account.dart';
import 'package:common/platform/account/api.dart';
import 'package:common/platform/stage/stage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../tools.dart';
@GenerateNiceMocks([
  MockSpec<AccountApi>(),
  MockSpec<StageStore>(),
  MockSpec<Persistence>(),
  MockSpec<AccountStore>(),
])
import 'account_test.mocks.dart';
import 'fixtures.dart';

void main() {
  group("store", () {
    test("loadWillReadFromPersistence", () async {
      await withTrace((m) async {
        final persistence = MockPersistence();
        when(persistence.loadJson(any, any, isBackup: true))
            .thenAnswer((_) => Future.value(jsonDecode(fixtureJsonAccount)));
        Core.register<Persistence>(persistence, tag: Persistence.secure);

        final subject = AccountStore();
        mockAct(subject);

        await subject.load(m);

        verify(persistence.loadJson(any, any, isBackup: true)).called(1);
        expect(subject.account!.id, "mockedmocked");
        expect(subject.account!.type, AccountType.cloud);
        expect(subject.account!.jsonAccount.active, true);
      });
    });

    test("createWillPostAccountAndWriteToPersistence", () async {
      await withTrace((m) async {
        final persistence = MockPersistence();
        Core.register<Persistence>(persistence, tag: Persistence.secure);

        final json = MockAccountApi();
        when(json.postAccount(m)).thenAnswer((_) =>
            Future.value(JsonAccount.fromJson(jsonDecode(fixtureJsonAccount))));
        Core.register<AccountApi>(json);

        final subject = AccountStore();
        mockAct(subject);

        await subject.createAccount(m);

        verify(persistence.saveJson(any, any, any, isBackup: true)).called(1);
        expect(subject.account!.id, "mockedmocked");
        expect(subject.account!.type, AccountType.cloud);
        expect(subject.account!.jsonAccount.active, true);
      });
    });

    test("fetchWillFetchFromApiAndWriteToPersistence", () async {
      await withTrace((m) async {
        final persistence = MockPersistence();
        when(persistence.loadJson(any, any, isBackup: true))
            .thenAnswer((_) => Future.value(jsonDecode(fixtureJsonAccount)));
        Core.register<Persistence>(persistence, tag: Persistence.secure);

        final json = MockAccountApi();
        when(json.getAccount(any, any)).thenAnswer((_) =>
            Future.value(JsonAccount.fromJson(jsonDecode(fixtureJsonAccount))));
        Core.register<AccountApi>(json);

        final subject = AccountStore();
        mockAct(subject);

        await subject.load(m);
        await subject.fetch(m);

        verify(persistence.saveJson(any, any, any, isBackup: true)).called(1);
      });
    });

    test("restoreWillGetAccountWithProvidedId", () async {
      await withTrace((m) async {
        Core.register<StageStore>(MockStageStore());

        final persistence = MockPersistence();
        when(persistence.loadJson(any, any, isBackup: true))
            .thenAnswer((_) => Future.value(jsonDecode(fixtureJsonAccount)));
        Core.register<Persistence>(persistence, tag: Persistence.secure);

        final json = MockAccountApi();
        when(json.getAccount(any, any)).thenAnswer((_) => Future.value(
            JsonAccount.fromJson(jsonDecode(fixtureJsonAccount2))));
        Core.register<AccountApi>(json);

        final subject = AccountStore();
        mockAct(subject);

        // First load as normal
        await subject.load(m);

        expect(subject.account!.id, "mockedmocked");

        // Then try restoring another account
        await subject.restore("mocked2", m);

        verify(json.getAccount("mocked2", m)).called(1);
        verify(persistence.saveJson(any, any, any, isBackup: true)).called(1);
        expect(subject.account!.id, "mocked2");
        expect(subject.account!.type, AccountType.libre);
        expect(subject.account!.jsonAccount.active, false);
      });
    });

    test("expireOfflineWillExpireAccountAndWriteToPersistence", () async {
      await withTrace((m) async {
        final persistence = MockPersistence();
        when(persistence.loadJson(any, any, isBackup: true))
            .thenAnswer((_) => Future.value(jsonDecode(fixtureJsonAccount)));
        Core.register<Persistence>(persistence, tag: Persistence.secure);

        final json = MockAccountApi();
        Core.register<AccountApi>(json);

        final subject = AccountStore();
        mockAct(subject);

        await subject.load(m);

        expect(subject.account!.id, "mockedmocked");
        expect(subject.account!.type, AccountType.cloud);
        expect(subject.account!.jsonAccount.active, true);

        await subject.expireOffline(m);

        verify(persistence.saveJson(any, any, any, isBackup: true)).called(1);
        expect(subject.account!.id, "mockedmocked");
        expect(subject.account!.type, AccountType.libre);
        expect(subject.account!.jsonAccount.active, false);
      });
    });

    test("proposeWillUpdateAccountAndWriteToPersistence", () async {
      await withTrace((m) async {
        final persistence = MockPersistence();
        Core.register<Persistence>(persistence, tag: Persistence.secure);

        final subject = AccountStore();

        await subject.propose(
            JsonAccount.fromJson(jsonDecode(fixtureJsonAccount2)), m);

        verify(persistence.saveJson(any, any, any, isBackup: true)).called(1);
        expect(subject.account!.id, "mocked2");
      });
    });
  });

  group("storeErrors", () {
    test("willReturnErrorOnEmptyCache", () async {
      await withTrace((m) async {
        final persistence = MockPersistence();
        when(persistence.loadJson(any, any, isBackup: true))
            .thenThrow(Exception("no account in cache"));
        Core.register<Persistence>(persistence, tag: Persistence.secure);

        Core.register<AccountApi>(MockAccountApi());

        final subject = AccountStore();

        await expectLater(subject.load(m), throwsException);
      });
    });

    test("fetchWillReturnErrorWhenNoLoadCalledBefore", () async {
      await withTrace((m) async {
        final subject = AccountStore();

        await expectLater(
            subject.fetch(m), throwsA(isA<AccountNotInitialized>()));
      });
    });

    // test("restoreWillThrowOnInvalidAccountId", () async {
    //   await withTrace((m) async {
    //     DI.register<StageStore>(MockStageStore());
    //     final subject = AccountStore();
    //
    //     // Empty account ID
    //     await expectLater(
    //         subject.restore(""), throwsA(isA<InvalidAccountId>()));
    //   });
    // });

    // test("will generate new keypair on empty cache", () async {
    //   final mCache = MockSecurePersistenceSpec();
    //   when(mCache.loadOrThrow(any)).thenAnswer((_) =>
    //       Future.value(jsonDecode(Fixtures.cacheAccount))
    //   );
    //   DI.register<SecurePersistenceSpec>(mCache);
    //
    //   final mKeypair = MockKeypairService();
    //   when(mKeypair.generate()).thenAnswer((_) =>
    //       Future.value(AccountKeypair("pub", "priv"))
    //   );
    //   DI.register<KeypairService>(mKeypair);
    //
    //   DI.register<ApiSpec>(MockApiSpec());
    //
    //   final store = AccountStore();
    //
    //   try {
    //     await store.load(DebugTrace.as("account"));
    //     verify(mKeypair.generate()).called(1);
    //     verify(mCache.save(any, any, any));
    //   } catch (e, s) {
    //     fail("exception thrown: $e\n$s");
    //   }
    // });
  });
}
