/// XRAP 安装端口与世代模型（协议 §5）。
///
/// 【本文件是协议的心脏】—— 世代 + 单事务指针翻转，
/// 是「半安装态不可见」（协议 P3）的落地机制。
///
/// 为什么需要它：blob 靠内容寻址与分块，「传了 60%」可独立校验
/// （《总纲》§6.1:1046）；而 row 的「装了一半」**是可以被查出来的** ——
/// 用户会读到残缺数据且无从发现。世代模型让中间态对读路径不存在。
library;

import '../cancellation_token.dart';
import 'dataset_manifest.dart';

/// 世代状态（协议 §5.1）。
enum DatasetGenerationStatus {
  /// 载荷正在下载或已下载但未校验。对读路径不可见。
  staged,

  /// sha256 校验通过，正在落地或已落地但未自检。对读路径不可见。
  verified,

  /// 完整可用。**只有此状态可被活跃指针指向**（协议不变式 I1）。
  ready,

  /// 曾经 ready，已被更新的世代取代。保留作回滚窗口（协议 §5.4）。
  superseded,

  /// 失败。载荷校验不通过、落地出错或行数自检不符。
  failed,
}

/// 一个已安装世代的完整描述。
final class InstalledDataset {
  /// 数据集 id。
  final String datasetId;

  /// 世代号。本地单调整数。
  ///
  /// 【为什么不用 sha256 当世代号】—— 落地结构每行都要带世代判别列，
  /// 用 64 字符 hex 会让几千行白背几百 KB。幂等由
  /// `UNIQUE(dataset_id, payload_sha256)` 保证，不需要世代号承担。
  final int generation;

  /// 本代的清单。
  final DatasetManifest manifest;

  /// 当前状态。
  final DatasetGenerationStatus status;

  /// 本代来自哪个源（诊断链，协议 §4.1）。
  final String sourceId;

  /// 实际落地行数。与 [DatasetManifest.declaredRowCount] 比对做自检。
  final int? actualRowCount;

  /// 落地完成时刻（UTC）。未完成为 null。
  final DateTime? installedAtUtc;

  /// 构造一个已安装世代描述。
  const InstalledDataset({
    required this.datasetId,
    required this.generation,
    required this.manifest,
    required this.status,
    required this.sourceId,
    this.actualRowCount,
    this.installedAtUtc,
  });

  /// 是否可被读路径使用。
  bool get isUsable => status == DatasetGenerationStatus.ready;
}

/// 安装结果。
///
/// **五态用 sealed 区分，因为补救动作完全不同** ——
/// 与 S1a 的 `BlobReadResult` 同一手法（《总纲》§3.2）。
///
/// 注意：其中三态是【正常路径】而非错误（协议 P5「失败沿用现存」）：
/// alreadyCurrent / rejectedSchema / sourceUnavailable 都不该抛异常，
/// 也不该让功能不可用。
sealed class InstallOutcome {
  /// 私有构造器：调用方只能走五个命名工厂。
  const InstallOutcome._();

  /// 已是最新，无动作。**冷启动的正常结果**（协议 P4：零网络）。
  const factory InstallOutcome.alreadyCurrent(InstalledDataset current) =
      InstallAlreadyCurrent;

  /// 安装成功，活跃指针已翻转到新世代。
  const factory InstallOutcome.installed(InstalledDataset installed) =
      InstallInstalled;

  /// app 结构版本不足，已拒绝（协议 §2.4 / 不变式 I5）。
  ///
  /// **这不是错误** —— 老 app 遇到要求更高的数据集的正常反应。
  /// 已在【下载载荷之前】拒绝，未消耗带宽。
  ///
  /// 两个数值都记录下来，是 D2 方向 B 的留痕要求：发布方若判断失误
  /// （该升 minimumAppSchemaRevision 却没升），据此可一眼定位是哪次发布、
  /// 哪个 app 版本区间受影响。
  const factory InstallOutcome.rejectedSchema({
    required int requiredRevision,
    required int appRevision,
    required InstalledDataset? current,
  }) = InstallRejectedSchema;

  /// 完整性校验失败：sha256 不匹配或行数不符。
  ///
  /// **安全事件，须告警**。活跃指针未动（不变式 I2/I3/I4）。
  const factory InstallOutcome.integrityFailed({
    required String reason,
    required InstalledDataset? current,
  }) = InstallIntegrityFailed;

  /// 源不可达。沿用现有世代，静默（协议 P5）。
  const factory InstallOutcome.sourceUnavailable({
    required String reason,
    required InstalledDataset? current,
  }) = InstallSourceUnavailable;
}

