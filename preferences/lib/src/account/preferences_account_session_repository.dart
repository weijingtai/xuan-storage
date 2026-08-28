import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PreferencesAccountSessionRepository
    implements AccountSessionRepository {
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
    final res = await get('', RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  @override
  Future<void> saveCurrentSession(AccountSession session) async {
    await put(session, RequestContext(scopeUid: 'system'));
  }

  @override
  Future<void> clearCurrentSession() async {
    await purge('', RequestContext(scopeUid: 'system'));
  }

  @override
  Future<Result<AccountSession?>> get(String id, RequestContext ctx) async {
    final appUserId = _preferences.getString(_keyAppUserId);
    if (appUserId == null) return const Ok(null);

    final kindString = _preferences.getString(_keyKind);
    final AccountKind kind;
    switch (kindString) {
      case 'anonymous':
        kind = AccountKind.anonymous;
      case 'registered':
        kind = AccountKind.registered;
      default:
        return const Ok(null);
    }

    return Ok(AccountSession(
      appUserId: AccountUserId(appUserId),
      providerUserId: ProviderUserId(
          _preferences.getString(_keyProviderUserId) ?? ''),
      kind: kind,
      providerId: _preferences.getString(_keyProviderId) ?? '',
      issuedAt: DateTime.tryParse(
              _preferences.getString(_keyIssuedAt) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastRefreshedAt:
          _preferences.getString(_keyLastRefreshedAt) != null
              ? DateTime.tryParse(_preferences.getString(_keyLastRefreshedAt)!)
              : null,
      email: _preferences.getString(_keyEmail),
    ));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    return Ok(_preferences.getString(_keyAppUserId) != null);
  }

  @override
  Future<Result<Rev>> put(AccountSession entity, RequestContext ctx,
      {Precondition pre = const Unconditional()}) async {
    await _preferences.setString(_keyAppUserId, entity.appUserId.value);
    await _preferences.setString(
        _keyProviderUserId, entity.providerUserId.value);
    await _preferences.setString(
        _keyKind, entity.kind == AccountKind.registered ? 'registered' : 'anonymous');
    await _preferences.setString(_keyProviderId, entity.providerId);
    await _preferences.setString(
        _keyIssuedAt, entity.issuedAt.toIso8601String());
    if (entity.lastRefreshedAt != null) {
      await _preferences.setString(
          _keyLastRefreshedAt, entity.lastRefreshedAt!.toIso8601String());
    } else {
      await _preferences.remove(_keyLastRefreshedAt);
    }
    if (entity.email != null) {
      await _preferences.setString(_keyEmail, entity.email!);
    } else {
      await _preferences.remove(_keyEmail);
    }
    return const Ok(Rev('prefs_session_rev'));
  }

  @override
  Future<Result<void>> purge(String id, RequestContext ctx) async {
    await _preferences.remove(_keyAppUserId);
    await _preferences.remove(_keyProviderUserId);
    await _preferences.remove(_keyKind);
    await _preferences.remove(_keyProviderId);
    await _preferences.remove(_keyIssuedAt);
    await _preferences.remove(_keyLastRefreshedAt);
    await _preferences.remove(_keyEmail);
    return const Ok(null);
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    final r = await body();
    return Ok(r);
  }
}
