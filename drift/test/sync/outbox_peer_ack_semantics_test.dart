import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:persistence_drift/persistence_drift.dart';

const _scopeUid = 'u1';
final _now = DateTime.utc(2026, 1, 10, 9, 0, 0);
const _cloud = PeerId('cloud');
const _lan = PeerId('lan');
const _firestore = PeerId('firestore');

OutboxRecord _record(String operationId) => OutboxRecord(
      operationId: operationId,
      scopeUid: _scopeUid,
      entityType: 'layout_template',
      entityId: 't1',
      opType: 'upsert',
      payloadJson: '{"k":1}',
      createdAtUtc: _now,
      attempt: 0,
    );

/// 一组 per-peer outbox 行为断言，对 InMemory 与 Drift 两套实现各跑一遍（parity）。
///
/// 两套实现跑同一组断言，差异立刻显形 —— 内存 fake 与 drift 各自绿但行为
/// 不一致，是这类改造最典型的漏。
void runOutboxParityAssertions(OutboxStore Function() createStore) {
  setUp(() {
    // ACT 05：peekBatch/计数按 channel 过滤且 fail closed。
    // 本 parity 套件期望 cloud 与 lan 都能取到 layout_template，须注册 private 策略。
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'layout_template',
      StoragePolicy.private(carriers: const {}),
    );
  });

  test('ack_for_one_peer_does_not_hide_record_from_another', () async {
    final store = createStore();
    await store.enqueue(_record('op1'));
    await store.markSuccess(operationId: 'op1', peerId: _cloud, atUtc: _now);

    final cloudBatch = await store.peekBatch(
      scopeUid: _scopeUid,
      peerId: _cloud,
      channel: Channel.cloud,
      limit: 100,
    );
    expect(cloudBatch, isEmpty);

    final lanBatch = await store.peekBatch(
      scopeUid: _scopeUid,
      peerId: _lan,
      channel: Channel.lan,
      limit: 100,
    );
    expect(lanBatch.map((r) => r.operationId), contains('op1'));
  });

  test('dead_for_one_peer_does_not_kill_another', () async {
    final store = createStore();
    await store.enqueue(_record('op1'));
    for (var i = 1; i <= 10; i += 1) {
      await store.markFailed(
        operationId: 'op1',
        peerId: _lan,
        attempt: i,
        errorCode: 'network',
        errorMessage: 'offline',
        atUtc: _now,
        isDead: i >= 10,
      );
    }

    expect(
      await store.deadCount(
        scopeUid: _scopeUid,
        peerId: _lan,
        channel: Channel.lan,
      ),
      1,
    );
    expect(
      await store.deadCount(
        scopeUid: _scopeUid,
        peerId: _cloud,
        channel: Channel.cloud,
      ),
      0,
    );

    final cloudBatch = await store.peekBatch(
      scopeUid: _scopeUid,
      peerId: _cloud,
      channel: Channel.cloud,
      limit: 100,
    );
    expect(cloudBatch.map((r) => r.operationId), contains('op1'));
  });

  test('attempt_for_reads_per_peer_counter', () async {
    final store = createStore();
    await store.enqueue(_record('op1'));
    expect(await store.attemptFor(operationId: 'op1', peerId: _lan), 0);

    await store.markFailed(
      operationId: 'op1',
      peerId: _lan,
      attempt: 1,
      errorCode: 'network',
      errorMessage: 'offline',
      atUtc: _now,
      isDead: false,
    );
    expect(await store.attemptFor(operationId: 'op1', peerId: _lan), 1);
    expect(await store.attemptFor(operationId: 'op1', peerId: _cloud), 0);

    await store.markFailed(
      operationId: 'op1',
      peerId: _lan,
      attempt: 2,
      errorCode: 'network',
      errorMessage: 'offline',
      atUtc: _now,
      isDead: false,
    );
    expect(await store.attemptFor(operationId: 'op1', peerId: _lan), 2);
    expect(await store.attemptFor(operationId: 'op1', peerId: _cloud), 0);
  });

  test('backlog_stream_is_per_peer', () async {
    final store = createStore();
    final cloudEvents = <int>[];
    final lanEvents = <int>[];
    final cloudSub = store
        .watchBacklogCount(
          scopeUid: _scopeUid,
          peerId: _cloud,
          channel: Channel.cloud,
        )
        .listen(cloudEvents.add);
    final lanSub = store
        .watchBacklogCount(
          scopeUid: _scopeUid,
          peerId: _lan,
          channel: Channel.lan,
        )
        .listen(lanEvents.add);

    await store.enqueue(_record('op1'));
    await pumpEventQueue();
    expect(cloudEvents.last, 1);
    expect(lanEvents.last, 1);

    await store.markSuccess(operationId: 'op1', peerId: _cloud, atUtc: _now);
    await pumpEventQueue();
    expect(cloudEvents.last, 0);
    expect(lanEvents.last, 1);

    await cloudSub.cancel();
    await lanSub.cancel();
  });
}

