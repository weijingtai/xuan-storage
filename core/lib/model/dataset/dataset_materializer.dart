/// XRAP 落地端口（协议 §3.3）—— **唯一的可插拔点**。
///
/// 模块之间的全部差异收敛到本接口。取载荷、校验、状态机、世代管理、
/// 活跃指针翻转、GC 一律由协议实现统一负责，模块不得自行实现（协议 N1）。
library;

import '../cancellation_token.dart';
import 'dataset_manifest.dart';

/// 落地结果。由 [DatasetMaterializer] 返回给安装器做自检。
final class MaterializeOutcome {
  /// 实际落地的行数。纯 blob 数据集返回 0。
  ///
  /// 安装器据此与 [DatasetManifest.declaredRowCount] 比对；
  /// 不符即判完整性失败且【不进入 ready】（协议不变式 I4）。
  final int rowCount;

  /// 落地物占用的字节数（估算即可）。用于 GC 决策与容量显示。
  final int bytesOnDisk;

  /// 构造一个落地结果。
  const MaterializeOutcome({
    required this.rowCount,
    required this.bytesOnDisk,
  });
}

/// 把校验过的载荷落成模块可查询的本地形态。
///
/// **每个数据集一个实现，这是接入方要写的东西**（协议 §3 第 3 项）。
///
/// 实现约定（违反则协议的原子性保证失效）：
/// - 只写入入参给定的 [generation]，**不得触碰其它世代**；
/// - **不得改动活跃指针** —— 翻转由安装器在独立事务内完成，
///   这是「半安装态不可见」（协议 P3）的结构保证；
/// - 落地过程可能被取消，取消后由安装器调用 [dropGeneration] 清理；
/// - 长耗时解析应在独立 isolate 内完成（《总纲》§3.6「isolate」）。
abstract interface class DatasetMaterializer {
  /// 本落地器服务的数据集 id。必须与 descriptor 一致。
  String get datasetId;

  /// 把 [payload] 落成 [generation] 这一代。
  ///
  /// 调用时机：安装器已完成 sha256 校验（协议 §5.2 第 5 步）。
  /// 因此实现【不需要】再校验完整性，只管解析与写入。
  ///
  /// 参数说明：
  /// - [manifest]: 本代的清单，含 carriers 与声明行数；
  /// - [payload]: 已校验的载荷字节流；
  /// - [generation]: 本代的世代号，必须写入落地结构的判别列；
  /// - [cancel]: 取消令牌。
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  });

  /// 删除 [generation] 这一代的全部落地物。
  ///
  /// 三处调用：落地失败回滚、取消后清理、GC 回收旧世代。
  /// **必须幂等** —— 删一个不存在的世代是正常调用，不是错误。
  Future<void> dropGeneration(int generation);
}
