/// 内存会合点后端 —— `CloudSignaling` 契约测试的真替身。
///
/// 【为什么它配得上「真」字】派工 §7：`onDisconnect` 是真实 RTDB 的**服务端
/// 行为**，本地 fake 通常不实现它。本后端**真的实现了这个语义**：
/// - `onDisconnectRemove` 把「断开时删除本端成员节点」登记进动作表；
/// - [triggerOnDisconnect] 执行那条**已登记**的动作（模拟服务端检测到连接断开
///   后执行预先登记的删除）—— 触发的是登记，不是手动删节点；
/// - 若从未登记（实现变异），触发后什么都不发生，成员节点保留 —— 这就是
///   「删掉登记步骤 → departed 相关测试必须变红」的抓手。
library;

import 'dart:async';
import 'dart:convert';

import 'package:persistence_core/model/signaling.dart';

import 'package:persistence_firebase/signaling/rendezvous_backend.dart';
import 'package:persistence_firebase/signaling/rtdb_rendezvous_backend.dart';

/// 内存会合点后端（测试替身）。
final class MemoryRendezvousBackend implements RendezvousBackend {
  final Map<RendezvousKey, _Room> _rooms = {};

  /// 成员 id → 断开时执行的动作（登记自 [onDisconnectRemove]）。
  final Map<String, Future<void> Function()> _disconnectActions = {};

  @override
  Future<void> register(RendezvousKey rv, String memberId) async {
    final room = _rooms.putIfAbsent(rv, _Room.new);
    room.members.add(memberId);
    room.notify();
  }

  @override
  Stream<RendezvousSnapshot> watch(RendezvousKey rv) {
    final room = _rooms.putIfAbsent(rv, _Room.new);
    return room.stream;
  }

  @override
  Future<void> onDisconnectRemove(RendezvousKey rv, String memberId) async {
    // 登记「断开时删除本端成员节点」：本端掉线时由（模拟的）服务端执行。
    _disconnectActions[memberId] = () async {
      final room = _rooms[rv];
      if (room == null) return;
      room.members.remove(memberId);
      room.notify();
    };
  }

  @override
  Future<void> remove(RendezvousKey rv, String memberId) async {
    final room = _rooms[rv];
    if (room == null) return;
    room.members.remove(memberId);
    room.notify();
  }

  @override
  Future<void> writeEnvelope(
    RendezvousKey rv,
    String fromMemberId,
    Map<String, Object?> payload,
  ) async {
    final room = _rooms.putIfAbsent(rv, _Room.new);
    final id = 'e${room.nextEnvelopeId++}';
    room.envelopes.add(
      RendezvousEnvelope(id: id, from: fromMemberId, payload: payload),
    );
    room.notify();
  }

  @override
  String pathOf(RendezvousKey rv, String memberId) =>
      // 绑定真实实现同一事实源：格式与前缀都取 `RtdbRendezvousBackend.rootPath`，
      // 不许在这里另写一个 'signaling' 字面量（验收 F1：fake 自己硬编码 = 复述
      // 约定，不是读回实现）。rootPath 被污染时 A7 断言必须跟着变红。
      '${RtdbRendezvousBackend.rootPath}/$rv/members/$memberId';

  /// 模拟服务端检测到 [memberId] 掉线：执行其**已登记**的断开删除动作。
  ///
  /// 若该成员从未登记过 `onDisconnect`（实现变异），什么都不做 ——
  /// 这正是「掉线会不会删」与「删了会怎样」的区别。
  Future<void> triggerOnDisconnect(String memberId) async {
    final action = _disconnectActions[memberId];
    if (action != null) await action();
  }

  /// 该成员是否已登记断开删除（A3 加严断言用）。
  bool debugHasRegisteredDisconnect(String memberId) {
    return _disconnectActions.containsKey(memberId);
  }

  /// 会合点下当前在场成员 id 集合。
  Set<String> debugMemberIds(RendezvousKey rv) {
    return _rooms[rv]?.members.toSet() ?? {};
  }

  /// 抹掉该成员已登记的断开删除（变异守卫测试注入用）。
  void debugForgetOnDisconnect(String memberId) {
    _disconnectActions.remove(memberId);
  }

  /// 把会合点序列化成「路径 + 载荷」文本，供 A7 隐私断言**读回**扫描。
  ///
  /// 返回值等价于 RTDB 上该会合点的路径段与全部信封载荷 —— 断言的正是
  /// 实现真正写到会合点的内容，而不是注释里的承诺。路径段经 [pathOf]
  /// 构造（绑定 `RtdbRendezvousBackend.rootPath` 这一事实源）。
  String debugSerializedRoom(RendezvousKey rv) {
    final room = _rooms[rv];
    if (room == null) return '${pathOf(rv, '?')} (empty)';
    final membersText = room.members.join(',');
    final envelopesText = room.envelopes
        .map((e) => '${e.id}:${e.from}:${jsonEncode(e.payload)}')
        .join(';');
    final pathText = room.members.isEmpty
        ? pathOf(rv, '?')
        : pathOf(rv, room.members.first);
    return '$pathText members=[$membersText] envelopes=[$envelopesText]';
  }
}

/// 一个会合点房间：成员集合 + 信封队列 + 快照广播。
final class _Room {
  final Set<String> members = {};
  final List<RendezvousEnvelope> envelopes = [];
  int nextEnvelopeId = 0;

  final StreamController<RendezvousSnapshot> _controller =
      StreamController<RendezvousSnapshot>.broadcast();

  /// 订阅即重放当前快照（契约：订阅后应立即得到当前状态）。
  Stream<RendezvousSnapshot> get stream => Stream.multi((controller) {
        controller.add(_currentSnapshot());
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  void notify() {
    if (!_controller.isClosed) {
      _controller.add(_currentSnapshot());
    }
  }

  RendezvousSnapshot _currentSnapshot() {
    return RendezvousSnapshot(
      members: members.toSet(),
      envelopes: List.of(envelopes),
    );
  }
}