/// 游标 per-peer 隔离断言，对 InMemory 与 Drift 两套实现各跑一遍（parity）。
///
/// 用值断言而非 `same()`：drift 每次 getCursor 都会从 DB 反序列化出【新对象】，
/// `same()` 只对 InMemory（存同一引用）成立，parity 要求两套跑同一组断言。
void runCursorParityAssertions(SyncStateStore Function() createStore) {
  test('cursor_is_isolated_per_peer', () async {
    final store = createStore();
    const entityType = 'record';

    final newer = TimestampCursor(
      serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
      tieBreaker: 'op_cloud',
    );
    await store.setCursorIfNewer(
      scopeUid: _scopeUid,
      peerId: _cloud,
      entityType: entityType,
      cursor: newer,
      atUtc: _now,
    );

    expect(
      await store.getCursor(
        scopeUid: _scopeUid,
        peerId: _lan,
        entityType: entityType,
      ),
      isNull,
    );

    final older = TimestampCursor(
      serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 7, 0, 0),
      tieBreaker: 'op_lan',
    );
    await store.setCursorIfNewer(
      scopeUid: _scopeUid,
      peerId: _lan,
      entityType: entityType,
      cursor: older,
      atUtc: _now,
    );

    final lanCursor = await store.getCursor(
      scopeUid: _scopeUid,
      peerId: _lan,
      entityType: entityType,
    );
    expect(lanCursor, isA<TimestampCursor>());
    final ts = lanCursor as TimestampCursor;
    expect(ts.serverUpdatedAtUtc, DateTime.utc(2026, 1, 10, 7, 0, 0));
    expect(ts.tieBreaker, 'op_lan');

    final cloudCursor = await store.getCursor(
      scopeUid: _scopeUid,
      peerId: _cloud,
      entityType: entityType,
    );
    expect(cloudCursor, isA<TimestampCursor>());
    final tsCloud = cloudCursor as TimestampCursor;
    expect(tsCloud.serverUpdatedAtUtc, DateTime.utc(2026, 1, 10, 8, 0, 0));
    expect(tsCloud.tieBreaker, 'op_cloud');
  });
}

