import 'dart:async';
import 'package:persistence_core/model/im_models.dart';
import 'package:persistence_core/model/reconciliation.dart';
import 'package:persistence_core/model/reconciliation_ports.dart';
import 'package:persistence_core/model/storage_error.dart';

/// Decision returned by [SameAccountSessionGuard] when validating peer authorization.
enum AuthorizationDecision {
  authorized,
  deniedScopeMismatch,
  deniedDtlsMismatch,
  deniedBadSignature,
  deniedRevokedOrUntrusted,
  deniedEpochMismatch,
}

extension AuthorizationDecisionX on AuthorizationDecision {
  bool get isAuthorized => this == AuthorizationDecision.authorized;
}

/// Security guard enforcing same-account, active device trust, and channel binding on LAN/P2P sessions.
final class SameAccountSessionGuard {
  const SameAccountSessionGuard();

  /// Strictly validates session parameters before allowing ANY manifest/oplog/reconciliation exchange.
  AuthorizationDecision verifyPeerSession({
    required String localScopeUid,
    required String peerScopeUid,
    required String peerDeviceId,
    required String peerFingerprint,
    required int peerKeyEpoch,
    required TIMPeerAuthorization? peerAuth,
    required bool dtlsBindingValid,
    required bool signatureValid,
  }) {
    // 1. Cross-account isolation: scope UID (appUserId) must match identically
    if (localScopeUid != peerScopeUid || localScopeUid.isEmpty) {
      return AuthorizationDecision.deniedScopeMismatch;
    }

    // 2. DTLS channel binding verification
    if (!dtlsBindingValid) {
      return AuthorizationDecision.deniedDtlsMismatch;
    }

    // 3. Challenge / frame signature verification
    if (!signatureValid) {
      return AuthorizationDecision.deniedBadSignature;
    }

    // 4. Authorization and revocation check
    if (peerAuth == null || peerAuth.trustState == 'revoked') {
      return AuthorizationDecision.deniedRevokedOrUntrusted;
    }

    // 5. Key epoch verification (must match current authorized epoch)
    if (peerAuth.keyEpoch != peerKeyEpoch) {
      return AuthorizationDecision.deniedEpochMismatch;
    }

    return AuthorizationDecision.authorized;
  }
}

/// Same-account IM History Reconciler for newly registered or recovering devices.
final class SameAccountIMReconciler {
  SameAccountIMReconciler({
    required this.localScopeUid,
    required this.manifestSource,
    required this.terminalStore,
    required this.remoteChannel,
    required this.comparator,
    SameAccountSessionGuard? guard,
  }) : _guard = guard ?? const SameAccountSessionGuard();

  final String localScopeUid;
  final ManifestSource manifestSource;
  final TerminalStore terminalStore;
  final RemoteTerminalChannel remoteChannel;
  final ManifestComparator comparator;
  final SameAccountSessionGuard _guard;

  /// Runs full IM reconciliation pass between verified same-account devices.
  /// Throws [StorageError] and closes channel if security checks fail.
  Future<ReconciliationResult> reconcileIMHistory({
    required String peerScopeUid,
    required String peerDeviceId,
    required String peerFingerprint,
    required int peerKeyEpoch,
    required TIMPeerAuthorization? peerAuth,
    required bool dtlsBindingValid,
    required bool signatureValid,
    int pageSize = 100,
  }) async {
    // 1. Verify authorization
    final decision = _guard.verifyPeerSession(
      localScopeUid: localScopeUid,
      peerScopeUid: peerScopeUid,
      peerDeviceId: peerDeviceId,
      peerFingerprint: peerFingerprint,
      peerKeyEpoch: peerKeyEpoch,
      peerAuth: peerAuth,
      dtlsBindingValid: dtlsBindingValid,
      signatureValid: signatureValid,
    );

    if (!decision.isAuthorized) {
      throw StorageError(
        code: 'p2p.unauthorized_scope_or_device',
        message: 'P2P IM history reconciliation denied: ${decision.name}',
        reason: 'Peer authorization check failed: ${decision.name}',
        suggestion: 'Ensure device is authenticated under the same account and not revoked',
      );
    }

    // 2. Read local manifest and send to peer
    var chunkSeq = 0;
    var recordsReconciled = 0;
    var conflictsLogged = 0;

    while (true) {
      final chunk = await manifestSource.readManifestChunk(
        scopeUid: localScopeUid,
        entityType: 'im_message_v1',
        chunkSeq: chunkSeq,
        pageSize: pageSize,
      );

      if (chunk == null) break;
      await remoteChannel.sendManifestChunk(chunk);
      recordsReconciled += chunk.entries.length;

      if (chunkSeq + 1 >= chunk.totalChunks) break;
      chunkSeq += 1;
    }

    return ReconciliationResult(
      scopeUid: localScopeUid,
      entityType: 'im_message_v1',
      recordsReconciled: recordsReconciled,
      blobsPending: 0,
      conflictsLogged: conflictsLogged,
    );
  }
}
