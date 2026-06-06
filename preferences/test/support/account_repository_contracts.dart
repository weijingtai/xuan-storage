// 与接口包 test/support 保持同步;第 2 个后端消费方出现时合并为 dev-only test-support 包

import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_account/repository_interface_account.dart';

Future<void> verifyAccountSessionRepositoryContract(
  AccountSessionRepository Function() create,
) async {
  final repo = create();
  final s = AccountSession(
    appUserId: const AccountUserId('app-1'),
    providerUserId: const ProviderUserId('prov-1'),
    kind: AccountKind.registered,
    providerId: 'firebase',
    issuedAt: DateTime.utc(2026, 1, 1),
  );
  // C1 往返
  await repo.saveCurrentSession(s);
  expect(await repo.getCurrentSession(), equals(s));
  // C2 覆盖写
  final s2 = AccountSession(
    appUserId: const AccountUserId('app-2'),
    providerUserId: const ProviderUserId('prov-2'),
    kind: AccountKind.anonymous,
    providerId: 'firebase',
    issuedAt: DateTime.utc(2026, 2, 2),
  );
  await repo.saveCurrentSession(s2);
  expect(await repo.getCurrentSession(), equals(s2));
  // C3 clear
  await repo.clearCurrentSession();
  expect(await repo.getCurrentSession(), isNull);
}

Future<void> verifyAccountPreferenceRepositoryContract(
  AccountPreferenceRepository Function() create,
) async {
  final repo = create();
  const u = AccountUserId('app-1');
  // P1 缺省
  expect((await repo.getPreferences(u)), equals(const AccountPreferences(appUserId: u)));
  // P2 往返
  const p = AccountPreferences(
    appUserId: u,
    syncEnabled: false,
    privacyMode: true,
    locale: 'zh',
    timeZone: 'Asia/Shanghai',
  );
  await repo.savePreferences(p);
  expect(await repo.getPreferences(u), equals(p));
  // P3 多用户隔离
  const u2 = AccountUserId('app-2');
  expect(await repo.getPreferences(u2), equals(const AccountPreferences(appUserId: u2)));
}

Future<void> verifyAccountIdentityLinkRepositoryContract(
  AccountIdentityLinkRepository Function() create,
) async {
  final repo = create();
  final link = AccountIdentityLink(
    anonymousAppUserId: const AccountUserId('anon-1'),
    registeredAppUserId: const AccountUserId('reg-1'),
    providerId: 'firebase',
    linkedAt: DateTime.utc(2026, 1, 1),
  );
  await repo.saveLink(link);
  expect(await repo.getByAnonymousUserId(const AccountUserId('anon-1')), equals(link));
  expect(await repo.getByRegisteredUserId(const AccountUserId('reg-1')), equals(link));
  expect(await repo.getByAnonymousUserId(const AccountUserId('missing')), isNull);
}

Future<void> verifyAccountAuthGatewayContract(
  AccountAuthGateway Function() create,
) async {
  final gw = create();
  expect((await gw.signInAnonymously()).kind, AccountKind.anonymous);
  expect(
    (await gw.signInWithEmailPassword(email: 'a@b.com', password: 'x')).kind,
    AccountKind.registered,
  );
}
