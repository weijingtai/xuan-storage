import 'package:persistence_core/core/sync_coordinator.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:test/test.dart';

const _scopeUid = 'user_alice';
final _now = DateTime.utc(2026, 1, 10, 9, 0, 0);
const _peerA = PeerId('peer_A');
const _peerB = PeerId('peer_B');

class _CountingSyncPeer implements SyncPeer {
  _CountingSyncPeer(this._peerId, {Channel channel = Channel.cloud})
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

OutboxRecord _record(String operationId, String entityType) => OutboxRecord(
      operationId: operationId,
      scopeUid: _scopeUid,
      entityType: entityType,
      entityId: 'e1',
      opType: 'upsert',
      payloadJson: '{"text":"msg"}',
      createdAtUtc: _now,
      attempt: 0,
    );

void main() {
  setUp(StoragePolicyRegistry.clearForTesting);

  group('SyncCoordinator Fanout Regression Prevention (Task 5)', () {
    test('P2P-IM-003: Peer A success and Peer B retry does NOT resend duplicate to Peer A', () async {
      StoragePolicyRegistry.register(
        'im_message_v1',
        StoragePolicy.private(carriers: const {}),
      );

      final outbox = InMemoryOutboxStore();
      final peerA = _CountingSyncPeer(_peerA, channel: Channel.lan);
      final peerB = _CountingSyncPeer(_peerB, channel: Channel.lan)
        ..onPush = (_) async => const SyncError(
              code: SyncErrorCode.network,
              message: 'Peer B offline',
            );

      final coordinator = SyncCoordinator(
        outboxStore: outbox,
        remoteGateway: peerA,
        peers: [peerA, peerB],
        nowUtc: () => _now,
      );

      await outbox.enqueue(_record('op_msg_1', 'im_message_v1'));

      // Round 1: Peer A succeeds (pushCount=1), Peer B fails (pushCount=1)
      final round1Results = await coordinator.pushOnce(scopeUid: _scopeUid);
      expect(round1Results.length, 2);
      expect(peerA.pushCount, 1);
      expect(peerA.received, ['op_msg_1']);
      expect(peerB.pushCount, 1);
      expect(peerB.received, ['op_msg_1']);

      // Round 2: Peer B comes back online (remove failure hook)
      peerB.onPush = null;

      // Execute retry pass
      final round2Results = await coordinator.pushOnce(scopeUid: _scopeUid);
      expect(round2Results.length, 2);

      // CRITICAL ASSERTION: Peer A must NOT have received op_msg_1 again
      expect(
        peerA.pushCount,
        1,
        reason: 'Peer A was already marked success in round 1 and must NOT be resent in round 2',
      );
      expect(peerA.received.length, 1);

      // Peer B must receive the retry and succeed
      expect(
        peerB.pushCount,
        2,
        reason: 'Peer B had failed in round 1 and must be retried in round 2',
      );
      expect(peerB.received, ['op_msg_1', 'op_msg_1']);
    });
  });
}
