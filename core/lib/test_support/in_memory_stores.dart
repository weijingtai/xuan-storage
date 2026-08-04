import 'dart:async';

import 'package:persistence_core/model/peer_eligibility.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';

/// [OutboxStore] 的内存实现，仅供测试与 parity 比对使用。
///
/// 【本类是 drift 实现的可执行规格】：ack 按 (operationId, peerId) 二元组存，
/// **不是**给 OutboxRecord 加一个 status 字段 —— 记录本身只有一份，ack 有 N 份。
///
/// 行为约定（与 drift 实现必须逐条一致）：
/// - enqueue 只存记录，【不】预建任何对端的 ack 行（对端集合入队时还不确定）。
/// - 可推判定：该 (operationId, peerId) 的 ack 行【不存在】或 status 为
///   'pending'/'failed' 时返回；'success'/'dead' 时不返回。
/// - markSuccess / markFailed 用 upsert 写 ack 行，惰性创建。
/// - attempt 归 ack 行管，t_outbox.attempt 是单 peer 时代遗留，本类不更新记录。
final class InMemoryOutboxStore implements OutboxStore {
  final Map<String, OutboxRecord> _recordsById = <String, OutboxRecord>{};
  final Map<String, _PeerAck> _acksByKey = <String, _PeerAck>{};
  final Map<String, StreamController<int>> _backlogControllersByKey =
      <String, StreamController<int>>{};

  String _ackKey(String operationId, PeerId peerId) =>
      '$operationId|${peerId.value}';

  String _backlogKey(String scopeUid, PeerId peerId, Channel channel) =>
      '$scopeUid|${peerId.value}|${channel.name}';

  StreamController<int> _controllerFor(
    String scopeUid,
    PeerId peerId,
    Channel channel,
  ) {
    final key = _backlogKey(scopeUid, peerId, channel);
    return _backlogControllersByKey.putIfAbsent(
      key,
      () => StreamController<int>.broadcast(),
    );
  }

  Future<void> _emitBacklog(
    String scopeUid,
    PeerId peerId,
    Channel channel,
  ) async {
    if (!_backlogControllersByKey
        .containsKey(_backlogKey(scopeUid, peerId, channel))) {
      return;
    }
    _controllerFor(scopeUid, peerId, channel).add(
      await backlogCount(
        scopeUid: scopeUid,
        peerId: peerId,
        channel: channel,
      ),
    );
  }

  /// enqueue 不知道对端集合，只能通知该 scope 下所有已订阅的对端。
  Future<void> _emitBacklogForScope(String scopeUid) async {
    for (final key in _backlogControllersByKey.keys.toList()) {
      final parts = key.split('|');
      if (parts.length != 3) continue;
      final scope = parts[0];
      if (scope != scopeUid) continue;
      final peerValue = parts[1];
      final channelName = parts[2];
      final channel = Channel.values.firstWhere(
        (c) => c.name == channelName,
        orElse: () => Channel.cloud,
      );
      await _emitBacklog(scope, PeerId(peerValue), channel);
    }
  }

  /// 入队一条 outbox 记录（内存 fake，可执行规格）。
  @override
  Future<void> enqueue(OutboxRecord record) async {
    _recordsById[record.operationId] = record;
    await _emitBacklogForScope(record.scopeUid);
  }

  bool _isPeekable(String operationId, PeerId peerId) {
    final ack = _acksByKey[_ackKey(operationId, peerId)];
    if (ack == null) return true;
    return ack.status == 'pending' || ack.status == 'failed';
  }

