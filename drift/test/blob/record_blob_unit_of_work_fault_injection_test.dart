import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/drift_record_blob_unit_of_work.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/blob/in_memory_record_blob_unit_of_work.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

RecordMeta _makeRecord(String uuid, {String? moduleDataJson, DateTime? deletedAt}) {
  return RecordMeta(
    uuid: uuid,
    scopeUid: 'scope-uow-test',
    module: 'meihua',
    category: 'divination',
    divinationType: 'meihuayishu',
    question: 'Fault injection test question',
    moduleDataJson: moduleDataJson,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
    deletedAt: deletedAt,
  );
}

BlobHandle _makeHandle(String manifestId) {
  return BlobHandle(
    plaintextSha256: manifestId * 64,
    cipherManifestId: manifestId,
    cipherId: 'identity',
    keyVersion: 1,
    totalBytes: 128,
    chunkCount: 1,
    mimeType: 'application/octet-stream',
  );
}

class _TestMeihuaAdapter implements ModuleRecordAdapter {
  @override
  String get module => 'meihua';
  @override
  String get category => 'divination';
  @override
  String get divinationType => 'meihuayishu';

  @override
  ({RecordMeta meta, Map<String, dynamic>? moduleData}) toRecord(Object m) =>
      throw UnimplementedError();

  @override
  Object fromRecord(RecordMeta meta, Map<String, dynamic>? d) =>
      throw UnimplementedError();

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? d) {
    final gua = d != null && d['upper_gua'] != null ? d['upper_gua'].toString() : '3';
    return [
      SearchTag('upper_gua', gua),
      SearchTag('divination_type', 'meihuayishu'),
    ];
  }
}

class _FailingOutboxStore implements OutboxStore {
  _FailingOutboxStore(this.inner);
  final OutboxStore inner;
  bool shouldFail = false;

  @override
  Future<void> enqueue(OutboxRecord record) async {
    if (shouldFail) {
      throw StateError('Injected outbox failure during enqueue');
    }
    return inner.enqueue(record);
  }

  @override
  Future<int> backlogCount({required String scopeUid, required PeerId peerId, required Channel channel}) =>
      inner.backlogCount(scopeUid: scopeUid, peerId: peerId, channel: channel);

  @override
  Future<int> deadCount({required String scopeUid, required PeerId peerId, required Channel channel}) =>
      inner.deadCount(scopeUid: scopeUid, peerId: peerId, channel: channel);

