import 'package:pigeon/pigeon.dart';

enum StageModal {
  help,
  onboarding,
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
  accountInitFailed,
  accountRestoreFailed,
  accountExpired,
  accountInvalid,
  plusTooManyLeases,
  plusVpnFailure,
  paymentUnavailable,
  paymentTempUnavailable,
  paymentFailed,
}

enum StageKnownRoute {
  homeStats,
  homeOverlayLock,
  homeOverlayRate,
  homeOverlayCrash,
  homeCloseOverlay,
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
