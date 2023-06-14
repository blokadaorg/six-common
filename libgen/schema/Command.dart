import 'package:pigeon/pigeon.dart';

enum CommandName {
  // Account
  restore,

  // AccountPayment
  receipt,
  fetchProducts,
  purchase,
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
  enableList,
  disableList,
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
}

@HostApi()
abstract class CommandOps {
  @async
  void doCanAcceptCommands();
}

@FlutterApi()
abstract class Commands {
  @async
  void onCommand(String command);

  @async
  void onCommandWithParam(String command, String p1);

  @async
  void onCommandWithParams(String command, String p1, String p2);
}