import 'dart:convert';

import 'package:common/account/account.dart';
import 'package:common/custom/json.dart';
import 'package:common/http/http.dart';
import 'package:common/json/json.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tools.dart';
import 'fixtures.dart';
@GenerateNiceMocks([
  MockSpec<HttpService>(),
  MockSpec<AccountStore>(),
])
import 'json_test.mocks.dart';

void main() {
  group("jsonEndpoint", () {
    test("willParseJson", () async {
      await withTrace((m) async {
        final subject =
            JsonCustomEndpoint.fromJson(jsonDecode(fixtureCustomEndpoint));
        final entries = subject.customList;

        expect(entries.isNotEmpty, true);

        final entry = entries.first;

        expect(entry.domainName, "bad.actor.is.bad.com");
        expect(entry.action, "block");
      });
    });
  });

  group("getEntries", () {
    test("willFetchEntries", () async {
      await withTrace((m) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value(fixtureCustomEndpoint));
        depend<HttpService>(http);

        final account = MockAccountStore();
        when(account.id).thenReturn("some-id");
        depend<AccountStore>(account);

        final subject = CustomJson();
        final entries = await subject.getEntries(m);

        expect(entries.isNotEmpty, true);
        expect(entries.first.domainName, "bad.actor.is.bad.com");
      });
    });
  });

  group("errors", () {
    test("willThrowOnInvalidJson", () async {
      await withTrace((m) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value("invalid json"));
        depend<HttpService>(http);

        final account = MockAccountStore();
        when(account.id).thenReturn("some-id");
        depend<AccountStore>(account);

        final subject = CustomJson();

        await expectLater(
            subject.getEntries(m), throwsA(isA<FormatException>()));
      });
    });

    test("fromJsonWillThrowOnInvalidJson", () async {
      await withTrace((m) async {
        await expectLater(
            () => JsonCustomEndpoint.fromJson({}), throwsA(isA<JsonError>()));
      });
    });
  });
}