/// 已是最新，无动作。
final class InstallAlreadyCurrent extends InstallOutcome {
  /// 当前活跃世代。
  final InstalledDataset current;

  /// 构造 [InstallAlreadyCurrent]。
  const InstallAlreadyCurrent(this.current) : super._();
}

/// 安装成功。
final class InstallInstalled extends InstallOutcome {
  /// 新安装并已激活的世代。
  final InstalledDataset installed;

  /// 构造 [InstallInstalled]。
  const InstallInstalled(this.installed) : super._();
}

/// app 结构版本不足，已拒绝。
final class InstallRejectedSchema extends InstallOutcome {
  /// 清单要求的最低 app 结构版本。
  final int requiredRevision;

  /// 本 app 声明的结构版本。
  final int appRevision;

  /// 仍在使用的现有世代；从未装成功过则为 null。
  final InstalledDataset? current;

  /// 构造 [InstallRejectedSchema]。
  const InstallRejectedSchema({
    required this.requiredRevision,
    required this.appRevision,
    required this.current,
  }) : super._();
}

/// 完整性校验失败。
final class InstallIntegrityFailed extends InstallOutcome {
  /// 失败原因（hash 不匹配 / 行数不符），含期望值与实际值。
  final String reason;

  /// 仍在使用的现有世代。
  final InstalledDataset? current;

  /// 构造 [InstallIntegrityFailed]。
  const InstallIntegrityFailed({required this.reason, required this.current})
      : super._();
}

/// 源不可达。
final class InstallSourceUnavailable extends InstallOutcome {
  /// 不可达原因（诊断用）。
  final String reason;

  /// 仍在使用的现有世代。
  final InstalledDataset? current;

  /// 构造 [InstallSourceUnavailable]。
  const InstallSourceUnavailable({required this.reason, required this.current})
      : super._();
}

/// 数据集安装器（协议 §5）。
///
/// **唯一实现，数据集无关。** 全部模块共用同一个安装器，
/// 差异由各自的 [DatasetMaterializer] 承担（协议 §3.3）。
///
/// 这正是协议「换方案只改一处」的兑现点：改 GC 策略、改更新时机、
/// 加签名，改的都是这一个实现，全部模块不动（协议 §12）。
abstract interface class DatasetInstaller {
  /// 确保有可用世代，供读路径调用。
  ///
  /// 已有 ready 世代 → 立即返回 [InstallAlreadyCurrent]，
  /// **不发任何网络请求**（协议 P4）。无 ready 世代时安装内置世代。
  ///
  /// 【这是读路径唯一允许调用的安装方法】—— 它不触网。
  Future<InstallOutcome> ensureInstalled(
    String datasetId, {
    CancellationToken? cancel,
  });

  /// 显式检查并安装更新。**会触网。**
  ///
  /// 合法触发点仅三个（协议 §5.6 / D6）：
  /// 用户手动检查 / 首次用到且无 ready 世代 / 显式业务动作。
  /// **不得在冷启动路径上调用**（协议 N8）。
  ///
  /// 安装序列见协议 §5.2：取清单 → 版本判定 → 幂等判定 → 取载荷 →
  /// 校验 → 落地 → 行数自检 → 单事务翻转指针 → 旧代转 superseded。
  Future<InstallOutcome> checkForUpdate(
    String datasetId, {
    CancellationToken? cancel,
  });

  /// 当前活跃世代。无则返回 null（调用方须 fail closed）。
  ///
  /// **读路径的唯一入口**（协议 §5.2 第 8 步）：
  /// 落地结构必须按此结果解析世代，不得直接查最大世代号。
  Future<InstalledDataset?> active(String datasetId);

  /// 全部世代，含 superseded 与 failed。诊断与容量显示用。
  Future<List<InstalledDataset>> generations(String datasetId);

  /// 回滚到指定世代（协议 §5.4 / D4）。
  ///
  /// 目标必须是 [DatasetGenerationStatus.superseded] 或 ready，
  /// 否则拒绝（不变式 I1）。当前阶段仅供诊断与故障处置，UI 不暴露。
  Future<InstallOutcome> rollbackTo(String datasetId, int generation);

  /// 回收旧世代（协议 §5.5 / D5）。
  ///
  /// 保留最近 1 个 superseded 世代作回滚窗口，更早的立即回收。
  /// [only] 非空时只处理该数据集。返回释放的字节数。
  ///
  /// **绝不回收活跃世代**，也不回收内置世代的兜底能力。
  Future<int> collectGarbage({String? only});
}
