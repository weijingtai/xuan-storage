/// XRAP 世代状态存储端口（协议 §5 的持久化抽象）。
///
/// 安装器的世代状态（哪些世代、各世代状态、活跃指针）通过本端口持久化。
/// 内存版用于测试，drift 版用于生产。安装序列逻辑（§5.2）在
/// [DatasetInstallerBase] 里写一遍，存储后端可替换。
///
/// 【为什么不在安装器里直接存】--协议 §3.3「唯一可插拔点是 materializer」
/// 指的是落地形态可插拔；而世代状态的存储技术（内存 / drift / 文件）
/// 是正交维度，用本端口隔离，不污染安装序列逻辑。
library;

import 'dataset_installer.dart';

/// 世代状态存储端口。
///
/// 实现需保证：
/// - [saveGeneration] 幂等（同 datasetId+generation 重复写覆盖）
/// - [setActiveGeneration] 与 [findReadyGeneration] 配合满足不变式 I1
///   （活跃指针只能指向 status==ready 的世代）
abstract interface class DatasetGenerationStore {
  /// 查找指定世代记录。不存在返回 null。
  Future<InstalledDataset?> findGeneration(String datasetId, int generation);

  /// 列出某数据集的全部世代。
  Future<List<InstalledDataset>> listGenerations(String datasetId);

  /// 保存（覆盖写）一个世代记录。
  Future<void> saveGeneration(InstalledDataset record);

  /// 删除指定世代记录。幂等（不存在不报错）。
  Future<void> deleteGeneration(String datasetId, int generation);

  /// 取活跃 generation 号。无返回 null。
  Future<int?> activeGeneration(String datasetId);

  /// 设置活跃 generation 号。
  /// 调用方须保证目标世代 status==ready（不变式 I1，由安装器在翻转前保证）。
  Future<void> setActiveGeneration(String datasetId, int generation);
}
