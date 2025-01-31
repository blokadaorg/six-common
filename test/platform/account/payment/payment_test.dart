import 'dart:convert';

import 'package:common/core/core.dart';
import 'package:common/platform/account/account.dart';
import 'package:common/platform/account/api.dart';
import 'package:common/platform/payment/api.dart';
import 'package:common/platform/payment/channel.pg.dart';
import 'package:common/platform/payment/payment.dart';
import 'package:common/platform/stage/stage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../tools.dart';
import '../fixtures.dart';
@GenerateNiceMocks([
  MockSpec<PaymentOps>(),
  MockSpec<AccountPaymentApi>(),
  MockSpec<AccountStore>(),
  MockSpec<AccountPaymentStore>(),
  MockSpec<StageStore>(),
])
import 'payment_test.mocks.dart';

final _fixtureProducts = [
  Product(
    id: "id1",
    title: "title1",
    description: "description1",
    price: "9.99",
    pricePerMonth: "9.99",
    periodMonths: 1,
    type: "plus",
    trial: null,
    owned: false,
  ),
  Product(
    id: "id2",
    title: "title2",
    description: "description2",
    price: "29.99",
    pricePerMonth: "2.09",
    periodMonths: 12,
    type: "cloud",
    trial: null,
    owned: false,
  ),
];

