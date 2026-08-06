// 包：persistence_drift  文件：drift/lib/theme/drift_theme_materializer.dart
// THEME-DRIFT：drift 版主题落地器（对应内存版 InMemoryThemeMaterializer）。
//
// 消费 JSON Lines 载荷（§4.3），整代写入 [DriftThemeTokenStore]。
// 行为逐条对齐内存版 InMemoryThemeMaterializer.materialize：
// - payload 是 Stream<List<int>>，逐行 UTF-8 解码
// - v 为 Map 的行立即抛 StateError（嵌套应在构建期展平）
// - 载荷行没有 g 字段，世代号一律取入参（R4-P0）
// - 返回 MaterializeOutcome(rowCount, bytesOnDisk)
// - 不重复校验载荷完整性（XRAP 已在调用前完成）
// - 不改动活跃指针（协议 P3，翻转是安装器的事）
// dropGeneration 转调 token store，幂等。

import 'dart:async';
import 'dart:convert';

import 'package:persistence_core/persistence_core.dart';

import 'drift_theme_token_store.dart';

/// drift 版主题 materializer：消费 JSON Lines 载荷，整代写入 drift token store。
///
/// 与内存版 [InMemoryThemeMaterializer] 同构，落地物写进外部传入的共享
/// [DriftThemeTokenStore]（§4.5 第 1 步：落地物必须存在工厂闭包捕获的外部
/// 对象里，不存在实例私有字段）。
class DriftThemeMaterializer implements DatasetMaterializer {
  DriftThemeMaterializer(this._tokens);

  final DriftThemeTokenStore _tokens;

  @override
  String get datasetId => _tokens.datasetId;

  /// 消费 JSON Lines 载荷，整代写入 [generation]。
  ///
  /// 实现要点逐条对齐内存版 InMemoryThemeMaterializer（验收 A20）：
  /// - payload 是 `Stream<List<int>>`，逐行 UTF-8 解码
  /// - v 为 Map 的行立即抛 StateError（契约违反）
  /// - 世代号一律取入参，不得从载荷读或校验（R4-P0）
  /// - 返回 MaterializeOutcome(rowCount, bytesOnDisk)
  /// - 不重复校验完整性、不改动活跃指针
  @override
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  }) async {
    final tokens = <String, dynamic>{};
    var rowCount = 0;
    var bytes = 0;
    await for (final line in payload
        .map((chunk) {
          bytes += chunk.length;
          return chunk;
        })
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.isEmpty) continue;
      final j = jsonDecode(line) as Map<String, dynamic>;
      if (j['v'] is Map) {
        throw StateError('token 值不得是 Map（嵌套应在构建期展平）: ${j['k']}');
      }
      tokens[j['k'] as String] = j['v'];
      rowCount++;
    }
    await _tokens.putGeneration(generation, tokens);
    return MaterializeOutcome(rowCount: rowCount, bytesOnDisk: bytes);
  }

  /// 转调 token store 的删除。幂等：删不存在世代静默返回（XRAP 事实⑤）。
  @override
  Future<void> dropGeneration(int generation) async {
    await _tokens.dropGeneration(generation);
  }
}
