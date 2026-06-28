import 'scope_alias_entry.dart';

/// 别名账本接口。
///
/// 管理 identity → scope_uid 的映射关系。
/// ScopeResolver 通过此接口完成所有 scope 查询和绑定。
abstract interface class ScopeLedger {
  /// 返回设备级 ghost scope_uid (bootstrap 铸的值)。
  Future<String> deviceScope();

  /// 查询某个身份是否已有别名。
  /// 命中 → 返回对应的 scope_uid；未命中 → 返回 null。
  Future<String?> scopeForIdentity(String authId, ScopeAuthKind authKind);

  /// 绑定身份到已有 scope (INSERT alias)。
  /// 升级场景：匿名→注册时调用。
  ///
  /// 注意：如果 (authKind, authId) 已存在，此方法会覆盖 scope_uid。
  /// 调用方 must guarantee not duplicate bind different scope.
  Future<void> bind(String authId, ScopeAuthKind authKind, String scopeUid);

  /// 铸造新 scope_uid 并绑定身份。
  /// 冲突场景：登录已有账户且无 link 时调用。
  Future<String> mintAndBind(String authId, ScopeAuthKind authKind);

  /// 返回某个 scope_uid 下的所有别名条目。
  Future<List<ScopeAliasEntry>> entriesForScope(String scopeUid);
}
