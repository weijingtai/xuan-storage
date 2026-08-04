import 'dart:async';

import 'package:persistence_core/model/sync_peer.dart';

/// 当前参与同步的对端集合。SyncRuntime 与 SyncCoordinator 的唯一枚举入口。
///
/// 【为什么要正式接口而不是一个 List 字段】：退避状态、ack 行、游标都按 peer 分片，
/// 对端集合变化时这些分片必须被清理。没有正式的 add/remove，
/// 清理时机就散落在各处，漏一处就是内存里留一批僵尸键（且不报错）。
abstract interface class PeerRegistry {
  /// 当前全部对端。顺序无意义。
  Iterable<SyncPeer> get peers;

  /// 对端标识集合，供退避 Map 做键清理。
  Set<PeerId> get peerIds;

  /// 注册一个对端。
  void register(SyncPeer peer);

  /// 移除一个对端，并【通知监听方清理该 peer 的全部分片状态】。
  void remove(PeerId peerId);

  /// 对端集合变化流。SyncRuntime 订阅它来清理退避 Map。
  Stream<Set<PeerId>> get changes;
}

/// [PeerRegistry] 的默认实现：内存集合 + 变更通知。
///
/// 变更流在 [register] / [remove] 后立即发射【最新对端集合】，
/// 订阅方（SyncRuntime）据此清理自己的 per-peer 状态分片。
final class DefaultPeerRegistry implements PeerRegistry {
  final Map<PeerId, SyncPeer> _byId = <PeerId, SyncPeer>{};
  final StreamController<Set<PeerId>> _controller =
      StreamController<Set<PeerId>>.broadcast();

  @override
  Iterable<SyncPeer> get peers => List.unmodifiable(_byId.values);

  @override
  Set<PeerId> get peerIds => Set.unmodifiable(_byId.keys);

  @override
  void register(SyncPeer peer) {
    _byId[peer.peerId] = peer;
    _emitChanges();
  }

  @override
  void remove(PeerId peerId) {
    if (_byId.remove(peerId) != null) {
      _emitChanges();
    }
  }

  @override
  Stream<Set<PeerId>> get changes => _controller.stream;

  void _emitChanges() {
    _controller.add(peerIds);
  }
}
