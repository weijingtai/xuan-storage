import 'package:persistence_core/core/sync_coordinator.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/routing/peer_fanout_pusher.dart';
import 'package:persistence_core/routing/remote_gateway_router.dart';
import 'package:persistence_core/routing/region.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:test/test.dart';

const _scopeUid = 'u1';
final _now = DateTime.utc(2026, 1, 10, 9, 0, 0);
const _cloud = PeerId('cloud');
const _lan = PeerId('lan');
const _webrtc = PeerId('webrtc');

/// 计数式 fake：记录收到的 operationId 与 push 次数，不抛异常。
///
/// 【不用 fail()】—— SyncCoordinator 里有 catch-all，TestFailure 会被吞掉，
/// 用 fail() 断言会静默通过（S5c 教训）。
class _CountingPeer implements SyncPeer {
  _CountingPeer(this._peerId, {Channel channel = Channel.cloud})
      : _channel = channel;

  final PeerId _peerId;
  final Channel _channel;
  final List<String> received = <String>[];
  int pushCount = 0;
  Future<SyncError?> Function(OutboxRecord record)? onPush;

  @override
  PeerId get peerId => _peerId;

  @override
  Channel get channel => _channel;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    pushCount += 1;
    received.add(record.operationId);
    return onPush?.call(record);
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
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

/// 立刻抛异常的对端。
class _ThrowingPeer implements SyncPeer {
  _ThrowingPeer(this._peerId, {Channel channel = Channel.cloud})
      : _channel = channel;

  final PeerId _peerId;
  final Channel _channel;
  int pushCount = 0;

  @override
  PeerId get peerId => _peerId;

  @override
  Channel get channel => _channel;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    pushCount += 1;
    throw StateError('simulated network failure for ${_peerId.value}');
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
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

void main() {
  setUp(StoragePolicyRegistry.clearForTesting);

  group('DefaultPeerFanoutPusher', () {
    test('every_peer_gets_an_entry_including_successes', () async {
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(
        _lan,
        channel: Channel.lan,
      )..onPush = (_) async => const SyncError(
          code: SyncErrorCode.network,
          message: 'timeout',
        );
      final webrtc = _ThrowingPeer(_webrtc, channel: Channel.webrtc);

      final pusher = DefaultPeerFanoutPusher(
        peers: [cloud, lan, webrtc],
      );

      final result = await pusher.pushToAll(
        _record('op1', 'xiang_reading'),
        eligiblePeers: {_cloud, _lan, _webrtc},
      );

      expect(result.length, 3);
      expect(result[_cloud], isNull, reason: '成功也必须有条目（区分"成功"与"没推"）');
      expect(result[_lan], isA<SyncError>());
      final webrtcErr = result[_webrtc];
      expect(webrtcErr, isA<SyncError>());
      expect(webrtcErr!.message, contains('webrtc'),
          reason: '异常映射的 message 必须带该 peer 的 peerId');
    });

    test('one_peer_throwing_does_not_abort_others', () async {
      final a = _ThrowingPeer(const PeerId('a'));
      final b = _CountingPeer(const PeerId('b'));
      final c = _CountingPeer(const PeerId('c'));

      final pusher = DefaultPeerFanoutPusher(peers: [a, b, c]);
      final result = await pusher.pushToAll(
        _record('op1', 'xiang_reading'),
        eligiblePeers: {const PeerId('a'), const PeerId('b'), const PeerId('c')},
      );

      // 不抛异常、正常返回
      expect(result.length, 3);
      expect(b.pushCount, 1, reason: '第一个 peer 抛异常不得中断其余对端的推送');
      expect(c.pushCount, 1);
    });

    test('pushes_are_concurrent_not_serial', () async {
      Future<SyncError?> slow(OutboxRecord _) =>
          Future.delayed(const Duration(milliseconds: 200), () => null);

      final peers = [
        _CountingPeer(const PeerId('a'))..onPush = slow,
        _CountingPeer(const PeerId('b'))..onPush = slow,
        _CountingPeer(const PeerId('c'))..onPush = slow,
      ];
      final pusher = DefaultPeerFanoutPusher(peers: peers);
      final sw = Stopwatch()..start();
      await pusher.pushToAll(
        _record('op1', 'xiang_reading'),
        eligiblePeers: {
          const PeerId('a'),
          const PeerId('b'),
          const PeerId('c'),
        },
      );
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(400),
          reason: '并发约 200ms，串行约 600ms；取中间阈值防 CI 抖动');
    });

    test('unknown_peer_in_eligible_set_returns_error_not_dropped', () async {
      final cloud = _CountingPeer(_cloud);
      final pusher = DefaultPeerFanoutPusher(peers: [cloud]);
      final result = await pusher.pushToAll(
        _record('op1', 'xiang_reading'),
        eligiblePeers: {_cloud, const PeerId('unregistered-peer')},
      );
      expect(result.length, 2);
      expect(result[_cloud], isNull);
      final err = result[const PeerId('unregistered-peer')];
      expect(err, isA<SyncError>());
      expect(err!.code, SyncErrorCode.unknown);
      expect(err.message, contains('未注册的对端'));
    });
  });

