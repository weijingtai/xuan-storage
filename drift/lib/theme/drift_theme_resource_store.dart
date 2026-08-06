// 包：persistence_drift  文件：drift/lib/theme/drift_theme_resource_store.dart
// THEME-DRIFT：drift 版主题资源 store（对应内存版 InMemoryThemeResourceStore）。
//
// 行为 1:1 对齐 core/lib/reference/in_memory_theme_resource_store.dart，
// 差异只在存储后端 + 缓存/事务要显式建：
// - identical 缓存层：D4，三元组键 (activeThemeId, packageVersion, overridesRevision)
// - 30ms 活跃读取超时降级：P6，照内存版 _readActiveWithTimeout
// - applyOverrides 原子：D5，校验在事务外、写入在单事务内
// - _overridesRevision：D8 选 (b)，从覆盖表派生（行数 + 最大 updated_at_utc），
//   不维护计数器列（§1.1 不碰 T1 文件 + 零 build_runner）

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:persistence_core/model/theme_dataset.dart' show themeDatasetId;
import 'package:persistence_core/model/theme_resource_store.dart';
import 'package:persistence_core/model/theme_resolution.dart'
    show ThemeSelectionOrigin;
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';
import 'package:persistence_core/reference/theme_token_merger.dart';

import 'theme_database.dart';

/// drift 版三层合并的主题 store。
///
/// 与 [InMemoryThemeResourceStore] 同构，存储后端换成 [ThemeDatabase]：
/// - 覆盖差量存 t_theme_override（scope_uid 分片，JSON 文本编码）
/// - 主题选择存 t_theme_selection（单行：selected_theme_id）
/// - bundled / 活跃世代 token 经 [ThemeLocalReader] 读取（注入
///   [DriftThemeLocalReader]，测试可注入 fake）
///
/// 【缓存（D4）】`resolve()` 结果按 `(activeThemeId, overridesRevision)`
/// 键缓存；键相同返回**同一实例**（identical）。写操作后
/// [_refreshAndNotify] 显式失效缓存再重算推送，保证写后新鲜。
class DriftThemeResourceStore implements ThemeResourceStore {
  DriftThemeResourceStore({
    required ThemeDatabase db,
    required this.scopeUid,
    required ThemeLocalReader localReader,
  })  : _db = db,
        _reader = localReader;

  final ThemeDatabase _db;

  @override
  final String scopeUid;

  /// 唯一本地读取端口（bundled / 活跃世代 / override 三层的数据源）。
  final ThemeLocalReader _reader;

  /// 单条缓存（D4）：三元组键 (activeThemeId, packageVersion, overridesRevision)。
  /// packageVersion 在 reference 阶段恒 null（store 不持有 installer），
  /// 与内存版一致。
  ThemeTokenSet? _cache;
  String? _cacheThemeId;
  int _cacheRevision = -1;

  /// watchResolved 的广播流（写操作后推送新值）。
  final StreamController<ThemeTokenSet> _controller =
      StreamController<ThemeTokenSet>.broadcast();

  /// 活跃世代读取的降级超时（P6，照内存版：30ms，50ms 内必须返回）。
  static const _activeReadTimeout = Duration(milliseconds: 30);

