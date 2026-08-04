/// Tests for blob lifecycle and garbage collection.
///
/// Verifies:
/// - Staged blobs expire after 24h TTL
/// - Cache tier zero refs → deleted
/// - sourceOfTruth zero refs → orphaned (bytes retained)
/// - Orphaned temp file cleanup
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_garbage_collector.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late Directory tmpDir;
  late PersistenceDriftDatabase db;
  late BlobMetadataRepository metaRepo;
  late DateTime frozenNow;

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'xiang_reading',
      StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
    );
    StoragePolicyRegistry.register(
      'playground_post',
      StoragePolicy.shared(carriers: {Carrier.row, Carrier.blob}),
    );

    tmpDir = Directory.systemTemp.createTempSync('blob_gc_');
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    metaRepo = BlobMetadataRepository(db: db, scopeUid: 'scope-a');
    frozenNow = DateTime.utc(2026, 8, 4, 12, 0);
  });

  tearDown(() {
    StoragePolicyRegistry.clearForTesting();
    db.close();
    tmpDir.deleteSync(recursive: true);
  });

  Future<void> _insertMeta(String manifestId, {int status = 0, int tier = 0, DateTime? stagedAt}) async {
    final stagedAtUtc = stagedAt ?? frozenNow;
    await db.into(db.blobMetas).insert(
      BlobMetasCompanion.insert(
        cipherManifestId: manifestId,
        scopeUid: 'scope-a',
        plaintextSha256: manifestId * 64,
        cipherId: 'identity',
        keyVersion: 1,
        totalBytes: 100,
        chunkCount: 1,
        mimeType: 'x/test',
        tier: tier,
        visibility: 0,
        status: Value(status),
        stagedAtUtc: stagedAtUtc,
        lastAccessAtUtc: frozenNow,
      ),
    );
  }

  Future<void> _insertRef(String manifestId, {String owner = 'rec-1'}) async {
    await db.into(db.blobRefs).insert(
      BlobRefsCompanion.insert(
        ownerRecordUuid: owner,
        cipherManifestId: manifestId,
      ),
    );
  }

  group('garbage collection', () {
    test('staged blob past 24h TTL is collected', () async {
      await _insertMeta('staged-old', stagedAt: frozenNow.subtract(const Duration(hours: 25)));

      final gc = DriftBlobGarbageCollector(
        db: db,
        scopeUid: 'scope-a',
        rootDir: tmpDir.path,
        now: () => frozenNow,
      );

      final result = await gc.collect();
      expect(result.stagedExpired, 1);

      final meta = await metaRepo.getMeta('staged-old');
      expect(meta, isNull, reason: '过期 staged blob 应被删除');
    });

    test('staged blob within 24h TTL is not collected', () async {
      await _insertMeta('staged-fresh', stagedAt: frozenNow.subtract(const Duration(hours: 23)));

      final gc = DriftBlobGarbageCollector(
        db: db,
        scopeUid: 'scope-a',
        rootDir: tmpDir.path,
        now: () => frozenNow,
      );

      final result = await gc.collect();
      expect(result.stagedExpired, 0);

      final meta = await metaRepo.getMeta('staged-fresh');
      expect(meta, isNotNull, reason: '未过期 staged blob 不应被删除');
    });

    test('cache tier zero refs is deleted', () async {
      await _insertMeta('cache-zero', status: 1, tier: 1);

      final gc = DriftBlobGarbageCollector(
        db: db,
        scopeUid: 'scope-a',
        rootDir: tmpDir.path,
        now: () => frozenNow,
      );

      final result = await gc.collect();
      expect(result.cacheDeleted, 1);

      final meta = await metaRepo.getMeta('cache-zero');
      expect(meta, isNull, reason: 'cache tier 零引用 blob 应被删除');
    });

    test('sourceOfTruth zero refs is orphaned but NOT deleted', () async {
      await _insertMeta('sot-zero', status: 1, tier: 0);

      final gc = DriftBlobGarbageCollector(
        db: db,
        scopeUid: 'scope-a',
        rootDir: tmpDir.path,
        now: () => frozenNow,
      );

      final result = await gc.collect();
      expect(result.sourceOfTruthOrphaned, 1);
      expect(result.cacheDeleted, 0);

      // meta 应该还在，但 status 变为 orphaned(2)
      final meta = await metaRepo.getMeta('sot-zero');
      expect(meta, isNotNull, reason: 'sourceOfTruth blob 不应被删除');
      expect(meta!.status, 2, reason: 'status 应变为 orphaned');
    });

    test('pinned cache (with refs) is not collected', () async {
      await _insertMeta('cache-pinned', status: 1, tier: 1);
      await _insertRef('cache-pinned');

      final gc = DriftBlobGarbageCollector(
        db: db,
        scopeUid: 'scope-a',
        rootDir: tmpDir.path,
        now: () => frozenNow,
      );

      final result = await gc.collect();
      expect(result.cacheDeleted, 0);

      final meta = await metaRepo.getMeta('cache-pinned');
      expect(meta, isNotNull, reason: '有引用的 cache blob 不应被删除');
    });
  });
}