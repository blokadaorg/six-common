import 'package:pigeon/pigeon.dart';

enum CommandName {
  // Config
  setFlavor,

  // Account
  restore,

  // AccountPayment
  receipt,
  fetchProducts,
  purchase,
  changeProduct,
  restorePayment,

  // AppStart
  pause,
  unpause,

  // Custom
  allow,
  deny,
  delete,

  // Deck
  enableDeck,
  disableDeck,
  toggleListByTag,

  // Device
  enableCloud,
  disableCloud,
  setRetention,

  // Journal
  sortNewest,
  sortCount,
  search,
  filter,
  filterDevice,

  // Notification,
  remoteNotification,
  appleNotificationToken,

  // Plus
  newPlus,
  clearPlus,
  activatePlus,
  deactivatePlus,

  // PlusLease
  deleteLease,

  // PlusVpn
  vpnStatus,

  // Stage
  foreground,
  background,
  route,
  modalShow,
  modalShown,
  modalDismiss,
  modalDismissed,

  // Tracer
  fatal,
  warning,
  log,
  crashLog,
  canPromptCrashLog,

  // Debug
  debugHttpFail,
  debugHttpOk,
  debugOnboard,
}

@HostApi()
abstract class CommandOps {
  @async
  void doCanAcceptCommands();
}

@FlutterApi()
abstract class CommandEvents {
  @async
  void onCommand(String command);

  @async
  void onCommandWithParam(String command, String p1);

  @async
  void onCommandWithParams(String command, String p1, String p2);
}
