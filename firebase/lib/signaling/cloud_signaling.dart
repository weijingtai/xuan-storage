/// 云端信令实现（RTDB 会合点中转 SDP/ICE）—— `SignalingChannel` 的
/// 第二个真实实现（裁定 C3 的落地：双方各自连到第三方会合点，在同一个
/// `RendezvousKey` 下读写信封）。
///
/// 【presence 语义】成员在场 = 会合点下存在其成员节点。**对端非正常断开的
/// `departed` 由服务端 `onDisconnect` 判定**：`open` 时经
/// [RendezvousBackend.onDisconnectRemove] 预先登记「掉线时删除本端成员节点」，
/// 服务端检测到连接断开即执行 —— 不靠客户端心跳 + 超时推断（契约 §6.3 /
/// 验收 A3）。
///
/// 【不回显】RTDB 是共享存储，天然会把自己写的读回来。`incoming` 只投递
/// `from != 本端` 的信封，并按信封 id 去重（`onValue` 每次推全量快照，
/// 不去重会重复投递）。
library;

import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_core/model/storage_error.dart';

import 'rendezvous_backend.dart';
import 'rtdb_rendezvous_backend.dart';

/// 对端已离开后仍调用 [SignalingSession.send] 抛出的错误。
///
/// 契约 §3.6「失败一律抛 StorageError 子类」；验收 A5「不静默丢弃」。
final class CloudPeerDepartedError extends StorageError {
  /// 构造对端已离开错误。
  const CloudPeerDepartedError()
      : super(
          code: 'cloud.peer_departed',
          message: '对端已离开，拒绝发送',
          reason: '信令会话的对端已 departed，再发信封不会有人接收',
          suggestion: '停止向该会合标识发送信封，等待新的会话',
        );
}

/// 会话已关闭后仍调用 [SignalingSession.send] 抛出的错误。
///
/// 契约 §3.6「失败一律抛 StorageError 子类」；验收 A5「不静默丢弃」。
/// 与 `p2p` `LocalSignaling` 的差异（p2p 是静默成功）记录在决定记录 D5，
/// 语义裁定与两端对齐待人类拍板 —— 本实现按「不静默丢弃」执行。
final class CloudSessionClosedError extends StorageError {
  /// 构造会话已关闭错误。
  const CloudSessionClosedError()
      : super(
          code: 'cloud.session_closed',
          message: '信令会话已关闭，拒绝发送',
          reason: '会话已 close，再写信封不会有人接收',
          suggestion: '为新的信令交换重新 open 一个会话',
        );
}

/// 云端信令通道：以 RTDB 为会合点中转 SDP/ICE。
class CloudSignaling implements SignalingChannel {
  /// 构造一个云端信令实现。
  ///
  /// [backend] 可注入（单测用内存 backend）；缺省用真 RTDB。
  CloudSignaling({RendezvousBackend? backend})
      : _backend = backend ??
            RtdbRendezvousBackend(database: FirebaseDatabase.instance);

  final RendezvousBackend _backend;
  final Map<RendezvousKey, _CloudSession> _sessions = {};

  @override
  Future<SignalingSession> open(
    RendezvousKey rendezvous, {
    CancellationToken? cancel,
  }) async {
    cancel?.throwIfCancelled();
    // R6：同一会合标识二次 open 时先关闭旧会话，否则旧成员节点留在会合点、
    // 旧 watch 不取消（对端永远看不到那一端 departed）。
    await _sessions[rendezvous]?.close();
    final memberId = _randomMemberId();
    final session = _CloudSession(rendezvous, memberId, _backend);
    _sessions[rendezvous] = session;
    try {
      await session._start();
    } catch (_) {
      _sessions.remove(rendezvous);
      rethrow;
    }
    return session;
  }

  @override
  Future<void> dispose() async {
    for (final s in _sessions.values) {
      await s.close();
    }
    _sessions.clear();
  }

  /// 测试钩子（验收 A3）：取指定会合标识下本端会话的成员 id。
  ///
  /// `simulateAbruptDisconnect` 用它找到对端成员 id，再触发其已登记的
  /// `onDisconnect` 删除。非测试代码不应使用。
  @visibleForTesting
  String? debugMemberIdOf(RendezvousKey rendezvous) {
    return _sessions[rendezvous]?.memberId;
  }

  /// 随机 transient 成员 id（隐私，A7）：无 scopeUid / 用户名 / 设备名，
  /// 且每次 open 换新（可轮换，防长期追踪）。
  static String _randomMemberId() {
    final r = Random();
    final hex = List.generate(8, (_) => r.nextInt(16).toRadixString(16)).join();
    return 'm-$hex';
  }
}

