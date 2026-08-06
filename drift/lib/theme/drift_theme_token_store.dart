// 包：persistence_drift  文件：drift/lib/theme/drift_theme_token_store.dart
// THEME-DRIFT：drift 版主题 token 世代存储（对应内存版 InMemoryThemeTokenStore）。
//
// 内存版用 `Map<int, Map<String, dynamic>>` 存；drift 版落 t_theme_token 表，
// 按 (dataset_id, generation) 分片。语义对齐：
// - tokensOf(generation)：读该代全部 token，未落地返回 null
// - putGeneration(generation, tokens)：整代覆盖写（幂等）
// - dropGeneration(generation)：删该代全部行（幂等，不存在静默返回）
// - generations：已落地世代号集合（诊断用）
//
// token value 是 dynamic（标量或 List，不得为 Map），drift 以 JSON 文本存，
// 读取时 jsonDecode 还原。这与内存版的 dynamic 值语义一致。

import 'dart:convert';

import 'package:drift/drift.dart';

import 'theme_database.dart';

/// drift 版主题 token 世代存储。
///
/// 落地物写进 [ThemeDatabase] 的 t_theme_token 表。与内存版
/// [InMemoryThemeTokenStore] 同构，供 [DriftThemeMaterializer] 与
/// [DriftThemeLocalReader] 共享（§4.5 第 1 步的「全进程一个共享落地物 store」
/// 在 drift 侧的落地形态）。
class DriftThemeTokenStore {
  DriftThemeTokenStore(this._db);

  final ThemeDatabase _db;

  /// 数据集 id。默认主题数据集 = 'theme.package'。
  /// 多数据集并存属 THEME-DRIFT 之后的范围，本实现按单一数据集写。
  final String datasetId = 'theme.package';

  /// 读取某一代的全部 token；该代未落地返回 null。
  ///
  /// 返回 Map.unmodifiable 只读视图（对齐内存版 A16 不可变性）。
  Future<Map<String, dynamic>?> tokensOf(int generation) async {
    final rows = await (_db.select(_db.themeTokens)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.generation.equals(generation)))
        .get();
    if (rows.isEmpty) return null;
    final tokens = <String, dynamic>{};
    for (final row in rows) {
      tokens[row.tokenKey] = jsonDecode(row.tokenValue);
    }
    return Map<String, dynamic>.unmodifiable(tokens);
  }

  /// 写入某一代的全部 token（整代覆盖写，幂等）。
  ///
  /// 幂等实现：先删该代全部行，再批量插入。只有 materializer 调用它
  /// （照内存版 putGeneration 的调用约束）。
  Future<void> putGeneration(int generation, Map<String, dynamic> tokens) async {
    await _db.transaction(() async {
      await (_db.delete(_db.themeTokens)
            ..where((t) =>
                t.datasetId.equals(datasetId) &
                t.generation.equals(generation)))
          .go();
      if (tokens.isEmpty) return;
      await _db.batch((b) {
        b.insertAll(
          _db.themeTokens,
          tokens.entries.map(
            (e) => ThemeTokensCompanion.insert(
              datasetId: datasetId,
              generation: generation,
              tokenKey: e.key,
              tokenValue: jsonEncode(e.value),
            ),
          ),
        );
      });
    });
  }

  /// 删除某一代。不存在时静默返回（XRAP 要求 dropGeneration 幂等）。
  Future<void> dropGeneration(int generation) async {
    await (_db.delete(_db.themeTokens)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.generation.equals(generation)))
        .go();
  }

  /// 已落地的世代号集合。诊断与 P4/A20/A21 断言用（对齐内存版 generations）。
  Future<Set<int>> get generations async {
    final rows = await (_db.selectOnly(_db.themeTokens)
          ..addColumns([_db.themeTokens.generation])
          ..where(_db.themeTokens.datasetId.equals(datasetId))
          ..groupBy([_db.themeTokens.generation]))
        .get();
    return rows.map((r) => r.read(_db.themeTokens.generation)!).toSet();
  }
}
