/// Tier-safe garbage collector for blob storage.
///
/// Manages lifecycle transitions:
/// - staged → committed (via reconcileRefs)
/// - committed → orphaned (via reconcileRefs zeroing refs for sourceOfTruth)
/// - committed → deleted (for cache tier when refs reach zero)
/// - orphaned file cleanup
library;

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/native.dart';
import 'package:persistence_drift/persistence_drift.dart';

/// Blob garbage collector.
///
/// Only collects:
/// - Staged blobs past TTL (24h)
/// - Cache tier blobs with zero refs
/// - Orphaned temp files
///
/// sourceOfTruth blobs with zero refs are orphaned but NOT deleted.
final class DriftBlobGarbageCollector {
  DriftBlobGarbageCollector({
    required PersistenceDriftDatabase db,
    required String scopeUid,
    required String rootDir,
    required DateTime Function() now,
  })  : _db = db,
        _scopeUid = scopeUid,
        _rootDir = rootDir,
        _now = now,
        _backend = FileSystemBlobByteBackend(rootDir: rootDir),
        _metadata = BlobMetadataRepository(db: db, scopeUid: scopeUid);

  final PersistenceDriftDatabase _db;
  final String _scopeUid;
  final String _rootDir;
  final DateTime Function() _now;
  final FileSystemBlobByteBackend _backend;
  final BlobMetadataRepository _metadata;

  /// Run a full collection cycle.
  Future<({int stagedExpired, int cacheDeleted, int orphansRemoved, int sourceOfTruthOrphaned})> collect() async {
    var stagedExpired = 0;
    var cacheDeleted = 0;
    var orphansRemoved = 0;
    var sourceOfTruthOrphaned = 0;

    // 1. Collect expired staged blobs (past 24h TTL)
    final cutoff = _now().subtract(const Duration(hours: 24));
    final stagedRows = await (_db.select(_db.blobMetas)
          ..where((t) => t.status.equals(0)))
        .get();

    for (final row in stagedRows) {
      if (row.stagedAtUtc.isBefore(cutoff)) {
        await _backend.deleteManifest('$_scopeUid/${row.cipherManifestId}');
        await _metadata.deleteMeta(row.cipherManifestId);
        stagedExpired++;
      }
    }

    // 2. Handle tier-specific lifecycle
    final allMetas = await (_db.select(_db.blobMetas)
          ..where((t) => t.scopeUid.equals(_scopeUid)))
        .get();

    for (final meta in allMetas) {
      if (meta.status == 0) continue; // skip staged

      final refCountResult = await _db.customSelect(
        'SELECT COUNT(*) AS cnt FROM t_blob_ref '
        'WHERE cipher_manifest_id = ?',
        variables: [Variable.withString(meta.cipherManifestId)],
      ).get();
      final refCount = refCountResult.single.read<int>('cnt');

      if (refCount > 0) continue;

      if (meta.tier == BlobTier.sourceOfTruth.index) {
        // sourceOfTruth: orphaned but NOT deleted
        if (meta.status != 2) {
          await (_db.update(_db.blobMetas)
                ..where((t) =>
                    t.cipherManifestId.equals(meta.cipherManifestId)))
              .write(BlobMetasCompanion(status: const Value(2)));
          sourceOfTruthOrphaned++;
        }
      } else if (meta.tier == BlobTier.cache.index) {
        // cache: actually delete
        await _backend.deleteManifest('$_scopeUid/${meta.cipherManifestId}');
        await _metadata.deleteMeta(meta.cipherManifestId);
        cacheDeleted++;
      }
    }

    // 3. Remove orphaned temp files
    final orphans = await _backend.orphanChunkPaths(_rootDir);
    for (final path in orphans) {
      try {
        await _backend.deleteManifest(path);
        orphansRemoved++;
      } catch (_) {}
    }

    return (
      stagedExpired: stagedExpired,
      cacheDeleted: cacheDeleted,
      orphansRemoved: orphansRemoved,
      sourceOfTruthOrphaned: sourceOfTruthOrphaned,
    );
  }
}