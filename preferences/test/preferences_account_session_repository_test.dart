import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_preferences/persistence_preferences.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'support/account_repository_contracts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late PreferencesAccountSessionRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    repo = PreferencesAccountSessionRepository(prefs);
  });

  group('PreferencesAccountSessionRepository', () {
    test('R1: saving registered AccountSession then getCurrentSession returns equal object', () async {
      final session = AccountSession(
        appUserId: const AccountUserId('app-1'),
        providerUserId: const ProviderUserId('prov-1'),
        kind: AccountKind.registered,
        providerId: 'firebase',
        issuedAt: DateTime.utc(2026, 1, 1),
        lastRefreshedAt: DateTime.utc(2026, 1, 2),
        email: 'test@example.com',
      );
      await repo.saveCurrentSession(session);
      expect(await repo.getCurrentSession(), equals(session));
    });

    test('R2: clearCurrentSession makes getCurrentSession return null', () async {
      final session = AccountSession(
        appUserId: const AccountUserId('app-1'),
        providerUserId: const ProviderUserId('prov-1'),
        kind: AccountKind.registered,
        providerId: 'firebase',
        issuedAt: DateTime.utc(2026, 1, 1),
      );
      await repo.saveCurrentSession(session);
      await repo.clearCurrentSession();
      expect(await repo.getCurrentSession(), isNull);
    });

    test('R3: raw SharedPreferences keys do not contain sensitive fields', () async {
      final session = AccountSession(
        appUserId: const AccountUserId('app-1'),
        providerUserId: const ProviderUserId('prov-1'),
        kind: AccountKind.registered,
        providerId: 'firebase',
        issuedAt: DateTime.utc(2026, 1, 1),
      );
      await repo.saveCurrentSession(session);
      final keys = prefs.getKeys();
      for (final key in keys) {
        expect(key, isNot(contains('idToken')));
        expect(key, isNot(contains('refreshToken')));
        expect(key, isNot(contains('credential')));
        expect(key, isNot(contains('secret')));
        expect(key, isNot(contains('password')));
      }
    });

    test('R4: all written keys start with account.session.', () async {
      final session = AccountSession(
        appUserId: const AccountUserId('app-1'),
        providerUserId: const ProviderUserId('prov-1'),
        kind: AccountKind.registered,
        providerId: 'firebase',
        issuedAt: DateTime.utc(2026, 1, 1),
        lastRefreshedAt: DateTime.utc(2026, 1, 2),
        email: 'test@example.com',
      );
      await repo.saveCurrentSession(session);
      final keys = prefs.getKeys();
      expect(keys, isNotEmpty);
      for (final key in keys) {
        expect(key, startsWith('account.session.'));
      }
    });

    test('R5: issuedAt and lastRefreshedAt round-trip through ISO-8601 accurately', () async {
      final issuedAt = DateTime.utc(2026, 6, 6, 14, 30, 45, 123, 456);
      final lastRefreshedAt = DateTime.utc(2026, 6, 6, 15, 30, 45, 789, 101);
      final session = AccountSession(
        appUserId: const AccountUserId('app-1'),
        providerUserId: const ProviderUserId('prov-1'),
        kind: AccountKind.registered,
        providerId: 'firebase',
        issuedAt: issuedAt,
        lastRefreshedAt: lastRefreshedAt,
      );
      await repo.saveCurrentSession(session);
      final retrieved = await repo.getCurrentSession();
      expect(retrieved!.issuedAt, equals(issuedAt));
      expect(retrieved.lastRefreshedAt, equals(lastRefreshedAt));
    });

    test('Contract: verifyAccountSessionRepositoryContract', () async {
      await verifyAccountSessionRepositoryContract(() => repo);
    });

    test('Negative: pre-load an invalid kind string returns null or throws AccountRepositoryError', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'account.session.app_user_id': 'app-1',
        'account.session.provider_user_id': 'prov-1',
        'account.session.kind': 'invalid-kind',
        'account.session.provider_id': 'firebase',
        'account.session.issued_at': DateTime.utc(2026, 1, 1).toIso8601String(),
      });
      prefs = await SharedPreferences.getInstance();
      repo = PreferencesAccountSessionRepository(prefs);

      try {
        final result = await repo.getCurrentSession();
        expect(result, isNull);
      } catch (e) {
        if (e is TestFailure) {
          rethrow;
        }
        expect(e, isA<AccountRepositoryError>());
      }
    });
  });
}
