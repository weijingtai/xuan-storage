/// 多 peer 化契约：对端标识 / 对端能力 / 同步对端接口 / 扇出推送器。
///
/// 设计稿 §5.2。把「一个远端」升级为「N 个对端」所需的四个类型。
/// 本文件【零实现】—— 只定义类型契约，不写任何 SyncPeer 的实现类。
/// 既有单 peer 网关（*Gateway 实现类）的迁移见 ACT 02。
library;

import 'storage_classification.dart';
import 'types.dart';

/// 对端标识。是 Map 的键，因此必须有值语义的 == 与 hashCode。
///
/// 用 extension type 而非裸 String：`Map<String, SyncError?>` 无法在类型上
/// 区分「键是 peerId」还是「键是 entityType」，而 S1b 里两者都是 String，
/// 混用不会报错只会静默串数据。SDK 约束 >=3.11.0，extension type 可用且零开销。
extension type const PeerId(String value) {}

/// 一个对端报告的能力。取代 [RegionCapabilities]（§5.2.1 阻断点 6）。
///
/// 与 RegionCapabilities 的区别：那个描述的是「一个 region 的后端」，
/// 天然假设只有一个远端；本类描述「某个具体对端」，多带 peerId 与 channel，
/// 让 SyncRuntime 能按对端而非按 region 做 feature gating。
final class PeerCapabilities {
  /// 该对端的标识。
  final PeerId peerId;

  /// 该对端走哪条通道。
  final Channel channel;

  /// 每种 entityType 对应的 schema 版本号。语义同 RegionCapabilities。
  final Map<String, int> entityVersions;

  /// 该对端支持的 feature 集合（例如 'outbox_v1'）。
  final Set<String> supportedFeatures;

  /// 对端协议版本号。
  final int protocolVersion;

  /// 构造一个 [PeerCapabilities]。
  const PeerCapabilities({
    required this.peerId,
    required this.channel,
    required this.entityVersions,
    required this.supportedFeatures,
    required this.protocolVersion,
  });
}

/// 一个可同步的对端。云端 gateway 与去中心化 peer 共用本接口。
///
/// 命名（§5.2）：接口叫 SyncPeer，实现类仍叫 `*Gateway`，为的是不改既有类名。
///
/// 与 [Transport] 的分层：Transport 在下（物理连接），SyncPeer 在上（oplog 协议）。
/// [Channel.cloud] 是唯一不经 Transport 的 SyncPeer —— 它直连后端 SDK。
abstract interface class SyncPeer {
  /// 本对端标识。
  PeerId get peerId;

  /// 本对端走哪条通道。
  Channel get channel;

  /// 推送一条 outbox 记录到该对端。成功返回 null，失败返回 [SyncError]。
  Future<SyncError?> push(OutboxRecord record);

  /// 按游标增量拉取该对端的变更。语义同既有单 peer 网关的 listChanges。
  ///
  /// 返回类型收窄（S1c §2.5 定稿，人类已批准）：
  /// - [RemoteChangesPage]：正常增量页。
  /// - [IncrementalUnavailable]：对端无法提供增量（游标早于保留水位 /
  ///   oplog 已压缩 / 主动拒绝），发起方须强制切全量对齐且【不得推进游标】。
  Future<RemoteChangesResult> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  });

  /// 该对端报告的能力。
  Future<PeerCapabilities> getCapabilities();
}

/// 向【指定的合格对端】扇出推送（§5.2.2 第 4 条 + §5.4 第一道锁）。
///
/// 取代 OutboxPusher 的 1-of-N 语义：一条 outbox 记录要送达 N 个对端，
/// 每个对端各有各的成败，压不成一个 SyncError?（§5.2.1 阻断点 4）。
///
/// ⚠ **方法名里的 All 指的是「[eligiblePeers] 里的全部」，不是「持有的全部」。**
/// 没有这个参数的版本（转译 v1）会让 §5.4 的 channel 过滤被整个架空：
/// peekBatch 辛苦挑出该对端能收的记录，pushToAll 转头又发给了所有人，
/// shared 数据照样泄漏到 LAN，而两边各自的测试都是绿的（Codex R1 · P0-1）。
abstract interface class PeerFanoutPusher {
  /// 把 [record] 推给 [eligiblePeers] 中的对端，逐个返回结果。
  ///
  /// [eligiblePeers]：允许接收本条记录的对端集合，由调用方按存储策略算出
  /// （ACT 05 的 `PeerEligibility`）。**实现【必须】只推这个集合里的对端。**
  ///
  /// 约定（四条都是 ACT 06 实现时的硬要求，写在这里让契约测试能验）：
  /// - 只推 [eligiblePeers] 里的对端，一个都不许多推；
  /// - 返回的 Map 的键集合【恰好等于】 [eligiblePeers]，成功的对端值为 null；
  /// - 某个对端抛异常【不得】中断其余对端的推送，异常转成该对端的 SyncError；
  /// - 不得因为某个对端失败就把整体判为失败 —— 成败是 per-peer 的。
  Future<Map<PeerId, SyncError?>> pushToAll(
    OutboxRecord record, {
    required Set<PeerId> eligiblePeers,
  });
}
