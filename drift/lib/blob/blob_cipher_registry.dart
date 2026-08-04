/// Registry for BlobCipher implementations.
///
/// Allows registering private ciphers per scope, supporting key version
/// validation and undecryptable error mapping.
library;

import 'package:persistence_core/persistence_core.dart';

import 'identity_blob_cipher.dart';

/// Registry that resolves ciphers by scope and visibility.
///
/// - Public visibility always returns [IdentityBlobCipher].
/// - Private visibility looks up a registered cipher per scope.
/// - If no cipher is registered for a private scope, throws [BlobUndecryptableError].
final class BlobCipherRegistry implements BlobCipherResolver {
  final Map<String, BlobCipher> _privateCiphers = {};

  /// Creates a [BlobCipherRegistry] with no private ciphers registered.
  BlobCipherRegistry();

  /// Register a private cipher for [scopeUid].
  void register(String scopeUid, BlobCipher cipher) {
    _privateCiphers[scopeUid] = cipher;
  }

  @override
  Future<BlobCipher> resolve({
    required String scopeUid,
    required BlobVisibility v,
  }) {
    if (v == BlobVisibility.public) {
      return Future<BlobCipher>.value(const IdentityBlobCipher());
    }
    final cipher = _privateCiphers[scopeUid];
    if (cipher != null) {
      return Future<BlobCipher>.value(cipher);
    }
    // Private key not available — throw undecryptable error.
    return Future<BlobCipher>.error(
      BlobUndecryptableError(),
    );
  }
}