  @override
  Future<void> markFailed({
    required String operationId,
    required PeerId peerId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) =>
      inner.markFailed(
        operationId: operationId,
        peerId: peerId,
        attempt: attempt,
        errorCode: errorCode,
        errorMessage: errorMessage,
        atUtc: atUtc,
        isDead: isDead,
      );

  @override
  Future<void> markSuccess({required String operationId, required PeerId peerId, required DateTime atUtc}) =>
      inner.markSuccess(operationId: operationId, peerId: peerId, atUtc: atUtc);

  @override
  Future<int> attemptFor({required String operationId, required PeerId peerId}) =>
      inner.attemptFor(operationId: operationId, peerId: peerId);

  @override
  Future<List<OutboxRecord>> peekBatch({required String scopeUid, required PeerId peerId, required Channel channel, required int limit}) =>
      inner.peekBatch(scopeUid: scopeUid, peerId: peerId, channel: channel, limit: limit);

  @override
  Stream<int> watchBacklogCount({required String scopeUid, required PeerId peerId, required Channel channel}) =>
      inner.watchBacklogCount(scopeUid: scopeUid, peerId: peerId, channel: channel);
}

void main() {
  const scopeUid = 'scope-uow-test';
  const peer = PeerId('cloud-peer');

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'record_meta',
      StoragePolicy.private(carriers: const {Carrier.row, Carrier.blob}),
    );
  });

  tearDown(() {
    StoragePolicyRegistry.clearForTesting();
  });

  group('DriftRecordBlobUnitOfWork - Stage-by-Stage Fault Injection', () {
    late PersistenceDriftDatabase db;
    late BlobMetadataRepository metaRepo;
    late BlobCipherRegistry cipherResolver;
    late DriftLocalBlobStore blobStore;
    late DriftRecordDataSource recordDs;
    late OutboxRecordsDao outboxDao;
    late DriftOutboxStore outboxStore;
    late RecordAdapterRegistry adapterRegistry;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      metaRepo = BlobMetadataRepository(db: db, scopeUid: scopeUid);
      cipherResolver = BlobCipherRegistry();
      cipherResolver.register(scopeUid, const IdentityBlobCipher());
      blobStore = DriftLocalBlobStore(
        scopeUid: scopeUid,
        metadataRepository: metaRepo,
        cipherResolver: cipherResolver,
        rootDir: '/tmp',
        db: db,
      );
      recordDs = DriftRecordDataSource(db, scopeUid: scopeUid);
      outboxDao = OutboxRecordsDao(db);
      outboxStore = DriftOutboxStore(dao: outboxDao);
      adapterRegistry = RecordAdapterRegistry([_TestMeihuaAdapter()]);
    });

    tearDown(() async {
      await db.close();
    });

    group('Save with blobs rollback', () {
      test('fault after record/index save rolls back record, index, refs, outbox', () async {
        final uow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterRecord: () async => throw Exception('Fault after record/index'),
        );

        final handle = _makeHandle('m-save-fail-1');
        final record = _makeRecord('rec-save-f1', moduleDataJson: jsonEncode({'upper_gua': '5'}));

        await expectLater(
          uow.saveWithBlobs(record: record, referencedBlobs: {handle}),
          throwsA(isA<Exception>()),
        );

        // Assert record not saved
        expect(await recordDs.getRecord('rec-save-f1'), isNull);
        // Assert index empty
        final indexHits = await recordDs.findByIndex(
          module: 'meihua',
          indexKey: 'upper_gua',
          indexValue: '5',
        );
        expect(indexHits, isEmpty);
        // Assert refs empty
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-save-f1'))).get();
        expect(refs, isEmpty);
        // Assert outbox empty
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });

      test('fault after blob refs rolls back record, index, refs, outbox', () async {
        final uow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterBlobRefs: () async => throw Exception('Fault after blob refs'),
        );

        final handle = _makeHandle('m-save-fail-2');
        final record = _makeRecord('rec-save-f2', moduleDataJson: jsonEncode({'upper_gua': '6'}));

        await expectLater(
          uow.saveWithBlobs(record: record, referencedBlobs: {handle}),
          throwsA(isA<Exception>()),
        );

        expect(await recordDs.getRecord('rec-save-f2'), isNull);
        final indexHits = await recordDs.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '6');
        expect(indexHits, isEmpty);
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-save-f2'))).get();
        expect(refs, isEmpty);
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });

      test('fault after outbox enqueue rolls back entire transaction', () async {
        final uow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterOutbox: () async => throw Exception('Fault after outbox'),
        );

        final handle = _makeHandle('m-save-fail-3');
        final record = _makeRecord('rec-save-f3', moduleDataJson: jsonEncode({'upper_gua': '7'}));

        await expectLater(
          uow.saveWithBlobs(record: record, referencedBlobs: {handle}),
          throwsA(isA<Exception>()),
        );

        expect(await recordDs.getRecord('rec-save-f3'), isNull);
        final indexHits = await recordDs.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '7');
        expect(indexHits, isEmpty);
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-save-f3'))).get();
        expect(refs, isEmpty);
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });
    });

    group('Soft-delete with blobs rollback', () {
      test('fault after soft-delete rolls back soft-delete, retains index, refs, outbox unchanged', () async {
        final cleanUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
        );

        final handle = _makeHandle('m-del-1');
        final record = _makeRecord('rec-del-f1', moduleDataJson: jsonEncode({'upper_gua': '1'}));
        await cleanUow.saveWithBlobs(record: record, referencedBlobs: {handle});

        // Clear outbox records from save
        await db.delete(db.outboxRecords).go();

        final failingUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterRecord: () async => throw Exception('Fault after soft delete record'),
        );

        await expectLater(
          failingUow.deleteWithBlobs('rec-del-f1'),
          throwsA(isA<Exception>()),
        );

        // Record must NOT be deleted (deletedAt must remain null)
        final rec = await recordDs.getRecord('rec-del-f1');
        expect(rec, isNotNull);
        expect(rec!.deletedAt, isNull);

        // Search index must still exist
        final indexHits = await recordDs.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '1');
        expect(indexHits, hasLength(1));

        // Blob refs must still exist
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-del-f1'))).get();
        expect(refs, hasLength(1));

        // Outbox must be empty (no DELETE enqueued)
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });

      test('fault after blob refs release rolls back soft delete', () async {
        final cleanUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
        );

        final handle = _makeHandle('m-del-2');
        final record = _makeRecord('rec-del-f2', moduleDataJson: jsonEncode({'upper_gua': '2'}));
        await cleanUow.saveWithBlobs(record: record, referencedBlobs: {handle});
        await db.delete(db.outboxRecords).go();

        final failingUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterBlobRefs: () async => throw Exception('Fault after refs release'),
        );

        await expectLater(
          failingUow.deleteWithBlobs('rec-del-f2'),
          throwsA(isA<Exception>()),
        );

        final rec = await recordDs.getRecord('rec-del-f2');
        expect(rec!.deletedAt, isNull);
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-del-f2'))).get();
        expect(refs, hasLength(1));
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });

      test('fault after outbox enqueue rolls back soft delete', () async {
        final cleanUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
        );

        final handle = _makeHandle('m-del-3');
        final record = _makeRecord('rec-del-f3', moduleDataJson: jsonEncode({'upper_gua': '3'}));
        await cleanUow.saveWithBlobs(record: record, referencedBlobs: {handle});
        await db.delete(db.outboxRecords).go();

        final failingUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterOutbox: () async => throw Exception('Fault after outbox enqueue'),
        );

        await expectLater(
          failingUow.deleteWithBlobs('rec-del-f3'),
          throwsA(isA<Exception>()),
        );

        final rec = await recordDs.getRecord('rec-del-f3');
        expect(rec!.deletedAt, isNull);
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-del-f3'))).get();
        expect(refs, hasLength(1));
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });
    });

    group('Restore with blobs rollback', () {
      test('fault after record restore rolls back restore, stays soft-deleted, index empty, refs empty, outbox empty', () async {
        final cleanUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
        );

        final handle = _makeHandle('m-res-1');
        final record = _makeRecord('rec-res-f1', moduleDataJson: jsonEncode({'upper_gua': '4'}));
        await cleanUow.saveWithBlobs(record: record, referencedBlobs: {handle});
        await cleanUow.deleteWithBlobs('rec-res-f1');
        await db.delete(db.outboxRecords).go();

        final failingUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterRecord: () async => throw Exception('Fault after record restore'),
        );

        await expectLater(
          failingUow.restoreWithBlobs(
            record: record.copyWith(deletedAt: null),
            referencedBlobs: {handle},
          ),
          throwsA(isA<Exception>()),
        );

        // Record must still be soft-deleted
        final rec = await recordDs.getRecord('rec-res-f1');
        expect(rec, isNotNull);
        expect(rec!.deletedAt, isNotNull);

        // Search index must be empty
        final indexHits = await recordDs.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '4');
        expect(indexHits, isEmpty);

        // Blob refs must be empty
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-res-f1'))).get();
        expect(refs, isEmpty);

        // Outbox empty
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });

      test('fault after blob refs reconcile rolls back restore', () async {
        final cleanUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
        );

        final handle = _makeHandle('m-res-2');
        final record = _makeRecord('rec-res-f2', moduleDataJson: jsonEncode({'upper_gua': '8'}));
        await cleanUow.saveWithBlobs(record: record, referencedBlobs: {handle});
        await cleanUow.deleteWithBlobs('rec-res-f2');
        await db.delete(db.outboxRecords).go();

        final failingUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterBlobRefs: () async => throw Exception('Fault after blob refs restore'),
        );

        await expectLater(
          failingUow.restoreWithBlobs(
            record: record.copyWith(deletedAt: null),
            referencedBlobs: {handle},
          ),
          throwsA(isA<Exception>()),
        );

        final rec = await recordDs.getRecord('rec-res-f2');
        expect(rec!.deletedAt, isNotNull);
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-res-f2'))).get();
        expect(refs, isEmpty);
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });

      test('fault after outbox enqueue rolls back restore', () async {
        final cleanUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
        );

        final handle = _makeHandle('m-res-3');
        final record = _makeRecord('rec-res-f3', moduleDataJson: jsonEncode({'upper_gua': '9'}));
        await cleanUow.saveWithBlobs(record: record, referencedBlobs: {handle});
        await cleanUow.deleteWithBlobs('rec-res-f3');
        await db.delete(db.outboxRecords).go();

        final failingUow = DriftRecordBlobUnitOfWork(
          db: db,
          scopeUid: scopeUid,
          blobStore: blobStore,
          adapterRegistry: adapterRegistry,
          outboxStore: outboxStore,
          injectFailureAfterOutbox: () async => throw Exception('Fault after outbox restore'),
        );

        await expectLater(
          failingUow.restoreWithBlobs(
            record: record.copyWith(deletedAt: null),
            referencedBlobs: {handle},
          ),
          throwsA(isA<Exception>()),
        );

        final rec = await recordDs.getRecord('rec-res-f3');
        expect(rec!.deletedAt, isNotNull);
        final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-res-f3'))).get();
        expect(refs, isEmpty);
        final outboxRows = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
        expect(outboxRows, isEmpty);
      });
    });
  });

  group('LocalRecordRepository - Transactional Outbox Rollback', () {
    late PersistenceDriftDatabase db;
    late DriftRecordDataSource ds;
    late OutboxRecordsDao dao;
    late _FailingOutboxStore failingOutbox;
    late RecordAdapterRegistry registry;
    late LocalRecordRepository repo;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      ds = DriftRecordDataSource(db, scopeUid: scopeUid);
      dao = OutboxRecordsDao(db);
      failingOutbox = _FailingOutboxStore(DriftOutboxStore(dao: dao));
      registry = RecordAdapterRegistry([_TestMeihuaAdapter()]);
      repo = LocalRecordRepository(ds, registry, outboxStore: failingOutbox);
    });

    tearDown(() async {
      await db.close();
    });

    test('saveRecord rolls back record and search tags when outbox fails', () async {
      failingOutbox.shouldFail = true;
      final record = _makeRecord('rec-repo-save', moduleDataJson: jsonEncode({'upper_gua': '2'}));

      await expectLater(
        repo.saveRecord(record, moduleData: {'upper_gua': '2'}),
        throwsA(isA<StateError>()),
      );

      // Record must not exist
      expect(await ds.getRecord('rec-repo-save'), isNull);
      // Search index must not exist
      final indexHits = await ds.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '2');
      expect(indexHits, isEmpty);
      // Outbox must be empty
      final outboxRows = await failingOutbox.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
      expect(outboxRows, isEmpty);
    });

    test('softDeleteRecord rolls back soft-delete when outbox fails', () async {
      failingOutbox.shouldFail = false;
      final record = _makeRecord('rec-repo-del', moduleDataJson: jsonEncode({'upper_gua': '3'}));
      await repo.saveRecord(record, moduleData: {'upper_gua': '3'});

      // Arm outbox failure
      failingOutbox.shouldFail = true;
      await expectLater(
        repo.softDeleteRecord('rec-repo-del', module: 'meihua'),
        throwsA(isA<StateError>()),
      );

      // Record must remain active (deletedAt is null)
      final saved = await ds.getRecord('rec-repo-del');
      expect(saved, isNotNull);
      expect(saved!.deletedAt, isNull);

      // Search index must remain intact
      final indexHits = await ds.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '3');
      expect(indexHits, hasLength(1));
    });

    test('restoreRecord rolls back restore when outbox fails', () async {
      failingOutbox.shouldFail = false;
      final record = _makeRecord('rec-repo-res', moduleDataJson: jsonEncode({'upper_gua': '4'}));
      await repo.saveRecord(record, moduleData: {'upper_gua': '4'});
      await repo.softDeleteRecord('rec-repo-res', module: 'meihua');

      // Arm outbox failure
      failingOutbox.shouldFail = true;
      await expectLater(
        repo.restoreRecord(record.copyWith(deletedAt: null), moduleData: {'upper_gua': '4'}),
        throwsA(isA<StateError>()),
      );

      // Record must remain soft-deleted
      final saved = await ds.getRecord('rec-repo-res');
      expect(saved, isNotNull);
      expect(saved!.deletedAt, isNotNull);

      // Search index must remain empty
      final indexHits = await ds.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '4');
      expect(indexHits, isEmpty);
    });
  });

  group('InMemoryRecordBlobUnitOfWork - Contract Parity and Rollback', () {
    test('save, soft-delete, and restore follow same observable contract', () async {
      final uow = InMemoryRecordBlobUnitOfWork(
        adapterRegistry: RecordAdapterRegistry([_TestMeihuaAdapter()]),
      );
      final handle = _makeHandle('mem-manifest-1');
      final record = _makeRecord('mem-rec-1', moduleDataJson: jsonEncode({'upper_gua': '6'}));

      // 1. Save
      await uow.saveWithBlobs(record: record, referencedBlobs: {handle});
      expect(uow.records, hasLength(1));
      expect(uow.records['mem-rec-1']!.deletedAt, isNull);
      expect(uow.refs['mem-rec-1'], contains(handle));
      expect(uow.searchTags['mem-rec-1'], hasLength(2));

      // 2. Soft delete
      await uow.deleteWithBlobs('mem-rec-1');
      expect(uow.records['mem-rec-1']!.deletedAt, isNotNull);
      expect(uow.refs['mem-rec-1'], isNull);
      expect(uow.searchTags['mem-rec-1'], isNull);

      // 3. Restore
      final restored = await uow.restoreWithBlobs(
        record: record.copyWith(deletedAt: null),
        referencedBlobs: {handle},
      );
      expect(restored, isTrue);
      expect(uow.records['mem-rec-1']!.deletedAt, isNull);
      expect(uow.refs['mem-rec-1'], contains(handle));
      expect(uow.searchTags['mem-rec-1'], hasLength(2));
    });

    test('fault injection in InMemoryRecordBlobUnitOfWork rolls back all in-memory state', () async {
      final uow = InMemoryRecordBlobUnitOfWork(
        adapterRegistry: RecordAdapterRegistry([_TestMeihuaAdapter()]),
        injectFailureAfterBlobRefs: () async => throw Exception('Mem fault'),
      );
      final handle = _makeHandle('mem-fail');
      final record = _makeRecord('mem-rec-fail');

      await expectLater(
        uow.saveWithBlobs(record: record, referencedBlobs: {handle}),
        throwsA(isA<Exception>()),
      );

      expect(uow.records, isEmpty);
      expect(uow.refs, isEmpty);
      expect(uow.searchTags, isEmpty);
    });
  });
}