  /// 取一批待推送记录（含 channel 过滤）（内存 fake，可执行规格）。
  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
    required int limit,
  }) async {
    final batch = _recordsById.values
        .where((r) => r.scopeUid == scopeUid)
        .where((r) => _isPeekable(r.operationId, peerId))
        .where((r) => PeerEligibility.allows(r.entityType, channel))
        .toList(growable: false)
          ..sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));

    if (limit <= 0) return const [];
    return batch.length <= limit ? batch : batch.sublist(0, limit);
  }

  /// 标记某记录对该对端推送成功（内存 fake，可执行规格）。
  @override
  Future<void> markSuccess({
    required String operationId,
    required PeerId peerId,
    required DateTime atUtc,
  }) async {
    _acksByKey[_ackKey(operationId, peerId)] = _PeerAck(
      status: 'success',
      atUtc: atUtc,
    );
    final r = _recordsById[operationId];
    if (r != null) await _emitBacklogForPeerScope(r.scopeUid, peerId);
  }

  /// 标记某记录对该对端推送失败（内存 fake，可执行规格）。
  @override
  Future<void> markFailed({
    required String operationId,
    required PeerId peerId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {
    _acksByKey[_ackKey(operationId, peerId)] = _PeerAck(
      status: isDead ? 'dead' : 'failed',
      attempt: attempt,
      errorCode: errorCode,
      errorMessage: errorMessage,
      atUtc: atUtc,
    );
    final r = _recordsById[operationId];
    if (r != null) await _emitBacklogForPeerScope(r.scopeUid, peerId);
  }

  /// ack 状态变化只影响单个 peer，但该 peer 可能被多个 channel 订阅过
  /// （比如同一对端同时订阅了它的不同通道视角）。逐个 channel 通知。
  Future<void> _emitBacklogForPeerScope(String scopeUid, PeerId peerId) async {
    for (final key in _backlogControllersByKey.keys.toList()) {
      final parts = key.split('|');
      if (parts.length != 3) continue;
      if (parts[0] != scopeUid || parts[1] != peerId.value) continue;
      final channel = Channel.values.firstWhere(
        (c) => c.name == parts[2],
        orElse: () => Channel.cloud,
      );
      await _emitBacklog(scopeUid, peerId, channel);
    }
  }

  /// 读某记录对该对端的重试次数（内存 fake，可执行规格）。
  @override
  Future<int> attemptFor({
    required String operationId,
    required PeerId peerId,
  }) async {
    final ack = _acksByKey[_ackKey(operationId, peerId)];
    return ack?.attempt ?? 0;
  }

  /// 该对端的待推送积压数（含 channel 过滤）（内存 fake，可执行规格）。
  @override
  Future<int> backlogCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) async {
    var count = 0;
    for (final r in _recordsById.values) {
      if (r.scopeUid != scopeUid) continue;
      if (!_isPeekable(r.operationId, peerId)) continue;
      if (!PeerEligibility.allows(r.entityType, channel)) continue;
      count += 1;
    }
    return count;
  }

  /// 订阅该对端的待推送积压数（内存 fake，可执行规格）。
  @override
  Stream<int> watchBacklogCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) {
    return (() async* {
      yield await backlogCount(
        scopeUid: scopeUid,
        peerId: peerId,
        channel: channel,
      );
      yield* _controllerFor(scopeUid, peerId, channel).stream;
    })()
        .distinct();
  }

  /// 该对端的死信数（内存 fake，可执行规格）。
  @override
  Future<int> deadCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) async {
    var count = 0;
    for (final r in _recordsById.values) {
      if (r.scopeUid != scopeUid) continue;
      if (!PeerEligibility.allows(r.entityType, channel)) continue;
      final ack = _acksByKey[_ackKey(r.operationId, peerId)];
      if (ack != null && ack.status == 'dead') count += 1;
    }
    return count;
  }
}

/// 一条 (operationId, peerId) 的 ack 状态。
class _PeerAck {
  _PeerAck({
    required this.status,
    this.attempt = 0,
    this.errorCode,
    this.errorMessage,
    this.atUtc,
  });

  /// ack 状态（pending/success/failed/dead）。
  final String status;
  /// 该对端的重试次数。
  final int attempt;
  /// 最近一次错误的错误码。
  final String? errorCode;
  /// 最近一次错误的错误信息。
  final String? errorMessage;
  /// ack 时间。
  final DateTime? atUtc;
}

/// [SyncStateStore] 的内存实现，仅供测试使用。
///
/// 【本类是 drift 实现的可执行规格】：游标按 (scopeUid, peerId, entityType)
/// 三元组存 —— 云端游标推进到 T，不代表 LAN peer 也同步到了 T。
/// setCursorIfNewer 的「不回退」判定只在该三元组那一行内比较，跨 peer 不可比。
final class InMemorySyncStateStore implements SyncStateStore {
  final Map<String, PullCursor> _cursors = <String, PullCursor>{};

  String _key(String scopeUid, PeerId peerId, String entityType) =>
      '$scopeUid|${peerId.value}|$entityType';

  int _compareTimestamp(TimestampCursor a, TimestampCursor b) {
    final tsCmp = a.serverUpdatedAtUtc.compareTo(b.serverUpdatedAtUtc);
    if (tsCmp != 0) return tsCmp;
    return a.tieBreaker.compareTo(b.tieBreaker);
  }

  /// 读 (scope, peer, entityType) 游标（内存 fake，可执行规格）。
  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) async {
    return _cursors[_key(scopeUid, peerId, entityType)];
  }

  /// 写游标（不回退）（内存 fake，可执行规格）。
  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) async {
    final k = _key(scopeUid, peerId, entityType);
    final existing = _cursors[k];

    if (existing is TimestampCursor && cursor is TimestampCursor) {
      if (_compareTimestamp(cursor, existing) <= 0) return;
    } else if (existing is RevisionCursor && cursor is RevisionCursor) {
      if (cursor.revision <= existing.revision) return;
    } else if (existing != null) {
      return;
    }

    _cursors[k] = cursor;
  }

  /// 清空游标（内存 fake，可执行规格）。
  @override
  Future<void> clear({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) async {
    _cursors.remove(_key(scopeUid, peerId, entityType));
  }

  /// 记录拉取时间（内存 fake，可执行规格）。
  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required DateTime atUtc,
  }) async {}

  /// 记录推送时间（内存 fake，可执行规格）。
  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required PeerId peerId,
    required DateTime atUtc,
  }) async {}
}
