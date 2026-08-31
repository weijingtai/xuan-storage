/// Tests for RecordBlobUnitOfWork.
///
/// Verifies:
/// - save record + blob refs atomically
/// - soft delete + release atomic
/// - injected failure rolls all back
/// - fake follows same observable contract
/// - C1: saveWithBlobs atomically validates every referenced blob inside the
///   transaction (real staged handles); absent/partial/corrupt/undecryptable
///   throw and leave Record + search index + blob ref + outbox empty, both
///   immediately and after closing/reopening the file-backed database.
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
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

/// 向 [blobStore] 写入一条真实 staged blob（生产采集等价物）并返回真实 handle。
Future<BlobHandle> _putRealBlob(
  DriftLocalBlobStore blobStore, {
  List<int> bytes = const [1, 2, 3, 4],
}) {
  return blobStore.put(
    Stream.value(bytes),
    mimeType: 'x/test',
    tier: BlobTier.sourceOfTruth,
    expectedBytes: bytes.length,
  );
}

void main() {
  group('DriftRecordBlobUnitOfWork', () {
    late PersistenceDriftDatabase db;
    late DriftRecordBlobUnitOfWork uow;
    late DriftRecordDataSource recordDs;
    late DriftOutboxStore outboxStore;
    late BlobMetadataRepository metaRepo;
    late DriftLocalBlobStore blobStore;

    setUp(() {
      StoragePolicyRegistry.clearForTesting();
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
      );

      db = PersistenceDriftDatabase(NativeDatabase.memory());

      metaRepo = BlobMetadataRepository(db: db, scopeUid: 'scope-a');
      final cipherResolver = BlobCipherRegistry();
      cipherResolver.register('scope-a', const IdentityBlobCipher());

      blobStore = DriftLocalBlobStore(
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
      // C1：必须使用真实 staged handle（saveWithBlobs 会在事务内校验字节）。
      final handle = await _putRealBlob(blobStore);
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
      expect(refRows.single.cipherManifestId, handle.cipherManifestId);
    });

    test('soft delete + release atomic', () async {
      final handle = await _putRealBlob(blobStore);
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
      final handle = await _putRealBlob(blobStore);
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
        final handle = await _putRealBlob(blobStore);
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
      final handle = BlobHandle(
        plaintextSha256: 'a' * 64,
        cipherManifestId: 'manifest-1',
        cipherId: 'identity',
        keyVersion: 1,
        totalBytes: 100,
        chunkCount: 1,
        mimeType: 'x/test',
      );

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

      final handle = await _putRealBlob(blobStore);
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

  group('C1 — saveWithBlobs 事务内原子校验引用 blob（file-backed + restart）', () {
    const scope = 'scope-c1';
    const peer = PeerId('cloud-peer');

    RecordMeta c1Record(String uuid) => RecordMeta(
          uuid: uuid,
          scopeUid: scope,
          module: 'meihua',
          category: 'divination',
          divinationType: 'meihuayishu',
          createdAt: DateTime.now(),
        );

    late Directory tempDir;
    late File dbFile;
    late String blobRoot;
    late PersistenceDriftDatabase db;
    late BlobMetadataRepository metaRepo;
    late DriftLocalBlobStore blobStore;
    late DriftRecordBlobUnitOfWork uow;
    late DriftRecordDataSource recordDs;
    late DriftOutboxStore outboxStore;
    late RecordAdapterRegistry adapterRegistry;

    void openComposition({bool emptyCipherResolver = false}) {
      db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      metaRepo = BlobMetadataRepository(db: db, scopeUid: scope);
      final resolver = BlobCipherRegistry();
      if (!emptyCipherResolver) {
        resolver.register(scope, const IdentityBlobCipher());
      }
      blobStore = DriftLocalBlobStore(
        scopeUid: scope,
        metadataRepository: metaRepo,
        cipherResolver: resolver,
        rootDir: blobRoot,
        db: db,
      );
      outboxStore = DriftOutboxStore(dao: OutboxRecordsDao(db));
      uow = DriftRecordBlobUnitOfWork(
        db: db,
        scopeUid: scope,
        blobStore: blobStore,
        adapterRegistry: adapterRegistry,
        outboxStore: outboxStore,
      );
      recordDs = DriftRecordDataSource(db, scopeUid: scope);
    }

    setUp(() {
      StoragePolicyRegistry.clearForTesting();
      StoragePolicyRegistry.register(
        'record_meta',
        StoragePolicy.private(carriers: const {Carrier.row, Carrier.blob}),
      );
      tempDir = Directory.systemTemp.createTempSync('uow_c1_');
      dbFile = File('${tempDir.path}/app.sqlite');
      blobRoot = '${tempDir.path}/blobs';
      Directory(blobRoot).createSync(recursive: true);
      adapterRegistry = RecordAdapterRegistry([MeiHuaRecordCodec()]);
      openComposition();
    });

    tearDown(() async {
      await db.close();
      StoragePolicyRegistry.clearForTesting();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    /// 断言四条数据库表面（Record / search index / blob ref / outbox）全空。
    Future<void> expectAllSurfacesEmpty(String recordUuid) async {
      expect(await recordDs.getRecord(recordUuid), isNull,
          reason: 'Record 必须零行');
      final indexHits = await recordDs.findByIndex(
        module: 'meihua',
        indexKey: 'divination_uuid',
        indexValue: 'null',
      );
      expect(indexHits, isEmpty, reason: 'search index 必须零行');
      final refs = await (db.select(
        db.blobRefs,
      )..where((t) => t.ownerRecordUuid.equals(recordUuid))).get();
      expect(refs, isEmpty, reason: 'blob ref 必须零行');
      final outboxRows = await outboxStore.peekBatch(
        scopeUid: scope,
        peerId: peer,
        channel: Channel.cloud,
        limit: 10,
      );
      expect(outboxRows, isEmpty, reason: 'outbox 必须零行');
    }

    test(
      '成功：真实 staged blob 提交 Record + index + ref + outbox，字节可完整读回',
      () async {
        final rawBytes = List<int>.generate(4096, (i) => i % 251);
        final handle = await _putRealBlob(blobStore, bytes: rawBytes);
        final record = c1Record('rec-c1-ok');

        await uow.saveWithBlobs(record: record, referencedBlobs: {handle});

        // Record 已提交
        expect(await recordDs.getRecord('rec-c1-ok'), isNotNull);
        // Search index 已提交
        final indexHits = await recordDs.findByIndex(
          module: 'meihua',
          indexKey: 'divination_uuid',
          indexValue: 'null',
        );
        expect(indexHits, isNotEmpty);
        // Blob ref 已提交
        final refs = await (db.select(
          db.blobRefs,
        )..where((t) => t.ownerRecordUuid.equals('rec-c1-ok'))).get();
        expect(refs, hasLength(1));
        expect(refs.single.cipherManifestId, handle.cipherManifestId);
        // Outbox 已提交
        final outboxRows = await outboxStore.peekBatch(
          scopeUid: scope,
          peerId: peer,
          channel: Channel.cloud,
          limit: 10,
        );
        expect(outboxRows, hasLength(1));
        // 字节可完整读回（reconcile 已把 staged 提升为 committed）
        final read = await blobStore.openRead(handle);
        expect(read, isA<BlobOk>());
        final readBytes = await (read as BlobOk)
            .plaintext
            .expand((b) => b)
            .toList();
        expect(readBytes, rawBytes);
      },
    );

    test(
      'absent：引用无元数据 handle → 抛 BlobNotFoundError，四表面全空，重启仍空',
      () async {
        final absentHandle = BlobHandle(
          plaintextSha256: 'b' * 64,
          cipherManifestId: 'absent-manifest',
          cipherId: 'identity',
          keyVersion: 1,
          totalBytes: 100,
          chunkCount: 1,
          mimeType: 'x/test',
        );
        await expectLater(
          uow.saveWithBlobs(
            record: c1Record('rec-c1-absent'),
            referencedBlobs: {absentHandle},
          ),
          throwsA(isA<BlobNotFoundError>()),
          reason: 'absent 引用必须在事务内抛错并整体回滚',
        );
        await expectAllSurfacesEmpty('rec-c1-absent');

        // 重启（关库 → 同文件重开）后仍全空
        await db.close();
        openComposition();
        await expectAllSurfacesEmpty('rec-c1-absent');
      },
    );

    test(
      'partial：chunk 缺失 → 抛 StorageError(blob_partial)，四表面全空，重启仍空',
      () async {
        // 真实两 chunk staged blob（32768 字节 → 2 × 16384）
        final rawBytes = List<int>.generate(32768, (i) => i % 251);
        final handle = await blobStore.put(
          Stream.value(rawBytes),
          mimeType: 'x/test',
          tier: BlobTier.sourceOfTruth,
          expectedBytes: rawBytes.length,
        );
        expect(handle.chunkCount, 2);

        // 删除第 1 个 chunk 的元数据行 → presentChunks={0} → partial
        await (db.delete(
          db.blobChunks,
        )..where(
            (t) => t.cipherManifestId.equals(handle.cipherManifestId) &
                t.chunkIndex.equals(1),
          ))
            .go();

        await expectLater(
          uow.saveWithBlobs(
            record: c1Record('rec-c1-partial'),
            referencedBlobs: {handle},
          ),
          throwsA(
            isA<StorageError>().having(
              (e) => e.code,
              'code',
              'storage.blob_partial',
            ),
          ),
          reason: 'partial 引用必须在事务内抛错并整体回滚',
        );
        await expectAllSurfacesEmpty('rec-c1-partial');

        await db.close();
        openComposition();
        await expectAllSurfacesEmpty('rec-c1-partial');
      },
    );

    test(
      'corrupt：磁盘 chunk 字节被篡改 → 流消费抛 BlobCorruptError，四表面全空，重启仍空',
      () async {
        final rawBytes = List<int>.generate(16384, (i) => i % 251);
        final handle = await _putRealBlob(blobStore, bytes: rawBytes);

        // 篡改磁盘上的 chunk 文件（SHA-256 校验失败发生在流消费时）
        final chunkFile = File(
          '$blobRoot/$scope/${handle.cipherManifestId}/0.bin',
        );
        expect(chunkFile.existsSync(), isTrue, reason: 'chunk 文件必须已写盘');
        await chunkFile.writeAsBytes([99, 99, 99]);

        await expectLater(
          uow.saveWithBlobs(
            record: c1Record('rec-c1-corrupt'),
            referencedBlobs: {handle},
          ),
          throwsA(isA<BlobCorruptError>()),
          reason: 'corrupt 引用必须在流消费阶段抛错并整体回滚',
        );
        await expectAllSurfacesEmpty('rec-c1-corrupt');

        await db.close();
        openComposition();
        await expectAllSurfacesEmpty('rec-c1-corrupt');
      },
    );

    test(
      'undecryptable：scope 无私钥 → 抛 BlobUndecryptableError，四表面全空，重启仍空',
      () async {
        // 先以注册 IdentityBlobCipher 的 store 写入真实 staged blob
        final handle = await _putRealBlob(blobStore);

        // 用空 cipher registry（无 scope 私钥）的同一 db/rootDir 重建 UoW
        await db.close();
        openComposition(emptyCipherResolver: true);

        await expectLater(
          uow.saveWithBlobs(
            record: c1Record('rec-c1-enc'),
            referencedBlobs: {handle},
          ),
          throwsA(isA<BlobUndecryptableError>()),
          reason: 'undecryptable 引用必须在事务内抛错并整体回滚',
        );
        await expectAllSurfacesEmpty('rec-c1-enc');

        await db.close();
        openComposition(emptyCipherResolver: true);
        await expectAllSurfacesEmpty('rec-c1-enc');
      },
    );
  });
}
