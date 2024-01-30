import 'package:common/fsm/api/api.dart';
import 'package:common/fsm/api/api.genn.dart';
import 'package:common/fsm/machine.dart';
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
      depend<Query<String, HttpRequest>>((it) async {
        return "result";
      }, tag: "http");

      final subject = ApiActor();

      final result =
          await subject.request(const HttpRequest(url: "https://example.com/"));
      expect(result, "result");
    });
  });
}
