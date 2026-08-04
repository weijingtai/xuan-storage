import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/in_memory_blob_store.dart';

Future<List<int>> _read(BlobReadResult result) async {
  final ok = result as BlobOk;
  return ok.plaintext.expand((part) => part).toList();
}

void main() {
  test('put deduplicates identical content and reads exact bytes', () async {
    final store = InMemoryBlobStore(scopeUid: 'scope-a');
    final bytes = List<int>.generate(20000, (i) => i % 251);
    final a = await store.put(Stream.value(bytes), mimeType: 'x/test', tier: BlobTier.sourceOfTruth, expectedBytes: bytes.length);
    final b = await store.put(Stream.value(bytes), mimeType: 'x/test', tier: BlobTier.sourceOfTruth, expectedBytes: bytes.length);
    expect(a, b);
    expect(await _read(await store.openRead(a)), bytes);
  });

  test('partial chunks can resume from interruption', () async {
    final store = InMemoryBlobStore(scopeUid: 'scope-a');
    const handle = BlobHandle(plaintextSha256: 'hash', cipherManifestId: 'manifest', cipherId: 'identity', keyVersion: 1, totalBytes: 4, chunkCount: 2, mimeType: 'x/test');
    await store.putChunk(handle, 0, [1, 2]);
    expect(await store.statusOf(handle), BlobStatus.partial);
    expect(await store.presentChunks(handle), {0});
    await store.putChunk(handle, 1, [3, 4]);
    expect(await _read(await store.openRead(handle)), [1, 2, 3, 4]);
  });

  test('cache eviction never removes sourceOfTruth bytes', () async {
    final store = InMemoryBlobStore(scopeUid: 'scope-a');
    final source = await store.put(Stream.value([1]), mimeType: 'x/test', tier: BlobTier.sourceOfTruth, expectedBytes: 1);
    final cache = await store.put(Stream.value([2]), mimeType: 'x/test', tier: BlobTier.cache, expectedBytes: 1);
    final result = await store.evictCache(targetFreeBytes: 1);
    expect(result.freed, 1);
    expect(await store.statusOf(cache), BlobStatus.absent);
    expect(await store.statusOf(source), BlobStatus.complete);
  });
}
