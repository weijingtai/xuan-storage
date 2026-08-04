/// XRAP 数据集错误类型（协议 §8.2 / 《总纲》§3.6「诊断」）。
///
/// 沿用既有 [StorageError] 的四段式（code + message + reason + suggestion），
/// code 前缀统一为 `storage.dataset_`。
///
/// 【为什么错误类型少】—— 协议的绝大多数「失败」不是异常而是
/// [InstallOutcome] 的正常取值（拒绝安装、源不可达都属正常路径，见 P5）。
/// 只有【调用方用错协议】才抛异常。
library;

import '../storage_error.dart';

/// 数据集注册违规。装配期抛出，不是运行时错误。
///
/// 触发场景（协议不变式 I8 / I9）：
/// - 注册的 policy 不是 resource + official；
/// - manifest 的 carriers 不是策略 carriers 的子集；
/// - supportedSchemaRevisions 为空集（那样永远装不进任何东西）。
class DatasetRegistrationError extends StorageError {
  /// 违规的数据集 id。
  final String datasetId;

  /// 构造一个注册违规错误。
  DatasetRegistrationError({
    required this.datasetId,
    required String violation,
    required String fix,
  }) : super(
          code: 'storage.dataset_registration_invalid',
          message: '数据集 "$datasetId" 注册违规: $violation',
          reason: violation,
          suggestion: fix,
        );
}

/// 落地实现违反协议约束。
///
/// 触发场景：[DatasetMaterializer] 触碰了不属于本世代的数据、
/// 或试图自行改动活跃指针（协议 §3.3 —— 翻转只能由安装器做）。
class DatasetMaterializerContractError extends StorageError {
  /// 违规的数据集 id。
  final String datasetId;

  /// 构造一个落地契约违规错误。
  DatasetMaterializerContractError({
    required this.datasetId,
    required String violation,
  }) : super(
          code: 'storage.dataset_materializer_contract',
          message: '数据集 "$datasetId" 的 Materializer 违反协议: $violation',
          reason: violation,
          suggestion:
              'Materializer 只能写入入参给定的 generation，'
              '不得触碰其它世代，不得改动活跃指针（协议 §3.3）。',
        );
}
