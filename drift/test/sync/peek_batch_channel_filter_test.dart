import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_drift/persistence_drift.dart';

const _scopeUid = 'u1';
final _now = DateTime.utc(2026, 1, 10, 9, 0, 0);
const _lan = PeerId('lan');

OutboxRecord _record(
  String entityType,
  String id, {
  required DateTime createdAtUtc,
}) =>
    OutboxRecord(
      operationId: '$entityType-$id',
      scopeUid: _scopeUid,
      entityType: entityType,
      entityId: id,
      opType: 'upsert',
      payloadJson: '{"k":1}',
      createdAtUtc: createdAtUtc,
      attempt: 0,
    );

void main() {
  late PersistenceDriftDatabase db;
  late DriftOutboxStore store;

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    store = DriftOutboxStore(dao: db.outboxRecordsDao);
  });

  tearDown(() async => await db.close());

  group('S1b drift 策略通道过滤', () {
    test('filter_before_limit_no_silent_starvation', () async {
      // 按 createdAtUtc 顺序：10 条 shared 在前，3 条 private 在后。
      for (var i = 0; i < 10; i += 1) {
        await store.enqueue(
          _record(
            'playground_post',
            'shared-$i',
            createdAtUtc: _now.add(Duration(minutes: i)),
          ),
        );
      }
      for (var i = 0; i < 3; i += 1) {
        await store.enqueue(
          _record(
            'xiang_reading',
            'private-$i',
            createdAtUtc: _now.add(Duration(minutes: 10 + i)),
          ),
        );
      }
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: const {}),
      );
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );

      final batch = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: _lan,
        channel: Channel.lan,
        limit: 3,
      );
      // 先按 limit 取前 3 条（全是 shared）再过滤的实现会返回空列表；
      // 必须【先过滤后截断】才拿得到 3 条 private。
      expect(batch.map((r) => r.entityType), everyElement('xiang_reading'));
      expect(batch, hasLength(3));
    });

    test('drift_matches_memory_fake_behavior_shared_not_for_lan', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: const {}),
      );
      await store.enqueue(_record('xiang_reading', 'a', createdAtUtc: _now));
      await store.enqueue(_record('playground_post', 'b', createdAtUtc: _now));

      final forLan = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: _lan,
        channel: Channel.lan,
        limit: 100,
      );
      expect(
        forLan.any((r) => r.entityType == 'playground_post'),
        isFalse,
        reason: 'shared 记录绝不进 LAN peer',
      );
      expect(forLan.map((r) => r.entityId), containsAll(['a']));
    });

    test('drift_matches_memory_fake_behavior_fail_closed', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      await store.enqueue(_record('xiang_reading', 'a', createdAtUtc: _now));
      await store.enqueue(
        _record('unregistered_thing', 'z', createdAtUtc: _now),
      );

      for (final ch in Channel.values) {
        final out = await store.peekBatch(
          scopeUid: _scopeUid,
          peerId: _lan,
          channel: ch,
          limit: 100,
        );
        expect(
          out.any((r) => r.entityType == 'unregistered_thing'),
          isFalse,
          reason: '未注册 entityType 在通道 $ch 下必须 fail closed',
        );
      }
    });

    test('drift_matches_memory_fake_behavior_counts_agree', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: const {}),
      );
      await store.enqueue(_record('playground_post', '1', createdAtUtc: _now));
      await store.enqueue(_record('playground_post', '2', createdAtUtc: _now));
      await store.enqueue(_record('playground_post', '3', createdAtUtc: _now));
      await store.enqueue(_record('xiang_reading', 'a', createdAtUtc: _now));
      await store.enqueue(_record('xiang_reading', 'b', createdAtUtc: _now));

      final peeked = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: _lan,
        channel: Channel.lan,
        limit: 100,
      );
      expect(peeked, hasLength(2));

      final backlog = await store.backlogCount(
        scopeUid: _scopeUid,
        peerId: _lan,
        channel: Channel.lan,
      );
      expect(backlog, 2, reason: 'backlog 计数必须与 peekBatch 用同一套过滤');
    });
  });
}