  group('SyncCoordinator 端到端扇出', () {
    test('end_to_end_shared_record_never_reaches_lan', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: const {}),
      );

      final outbox = InMemoryOutboxStore();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan);

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        nowUtc: () => _now,
      );

      await outbox.enqueue(_record('shared-1', 'playground_post'));
      await outbox.enqueue(_record('private-1', 'xiang_reading'));

      await coordinator.pushOnce(scopeUid: _scopeUid);

      // cloud 收到两条
      expect(cloud.received, containsAll(['shared-1', 'private-1']));
      // lan 只收到 private 那条
      expect(lan.received, contains('private-1'));
      expect(lan.received, isNot(contains('shared-1')),
          reason: 'shared 记录绝不进 LAN peer —— §5.4 第一道锁的终检');
    });

    test('coordinator_writes_ack_per_peer_from_result_map', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan)
        ..onPush = (_) async => const SyncError(
          code: SyncErrorCode.network,
          message: 'timeout',
        );

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        nowUtc: () => _now,
      );

      await outbox.enqueue(_record('op1', 'xiang_reading'));
      await coordinator.pushOnce(scopeUid: _scopeUid);

      final cloudBatch = await outbox.peekBatch(
        scopeUid: _scopeUid,
        peerId: _cloud,
        channel: Channel.cloud,
        limit: 100,
      );
      expect(cloudBatch, isEmpty, reason: 'cloud 成功应写 success ack');

      final lanBatch = await outbox.peekBatch(
        scopeUid: _scopeUid,
        peerId: _lan,
        channel: Channel.lan,
        limit: 100,
      );
      expect(lanBatch.map((r) => r.operationId), contains('op1'),
          reason: 'lan 失败应写 failed ack，可重试');

      expect(
        await outbox.attemptFor(operationId: 'op1', peerId: _lan),
        1,
      );
      expect(
        await outbox.attemptFor(operationId: 'op1', peerId: _cloud),
        0,
      );
    });

    test('attempt_comes_from_ack_row_not_from_outbox_record', () async {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: const {}),
      );
      final outbox = InMemoryOutboxStore();
      final cloud = _CountingPeer(_cloud);
      final lan = _CountingPeer(_lan, channel: Channel.lan)
        ..onPush = (_) async => const SyncError(
          code: SyncErrorCode.network,
          message: 'timeout',
        );

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: cloud,
        peers: [cloud, lan],
        nowUtc: () => _now,
      );

      await outbox.enqueue(_record('op1', 'xiang_reading'));

      // 第一轮：lan 失败 → attempt 1
      await coordinator.pushOnce(scopeUid: _scopeUid);
      expect(
        await outbox.attemptFor(operationId: 'op1', peerId: _lan),
        1,
      );
      expect(
        await outbox.attemptFor(operationId: 'op1', peerId: _cloud),
        0,
      );

      // 第二轮：lan 仍失败 → attempt 2
      await coordinator.pushOnce(scopeUid: _scopeUid);
      expect(
        await outbox.attemptFor(operationId: 'op1', peerId: _lan),
        2,
        reason: 'attempt 必须来自 ack 行（per-peer），不能是 t_outbox 全局字段',
      );
      expect(
        await outbox.attemptFor(operationId: 'op1', peerId: _cloud),
        0,
      );
    });
  });

  group('RemoteGatewayRouter 行为守卫', () {
    test('router_behavior_unchanged_still_one_of_n', () async {
      final mainland = _CountingPeer(const PeerId('supabase'), channel: Channel.cloud);
      final overseas = _CountingPeer(const PeerId('firebase'), channel: Channel.cloud);

      final router = RemoteGatewayRouter(
        gateways: {Region.supabase: mainland, Region.firebase: overseas},
        currentRegion: () => Region.supabase,
      );

      await router.push(_record('op1', 'xiang_reading'));

      expect(mainland.pushCount, 1);
      expect(overseas.pushCount, 0,
          reason: 'router 仍是 1-of-N：大陆走 Supabase，海外走 Firebase，不同时推');
    });
  });
}
