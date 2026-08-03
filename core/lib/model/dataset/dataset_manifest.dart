/// XRAP 数据集清单（协议 §2.3 / §5.2）。
///
/// 清单由发布侧产出，安装侧据此判定「装不装、装完对不对」。
/// 内置世代的清单随内置载荷一起放在 persistence_assets 内。
library;

import '../storage_classification.dart';

/// 数据集清单：描述某个数据集某个版本的全部元数据。
///
/// 【值对象】同值相等。不含任何行为，判定逻辑全在 [DatasetInstaller]。
final class DatasetManifest {
  /// 数据集稳定标识，跨版本不变。
  ///
  /// 命名约定（协议 §2.1，强制）：`<域>.<名>`，全小写下划线分词，
  /// 例 'geo.admin_division'。**必须与 StoragePolicyRegistry 的
  /// entityType 一致** —— 策略查表依赖这一点。
  final String datasetId;

  /// 内容版本。人可读，用于展示与诊断。
  ///
  /// 【不参与兼容判定】—— 判定只看 [schemaRevision]（协议 §2.3）。
  /// 不要在此写 semver 并期望被比较：协议明确禁止字符串比较做判定（N7）。
  final String contentVersion;

  /// 结构版本。**机械兼容判定的唯一依据**（协议 §2.4）。
  ///
  /// 安装侧规则：不在 [DatasetDescriptor.supportedSchemaRevisions] 内
  /// 即拒绝安装，沿用现有世代，且【不下载载荷】以省带宽（不变式 I5）。
  final int schemaRevision;

  /// 落地载体（协议 §2.2）。复用 S1a 的 [Carrier]，不新造形态枚举。
  ///
  /// 必须是注册策略 carriers 的【子集】，否则注册期抛异常（不变式 I8）。
  final Set<Carrier> carriers;

  /// 载荷整包 sha256（hex 小写）。
  ///
  /// **安装前校验，不匹配绝不进入落地阶段**（不变式 I3）。
  /// 这是 row 类资源唯一的完整性锚点 —— row 没有 blob 的分块 hash 可用。
  final String payloadSha256;

  /// 载荷字节数。用于进度显示与续传水位比对。
  final int payloadBytes;

  /// 声明行数。[carriers] 含 [Carrier.row] 时必填。
  ///
  /// 落地后按此自检实际行数，不符即判完整性失败（不变式 I4）。
  /// 纯 blob 数据集为 null。
  final int? declaredRowCount;

  /// 载荷相对路径。远端世代有值；内置世代为 null（载荷在 asset 内）。
  final String? payloadPath;

  /// 发布时刻（UTC）。仅用于诊断，不参与任何判定。
  final DateTime publishedAtUtc;

  /// 构造一份清单。
  const DatasetManifest({
    required this.datasetId,
    required this.contentVersion,
    required this.schemaRevision,
    required this.carriers,
    required this.payloadSha256,
    required this.payloadBytes,
    this.declaredRowCount,
    this.payloadPath,
    required this.publishedAtUtc,
  });

  /// 是否需要行数自检（即 carriers 是否含 row）。
  bool get requiresRowCountCheck => carriers.contains(Carrier.row);

  /// 摘要字符串，用于诊断日志。
  @override
  String toString() =>
      'DatasetManifest($datasetId, content=$contentVersion, '
      'schema=$schemaRevision, bytes=$payloadBytes)';
}
