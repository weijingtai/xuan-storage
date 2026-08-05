/// Tests for blob cipher resolution.
///
/// Verifies:
/// - Public resolver returns identity cipher
/// - Private registered cipher works
/// - Unavailable private key maps to BlobUndecryptableError
/// - Key version validation
/// - Copied byte lists (mutation-safe)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';

/// A test cipher that simulates private encryption.
final class TestPrivateCipher implements BlobCipher {
  final int _xorKey;

  const TestPrivateCipher({required int xorKey}) : _xorKey = xorKey;

  @override
  String get id => 'test_private';

  @override
  int get currentKeyVersion => 1;

  @override
  Future<List<int>> encryptChunk(List<int> plain, {required int chunkIndex}) {
    return Future.value(plain.map((b) => b ^ _xorKey).toList());
  }

  @override
  Future<List<int>> decryptChunk(
    List<int> cipherBytes, {
    required int chunkIndex,
    required int keyVersion,
  }) async {
    if (keyVersion != currentKeyVersion) {
      throw BlobUndecryptableError();
    }
    return cipherBytes.map((b) => b ^ _xorKey).toList();
  }
}

void main() {
  group('blob cipher resolution', () {
    test('public resolver returns identity cipher', () async {
      final registry = BlobCipherRegistry();
      final cipher = await registry.resolve(
        scopeUid: 'scope-a',
        v: BlobVisibility.public,
      );
      expect(cipher, isA<IdentityBlobCipher>());
      expect(cipher.id, 'identity');
      expect(cipher.currentKeyVersion, 1);
    });

    test('identity cipher round-trips bytes', () async {
      const cipher = IdentityBlobCipher();
      final encrypted = await cipher.encryptChunk([1, 2, 3], chunkIndex: 0);
      expect(encrypted, [1, 2, 3]);
      final decrypted = await cipher.decryptChunk(
        encrypted,
        chunkIndex: 0,
        keyVersion: 1,
      );
      expect(decrypted, [1, 2, 3]);
    });

    test('identity cipher produces copied byte lists (mutation-safe)', () async {
      const cipher = IdentityBlobCipher();
      final original = [1, 2, 3];
      final encrypted = await cipher.encryptChunk(original, chunkIndex: 0);
      // Mutating original should not affect encrypted output
      original[0] = 99;
      expect(encrypted, [1, 2, 3]);
    });

    test('private registered cipher works', () async {
      final registry = BlobCipherRegistry();
      registry.register('scope-a', TestPrivateCipher(xorKey: 0xAA));

      final cipher = await registry.resolve(
        scopeUid: 'scope-a',
        v: BlobVisibility.private,
      );
      expect(cipher, isA<TestPrivateCipher>());
      expect(cipher.id, 'test_private');

      final encrypted = await cipher.encryptChunk([1, 2, 3], chunkIndex: 0);
      expect(encrypted, [1 ^ 0xAA, 2 ^ 0xAA, 3 ^ 0xAA]);

      final decrypted = await cipher.decryptChunk(
        encrypted,
        chunkIndex: 0,
        keyVersion: 1,
      );
      expect(decrypted, [1, 2, 3]);
    });

    test('unavailable private key maps to BlobUndecryptableError', () async {
      final registry = BlobCipherRegistry();
      // No cipher registered for scope-a

      await expectLater(
        registry.resolve(
          scopeUid: 'scope-a',
          v: BlobVisibility.private,
        ),
        throwsA(isA<BlobUndecryptableError>()),
      );
    });

    test('key version mismatch causes undecryptable error', () async {
      const cipher = TestPrivateCipher(xorKey: 0xAA);
      final encrypted = await cipher.encryptChunk([1], chunkIndex: 0);

      await expectLater(
        cipher.decryptChunk(encrypted, chunkIndex: 0, keyVersion: 999),
        throwsA(isA<BlobUndecryptableError>()),
      );
    });
  });
}