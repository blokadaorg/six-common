import 'package:common/account/account.dart';
import 'package:common/common/model.dart';
import 'package:common/dragon/persistence/persistence.dart';
import 'package:common/dragon/support/controller.dart';
import 'package:common/dragon/value.dart';
import 'package:common/logger/logger.dart';
import 'package:common/scheduler/scheduler.dart';
import 'package:common/stage/channel.pg.dart';
import 'package:common/stage/stage.dart';
import 'package:common/util/di.dart';

class PurchaseTimout with Logging {
  late final _stage = dep<StageStore>();
  late final _support = dep<SupportController>();
  late final _account = dep<AccountStore>();
  late final _scheduler = dep<Scheduler>();
  late final _notified = PurchaseTimeoutNotified();

  bool _userAbandonedPurchase = false;

  load() async {
    _stage.addOnValue(routeChanged, onRouteChanged);
    await _notified.fetch();
  }

  // Send support event when user abandoned purchase
  Future<void> onRouteChanged(StageRouteState route, Marker m) async {
    if (_notified.now) return;

    if (!route.isForeground() && _userAbandonedPurchase) {
      _userAbandonedPurchase = false;
      await _scheduler.addOrUpdate(Job(
        "sendPurchaseTimeout",
        before: DateTime.now().add(const Duration(seconds: 27)),
        m,
        callback: sendPurchaseTimeout,
      ));
      return;
    }

    if (route.modal == null && route.prevModal == StageModal.payment) {
      log(m).i("User abandoned purchase");
      _userAbandonedPurchase = true;
    }
  }

  Future<bool> sendPurchaseTimeout(Marker m) async {
    if (_account.type.isActive()) return false;
    await _support.sendEvent(SupportEvent.purchaseTimeout, m);
    //_notified.now = true;
    return false;
  }
}

class PurchaseTimeoutNotified extends AsyncValue<bool> {
  late final _persistence = dep<Persistence>();

  static const key = "purchase_timeout_notified";

  @override
  Future<bool> doLoad() async {
    return (await _persistence.load(key)) == "1";
  }

  @override
  doSave(bool value) async {
    await _persistence.save(key, value ? "1" : "0");
  }
}