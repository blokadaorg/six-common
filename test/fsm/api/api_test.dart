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
  group("ApiActor", () {
    test("basic", () async {
      final subject = ApiActor(mockedAct);
      subject.injectHttp((it) async {
        subject.onHttpOk("result");
      });
      await subject.onQueryParams({});

      final result = await subject
          .doRequest(const HttpRequest(url: "https://example.com/"));
      expect(result.result, "result");
    });

    test("failingRequest", () async {
      final error = Exception("error");
      final subject = ApiActor(mockedAct);
      subject.injectHttp((it) async {
        subject.onHttpFail(error);
      });
      await subject.onQueryParams({});

      final result = await subject
          .doRequest(const HttpRequest(url: "https://example.com/"));
      expect(result.error, error);
    });

    test("queryParamsMissing", () async {
      final subject = ApiActor(mockedAct);
      subject.injectHttp((it) async {
        subject.onHttpOk("result");
      });
      await subject.onQueryParams({});

      final result = await subject.doApiRequest(ApiEndpoint.getList);
      expect(result.result, null);
    });

    test("apiRequest2", () async {
      final subject = ApiActor(mockedAct);
      subject.injectHttp((it) async {
        subject.onHttpOk("result");
      });
      await subject.onQueryParams({});

      await subject.waitForState("ready");
      final result = await subject.doApiRequest(ApiEndpoint.getList);
      //expect(result.error != null, true);
      expect(result.result, null);
    });
  });
}
