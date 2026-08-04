/// Drift-backed LocalBlobStore implementation.
///
/// Orchestrates byte backend, metadata repository, and cipher resolver
/// to implement the full LocalBlobStore contract.
library;

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as dr;
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/blob/native.dart';
import 'package:persistence_drift/persistence_drift.dart';

const int blobChunkSize = 16384;

/// Drift + file-system implementation of [LocalBlobStore].
final class DriftLocalBlobStore implements LocalBlobStore {
  DriftLocalBlobStore({
    required this.scopeUid,
    required BlobMetadataRepository metadataRepository,
    required BlobCipherResolver cipherResolver,
    required String rootDir,
    required PersistenceDriftDatabase db,
  })  : _metadata = metadataRepository,
        _cipherResolver = cipherResolver,
        _backend = FileSystemBlobByteBackend(rootDir: rootDir),
        _db = db;

  final BlobMetadataRepository _metadata;
  final BlobCipherResolver _cipherResolver;
  final FileSystemBlobByteBackend _backend;
  final PersistenceDriftDatabase _db;

  @override
  final String scopeUid;

  @override
  Future<BlobHandle> putFile(
    String path, {
    required String mimeType,
    required BlobTier tier,
    CancellationToken? cancel,
    void Function(int sent, int total)? onProgress,
  }) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    cancel?.throwIfCancelled();
    return _putBytes(bytes, mimeType: mimeType, tier: tier, cancel: cancel);
  }

  @override
  Future<BlobHandle> put(
    Stream<List<int>> bytes, {
    required String mimeType,
    required BlobTier tier,
    required int expectedBytes,
    CancellationToken? cancel,
  }) async {
    final data = <int>[];
    await for (final part in bytes) {
      cancel?.throwIfCancelled();
      data.addAll(part);
    }
    return _putBytes(data, mimeType: mimeType, tier: tier, cancel: cancel);
  }

  Future<BlobHandle> _putBytes(
    List<int> plaintext, {
    required String mimeType,
    required BlobTier tier,
    CancellationToken? cancel,
    void Function(int sent, int total)? onProgress,
  }) async {
    final plaintextSha256 = sha256.convert(plaintext).toString();
    final cipher = await _cipherResolver.resolve(
      scopeUid: scopeUid,
      v: _tierToVisibility(tier),
    );

    // Chunk and encrypt
    final chunkCount = (plaintext.length + blobChunkSize - 1) ~/ blobChunkSize;
    final cipherManifestId = (cipher is IdentityBlobCipher)
        ? plaintextSha256
        : _randomUuid();

    final handle = BlobHandle(
      plaintextSha256: plaintextSha256,
      cipherManifestId: cipherManifestId,
      cipherId: cipher.id,
      keyVersion: cipher.currentKeyVersion,
      totalBytes: plaintext.length,
      chunkCount: chunkCount,
      mimeType: mimeType,
    );

    // Write chunks
    for (var i = 0; i < chunkCount; i++) {
      cancel?.throwIfCancelled();
      final start = i * blobChunkSize;
      final end = (start + blobChunkSize > plaintext.length)
          ? plaintext.length
          : start + blobChunkSize;
      final chunk = plaintext.sublist(start, end);
      final cipherChunk = await cipher.encryptChunk(chunk, chunkIndex: i);
      final chunkSha256 = sha256.convert(cipherChunk).toString();

      await _backend.writeChunk(
        '$scopeUid/$cipherManifestId',
        i,
        cipherChunk,
      );
      await _metadata.upsertChunk(
        cipherManifestId: cipherManifestId,
        chunkIndex: i,
        cipherBytesLen: cipherChunk.length,
        chunkSha256: chunkSha256,
      );
      onProgress?.call(i + 1, chunkCount);
    }

    // Insert blob meta (staged by default)
    await _metadata.stageIncomingManifest(
      entityType: 'xiang_reading',
      peerManifest: handle,
      peerTier: tier,
      peerVisibility: _tierToVisibility(tier),
    );

    return handle;
  }

  @override
  Future<void> putChunk(BlobHandle handle, int index, List<int> cipherBytes) async {
    final chunkSha256 = sha256.convert(cipherBytes).toString();
    await _backend.writeChunk(
      '$scopeUid/${handle.cipherManifestId}',
      index,
      cipherBytes,
    );
    await _metadata.upsertChunk(
      cipherManifestId: handle.cipherManifestId,
      chunkIndex: index,
      cipherBytesLen: cipherBytes.length,
      chunkSha256: chunkSha256,
    );
  }

  @override
  Future<List<int>> readCipherChunk(BlobHandle handle, int index) async {
    return _backend.readChunk(
      '$scopeUid/${handle.cipherManifestId}',
      index,
    );
  }

  @override
  Future<BlobReadResult> openRead(BlobHandle handle, {CancellationToken? cancel}) async {
    final meta = await _metadata.getMeta(handle.cipherManifestId);
    if (meta == null) return const BlobReadResult.absent();

    // Staged blobs are not visible to openRead
    if (meta.status == 0) {
      // staged — not visible to consumers
      return const BlobReadResult.absent();
    }

    final present = await _metadata.presentChunks(handle.cipherManifestId);
    if (present.isEmpty) return const BlobReadResult.absent();
    if (present.length != handle.chunkCount) {
      return BlobReadResult.partial(present);
    }

    // Verify all chunks
    final badChunks = <int>{};
    for (final i in present) {
      cancel?.throwIfCancelled();
      try {
        await _backend.readChunk(
          '$scopeUid/${handle.cipherManifestId}',
          i,
        );
      } catch (_) {
        badChunks.add(i);
      }
    }
    if (badChunks.isNotEmpty) return BlobReadResult.corrupt(badChunks);

    // Read all chunks, decrypt, and stream
    final cipher = await _cipherResolver.resolve(
      scopeUid: scopeUid,
      v: _tierToVisibility(BlobTier.values[meta.tier]),
    );

    final controller = StreamController<List<int>>();
    Future(() async {
      try {
        for (var i = 0; i < handle.chunkCount; i++) {
          cancel?.throwIfCancelled();
          final cipherBytes = await _backend.readChunk(
            '$scopeUid/${handle.cipherManifestId}',
            i,
          );
          final plain = await cipher.decryptChunk(
            cipherBytes,
            chunkIndex: i,
            keyVersion: handle.keyVersion,
          );
          controller.add(plain);
        }
        await controller.close();
      } catch (e) {
        controller.addError(e);
      }
    });
    return BlobReadResult.ok(controller.stream);
  }

  @override
  Future<BlobStatus> statusOf(BlobHandle handle) async {
    final meta = await _metadata.getMeta(handle.cipherManifestId);
    if (meta == null) return BlobStatus.absent;
    // Staged blobs appear as absent to consumers
    if (meta.status == 0) return BlobStatus.absent;

    final present = await _metadata.presentChunks(handle.cipherManifestId);
    if (present.length == handle.chunkCount) return BlobStatus.complete;
    if (present.isEmpty) return BlobStatus.absent;
    return BlobStatus.partial;
  }

  @override
  Future<Set<int>> presentChunks(BlobHandle handle) async {
    return _metadata.presentChunks(handle.cipherManifestId);
  }

  @override
  Future<int?> sizeOf(BlobHandle handle) async {
    final meta = await _metadata.getMeta(handle.cipherManifestId);
    if (meta == null) return null;
    // Staged blobs are not visible to consumers
    if (meta.status == 0) return null;
    return handle.totalBytes;
  }

  @override
  Stream<BlobEntry> list({required BlobTier tier}) async* {
    final metas = await _metadata.listByTier(tier);
    for (final meta in metas) {
      // Don't expose staged blobs
      if (meta.status == 0) continue;
      yield BlobEntry(
        handle: BlobHandle(
          plaintextSha256: meta.plaintextSha256,
          cipherManifestId: meta.cipherManifestId,
          cipherId: meta.cipherId,
          keyVersion: meta.keyVersion,
          totalBytes: meta.totalBytes,
          chunkCount: meta.chunkCount,
          mimeType: meta.mimeType,
        ),
        tier: tier,
        lastAccessAtUtc: meta.lastAccessAtUtc,
        refCount: 0, // Placeholder
      );
    }
  }

  @override
  Future<void> reconcileRefs({
    required String ownerRecordUuid,
    required Set<BlobHandle> handles,
  }) async {
    // 1. Delete existing refs for this owner
    await (_db.delete(_db.blobRefs)
          ..where((t) => t.ownerRecordUuid.equals(ownerRecordUuid)))
        .go();

    // 2. Insert new refs
    for (final handle in handles) {
      await _db.into(_db.blobRefs).insert(
            BlobRefsCompanion.insert(
              ownerRecordUuid: ownerRecordUuid,
              cipherManifestId: handle.cipherManifestId,
            ),
          );
    }

    // 3. Promote all referenced blobs from staged(0) to committed(1)
    for (final handle in handles) {
      final existing = await (_db.select(_db.blobMetas)
            ..where((t) => t.cipherManifestId.equals(handle.cipherManifestId)))
          .get();
      for (final meta in existing) {
        if (meta.status == 0) {
          await (_db.update(_db.blobMetas)
                ..where((t) =>
                    t.cipherManifestId.equals(handle.cipherManifestId)))
              .write(BlobMetasCompanion(status: dr.Value(1)));
        }
      }
    }
  }

  @override
  Future<void> evictByExternalId(String externalId) async {
    // TODO: implement in Task 8
  }

  @override
  Future<({int freed, int unreclaimable})> evictCache({
    required int targetFreeBytes,
  }) async {
    // TODO: implement in Task 8
    return (freed: 0, unreclaimable: 0);
  }

  BlobVisibility _tierToVisibility(BlobTier tier) {
    return switch (tier) {
      BlobTier.sourceOfTruth => BlobVisibility.private,
      BlobTier.cache => BlobVisibility.public,
    };
  }

  String _randomUuid() {
    final bytes = List<int>.generate(16, (_) => DateTime.now().microsecondsSinceEpoch & 0xFF);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}