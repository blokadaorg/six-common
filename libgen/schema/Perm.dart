import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class PermOps {
  @async
  bool doIsPrivateDnsEnabled(String tag);

  @async
  void doSetPrivateDnsEnabled(String tag, String alias);

  @async
  void doSetDns(String tag);

  @async
  bool doNotificationEnabled();

  @async
  bool doVpnEnabled();

  @async
  void doOpenSettings();
}
