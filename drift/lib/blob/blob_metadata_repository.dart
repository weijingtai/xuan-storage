/// Transaction-aware blob metadata repository.
///
/// Handles CRUD for blob metadata (metas, chunks, refs) with scope isolation
/// and StoragePolicyRegistry-derived staging security.
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:drift/drift.dart';

/// Repository for blob metadata operations.
///
/// All queries are constrained by [scopeUid] to prevent cross-account data leaks.
/// [stageIncomingManifest] derives visibility/tier/encryption from local
/// [StoragePolicyRegistry], never from peer declarations.
final class BlobMetadataRepository {
  BlobMetadataRepository({
    required PersistenceDriftDatabase db,
    required this.scopeUid,
  }) : _db = db;

  final PersistenceDriftDatabase _db;
  final String scopeUid;

  /// Stage an incoming manifest derived from local policy.
  Future<void> stageIncomingManifest({
    required String entityType,
    required BlobHandle peerManifest,
    required BlobTier peerTier,
    required BlobVisibility peerVisibility,
  }) async {
    final policy = StoragePolicyRegistry.lookup(entityType);
    if (policy == null) {
      throw ArgumentError(
        'StoragePolicy not registered for entityType: $entityType',
      );
    }
    if (!policy.carriers.contains(Carrier.blob)) {
      throw ArgumentError(
        'StoragePolicy for $entityType does not allow Carrier.blob',
      );
    }

    final localVisibility = _deriveVisibility(policy.visibility);
    final localTier = _deriveTier(policy.visibility);

    if (peerVisibility != localVisibility) {
      throw ArgumentError(
        'Peer declared visibility $peerVisibility but local policy '
        'requires $localVisibility',
      );
    }
    if (peerTier != localTier) {
      throw ArgumentError(
        'Peer declared tier $peerTier but local policy requires $localTier',
      );
    }

    await _db.into(_db.blobMetas).insert(
          BlobMetasCompanion.insert(
            cipherManifestId: peerManifest.cipherManifestId,
            scopeUid: scopeUid,
            plaintextSha256: peerManifest.plaintextSha256,
            cipherId: peerManifest.cipherId,
            keyVersion: peerManifest.keyVersion,
            totalBytes: peerManifest.totalBytes,
            chunkCount: peerManifest.chunkCount,
            mimeType: peerManifest.mimeType,
            tier: localTier.index,
            visibility: localVisibility.index,
            status: const Value(0),
            stagedAtUtc: DateTime.now().toUtc(),
            lastAccessAtUtc: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> upsertChunk({
    required String cipherManifestId,
    required int chunkIndex,
    required int cipherBytesLen,
    required String chunkSha256,
  }) async {
    await _db.into(_db.blobChunks).insert(
          BlobChunksCompanion.insert(
            cipherManifestId: cipherManifestId,
            chunkIndex: chunkIndex,
            cipherBytesLen: cipherBytesLen,
            chunkSha256: chunkSha256,
          ),
        );
  }

  Future<Set<int>> presentChunks(String cipherManifestId) async {
    final rows = await (_db.select(_db.blobChunks)
          ..where((t) => t.cipherManifestId.equals(cipherManifestId)))
        .get();
    return rows.map((r) => r.chunkIndex).toSet();
  }

  Future<BlobMetaRow?> getMeta(String cipherManifestId) async {
    final rows = await (_db.select(_db.blobMetas)
          ..where((t) =>
              t.cipherManifestId.equals(cipherManifestId) &
              t.scopeUid.equals(scopeUid)))
        .get();
    return rows.isEmpty ? null : rows.single;
  }

  Future<List<BlobMetaRow>> listByTier(BlobTier tier) async {
    return (_db.select(_db.blobMetas)
          ..where((t) =>
              t.scopeUid.equals(scopeUid) & t.tier.equals(tier.index)))
        .get();
  }

  Future<void> touchAccess(String cipherManifestId) async {
    await (_db.update(_db.blobMetas)
          ..where((t) => t.cipherManifestId.equals(cipherManifestId)))
        .write(BlobMetasCompanion(
          lastAccessAtUtc: Value(DateTime.now()),
        ));
  }

  Future<void> deleteMeta(String cipherManifestId) async {
    await (_db.delete(_db.blobChunks)
          ..where((t) => t.cipherManifestId.equals(cipherManifestId)))
        .go();
    await (_db.delete(_db.blobMetas)
          ..where((t) => t.cipherManifestId.equals(cipherManifestId)))
        .go();
  }

  BlobVisibility _deriveVisibility(DataVisibility v) {
    return switch (v) {
      DataVisibility.private => BlobVisibility.private,
      DataVisibility.shared => BlobVisibility.public,
      DataVisibility.resource => BlobVisibility.public,
      DataVisibility.control => BlobVisibility.public,
    };
  }

  BlobTier _deriveTier(DataVisibility v) {
    return switch (v) {
      DataVisibility.private => BlobTier.sourceOfTruth,
      DataVisibility.shared => BlobTier.cache,
      DataVisibility.resource => BlobTier.cache,
      DataVisibility.control => BlobTier.cache,
    };
  }
}