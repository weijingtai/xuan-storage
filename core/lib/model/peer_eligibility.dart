import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/sync_peer.dart';

/// 存储策略 → 哪些对端有资格接收（§5.4 第一道锁的【单一判定源】）。
///
/// peekBatch（ACT 5）与 PeerFanoutPusher 的调用方（ACT 06）
/// **必须共用本类**。两处各写一份判定迟早会分叉，
/// 而分叉那天没有任何测试会红 —— 除非你把判定收在一处。
abstract final class PeerEligibility {
  /// 该 [entityType] 的记录允许走哪些通道。
  ///
  /// fail closed：[StoragePolicyRegistry.lookup] 返回 null 时返回【空集】，
  /// 不是"全部允许"。未注册意味着"没人想过它该不该外发"。
  static Set<Channel> channelsFor(String entityType) {
    final policy = StoragePolicyRegistry.lookup(entityType);
    if (policy == null) return const {};
    return policy.channels;
  }

  /// 该 [entityType] 的记录允许发给 [peers] 中的哪些对端。
  ///
  /// 实现即 `peers.where((p) => channelsFor(entityType).contains(p.channel))`。
  /// ACT 06 的 coordinator 用它算 `pushToAll` 的 eligiblePeers。
  static Set<PeerId> eligiblePeers(String entityType, Iterable<SyncPeer> peers) {
    final allowed = channelsFor(entityType);
    return peers
        .where((p) => allowed.contains(p.channel))
        .map((p) => p.peerId)
        .toSet();
  }

  /// 单个判定：该记录能不能走该通道。peekBatch 的过滤谓词。
  static bool allows(String entityType, Channel channel) {
    return channelsFor(entityType).contains(channel);
  }
}