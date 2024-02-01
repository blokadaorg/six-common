import '../account/account.dart';
import '../device/device.dart';
import '../http/channel.pg.dart';
import '../util/di.dart';
import 'api/api.dart';
import 'filter/filter.dart';
import 'machine.dart';

// Query<String, ApiEndpoint> api(Put<String> log) => (it) async {
//       return (await ApiActor().doApiRequest(it)).result!;
//     };
//
// Get<UserLists> userLists() => () async {
//       return dep<DeviceStore>().lists?.toSet() ?? {};
//     };
//
// Query<String, HttpRequest> http() => (it) async {
//       return await dep<HttpOps>().doGet(it.url);
//     };
//
// Query<String, String> queryParam() => (it) async {
//       if (it == "account_id") {
//         return dep<AccountStore>().id;
//       } else {
//         throw Exception("Unsupported: $it");
//       }
//     };
