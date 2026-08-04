import 'dart:io';

import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:test/test.dart';

const _scopeUid = 'u1';
final _now = DateTime.utc(2026, 1, 10, 9, 0, 0);

OutboxRecord _record(String entityType, String id) => OutboxRecord(
      operationId: '$entityType-$id',
      scopeUid: _scopeUid,
      entityType: entityType,
      entityId: id,
      opType: 'upsert',
      payloadJson: '{"k":1}',
      createdAtUtc: _now,
      attempt: 0,
    );

void main() {
  setUp(StoragePolicyRegistry.clearForTesting);

  group('S1b 策略通道过滤（InMemoryOutboxStore）', () {
    test('shared_record_never_returned_for_lan_peer', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: const {}),
      );

      final store = InMemoryOutboxStore();
      final lan = const PeerId('lan');
      final cloud = const PeerId('cloud');

      await store.enqueue(_record('xiang_reading', 'a'));
      await store.enqueue(_record('playground_post', 'b'));

      final forLan = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: lan,
        channel: Channel.lan,
        limit: 100,
      );
      // shared 记录绝不进 LAN peer —— 「防混用」的真正验收项
      expect(
        forLan.any((r) => r.entityType == 'playground_post'),
        isFalse,
      );
      expect(forLan.map((r) => r.entityId), containsAll(['a']));

      final forCloud = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: cloud,
        channel: Channel.cloud,
        limit: 100,
      );
      // 反向确认：过滤不是「一刀切禁掉 shared」
      expect(
        forCloud.map((r) => r.entityType),
        containsAll(['xiang_reading', 'playground_post']),
      );
    });

    test('unregistered_entity_type_fails_closed', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );

      final store = InMemoryOutboxStore();
      final lan = const PeerId('lan');

      await store.enqueue(_record('xiang_reading', 'a'));
      await store.enqueue(_record('unregistered_thing', 'z'));

      for (final ch in Channel.values) {
        final out = await store.peekBatch(
          scopeUid: _scopeUid,
          peerId: lan,
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

    test('counts_agree_with_peek_batch', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: const {}),
      );

      final store = InMemoryOutboxStore();
      final lan = const PeerId('lan');

      // 3 条 shared + 2 条 private
      await store.enqueue(_record('playground_post', '1'));
      await store.enqueue(_record('playground_post', '2'));
      await store.enqueue(_record('playground_post', '3'));
      await store.enqueue(_record('xiang_reading', 'a'));
      await store.enqueue(_record('xiang_reading', 'b'));

      final peeked = await store.peekBatch(
        scopeUid: _scopeUid,
        peerId: lan,
        channel: Channel.lan,
        limit: 100,
      );
      expect(peeked, hasLength(2));

      final backlog = await store.backlogCount(
        scopeUid: _scopeUid,
        peerId: lan,
        channel: Channel.lan,
      );
      // 计数不跟着过滤走时，SyncRuntime 会看到"还有 5 条待推"但 peekBatch 只给 2 条，
      // 推完后 backlog 仍是 3 —— 无限空转唤醒。
      expect(backlog, 2, reason: 'backlog 计数必须与 peekBatch 用同一套过滤');
    });
  });

  group('S1b 实现守卫（单一判定源 + 不许硬编码分支）', () {
    test('filter_uses_policy_channels_not_hardcoded_enum', () async {
      // 判定逻辑所在处（PeerEligibility）必须用 policy.channels.contains，
      // 不得出现硬编码的 channel 枚举分支。
      final peerEligibility =
          await File('lib/model/peer_eligibility.dart').readAsString();
      expect(
        peerEligibility,
        contains('channelsFor(entityType).contains(channel)'),
        reason: 'PeerEligibility.allows 必须用 policy.channels 判定，不得手写枚举',
      );
      expect(
        peerEligibility,
        isNot(contains('channel == Channel.')),
        reason: 'PeerEligibility 不得硬编码 channel 枚举分支',
      );

      for (final path in const [
        'lib/model/ports.dart',
        'lib/core/sync_coordinator.dart',
      ]) {
        final source = await File(path).readAsString();
        expect(
          source,
          isNot(contains('channel == Channel.')),
          reason: '$path 不得硬编码 channel 枚举分支',
        );
        expect(
          source,
          isNot(contains('switch (channel)')),
          reason: '$path 不得写 switch(channel) 硬编码分支',
        );
      }

      final drift = await File('../drift/lib/persistence_drift.dart')
          .readAsString();
      expect(
        drift,
        isNot(contains('channel == Channel.')),
        reason: 'drift 实现不得硬编码 channel 枚举分支',
      );
      expect(
        drift,
        isNot(contains('switch (channel)')),
        reason: 'drift 实现不得写 switch(channel) 硬编码分支',
      );
      // 判定必须走单一判定源 PeerEligibility.allows（Codex R1 · P0-1），
      // 而不是在 drift 里自己写 if-else 枚举分支。
      expect(
        drift,
        contains('PeerEligibility.allows'),
        reason: 'drift 实现必须调 PeerEligibility.allows（单一判定源）',
      );
    });

    test('peer_eligibility_is_the_single_decision_source', () async {
      // lookup 只能出现在 peer_eligibility.dart 一处。
      // 实现若在 fake/drift/coordinator 里重复写 lookup 判定，这条会红。
      final process = await Process.run(
        'grep',
        [
          '-rn',
          'StoragePolicyRegistry.lookup',
          'lib',
          '../drift/lib',
        ],
      );
      final lines = (process.stdout as String)
          .split('\n')
          .where((l) => !l.contains('peer_eligibility.dart'))
          .where((l) => !l.contains('///'))
          .where((l) => !l.contains('//'))
          .where((l) => l.trim().isNotEmpty);
      expect(lines, isEmpty, reason: 'lookup 判定逻辑只允许出现在 PeerEligibility 一处');
    });
  });
}
