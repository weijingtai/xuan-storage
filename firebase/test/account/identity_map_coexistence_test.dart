import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:persistence_firebase/account/firestore_app_user_id_resolver.dart';

/// Returns true if the error looks like a fake_cloud_firestore limitation
/// (no transaction / serverTimestamp support).
bool _isFakeFirestoreLimitation(Object e) {
  final msg = e.toString();
  return msg.contains('serverTimestamp') ||
      msg.contains('Transaction') ||
      msg.contains('transaction') ||
      msg.contains('FieldValue');
}

void main() {
  group('identity_map coexistence', () {
    late FakeFirebaseFirestore fs;
    late FirestoreAppUserIdResolver resolver;

    setUp(() async {
      fs = FakeFirebaseFirestore();

      // Pre-seed a legacy identity_map entry (the old schema).
      await fs.collection('identity_map').doc('prov-1').set({
        'appUserId': 'legacy-X',
        'schemaVersion': 1,
      });

      resolver = FirestoreAppUserIdResolver(fs);
    });

    test(
      'existing identity_map user resolves to original appUserId',
      () async {
        try {
          final result = await resolver.resolve(
            providerUserId: const ProviderUserId('prov-1'),
            providerId: 'fake',
          );

          expect(
            result,
            equals(const AccountUserId('legacy-X')),
            reason: 'Legacy identity_map entry must still resolve correctly',
          );
        } catch (e) {
          if (_isFakeFirestoreLimitation(e)) {
            // Skip rather than report a false-green pass.
            markTestSkipped(
              'fake_cloud_firestore lacks transaction/serverTimestamp '
              'support: $e',
            );
            return;
          }
          rethrow;
        }
      },
    );

    test(
      'new providerUID creates a fresh appUserId (not "legacy-X")',
      () async {
        try {
          final result = await resolver.resolve(
            providerUserId: const ProviderUserId('prov-NEW'),
            providerId: 'fake',
          );

          expect(
            result.value,
            isNotEmpty,
            reason: 'New provider should get a generated UUID',
          );
          expect(
            result,
            isNot(equals(const AccountUserId('legacy-X'))),
            reason: 'New provider must NOT collide with legacy id',
          );
        } catch (e) {
          if (_isFakeFirestoreLimitation(e)) {
            markTestSkipped(
              'fake_cloud_firestore lacks transaction/serverTimestamp '
              'support: $e',
            );
            return;
          }
          rethrow;
        }
      },
    );

    test(
      'resolver never reads or writes account_identity_links collection',
      () async {
        try {
          // Resolve a legacy entry.
          await resolver.resolve(
            providerUserId: const ProviderUserId('prov-1'),
            providerId: 'fake',
          );

          // Resolve a new entry.
          await resolver.resolve(
            providerUserId: const ProviderUserId('prov-ISO'),
            providerId: 'fake',
          );

          // Dump the entire Firestore instance and verify
          // the account_identity_links collection is absent.
          final snapshot =
              await fs.collection('account_identity_links').get();
          expect(
            snapshot.docs,
            isEmpty,
            reason: 'FirestoreAppUserIdResolver must never touch '
                'account_identity_links',
          );
        } catch (e) {
          if (_isFakeFirestoreLimitation(e)) {
            markTestSkipped(
              'fake_cloud_firestore lacks transaction/serverTimestamp '
              'support: $e',
            );
            return;
          }
          rethrow;
        }
      },
    );
  });
}
