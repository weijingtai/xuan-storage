import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:repository_interface_account/repository_interface_account.dart';

final class FirestoreAppUserIdResolver implements AppUserIdResolver {
  FirestoreAppUserIdResolver(this._firestore, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  @override
  Future<AccountUserId> resolve({
    required ProviderUserId providerUserId,
    required String providerId,
  }) async {
    final doc = _firestore.collection('identity_map').doc(providerUserId.value);

    try {
      final result = await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(doc);
        final existing = snapshot.data();
        final existingAppUserId = existing?['appUserId'];

        if (existingAppUserId is String && existingAppUserId.isNotEmpty) {
          tx.set(
            doc,
            {
              'lastSeenAt': FieldValue.serverTimestamp(),
              'providerType': providerId,
              'schemaVersion': 1,
            },
            SetOptions(merge: true),
          );
          return existingAppUserId;
        }

        final newAppUserId = _uuid.v4();
        tx.set(
          doc,
          {
            'appUserId': newAppUserId,
            'createdAt': FieldValue.serverTimestamp(),
            'lastSeenAt': FieldValue.serverTimestamp(),
            'providerType': providerId,
            'schemaVersion': 1,
          },
        );
        return newAppUserId;
      }).timeout(const Duration(seconds: 12));

      return AccountUserId(result);
    } on TimeoutException {
      throw const AccountRepositoryError(
        code: AccountErrorCode.networkUnavailable,
        message: 'Firestore transaction timed out',
      );
    } catch (e) {
      if (e is AccountRepositoryError || e is AccountIdentityConflict) {
        rethrow;
      }
      throw AccountRepositoryError(
        code: AccountErrorCode.unknown,
        message: e.toString(),
        cause: e,
      );
    }
  }
}
