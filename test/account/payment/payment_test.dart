import 'dart:convert';

import 'package:common/account/account.dart';
import 'package:common/account/json.dart';
import 'package:common/account/payment/channel.pg.dart';
import 'package:common/account/payment/json.dart';
import 'package:common/account/payment/payment.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../tools.dart';
import '../fixtures.dart';
@GenerateNiceMocks([
  MockSpec<AccountPaymentOps>(),
  MockSpec<AccountPaymentJson>(),
  MockSpec<AccountStore>(),
  MockSpec<AccountPaymentStore>(),
])
import 'payment_test.mocks.dart';

final _fixtureProducts = [
  Product(
      id: "id1",
      title: "title1",
      description: "description1",
      price: "9.99",
      period: 1,
      type: "plus",
      trial: false),
  Product(
      id: "id2",
      title: "title2",
      description: "description2",
      price: "29.99",
      period: 12,
      type: "cloud",
      trial: false),
];

void main() {
  group("store", () {
    test("willFetchProducts", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doFetchProducts()).thenAnswer((_) async => _fixtureProducts);
        di.registerSingleton<AccountPaymentOps>(ops);

        final subject = AccountPaymentStore();
        expect(subject.status, PaymentStatus.unknown);

        await subject.fetchProducts(trace);
        expect(subject.status, PaymentStatus.ready);
        expect(subject.products?.length, _fixtureProducts.length);
        expect(subject.products?[0].id, "id1");
        verify(ops.doFetchProducts()).called(1);
        verify(ops.doArePaymentsAvailable()).called(1);

        // Second call doesn't check availability again
        await subject.fetchProducts(trace);
        verify(ops.doFetchProducts()).called(1);
        verifyNever(ops.doArePaymentsAvailable());
      });
    });

    test("willPerformPurchase", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipt(any)).thenAnswer((_) async => "receipt");
        di.registerSingleton<AccountPaymentOps>(ops);

        final json = MockAccountPaymentJson();
        when(json.postCheckout(any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        di.registerSingleton<AccountPaymentJson>(json);

        final account = MockAccountStore();
        di.registerSingleton<AccountStore>(account);

        final subject = AccountPaymentStore();

        await subject.purchase(trace, "id1");
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipt("id1")).called(1);
        verify(json.postCheckout(any, "receipt")).called(1);
        verify(account.propose(any, any)).called(1);
      });
    });

    test("willProcessQueuedReceiptsFirstOnPurchase", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        di.registerSingleton<AccountPaymentOps>(ops);

        final json = MockAccountPaymentJson();
        when(json.postCheckout(any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        di.registerSingleton<AccountPaymentJson>(json);

        final account = MockAccountStore();
        di.registerSingleton<AccountStore>(account);

        final subject = AccountPaymentStore();
        subject.receipts = ["receipt1", "receipt2"];

        // Will try old receipts from the latest first and succeed without purchase
        await subject.purchase(trace, "id1");
        expect(subject.status, PaymentStatus.ready);
        expect(subject.receipts.isEmpty, true);
        verify(json.postCheckout(any, "receipt2")).called(1);
        verify(account.propose(any, any)).called(1);
        verifyNever(ops.doPurchaseWithReceipt(any));
      });
    });

    test("willRestore", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doRestoreWithReceipt()).thenAnswer((_) async => "receipt");
        di.registerSingleton<AccountPaymentOps>(ops);

        final json = MockAccountPaymentJson();
        when(json.postCheckout(any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        di.registerSingleton<AccountPaymentJson>(json);

        final account = MockAccountStore();
        di.registerSingleton<AccountStore>(account);

        final subject = AccountPaymentStore();
        expect(subject.status, PaymentStatus.unknown);

        await subject.restore(trace);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doRestoreWithReceipt()).called(1);
        verify(json.postCheckout(any, "receipt")).called(1);
        verify(account.propose(any, any)).called(1);
      });
    });

    test("willRestoreInBackground", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        di.registerSingleton<AccountPaymentOps>(ops);

        final json = MockAccountPaymentJson();
        when(json.postCheckout(any, "good receipt")).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount)));
        when(json.postCheckout(any, "bad receipt"))
            .thenThrow(Exception("bad receipt"));
        di.registerSingleton<AccountPaymentJson>(json);

        final account = MockAccountStore();
        di.registerSingleton<AccountStore>(account);

        final subject = AccountPaymentStore();
        subject.receipts = ["old receipt", "good receipt"];
        expect(subject.status, PaymentStatus.unknown);

        // Will try the "bad receipt" provided first, then the "good receipt"
        // from the old queued up receipts, and ignore the "old receipt".
        await subject.restoreInBackground(trace, "bad receipt");

        expect(subject.status, PaymentStatus.ready);
        expect(subject.receipts.isEmpty, true);
        verify(json.postCheckout(any, "bad receipt")).called(1);
        verify(json.postCheckout(any, "good receipt")).called(1);
        verify(account.propose(any, any)).called(1);
      });
    });
  });

  group("storeErrors", () {
    test("willNotFetchProductsIfNotReady", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => false);
        di.registerSingleton<AccountPaymentOps>(ops);

        final subject = AccountPaymentStore();

        await expectLater(subject.fetchProducts(trace), throwsException);
        expect(subject.status, PaymentStatus.fatal);
        expect(subject.products, null);
        verify(ops.doArePaymentsAvailable()).called(1);
        verifyNever(ops.doFetchProducts());
      });
    });

    test("willNotCallApiOnFailingPurchase", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipt(any))
            .thenThrow(Exception("Channel failing"));
        di.registerSingleton<AccountPaymentOps>(ops);

        final json = MockAccountPaymentJson();
        di.registerSingleton<AccountPaymentJson>(json);

        final account = MockAccountStore();
        di.registerSingleton<AccountStore>(account);

        final subject = AccountPaymentStore();

        await expectLater(subject.purchase(trace, "id1"), throwsException);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipt("id1")).called(1);
        verifyNever(json.postCheckout(any, any));
        verifyNever(account.propose(any, any));
      });
    });

    test("willNotProposeAccountOnFailingApiCall", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipt(any)).thenAnswer((_) async => "receipt");
        di.registerSingleton<AccountPaymentOps>(ops);

        final json = MockAccountPaymentJson();
        when(json.postCheckout(any, any)).thenThrow(Exception("Api failing"));
        di.registerSingleton<AccountPaymentJson>(json);

        final account = MockAccountStore();
        di.registerSingleton<AccountStore>(account);

        final subject = AccountPaymentStore();

        await expectLater(subject.purchase(trace, "id1"), throwsException);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipt("id1")).called(1);
        verify(json.postCheckout(any, "receipt")).called(1);
        verifyNever(account.propose(any, any));
      });
    });

    test("willNotProposeAccountOnApiReturningInactiveAccount", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        when(ops.doPurchaseWithReceipt(any)).thenAnswer((_) async => "receipt");
        di.registerSingleton<AccountPaymentOps>(ops);

        final json = MockAccountPaymentJson();
        when(json.postCheckout(any, any)).thenAnswer(
            (_) async => JsonAccount.fromJson(jsonDecode(fixtureJsonAccount2)));
        di.registerSingleton<AccountPaymentJson>(json);

        final account = MockAccountStore();
        di.registerSingleton<AccountStore>(account);

        final subject = AccountPaymentStore();

        await expectLater(subject.purchase(trace, "id1"), throwsException);
        expect(subject.status, PaymentStatus.ready);
        verify(ops.doPurchaseWithReceipt("id1")).called(1);
        verify(json.postCheckout(any, "receipt")).called(1);
        verifyNever(account.propose(any, any));
      });
    });
  });

  group("binder", () {
    test("onStatusChanged", () async {
      await withTrace((trace) async {
        final ops = MockAccountPaymentOps();
        when(ops.doArePaymentsAvailable()).thenAnswer((_) async => true);
        di.registerSingleton<AccountPaymentOps>(ops);

        final store = AccountPaymentStore();
        di.registerSingleton<AccountPaymentStore>(store);

        await store.fetchProducts(trace);
        verify(ops.doPaymentStatusChanged(PaymentStatus.fetching)).called(1);
        verify(ops.doPaymentStatusChanged(PaymentStatus.ready)).called(1);
      });
    });
  });
}
