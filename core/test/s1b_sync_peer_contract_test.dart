import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';

/// S1b 契约测试：SyncPeer / PeerCapabilities / PeerId / PeerFanoutPusher。
///
/// 本 ACT 只定义类型契约（零实现），因此这里的 fake 全部是测试内私有类，
/// 不是交付物 —— 真正的实现类在后续 ACT（02/06）才出现。
void main() {
  group('PeerId 值语义', () {
    test('peer_id_has_value_semantics_as_map_key', () {
      // 内容相同的两个 PeerId 必须相等（值语义）。
      expect(PeerId('cloud') == PeerId('cloud'), isTrue);

      // 内容相同的 PeerId 先后放进同一个 Map，只占一个键。
      final map = <PeerId, String>{};
      map[PeerId('cloud')] = 'a';
      map[PeerId('cloud')] = 'b';
      expect(map.length, 1);
      expect(map[PeerId('cloud')], 'b');

      // 内容不同的 PeerId 不相等。
      expect(PeerId('cloud') != PeerId('lan'), isTrue);
    });
  });

  group('PeerCapabilities', () {
    test('peer_capabilities_carries_peer_and_channel', () {
      final caps = PeerCapabilities(
        peerId: PeerId('cloud'),
        channel: Channel.cloud,
        entityVersions: const {'record': 1},
        supportedFeatures: const {'outbox_v1'},
        protocolVersion: 1,
      );

      // 五个字段都能读回且值正确。
      expect(caps.peerId, PeerId('cloud'));
      expect(caps.channel, Channel.cloud);
      expect(caps.entityVersions, {'record': 1});
      expect(caps.supportedFeatures, {'outbox_v1'});
      expect(caps.protocolVersion, 1);

      // PeerCapabilities 【不是】 RegionCapabilities 的子类型 ——
      // 继承会让「region 能力」与「peer 能力」在类型上混淆。
      expect(caps is RegionCapabilities, isFalse);
    });
  });

  group('SyncPeer 可实现性', () {
    test('sync_peer_is_implementable_without_transport', () {
      // 云端不经 Transport 也必须是 SyncPeer（§5.2 分层）。
      // 若有人把 Transport / PeerSession 写成 SyncPeer 的必需成员，本条编译失败。
      final SyncPeer peer = _CloudPeer();
      expect(peer.peerId, PeerId('cloud'));
      expect(peer.channel, Channel.cloud);
    });
  });

  group('PeerFanoutPusher 契约', () {
    test('fanout_result_map_equals_eligible_set_exactly', () async {
      // fake pusher 持有四个对端；eligiblePeers 只传前三个。
      final manualExport = _CountingPeer(PeerId('manualExport'));
      final pusher = _FakeFanoutPusher([
        _FakeResultPeer(PeerId('cloud'), error: null),
        _FakeResultPeer(PeerId('lan'), error: const SyncError(
          code: SyncErrorCode.permission,
          message: 'lan 拒绝',
        )),
        _ThrowingPeer(PeerId('webrtc')),
        manualExport,
      ]);

      final results = await pusher.pushToAll(
        _sampleRecord(),
        eligiblePeers: const {
          PeerId('cloud'),
          PeerId('lan'),
          PeerId('webrtc'),
        },
      );

      // 返回 Map 的键集合【恰好等于】 eligiblePeers（length 为 3）。
      expect(results.length, 3);
      expect(
        results.keys.toSet(),
        const {PeerId('cloud'), PeerId('lan'), PeerId('webrtc')},
      );

      // 成功也必须留条目，值为 null。
      expect(results.containsKey(PeerId('cloud')), isTrue);
      expect(results[PeerId('cloud')], isNull);

      // 失败的对端值是 SyncError 且 code 可读。
      final lanError = results[PeerId('lan')];
      expect(lanError, isA<SyncError>());
      expect((lanError as SyncError).code, SyncErrorCode.permission);

      // 抛异常的对端转成 SyncError，不漏项、不外抛。
      final webrtcError = results[PeerId('webrtc')];
      expect(webrtcError, isA<SyncError>());

      // manualExport 未被推送：pushCount 为 0，且不在返回 Map 里。
      expect(manualExport.pushCount, 0);
      expect(results.containsKey(PeerId('manualExport')), isFalse);
    });
  });

  group('SyncPeer 无订阅类方法（文本守卫）', () {
    test('sync_peer_has_no_watch_or_push_subscription_method', () {
      final source = File('lib/model/sync_peer.dart').readAsStringSync();

      // 取出 SyncPeer 声明块（abstract interface class SyncPeer { ... }）。
      final start = source.indexOf('abstract interface class SyncPeer');
      expect(start, greaterThanOrEqualTo(0), reason: '找不到 SyncPeer 声明');
      final brace = source.indexOf('{', start);
      final end = source.indexOf('\n}', brace);
      expect(end, greaterThanOrEqualTo(0), reason: 'SyncPeer 声明块未闭合');
      final block = source.substring(brace, end);

      // 能力差异必须靠 capabilities 表达，不得往基类塞订阅类方法。
      expect(block.contains('watch('), isFalse, reason: 'SyncPeer 不得有 watch()');
      expect(block.contains('subscribe('), isFalse,
          reason: 'SyncPeer 不得有 subscribe()');
      expect(block.contains('Stream<'), isFalse,
          reason: 'SyncPeer 不得返回 Stream');
    });
  });
}

