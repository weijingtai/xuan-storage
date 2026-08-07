// 包：persistence_drift  文件：drift/lib/theme/drift_theme_local_reader.dart
// THEME-DRIFT：drift 版主题本地读取端口（对应内存版 XrapThemeLocalReader）。
//
// 行为 1:1 对齐 core/lib/reference/theme_assembly.dart 的 XrapThemeLocalReader，
// 只把数据源从内存换成 drift：
// - readBundledTokens：generation 0 落地物（fail closed，未落地抛 StateError）
// - readActiveThemeTokens：六步无分支，读 XRAP 活跃指针指向的世代落地物
// - readOverrides：查 t_theme_override 覆盖表（scope_uid 分片）

import 'dart:convert';

import 'package:persistence_core/model/dataset/dataset_installer.dart';
import 'package:persistence_core/model/theme_dataset.dart' show themeDatasetId;
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_value_types.dart';

import 'drift_theme_token_store.dart';
import 'theme_database.dart';

/// drift 版 [ThemeLocalReader]。
///
/// 与 [XrapThemeLocalReader] 同构（§4.5 第 4 步的 drift 落地形态）：
/// bundled 读 generation 0，活跃主题读 XRAP 活跃指针指向的世代，
/// 用户覆盖差量查 t_theme_override 表 —— 三个读方法的数据来源各自独立。
///
/// 构造入参：共享 [DriftThemeTokenStore]（读 token 落地物）、
/// [DatasetInstaller]（只读活跃指针，不触发安装）、[scopeUid]（覆盖表分片）、
/// [db]（覆盖表的宿主库，tokenStore 未暴露库句柄，查表需直取）。
class DriftThemeLocalReader implements ThemeLocalReader {
  DriftThemeLocalReader({
    required ThemeDatabase db,
    required DriftThemeTokenStore tokenStore,
    required DatasetInstaller installer,
    required this.scopeUid,
  })  : _db = db,
        _tokens = tokenStore,
        _installer = installer;

  /// 覆盖表宿主库（t_theme_override）。
  final ThemeDatabase _db;

  /// §4.5 第 1 步创建的共享落地物 store（与 materializer 工厂捕获的是同一实例）。
  final DriftThemeTokenStore _tokens;

  /// XRAP 安装器。只读活跃指针（`active`），
  /// reader 不得调 `ensureInstalled` / `checkForUpdate`。
  final DatasetInstaller _installer;

  /// 作用域 uid（多账号隔离），读覆盖表要用。
  final String scopeUid;

  /// bundled = XRAP 的 **generation 0**。
  ///
  /// 照 XrapThemeLocalReader：`tokensOf(0)` 为 null 抛 `StateError`（fail closed）——
  /// 说明装配漏了第 3 步的 `ensureInstalled`，**不得静默返回空 Map**
  /// （空 Map 会让三层合并全部落空却全绿）。
  @override
  Future<Map<String, dynamic>> readBundledTokens() async {
    final tokens = await _tokens.tokensOf(0);
    if (tokens == null) {
      throw StateError(
        'generation 0 未落地：装配期漏调 ensureInstalled（§4.5 第 3 步）',
      );
    }
    return tokens;
  }

  /// 活跃世代的 token。**六步，无分支歧义**，照 XrapThemeLocalReader：
  ///   1. `themeId != tokenStore.datasetId` → 抛 `ArgumentError`。
  ///   2. `final active = await installer.active(themeDatasetId);`
  ///   3. `active == null || !active.isUsable` → 返回 null（无 ready 世代）
  ///   4. `active.generation == 0` → 返回 null
  ///      （第 0 代是 bundled，由 readBundledTokens 承担，不重复算作"已装主题包"）
  ///   5. `final t = _tokens.tokensOf(active.generation);`
  ///      `t == null` → 返回 null（指针指向的世代无落地物：结构性不一致，
  ///      fail closed 交给 bundled 兜底，与 P6 同一条降级路径）
  ///   6. 返回 `t`
  @override
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId) async {
    if (themeId != _tokens.datasetId) {
      throw ArgumentError(
        'reference 阶段 themeId 必须为数据集 id ${_tokens.datasetId}'
        '（多主题包并存属 THEME-DRIFT，不在 S5a）',
      );
    }
    final active = await _installer.active(themeDatasetId);
    if (active == null || !active.isUsable) return null;
    if (active.generation == 0) return null;
    final tokens = await _tokens.tokensOf(active.generation);
    if (tokens == null) return null;
    return tokens;
  }

  /// 查 t_theme_override 表（scope_uid 分片），还原成 [OverrideEntry]。
  @override
  Future<Map<String, OverrideEntry>> readOverrides() async {
    final rows = await (_db.select(_db.themeOverrides)
          ..where((t) => t.scopeUid.equals(scopeUid)))
        .get();
    final result = <String, OverrideEntry>{};
    for (final row in rows) {
      result[row.tokenKey] = OverrideEntry(
        value: jsonDecode(row.value),
        origin: _originFrom(row),
        updatedAtUtc: row.updatedAtUtc,
      );
    }
    return Map<String, OverrideEntry>.unmodifiable(result);
  }

  /// 还原覆盖来源：'manual' -> manual；'package' -> fromPackage(行内主题 id/版本)。
  OverrideOrigin _originFrom(ThemeOverrideRow row) {
    if (row.originKind == 'manual') return OverrideOrigin.manual;
    return OverrideOrigin.fromPackage(
      themeId: row.originThemeId!,
      version: row.originThemeVersion!,
    );
  }
}
