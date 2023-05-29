import 'package:common/util/mobx.dart';
import 'package:mobx/mobx.dart';

import '../../util/di.dart';
import '../../util/trace.dart';
import '../account.dart';
import 'channel.pg.dart';
import 'json.dart';

part 'payment.g.dart';

typedef ProductId = String;
typedef ReceiptBlob = String;

class AccountPaymentStore = AccountPaymentStoreBase with _$AccountPaymentStore;

abstract class AccountPaymentStoreBase with Store, Traceable, Dependable {
  late final _ops = di<AccountPaymentOps>();
  late final _json = di<AccountPaymentJson>();
  late final _account = di<AccountStore>();

  AccountPaymentStoreBase() {
    reactionOnStore((_) => status, (status) async {
      await _ops.doPaymentStatusChanged(status);
    });

    reactionOnStore((_) => products, (products) async {
      if (products != null) {
        await _ops.doProductsChanged(products);
      }
    });
  }

  @override
  attach() {
    depend<AccountPaymentJson>(AccountPaymentJson());
    depend<AccountPaymentOps>(AccountPaymentOps());
    depend<AccountPaymentStore>(this as AccountPaymentStore);
  }

  @observable
  PaymentStatus status = PaymentStatus.unknown;

  @observable
  List<Product>? products;

  @observable
  List<ReceiptBlob> receipts = [];

  @action
  Future<void> fetchProducts(Trace parentTrace) async {
    return await traceWith(parentTrace, "fetchProducts", (trace) async {
      await _ensureInit();
      _ensureReady();

      status = PaymentStatus.fetching;
      try {
        products = (await _ops.doFetchProducts()).cast<Product>();
        status = PaymentStatus.ready;
      } on Exception catch (e) {
        status = PaymentStatus.ready;
        rethrow;
      }
    });
  }

  @action
  Future<void> purchase(Trace parentTrace, ProductId id) async {
    return await traceWith(parentTrace, "purchase", (trace) async {
      await _ensureInit();
      _ensureReady();

      status = PaymentStatus.purchasing;
      try {
        if (await _processQueuedReceipts(trace)) {
          // Restored from a queued receipt, no need to purchase
          status = PaymentStatus.ready;
          return;
        }

        final receipt = await _ops.doPurchaseWithReceipt(id);
        await _processReceipt(trace, receipt);
        status = PaymentStatus.ready;
      } on Exception catch (e) {
        _ops.doFinishOngoingTransaction();
        status = PaymentStatus.ready;
        rethrow;
      }
    });
  }

  @action
  Future<void> restore(Trace parentTrace) async {
    return await traceWith(parentTrace, "restore", (trace) async {
      await _ensureInit();
      _ensureReady();

      status = PaymentStatus.restoring;
      try {
        if (await _processQueuedReceipts(trace)) {
          // Restored from a queued receipt, no need to purchase
          status = PaymentStatus.ready;
          return;
        }

        final receipt = await _ops.doRestoreWithReceipt();
        await _processReceipt(trace, receipt);
        status = PaymentStatus.ready;
      } on Exception catch (e) {
        _ops.doFinishOngoingTransaction();
        status = PaymentStatus.ready;
        rethrow;
      }
    });
  }

  @action
  Future<void> restoreInBackground(
      Trace parentTrace, ReceiptBlob receipt) async {
    return await traceWith(parentTrace, "restoreInBackground", (trace) async {
      await _ensureInit();

      if (status != PaymentStatus.ready) {
        receipts.add(receipt);
        trace.addAttribute("queued", true);
        trace.addAttribute("queueSize", receipts.length);
        return;
      }

      status = PaymentStatus.restoring;
      try {
        await _processReceipt(trace, receipt);

        // Succeeded (no exception), drop any older receipts
        receipts.clear();

        status = PaymentStatus.ready;
      } on Exception catch (e) {
        // Ignore any errors when processing payments in the background
        // Try any (older) queued receipts as a fallback
        await _processQueuedReceipts(trace);
        status = PaymentStatus.ready;
      }
    });
  }

  _processReceipt(Trace trace, ReceiptBlob receipt) async {
    final account = await _json.postCheckout(trace, receipt);

    try {
      final type = AccountType.values.byName(account.type ?? "unknown");
      if (!type.isActive()) {
        throw Exception("Account still inactive after purchase");
      }
    } catch (e) {
      throw Exception("Account still inactive after purchase");
    }

    _ops.doFinishOngoingTransaction();
    await _account.propose(trace, account);
  }

  Future<bool> _processQueuedReceipts(Trace trace) async {
    if (receipts.isEmpty) {
      return false;
    }

    trace.addAttribute("queueSize", receipts.length);
    while (receipts.isNotEmpty) {
      // Process from the newest receipt first
      final receipt = receipts.removeLast();
      try {
        await traceWith(trace, "processQueuedReceipt", (trace) async {
          await _processReceipt(trace, receipt);
        });
        // Succeeded (no exception), drop any older receipts
        receipts.clear();
        return true;
      } on Exception catch (e) {
        // Ignore any errors when processing payments in the background
      }
    }
    return false;
  }

  _ensureInit() async {
    if (status == PaymentStatus.unknown &&
        !(await _ops.doArePaymentsAvailable())) {
      status = PaymentStatus.fatal;
      throw Exception("Payments not available");
    } else {
      status = PaymentStatus.ready;
    }
  }

  _ensureReady() {
    if (status != PaymentStatus.ready) {
      throw Exception("Payments not ready");
    }
  }
}
