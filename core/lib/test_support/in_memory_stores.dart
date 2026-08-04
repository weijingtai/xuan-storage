import 'dart:async';

import 'package:persistence_core/model/ports.dart';
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

  String _backlogKey(String scopeUid, PeerId peerId) =>
      '$scopeUid|${peerId.value}';

  StreamController<int> _controllerFor(String scopeUid, PeerId peerId) {
    final key = _backlogKey(scopeUid, peerId);
    return _backlogControllersByKey.putIfAbsent(
      key,
      () => StreamController<int>.broadcast(),
    );
  }

  Future<void> _emitBacklog(String scopeUid, PeerId peerId) async {
    if (!_backlogControllersByKey.containsKey(_backlogKey(scopeUid, peerId))) {
      return;
    }
    _controllerFor(scopeUid, peerId)
        .add(await backlogCount(scopeUid: scopeUid, peerId: peerId));
  }

  /// enqueue 不知道对端集合，只能通知该 scope 下所有已订阅的对端。
  Future<void> _emitBacklogForScope(String scopeUid) async {
    for (final key in _backlogControllersByKey.keys.toList()) {
      final sep = key.indexOf('|');
      final scope = sep < 0 ? key : key.substring(0, sep);
      final peerValue = sep < 0 ? key : key.substring(sep + 1);
      if (scope != scopeUid) continue;
      await _emitBacklog(scope, PeerId(peerValue));
    }
  }

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

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required PeerId peerId,
    required int limit,
  }) async {
    final batch = _recordsById.values
        .where((r) => r.scopeUid == scopeUid)
        .where((r) => _isPeekable(r.operationId, peerId))
        .toList(growable: false)
          ..sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));

    if (limit <= 0) return const [];
    return batch.length <= limit ? batch : batch.sublist(0, limit);
  }

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
    if (r != null) await _emitBacklog(r.scopeUid, peerId);
  }

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
    if (r != null) await _emitBacklog(r.scopeUid, peerId);
  }

  @override
  Future<int> attemptFor({
    required String operationId,
    required PeerId peerId,
  }) async {
    final ack = _acksByKey[_ackKey(operationId, peerId)];
    return ack?.attempt ?? 0;
  }

  @override
  Future<int> backlogCount({
    required String scopeUid,
    required PeerId peerId,
  }) async {
    var count = 0;
    for (final r in _recordsById.values) {
      if (r.scopeUid != scopeUid) continue;
      if (_isPeekable(r.operationId, peerId)) count += 1;
    }
    return count;
  }

  @override
  Stream<int> watchBacklogCount({
    required String scopeUid,
    required PeerId peerId,
  }) {
    return (() async* {
      yield await backlogCount(scopeUid: scopeUid, peerId: peerId);
      yield* _controllerFor(scopeUid, peerId).stream;
    })()
        .distinct();
  }

  @override
  Future<int> deadCount({
    required String scopeUid,
    required PeerId peerId,
  }) async {
    var count = 0;
    for (final r in _recordsById.values) {
      if (r.scopeUid != scopeUid) continue;
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

  final String status;
  final int attempt;
  final String? errorCode;
  final String? errorMessage;
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

  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) async {
    return _cursors[_key(scopeUid, peerId, entityType)];
  }

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

  @override
  Future<void> clear({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) async {
    _cursors.remove(_key(scopeUid, peerId, entityType));
  }

  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required DateTime atUtc,
  }) async {}

  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required PeerId peerId,
    required DateTime atUtc,
  }) async {}
}
