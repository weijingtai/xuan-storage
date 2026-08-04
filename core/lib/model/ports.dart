import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';

/// Persistence-core ports (contracts) for local-first sync.
///
/// 功能说明：
/// - 本文件定义同步引擎与具体存储/网络实现之间的接口契约（Ports）。
/// - 上层（SyncCoordinator/SyncRuntime）只依赖这些接口，不依赖具体实现（Drift/Firebase）。
///
/// 设计原则：
/// - 以 scopeUid（通常为用户 uid）作为多账号隔离的最小单位。
/// - 方法签名尽量保持最小、稳定，便于跨子项目复用。

/// Local outbox storage.
///
/// 功能说明：
/// - 存储“本地已确认写入但尚未成功同步到远端”的操作记录（[OutboxRecord]）。
/// - 提供批量取出待推送记录、以及推送成功/失败后的状态回写。
///
/// 约束：
/// - 推荐实现保证 peekBatch 的返回顺序稳定（通常按 createdAtUtc 升序）。
/// - 必须以 [scopeUid] 做隔离，避免跨账号错推。
abstract class OutboxStore {
  /// Enqueues a new outbox record.
  ///
  /// 参数说明：
  /// - [record]: 待入队的 outbox 记录。
  ///
  /// 约束：
  /// - 推荐以 operationId 作为唯一键，避免重复入队导致重复推送。
  Future<void> enqueue(OutboxRecord record);

  /// Returns a batch of outbox records for pushing.
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid（通常为用户 uid）。
  /// - [peerId]: 只返回【该对端尚未 ack】的记录。这是多 peer 的核心 ——
  ///   同一条 operationId 对 cloud 已成功、对 lan 仍 pending 是常态。
  /// - [limit]: 最大返回条数。
  ///
  /// 返回值：
  /// - 待推送的 outbox 记录列表（对 [peerId] 而言可推的：无 ack 行 + pending/failed）。
  ///
  /// 约束：
  /// - 返回的记录应当是“可重试”的集合：pending + failed（不包含 dead/success）。
  /// - 推荐排序稳定（createdAtUtc 升序），便于重试公平与测试确定性。
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required PeerId peerId,
    required int limit,
  });

  /// Marks one outbox record as successfully pushed.
  ///
  /// 参数说明：
  /// - [operationId]: 要标记的操作 id。
  /// - [peerId]: 标记对该对端推送成功。
  /// - [atUtc]: 标记时间（UTC）。
  ///
  /// 语义变更（§5.2.1 阻断点 3）：success 是 (operationId, peerId) 二元组的属性，
  /// 不是 operationId 的属性。对 cloud 成功【不得】让该行退出其他对端的 peekBatch。
  ///
  /// 约束：
  /// - 建议实现允许幂等调用（重复 success 不应报错）。
  /// - 【不得】删除 t_outbox 行 —— 删除是 compaction 的事（§5.3），
  ///   否则其他对端永远拿不到这条记录。
  Future<void> markSuccess({
    required String operationId,
    required PeerId peerId,
    required DateTime atUtc,
  });

  /// Marks one outbox record as failed.
  ///
  /// 参数说明：
  /// - [operationId]: 要标记的操作 id。
  /// - [peerId]: 标记对该对端推送失败。
  /// - [attempt]: 本次失败后该对端的尝试次数。
  /// - [errorCode]: 错误分类 code（建议与 [SyncErrorCode] 对齐）。
  /// - [errorMessage]: 用于诊断的错误信息。
  /// - [atUtc]: 标记时间（UTC）。
  /// - [isDead]: 是否进入死信（达到最大尝试次数阈值）。
  ///
  /// 语义变更（§5.2.1 阻断点 3）：attempt 与 isDead 同样是 per-peer 的 ——
  /// 一个长期离线的 LAN peer 达到 dead 阈值，【不得】影响该行对 cloud 的可推送性。
  ///
  /// 约束：
  /// - 当 [isDead] 为 true 时，该记录对 [peerId] 不应再被 [peekBatch] 返回。
  Future<void> markFailed({
    required String operationId,
    required PeerId peerId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  });

  /// 读取【某一条记录对某一个对端】的当前重试次数。
  ///
  /// 【新增方法，不是签名变更】。ACT 06 的 coordinator 要用它算下一次的 attempt ——
  /// 没有这个读取端口，调用方只能退回 `record.attempt`（t_outbox 上的全局字段），
  /// 于是两个对端共用一个计数：cloud 成功也会被 lan 的失败推高，
  /// 进而在 10 次内把 cloud 也推成 dead。
  ///
  /// 约束：
  /// - ack 行不存在（从未推送过）时返回 0，不抛异常。
  Future<int> attemptFor({
    required String operationId,
    required PeerId peerId,
  });

  /// 该对端的待推送积压数（含 ack 行不存在的记录）。
  Future<int> backlogCount({required String scopeUid, required PeerId peerId});

  /// 订阅该对端的待推送积压数。
  Stream<int> watchBacklogCount({
    required String scopeUid,
    required PeerId peerId,
  });

  /// 该对端的死信数（该对端 ack 行 status = 'dead' 的条数）。
  Future<int> deadCount({required String scopeUid, required PeerId peerId});
}

