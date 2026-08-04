import 'dart:io';

import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:test/test.dart';

const _scopeUid = 'u1';
final _now = DateTime.utc(2026, 1, 10, 9, 0, 0);

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

int? _last(List<int> values) => values.isEmpty ? null : values.last;

void main() {
  group('S1b per-peer ports（InMemoryOutboxStore 可执行规格）', () {
    test('ack_for_one_peer_does_not_hide_record_from_another', () async {
      final store = InMemoryOutboxStore();
      final cloud = const PeerId('cloud');
      final lan = const PeerId('lan');

      await store.enqueue(_record('op1'));
      await store.markSuccess(
        operationId: 'op1',
        peerId: cloud,
        atUtc: _now,
      );

      final cloudBatch = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: cloud,
        limit: 100,
      );
      expect(cloudBatch, isEmpty);

      final lanBatch = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: lan,
        limit: 100,
      );
      expect(lanBatch.map((r) => r.operationId), contains('op1'));
    });

    test('dead_for_one_peer_does_not_kill_another', () async {
      final store = InMemoryOutboxStore();
      final cloud = const PeerId('cloud');
      final lan = const PeerId('lan');

      await store.enqueue(_record('op1'));
      for (var i = 1; i <= 10; i += 1) {
        await store.markFailed(
          operationId: 'op1',
          peerId: lan,
          attempt: i,
          errorCode: 'network',
          errorMessage: 'offline',
          atUtc: _now,
          isDead: i >= 10,
        );
      }

      expect(await store.deadCount(scopeUid: _scopeUid, peerId: lan), 1);
      expect(await store.deadCount(scopeUid: _scopeUid, peerId: cloud), 0);

      final cloudBatch = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: cloud,
        limit: 100,
      );
      expect(cloudBatch.map((r) => r.operationId), contains('op1'));
    });

    test('attempt_for_reads_per_peer_counter', () async {
      final store = InMemoryOutboxStore();
      final cloud = const PeerId('cloud');
      final lan = const PeerId('lan');

      await store.enqueue(_record('op1'));
      expect(await store.attemptFor(operationId: 'op1', peerId: lan), 0);

      await store.markFailed(
        operationId: 'op1',
        peerId: lan,
        attempt: 1,
        errorCode: 'network',
        errorMessage: 'offline',
        atUtc: _now,
        isDead: false,
      );
      expect(await store.attemptFor(operationId: 'op1', peerId: lan), 1);
      expect(await store.attemptFor(operationId: 'op1', peerId: cloud), 0);

      await store.markFailed(
        operationId: 'op1',
        peerId: lan,
        attempt: 2,
        errorCode: 'network',
        errorMessage: 'offline',
        atUtc: _now,
        isDead: false,
      );
      expect(await store.attemptFor(operationId: 'op1', peerId: lan), 2);
      expect(await store.attemptFor(operationId: 'op1', peerId: cloud), 0);
    });

    test('cursor_is_isolated_per_peer', () async {
      final store = InMemorySyncStateStore();
      const entityType = 'record';
      final cloud = const PeerId('cloud');
      final lan = const PeerId('lan');

      final newer = TimestampCursor(
        serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
        tieBreaker: 'op_cloud',
      );
      await store.setCursorIfNewer(
        scopeUid: _scopeUid,
        peerId: cloud,
        entityType: entityType,
        cursor: newer,
        atUtc: _now,
      );

      expect(
        await store.getCursor(
          scopeUid: _scopeUid,
          peerId: lan,
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
        peerId: lan,
        entityType: entityType,
        cursor: older,
        atUtc: _now,
      );
      expect(
        await store.getCursor(
          scopeUid: _scopeUid,
          peerId: lan,
          entityType: entityType,
        ),
        same(older),
      );
      expect(
        await store.getCursor(
          scopeUid: _scopeUid,
          peerId: cloud,
          entityType: entityType,
        ),
        same(newer),
      );
    });

    test('backlog_stream_is_per_peer', () async {
      final store = InMemoryOutboxStore();
      final cloud = const PeerId('cloud');
      final lan = const PeerId('lan');

      final cloudEvents = <int>[];
      final lanEvents = <int>[];
      final cloudSub = store
          .watchBacklogCount(scopeUid: _scopeUid, peerId: cloud)
          .listen(cloudEvents.add);
      final lanSub = store
          .watchBacklogCount(scopeUid: _scopeUid, peerId: lan)
          .listen(lanEvents.add);

      await store.enqueue(_record('op1'));
      await pumpEventQueue();
      expect(_last(cloudEvents), 1);
      expect(_last(lanEvents), 1);

      await store.markSuccess(
        operationId: 'op1',
        peerId: cloud,
        atUtc: _now,
      );
      await pumpEventQueue();
      expect(_last(cloudEvents), 0);
      expect(_last(lanEvents), 1);

      await cloudSub.cancel();
      await lanSub.cancel();
    });
  });

  group('S1b 端口文本守卫', () {
    test('enqueue_signature_unchanged', () async {
      final source = await File('lib/model/ports.dart').readAsString();
      expect(source, contains('Future<void> enqueue(OutboxRecord record);'));
    });

    test('no_default_value_on_peer_id', () async {
      final source = await File('lib/model/ports.dart').readAsString();
      expect(source, isNot(contains('PeerId peerId =')));
      expect(source, isNot(contains('[PeerId peerId')));

      final matches = RegExp(r'required PeerId peerId').allMatches(source);
      expect(matches.length, 12,
          reason: 'OutboxStore 7 个 + SyncStateStore 5 个 = 12，enqueue 是有意的例外');
    });
  });
}
