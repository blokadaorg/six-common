import 'package:common/core/core.dart';
import 'package:common/main-widgets.dart';
import 'package:common/platform/perm/perm.dart';
import 'package:dartx/dartx.dart';

import '../../common/module/lock/lock.dart';
import '../../family/module/family/family.dart';
import '../account/account.dart';
import '../account/payment/payment.dart';
import '../account/refresh/refresh.dart';
import '../app/start/start.dart';
import '../custom/custom.dart';
import '../device/device.dart';
import '../journal/channel.pg.dart' as jour;
import '../journal/journal.dart';
import '../notification/notification.dart';
import '../plus/lease/lease.dart';
import '../plus/plus.dart';
import '../plus/vpn/vpn.dart';
import '../stage/channel.pg.dart';
import '../stage/stage.dart';
import 'channel.act.dart';
import 'channel.pg.dart';

class CommandStore with Logging, Actor implements CommandEvents {
  late final _stage = Core.get<StageStore>();
  late final _account = Core.get<AccountStore>();
  late final _accountPayment = Core.get<AccountPaymentStore>();
  late final _accountRefresh = Core.get<AccountRefreshStore>();
  late final _appStart = Core.get<AppStartStore>();
  late final _custom = Core.get<CustomStore>();
  late final _device = Core.get<DeviceStore>();
  late final _notification = Core.get<NotificationStore>();
  late final _permission = Core.get<PlatformPermActor>();
  late final _scheduler = Core.get<Scheduler>();

  late final _lock = Core.get<LockActor>();

  // V6 only commands
  late final _journal = Core.get<JournalStore>();
  late final _plus = Core.get<PlusStore>();
  late final _plusLease = Core.get<PlusLeaseStore>();
  late final _plusVpn = Core.get<PlusVpnStore>();

  @override
  void onRegister() {
    Core.register<CommandStore>(this);
    if (Core.act.isProd) CommandEvents.setup(this);
    getOps().doCanAcceptCommands();
  }

  final newCommands = ["WARNING", "FATAL"];

  @override
  Future<void> onCommand(String command, Marker m) async {
    for (var cmd in newCommands) {
      if (command.startsWith(cmd)) {
        return await commands.execute(m, command, null);
      }
    }

    final cmd = _commandFromString(command);
    await log(m).trace(_cmdName(command, null), (m) async {
      try {
        return await _execute(cmd, m);
      } catch (e) {
        await commands.execute(m, command, null);
      }
    });
  }

  @override
  Future<void> onCommandWithParam(String command, String p1, Marker m) async {
    for (var cmd in newCommands) {
      if (command.startsWith(cmd)) {
        return await commands.execute(m, command, null);
      }
    }

    final cmd = _commandFromString(command);
    await log(m).trace(_cmdName(command, p1), (m) async {
      try {
        return await _execute(cmd, m, p1: p1);
      } catch (e) {
        await commands.execute(m, command, [p1]);
      }
    });
  }

  @override
  Future<void> onCommandWithParams(
      String command, String p1, String p2, Marker m) async {
    for (var cmd in newCommands) {
      if (command.startsWith(cmd)) {
        return await commands.execute(m, command, null);
      }
    }

    final cmd = _commandFromString(command);
    await log(m).trace(_cmdName(command, p1), (m) async {
      try {
        return await _execute(cmd, m, p1: p1, p2: p2);
      } catch (e) {
        await commands.execute(m, command, [p1, p2]);
      }
    });
  }

  onCommandString(String command, Marker m) async {
    return await log(m).trace("onCommandString", (m) async {
      final commandParts = command.split(" ");
      final cmd = _commandFromString(commandParts.first);
      final p1 = commandParts.elementAtOrNull(1);
      final p2 = commandParts.elementAtOrNull(2);
      return await _execute(cmd, m, p1: p1, p2: p2);
    });
  }

