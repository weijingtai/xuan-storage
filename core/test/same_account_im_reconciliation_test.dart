import 'package:persistence_core/persistence_core.dart';
import 'package:test/test.dart';

class _FakeManifestSource implements ManifestSource {
  final List<ManifestChunk> chunks;
  _FakeManifestSource(this.chunks);

  int readCalls = 0;

  @override
  Future<ManifestChunk?> readManifestChunk({
    required String scopeUid,
    required String entityType,
    required int chunkSeq,
    required int pageSize,
  }) async {
    readCalls += 1;
    if (chunkSeq >= chunks.length) return null;
    return chunks[chunkSeq];
  }
}

class _FakeTerminalStore implements TerminalStore {
  final Map<String, EntityTerminal> store = {};

  @override
  Future<EntityTerminal?> readTerminal({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) async =>
      store['$scopeUid:$entityType:$entityId'];

  @override
  Future<void> writeTerminal(EntityTerminal terminal) async {
    store['${terminal.scopeUid}:${terminal.entityType}:${terminal.entityId}'] = terminal;
  }
}

class _FakeRemoteTerminalChannel implements RemoteTerminalChannel {
  final List<ManifestChunk> receivedChunks = [];
  final List<EntityTerminal> receivedTerminals = [];
  final List<EntityRequest> receivedRequests = [];
  final List<CursorAdvance> receivedAdvances = [];

  @override
  Future<void> sendManifestChunk(ManifestChunk chunk) async {
    receivedChunks.add(chunk);
  }

  @override
  Future<void> sendTerminals(List<EntityTerminal> terminals) async {
    receivedTerminals.addAll(terminals);
  }

  @override
  Future<void> requestTerminals(List<EntityRequest> requests) async {
    receivedRequests.addAll(requests);
  }

