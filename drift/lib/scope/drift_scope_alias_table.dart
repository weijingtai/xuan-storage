import 'package:drift/drift.dart';

/// 别名账本表。
///
/// 记录 identity → scope_uid 的映射关系。
/// 主键 (auth_kind, auth_id) 保证同一身份不会映射 to two scope.
class TScopeAlias extends Table {
  @override
  String get tableName => 't_scope_alias';

  TextColumn get authKind => text().named('auth_kind')();
  TextColumn get authId => text().named('auth_id')();
  TextColumn get scopeUid => text().named('scope_uid')();
  DateTimeColumn get linkedAt => dateTime().named('linked_at')();

  @override
  Set<Column> get primaryKey => {authKind, authId};
}
