import 'package:common/core/core.dart';
import 'package:common/platform/perm/channel.pg.dart';

class OpenPerms {
  late final _ops = DI.get<PermOps>();

  open() async {
    _ops.doOpenSettings();
  }
}
