part of 'api.dart';

class AccountId extends AsyncValue<String> {}

class BaseUrl extends Value<String> {
  BaseUrl()
      : super(load: () {
          return DI.act.isFamily
              ? "https://family.api.blocka.net/"
              : "https://api.blocka.net/";
        });
}

class ApiRetryDuration extends Value<Duration> {
  ApiRetryDuration()
      : super(load: () {
          return Duration(seconds: DI.act.isProd ? 3 : 0);
        });
}

class UserAgent extends AsyncValue<String> {}
