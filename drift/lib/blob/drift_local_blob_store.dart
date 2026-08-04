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

    // Insert blob meta (staged by default) — 本地 put 直接插入，不走 stageIncomingManifest
    await _db.into(_db.blobMetas).insert(
          BlobMetasCompanion.insert(
            cipherManifestId: handle.cipherManifestId,
            scopeUid: scopeUid,
            plaintextSha256: handle.plaintextSha256,
            cipherId: handle.cipherId,
            keyVersion: handle.keyVersion,
            totalBytes: handle.totalBytes,
            chunkCount: handle.chunkCount,
            mimeType: handle.mimeType,
            tier: tier.index,
            visibility: _tierToVisibility(tier).index,
            status: const dr.Value(0),
            stagedAtUtc: DateTime.now().toUtc(),
            lastAccessAtUtc: DateTime.now().toUtc(),
          ),
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

    // Verify all chunks against stored SHA-256
    final badChunks = <int>{};
    for (final i in present) {
      cancel?.throwIfCancelled();
      try {
        final bytes = await _backend.readChunk(
          '$scopeUid/${handle.cipherManifestId}',
          i,
        );
        final actualSha = sha256.convert(bytes).toString();
        // 从元数据中读取预期的 chunkSha256
        final chunkRows = await (_db.select(_db.blobChunks)
              ..where((t) =>
                  t.cipherManifestId.equals(handle.cipherManifestId) &
                  t.chunkIndex.equals(i)))
            .get();
        if (chunkRows.isNotEmpty) {
          if (actualSha != chunkRows.single.chunkSha256) {
            badChunks.add(i);
          }
        }
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
    // 查找所有匹配 externalId 的 blob 元数据，删除文件系统和元数据
    final metas = await (_db.select(_db.blobMetas)
          ..where((t) => t.externalId.equals(externalId)))
        .get();
    for (final meta in metas) {
      await _backend.deleteManifest('$scopeUid/${meta.cipherManifestId}');
      await _metadata.deleteMeta(meta.cipherManifestId);
    }
  }

  @override
  Future<({int freed, int unreclaimable})> evictCache({
    required int targetFreeBytes,
  }) async {
    // 只清理 cache tier 且零引用的 blob
    final cacheMetas = await (_db.select(_db.blobMetas)
          ..where((t) =>
              t.scopeUid.equals(scopeUid) & t.tier.equals(BlobTier.cache.index)))
        .get();

    var freed = 0;
    var unreclaimable = 0;

    // 按最近访问时间升序排序（LRU）
    final sorted = List.of(cacheMetas)
      ..sort((a, b) => a.lastAccessAtUtc.compareTo(b.lastAccessAtUtc));

    for (final meta in sorted) {
      if (freed >= targetFreeBytes) break;

      // 检查引用计数
      final refCountResult = await _db.customSelect(
        'SELECT COUNT(*) AS cnt FROM t_blob_ref '
        'WHERE cipher_manifest_id = ?',
        variables: [dr.Variable.withString(meta.cipherManifestId)],
      ).get();
      final refCount = refCountResult.single.read<int>('cnt');

      if (refCount > 0) {
        unreclaimable += meta.totalBytes;
        continue;
      }

      // 删除文件系统和元数据
      await _backend.deleteManifest('$scopeUid/${meta.cipherManifestId}');
      await _metadata.deleteMeta(meta.cipherManifestId);
      freed += meta.totalBytes;
    }

    return (freed: freed, unreclaimable: unreclaimable);
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