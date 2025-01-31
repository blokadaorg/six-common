import 'package:common/core/core.dart';
import 'package:mocktail/mocktail.dart';

import 'channel.pg.dart';

class MockAccountPaymentOps extends Mock implements PaymentOps {}

PaymentOps getOps() {
  if (Core.act.isProd) {
    return PaymentOps();
  }

  final ops = MockAccountPaymentOps();
  _actNormal(ops);
  return ops;
}

_actNormal(MockAccountPaymentOps ops) {
  registerFallbackValue(PaymentStatus.unknown);

  when(() => ops.doFinishOngoingTransaction()).thenAnswer(ignore());
  when(() => ops.doPaymentStatusChanged(any())).thenAnswer(ignore());
  when(() => ops.doProductsChanged(any())).thenAnswer(ignore());

  when(() => ops.doArePaymentsAvailable()).thenAnswer((_) async {
    return true;
  });

  when(() => ops.doFetchProducts()).thenAnswer((_) async {
    return [
      Product(
          id: 'id1',
          title: 'Product 1',
          description: 'Desc 1',
          price: '9.99',
          pricePerMonth: '9.99',
          periodMonths: 1,
          type: 'cloud',
          trial: 7,
          owned: false),
    ];
  });

  when(() => ops.doPurchaseWithReceipts(any())).thenAnswer((_) async {
    return ["mocked-receipt"];
  });

  when(() => ops.doRestoreWithReceipts()).thenAnswer((_) async {
    return ["mocked-receipt"];
  });

  when(() => ops.doChangeProductWithReceipt(any())).thenAnswer((_) async {
    return "mocked-receipt";
  });
}
