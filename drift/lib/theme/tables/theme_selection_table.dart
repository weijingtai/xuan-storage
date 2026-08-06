// 包：persistence_drift  文件：drift/lib/theme/tables/theme_selection_table.dart
// THEME-DRIFT：用户主题选择表（独立库）。
//
// 对应内存版 InMemoryThemeResourceStore 的 `_selectedThemeId`。
// 单行状态：null = 跟随官方默认；非 null = 用户显式选择。
// selectTheme / clearThemeSelection 写本表。

import 'package:drift/drift.dart';

/// 用户主题选择表（THEME-DRIFT 独立库）。
///
/// 单行表：`(scope_uid)` 唯一标识一行，`selected_theme_id` 为 null
/// 表示跟随官方默认（照内存版 `_selectedThemeId` 语义）。
@DataClassName('ThemeSelectionRow')
class ThemeSelections extends Table {
  @override
  String get tableName => 't_theme_selection';

  /// 账号作用域。
  TextColumn get scopeUid => text().named('scope_uid')();

  /// 用户显式选择的主题 id；null = 跟随官方默认。
  TextColumn get selectedThemeId =>
      text().nullable().named('selected_theme_id')();

  @override
  Set<Column> get primaryKey => {scopeUid};
}
