import 'package:common/dragon/value.dart';

import '../../common/model.dart';
import '../../util/di.dart';
import '../persistence/persistence.dart';

class ThisDevice extends NullableValue<JsonDevice> {
  late final _persistence = dep<Persistence>();
  late final _marshal = JsonDeviceMarshal();

  static const key = "this_device";

  @override
  Future<JsonDevice?> doLoad() async {
    final response = await _persistence.load(key);
    if (response == null) return null;
    return _marshal.toDeviceDirect(response);
  }

  @override
  doSave(JsonDevice? value) async {
    if (value == null) {
      await _persistence.delete(key);
      return;
    }
    await _persistence.save(key, _marshal.fromDeviceDirect(value));
  }
}
