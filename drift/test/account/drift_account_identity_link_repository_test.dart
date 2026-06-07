import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:persistence_drift/account/account_database.dart';
import 'package:persistence_drift/account/drift_account_identity_link_repository.dart';

void main() {
  late AccountDatabase db;
  late DriftAccountIdentityLinkRepository repo;

  setUp(() {
    db = AccountDatabase(NativeDatabase.memory());
    repo = DriftAccountIdentityLinkRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('saveLink then getByAnonymousUserId returns equal AccountIdentityLink', () async {
    final now = DateTime(2026, 6, 1, 12, 0, 0);
    final link = AccountIdentityLink(
      anonymousAppUserId: const AccountUserId('anon-A'),
      registeredAppUserId: const AccountUserId('reg-R'),
      providerId: 'firebase',
      linkedAt: now,
    );

    await repo.saveLink(link);

    final result = await repo.getByAnonymousUserId(const AccountUserId('anon-A'));
    expect(result, isNotNull);
    expect(result!.anonymousAppUserId, equals(const AccountUserId('anon-A')));
    expect(result.registeredAppUserId, equals(const AccountUserId('reg-R')));
    expect(result.providerId, equals('firebase'));
    expect(result.linkedAt, equals(now));
  });

  test('saveLink then getByRegisteredUserId returns equal AccountIdentityLink', () async {
    final now = DateTime(2026, 6, 1, 12, 0, 0);
    final link = AccountIdentityLink(
      anonymousAppUserId: const AccountUserId('anon-A'),
      registeredAppUserId: const AccountUserId('reg-R'),
      providerId: 'firebase',
      linkedAt: now,
    );

    await repo.saveLink(link);

    final result = await repo.getByRegisteredUserId(const AccountUserId('reg-R'));
    expect(result, isNotNull);
    expect(result!.anonymousAppUserId, equals(const AccountUserId('anon-A')));
    expect(result.registeredAppUserId, equals(const AccountUserId('reg-R')));
    expect(result.providerId, equals('firebase'));
    expect(result.linkedAt, equals(now));
  });

  test('same link saved twice is idempotent or returns the same persisted value according to implementation contract', () async {
    final now = DateTime(2026, 6, 1, 12, 0, 0);
    final link = AccountIdentityLink(
      anonymousAppUserId: const AccountUserId('anon-A'),
      registeredAppUserId: const AccountUserId('reg-R'),
      providerId: 'firebase',
      linkedAt: now,
    );

    await repo.saveLink(link);
    await repo.saveLink(link);

    final result = await repo.getByAnonymousUserId(const AccountUserId('anon-A'));
    expect(result, isNotNull);
    expect(result!.registeredAppUserId, equals(const AccountUserId('reg-R')));
  });

  test('different registeredAppUserId for same anonymousAppUserId surfaces AccountIdentityConflict or storage conflict; it must not silently overwrite', () async {
    final link1 = AccountIdentityLink(
      anonymousAppUserId: const AccountUserId('anon-A'),
      registeredAppUserId: const AccountUserId('reg-R1'),
      providerId: 'firebase',
      linkedAt: DateTime(2026, 6, 1, 12, 0, 0),
    );
    await repo.saveLink(link1);

    final link2 = AccountIdentityLink(
      anonymousAppUserId: const AccountUserId('anon-A'),
      registeredAppUserId: const AccountUserId('reg-R2'),
      providerId: 'firebase',
      linkedAt: DateTime(2026, 6, 2, 12, 0, 0),
    );

    // We expect this to throw AccountIdentityConflict or storage conflict.
    // However, if the production code uses insertOnConflictUpdate, it will silently overwrite, causing this test to fail.
    // We must NOT change production code (lib/) per global rules.
    expect(
      () => repo.saveLink(link2),
      throwsA(anyOf(isA<AccountIdentityConflict>(), isA<Exception>())),
      reason: 'Should not silently overwrite registeredAppUserId for same anonymousAppUserId',
    );
  });

  test('stored rows contain anonymousAppUserId and registeredAppUserId, not provider UID', () async {
    final link = AccountIdentityLink(
      anonymousAppUserId: const AccountUserId('anon-A'),
      registeredAppUserId: const AccountUserId('reg-R'),
      providerId: 'firebase',
      linkedAt: DateTime.now(),
    );
    await repo.saveLink(link);

    final rows = await db.select(db.accountIdentityLinks).get();
    expect(rows, isNotEmpty);
    
    final row = rows.first;
    expect(row.anonymousAppUserId, equals('anon-A'));
    expect(row.registeredAppUserId, equals('reg-R'));
  });
}
