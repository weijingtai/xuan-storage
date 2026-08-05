/// 基于 Firebase Realtime Database 的会合点后端 —— `CloudSignaling` 的真实后端。
///
/// 【路径布局】`signaling/{rendezvous}/members/{memberId}`（在场标识）与
/// `signaling/{rendezvous}/envelopes/{pushId}`（信封）。整条路径不含任何身份
/// 信息（验收 A7）—— 成员 id 由 `CloudSignaling` 以随机 transient id 生成，
/// 前缀固定为 `signaling`，与 scopeUid / 用户名 / 设备名无关。
///
/// 【presence 语义】对端**非正常断开**的 `departed` 由服务端 `onDisconnect`
/// 判定：本端 `open` 时通过 [onDisconnectRemove] 预先登记「连接断开时删除本端
/// 成员节点」，服务端检测到连接断开即执行 —— 这是服务端事实，不是客户端
/// 心跳 + 超时推断（契约 §6.3 后端能力要求 / 验收 A3）。
library;

import 'package:firebase_database/firebase_database.dart';
import 'package:persistence_core/model/signaling.dart';

import 'rendezvous_backend.dart';

/// RTDB 会合点后端。
final class RtdbRendezvousBackend implements RendezvousBackend {
  /// 构造一个 RTDB 会合点后端。
  ///
  /// 参数说明：
  /// - [database]: Firebase Realtime Database 实例。
  RtdbRendezvousBackend({required FirebaseDatabase database})
      : _database = database;

  final FirebaseDatabase _database;

  /// RTDB 根路径前缀（不含身份信息）。
  static const String rootPath = 'signaling';

  DatabaseReference _roomRef(RendezvousKey rv) =>
      _database.ref('$rootPath/$rv');

  DatabaseReference _memberRef(RendezvousKey rv, String memberId) =>
      _database.ref('$rootPath/$rv/members/$memberId');

  DatabaseReference _envelopesRef(RendezvousKey rv) =>
      _database.ref('$rootPath/$rv/envelopes');

  @override
  Future<void> register(RendezvousKey rv, String memberId) async {
    await _memberRef(rv, memberId).set(true);
  }

  @override
  Stream<RendezvousSnapshot> watch(RendezvousKey rv) {
    // RTDB onValue 订阅后立即触发一次当前值（契约「订阅后应立即得到当前状态」）。
    return _roomRef(rv).onValue.map(_snapshotFromEvent);
  }

  /// 把一次 RTDB 事件转成会合点快照。
  ///
  /// 参数说明：
  /// - [event]: RTDB 数据事件。
  ///
  /// 返回值：
  /// - 解析出的 [RendezvousSnapshot]。
  RendezvousSnapshot _snapshotFromEvent(DatabaseEvent event) {
    final raw = event.snapshot.value;
    final map = raw is Map
        ? Map<Object?, Object?>.from(raw)
        : <Object?, Object?>{};

    final members = <String>{};
    final membersRaw = map['members'];
    if (membersRaw is Map) {
      for (final k in membersRaw.keys) {
        members.add(k.toString());
      }
    }

    final envelopes = <RendezvousEnvelope>[];
    final envelopesRaw = map['envelopes'];
    if (envelopesRaw is Map) {
      envelopesRaw.forEach((key, value) {
        if (value is! Map) return;
        final from = value['from'];
        if (from is! String) return;
        envelopes.add(RendezvousEnvelope(
          id: key.toString(),
          from: from,
          payload: Map<String, Object?>.from(value),
        ));
      });
    }
    return RendezvousSnapshot(members: members, envelopes: envelopes);
  }

  @override
  Future<void> onDisconnectRemove(RendezvousKey rv, String memberId) async {
    // 服务端钩子：本端连接断开时自动删除本端成员节点。
    await _memberRef(rv, memberId).onDisconnect().remove();
  }

  @override
  Future<void> remove(RendezvousKey rv, String memberId) async {
    await _memberRef(rv, memberId).remove();
  }

  @override
  Future<void> writeEnvelope(
    RendezvousKey rv,
    String fromMemberId,
    Map<String, Object?> payload,
  ) async {
    // push() 生成唯一 id（内嵌时间戳，接近发送序），对端据此按序到达。
    await _envelopesRef(rv).push().set({...payload, 'from': fromMemberId});
  }
}