  @override
  Future<ThemeTokenSet> resolve({Object? cancel}) async {
    // ⚠️ 端口签名是 `{CancellationToken? cancel}`，这里用超类型 `Object?`：
    // 照内存版实现（reference 不阻塞、不可取消），override 合法（参数逆变）。
    // 读三层。bundled 恒存在；overrides = reader 注入的 base + 表内 applied
    // （drift 版两者同一张表，merge 是幂等防御）；活跃世代带超时降级。
    final bundled = await _reader.readBundledTokens();
    final baseOverrides = await _reader.readOverrides();
    final applied = await _readAppliedOverridesFromDb();
    final overrides = <String, OverrideEntry>{...baseOverrides, ...applied};
    final selectedThemeId = await _readSelection();
    final themeId = selectedThemeId ?? themeDatasetId;
    final packageTokens = await _readActiveWithTimeout(themeId);
    final activeThemeId = packageTokens == null ? null : themeId;

    // 缓存键三元组 (activeThemeId, packageVersion, overridesRevision)。
    final overridesRevision = await _readOverridesRevision();
    if (_cache != null &&
        _cacheThemeId == activeThemeId &&
        _cacheRevision == overridesRevision) {
      return _cache!;
    }

    final selectionOrigin = selectedThemeId != null
        ? ThemeSelectionOrigin.userSelected
        : (packageTokens == null
            ? ThemeSelectionOrigin.bundledFallback
            : ThemeSelectionOrigin.officialDefault);

    final result = mergeThemeTokens(
      bundledTokens: bundled,
      packageTokens: packageTokens,
      overrides: overrides,
      activeThemeId: activeThemeId,
      activeThemeVersion: null,
      selectionOrigin: selectionOrigin,
      resolvedAtUtc: DateTime.now().toUtc(),
    );
    _cache = result;
    _cacheThemeId = activeThemeId;
    _cacheRevision = overridesRevision;
    return result;
  }

  @override
  Stream<ThemeTokenSet> watchResolved() => _controller.stream;

  @override
  Future<List<LocalTheme>> listLocalThemes() async {
    final result = <LocalTheme>[
      const LocalTheme(
        id: themeDatasetId,
        displayName: '内置默认主题',
        author: 'builtin',
        generation: 0,
      ),
    ];
    final active = await _readActiveWithTimeout(themeDatasetId);
    if (active != null) {
      // reference 阶段数据集唯一，活跃世代即同一数据集的高世代落地物；
      // 照内存版：非 0 即视为"已装主题包"。
      result.add(
        const LocalTheme(
          id: themeDatasetId,
          displayName: '已安装主题包',
          author: 'official',
          generation: 1,
        ),
      );
    }
    return List<LocalTheme>.unmodifiable(result);
  }

  @override
  Future<void> selectTheme(String themeId) async {
    // 端口契约：themeId 必须在 listLocalThemes 中。reference 阶段数据集
    // 唯一，等价于 id 必须为主题数据集 id（照内存版 StateError）。
    if (themeId != themeDatasetId) {
      throw StateError(
        '未知主题: $themeId（reference 阶段仅支持数据集 $themeDatasetId，'
        '多主题包并存属 THEME-DRIFT）',
      );
    }
    await _db.into(_db.themeSelections).insertOnConflictUpdate(
          ThemeSelectionsCompanion.insert(
            scopeUid: scopeUid,
            selectedThemeId: Value(themeId),
          ),
        );
    await _refreshAndNotify();
  }

  @override
  Future<void> clearThemeSelection() async {
    // 行不存在 = 跟随官方默认（_readSelection 返回 null），删除即清除。
    await (_db.delete(_db.themeSelections)
          ..where((t) => t.scopeUid.equals(scopeUid)))
        .go();
    await _refreshAndNotify();
  }

  @override
  Future<void> applyOverrides({
    required Map<String, dynamic> patch,
    required OverrideOrigin origin,
  }) async {
    // 原子提交（D5 / A11②）：先整批校验，任一非法整批不生效（事务外）。
    for (final entry in patch.entries) {
      if (entry.value is Map) {
        throw StateError(
          '覆盖值不得为 Map（扁平差量契约违反，§4.3 v 不得为 Map）: ${entry.key}',
        );
      }
    }
    // 写入段：单事务，中途失败整批回滚（A5）。
    await _db.transaction(() async {
      final now = DateTime.now().toUtc();
      for (final entry in patch.entries) {
        await _db.into(_db.themeOverrides).insertOnConflictUpdate(
              ThemeOverridesCompanion.insert(
                scopeUid: scopeUid,
                tokenKey: entry.key,
                value: jsonEncode(entry.value),
                originKind: origin.kind,
                originThemeId: Value(origin.sourceThemeId),
                originThemeVersion: Value(origin.sourceThemeVersion),
                updatedAtUtc: now,
              ),
            );
      }
    });
    await _refreshAndNotify();
  }