void main() {
  group("store", () {
    test("willFetchProducts", () async {
      await withTrace((m) async {
        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doFetchProducts()).thenAnswer((_) async => _fixtureProducts);
        Core.register<PaymentOps>(ops);

        Core.register<AccountStore>(MockAccountStore());

        final subject = AccountPaymentStore();
        expect(subject.status, PaymentStatus.unknown);

        await subject.fetchProducts(m);
        expect(subject.status, PaymentStatus.ready);
        expect(subject.products?.length, _fixtureProducts.length);
        expect(subject.products?[0].id, "id1");
        verify(ops.doFetchProducts()).called(1);
        verify(ops.doArePaymentsAvailable()).called(1);

        // Second call doesn't check availability again
        await subject.fetchProducts(m);
        verify(ops.doFetchProducts()).called(1);
        verifyNever(ops.doArePaymentsAvailable());
      });
    });

    test("willPerformPurchase", () async {
      await withTrace((m) async {
        Core.register<StageStore>(MockStageStore());

        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipts(any))
            .thenAnswer((_) async => ["receipt"]);
        Core.register<PaymentOps>(ops);

        final json = MockAccountPaymentApi();
        when(json.postCheckout(any, any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        Core.register<AccountPaymentApi>(json);

        final account = MockAccountStore();
        Core.register<AccountStore>(account);

        final subject = AccountPaymentStore();
        mockAct(subject);

        await subject.purchase("id1", m);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipts("id1")).called(1);
        verify(json.postCheckout("receipt", any, any)).called(1);
        verify(account.propose(any, any)).called(1);
      });
    });

    test("willProcessQueuedReceiptsFirstOnPurchase", () async {
      await withTrace((m) async {
        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        Core.register<PaymentOps>(ops);

        final json = MockAccountPaymentApi();
        when(json.postCheckout(any, any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        Core.register<AccountPaymentApi>(json);

        final account = MockAccountStore();
        Core.register<AccountStore>(account);

        final subject = AccountPaymentStore();
        mockAct(subject);
        subject.receipts = ["receipt1", "receipt2"];

        // Will try old receipts from the latest first and succeed without purchase
        await subject.purchase("id1", m);
        expect(subject.status, PaymentStatus.ready);
        expect(subject.receipts.isEmpty, true);
        verify(json.postCheckout("receipt2", any, any)).called(1);
        verify(account.propose(any, any)).called(1);
        verifyNever(ops.doPurchaseWithReceipts(any));
      });
    });

    test("willRestore", () async {
      await withTrace((m) async {
        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doRestoreWithReceipts()).thenAnswer((_) async => ["receipt"]);
        Core.register<PaymentOps>(ops);

        final json = MockAccountPaymentApi();
        when(json.postCheckout(any, any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        Core.register<AccountPaymentApi>(json);

        final account = MockAccountStore();
        Core.register<AccountStore>(account);

        final subject = AccountPaymentStore();
        mockAct(subject);
        expect(subject.status, PaymentStatus.unknown);

        await subject.restore(m);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doRestoreWithReceipts()).called(1);
        verify(json.postCheckout("receipt", any, any)).called(1);
        verify(account.propose(any, any)).called(1);
      });
    });

    test("willRestoreInBackground", () async {
      await withTrace((m) async {
        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        Core.register<PaymentOps>(ops);

        final json = MockAccountPaymentApi();
        when(json.postCheckout("good receipt", any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        when(json.postCheckout("bad receipt", any, any))
            .thenThrow(Exception("bad receipt"));
        Core.register<AccountPaymentApi>(json);

        final account = MockAccountStore();
        Core.register<AccountStore>(account);

        final subject = AccountPaymentStore();
        mockAct(subject);
        subject.receipts = ["old receipt", "good receipt"];
        expect(subject.status, PaymentStatus.unknown);

        // Will try the "bad receipt" provided first, then the "good receipt"
        // from the old queued up receipts, and ignore the "old receipt".
        await subject.restoreInBackground("bad receipt", m);

        expect(subject.status, PaymentStatus.ready);
        expect(subject.receipts.isEmpty, true);
        verify(json.postCheckout("bad receipt", any, any)).called(1);
        verify(json.postCheckout("good receipt", any, any)).called(1);
        verify(account.propose(any, any)).called(1);
      });
    });
  });

  group("storeErrors", () {
    test("willNotFetchProductsIfNotReady", () async {
      await withTrace((m) async {
        Core.register<StageStore>(MockStageStore());

        Core.register<AccountStore>(MockAccountStore());

        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => false);
        Core.register<PaymentOps>(ops);

        final subject = AccountPaymentStore();

        await expectLater(subject.fetchProducts(m), throwsException);
        expect(subject.status, PaymentStatus.fatal);
        expect(subject.products, null);
        verify(ops.doArePaymentsAvailable()).called(1);
        verifyNever(ops.doFetchProducts());
      });
    });

    test("willNotCallApiOnFailingPurchase", () async {
      await withTrace((m) async {
        Core.register<StageStore>(MockStageStore());

        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipts(any))
            .thenThrow(Exception("Channel failing"));
        Core.register<PaymentOps>(ops);

        final json = MockAccountPaymentApi();
        Core.register<AccountPaymentApi>(json);

        final account = MockAccountStore();
        Core.register<AccountStore>(account);

        final subject = AccountPaymentStore();

        await expectLater(subject.purchase("id1", m), throwsException);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipts("id1")).called(1);
        verifyNever(json.postCheckout(any, any, any));
        verifyNever(account.propose(any, any));
      });
    });

    test("willNotProposeAccountOnFailingApiCall", () async {
      await withTrace((m) async {
        Core.register<StageStore>(MockStageStore());

        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipts(any))
            .thenAnswer((_) async => ["receipt"]);
        Core.register<PaymentOps>(ops);

        final json = MockAccountPaymentApi();
        when(json.postCheckout(any, any, any))
            .thenThrow(Exception("Api failing"));
        Core.register<AccountPaymentApi>(json);

        final account = MockAccountStore();
        Core.register<AccountStore>(account);

        final subject = AccountPaymentStore();
        mockAct(subject);

        await expectLater(subject.purchase("id1", m), throwsException);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipts("id1")).called(1);
        verify(json.postCheckout("receipt", any, any)).called(1);
        verifyNever(account.propose(any, any));
      });
    });

    test("willNotProposeAccountOnApiReturningInactiveAccount", () async {
      await withTrace((m) async {
        Core.register<StageStore>(MockStageStore());

        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipts(any))
            .thenAnswer((_) async => ["receipt"]);
        Core.register<PaymentOps>(ops);

        final json = MockAccountPaymentApi();
        when(json.postCheckout(any, any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount2)));
        Core.register<AccountPaymentApi>(json);

        final account = MockAccountStore();
        Core.register<AccountStore>(account);

        final subject = AccountPaymentStore();
        mockAct(subject);

        await expectLater(subject.purchase("id1", m), throwsException);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipts("id1")).called(1);
        verify(json.postCheckout("receipt", any, any)).called(1);
        verifyNever(account.propose(any, any));
      });
    });
  });

  group("binder", () {
    test("onStatusChanged", () async {
      await withTrace((m) async {
        final ops = MockPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        Core.register<PaymentOps>(ops);

        Core.register<AccountStore>(MockAccountStore());

        final store = AccountPaymentStore();
        Core.register<AccountPaymentStore>(store);

        await store.fetchProducts(m);
        verify(ops.doPaymentStatusChanged(PaymentStatus.fetching)).called(1);
        verify(ops.doPaymentStatusChanged(PaymentStatus.ready)).called(1);
      });
    });
  });
}
