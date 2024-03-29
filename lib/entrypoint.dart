import 'account/account.dart';
import 'account/payment/payment.dart';
import 'account/refresh/refresh.dart';
import 'app/app.dart';
import 'app/start/start.dart';
import 'command/command.dart';
import 'custom/custom.dart';
import 'deck/deck.dart';
import 'device/device.dart';
import 'env/env.dart';
import 'family/family.dart';
import 'fsm/filter/filter.dart';
import 'http/http.dart';
import 'journal/journal.dart';
import 'link/link.dart';
import 'lock/lock.dart';
import 'notification/notification.dart';
import 'perm/perm.dart';
import 'persistence/persistence.dart';
import 'plus/gateway/gateway.dart';
import 'plus/keypair/keypair.dart';
import 'plus/lease/lease.dart';
import 'plus/plus.dart';
import 'plus/vpn/vpn.dart';
import 'rate/rate.dart';
import 'stage/stage.dart';
import 'stats/refresh/refresh.dart';
import 'stats/stats.dart';
import 'timer/timer.dart';
import 'ui/notfamily/home/home.dart';
import 'util/config.dart';
import 'util/di.dart';
import 'util/trace.dart';
import 'tracer/tracer.dart';

class Entrypoint with Dependable, TraceOrigin, Traceable {
  late final _appStart = dep<AppStartStore>();

  @override
  attach(Act act) {
    cfg.act = act;

    Tracer().attachAndSaveAct(act);
    DefaultTimer().attachAndSaveAct(act);

    PlatformPersistence(isSecure: false).attachAndSaveAct(act);
    final secure = PlatformPersistence(isSecure: true);
    depend<SecurePersistenceService>(secure);

    if (act.hasToys()) {
      RepeatingHttpService(
        DebugHttpService(PlatformHttpService()),
        maxRetries: cfg.httpMaxRetries,
        waitTime: cfg.httpRetryDelay,
      ).attachAndSaveAct(act);
    } else {
      RepeatingHttpService(
        PlatformHttpService(),
        maxRetries: cfg.httpMaxRetries,
        waitTime: cfg.httpRetryDelay,
      ).attachAndSaveAct(act);
    }

    // The stores. Order is important
    EnvStore().attachAndSaveAct(act);
    StageStore().attachAndSaveAct(act);
    AccountStore().attachAndSaveAct(act);
    NotificationStore().attachAndSaveAct(act);
    AccountPaymentStore().attachAndSaveAct(act);
    AccountRefreshStore().attachAndSaveAct(act);
    DeviceStore().attachAndSaveAct(act);

    final filter = FilterActor(act);
    depend(filter);

    AppStore().attachAndSaveAct(act);
    AppStartStore().attachAndSaveAct(act);
    PermStore().attachAndSaveAct(act);
    LockStore().attachAndSaveAct(act);
    CustomStore().attachAndSaveAct(act);
    //DeckStore().attachAndSaveAct(act);
    JournalStore().attachAndSaveAct(act);
    PlusStore().attachAndSaveAct(act);
    PlusKeypairStore().attachAndSaveAct(act);
    PlusGatewayStore().attachAndSaveAct(act);
    PlusLeaseStore().attachAndSaveAct(act);
    PlusVpnStore().attachAndSaveAct(act);
    StatsStore().attachAndSaveAct(act);
    StatsRefreshStore().attachAndSaveAct(act);
    FamilyStore(act).attachAndSaveAct(act);
    HomeStore().attachAndSaveAct(act);
    RateStore().attachAndSaveAct(act);
    CommandStore().attachAndSaveAct(act);
    LinkStore().attachAndSaveAct(act);

    depend<Entrypoint>(this);
  }

  Future<void> onStartApp() async {
    await traceAs("onStartApp", (trace) async {
      await _appStart.startApp(trace);
    });
  }
}
