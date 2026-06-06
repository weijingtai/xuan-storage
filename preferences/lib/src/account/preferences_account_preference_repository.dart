import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PreferencesAccountPreferenceRepository implements AccountPreferenceRepository {
  const PreferencesAccountPreferenceRepository(this._preferences);
  final SharedPreferences _preferences;

  String _key(AccountUserId userId, String field) => 'account.preferences.${userId.value}.$field';

  @override
  Future<AccountPreferences> getPreferences(AccountUserId userId) async {
    return AccountPreferences(
      appUserId: userId,
      syncEnabled: _preferences.getBool(_key(userId, 'sync_enabled')) ?? true,
      privacyMode: _preferences.getBool(_key(userId, 'privacy_mode')) ?? false,
      locale: _preferences.getString(_key(userId, 'locale')),
      timeZone: _preferences.getString(_key(userId, 'time_zone')),
    );
  }

  @override
  Future<void> savePreferences(AccountPreferences preferences) async {
    final userId = preferences.appUserId;
    await _preferences.setBool(_key(userId, 'sync_enabled'), preferences.syncEnabled);
    await _preferences.setBool(_key(userId, 'privacy_mode'), preferences.privacyMode);
    if (preferences.locale != null) {
      await _preferences.setString(_key(userId, 'locale'), preferences.locale!);
    } else {
      await _preferences.remove(_key(userId, 'locale'));
    }
    if (preferences.timeZone != null) {
      await _preferences.setString(_key(userId, 'time_zone'), preferences.timeZone!);
    } else {
      await _preferences.remove(_key(userId, 'time_zone'));
    }
  }
}
