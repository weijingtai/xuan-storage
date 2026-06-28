/// 别名身份类型。
enum ScopeAuthKind {
  anonymous,  // guest appUserId
  registered, // 注册 appUserId
  device,     // 设备 id (无 BaaS 场景，仅 ScopeBootstrapStore 内部标识 ghost scope)
}

/// 别名账本条目：某个身份 → 某个 scope_uid 的映射。
///
/// 主键是 (authKind, authId)。同一 authId 不会出现在两个 scope 下。
class ScopeAliasEntry {
  const ScopeAliasEntry({
    required this.authKind,
    required this.authId,
    required this.scopeUid,
    required this.linkedAt,
  });

  final ScopeAuthKind authKind;
  final String authId;
  final String scopeUid;
  final DateTime linkedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScopeAliasEntry &&
          runtimeType == other.runtimeType &&
          authKind == other.authKind &&
          authId == other.authId &&
          scopeUid == other.scopeUid;

  @override
  int get hashCode => Object.hash(authKind, authId, scopeUid);
}
