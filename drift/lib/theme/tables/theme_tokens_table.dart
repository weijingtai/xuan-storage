// 包：persistence_drift  文件：drift/lib/theme/tables/theme_tokens_table.dart
// THEME-DRIFT：主题 token 世代表（独立库，不进主库）。
//
// 对应内存版 InMemoryThemeTokenStore 的 `_byGeneration`：世代号 -> (key -> value)。
// 按世代分片 -- 世代翻转时旧代整体丢弃（可整体替换的资源语义，§D3）。
//
// token value 是扁平差量（§4.3 v 不得为 Map），可能是 int/double/String/bool/
// List（非 Map）。drift 无「任意 JSON 标量」列类型，统一以 JSON 文本存，
// 读取时 jsonDecode 还原为动态类型。这与内存版的 dynamic 值语义一致。

import 'package:drift/drift.dart';

/// 主题 token 世代表（THEME-DRIFT 独立库）。
///
/// 一行 = 一个世代的一个 token key。
/// `(dataset_id, generation, token_key)` 唯一标识一行。
/// 世代翻转（XRAP 指针翻转到新 ready 世代）时，旧 generation 的行
/// 整批删除（dropGeneration 幂等，照 InMemoryThemeTokenStore.dropGeneration）。
@DataClassName('ThemeTokenRow')
class ThemeTokens extends Table {
  @override
  String get tableName => 't_theme_token';

  /// 数据集 id（XRAP 主题数据集 = 'theme.package'）。
  TextColumn get datasetId => text().named('dataset_id')();

  /// 世代号。generation 0 = bundled 内置世代（恒存在，XRAP 协议 P5）。
  IntColumn get generation => integer()();

  /// 扁平 token key（如 'light.four_zhu_card.background'）。
  TextColumn get tokenKey => text().named('token_key')();

  /// token 值，JSON 文本编码。
  ///
  /// 存的是标量或 List 的 JSON 表示；Map 由构建期展平为多条 token，
  /// 落地期 v 为 Map 直接抛 StateError（照 InMemoryThemeMaterializer）。
  TextColumn get tokenValue => text().named('token_value')();

  @override
  Set<Column> get primaryKey => {datasetId, generation, tokenKey};

  List<Index> get indexes => [
        // 按世代批量读 / 删（dropGeneration、tokensOf）。
        Index(
          'idx_theme_token_dataset_generation',
          'CREATE INDEX idx_theme_token_dataset_generation '
          'ON t_theme_token (dataset_id, generation);',
        ),
      ];
}
