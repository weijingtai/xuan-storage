import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/blob_types.dart';

void main() {
  group('BlobHandle 值对象', () {
    test('blob_handle_carries_both_hashes_and_key_version', () {
      // 公开 blob：cipher 是 identity（不加密），两个 hash 相同
      const publicHandle = BlobHandle(
        plaintextSha256: 'abc123',
        cipherManifestId: 'abc123',
        cipherId: 'identity',
        keyVersion: 1,
        totalBytes: 1024,
        chunkCount: 4,
        mimeType: 'image/jpeg',
      );
      expect(publicHandle.plaintextSha256, 'abc123');
      expect(publicHandle.cipherManifestId, 'abc123');
      expect(publicHandle.plaintextSha256, publicHandle.cipherManifestId);

      // 私有 blob：cipherManifestId 是随机 UUID，与 plaintextSha256 不同
      const privateHandle = BlobHandle(
        plaintextSha256: 'def456',
        cipherManifestId: 'a-random-uuid',
        cipherId: 'aes-gcm',
        keyVersion: 3,
        totalBytes: 2048,
        chunkCount: 8,
        mimeType: 'video/mp4',
      );
      expect(privateHandle.plaintextSha256, isNot(privateHandle.cipherManifestId));
      expect(privateHandle.cipherId, 'aes-gcm');
      expect(privateHandle.keyVersion, 3);

      // 值相等语义：同值 == 为真
      const same = BlobHandle(
        plaintextSha256: 'def456',
        cipherManifestId: 'a-random-uuid',
        cipherId: 'aes-gcm',
        keyVersion: 3,
        totalBytes: 2048,
        chunkCount: 8,
        mimeType: 'video/mp4',
      );
      expect(privateHandle, same);
      expect(privateHandle.hashCode, same.hashCode);
      expect(publicHandle, isNot(privateHandle));
    });
  });

  group('BlobReadResult sealed 穷尽匹配', () {
    test('blob_read_result_five_branches_exhaustive', () {
      String describe(BlobReadResult r) => switch (r) {
            BlobOk() => 'ok',
            BlobAbsent() => 'absent',
            BlobPartial(:final presentChunks) =>
              'partial:${presentChunks.length}',
            BlobCorrupt(:final badChunks) => 'corrupt:${badChunks.length}',
            BlobUndecryptable() => 'undecryptable',
          };

      expect(describe(BlobReadResult.ok(Stream.value([1, 2, 3]))), 'ok');
      expect(describe(BlobReadResult.absent()), 'absent');

      final partial = BlobReadResult.partial({0, 1, 3});
      expect(describe(partial), 'partial:3');
      expect(partial, isA<BlobPartial>());
      expect((partial as BlobPartial).presentChunks, {0, 1, 3});

      final corrupt = BlobReadResult.corrupt({2});
      expect(describe(corrupt), 'corrupt:1');
      expect((corrupt as BlobCorrupt).badChunks, {2});

      expect(describe(BlobReadResult.undecryptable()), 'undecryptable');
    });
  });

  group('BlobStatus / BlobTier / BlobVisibility', () {
    test('blob_status_has_five_states', () {
      expect(BlobStatus.values, hasLength(5));
      expect(
        BlobStatus.values.map((e) => e.name),
        ['absent', 'partial', 'complete', 'corrupt', 'undecryptable'],
      );
      // 不允许布尔式的 isPresent：partial 态必须可表达（§6.2 断点续传）
      expect(BlobStatus.partial, isNotNull);
    });

    test('blob_tier_two_states_only', () {
      expect(BlobTier.values, hasLength(2));
      expect(
        BlobTier.values.map((e) => e.name),
        ['sourceOfTruth', 'cache'],
      );
    });

    test('blob_visibility_two_states', () {
      expect(BlobVisibility.values, hasLength(2));
      expect(
        BlobVisibility.values.map((e) => e.name),
        ['private', 'public'],
      );
    });
  });
}