  _execute(CommandName cmd, Marker m, {String? p1, String? p2}) async {
    switch (cmd) {
      case CommandName.url:
        _ensureParam(p1);
        return await _executeUrl(p1!, m);
      case CommandName.restore:
        _ensureParam(p1);
        await _account.restore(p1!, m);
        return await _accountRefresh.syncAccount(_account.account, m);
      case CommandName.account:
        return _account.account?.id;
      case CommandName.receipt:
        _ensureParam(p1);
        await _accountPayment.restoreInBackground(p1!, m);
        return await _accountRefresh.syncAccount(_account.account, m);
      case CommandName.fetchProducts:
        return await _accountPayment.fetchProducts(m);
      case CommandName.purchase:
        _ensureParam(p1);
        await _accountPayment.purchase(p1!, m);
        return await _accountRefresh.syncAccount(_account.account, m);
      case CommandName.changeProduct:
        _ensureParam(p1);
        await _accountPayment.changeProduct(p1!, m);
        return await _accountRefresh.syncAccount(_account.account, m);
      case CommandName.restorePayment:
        // TODO:
        // Only restore implicitly if current account is not active
        // TODO: finish ongoing transaction after any success or fail (stop processing)
        await _accountPayment.restore(m);
        return await _accountRefresh.syncAccount(_account.account, m);
      case CommandName.pause:
        return await _appStart.pauseAppIndefinitely(m);
      case CommandName.unpause:
        return await _appStart.unpauseApp(m);
      case CommandName.allow:
        _ensureParam(p1);
        return await _custom.allow(p1!, m);
      case CommandName.deny:
        _ensureParam(p1);
        return await _custom.deny(p1!, m);
      case CommandName.delete:
        _ensureParam(p1);
        return await _custom.delete(p1!, m);
      case CommandName.enableCloud:
        return await _device.setCloudEnabled(true, m);
      case CommandName.disableCloud:
        return await _device.setCloudEnabled(false, m);
      case CommandName.setRetention:
        _ensureParam(p1);
        return await _device.setRetention(p1!, m);
      case CommandName.setSafeSearch:
        _ensureParam(p1);
        //return await _device.setSafeSearch(p1 == "1");
        throw Exception("Not implemented WIP");
      case CommandName.deviceAlias:
        _ensureParam(p1);
        //return await _family.renameThisDevice(p1!);
        throw Exception("Not implemented WIP");
      case CommandName.sortNewest:
        return await _journal.updateFilter(sortNewestFirst: true, m);
      case CommandName.sortCount:
        return await _journal.updateFilter(sortNewestFirst: false, m);
      case CommandName.search:
        return await _journal.updateFilter(searchQuery: p1, m);
      case CommandName.filter:
        _ensureParam(p1);
        return await _journal.updateFilter(
            showOnly: jour.JournalFilterType.values.byName(p1!), m);
      case CommandName.filterDevice:
        return await _journal.updateFilter(deviceName: p1, m);
      case CommandName.newPlus:
        _ensureParam(p1);
        return await _plus.newPlus(p1!, m);
      case CommandName.clearPlus:
        return await _plus.clearPlus(m);
      case CommandName.activatePlus:
        return await _plus.switchPlus(true, m);
      case CommandName.deactivatePlus:
        return await _plus.switchPlus(false, m);
      case CommandName.deleteLease:
        _ensureParam(p1);
        return await _plusLease.deleteLeaseById(p1!, m);
      case CommandName.vpnStatus:
        _ensureParam(p1);
        return await _plusVpn.setActualStatus(p1!, m);
      case CommandName.foreground:
        return await _stage.setForeground(m);
      case CommandName.background:
        return await _stage.setBackground(m);
      case CommandName.route:
        _ensureParam(p1);
        return await _stage.setRoute(p1!, m);
      case CommandName.modalShow:
        _ensureParam(p1);
        return await _stage.showModal(_modalFromString(p1!), m);
      case CommandName.modalShown:
        _ensureParam(p1);
        return await _stage.modalShown(_modalFromString(p1!), m);
      case CommandName.modalDismiss:
        return await _stage.dismissModal(m);
      case CommandName.modalDismissed:
        return await _stage.modalDismissed(m);
      case CommandName.setPin:
        _ensureParam(p1);
        await _lock.lock(m, p1!);
        return await _stage.setRoute("home", m);
      case CommandName.back:
        return await _stage.back();
      case CommandName.unlock:
        _ensureParam(p1);
        return await _lock.unlock(m, p1!);
      case CommandName.remoteNotification:
        return await _accountRefresh.onRemoteNotification(m);
      case CommandName.appleNotificationToken:
        _ensureParam(p1);
        return await _notification.saveAppleToken(p1!, m);
      case CommandName.notificationTapped:
        _ensureParam(p1);
        return await _notification.notificationTapped(p1!, m);
      case CommandName.crashLog:
        //return await _tracer.checkForCrashLog(force: true, m);
        return;
      case CommandName.canPromptCrashLog:
        //return await _tracer.canPromptCrashLog(p1 == "1", m);
        return false;
      case CommandName.debugHttpFail:
        _ensureParam(p1);
        Core.config.debugFailingRequests.add(p1!);
        return;
      case CommandName.debugHttpOk:
        _ensureParam(p1);
        Core.config.debugFailingRequests.remove(p1!);
        return;
      case CommandName.debugOnboard:
        // await _account.restore("mockedmocked");
        // await _device.setLinkedTag(null);
        // return await _family.deleteAllDevices;
        throw Exception("Not implemented WIP");
      case CommandName.debugBg:
        Core.config.debugBg = !Core.config.debugBg;
        return;
      case CommandName.setFlavor:
        return;
      case CommandName.mock:
        _ensureParam(p1);
        // await mockCommands.handleCommand("$p1 ${p2 ?? ""}");
        throw Exception("Not implemented WIP");
        return;
      case CommandName.s:
        _ensureParam(p1);
        final scenarios = {
          "start": [
            "mock appstatus reconfiguring",
            "mock appstatus paused",
            "mock phase fresh",
          ],
          "devices": [
            "mock appstatus reconfiguring",
            "mock appstatus paused",
            "mock phase parentHasDevices",
          ],
        };
        final scenario = scenarios[p1];
        if (scenario != null) {
          for (var cmd in scenario) {
            await onCommandString(cmd, m);
            await sleepAsync(const Duration(seconds: 1));
          }
        } else {
          throw ArgumentError("Unknown scenario: $p1");
        }
      case CommandName.ws:
        _ensureParam(p1);
        final ws = Core.get<DevWebsocket>();
        ws.ip = p1!;
        ws.handle();
        return;
      case CommandName.supportAskNotificationPerms:
        return await _permission.askNotificationPermissions(m);
      case CommandName.schedulerPing:
        await _scheduler.pingFromBackground(m);
        return;
      default:
        throw Exception("Unsupported command: $cmd");
    }
  }

