import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PreferencesAccountPreferenceRepository
    implements AccountPreferenceRepository {
  const PreferencesAccountPreferenceRepository(this._preferences);
  final SharedPreferences _preferences;

  String _key(AccountUserId userId, String field) =>
      'account.preferences.${userId.value}.$field';

  @override
  Future<Result<AccountPreferences?>> get(String id, RequestContext ctx) async {
    final userId = AccountUserId(id);
    return Ok(AccountPreferences(
      appUserId: userId,
      syncEnabled: _preferences.getBool(_key(userId, 'sync_enabled')) ?? true,
      privacyMode:
          _preferences.getBool(_key(userId, 'privacy_mode')) ?? false,
      locale: _preferences.getString(_key(userId, 'locale')),
      timeZone: _preferences.getString(_key(userId, 'time_zone')),
    ));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final userId = AccountUserId(id);
    return Ok(_preferences.containsKey(_key(userId, 'sync_enabled')) ||
        _preferences.containsKey(_key(userId, 'privacy_mode')));
  }

  @override
  Future<Result<Rev>> put(AccountPreferences entity, RequestContext ctx,
      {Precondition pre = const Unconditional()}) async {
    final userId = entity.appUserId;
    await _preferences.setBool(
        _key(userId, 'sync_enabled'), entity.syncEnabled);
    await _preferences.setBool(
        _key(userId, 'privacy_mode'), entity.privacyMode);
    if (entity.locale != null) {
      await _preferences.setString(_key(userId, 'locale'), entity.locale!);
    } else {
      await _preferences.remove(_key(userId, 'locale'));
    }
    if (entity.timeZone != null) {
      await _preferences.setString(_key(userId, 'time_zone'), entity.timeZone!);
    } else {
      await _preferences.remove(_key(userId, 'time_zone'));
    }
    return const Ok(Rev('prefs_pref_rev'));
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    final r = await body();
    return Ok(r);
  }
}
