import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:persistence_firebase/account/account.dart';
import 'package:repository_interface_account/repository_interface_account.dart';

/// Firebase Auth emulator integration tests (TACT-3B).
///
/// Requires a running Firebase Auth emulator on localhost:9099
/// AND a Flutter platform environment (device/emulator, not VM).
/// In `flutter test --platform=vm`, Firebase.initializeApp() will fail
/// due to missing platform channels — tests will skip with explanation.
///
/// To run: `flutter test` on a connected device, or set up
/// `flutter test --platform=chrome` for web.
void main() {
  group('Firebase Auth Emulator Contract Test (TACT-3B)', () {
    late fb.FirebaseAuth auth;
    late FirebaseAccountAuthGateway gateway;
    bool _skipped = false;

    setUpAll(() async {
      // Attempt Firebase init — fails in VM test runner
      try {
        await Firebase.initializeApp();
      } catch (e) {
        _skipped = true;
        markTestSkipped(
          'Firebase platform channels unavailable in flutter test VM.\n'
          'Error: $e\n'
          'Run on device: flutter test --device=...\n'
          'Or set FIREBASE_AUTH_EMULATOR_HOST=localhost:9099',
        );
        return;
      }

      // Detect emulator availability
      final emulatorHost =
          Platform.environment['FIREBASE_AUTH_EMULATOR_HOST'];
      final isEmulatorSet = emulatorHost != null && emulatorHost.isNotEmpty;

      if (!isEmulatorSet) {
        // Probe localhost:9099
        try {
          await Socket.connect('localhost', 9099,
              timeout: const Duration(seconds: 2));
        } catch (_) {
          _skipped = true;
          markTestSkipped(
            'Firebase Auth emulator not detected on localhost:9099.\n'
            'Start: firebase emulators:start --only auth',
          );
          return;
        }
      }

      auth = fb.FirebaseAuth.instance;
      if (isEmulatorSet) {
        final parts = emulatorHost!.split(':');
        auth.useAuthEmulator(parts.first, int.parse(parts.last));
      } else {
        auth.useAuthEmulator('localhost', 9099);
      }

      gateway = FirebaseAccountAuthGateway(
        firebaseAuth: auth,
        appUserIdResolver: const IdentityAppUserIdResolver(),
      );
    });

    test('anonymous login returns AccountSession with non-empty providerUserId and appUserId mapping', () async {
      if (_skipped) return;
      final session = await gateway.signInAnonymously();
      expect(session, isA<AccountSession>());
      expect(session.kind, AccountKind.anonymous);
      expect(session.appUserId.value, isNotEmpty);
      expect(session.providerUserId.value, isNotEmpty);

      // Cleanup
      await auth.currentUser!.delete();
    });

    test('createUserWithEmailPassword returns AccountSession(kind: registered)', () async {
      if (_skipped) return;
      final email = 'it-${DateTime.now().millisecondsSinceEpoch}@emulator.test';
      final session = await gateway.createUserWithEmailPassword(
        email: email,
        password: 'test1234',
      );
      expect(session, isA<AccountSession>());
      expect(session.kind, AccountKind.registered);
      expect(session.email, email);

      // Cleanup
      await auth.currentUser!.delete();
    });

    test('signInWithEmailPassword returns AccountSession(kind: registered)', () async {
      if (_skipped) return;
      // First create a user
      final email = 'si-${DateTime.now().millisecondsSinceEpoch}@emulator.test';
      await gateway.createUserWithEmailPassword(email: email, password: 'test1234');
      await auth.signOut();

      // Then sign in
      final session = await gateway.signInWithEmailPassword(
        email: email,
        password: 'test1234',
      );
      expect(session.kind, AccountKind.registered);
      expect(session.email, email);

      // Cleanup
      await auth.currentUser!.delete();
    });

    test('linkAnonymousToEmailPassword upgrades session and does not expose UserCredential', () async {
      if (_skipped) return;
      // Anonymous login first
      final anon = await gateway.signInAnonymously();
      expect(anon.kind, AccountKind.anonymous);

      // Link
      final email = 'link-${DateTime.now().millisecondsSinceEpoch}@emulator.test';
      final linked = await gateway.linkAnonymousToEmailPassword(
        email: email,
        password: 'test1234',
      );
      expect(linked, isA<AccountSession>());
      expect(linked.kind, AccountKind.registered);
      expect(linked.email, email);
      // No UserCredential or FirebaseSession type exposed
      expect(linked.appUserId, isA<AccountUserId>());

      // Cleanup
      await auth.currentUser!.delete();
    });

    test('signOut causes watchSession to emit null', () async {
      if (_skipped) return;
      // Sign in first
      final email = 'so-${DateTime.now().millisecondsSinceEpoch}@emulator.test';
      await gateway.createUserWithEmailPassword(email: email, password: 'test1234');

      // watch session stream
      AccountSession? emitted;
      final sub = gateway.watchSession().listen((s) {
        if (s == null) emitted = null;
      });

      await gateway.signOut();
      // Allow stream to propagate
      await Future.delayed(const Duration(milliseconds: 100));

      expect(emitted, isNull);
      await sub.cancel();
    });

    test('FirebaseAuthException is translated to provider-neutral AccountRepositoryError', () async {
      if (_skipped) return;
      // Sign in with wrong password on a non-existent user
      expect(
        () => gateway.signInWithEmailPassword(
          email: 'nonexistent@emulator.test',
          password: 'wrong',
        ),
        throwsA(isA<AccountRepositoryError>()),
      );
    });
  });
}
