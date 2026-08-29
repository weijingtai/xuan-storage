import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';

void main() {
  group('P2P Same-Account Security Boundary (P2P-IM-001)', () {
    const sessionGuard = SameAccountSessionGuard();

    test('validates and permits authorized same-account session', () {
      const auth = TIMPeerAuthorization(
        scopeUid: 'user_alice',
        peerDeviceId: 'dev_laptop',
        peerPublicKeyFingerprint: 'fp_laptop_123',
        accountBindingCertHash: 'cert_abc',
        keyEpoch: 1,
        trustState: 'active',
        expiresAtUtcMs: 1724720400000 + 86400000,
      );

      final decision = sessionGuard.verifyPeerSession(
        localScopeUid: 'user_alice',
        peerScopeUid: 'user_alice',
        peerDeviceId: 'dev_laptop',
        peerFingerprint: 'fp_laptop_123',
        peerKeyEpoch: 1,
        peerAuth: auth,
        dtlsBindingValid: true,
        signatureValid: true,
      );

      expect(decision, AuthorizationDecision.authorized);
      expect(decision.isAuthorized, isTrue);
    });

    test('rejects cross-account session immediately', () {
      const auth = TIMPeerAuthorization(
        scopeUid: 'user_bob',
        peerDeviceId: 'dev_laptop',
        peerPublicKeyFingerprint: 'fp_laptop_123',
        accountBindingCertHash: 'cert_abc',
        keyEpoch: 1,
        trustState: 'active',
        expiresAtUtcMs: 1724720400000 + 86400000,
      );

      final decision = sessionGuard.verifyPeerSession(
        localScopeUid: 'user_alice',
        peerScopeUid: 'user_bob',
        peerDeviceId: 'dev_laptop',
        peerFingerprint: 'fp_laptop_123',
        peerKeyEpoch: 1,
        peerAuth: auth,
        dtlsBindingValid: true,
        signatureValid: true,
      );

      expect(decision, AuthorizationDecision.deniedScopeMismatch);
      expect(decision.isAuthorized, isFalse);
    });

    test('rejects revoked device or epoch mismatch', () {
      const revokedAuth = TIMPeerAuthorization(
        scopeUid: 'user_alice',
        peerDeviceId: 'dev_lost_phone',
        peerPublicKeyFingerprint: 'fp_lost',
        accountBindingCertHash: 'cert_lost',
        keyEpoch: 1,
        trustState: 'revoked',
        expiresAtUtcMs: 1724720400000,
      );

      final decision = sessionGuard.verifyPeerSession(
        localScopeUid: 'user_alice',
        peerScopeUid: 'user_alice',
        peerDeviceId: 'dev_lost_phone',
        peerFingerprint: 'fp_lost',
        peerKeyEpoch: 1,
        peerAuth: revokedAuth,
        dtlsBindingValid: true,
        signatureValid: true,
      );

      expect(decision, AuthorizationDecision.deniedRevokedOrUntrusted);
    });
  });
}
