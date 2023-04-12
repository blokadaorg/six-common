import 'package:common/account/json.dart';

const fixtureJsonEndpoint = '''{
  "account": $fixtureJsonAccount
}''';

const fixtureJsonAccount = '''{
  "id":"mockedmocked",
  "active_until":"2023-01-23T06:46:37.790654Z",
  "active":true,
  "type":"cloud",
  "payment_source":"internal"
}''';

const fixtureJsonAccount2 = '''{
  "id":"mocked2",
  "active":false,
  "type":"libre"
}''';
