/// Tests for RecordBlobUnitOfWork.
///
/// Verifies:
/// - save record + blob refs atomically
/// - soft delete + release atomic
/// - fake follows same observable contract
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/drift_record_blob_unit_of_work.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/record/drift_record_data_source.dart';
import 'package:persistence_drift/blob/in_memory_record_blob_unit_of_work.dart'
    as support;
import 'package:repository_interface_record/repository_interface_record.dart'
    hide isNotNull;

RecordMeta _makeRecord(String uuid) {
  return RecordMeta(
    uuid: uuid,
    scopeUid: 'scope-a',
    module: 'meihua',
    category: 'divination',
    divinationType: 'meihuayishu',
    createdAt: DateTime.now(),
  );
}

BlobHandle _makeHandle(String manifestId) {
  return BlobHandle(
    plaintextSha256: manifestId * 64,
    cipherManifestId: manifestId,
    cipherId: 'identity',
    keyVersion: 1,
    totalBytes: 100,
    chunkCount: 1,
    mimeType: 'x/test',
  );
}

void main() {
  group('DriftRecordBlobUnitOfWork', () {
    late PersistenceDriftDatabase db;
    late DriftRecordBlobUnitOfWork uow;
    late DriftRecordDataSource recordDs;

    setUp(() {
      StoragePolicyRegistry.clearForTesting();
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
      );

      db = PersistenceDriftDatabase(NativeDatabase.memory());

      final metaRepo = BlobMetadataRepository(db: db, scopeUid: 'scope-a');
      final cipherResolver = BlobCipherRegistry();
      cipherResolver.register('scope-a', const IdentityBlobCipher());

      final blobStore = DriftLocalBlobStore(
        scopeUid: 'scope-a',
        metadataRepository: metaRepo,
        cipherResolver: cipherResolver,
        rootDir: '/tmp',
        db: db,
      );

      uow = DriftRecordBlobUnitOfWork(
        db: db,
        scopeUid: 'scope-a',
        blobStore: blobStore,
      );
      recordDs = DriftRecordDataSource(db, scopeUid: 'scope-a');
    });

    tearDown(() {
      StoragePolicyRegistry.clearForTesting();
      db.close();
    });

    test('save record + blob refs atomically', () async {
      final handle = _makeHandle('manifest-1');
      await uow.saveWithBlobs(
        record: _makeRecord('rec-1'),
        referencedBlobs: {handle},
      );

      final saved = await recordDs.getRecord('rec-1');
      expect(saved, isNotNull);
      expect(saved!.uuid, 'rec-1');

      final refRows = await (db.select(db.blobRefs)
            ..where((t) => t.ownerRecordUuid.equals('rec-1')))
          .get();
      expect(refRows, hasLength(1));
      expect(refRows.single.cipherManifestId, 'manifest-1');
    });

    test('soft delete + release atomic', () async {
      final handle = _makeHandle('manifest-2');
      await uow.saveWithBlobs(
        record: _makeRecord('rec-2'),
        referencedBlobs: {handle},
      );

      await uow.deleteWithBlobs('rec-2');

      // Record should be soft-deleted (deletedAt set)
      final saved = await recordDs.getRecord('rec-2');
      expect(saved, isNotNull);
      expect(saved!.deletedAt, isNotNull, reason: '软删后 deletedAt 应被设置');

      // Blob refs should be released
      final refRows = await (db.select(db.blobRefs)
            ..where((t) => t.ownerRecordUuid.equals('rec-2')))
          .get();
      expect(refRows, isEmpty, reason: '软删后 blob ref 应释放');
    });
  });

  group('InMemoryRecordBlobUnitOfWork', () {
    test('save and delete follow same contract', () async {
      final uow = support.InMemoryRecordBlobUnitOfWork();
      final handle = _makeHandle('manifest-1');

      await uow.saveWithBlobs(
        record: _makeRecord('rec-1'),
        referencedBlobs: {handle},
      );

      expect(uow.records, hasLength(1));
      expect(uow.refs, hasLength(1));
      expect(uow.refs['rec-1'], contains(handle));

      await uow.deleteWithBlobs('rec-1');
      expect(uow.records, isEmpty);
      expect(uow.refs, isEmpty);
    });
  });
}