import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';

void main() {
  test('identity cipher round-trips bytes and resolver is asynchronous', () async {
    const resolver = DefaultBlobCipherResolver();
    final cipher = await resolver.resolve(
      scopeUid: 'scope-a',
      v: BlobVisibility.public,
    );
    expect(cipher, isA<IdentityBlobCipher>());
    expect(await cipher.encryptChunk([1, 2], chunkIndex: 0), [1, 2]);
    expect(
      await cipher.decryptChunk([3, 4], chunkIndex: 0, keyVersion: 1),
      [3, 4],
    );
  });
}
