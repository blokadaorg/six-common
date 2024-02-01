import 'package:common/fsm/api/api.dart';
import 'package:common/fsm/machine.dart';
import 'package:common/util/act.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools.dart';
// @GenerateNiceMocks([
//   MockSpec<HttpService>(),
//   MockSpec<AccountStore>(),
// ])

void main() {
  group("api", () {
    test("basic", () async {
      final act =
          ActScreenplay(ActScenario.platformIsMocked, Flavor.og, Platform.ios);

      final subject = ApiActor(act);
      subject.injectHttp((it) async {
        subject.onHttpOk("result");
        //subject.onHttpFail(Exception("error 303"));
      });
      await subject.onQueryParams({"account_id": "123"});

      final result = await subject
          .doRequest(const HttpRequest(url: "https://example.com/"));
      expect(result.result, "result");
    });
  });
}
