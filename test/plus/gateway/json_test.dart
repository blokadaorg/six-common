import 'dart:convert';

import 'package:common/env/env.dart';
import 'package:common/http/http.dart';
import 'package:common/json/json.dart';
import 'package:common/plus/gateway/json.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../tools.dart';
import 'fixtures.dart';
@GenerateNiceMocks([
  MockSpec<HttpService>(),
])
import 'json_test.mocks.dart';

void main() {
  group("jsonEndpoint", () {
    test("willParseJson", () async {
      await withTrace((trace) async {
        final subject =
            JsonGatewayEndpoint.fromJson(jsonDecode(fixtureGatewayEndpoint));
        final entries = subject.gateways;

        expect(entries.isNotEmpty, true);

        final entry = entries.first;

        expect(entry.region, "europe-west1");
        expect(entry.country, "ES");
      });
    });
  });

  group("getEntries", () {
    test("willFetchEntries", () async {
      await withTrace((trace) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value(fixtureGatewayEndpoint));
        di.registerSingleton<HttpService>(http);

        final env = EnvStore();
        env.setAccountId(trace, "some-id");
        di.registerSingleton<EnvStore>(env);

        final subject = PlusGatewayJson();
        final entries = await subject.get(trace);

        expect(entries.isNotEmpty, true);
        expect(entries.first.region, "europe-west1");
      });
    });
  });

  group("errors", () {
    test("willThrowOnInvalidJson", () async {
      await withTrace((trace) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value("invalid json"));
        di.registerSingleton<HttpService>(http);

        final env = EnvStore();
        env.setAccountId(trace, "some-id");
        di.registerSingleton<EnvStore>(env);

        final subject = PlusGatewayJson();

        await expectLater(subject.get(trace), throwsA(isA<FormatException>()));
      });
    });

    test("fromJsonWillThrowOnInvalidJson", () async {
      await withTrace((trace) async {
        await expectLater(
            () => JsonGatewayEndpoint.fromJson({}), throwsA(isA<JsonError>()));
      });
    });
  });
}
