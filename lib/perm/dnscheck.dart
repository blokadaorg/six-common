import 'dart:io';

import 'package:common/common/model.dart';
import 'package:common/logger/logger.dart';

class PrivateDnsCheck with Logging {
  bool isCorrect(Marker m, String line, DeviceTag tag, String alias) {
    log(m).pair("current dns", line);

    var expected = _getIosPrivateDnsString(m, tag, alias);

    if (Platform.isAndroid) {
      expected = _getAndroidPrivateDnsString(m, tag, alias);
    }

    return line == expected;
  }

  String _getIosPrivateDnsString(Marker m, DeviceTag tag, String alias) {
    try {
      final name = _escapeAlias(alias);
      return "https://cloud.blokada.org/$tag/$name";
    } catch (e) {
      log(m).e(msg: "getIosPrivatDnsString", err: e);
      return "";
    }
  }

  String _getAndroidPrivateDnsString(Marker m, DeviceTag tag, String alias) {
    try {
      final name = _sanitizeAlias(alias);
      return "$name-$tag.cloud.blokada.org";
    } catch (e) {
      log(m).e(msg: "getAndroidPrivateDnsString", err: e);
      return "";
    }
  }

  String _sanitizeAlias(String alias) {
    var a = alias.trim().replaceAll(" ", "--");
    if (a.length > 56) a = a.substring(0, 56);
    return a;
  }

  String _escapeAlias(String alias) {
    // TODO: implement
    return alias.trim();
  }
}
