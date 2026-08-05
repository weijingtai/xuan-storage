/// Drift-backed LocalBlobStore implementation.
///
/// Orchestrates byte backend, metadata repository, and cipher resolver
/// to implement the full LocalBlobStore contract.
///
/// 写路径采用有界流式（阶段 1）：逐块 16 KiB 处理，不累积整段明文。
/// 读路径采用惰性校验（阶段 2）：逐块校验 SHA-256，不预先全量哈希。
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as dr;
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
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
    final totalBytes = await file.length();
    return _putStream(
      file.openRead(),
      expectedBytes: totalBytes,
      mimeType: mimeType,
      tier: tier,
      cancel: cancel,
      onProgress: onProgress,
    );
  }

  @override
  Future<BlobHandle> put(
    Stream<List<int>> bytes, {
    required String mimeType,
    required BlobTier tier,
    required int expectedBytes,
    CancellationToken? cancel,
  }) async {
    return _putStream(
      bytes,
      expectedBytes: expectedBytes,
      mimeType: mimeType,
      tier: tier,
      cancel: cancel,
    );
  }

  /// 流式写入核心函数。
  ///
  /// 从输入流逐块累积到恰好 16 KiB 后处理一块，不累积整段明文。
  /// 使用增量哈希（sha256 chunked conversion），收尾取 digest。
  /// cipherManifestId 一律随机 UUID（方案 B），去重由收尾查重承担。
  Future<BlobHandle> _putStream(
    Stream<List<int>> inputStream, {
    required int expectedBytes,
    required String mimeType,
    required BlobTier tier,
    CancellationToken? cancel,
    void Function(int sent, int total)? onProgress,
  }) async {
    final cipher = await _cipherResolver.resolve(
      scopeUid: scopeUid,
      v: _tierToVisibility(tier),
    );

    // 一律随机 UUID（方案 B）
    final cipherManifestId = _randomUuid();

    // 增量哈希
    final digestAccumulator = DigestAccumulator();
    final shaSink = sha256.startChunkedConversion(digestAccumulator);
    // shaSink 是 Sink<List<int>> 包装器，digestAccumulator 独立持有
    var totalBytes = 0;
    var chunkCount = 0;

    // 用 Uint8List 队列替代 List<int> 累积，避免 O(n²) 重拷。
    final pending = <Uint8List>[];
    var pendingOffset = 0;

    // 从 pending 队列中取出恰好 chunkSize 字节。
    Uint8List? takeChunk() {
      final avail = pending.fold(0, (int sum, e) => sum + e.length) - pendingOffset;
      if (avail < blobChunkSize) return null;
      final result = Uint8List(blobChunkSize);
      var written = 0;
      while (written < blobChunkSize) {
        final head = pending.first;
        final available = head.length - pendingOffset;
        final need = blobChunkSize - written;
        final take = need < available ? need : available;
        result.setRange(written, written + take, head, pendingOffset);
        written += take;
        pendingOffset += take;
        if (pendingOffset >= head.length) {
          pending.removeAt(0);
          pendingOffset = 0;
        }
      }
      return result;
    }

    // 计算 pending 队列剩余字节数。
    int pendingLen() =>
        pending.fold(0, (int s, e) => s + e.length) - pendingOffset;

    // 逐块处理
    await for (final part in inputStream) {
      cancel?.throwIfCancelled();
      pending.add(Uint8List.fromList(part is Uint8List ? part : part.toList()));

      // 累积到 >= blobChunkSize 时吐出一块
      while (pendingLen() >= blobChunkSize) {
        final chunkBytes = takeChunk()!;

        // 增量喂入哈希
        shaSink.add(chunkBytes);

        // 加密 → 写盘 → 更新元数据
        final cipherChunk = await cipher.encryptChunk(
          chunkBytes.toList(),
          chunkIndex: chunkCount,
        );
        final chunkSha256 = sha256.convert(cipherChunk).toString();

        await _backend.writeChunk(
          '$scopeUid/$cipherManifestId',
          chunkCount,
          cipherChunk,
        );
        await _metadata.upsertChunk(
          cipherManifestId: cipherManifestId,
          chunkIndex: chunkCount,
          cipherBytesLen: cipherChunk.length,
          chunkSha256: chunkSha256,
        );

        chunkCount++;
        totalBytes += chunkBytes.length;
        onProgress?.call(chunkCount, (expectedBytes + blobChunkSize - 1) ~/ blobChunkSize);
      }
    }

    // 处理最后不足一块的残余
    if (pendingLen() > 0) {
      final remaining = Uint8List(pendingLen());
      var written = 0;
      while (written < remaining.length) {
        final head = pending.first;
        final available = head.length - pendingOffset;
        final need = remaining.length - written;
        final take = need < available ? need : available;
        remaining.setRange(written, written + take, head, pendingOffset);
        written += take;
        pendingOffset += take;
        if (pendingOffset >= head.length) {
          pending.removeAt(0);
          pendingOffset = 0;
        }
      }
      pending.clear();
      pendingOffset = 0;
      shaSink.add(remaining);

      final cipherChunk = await cipher.encryptChunk(
        remaining.toList(),
        chunkIndex: chunkCount,
      );
      final chunkSha256 = sha256.convert(cipherChunk).toString();

      await _backend.writeChunk(
        '$scopeUid/$cipherManifestId',
        chunkCount,
        cipherChunk,
      );
      await _metadata.upsertChunk(
        cipherManifestId: cipherManifestId,
        chunkIndex: chunkCount,
        cipherBytesLen: cipherChunk.length,
        chunkSha256: chunkSha256,
      );

      chunkCount++;
      totalBytes += remaining.length;
      onProgress?.call(chunkCount, chunkCount);
    }

    // 收尾哈希
    shaSink.close();
    final plaintextSha256 = digestAccumulator.hexDigest;

    // 校验 expectedBytes
    if (totalBytes != expectedBytes) {
      // 清理已写文件
      await _backend.deleteManifest('$scopeUid/$cipherManifestId');
      throw ArgumentError(
        'Expected $expectedBytes bytes but received $totalBytes',
      );
    }

    // 收尾去重：如果已有相同 plaintextSha256 的 blob，删除刚写入的
    final existing = await (_db.select(_db.blobMetas)
          ..where((t) =>
              t.plaintextSha256.equals(plaintextSha256) &
              t.scopeUid.equals(scopeUid)))
        .get();
    if (existing.isNotEmpty) {
      // 内容已存在，删除本次写入的 chunk 文件，复用已有
      await _backend.deleteManifest('$scopeUid/$cipherManifestId');
      return BlobHandle(
        plaintextSha256: plaintextSha256,
        cipherManifestId: existing.first.cipherManifestId,
        cipherId: cipher.id,
        keyVersion: cipher.currentKeyVersion,
        totalBytes: totalBytes,
        chunkCount: chunkCount,
        mimeType: mimeType,
      );
    }

    final handle = BlobHandle(
      plaintextSha256: plaintextSha256,
      cipherManifestId: cipherManifestId,
      cipherId: cipher.id,
      keyVersion: cipher.currentKeyVersion,
      totalBytes: totalBytes,
      chunkCount: chunkCount,
      mimeType: mimeType,
    );

    // 插入 blob meta（staged 状态）
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

    // Staged blobs are not visible to consumers
    if (meta.status == 0) {
      return const BlobReadResult.absent();
    }

    final present = await _metadata.presentChunks(handle.cipherManifestId);
    if (present.isEmpty) return const BlobReadResult.absent();
    if (present.length != handle.chunkCount) {
      return BlobReadResult.partial(present);
    }

    // 阶段 2：惰性校验 —— 一次性批量取出所有 chunk 元数据，逐块流式校验
    final chunkMetaRows = await (_db.select(_db.blobChunks)
          ..where((t) => t.cipherManifestId.equals(handle.cipherManifestId))
          ..orderBy([(t) => dr.OrderingTerm.asc(t.chunkIndex)]))
        .get();
    // 构建索引：index → expectedSha256
    final expectedShaMap = <int, String>{};
    for (final row in chunkMetaRows) {
      expectedShaMap[row.chunkIndex] = row.chunkSha256;
    }

    final cipher = await _cipherResolver.resolve(
      scopeUid: scopeUid,
      v: _tierToVisibility(BlobTier.values[meta.tier]),
    );

    final controller = StreamController<List<int>>();
    // 异步流式读取、校验、解密
    Future(() async {
      try {
        for (var i = 0; i < handle.chunkCount; i++) {
          cancel?.throwIfCancelled();
          final cipherBytes = await _backend.readChunk(
            '$scopeUid/${handle.cipherManifestId}',
            i,
          );
          // 校验 SHA-256（惰性逐块）
          final actualSha = sha256.convert(cipherBytes).toString();
          if (actualSha != expectedShaMap[i]) {
            controller.addError(BlobCorruptError());
            await controller.close();
            return;
          }
          final plain = await cipher.decryptChunk(
            cipherBytes,
            chunkIndex: i,
            keyVersion: handle.keyVersion,
          );
          controller.add(plain);
        }
        await controller.close();
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });
    return BlobReadResult.ok(controller.stream);
  }

  @override
  Future<BlobStatus> statusOf(BlobHandle handle) async {
    final meta = await _metadata.getMeta(handle.cipherManifestId);
    if (meta == null) return BlobStatus.absent;
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
    if (meta.status == 0) return null;
    return handle.totalBytes;
  }

  @override
  Stream<BlobEntry> list({required BlobTier tier}) async* {
    final metas = await _metadata.listByTier(tier);
    for (final meta in metas) {
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
        refCount: 0,
      );
    }
  }

  @override
  Future<void> reconcileRefs({
    required String ownerRecordUuid,
    required Set<BlobHandle> handles,
  }) async {
    await (_db.delete(_db.blobRefs)
          ..where((t) => t.ownerRecordUuid.equals(ownerRecordUuid)))
        .go();

    for (final handle in handles) {
      await _db.into(_db.blobRefs).insert(
            BlobRefsCompanion.insert(
              ownerRecordUuid: ownerRecordUuid,
              cipherManifestId: handle.cipherManifestId,
            ),
          );
    }

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
    final cacheMetas = await (_db.select(_db.blobMetas)
          ..where((t) =>
              t.scopeUid.equals(scopeUid) & t.tier.equals(BlobTier.cache.index)))
        .get();

    var freed = 0;
    var unreclaimable = 0;

    final sorted = List.of(cacheMetas)
      ..sort((a, b) => a.lastAccessAtUtc.compareTo(b.lastAccessAtUtc));

    for (final meta in sorted) {
      if (freed >= targetFreeBytes) break;

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

/// 收集增量哈希的最终 digest。
class DigestAccumulator implements Sink<Digest> {
  Digest? _digest;

  @override
  void add(Digest data) {
    _digest = data;
  }

  @override
  void close() {}

  String get hexDigest => _digest!.toString();
}