/// S1c 全量对齐协议的消息类型（core 契约层，零实现）。
///
/// 四阶段消息线序（设计稿 §3.1 定稿）：
/// ```
/// 发起方                          对端
///   │  ① 清单分片（ManifestChunk）   ->
///   │                                 │ 双遍历比对（见 §3.1② 五类）
///   │  <- ②a 终态（EntityTerminal）   │  本地有/对方无 或 本地更新
///   │  <- ②b 索求（EntityRequest）    │  对方更新 或 本地无/对方有，请对方发来
///   │  ②b' 终态（EntityTerminal）  ->  │  回应索求
///   │  ④ 游标确认（CursorAdvance） ->  │  双方各自③过仲裁器+同事务写后
///   │                                 │  游标设为现在
/// ```
///
/// 承载流形态：四类消息复用同一条 [StreamKind.reconciliation] 逻辑流，
/// 靠消息类型字段区分（不每类开一流，避免多路复用碎片化，设计稿 §3.1 定稿）。
/// 断点续传分片 id = (scopeUid, entityType, chunkSeq)，chunkSeq 从 0 递增。
library;

/// 清单中的一行：一个实体的当前版本坐标 + 是否删除。
///
/// 直接映射 `t_entity_stamp` 的一行（S1c §2.3 定稿）：
/// - [entityId]：实体 id。
/// - [hlcPacked]：该实体的 HLC 打包值 `(l << 16) | c`（= `hlcPacked` 列）。
/// - [deviceId]：写入该版本的设备（HLC 相等时的决胜位）。
/// - [isDeleted]：墓碑标记。true 表示该行是墓碑（清单含全部未压缩戳行，
///   **含墓碑行**，S1c §3.2① 定稿）。
final class ManifestEntry {
  /// 构造一个清单行。
  const ManifestEntry({
    required this.entityId,
    required this.hlcPacked,
    required this.deviceId,
    required this.isDeleted,
  });

  /// 实体 id。
  final String entityId;

  /// HLC 打包值。
  final int hlcPacked;

  /// 写入该版本的设备。
  final String deviceId;

  /// 墓碑标记（true = 该实体已删除）。
  final bool isDeleted;
}

/// 清单分片（①）。
///
/// 按 (scopeUid, entityType) 分片，每个分片带 [chunkSeq] 与 [totalChunks]，
/// 供发起方与对端实现断点续传（S1c §3.2② 定稿）。
final class ManifestChunk {
  /// 构造一个清单分片。
  const ManifestChunk({
    required this.scopeUid,
    required this.entityType,
    required this.chunkSeq,
    required this.totalChunks,
    required this.entries,
  });

  /// 所属作用域。
  final String scopeUid;

  /// 实体类型（自由字符串）。
  final String entityType;

  /// 当前分片序号（从 0 递增）。
  final int chunkSeq;

  /// 总分片数。
  final int totalChunks;

  /// 本分片的清单行。
  final List<ManifestEntry> entries;
}

/// 实体终态（②a / ②b'）。
///
/// 对齐时发送实体的**当前状态**（不是产生它的操作序列，S1c §2.2 定稿）。
/// [hlcPacked]/[deviceId] 是该实体最近一次变更（可能是删除）的版本戳。
final class EntityTerminal {
  /// 构造一个实体终态。
  const EntityTerminal({
    required this.scopeUid,
    required this.entityType,
    required this.entityId,
    required this.isDeleted,
    required this.hlcPacked,
    required this.deviceId,
    this.payloadJson,
  });

  /// 所属作用域。
  final String scopeUid;

  /// 实体类型。
  final String entityType;

  /// 实体 id。
  final String entityId;

  /// 墓碑标记：true 表示对端视该实体为已删除（终态即墓碑）。
  final bool isDeleted;

  /// 该实体的 HLC 打包值。
  final int hlcPacked;

  /// 写入该版本的设备。
  final String deviceId;

  /// 实体终态 payload（JSON 字符串）。墓碑可空。
  final String? payloadJson;
}

/// 实体索求（②b）。
///
/// 比对发现"对方版本更新"或"本地无/对方有"时，向对方索求该实体的终态。
final class EntityRequest {
  /// 构造一个实体索求。
  const EntityRequest({
    required this.scopeUid,
    required this.entityType,
    required this.entityId,
  });

  /// 所属作用域。
  final String scopeUid;

  /// 实体类型。
  final String entityType;

  /// 实体 id。
  final String entityId;
}

/// 游标确认（④）。
///
/// 双方各自把收到的终态过仲裁器并【同事务】写记录+戳（S1b A13 门禁要求）
/// 之后，游标各自设为"现在"，由发起方发出本确认。
///
/// [recordsReconciled] 与 [blobsPending] 是两个计数（S1c §3.2③ 定稿）：
/// - [recordsReconciled]：本次对齐处理的记录条数。
/// - [blobsPending]：记录齐了但 blob 尚未下载的条数。`blobsPending > 0`
///   即「记录齐了但图片没齐」，UX 层据此显示占位。
final class CursorAdvance {
  /// 构造一个游标确认。
  const CursorAdvance({
    required this.scopeUid,
    required this.entityType,
    required this.recordsReconciled,
    required this.blobsPending,
  });

  /// 所属作用域。
  final String scopeUid;

  /// 实体类型。
  final String entityType;

  /// 本次对齐处理的记录条数。
  final int recordsReconciled;

  /// 记录齐了但 blob 尚未下载的条数。
  final int blobsPending;
}
