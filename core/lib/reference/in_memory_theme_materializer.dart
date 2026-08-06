// 包：persistence_core  文件：core/lib/reference/in_memory_theme_materializer.dart
// 【reference】§4.4 落地结构。两者一体，拆开会让 reference 层多一个文件而不增加信息。

import 'dart:convert';

import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/dataset/dataset_manifest.dart';
import 'package:persistence_core/model/dataset/dataset_materializer.dart';
import 'package:persistence_core/model/theme_dataset.dart';

/// reference 落地物的共享持有者：世代号 -> (扁平 key -> 值) 的两级内存 Map。
///
/// 【为什么必须是独立对象】XRAP 的 DatasetDescriptor.materializer 是工厂
/// （dataset_descriptor.dart:44），安装器每次落地新建一个 materializer 实例，
/// 该实例出了安装流程即不可达。落地物若存在实例私有字段里，启动路径的
/// ThemeLocalReader 永远读不到（R4-P1-3 断链）。
/// 故落地物必须存在这个由工厂闭包捕获的外部对象里（§4.5 第 1-2 步）。
final class InMemoryThemeTokenStore {
  /// 装配期建一个，全生命周期共享（§4.5 第 1 步）。
  InMemoryThemeTokenStore();

  final Map<int, Map<String, dynamic>> _byGeneration = {};

  /// 写入某一代的全部 token（整代覆盖写，幂等）。只有 materializer 调用它。
  void putGeneration(int generation, Map<String, dynamic> tokens) {
    _byGeneration[generation] = tokens;
  }

  /// 读取某一代的 token；该代未落地返回 null。
  /// 返回 Map.unmodifiable 只读视图（A16 不可变性）。
  Map<String, dynamic>? tokensOf(int generation) {
    final tokens = _byGeneration[generation];
    if (tokens == null) return null;
    return Map<String, dynamic>.unmodifiable(tokens);
  }

  /// 删除某一代。不存在时静默返回（XRAP 要求 dropGeneration 幂等）。
  void dropGeneration(int generation) {
    _byGeneration.remove(generation);
  }

  /// 已落地的世代号集合。诊断与 P4/A20/A21 断言用。
  Set<int> get generations => Set<int>.unmodifiable(_byGeneration.keys);
}

/// S5a 在 XRAP 中的唯一可插拔点（§4.2：不另包 ThemeMaterializer 子接口）。
/// 消费 JSON Lines 载荷（§4.3），整代写入共享 store。
final class InMemoryThemeMaterializer implements DatasetMaterializer {
  /// 落地物写进外部传入的共享 store，不存在实例私有字段里（§4.5）。
  InMemoryThemeMaterializer(this._tokens);

  final InMemoryThemeTokenStore _tokens;

  @override
  String get datasetId => themeDatasetId;

  /// 消费 JSON Lines 载荷（§4.3），整代写入 [generation]。
  ///
  /// 实现要点（逐条对应验收 A20）：
  /// - payload 是 `Stream<List<int>>`（不是 Uint8List），逐行 UTF-8 解码；
  /// - v 为 Map 的行立即抛 StateError（嵌套应在构建期展平，契约违反）；
  /// - 载荷行没有 g 字段，世代号一律取入参 —— 不得从载荷里读或校验世代（R4-P0）；
  /// - 返回 MaterializeOutcome(rowCount: 实际行数, bytesOnDisk: 载荷字节数)；
  /// - 不重复校验载荷完整性（XRAP 已在调用前完成，dataset_materializer.dart:43-45）；
  /// - 不改动活跃指针（协议 P3，翻转是安装器的事）。
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
    // Stream<List<int>> → 逐行 UTF-8 解码。载荷是 LF 分隔的 JSON Lines。
    await for (final line in payload
        .map((chunk) {
          bytes += chunk.length;
          return chunk;
        })
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.isEmpty) continue; // 末行 LF 产生的空串，跳过
      final j = jsonDecode(line) as Map<String, dynamic>;
      if (j['v'] is Map) {
        throw StateError('token 值不得是 Map（嵌套应在构建期展平）: ${j['k']}');
      }
      tokens[j['k'] as String] = j['v']; // 只读 k/v/t，载荷里没有 g
      rowCount++;
    }
    _tokens.putGeneration(generation, tokens); // 用入参 generation，不读载荷
    return MaterializeOutcome(rowCount: rowCount, bytesOnDisk: bytes);
  }

  /// 转调共享 store 的删除。幂等：删不存在世代静默返回（XRAP 事实⑤）。
  @override
  Future<void> dropGeneration(int generation) async {
    _tokens.dropGeneration(generation);
  }
}
