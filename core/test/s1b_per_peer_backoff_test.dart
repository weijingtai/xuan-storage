import 'package:persistence_core/core/sync_coordinator.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/sync/peer_registry.dart';
import 'package:persistence_core/sync/sync_runtime.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:test/test.dart';

const _scopeUid = 'u1';
final _now = DateTime.utc(2026, 1, 10, 9, 0, 0);
const _cloud = PeerId('cloud');
const _lan = PeerId('lan');

class _CountingPeer implements SyncPeer {
  _CountingPeer(this._peerId, {Channel channel = Channel.cloud})
      : _channel = channel;

  final PeerId _peerId;
  final Channel _channel;
  int pushCount = 0;
  int pullCount = 0;
  Future<SyncError?> Function(OutboxRecord record)? onPush;
  Future<SyncError?> Function()? onPull;

  @override
  PeerId get peerId => _peerId;

  @override
  Channel get channel => _channel;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    pushCount += 1;
    final fn = onPush;
    if (fn == null) return null;
    return fn(record);
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    pullCount += 1;
    final fn = onPull;
    if (fn != null) await fn();
    return const RemoteChangesPage(changes: [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async => PeerCapabilities(
    peerId: _peerId,
    channel: _channel,
    entityVersions: const {},
    supportedFeatures: const {'outbox_v1'},
    protocolVersion: 1,
  );
}

OutboxRecord _record(String operationId, String entityType) => OutboxRecord(
      operationId: operationId,
      scopeUid: _scopeUid,
      entityType: entityType,
      entityId: 'e1',
      opType: 'upsert',
      payloadJson: '{"k":1}',
      createdAtUtc: _now,
      attempt: 0,
    );

/// 组装一个可注入 PeerRegistry 的 SyncRuntime。
SyncRuntime _buildRuntime({
  required PeerRegistry registry,
  required SyncCoordinator coordinator,
  DateTime Function()? nowUtc,
  Duration minBackoff = const Duration(milliseconds: 100),
  Duration maxBackoff = const Duration(milliseconds: 500),
}) {
  return SyncRuntime(
    coordinator: coordinator,
    peerRegistry: registry,
    nowUtc: nowUtc ?? () => _now,
    enablePushTimer: false,
    enablePush: true,
    minBackoff: minBackoff,
    maxBackoff: maxBackoff,
  );
}

class _NoopApplier implements LocalApplier {
  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    return const LocalApplyResult(
      canAdvanceCursor: true,
      appliedCount: 0,
      outcomes: <ChangeApplyOutcome>[],
      lastError: null,
    );
  }
}

void main() {
  setUp(StoragePolicyRegistry.clearForTesting);

  group('PeerRegistry', () {
    test('register_and_peers_reflect', () {
      final registry = DefaultPeerRegistry();
      expect(registry.peerIds, isEmpty);

      final cloud = _CountingPeer(_cloud);
      registry.register(cloud);
      expect(registry.peerIds, {_cloud});
      expect(registry.peers.toList(), [cloud]);
    });

    test('remove_notifies_and_clears_peer', () async {
      final registry = DefaultPeerRegistry();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan);

      final seen = <Set<PeerId>>[];
      final sub = registry.changes.listen(seen.add);

      registry.register(cloud);
      registry.register(lan);
      registry.remove(_lan);
      await pumpEventQueue();

      expect(registry.peerIds, {_cloud});
      expect(seen.any((s) => !s.contains(_lan)), isTrue,
          reason: 'remove 必须通知监听方该 peer 已离开');

      sub.cancel();
    });
  });

