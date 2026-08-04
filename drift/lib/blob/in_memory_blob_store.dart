import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:persistence_core/persistence_core.dart';

import 'identity_blob_cipher.dart';

const int blobChunkBytes = 16384;

final class InMemoryBlobStore implements LocalBlobStore {
  InMemoryBlobStore({required this.scopeUid, BlobCipherResolver? resolver})
      : _resolver = resolver ?? const DefaultBlobCipherResolver();

  @override
  final String scopeUid;
  final BlobCipherResolver _resolver;
  final Map<BlobHandle, Map<int, List<int>>> _chunks = {};
  final Map<BlobHandle, BlobTier> _tiers = {};
  final Map<BlobHandle, DateTime> _access = {};
  final Map<String, Set<BlobHandle>> _refs = {};

  @override
  Future<BlobHandle> putFile(String path, {required String mimeType, required BlobTier tier, CancellationToken? cancel, void Function(int sent, int total)? onProgress}) async => throw UnsupportedError('Use put(Stream) in memory store');

  @override
  Future<BlobHandle> put(Stream<List<int>> bytes, {required String mimeType, required BlobTier tier, required int expectedBytes, CancellationToken? cancel}) async {
    final data = <int>[];
    await for (final part in bytes) { cancel?.throwIfCancelled(); data.addAll(part); }
    final digest = sha256.convert(data).toString();
    final handle = BlobHandle(plaintextSha256: digest, cipherManifestId: digest, cipherId: 'identity', keyVersion: 1, totalBytes: data.length, chunkCount: (data.length + blobChunkBytes - 1) ~/ blobChunkBytes, mimeType: mimeType);
    _chunks.putIfAbsent(handle, () => {});
    _tiers[handle] = tier; _access[handle] = DateTime.now().toUtc();
    for (var i = 0; i < handle.chunkCount; i++) { await putChunk(handle, i, data.sublist(i * blobChunkBytes, (i + 1) * blobChunkBytes > data.length ? data.length : (i + 1) * blobChunkBytes)); }
    return handle;
  }

  @override
  Future<void> putChunk(BlobHandle handle, int index, List<int> cipherBytes) async { _chunks.putIfAbsent(handle, () => {})[index] = List<int>.from(cipherBytes); _access[handle] = DateTime.now().toUtc(); }
  @override
  Future<List<int>> readCipherChunk(BlobHandle handle, int index) async { final b = _chunks[handle]?[index]; if (b == null) throw BlobNotFoundError(); return List<int>.from(b); }
  @override
  Future<BlobReadResult> openRead(BlobHandle handle, {CancellationToken? cancel}) async { final present = await presentChunks(handle); if (present.isEmpty) return const BlobReadResult.absent(); if (present.length != handle.chunkCount) return BlobReadResult.partial(present); final all = <int>[]; for (var i = 0; i < handle.chunkCount; i++) { cancel?.throwIfCancelled(); all.addAll(await readCipherChunk(handle, i)); } return BlobReadResult.ok(Stream.value(all)); }
  @override
  Future<BlobStatus> statusOf(BlobHandle handle) async { final p = await presentChunks(handle); if (p.isEmpty) return BlobStatus.absent; return p.length == handle.chunkCount ? BlobStatus.complete : BlobStatus.partial; }
  @override
  Future<Set<int>> presentChunks(BlobHandle handle) async => {...?_chunks[handle]?.keys};
  @override
  Future<int?> sizeOf(BlobHandle handle) async => _chunks.containsKey(handle) ? handle.totalBytes : null;
  @override
  Stream<BlobEntry> list({required BlobTier tier}) async* { for (final h in _chunks.keys.where((h) => _tiers[h] == tier)) { yield BlobEntry(handle: h, tier: tier, lastAccessAtUtc: _access[h]!, refCount: _refs.values.where((s) => s.contains(h)).length); } }
  @override
  Future<void> reconcileRefs({required String ownerRecordUuid, required Set<BlobHandle> handles}) async { _refs[ownerRecordUuid] = Set.of(handles); }
  @override
  Future<void> evictByExternalId(String externalId) async {}
  @override
  Future<({int freed, int unreclaimable})> evictCache({required int targetFreeBytes}) async { var freed = 0; for (final h in _chunks.keys.toList()) { if (_tiers[h] == BlobTier.cache && freed < targetFreeBytes && !_refs.values.any((s) => s.contains(h))) { freed += h.totalBytes; _chunks.remove(h); _tiers.remove(h); } } return (freed: freed, unreclaimable: 0); }
}
