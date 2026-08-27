import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/drift_record_blob_unit_of_work.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

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
    final gua = d != null && d['upper_gua'] != null ? d['upper_gua'].toString() : '1';
    return [
      SearchTag('upper_gua', gua),
      SearchTag('divination_type', 'meihuayishu'),
    ];
  }
}

void main() {
  const scopeUid = 'scope-restart-test';
  const peer = PeerId('cloud-peer');
  late Directory tempDir;
  late File dbFile;
  late String blobRootDir;

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'record_meta',
      StoragePolicy.private(carriers: const {Carrier.row, Carrier.blob}),
    );
    tempDir = Directory.systemTemp.createTempSync('drift_uow_restart_test_');
    dbFile = File('${tempDir.path}/app.sqlite');
    blobRootDir = '${tempDir.path}/blobs';
    Directory(blobRootDir).createSync(recursive: true);
  });

  tearDown(() {
    StoragePolicyRegistry.clearForTesting();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('file-backed Drift DB restart preserves record, moduleData, searchTags, outbox, refs across soft-delete and restore', () async {
    final adapterRegistry = RecordAdapterRegistry([_TestMeihuaAdapter()]);

    // ── STEP 1: Initial DB open, save record + blob + outbox ──
    late BlobHandle savedHandle;
    {
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      final metaRepo = BlobMetadataRepository(db: db, scopeUid: scopeUid);
      final cipherResolver = BlobCipherRegistry();
      cipherResolver.register(scopeUid, const IdentityBlobCipher());
      final blobStore = DriftLocalBlobStore(
        scopeUid: scopeUid,
        metadataRepository: metaRepo,
        cipherResolver: cipherResolver,
        rootDir: blobRootDir,
        db: db,
      );
      final outboxDao = OutboxRecordsDao(db);
      final outboxStore = DriftOutboxStore(dao: outboxDao);
      final uow = DriftRecordBlobUnitOfWork(
        db: db,
        scopeUid: scopeUid,
        blobStore: blobStore,
        adapterRegistry: adapterRegistry,
        outboxStore: outboxStore,
      );

      // Write raw blob bytes
      final rawBytes = utf8.encode('Source-of-truth blob content that must persist forever');
      savedHandle = await blobStore.put(
        Stream.value(rawBytes),
        mimeType: 'text/plain',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: rawBytes.length,
      );

      final record = RecordMeta(
        uuid: 'rec-restart-1',
        scopeUid: scopeUid,
        module: 'meihua',
        category: 'divination',
        divinationType: 'meihuayishu',
        question: 'Will restarting the database preserve all data?',
        moduleDataJson: jsonEncode({'upper_gua': '7', 'detail': 'restart_step1'}),
        createdAt: DateTime.utc(2026, 1, 1, 12, 0, 0),
        updatedAt: DateTime.utc(2026, 1, 1, 12, 0, 0),
      );

      await uow.saveWithBlobs(record: record, referencedBlobs: {savedHandle});

      await db.close();
    }

    // ── STEP 2: Reopen DB, verify saved state ──
    {
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      final recordDs = DriftRecordDataSource(db, scopeUid: scopeUid);
      final outboxDao = OutboxRecordsDao(db);
      final outboxStore = DriftOutboxStore(dao: outboxDao);

      // 1. Record exists with correct fields
      final rec = await recordDs.getRecord('rec-restart-1');
      expect(rec, isNotNull);
      expect(rec!.uuid, 'rec-restart-1');
      expect(rec.question, 'Will restarting the database preserve all data?');
      expect(rec.moduleDataJson, contains('restart_step1'));
      expect(rec.deletedAt, isNull);

      // 2. Search tags queryable
      final tags = await recordDs.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '7');
      expect(tags, hasLength(1));
      expect(tags.single.uuid, 'rec-restart-1');

      // 3. Blob refs table has reference
      final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-restart-1'))).get();
      expect(refs, hasLength(1));
      expect(refs.single.cipherManifestId, savedHandle.cipherManifestId);

      // 4. Outbox records table has UPSERT
      final outbox = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
      expect(outbox, hasLength(1));
      expect(outbox.single.opType, 'UPSERT');
      expect(outbox.single.entityId, 'rec-restart-1');
      expect(outbox.single.payloadJson, contains('restart_step1'));

      await db.close();
    }

    // ── STEP 3: Reopen DB, soft-delete with blobs ──
    {
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      final metaRepo = BlobMetadataRepository(db: db, scopeUid: scopeUid);
      final cipherResolver = BlobCipherRegistry();
      cipherResolver.register(scopeUid, const IdentityBlobCipher());
      final blobStore = DriftLocalBlobStore(
        scopeUid: scopeUid,
        metadataRepository: metaRepo,
        cipherResolver: cipherResolver,
        rootDir: blobRootDir,
        db: db,
      );
      final outboxDao = OutboxRecordsDao(db);
      final outboxStore = DriftOutboxStore(dao: outboxDao);
      final uow = DriftRecordBlobUnitOfWork(
        db: db,
        scopeUid: scopeUid,
        blobStore: blobStore,
        adapterRegistry: adapterRegistry,
        outboxStore: outboxStore,
      );

      await uow.deleteWithBlobs('rec-restart-1');

      await db.close();
    }

    // ── STEP 4: Reopen DB, verify soft-deleted state ──
    {
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      final recordDs = DriftRecordDataSource(db, scopeUid: scopeUid);
      final outboxDao = OutboxRecordsDao(db);
      final outboxStore = DriftOutboxStore(dao: outboxDao);

      // 1. Record is soft-deleted
      final rec = await recordDs.getRecord('rec-restart-1');
      expect(rec, isNotNull);
      expect(rec!.deletedAt, isNotNull);

      // 2. Search tags are cleared
      final tags = await recordDs.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '7');
      expect(tags, isEmpty);

      // 3. Blob refs are cleared
      final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-restart-1'))).get();
      expect(refs, isEmpty);

      // 4. Outbox records contains DELETE
      final outbox = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
      final deleteOps = outbox.where((o) => o.opType == 'DELETE').toList();
      expect(deleteOps, hasLength(1));
      expect(deleteOps.single.entityId, 'rec-restart-1');

      // 5. Blob bytes on disk are STILL PRESERVED (sourceOfTruth bytes not deleted)
      final metaRepo = BlobMetadataRepository(db: db, scopeUid: scopeUid);
      final cipherResolver = BlobCipherRegistry();
      cipherResolver.register(scopeUid, const IdentityBlobCipher());
      final blobStore = DriftLocalBlobStore(
        scopeUid: scopeUid,
        metadataRepository: metaRepo,
        cipherResolver: cipherResolver,
        rootDir: blobRootDir,
        db: db,
      );
      final readResult = await blobStore.openRead(savedHandle);
      expect(readResult, isA<BlobOk>());
      final readBytes = await (readResult as BlobOk).plaintext.fold<List<int>>([], (p, e) => p..addAll(e));
      expect(utf8.decode(readBytes), 'Source-of-truth blob content that must persist forever');

      await db.close();
    }

    // ── STEP 5: Reopen DB, restore with blobs ──
    {
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      final metaRepo = BlobMetadataRepository(db: db, scopeUid: scopeUid);
      final cipherResolver = BlobCipherRegistry();
      cipherResolver.register(scopeUid, const IdentityBlobCipher());
      final blobStore = DriftLocalBlobStore(
        scopeUid: scopeUid,
        metadataRepository: metaRepo,
        cipherResolver: cipherResolver,
        rootDir: blobRootDir,
        db: db,
      );
      final outboxDao = OutboxRecordsDao(db);
      final outboxStore = DriftOutboxStore(dao: outboxDao);
      final uow = DriftRecordBlobUnitOfWork(
        db: db,
        scopeUid: scopeUid,
        blobStore: blobStore,
        adapterRegistry: adapterRegistry,
        outboxStore: outboxStore,
      );

      final recordToRestore = RecordMeta(
        uuid: 'rec-restart-1',
        scopeUid: scopeUid,
        module: 'meihua',
        category: 'divination',
        divinationType: 'meihuayishu',
        question: 'Will restarting the database preserve all data?',
        moduleDataJson: jsonEncode({'upper_gua': '7', 'detail': 'restart_step1'}),
        createdAt: DateTime.utc(2026, 1, 1, 12, 0, 0),
        updatedAt: DateTime.utc(2026, 1, 2, 12, 0, 0),
        deletedAt: null,
      );

      final restored = await uow.restoreWithBlobs(
        record: recordToRestore,
        referencedBlobs: {savedHandle},
      );
      expect(restored, isTrue);

      await db.close();
    }

    // ── STEP 6: Reopen DB, verify restored state ──
    {
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      final recordDs = DriftRecordDataSource(db, scopeUid: scopeUid);
      final outboxDao = OutboxRecordsDao(db);
      final outboxStore = DriftOutboxStore(dao: outboxDao);

      // 1. Record is restored (deletedAt is null)
      final rec = await recordDs.getRecord('rec-restart-1');
      expect(rec, isNotNull);
      expect(rec!.deletedAt, isNull);

      // 2. Search tags queryable again
      final tags = await recordDs.findByIndex(module: 'meihua', indexKey: 'upper_gua', indexValue: '7');
      expect(tags, hasLength(1));
      expect(tags.single.uuid, 'rec-restart-1');

      // 3. Blob refs restored
      final refs = await (db.select(db.blobRefs)..where((t) => t.ownerRecordUuid.equals('rec-restart-1'))).get();
      expect(refs, hasLength(1));
      expect(refs.single.cipherManifestId, savedHandle.cipherManifestId);

      // 4. Outbox records contains UPSERT for restored record
      final outbox = await outboxStore.peekBatch(scopeUid: scopeUid, peerId: peer, channel: Channel.cloud, limit: 10);
      final upsertOps = outbox.where((o) => o.opType == 'UPSERT').toList();
      expect(upsertOps, isNotEmpty);
      expect(upsertOps.last.entityId, 'rec-restart-1');

      // 5. Blob bytes intact
      final metaRepo = BlobMetadataRepository(db: db, scopeUid: scopeUid);
      final cipherResolver = BlobCipherRegistry();
      cipherResolver.register(scopeUid, const IdentityBlobCipher());
      final blobStore = DriftLocalBlobStore(
        scopeUid: scopeUid,
        metadataRepository: metaRepo,
        cipherResolver: cipherResolver,
        rootDir: blobRootDir,
        db: db,
      );
      final readResult = await blobStore.openRead(savedHandle);
      expect(readResult, isA<BlobOk>());
      final readBytes = await (readResult as BlobOk).plaintext.fold<List<int>>([], (p, e) => p..addAll(e));
      expect(utf8.decode(readBytes), 'Source-of-truth blob content that must persist forever');

      await db.close();
    }
  });
}