  group('SyncRuntime per-peer 退避', () {
    test('unreachable_peer_does_not_delay_cloud_push', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan)
        ..onPush = (_) async => const SyncError(
          code: SyncErrorCode.network,
          message: 'lan offline',
        );

      final registry = DefaultPeerRegistry();
      registry.register(cloud);
      registry.register(lan);

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        nowUtc: () => _now,
      );
      final runtime = _buildRuntime(
        registry: registry,
        coordinator: coordinator,
      );

      await runtime.start();
      await runtime.setScopeUid(_scopeUid);

      await outbox.enqueue(_record('op1', 'xiang_reading'));

      // 手动触发几轮推送（enablePush=false，走 triggerPush）
      for (var i = 0; i < 3; i += 1) {
        await runtime.triggerPush();
        await runtime.triggerPush();
        await runtime.triggerPush();
      }

      // lan 进入退避
      final lanNotBefore = runtime.debugNextPushNotBefore[_lan];
      expect(lanNotBefore, isNotNull, reason: 'lan 失败后应进入退避');
      expect(lanNotBefore!.isAfter(_now), isTrue);

      // cloud 从未退避
      expect(runtime.debugNextPushNotBefore[_cloud], isNull,
          reason: 'cloud 恒成功，不得被 lan 的失败拖进退避');

      // cloud 仍被调用
      expect(cloud.pushCount, greaterThan(0));
    });

    test('peer_in_backoff_is_skipped_others_still_pushed', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan)
        ..onPush = (_) async => const SyncError(
          code: SyncErrorCode.network,
          message: 'lan offline',
        );

      final registry = DefaultPeerRegistry();
      registry.register(cloud);
      registry.register(lan);

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        nowUtc: () => _now,
      );
      final runtime = _buildRuntime(
        registry: registry,
        coordinator: coordinator,
      );

      await runtime.start();
      await runtime.setScopeUid(_scopeUid);

      await outbox.enqueue(_record('op1', 'xiang_reading'));

      // 先把 lan 打进退避
      for (var i = 0; i < 3; i += 1) {
        await runtime.triggerPush();
      }
      expect(runtime.debugNextPushNotBefore[_lan], isNotNull);

      // cloud 已把 op1 推成功，故无待推记录。再入队一条新记录，
      // 验证「lan 退避时只推 cloud」—— cloud 有新记录可推。
      await outbox.enqueue(_record('op2', 'xiang_reading'));

      final lanBefore = lan.pushCount;
      final cloudBefore = cloud.pushCount;

      await runtime.triggerPush();

      // lan 被跳过，cloud 照常推
      expect(lan.pushCount, lanBefore,
          reason: 'lan 在退避窗口内应被跳过');
      expect(cloud.pushCount, greaterThan(cloudBefore),
          reason: '「任一 peer 退避就整轮跳过」会把 cloud 也卡住');
    });

    test('failure_count_resets_per_peer_on_success', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      var lanFails = true;
      var current = _now;
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan)
        ..onPush = (_) async => lanFails
            ? const SyncError(code: SyncErrorCode.network, message: 'offline')
            : null;

      final registry = DefaultPeerRegistry();
      registry.register(cloud);
      registry.register(lan);

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        nowUtc: () => current,
      );
      final runtime = _buildRuntime(
        registry: registry,
        coordinator: coordinator,
        nowUtc: () => current,
      );

      await runtime.start();
      await runtime.setScopeUid(_scopeUid);

      await outbox.enqueue(_record('op1', 'xiang_reading'));

      // lan 失败 3 次
      for (var i = 0; i < 3; i += 1) {
        await runtime.triggerPush();
      }
      expect(runtime.debugPushFailureCount[_lan], greaterThan(0));

      // 推进时钟超过退避窗口，lan 转成功
      current = _now.add(const Duration(seconds: 1));
      lanFails = false;
      await runtime.triggerPush();
      expect(runtime.debugPushFailureCount[_lan], 0,
          reason: 'lan 成功后自己的失败数应归零');
      expect(runtime.debugNextPushNotBefore[_lan], isNull);

      // cloud 全程无失败
      expect(runtime.debugPushFailureCount[_cloud], 0,
          reason: 'cloud 不被 lan 的失败/归零影响');
    });

    test('pull_backoff_keyed_by_peer_and_entity_type', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan)
        ..onPull = () async => throw const SyncError(
          code: SyncErrorCode.network,
          message: 'lan pull offline',
        );

      final registry = DefaultPeerRegistry();
      registry.register(cloud);
      registry.register(lan);

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        syncStateStore: InMemorySyncStateStore(),
        localApplier: _NoopApplier(),
        nowUtc: () => _now,
      );
      final runtime = _buildRuntime(
        registry: registry,
        coordinator: coordinator,
      );

      await runtime.start();
      await runtime.setScopeUid(_scopeUid);
      await runtime.setPullEntityTypes(
        ['record', 'divination_case'],
        triggerImmediately: false,
      );

      // lan 拉取 record 失败，进入退避
      await runtime.triggerPull('record');
      expect(
        runtime.debugNextPullNotBefore[(_lan, 'record')],
        isNotNull,
        reason: '(lan, record) 失败后应进入退避',
      );

      // (cloud, record) 与 (lan, divination_case) 不受影响
      expect(
        runtime.debugNextPullNotBefore[(_cloud, 'record')],
        isNull,
        reason: 'lan 的失败不得影响 (cloud, record)',
      );
      expect(
        runtime.debugNextPullNotBefore[(_lan, 'divination_case')],
        isNull,
        reason: 'lan 的 record 失败不得影响 (lan, divination_case)',
      );
    });

    test('backoff_algorithm_unchanged', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      var current = _now;
      final cloud = _CountingPeer(_cloud)
        ..onPush = (_) async => const SyncError(
          code: SyncErrorCode.network,
          message: 'offline',
        );

      final registry = DefaultPeerRegistry();
      registry.register(cloud);

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud],
        nowUtc: () => current,
      );
      final runtime = _buildRuntime(
        registry: registry,
        coordinator: coordinator,
        nowUtc: () => current,
        minBackoff: const Duration(seconds: 2),
        maxBackoff: const Duration(minutes: 2),
      );

      await runtime.start();
      await runtime.setScopeUid(_scopeUid);

      // 每次失败后记录退避时长，然后推进时钟越过后再触发下一次
      final durations = <Duration>[];
      for (var i = 1; i <= 5; i += 1) {
        await outbox.enqueue(_record('op$i', 'xiang_reading'));
        await runtime.triggerPush();
        final notBefore = runtime.debugNextPushNotBefore[_cloud];
        expect(notBefore, isNotNull);
        durations.add(notBefore!.difference(current));
        current = notBefore.add(const Duration(milliseconds: 1));
      }

      // 指数退避：minBackoff(2s) → 4s → 8s → 16s → 32s（被 maxBackoff 2min 截断前）
      expect(durations[0], const Duration(seconds: 2));
      expect(durations[1], const Duration(seconds: 4));
      expect(durations[2], const Duration(seconds: 8));
      expect(durations[3], const Duration(seconds: 16));
      expect(durations[4], const Duration(seconds: 32),
          reason: '退避算法零变化：指数增长、被 maxBackoff 截断、不小于 minBackoff');
    });

    test('backoff_maps_do_not_leak_removed_peers', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan)
        ..onPush = (_) async => const SyncError(
          code: SyncErrorCode.network,
          message: 'offline',
        );

      final registry = DefaultPeerRegistry();
      registry.register(cloud);
      registry.register(lan);

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        nowUtc: () => _now,
      );
      final runtime = _buildRuntime(
        registry: registry,
        coordinator: coordinator,
      );

      await runtime.start();
      await runtime.setScopeUid(_scopeUid);

      await outbox.enqueue(_record('op1', 'xiang_reading'));
      for (var i = 0; i < 3; i += 1) {
        await runtime.triggerPush();
      }

      // lan 进入退避（四个 Map 里都有它的键）
      expect(runtime.debugNextPushNotBefore.containsKey(_lan), isTrue);

      // 走正式 API 移除 lan
      registry.remove(_lan);

      // 等 registry 变更流的清理回调执行完（异步队列，需要真实让出）
      await Future<void>.delayed(const Duration(milliseconds: 20));
      for (var i = 0; i < 5; i += 1) {
        await pumpEventQueue();
      }

      expect(runtime.debugNextPushNotBefore.containsKey(_lan), isFalse,
          reason: '移除对端后退避 Map 不得留僵尸键');
      expect(runtime.debugPushFailureCount.containsKey(_lan), isFalse);
    });
  });
}