  _executeUrl(String url, Marker m) async {
    try {
      // Family link device
      if (url.startsWith(familyLinkBase)) {
        final tag = url.split("tag=").last.split("&").first.trim();
        final name = url.split("name=").last.urlDecode.trim();
        if (tag.isEmpty || name.isEmpty) {
          throw Exception("Unknown familyLink token parameters");
        }

        return await _execute(CommandName.familyLink, m, p1: tag, p2: name);
      } else {
        throw Exception("Unsupported url: $url");
      }
    } catch (e) {
      await _stage.showModal(StageModal.fault, m);
      rethrow;
    }
  }

  _ensureParam(String? p1) {
    if (p1 == null) throw Exception("Missing parameter");
  }

  final _censoredCommands = [
    CommandName.restore.name,
    CommandName.receipt.name,
    CommandName.appleNotificationToken.name,
  ];

  final _noTimeLimitCommands = [
    CommandName.newPlus.name,
    CommandName.receipt.name,
    CommandName.restorePayment.name,
    CommandName.purchase.name,
  ];

  String _cmdName(String cmd, String? p1) {
    if (_censoredCommands.contains(cmd)) {
      p1 = "***";
    }
    return cmd + (p1 != null ? "(${shortString(p1, length: 16)})" : "()");
  }

  String shortString(String s, {int length = 64}) {
    if (s.length > length) {
      return "${s.substring(0, length).replaceAll("\n", "").trim()}[...]";
    } else {
      return s.replaceAll("\n", "").trim();
    }
  }

  final Map<String, CommandName> _lowercaseCommandNames = {
    for (var cmd in CommandName.values) cmd.name.toLowerCase(): cmd,
  };

  CommandName _commandFromString(String command) {
    try {
      return CommandName.values.byName(command);
    } catch (_) {
      try {
        return _lowercaseCommandNames[command.toLowerCase()]!;
      } catch (_) {
        throw ArgumentError("Unknown command: $command");
      }
    }
  }

  final Map<String, StageModal> _lowercaseModals = {
    for (var cmd in StageModal.values) cmd.name.toLowerCase(): cmd,
  };

  StageModal _modalFromString(String command) {
    try {
      return StageModal.values.byName(command);
    } catch (_) {
      try {
        return _lowercaseModals[command.toLowerCase()]!;
      } catch (_) {
        throw ArgumentError("Unknown modal: $command");
      }
    }
  }
}
