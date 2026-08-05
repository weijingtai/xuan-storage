/// Tests for BlobMetadataRepository.
///
/// Verifies:
/// - Scope isolation
/// - Registry-derived manifest staging
/// - Unregistered/non-blob policy rejection
/// - Forged private→resource/cache declaration rejection with zero side effects
/// - Chunk upsert and present set queries
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  late BlobMetadataRepository repo;

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    repo = BlobMetadataRepository(db: db, scopeUid: 'scope-a');

    // Register test policies
    StoragePolicyRegistry.register(
      'xiang_reading',
      StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
    );
    StoragePolicyRegistry.register(
      'playground_post',
      StoragePolicy.shared(carriers: {Carrier.row, Carrier.blob}),
    );
    StoragePolicyRegistry.register(
      'remote_control',
      StoragePolicy.control(),
    );
  });

  tearDown(() {
    StoragePolicyRegistry.clearForTesting();
    db.close();
  });

  group('scope isolation', () {
    test('meta queries are constrained by scopeUid', () async {
      await repo.stageIncomingManifest(
        entityType: 'xiang_reading',
        peerManifest: _sampleHandle('m1'),
        peerTier: BlobTier.sourceOfTruth,
        peerVisibility: BlobVisibility.private,
      );

      final repoB = BlobMetadataRepository(db: db, scopeUid: 'scope-b');
      final meta = await repoB.getMeta('m1');
      expect(meta, isNull, reason: '不同 scope 不应看到对方 blob');
    });
  });

  group('incoming staging', () {
    test('stages manifest from registered policy', () async {
      await repo.stageIncomingManifest(
        entityType: 'xiang_reading',
        peerManifest: _sampleHandle('m1'),
        peerTier: BlobTier.sourceOfTruth,
        peerVisibility: BlobVisibility.private,
      );

      final meta = await repo.getMeta('m1');
      expect(meta, isNotNull);
      expect(meta!.cipherManifestId, 'm1');
      expect(meta.scopeUid, 'scope-a');
    });

    test('rejects unregistered entityType', () async {
      await expectLater(
        repo.stageIncomingManifest(
          entityType: 'unregistered_type',
          peerManifest: _sampleHandle('m1'),
          peerTier: BlobTier.sourceOfTruth,
          peerVisibility: BlobVisibility.private,
        ),
        throwsArgumentError,
      );
    });

    test('rejects entityType without blob carrier', () async {
      // control policy has Carrier.row only (no Carrier.blob)
      await expectLater(
        repo.stageIncomingManifest(
          entityType: 'remote_control',
          peerManifest: _sampleHandle('m1'),
          peerTier: BlobTier.cache,
          peerVisibility: BlobVisibility.public,
        ),
        throwsArgumentError,
      );
    });

    test('rejects forged private→resource declaration', () async {
      // local policy is private (xiang_reading), peer declares resource/cache
      await expectLater(
        repo.stageIncomingManifest(
          entityType: 'xiang_reading',
          peerManifest: _sampleHandle('m1'),
          peerTier: BlobTier.cache,
          peerVisibility: BlobVisibility.public,
        ),
        throwsArgumentError,
      );

      // Verify zero side effects
      final meta = await repo.getMeta('m1');
      expect(meta, isNull, reason: '伪造声明不应留下任何数据库记录');
    });

    test('rejects forged private→cache declaration', () async {
      await expectLater(
        repo.stageIncomingManifest(
          entityType: 'xiang_reading',
          peerManifest: _sampleHandle('m2'),
          peerTier: BlobTier.cache,
          peerVisibility: BlobVisibility.public,
        ),
        throwsArgumentError,
      );

      final meta = await repo.getMeta('m2');
      expect(meta, isNull, reason: '伪造声明不应留下任何数据库记录');
    });
  });

  group('chunk operations', () {
    test('upsert and query present chunks', () async {
      await repo.stageIncomingManifest(
        entityType: 'xiang_reading',
        peerManifest: _sampleHandle('m1'),
        peerTier: BlobTier.sourceOfTruth,
        peerVisibility: BlobVisibility.private,
      );

      await repo.upsertChunk(
        cipherManifestId: 'm1',
        chunkIndex: 0,
        cipherBytesLen: 100,
        chunkSha256: 'a' * 64,
      );
      await repo.upsertChunk(
        cipherManifestId: 'm1',
        chunkIndex: 1,
        cipherBytesLen: 200,
        chunkSha256: 'b' * 64,
      );

      final present = await repo.presentChunks('m1');
      expect(present, {0, 1});
    });
  });
}

BlobHandle _sampleHandle(String manifestId) {
  return BlobHandle(
    plaintextSha256: 'a' * 64,
    cipherManifestId: manifestId,
    cipherId: 'identity',
    keyVersion: 1,
    totalBytes: 100,
    chunkCount: 2,
    mimeType: 'x/test',
  );
}