/// Storage for per-scope, per-entityType pull cursors and sync markers.
///
/// 功能说明：
/// - 存储远端增量拉取游标（cursor），使 pull 支持断点续拉。
/// - 提供 pull/push 的时间戳标记（用于诊断/可观测性）。
///
/// 约束：
/// - cursor 必须按 (scopeUid, peerId, entityType) 隔离。
/// - [setCursorIfNewer] 必须避免 cursor 回退，且只在该三元组那一行内比较
///   —— 跨 peer 的游标本来不可比，混用会导致「换了个 peer 就从错误的位置续拉」。
abstract class SyncStateStore {
  /// Gets the last stored cursor for (scopeUid, peerId, entityType).
  ///
  /// 返回值：
  /// - 若该对端从未拉取过则返回 null。
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  });

  /// Sets cursor only if it is newer than the current one.
  ///
  /// 参数说明：
  /// - [cursor]: 候选 cursor。
  /// - [atUtc]: 写入时间（UTC）。
  ///
  /// 约束：
  /// - 若 cursor 类型与既有 cursor 不一致，推荐拒绝覆盖（避免混用策略）。
  /// - 「不回退」判定只比较 (scopeUid, peerId, entityType) 那一行，不跨 peer。
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  });

  /// Clears cursor and markers for (scopeUid, peerId, entityType).
  ///
  /// 用途：
  /// - 账号切换/数据重置/强制全量重拉时使用。
  Future<void> clear({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  });

  /// Records that pull succeeded for (scopeUid, peerId, entityType) at [atUtc].
  Future<void> markPulledAt({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required DateTime atUtc,
  });

  /// Records that push succeeded for [scopeUid] at [atUtc].
  Future<void> markPushedAt({
    required String scopeUid,
    required PeerId peerId,
    required DateTime atUtc,
  });
}

/// Applies remote changes to local storage.
///
/// 功能说明：
/// - 将 [SyncPeer.listChanges] 返回的 [RemoteChange] 回填到本地数据库。
/// - 给出逐条处理结果（outcomes），并指示是否允许推进 cursor。
///
/// 关键约束（防回环）：
/// - 回填本地不得进入 outbox（否则会产生远端->本地->远端的回环）。
abstract class LocalApplier {
  /// Applies a batch of remote changes into local storage.
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid。
  /// - [entityType]: 实体类型。
  /// - [changes]: 从远端拉取到的变更集合。
  ///
  /// 返回值：
  /// - [LocalApplyResult]：包含 appliedCount、outcomes、lastError、canAdvanceCursor。
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  });
}

/// Device identity metadata attached to operations.
///
/// 用途：
/// - 诊断同步问题（区分不同设备）。
/// - 冲突处理的平局破坏因子（例如 deviceId）。
/// - oplog 审计信息。
class DeviceIdentity {
  /// Creates a [DeviceIdentity].
  ///
  /// 参数说明：
  /// - [deviceId]: 设备唯一标识（稳定且不含敏感信息）。
  /// - [platform]: 平台标识（例如 ios/android/macos/windows/web）。
  /// - [formFactor]: 设备形态（例如 phone/tablet/desktop）。
  /// - [model]/[osVersion]/[appVersion]: 可选诊断信息。
  const DeviceIdentity({
    required this.deviceId,
    required this.platform,
    required this.formFactor,
    this.model,
    this.osVersion,
    this.appVersion,
  });

  final String deviceId;
  final String platform;
  final String formFactor;
  final String? model;
  final String? osVersion;
  final String? appVersion;
}

/// Provides [DeviceIdentity].
///
/// 典型实现：
/// - Flutter 侧通过 platform channel / package_info_plus / device_info_plus 获取。
abstract class DeviceIdentityProvider {
  /// Returns current device identity.
  Future<DeviceIdentity> get();
}

/// Provides current sync scope uid.
///
/// 典型实现：
/// - 将具体认证系统（FirebaseAuth/自研账号）与同步引擎解耦。
abstract class AuthScopeProvider {
  /// Returns current scope uid.
  ///
  /// 约定：
  /// - 返回值通常等同于当前登录用户的 uid。
  Future<String> getScopeUid();
}

/// Resolves the physical path for a shared database file.
///
/// 功能说明：
/// - 跨 APP 共享同一个 `.db` 文件时，需要定位到系统级共享存储。
/// - iOS: 通过 App Groups 的 containerURLForSecurityApplicationGroupIdentifier。
/// - Android: 通过 External/Internal shared storage 分区。
///
/// 使用场景：
/// - 单体 APP（如太乙独立版、奇门独立版）同时运行时，利用 WAL + Shared Storage
///   共享同一个物理 `.db` 文件，避免数据孤岛。
///
/// 约束：
/// - [groupId] 为 null 时，回退到标准本地存储路径。
/// - 返回的路径必须是绝对路径，以数据库文件名结尾。
abstract interface class ISharedPathProvider {
  /// Resolves the absolute physical path for a shared database.
  ///
  /// 参数说明：
  /// - [dbName]: 数据库文件名（如 'xuan.db'）。
  ///
  /// 返回值：
  /// - 绝对路径字符串，以 [dbName] 结尾。
  ///
  /// 平台逻辑：
  /// - 有 groupId → 共享容器路径（iOS App Groups / Android Shared Storage）。
  /// - 无 groupId → 标准应用私有路径。
  Future<String> getDatabasePath(String dbName);
}
