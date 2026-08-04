import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';

/// [PeerFanoutPusher] 的默认实现：把一条记录并发推给全部对端。
///
/// 与 [RemoteGatewayRouter] 的分工：router 是「按 region 选一个云端后端」，
/// 是【路由】；本类是「推给所有对端」，是【扇出】。两者不可互相取代 ——
/// router 仍然作为其中一个 peer 参与扇出（它对外表现为单个 cloud peer）。
final class DefaultPeerFanoutPusher implements PeerFanoutPusher {
  /// [peers]：本实例【持有】的全部对端。顺序不影响结果（并发执行）。
  ///
  /// ⚠ 持有 ≠ 会推。实际推给谁由 [pushToAll] 的 `eligiblePeers` 决定。
  DefaultPeerFanoutPusher({required List<SyncPeer> peers}) : _peers = peers;

  final List<SyncPeer> _peers;

  /// 当前持有的对端标识，用于诊断「这条记录【本可以】被推给谁」。
  List<PeerId> get peerIds => _peers.map((p) => p.peerId).toList();

  /// 把 [record] 推给 [eligiblePeers] 中的对端，逐个返回结果。
  ///
  /// ⚠ **签名必须与 ACT 01 的 [PeerFanoutPusher] 契约逐字一致** ——
  /// 少了 `eligiblePeers` 这个 named 参数就不是 override 而是新方法，
  /// 编译器会以"未实现抽象成员"报错；就算侥幸编译过，
  /// §5.4 的 channel 过滤也会被整个架空（Codex R1 · P0-1、R2 复核）。
  ///
  /// [eligiblePeers] 里出现了本实例【不持有】的 PeerId 时：
  /// 该项在返回 Map 里给一个 `SyncErrorCode.unknown` 的 SyncError，
  /// message 写明"未注册的对端"。**不要静默丢弃**——
  /// 丢弃会让调用方以为推成功了（Map 里没有条目 = 没推 = 下轮重推，
  /// 但调用方按 eligiblePeers 遍历时会拿到 null，等同于成功）。
  @override
  Future<Map<PeerId, SyncError?>> pushToAll(
    OutboxRecord record, {
    required Set<PeerId> eligiblePeers,
  }) async {
    final heldById = {for (final p in _peers) p.peerId: p};

    final futures = <Future<MapEntry<PeerId, SyncError?>>>[];
    for (final peerId in eligiblePeers) {
      final peer = heldById[peerId];
      if (peer == null) {
        futures.add(
          Future.value(
            MapEntry(
              peerId,
              SyncError(
                code: SyncErrorCode.unknown,
                message: '未注册的对端: ${peerId.value}（pusher 不持有该 peer）',
              ),
            ),
          ),
        );
        continue;
      }
      futures.add(_pushOne(peer, record));
    }

    final entries = await Future.wait(futures);
    return Map<PeerId, SyncError?>.fromEntries(entries);
  }

  /// 推给单个对端，把异常转成 SyncError。
  ///
  /// ⚠ 必须在这里 catch：直接 `Future.wait([...]).catchError(...)` 会在
  /// 任一 future 抛出时立即以该异常完成（其余结果丢失），
  /// 无法保证"某个对端失败不中断其余对端"。
  Future<MapEntry<PeerId, SyncError?>> _pushOne(
    SyncPeer peer,
    OutboxRecord record,
  ) async {
    try {
      final error = await peer.push(record);
      return MapEntry(peer.peerId, error);
    } catch (e) {
      return MapEntry(
        peer.peerId,
        SyncError(
          code: SyncErrorCode.unknown,
          message: '${peer.peerId.value}: $e',
        ),
      );
    }
  }
}
