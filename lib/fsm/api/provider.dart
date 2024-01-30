import '../../account/account.dart';
import '../../http/channel.act.dart';
import '../../http/channel.pg.dart';
import '../../util/di.dart';
import '../../util/trace.dart';
import '../machine.dart';
import 'api.dart';

class ApiActorProvider with Dependable, TraceOrigin {
  @override
  void attach(Act act) {
    HttpOps ops = getOps(act);

    depend<Query<String, HttpRequest>>((it) async {
      return await ops.doGet(it.url);
    }, tag: "http");

    final account = dep<AccountStore>();

    depend<Query<String, String>>((it) async {
      if (it == "account_id") {
        return account.id;
      } else {
        throw Exception("Unsupported: $it");
      }
    }, tag: "queryParam");
  }
}
