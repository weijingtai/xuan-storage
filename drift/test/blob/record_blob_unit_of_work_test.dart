/// Tests for RecordBlobUnitOfWork.
///
/// Verifies:
/// - save record + blob refs atomically
/// - soft delete + release atomic
/// - injected failure rolls all back
/// - fake follows same observable contract
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/drift_record_blob_unit_of_work.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/blob/in_memory_record_blob_unit_of_work.dart'
    as support;
import 'package:repository_interface_record/repository_interface_record.dart';

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
    late DriftOutboxStore outboxStore;

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
        adapterRegistry: RecordAdapterRegistry([MeiHuaRecordCodec()]),
        outboxStore: outboxStore = DriftOutboxStore(dao: OutboxRecordsDao(db)),
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

      final refRows = await (db.select(
        db.blobRefs,
      )..where((t) => t.ownerRecordUuid.equals('rec-1'))).get();
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
      final refRows = await (db.select(
        db.blobRefs,
      )..where((t) => t.ownerRecordUuid.equals('rec-2'))).get();
      expect(refRows, isEmpty, reason: '软删后 blob ref 应释放');
    });

    test('saveWithBlobs populates search index from codec', () async {
      // RED：当前 saveWithBlobs 不提取搜索标签到 t_record_search_index。
      // findByIndex 应返回空列表（RED 失败）。
      final handle = _makeHandle('manifest-idx');
      await uow.saveWithBlobs(
        record: _makeRecord('rec-idx'),
        referencedBlobs: {handle},
      );

      final results = await recordDs.findByIndex(
        module: 'meihua',
        indexKey: 'divination_uuid',
        indexValue: 'null',
        limit: 10,
      );
      // RED：当前未填充搜索索引，期望 0 条结果。
      expect(
        results,
        isNotEmpty,
        reason:
            'RED：saveWithBlobs 未提取搜索标签到 t_record_search_index；修复后 findByIndex 应返回 rec-idx',
      );
    });

    test(
      'direct save joins the caller transaction and rolls back with it',
      () async {
        final handle = _makeHandle('manifest-direct');
        await expectLater(
          db.transaction(() async {
            await uow.saveWithBlobsDirect(
              record: _makeRecord('rec-direct'),
              referencedBlobs: {handle},
            );
            throw StateError('caller transaction failed');
          }),
          throwsStateError,
        );

        expect(await recordDs.getRecord('rec-direct'), isNull);
        expect(
          await outboxStore.peekBatch(
            scopeUid: 'scope-a',
            peerId: const PeerId('cloud'),
            channel: Channel.cloud,
            limit: 10,
          ),
          isEmpty,
        );
      },
    );

    test(
      'record data source exposes a non-transactional save body for UoW composition',
      () async {
        final record = _makeRecord('rec-direct-body');
        await db.transaction(() async {
          await recordDs.saveRecordDirect(record, const <SearchTag>[]);
        });
        expect(await recordDs.getRecord('rec-direct-body'), isNotNull);
      },
    );
  });

  group('InMemoryRecordBlobUnitOfWork', () {
    test('save, delete, and restore follow same contract', () async {
      final uow = support.InMemoryRecordBlobUnitOfWork();
      final handle = _makeHandle('manifest-1');

      await uow.saveWithBlobs(
        record: _makeRecord('rec-1'),
        referencedBlobs: {handle},
      );

      expect(uow.records, hasLength(1));
      expect(uow.records['rec-1']!.deletedAt, isNull);
      expect(uow.refs, hasLength(1));
      expect(uow.refs['rec-1'], contains(handle));

      await uow.deleteWithBlobs('rec-1');
      expect(uow.records['rec-1']!.deletedAt, isNotNull);
      expect(uow.refs['rec-1'], isNull);

      final restored = await uow.restoreWithBlobs(
        record: _makeRecord('rec-1').copyWith(deletedAt: null),
        referencedBlobs: {handle},
      );
      expect(restored, isTrue);
      expect(uow.records['rec-1']!.deletedAt, isNull);
      expect(uow.refs['rec-1'], contains(handle));
    });
  });

  group('rollback', () {
    test('injected failure after save rolls back record and refs', () async {
      StoragePolicyRegistry.clearForTesting();
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
      );

      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(() {
        StoragePolicyRegistry.clearForTesting();
        db.close();
      });

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

      // 注入一个失败：保存记录后抛异常
      var injected = false;
      final uow = DriftRecordBlobUnitOfWork.testWithoutOutbox(
        db: db,
        scopeUid: 'scope-a',
        blobStore: blobStore,
        injectFailureAfterSave: () async {
          injected = true;
          throw Exception('Injected failure after save');
        },
      );

      final handle = _makeHandle('manifest-rollback');
      await expectLater(
        uow.saveWithBlobs(
          record: _makeRecord('rec-rollback'),
          referencedBlobs: {handle},
        ),
        throwsA(isA<Exception>()),
        reason: '注入失败后 saveWithBlobs 应抛异常',
      );

      expect(injected, isTrue, reason: '注入点必须被触发');

      // 验证记录被回滚
      final recordDs = DriftRecordDataSource(db, scopeUid: 'scope-a');
      final saved = await recordDs.getRecord('rec-rollback');
      expect(saved, isNull, reason: '事务回滚后记录应不存在');

      // 验证 blob ref 被回滚
      final refRows = await (db.select(
        db.blobRefs,
      )..where((t) => t.ownerRecordUuid.equals('rec-rollback'))).get();
      expect(refRows, isEmpty, reason: '事务回滚后 blob ref 应不存在');
    });
  });
}
