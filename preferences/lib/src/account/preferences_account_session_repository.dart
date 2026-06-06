import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PreferencesAccountSessionRepository implements AccountSessionRepository {
  const PreferencesAccountSessionRepository(this._preferences);
  final SharedPreferences _preferences;

  static const _prefix = 'account.session.';
  static const _keyAppUserId = '${_prefix}app_user_id';
  static const _keyProviderUserId = '${_prefix}provider_user_id';
  static const _keyKind = '${_prefix}kind';
  static const _keyProviderId = '${_prefix}provider_id';
  static const _keyIssuedAt = '${_prefix}issued_at';
  static const _keyLastRefreshedAt = '${_prefix}last_refreshed_at';
  static const _keyEmail = '${_prefix}email';

  @override
  Future<AccountSession?> getCurrentSession() async {
    final appUserId = _preferences.getString(_keyAppUserId);
    if (appUserId == null) return null;

    final kindString = _preferences.getString(_keyKind);
    final AccountKind kind;
    switch (kindString) {
      case 'anonymous':
        kind = AccountKind.anonymous;
      case 'registered':
        kind = AccountKind.registered;
      default:
        // Corrupted or unrecognized kind — treat as no valid session.
        return null;
    }

    return AccountSession(
      appUserId: AccountUserId(appUserId),
      providerUserId: ProviderUserId(_preferences.getString(_keyProviderUserId) ?? ''),
      kind: kind,
      providerId: _preferences.getString(_keyProviderId) ?? '',
      issuedAt: DateTime.tryParse(_preferences.getString(_keyIssuedAt) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      lastRefreshedAt: _preferences.getString(_keyLastRefreshedAt) != null
          ? DateTime.tryParse(_preferences.getString(_keyLastRefreshedAt)!)
          : null,
      email: _preferences.getString(_keyEmail),
    );
  }

  @override
  Future<void> saveCurrentSession(AccountSession session) async {
    await _preferences.setString(_keyAppUserId, session.appUserId.value);
    await _preferences.setString(_keyProviderUserId, session.providerUserId.value);
    await _preferences.setString(_keyKind, session.kind == AccountKind.registered ? 'registered' : 'anonymous');
    await _preferences.setString(_keyProviderId, session.providerId);
    await _preferences.setString(_keyIssuedAt, session.issuedAt.toIso8601String());
    if (session.lastRefreshedAt != null) {
      await _preferences.setString(_keyLastRefreshedAt, session.lastRefreshedAt!.toIso8601String());
    } else {
      await _preferences.remove(_keyLastRefreshedAt);
    }
    if (session.email != null) {
      await _preferences.setString(_keyEmail, session.email!);
    } else {
      await _preferences.remove(_keyEmail);
    }
  }

  @override
  Future<void> clearCurrentSession() async {
    await _preferences.remove(_keyAppUserId);
    await _preferences.remove(_keyProviderUserId);
    await _preferences.remove(_keyKind);
    await _preferences.remove(_keyProviderId);
    await _preferences.remove(_keyIssuedAt);
    await _preferences.remove(_keyLastRefreshedAt);
    await _preferences.remove(_keyEmail);
  }
}
