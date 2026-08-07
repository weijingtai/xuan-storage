/// S1c 全量对齐的端口与比对器（core 契约层，零实现）。
///
/// 四阶段消息的值类型在 [reconciliation.dart]；本文件定义这些消息的
/// 【数据源/落地点】端口，以及【双遍历五类比对】的纯函数。
///
/// 端口与编排器的关系（ACT-D）：
/// - [ManifestSource]：读本地 `t_entity_stamp` 生成清单分片（含墓碑行）。
/// - [TerminalStore]：按 entityId 读/写实体终态（含 payload）。
/// - [RemoteTerminalChannel]：与对端交换终态/索求/确认。
/// - [ManifestComparator]：纯函数，无 IO —— 双遍历五类比对的核心，
///   单测穷举它（定序正是最需要穷举的那类代码，手法照 [ConflictArbiter]）。
library;

import 'reconciliation.dart';

/// 清单数据源：读本地实体版本坐标生成清单。
///
/// 直接映射 `t_entity_stamp` 表（S1c §2.3 定稿）：
/// - 清单含【全部未压缩戳行，含 `is_deleted=true` 墓碑行】（S1c §3.2① 定稿）。
/// - 按 (scopeUid, entityType) 分片，[ManifestChunk.chunkSeq] 从 0 递增。
/// - 分片续传：发起方按 chunkSeq 逐片索取，中断后从失败片重发。
abstract interface class ManifestSource {
  /// 读取某 (scopeUid, entityType) 的下一片清单。
  ///
  /// 参数说明：
  /// - [chunkSeq]：第几片（从 0 开始）。
  /// - [pageSize]：单片最大行数（契约层参数 `manifestPageSize`，由配置注入）。
  ///
  /// 返回值：
  /// - [ManifestChunk]：本片清单。实现必须正确填 [totalChunks]。
  /// - 返回 null 表示该 (scopeUid, entityType) 没有可对齐的实体类型
  ///   （本地为空清单时 [ManifestChunk.entries] 为空即可，不需返回 null）。
  Future<ManifestChunk?> readManifestChunk({
    required String scopeUid,
    required String entityType,
    required int chunkSeq,
    required int pageSize,
  });
}

/// 实体终态存取：供对齐时按需读/写实体当前状态。
///
/// 终态含 payload（JSON 字符串）；墓碑（isDeleted=true）可无 payload。
/// 读终态用于「本地有/对方无 → 发终态」「回应索求」；
/// 写终态是【对端索求本端数据】时对端的落地点（对端侧 ②b'）。
abstract interface class TerminalStore {
  /// 读某个实体的终态；本地无该实体时返回 null。
  Future<EntityTerminal?> readTerminal({
    required String scopeUid,
    required String entityType,
    required String entityId,
  });

  /// 写一个终态到本地（创建或覆盖）。墓碑与活记录统一走本方法。
  ///
  /// ⚠ 实现【必须】把终态的戳与记录【同事务】落盘（S1b A13 门禁），
  /// 不允许戳与记录分两次独立写。
  Future<void> writeTerminal(EntityTerminal terminal);
}

/// 与对端交换对齐消息的通道（四阶段的传输承载）。
///
/// 设计稿 §3.1 定稿：四类消息复用同一条 `StreamKind.reconciliation`
/// 逻辑流，靠消息类型字段区分。本端口把该逻辑流封装成 RPC 风格方法，
/// 让编排器（与传输层实现）解耦——传输层实现走 reconciliation 流，
/// 编排器只依赖本端口。
abstract interface class RemoteTerminalChannel {
  /// 推送一片清单给对端（①）。
  Future<void> sendManifestChunk(ManifestChunk chunk);

  /// 把一批终态发给对端（②a 本地有/对方无 或 本地更新；②b' 回应索求）。
  Future<void> sendTerminals(List<EntityTerminal> terminals);

  /// 向对端索求一批终态（②b 对方更新 或 本地无/对方有）。
  Future<void> requestTerminals(List<EntityRequest> requests);

  /// 通知对端本端已完成对齐、游标将置现在（④）。
  Future<void> sendCursorAdvance(CursorAdvance advance);
}

/// 双遍历比对的一行决策结果。
///
/// 设计稿 §3.1② 定稿（五类）：
/// - [ManifestComparatorDecision.sendTerminal]：本地有/对方无，或双方都有且本地更新 → 发终态给对方。
/// - [ManifestComparatorDecision.requestTerminal]：双方都有且对方更新，或本地无/对方有 → 请对方发来。
/// - [ManifestComparatorDecision.skip]：版本相同 → 跳过。
enum ManifestComparatorDecision {
  /// 本地版本应该发给对方（对方缺 / 本地更新）。
  sendTerminal,

  /// 需要向对方索求（对方更新 / 本地缺）。
  requestTerminal,

  /// 版本相同，无需交换。
  skip,
}