/// 一个最小可编译的云端 peer（测试内 fake，不是交付物）。
class _CloudPeer implements SyncPeer {
  @override
  PeerId get peerId => PeerId('cloud');

  @override
  Channel get channel => Channel.cloud;

  @override
  Future<SyncError?> push(OutboxRecord record) async => null;

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return RemoteChangesPage(changes: const [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async {
    return PeerCapabilities(
      peerId: peerId,
      channel: channel,
      entityVersions: const {},
      supportedFeatures: const {'outbox_v1'},
      protocolVersion: 1,
    );
  }
}

/// 按契约语义实现的 fake pusher：只推 eligiblePeers，异常转 SyncError。
class _FakeFanoutPusher implements PeerFanoutPusher {
  _FakeFanoutPusher(this.peers);

  final List<SyncPeer> peers;

  SyncPeer? _find(PeerId id) {
    for (final p in peers) {
      if (p.peerId == id) return p;
    }
    return null;
  }

  @override
  Future<Map<PeerId, SyncError?>> pushToAll(
    OutboxRecord record, {
    required Set<PeerId> eligiblePeers,
  }) async {
    final results = <PeerId, SyncError?>{};
    for (final id in eligiblePeers) {
      final peer = _find(id);
      if (peer == null) {
        results[id] = const SyncError(
          code: SyncErrorCode.unknown,
          message: '未注册的对端',
        );
        continue;
      }
      try {
        results[id] = await peer.push(record);
      } catch (e) {
        results[id] = SyncError(
          code: SyncErrorCode.unknown,
          message: '对端 ${id.value} 抛异常: $e',
        );
      }
    }
    return results;
  }
}

/// 返回固定结果的 fake peer。
class _FakeResultPeer implements SyncPeer {
  _FakeResultPeer(this.peerId, {required this.error});

  @override
  final PeerId peerId;

  final SyncError? error;

  @override
  Channel get channel => Channel.lan;

  @override
  Future<SyncError?> push(OutboxRecord record) async => error;

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return RemoteChangesPage(changes: const [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async {
    return PeerCapabilities(
      peerId: peerId,
      channel: channel,
      entityVersions: const {},
      supportedFeatures: const {},
      protocolVersion: 1,
    );
  }
}

/// push 即抛异常的 fake peer。
class _ThrowingPeer implements SyncPeer {
  _ThrowingPeer(this.peerId);

  @override
  final PeerId peerId;

  @override
  Channel get channel => Channel.webrtc;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    throw StateError('webrtc 连接断开');
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return RemoteChangesPage(changes: const [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async {
    return PeerCapabilities(
      peerId: peerId,
      channel: channel,
      entityVersions: const {},
      supportedFeatures: const {},
      protocolVersion: 1,
    );
  }
}

/// 计数式 spy peer：记录 push 调用次数，不用 fail()（catch-all 会吞 TestFailure）。
class _CountingPeer implements SyncPeer {
  _CountingPeer(this.peerId);

  @override
  final PeerId peerId;

  int pushCount = 0;

  @override
  Channel get channel => Channel.manualExport;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    pushCount++;
    return null;
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return RemoteChangesPage(changes: const [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async {
    return PeerCapabilities(
      peerId: peerId,
      channel: channel,
      entityVersions: const {},
      supportedFeatures: const {},
      protocolVersion: 1,
    );
  }
}

OutboxRecord _sampleRecord() {
  return OutboxRecord(
    operationId: 'op-1',
    scopeUid: 'scope-1',
    entityType: 'record',
    entityId: 'entity-1',
    opType: 'upsert',
    payloadJson: '{}',
    createdAtUtc: DateTime.utc(2026, 8, 2),
    attempt: 0,
  );
}
