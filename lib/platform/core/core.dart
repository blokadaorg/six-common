import 'package:common/core/core.dart';
import 'package:common/platform/core/channel.pg.dart';

part 'channel.dart';

class PlatformCoreModule with Logging, Module {
  @override
  onCreateModule() async {
    CoreChannel channel;

    if (Core.act.isProd) {
      channel = PlatformCoreChannel();
    } else {
      channel = RuntimeCoreChannel();
    }

    await register<PersistenceChannel>(channel);
  }
}
