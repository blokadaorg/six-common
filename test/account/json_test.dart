import 'dart:convert';

import 'package:common/account/json.dart';
import 'package:common/http/http.dart';
import 'package:common/json/json.dart';
import 'package:common/util/di.dart';
import 'package:common/util/trace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tools.dart';

import 'fixtures.dart';
@GenerateNiceMocks([
  MockSpec<HttpService>(),
])
import 'json_test.mocks.dart';

void main() {
  group("getAccount", () {
    test("willFetchAccount", () async {
      await withTrace((trace) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value(fixtureJsonEndpoint));
        depend<HttpService>(http);

        final subject = AccountJson();
        final account = await subject.getAccount(trace, "some-id");

        expect(account.type, "cloud");
        expect(account.active, true);
        expect(account.activeUntil, "2023-01-23T06:46:37.790654Z");
      });
    });
  });

  group("postAccount", () {
    test("willCallPostMethod", () async {
      await withTrace((trace) async {
        final http = MockHttpService();
        when(http.request(any, any, any))
            .thenAnswer((_) => Future.value(fixtureJsonEndpoint));
        depend<HttpService>(http);

        final subject = AccountJson();
        final account = await subject.postAccount(trace);

        verify(http.request(any, any, any)).called(1);
        expect(account.id, "mockedmocked");
      });
    });
  });

  group("jsonAccount", () {
    test("willParseJson", () async {
      await withTrace((trace) async {
        final subject = JsonAccount.fromJson(jsonDecode(fixtureJsonAccount));

        expect(subject.id, "mockedmocked");
        expect(subject.activeUntil, "2023-01-23T06:46:37.790654Z");
        expect(subject.active, true);
        expect(subject.type, "cloud");
        expect(subject.paymentSource, "internal");
        expect(subject.isActive(), true);

        final json = subject.toJson();

        expect(json["id"], "mockedmocked");
        expect(json["active_until"], "2023-01-23T06:46:37.790654Z");
        expect(json["active"], true);
        expect(json["type"], "cloud");
        expect(json["payment_source"], "internal");
      });
    });
  });

  group("errors", () {
    test("willThrowOnInvalidJson", () async {
      await withTrace((trace) async {
        final http = MockHttpService();
        when(http.get(any, any))
            .thenAnswer((_) => Future.value("invalid json"));
        depend<HttpService>(http);

        final subject = AccountJson();

        await expectLater(subject.getAccount(trace, "some-id"),
            throwsA(isA<FormatException>()));
      });
    });

    test("fromJsonWillThrowOnInvalidJson", () async {
      await withTrace((trace) async {
        await expectLater(
            () => JsonAccount.fromJson({}), throwsA(isA<JsonError>()));
      });
    });
  });
}