void main() {
  group('S1b outbox peer ack semantics — 内存 fake 与 drift 实现 parity', () {
    group('InMemoryOutboxStore', () {
      runOutboxParityAssertions(InMemoryOutboxStore.new);
    });

    group('DriftOutboxStore', () {
      late PersistenceDriftDatabase db;
      late DriftOutboxStore store;

      setUp(() {
        db = PersistenceDriftDatabase(NativeDatabase.memory());
        store = DriftOutboxStore(dao: db.outboxRecordsDao);
      });

      tearDown(() async => await db.close());

      runOutboxParityAssertions(() => store);
    });
  });

  group('S1b cursor peer 隔离 — 内存 fake 与 drift 实现 parity', () {
    group('InMemorySyncStateStore', () {
      runCursorParityAssertions(InMemorySyncStateStore.new);
    });

    group('DriftSyncStateStore', () {
      late PersistenceDriftDatabase db;
      late DriftSyncStateStore store;

      setUp(() {
        db = PersistenceDriftDatabase(NativeDatabase.memory());
        store = DriftSyncStateStore(dao: db.syncStatesDao);
      });

      tearDown(() async => await db.close());

      runCursorParityAssertions(() => store);
    });
  });

  group('S1b drift 特有 DB 级断言', () {
    test('never_acked_record_is_peekable_by_new_peer', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = DriftOutboxStore(dao: db.outboxRecordsDao);

      // 完全不调用任何 markSuccess/markFailed —— t_outbox_peer_ack 里一行都没有。
      await store.enqueue(_record('op1'));

      final batch = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: _lan,
        channel: Channel.lan,
        limit: 100,
      );
      expect(batch.map((r) => r.operationId), contains('op1'));
      expect(
        await store.backlogCount(
          scopeUid: _scopeUid,
          peerId: _lan,
          channel: Channel.lan,
        ),
        1,
      );
      expect(await store.attemptFor(operationId: 'op1', peerId: _lan), 0);
    });

    test('no_ack_rows_created_at_enqueue', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = DriftOutboxStore(dao: db.outboxRecordsDao);

      await store.enqueue(_record('op1'));

      final ackRows = await (db.select(db.outboxPeerAcks)).get();
      expect(ackRows, isEmpty,
          reason: 'ack 行必须惰性创建，enqueue 不得预建任何对端的 ack 行');
    });

    test('success_on_one_peer_does_not_delete_outbox_row', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = DriftOutboxStore(dao: db.outboxRecordsDao);

      await store.enqueue(_record('op1'));
      await store.markSuccess(
        operationId: 'op1',
        peerId: _firestore,
        atUtc: _now,
      );

      expect(
        await store.peekBatch(
          scopeUid: _scopeUid,
          peerId: _firestore,
          channel: Channel.cloud,
          limit: 100,
        ),
        isEmpty,
      );
      expect(
        (await store.peekBatch(
          scopeUid: _scopeUid,
          peerId: _lan,
          channel: Channel.lan,
          limit: 100,
        ))
            .map((r) => r.operationId),
        contains('op1'),
      );

      // t_outbox 里该行仍在 —— success 不删记录（compaction 才删，§5.3）。
      final outboxRows = await (db.select(db.outboxRecords)).get();
      expect(outboxRows.map((r) => r.operationId), contains('op1'));
    });

    test('dead_on_one_peer_leaves_outbox_attempt_untouched', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = DriftOutboxStore(dao: db.outboxRecordsDao);

      await store.enqueue(_record('op1'));
      for (var i = 1; i <= 10; i += 1) {
        await store.markFailed(
          operationId: 'op1',
          peerId: _lan,
          attempt: i,
          errorCode: 'network',
          errorMessage: 'offline',
          atUtc: _now,
          isDead: i >= 10,
        );
      }

      expect(
        await store.deadCount(
          scopeUid: _scopeUid,
          peerId: _lan,
          channel: Channel.lan,
        ),
        1,
      );
      expect(
        await store.peekBatch(
          scopeUid: _scopeUid,
          peerId: _lan,
          channel: Channel.lan,
          limit: 100,
        ),
        isEmpty,
      );
      expect(
        await store.deadCount(
          scopeUid: _scopeUid,
          peerId: _firestore,
          channel: Channel.cloud,
        ),
        0,
      );
      expect(
        (await store.peekBatch(
          scopeUid: _scopeUid,
          peerId: _firestore,
          channel: Channel.cloud,
          limit: 100,
        ))
            .map((r) => r.operationId),
        contains('op1'),
      );

      // t_outbox 里该行的 attempt 字段未被改动 —— attempt 是 per-peer 的，归 ack 表管。
      final row = await (db.select(db.outboxRecords)
            ..where((t) => t.operationId.equals('op1')))
          .getSingle();
      expect(row.attempt, 0);
      expect(row.status, 'pending',
          reason: 't_outbox.status 保持入队时的 pending，不被 per-peer 的 ack 流转改写');
    });
  });
}
