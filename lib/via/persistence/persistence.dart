import 'package:vistraced/via.dart';

import '../../fsm/device/json.dart';
import '../actions.dart';

part 'persistence.g.dart';

@ViaModule([
  InjectedVia(doPersistence, ViaBase<String>, ViaPersistence<String>),
  InjectedVia(
      doPersistence, ViaBase<JsonDevice?>, ViaPersistence<JsonDevice?>),
])
class PersistenceModule extends _$PersistenceModule {}

@Injected()
class ViaPersistence<T> extends ViaBase<T> {
  @override
  Future<T> get() async {
    if (type == String) return "3" as T;
    throw Exception("not implemented");
  }

  @override
  Future<void> set(T value) async {}
}