/// 一条已打开的云端信令会话。
final class _CloudSession implements SignalingSession {
  _CloudSession(this.rendezvous, this.memberId, this._backend);

  @override
  final RendezvousKey rendezvous;

  /// 本端在会合点下的成员 id（随机 transient，A7 隐私）。
  final String memberId;

  final RendezvousBackend _backend;

  final StreamController<SignalingEnvelope> _incoming =
      StreamController<SignalingEnvelope>.broadcast();
  final StreamController<PeerPresence> _presence =
      StreamController<PeerPresence>.broadcast();

  PeerPresence _current = PeerPresence.awaiting;

  /// 是否曾见过对端成员（awaiting → departed 的判据：没来过是 awaiting，
  /// 来过又消失才是 departed）。
  bool _peerEverSeen = false;

  /// 已消费的信封 id（onValue 全量快照去重）。
  final Set<String> _consumedEnvelopeIds = {};

  StreamSubscription<RendezvousSnapshot>? _watchSub;
  bool _closed = false;

  @override
  Stream<SignalingEnvelope> get incoming => _incoming.stream;

  @override
  Stream<PeerPresence> get peerPresence => Stream.multi((controller) {
        // 订阅即重放当前状态（契约：订阅后应立即得到当前状态）。
        // 每个订阅者独立重放 —— broadcast 的 onListen 只服务首个订阅者。
        controller.add(_current);
        final sub = _presence.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  /// 启动会话：登记成员 → 登记 onDisconnect 删除 → 监听会合点。
  ///
  /// 【顺序为什么这样】先登记成员再订阅 watch，订阅即重放的首帧就含本端
  /// 在场；`onDisconnectRemove` 必须在连接活跃时登记（变异自检：删掉这一步，
  /// 对端非正常断开不再产出 departed）。
  Future<void> _start() async {
    await _backend.register(rendezvous, memberId);
    await _backend.onDisconnectRemove(rendezvous, memberId);
    _watchSub = _backend.watch(rendezvous).listen(_onSnapshot);
  }

  /// 处理一帧会合点快照：先投递对端新信封，再判定 presence。
  ///
  /// 参数说明：
  /// - [snap]: 会合点快照。
  void _onSnapshot(RendezvousSnapshot snap) {
    if (_closed) return;

    // 信封：只投递对端发来的新信封（不回显本端 + 按 id 去重）。
    for (final e in snap.envelopes) {
      if (e.from == memberId) continue;
      if (!_consumedEnvelopeIds.add(e.id)) continue;
      try {
        _incoming.add(signalingEnvelopeFromPayload(e.payload));
      } on FormatException {
        // 坏载荷（未知类型等）跳过，不中断整帧处理。
      }
    }

    // presence：对端在场 = 成员集合里有非本端成员。
    final peerPresent = snap.members.any((m) => m != memberId);
    if (peerPresent) {
      _peerEverSeen = true;
      _emit(PeerPresence.present);
    } else if (_peerEverSeen) {
      _emit(PeerPresence.departed);
    }
    // 未见过对端且现在也没有 → 保持 awaiting。
  }

  @override
  Future<void> send(SignalingEnvelope envelope) async {
    if (_closed) throw CloudSessionClosedError();
    if (_current == PeerPresence.departed) {
      throw CloudPeerDepartedError();
    }
    await _backend.writeEnvelope(
      rendezvous,
      memberId,
      signalingEnvelopeToPayload(envelope),
    );
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    // 尽力先发 ByeEnvelope，使对端能立即 departed（契约约定）。
    try {
      await _backend.writeEnvelope(rendezvous, memberId, {'t': 'bye'});
    } catch (_) {
      // 会合点不可达，发不出去就算了 —— close 尽力而为。
    }
    // 清理自己的成员节点（对端据此判定离开）。
    try {
      await _backend.remove(rendezvous, memberId);
    } catch (_) {}
    await _teardown();
  }

  void _emit(PeerPresence p) {
    // 同值去重（R5）：后端每次写信封都会推一帧快照，若对端在场期间连发
    // 信封，present 会被重复发射；与 LocalSignaling 的「配对只发射一次」
    // 语义对齐。去重挡的是「重复的同值」，不挡状态推进（awaiting→present→departed）。
    if (p == _current) return;
    _current = p;
    if (!_presence.isClosed) _presence.add(p);
  }

  Future<void> _teardown() async {
    // R9：清空已消费信封 id 集合（与 D4「rv 一次一用」约束叠加后，
    // 长会话 / rv 复用也不会让 _consumedEnvelopeIds 无界增长）。
    _consumedEnvelopeIds.clear();
    await _watchSub?.cancel();
    _watchSub = null;
    if (!_incoming.isClosed) await _incoming.close();
    if (!_presence.isClosed) await _presence.close();
  }
}
