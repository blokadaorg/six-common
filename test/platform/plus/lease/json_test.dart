import 'dart:convert';

import 'package:common/core/core.dart';
import 'package:common/platform/account/account.dart';
import 'package:common/platform/http/http.dart';
import 'package:common/platform/plus/lease/json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../tools.dart';
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
            JsonLeaseEndpoint.fromJson(jsonDecode(fixtureLeaseEndpoint));
        final entries = subject.leases;

        expect(entries.isNotEmpty, true);

        final entry = entries.first;

        expect(entry.vip4, "10.143.0.142");
        expect(entry.alias, "Solar quokka");
      });
    });
  });

  group("getEntries", () {
    test("willFetchEntries", () async {
      await withTrace((m) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value(fixtureLeaseEndpoint));
        Core.register<HttpService>(http);

        final account = MockAccountStore();
        when(account.id).thenReturn("some-id");
        Core.register<AccountStore>(account);

        final subject = PlusLeaseJson();
        final entries = await subject.getLeases(m);

        expect(entries.isNotEmpty, true);
        expect(entries.first.alias, "Solar quokka");
      });
    });
  });

  group("errors", () {
    test("willThrowOnInvalidJson", () async {
      await withTrace((m) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value("invalid json"));
        Core.register<HttpService>(http);

        final account = MockAccountStore();
        when(account.id).thenReturn("some-id");
        Core.register<AccountStore>(account);

        final subject = PlusLeaseJson();

        await expectLater(
            subject.getLeases(m), throwsA(isA<FormatException>()));
      });
    });

    test("fromJsonWillThrowOnInvalidJson", () async {
      await withTrace((m) async {
        await expectLater(
            () => JsonLeaseEndpoint.fromJson({}), throwsA(isA<JsonError>()));
      });
    });
  });
}