  @override
  Future<void> removeOverrides(Set<String> tokenKeys) async {
    // 幂等（A12②）：不存在的 key 静默忽略。单事务。
    await _db.transaction(() async {
      for (final key in tokenKeys) {
        await (_db.delete(_db.themeOverrides)
              ..where((t) =>
                  t.scopeUid.equals(scopeUid) & t.tokenKey.equals(key)))
            .go();
      }
    });
    await _refreshAndNotify();
  }

  @override
  Future<Map<String, OverrideEntry>> listOverrides() async {
    final base = await _reader.readOverrides();
    final applied = await _readAppliedOverridesFromDb();
    final all = <String, OverrideEntry>{...base, ...applied};
    return Map<String, OverrideEntry>.unmodifiable(all);
  }

  /// 读活跃世代 token，带 [Duration] 超时降级（P6，照内存版六步）。
  Future<Map<String, dynamic>?> _readActiveWithTimeout(String themeId) {
    return _reader
        .readActiveThemeTokens(themeId)
        .timeout(_activeReadTimeout, onTimeout: () => null);
  }

  /// 覆盖层变更 / 主题切换后：失效缓存 → 重算 → 推送新值（照内存版）。
  Future<void> _refreshAndNotify() async {
    if (_controller.isClosed) return;
    _cache = null;
    _cacheThemeId = null;
    _cacheRevision = -1;
    _controller.add(await resolve());
  }

  /// 查 t_theme_selection（scope_uid 单行），返回 selected_theme_id（可空）。
  Future<String?> _readSelection() async {
    final row = await (_db.select(_db.themeSelections)
          ..where((t) => t.scopeUid.equals(scopeUid)))
        .getSingleOrNull();
    return row?.selectedThemeId;
  }

  /// 查 t_theme_override（scope_uid 分片），还原成 [OverrideEntry]。
  ///
  /// 与 reader.readOverrides 同表同构；store 直接读库保证写路径新鲜
  /// （reader 在测试里可注入 fake，不能依赖它读 applied）。
  Future<Map<String, OverrideEntry>> _readAppliedOverridesFromDb() async {
    final rows = await (_db.select(_db.themeOverrides)
          ..where((t) => t.scopeUid.equals(scopeUid)))
        .get();
    final result = <String, OverrideEntry>{};
    for (final row in rows) {
      result[row.tokenKey] = OverrideEntry(
        value: jsonDecode(row.value),
        origin: row.originKind == 'manual'
            ? OverrideOrigin.manual
            : OverrideOrigin.fromPackage(
                themeId: row.originThemeId!,
                version: row.originThemeVersion!,
              ),
        updatedAtUtc: row.updatedAtUtc,
      );
    }
    return Map<String, OverrideEntry>.unmodifiable(result);
  }

  /// D8 (b)：从覆盖表派生 revision = 行数 + 最大 updated_at_utc 毫秒数。
  ///
  /// 任何写操作（增/删/改值）都会改变行数或 updated_at_utc；同一秒内
  /// 同 key 重写（行数不变、秒精度不变）的残留风险由
  /// [_refreshAndNotify] 的「写后必失效重算」兜住（D8 第 2 条）。
  Future<int> _readOverridesRevision() async {
    final row = await (_db.selectOnly(_db.themeOverrides)
          ..addColumns([
            _db.themeOverrides.updatedAtUtc.max(),
            countAll(),
          ])
          ..where(_db.themeOverrides.scopeUid.equals(scopeUid)))
        .getSingleOrNull();
    if (row == null) return 0;
    final maxMs =
        row.read(_db.themeOverrides.updatedAtUtc.max())?.millisecondsSinceEpoch ??
            0;
    final count = row.read(countAll()) ?? 0;
    // 组合成单调可比较的 int：行数分量低位，毫秒分量高位。
    return maxMs * 1000000 + count;
  }
}
