/// XRAP 数据集装配期声明（协议 §3）。
///
/// 【接入方每天要写的东西】—— 一个模块「接入 XRAP」的全部动作，
/// 就是构造一个 [DatasetDescriptor] 并调用 `DatasetRegistry.register`。
library;

import '../storage_policy.dart';
import 'dataset_manifest.dart';
import 'dataset_materializer.dart';

/// 一个数据集的装配期声明。
///
/// 这是【消费方（app 代码）的编译期事实】：本 app 的结构版本、
/// 内置了哪个世代、用什么落地。与 [DatasetManifest]（发布方的事实）配对，
/// 二者比对产出安装判定（协议 §2.4）。
final class DatasetDescriptor {
  /// 数据集稳定标识。必须与 [bundledManifest] 的 datasetId 一致。
  final String datasetId;

  /// **本 app 代码的结构版本**（协议 §2.4，D2 方向 B）。
  ///
  /// minSdkVersion 模型：判定是
  /// `appSchemaRevision >= manifest.minimumAppSchemaRevision`。
  /// 消费方【不做兼容性推理】，只比大小 —— 判断责任在发布方。
  ///
  /// 何时递增：本 app 的落地逻辑升级到能读更高结构的数据时。
  final int appSchemaRevision;

  /// 存储策略。必须是 `StoragePolicy.resource` 且 publisher 为 official
  /// （协议不变式 I9）。策略的 carriers 是 manifest carriers 的上界（I8）。
  final StoragePolicy policy;

  /// 内置世代的清单。**恒存在** —— 内置资源是永久兜底（协议 P5）。
  ///
  /// 内置世代作为 generation 0 参与统一机制（协议 §4.2 / D3），
  /// 且其 payloadFormat **必须**是 [DatasetPayloadFormat.prebuilt] ——
  /// 设备上零解析是硬要求，注册期强制。
  final DatasetManifest bundledManifest;

  /// 落地器工厂。**唯一的可插拔点**（协议 §3.3）。
  ///
  /// 用工厂而非实例：落地器可能持有数据库连接等资源，
  /// 由安装器在需要时创建、用完释放。
  final DatasetMaterializer Function() materializer;

  /// 构造一个数据集声明。
  ///
  /// 【不在构造器校验】—— 校验发生在 `DatasetRegistry.register`，
  /// 与 S1a 的 StoragePolicyRegistry 保持同一形制：
  /// 结构性约束靠参数表，语义约束靠注册期抛异常（《总纲》§2.3.0）。
  const DatasetDescriptor({
    required this.datasetId,
    required this.appSchemaRevision,
    required this.policy,
    required this.bundledManifest,
    required this.materializer,
  });

  /// 本 app 是否能消费给定清单（协议 §2.4，只比大小）。
  bool supports(DatasetManifest m) =>
      appSchemaRevision >= m.minimumAppSchemaRevision;
}
