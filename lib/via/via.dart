import 'package:vistraced/via.dart';

import '../common/model.dart';
import 'actions.dart';

part 'via.g.dart';

@Module([DirectVia<UserFilterConfig>])
class ViasModule extends _$ViasModule {}

@Injected()
class DirectVia<T> extends ViaBase<T> {
  @override
  Future<T> get() async => value as T;

  @override
  Future<void> set(T value) async {}
}

@ViaModule([
  InjectedVia(doDirect, ViaBase<UserFilterConfig>, DirectVia<UserFilterConfig>),
])
class DeviceFilterLink extends _$DeviceFilterLink {}