/// 双遍历五类比对的纯函数。
///
/// 无 IO、无状态 —— 定序逻辑必须可被单元测试穷举，手法照
/// [ConflictArbiter]（core/lib/model/conflict_arbiter.dart）。
///
/// 两个遍历方向对应两个方法（设计稿 §3.1②）：
/// - [classifyLocalEntry]：遍历【自己】清单时，对每个本地条目分类。
/// - [classifyRemoteEntry]：遍历【收到】清单时，对每个远端条目分类。
///
/// 分类用版本戳全序比较（[VersionStamp.compareTo]），`is_deleted` 是
/// 数据位、不参与定序（S1c §3.2① 定稿，仲裁器零改动）。
abstract interface class ManifestComparator {
  /// 遍历本地清单：本地有某个实体时，决定怎么处理它。
  ///
  /// [local] 必非空（正在遍历的本端清单条目）；
  /// [remote] 为 null 表示对端清单里没有该实体。
  /// 返回 [ManifestComparatorDecision]：
  /// - 对方无 → sendTerminal
  /// - 双方都有：
  ///   · 本地戳 > 对方戳 → sendTerminal（本地更新，发给对方）
  ///   · 本地戳 < 对方戳 → requestTerminal（对方更新，索求）
  ///   · 戳相等 → skip
  ManifestComparatorDecision classifyLocalEntry({
    required ManifestEntry local,
    required ManifestEntry? remote,
  });

  /// 遍历【收到】的清单：对端有某个实体时，决定怎么处理它。
  ///
  /// [remote] 必非空（正在遍历的远端清单条目）；
  /// [local] 为 null 表示本地没有该实体。
  /// 返回 [ManifestComparatorDecision]：
  /// - 本地无 → requestTerminal（请对方发来，新设备入网核心路径）
  /// - 双方都有：与 [classifyLocalEntry] 同理按戳比较（方向对称，
  ///   同一对 (local, remote) 两个方法给出【互补】结论，除非戳相等）。
  ManifestComparatorDecision classifyRemoteEntry({
    required ManifestEntry? local,
    required ManifestEntry remote,
  });
}

/// 一次全量对齐（单个 (scopeUid, entityType)）的汇总结果。
///
/// 字段与 [CursorAdvance] 对齐（S1c §3.2③ 定稿）：两个计数直接喂给
/// [CursorAdvance]，供对端 UX 判断「记录齐了但 blob 没齐」。
class ReconciliationResult {
  /// 构造一个 [ReconciliationResult]。
  const ReconciliationResult({
    required this.scopeUid,
    required this.entityType,
    required this.recordsReconciled,
    required this.blobsPending,
    required this.conflictsLogged,
  });

  /// 所属作用域。
  final String scopeUid;

  /// 实体类型。
  final String entityType;

  /// 本次对齐处理的记录条数（§3.2③ 的 `recordsReconciled`）。
  final int recordsReconciled;

  /// 记录齐了但 blob 尚未下载的条数（§3.2③ 的 `blobsPending`）。
  /// 全量对齐只处理记录，blob 是独立阶段 → 对齐完成时 blob 一律 pending，
  /// 由实现方按实体类型判断（无 blob 的实体类型填 0）。
  final int blobsPending;

  /// 本次对齐产生的【冲突留档计数】（评审 R1 P2-2 硬性条目）：
  /// 被丢弃一方留档的条数（takeRemote 覆盖本地 / keepLocal 丢远端 都算）。
  /// 必须可观测、可计数 —— 上层据此评估折叠呈现策略（§5 定稿）。
  final int conflictsLogged;
}

/// 单侧全量对齐落库：把从对端收到的【终态批次】按本地清单比对、
/// 过仲裁器、同事务落库，产出结果与逐条决策。
///
/// 这是四阶段中「③ 过仲裁器 + 同事务写」的单侧可测单元 —— 传输交换
/// （① 清单、② 索求、②b' 回应）由编排器协调，本端口只管【本地落库】。
/// 输入是 [EntityTerminal]（终态）而非 [RemoteChange]（oplog 事件），
/// 因为全量对齐交换的是终态（S1c §2.2 定稿，不重放 oplog）。
abstract interface class LocalReconciliationApplier {
  /// 应用一批来自对端的终态。
  ///
  /// 约定（三条，ACT-D 实现时的硬要求）：
  /// - 逐条比对本地清单（[ManifestComparator]）：本地更新 → 丢弃远端
  ///   （keepLocal，留档）；远端更新或本地无 → 采用（takeRemote，覆盖时
  ///   留档本地旧版）；戳相等 → 跳过。
  /// - 采用的终态【同事务】写记录 + 戳（S1b A13 门禁）。
  /// - [isDeleted] 是数据位：终态墓碑 → 写墓碑；活终态 → 写活记录。
  ///
  /// 返回值：[ReconciliationResult]（含 [ReconciliationResult.conflictsLogged]）。
  Future<ReconciliationResult> applyTerminals({
    required String scopeUid,
    required String entityType,
    required List<EntityTerminal> terminals,
  });
}
