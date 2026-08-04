/// XRAP 数据集清单（协议 §2.3 / §5.2）。
///
/// 清单由发布侧产出，安装侧据此判定「装不装、装完对不对」。
/// 内置世代的清单随内置载荷一起放在 persistence_assets 内。
library;

import '../storage_classification.dart';

/// 载荷格式（协议 §4.2）。决定 [DatasetMaterializer] 怎么处理字节。
enum DatasetPayloadFormat {
  /// 构建期做好的落地形态（.sqlite 等）。设备上只落位，**零解析**。
  ///
  /// 内置世代**必须**是这种 —— 3515 行的 JSON 解析加建索引会让首访卡顿。
  prebuilt,

  /// 原始文本（JSON / CSV），需在设备上解析。
  ///
  /// 仅允许用于远端世代：解析发生在用户显式触发更新之后（协议 §5.6），
  /// 不在启动或首访路径上。
  rawText,
}

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
  /// 【不参与兼容判定】—— 判定只看 [minimumAppSchemaRevision]（协议 §2.3）。
  /// 不要在此写 semver 并期望被比较：协议明确禁止字符串比较做判定（N7）。
  final String contentVersion;

  /// 读取本数据集所要求的**最低 app 结构版本**（协议 §2.4，D2 方向 B）。
  ///
  /// minSdkVersion 模型：发布方判断「这次结构改动要求消费方具备什么能力」
  /// 并写入本字段；消费方【不做兼容性推理】，只做一次整数比较：
  /// `app.appSchemaRevision >= manifest.minimumAppSchemaRevision` 即可安装。
  ///
  /// 不满足时拒绝安装、沿用现有世代，且【不下载载荷】以省带宽（不变式 I5）。
  ///
  /// 【发布方责任】只加可选字段时本值不变（老 app 忽略新字段照常工作）；
  /// 只有「老 app 读了会出错或读出错误结果」时才递增。
  final int minimumAppSchemaRevision;

  /// 载荷格式（协议 §4.2）。
  ///
  /// 内置世代恒为 [DatasetPayloadFormat.prebuilt] —— 设备上零解析是硬要求。
  final DatasetPayloadFormat payloadFormat;

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
    required this.minimumAppSchemaRevision,
    required this.payloadFormat,
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
      'minApp=$minimumAppSchemaRevision, format=${payloadFormat.name}, '
      'bytes=$payloadBytes)';
}
