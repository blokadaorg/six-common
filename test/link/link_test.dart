import 'package:common/account/account.dart';
import 'package:common/env/env.dart';
import 'package:common/link/channel.pg.dart';
import 'package:common/link/link.dart';
import 'package:common/lock/lock.dart';
import 'package:common/util/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tools.dart';
@GenerateNiceMocks([
  MockSpec<LinkOps>(),
  MockSpec<AccountStore>(),
  MockSpec<LockStore>(),
  MockSpec<EnvStore>(),
])
import 'link_test.mocks.dart';

void main() {
  group("store", () {
    test("willUpdateLinksOnLock", () async {
      await withTrace((trace) async {
        depend<AccountStore>(MockAccountStore());
        depend<LockStore>(MockLockStore());

        final env = MockEnvStore();
        when(env.userAgent).thenReturn("mocked user agent");
        depend<EnvStore>(env);

        final ops = MockLinkOps();
        depend<LinkOps>(ops);

        final subject = LinkStore();
        mockAct(subject);
        subject.start(trace);

        await subject.updateLinks(trace, true);

        verify(ops.doLinksChanged(any)).called(1);
      });
    });
  });
}