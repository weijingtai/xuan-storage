import 'package:persistence_core/persistence_core.dart';

/// No-op cipher used for public blobs.
final class IdentityBlobCipher implements BlobCipher {
  const IdentityBlobCipher();

  @override
  String get id => 'identity';

  @override
  int get currentKeyVersion => 1;

  @override
  Future<List<int>> encryptChunk(List<int> plain, {required int chunkIndex}) =>
      Future<List<int>>.value(List<int>.from(plain));

  @override
  Future<List<int>> decryptChunk(
    List<int> cipherBytes, {
    required int chunkIndex,
    required int keyVersion,
  }) => Future<List<int>>.value(List<int>.from(cipherBytes));
}

/// Resolver that supports public identity blobs and rejects private blobs.
final class DefaultBlobCipherResolver implements BlobCipherResolver {
  const DefaultBlobCipherResolver();

  @override
  Future<BlobCipher> resolve({
    required String scopeUid,
    required BlobVisibility v,
  }) {
    if (v == BlobVisibility.public) {
      return Future<BlobCipher>.value(const IdentityBlobCipher());
    }
    throw UnsupportedError('Private blob cipher is supplied by S6');
  }
}
