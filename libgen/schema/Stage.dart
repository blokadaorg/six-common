import 'package:pigeon/pigeon.dart';

enum StageModal {
  help,
  perms,
  onboardingFamily,
  onboardingAccountDecided,
  // pause,
  payment,
  //paymentDetails,
  plusLocationSelect,
  debug,
  debugSharing,
  adsCounterShare,
  custom,
  // updatePrompt,
  // updateOngoing,
  // updateComplete,
  fault,
  faultLocked,
  faultLockInvalid,
  faultLinkAlready,
  accountChange,
  accountLink,
  accountInitFailed,
  accountRestoreFailed,
  accountRestoreIdOk,
  accountRestoreIdFailed,
  accountExpired,
  accountInvalid,
  plusTooManyLeases,
  plusVpnFailure,
  paymentUnavailable,
  paymentTempUnavailable,
  paymentFailed,
  deviceAlias,
  lock,
  rate,
  crash
}

@HostApi()
abstract class StageOps {
  @async
  void doShowModal(StageModal modal);

  @async
  void doDismissModal();

  @async
  void doRouteChanged(String path);

  @async
  void doShowNavbar(bool show);

  @async
  void doOpenLink(String url);

  @async
  void doHomeReached();
}

@FlutterApi()
abstract class StageEvents {
  @async
  void onForeground();

  @async
  void onBackground();

  @async
  void onRoute(String path);

  // TODO: Change to enum once supported
  @async
  void onModalShow(String modal);

  @async
  void onModalShown(String modal);

  @async
  void onModalDismiss();

  @async
  void onModalDismissed();
}
