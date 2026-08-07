// 包：persistence_drift  文件：drift/lib/theme/tables/theme_overrides_table.dart
// THEME-DRIFT：用户覆盖差量表（独立库）。
//
// 对应内存版 InMemoryThemeResourceStore 的 `_appliedOverrides` +
// reader 注入的 `initialOverrides`。drift 版两者合并存一张表。
//
// applyOverrides 必须原子（A5）：先整批校验（v 不得为 Map），再在单个
// drift 事务里 upsert 全部 key + 自增 revision。中途失败整批回滚。
// removeOverrides 幂等（不存在的 key 静默忽略，照内存版）。

import 'package:drift/drift.dart';

/// 用户主题覆盖差量表（THEME-DRIFT 独立库）。
///
/// 一行 = 某作用域下一个 token key 的当前覆盖值。
/// `(scope_uid, token_key)` 唯一标识一行。
@DataClassName('ThemeOverrideRow')
class ThemeOverrides extends Table {
  @override
  String get tableName => 't_theme_override';

  /// 账号作用域。与内存版 scopeUid 对齐；多账号隔离。
  TextColumn get scopeUid => text().named('scope_uid')();

  /// 扁平 token key。
  TextColumn get tokenKey => text().named('token_key')();

  /// 覆盖值，JSON 文本编码（标量或 List，不得为 Map）。
  TextColumn get value => text()();

  /// 覆盖来源类型：'manual' 或 'package'（照 OverrideOrigin.kind）。
  TextColumn get originKind => text().named('origin_kind')();

  /// 取值来源主题包 id；manual 时为 null（照 OverrideOrigin.sourceThemeId）。
  TextColumn get originThemeId =>
      text().nullable().named('origin_theme_id')();

  /// 取值时该主题包版本；manual 时为 null（照 OverrideOrigin.sourceThemeVersion）。
  TextColumn get originThemeVersion =>
      text().nullable().named('origin_theme_version')();

  /// 写入时刻（UTC）。
  DateTimeColumn get updatedAtUtc => dateTime().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {scopeUid, tokenKey};
}