  @override
  Future<void> sendCursorAdvance(CursorAdvance advance) async {
    receivedAdvances.add(advance);
  }
}

void main() {
  group('Same-Account P2P IM Reconciliation & Security Boundaries (Task 6)', () {
    const localUid = 'u_alice';
    const activeAuth = TIMPeerAuthorization(
      scopeUid: localUid,
      peerDeviceId: 'dev_alice_tablet',
      peerPublicKeyFingerprint: 'fp_tablet_123',
      accountBindingCertHash: 'cert_123',
      keyEpoch: 2,
      trustState: 'active',
      expiresAtUtcMs: 1724720400000 + 86400000,
    );

    test('P2P-IM-001: Denies cross-account connection (scope mismatch) and yields zero data disclosure', () async {
      final manifestSource = _FakeManifestSource([
        const ManifestChunk(
          scopeUid: localUid,
          entityType: 'im_message_v1',
          chunkSeq: 0,
          totalChunks: 1,
          entries: [
            ManifestEntry(entityId: 'msg_1', hlcPacked: 1000, deviceId: 'dev_phone', isDeleted: false),
          ],
        ),
      ]);
      final channel = _FakeRemoteTerminalChannel();
      final reconciler = SameAccountIMReconciler(
        localScopeUid: localUid,
        manifestSource: manifestSource,
        terminalStore: _FakeTerminalStore(),
        remoteChannel: channel,
        comparator: DefaultManifestComparator(),
      );

      // Attempt reconciliation from different account 'u_bob'
      expect(
        () => reconciler.reconcileIMHistory(
          peerScopeUid: 'u_bob',
          peerDeviceId: 'dev_bob',
          peerFingerprint: 'fp_bob',
          peerKeyEpoch: 2,
          peerAuth: activeAuth,
          dtlsBindingValid: true,
          signatureValid: true,
        ),
        throwsA(isA<StorageError>()),
      );

      // Zero manifest chunks sent
      expect(channel.receivedChunks, isEmpty);
      expect(manifestSource.readCalls, 0);
    });

    test('P2P-IM-001: Denies revoked device and returns zero manifest/oplog', () async {
      final manifestSource = _FakeManifestSource([]);
      final channel = _FakeRemoteTerminalChannel();
      final reconciler = SameAccountIMReconciler(
        localScopeUid: localUid,
        manifestSource: manifestSource,
        terminalStore: _FakeTerminalStore(),
        remoteChannel: channel,
        comparator: DefaultManifestComparator(),
      );

      const revokedAuth = TIMPeerAuthorization(
        scopeUid: localUid,
        peerDeviceId: 'dev_alice_old_phone',
        peerPublicKeyFingerprint: 'fp_old',
        accountBindingCertHash: 'cert_old',
        keyEpoch: 2,
        trustState: 'revoked', // Revoked device!
        expiresAtUtcMs: 1724720400000,
      );

      expect(
        () => reconciler.reconcileIMHistory(
          peerScopeUid: localUid,
          peerDeviceId: 'dev_alice_old_phone',
          peerFingerprint: 'fp_old',
          peerKeyEpoch: 2,
          peerAuth: revokedAuth,
          dtlsBindingValid: true,
          signatureValid: true,
        ),
        throwsA(isA<StorageError>()),
      );

      expect(channel.receivedChunks, isEmpty);
    });

    test('P2P-IM-001: Denies changed epoch, bad DTLS binding or bad signature', () async {
      final reconciler = SameAccountIMReconciler(
        localScopeUid: localUid,
        manifestSource: _FakeManifestSource([]),
        terminalStore: _FakeTerminalStore(),
        remoteChannel: _FakeRemoteTerminalChannel(),
        comparator: DefaultManifestComparator(),
      );

      // 1. Epoch mismatch
      expect(
        () => reconciler.reconcileIMHistory(
          peerScopeUid: localUid,
          peerDeviceId: 'dev_alice_tablet',
          peerFingerprint: 'fp_tablet_123',
          peerKeyEpoch: 99, // mismatch (auth has 2)
          peerAuth: activeAuth,
          dtlsBindingValid: true,
          signatureValid: true,
        ),
        throwsA(isA<StorageError>()),
      );

      // 2. Bad DTLS binding
      expect(
        () => reconciler.reconcileIMHistory(
          peerScopeUid: localUid,
          peerDeviceId: 'dev_alice_tablet',
          peerFingerprint: 'fp_tablet_123',
          peerKeyEpoch: 2,
          peerAuth: activeAuth,
          dtlsBindingValid: false,
          signatureValid: true,
        ),
        throwsA(isA<StorageError>()),
      );

      // 3. Bad signature
      expect(
        () => reconciler.reconcileIMHistory(
          peerScopeUid: localUid,
          peerDeviceId: 'dev_alice_tablet',
          peerFingerprint: 'fp_tablet_123',
          peerKeyEpoch: 2,
          peerAuth: activeAuth,
          dtlsBindingValid: true,
          signatureValid: false,
        ),
        throwsA(isA<StorageError>()),
      );
    });

    test('P2P-IM-001: Same-account active device successfully reconciles IM dataset and converges tombstones', () async {
      final manifestSource = _FakeManifestSource([
        const ManifestChunk(
          scopeUid: localUid,
          entityType: 'im_message_v1',
          chunkSeq: 0,
          totalChunks: 1,
          entries: [
            ManifestEntry(entityId: 'msg_1', hlcPacked: 1000, deviceId: 'dev_phone', isDeleted: false),
            ManifestEntry(entityId: 'msg_deleted', hlcPacked: 2000, deviceId: 'dev_phone', isDeleted: true),
          ],
        ),
      ]);
      final channel = _FakeRemoteTerminalChannel();
      final reconciler = SameAccountIMReconciler(
        localScopeUid: localUid,
        manifestSource: manifestSource,
        terminalStore: _FakeTerminalStore(),
        remoteChannel: channel,
        comparator: DefaultManifestComparator(),
      );

      final result = await reconciler.reconcileIMHistory(
        peerScopeUid: localUid,
        peerDeviceId: 'dev_alice_tablet',
        peerFingerprint: 'fp_tablet_123',
        peerKeyEpoch: 2,
        peerAuth: activeAuth,
        dtlsBindingValid: true,
        signatureValid: true,
      );

      expect(result.recordsReconciled, 2);
      expect(channel.receivedChunks.length, 1);
      final entries = channel.receivedChunks.first.entries;
      expect(entries.any((e) => e.entityId == 'msg_1' && !e.isDeleted), isTrue);
      expect(entries.any((e) => e.entityId == 'msg_deleted' && e.isDeleted), isTrue, reason: 'Tombstones must converge across same-account devices');
    });
  });
}
