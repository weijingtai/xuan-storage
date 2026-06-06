import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_preferences/persistence_preferences.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'support/account_repository_contracts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late PreferencesAccountPreferenceRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    repo = PreferencesAccountPreferenceRepository(prefs);
  });

  group('PreferencesAccountPreferenceRepository', () {
    test('P1: missing preferences return AccountPreferences defaults', () async {
      const userId = AccountUserId('user-1');
      final result = await repo.getPreferences(userId);

      expect(result, equals(const AccountPreferences(appUserId: userId)));
      expect(result.syncEnabled, isTrue);
      expect(result.privacyMode, isFalse);
      expect(result.locale, isNull);
      expect(result.timeZone, isNull);
    });

    test('P2: save preferences round-trip syncEnabled, privacyMode, locale, and timeZone', () async {
      const userId = AccountUserId('user-1');
      const p = AccountPreferences(
        appUserId: userId,
        syncEnabled: false,
        privacyMode: true,
        locale: 'zh',
        timeZone: 'Asia/Shanghai',
      );

      await repo.savePreferences(p);
      final result = await repo.getPreferences(userId);

      expect(result, equals(p));
      expect(result.syncEnabled, isFalse);
      expect(result.privacyMode, isTrue);
      expect(result.locale, 'zh');
      expect(result.timeZone, 'Asia/Shanghai');
    });

    test('P3: preferences for two appUserId values do not overwrite each other', () async {
      const user1 = AccountUserId('user-1');
      const user2 = AccountUserId('user-2');

      const p1 = AccountPreferences(
        appUserId: user1,
        syncEnabled: true,
        privacyMode: false,
        locale: 'en',
      );

      const p2 = AccountPreferences(
        appUserId: user2,
        syncEnabled: false,
        privacyMode: true,
        locale: 'zh',
      );

      await repo.savePreferences(p1);
      await repo.savePreferences(p2);

      final result1 = await repo.getPreferences(user1);
      final result2 = await repo.getPreferences(user2);

      expect(result1.syncEnabled, isTrue);
      expect(result1.privacyMode, isFalse);
      expect(result1.locale, 'en');
      expect(result1.timeZone, isNull);

      expect(result2.syncEnabled, isFalse);
      expect(result2.privacyMode, isTrue);
      expect(result2.locale, 'zh');
      expect(result2.timeZone, isNull);
    });

    test('Contract: verifyAccountPreferenceRepositoryContract', () async {
      await verifyAccountPreferenceRepositoryContract(() => PreferencesAccountPreferenceRepository(prefs));
    });
  });
}
