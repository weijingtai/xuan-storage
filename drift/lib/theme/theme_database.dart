// 包：persistence_drift  文件：drift/lib/theme/theme_database.dart
// THEME-DRIFT：主题独立 drift 库（照 T1 的 GeoDatabase，不进主库）。
//
// 【为什么独立库】design.md D1（§四裁定，已人类确认 2026-08-06）：
// 主题是可整体替换的 XRAP 资源，与 T1 地理资产同类；独立库使主库
// schemaVersion 保持 9 不动，零主库迁移风险，且最不与另一个 Theme agent
// 撞车（只新增 drift/lib/theme/*，不碰 core/lib/reference 与 core/lib/model）。
//
// 【为什么 schemaVersion 从 1 起】照 T1。独立库与主库版本号空间无关。
//
// 【重启后主题仍在】本库是单独 .sqlite 文件，进程退出文件还在、重开即恢复
// （验收 A7）。内存版 InMemoryThemeResourceStore 做不到这一点 -- 这正是
// 本任务存在的理由。

import 'package:drift/drift.dart';

import 'tables/theme_tokens_table.dart';
import 'tables/theme_overrides_table.dart';
import 'tables/theme_selection_table.dart';
import 'tables/theme_dataset_generations_table.dart';

part 'theme_database.g.dart';

/// 主题独立资源数据库（THEME-DRIFT，照 T1 GeoDatabase 模式）。
///
/// 承载 4 张表：
/// - `t_theme_token`（按世代分片的 token，对应 InMemoryThemeTokenStore）
/// - `t_theme_override`（用户覆盖差量，对应 _appliedOverrides + initialOverrides）
/// - `t_theme_selection`（用户主题选择，对应 _selectedThemeId）
/// - `t_theme_dataset_generation`（XRAP 世代状态，照 T1 DatasetGenerations）
///
/// schemaVersion 从 1 起（D2）。未来主题落地结构升级递增本库版本，
/// 与主库 PersistenceDriftDatabase 的版本号无关。
@DriftDatabase(
  tables: [ThemeTokens, ThemeOverrides, ThemeSelections, ThemeDatasetGenerations],
)
class ThemeDatabase extends _$ThemeDatabase {
  ThemeDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createThemeTokenIndices();
        },
        // 独立库 v1 起步，暂无升级路径。未来加表/列时在此追加 from<N> 分支。
        onUpgrade: (m, from, to) async {
          if (from < 1) {
            await m.createAll();
            await _createThemeTokenIndices();
          }
        },
      );

  /// m.createAll 会建表声明的索引，但 onCreate 额外显式建一次以与
  /// onUpgrade 路径对齐（照主库 _createBlobIndices 的防御性写法）。
  Future<void> _createThemeTokenIndices() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_theme_token_dataset_generation '
      'ON t_theme_token (dataset_id, generation);',
    );
  }
}
