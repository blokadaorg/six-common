import 'package:common/account/account.dart' as acc;
import 'package:common/dragon/account/account_id.dart';
import 'package:common/util/di.dart';

class AccountController {
  late final _store = dep<acc.AccountStore>();
  late final _accountId = dep<AccountId>();
  bool _started = false;

  start() async {
    if (_started) return;
    _started = true;

    // TODO: drop this legacy sync class eventually
    _store.addOn(acc.accountChanged, (_) {
      _accountId.now = _store.account!.id;
    });
  }
}
