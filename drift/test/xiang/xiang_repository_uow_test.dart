/// C3 — Xiang 仓库 put 走共享 RecordBlobUnitOfWork（FINAL-REWORK-PLAN）。
///
/// 生产等价装配：
///   真实 DriftMediaAcquisitionAdapter 采集（staged status=0）
///   → XiangReadingRepositoryImpl.put
///   → 注入的共享 DriftRecordBlobUnitOfWork.saveWithBlobs
///   → Record + search index + blob ref + outbox 同事务提交，staged 提升为
///     committed（status=1），字节可完整读回。
///
/// 失败路径：corrupt（磁盘 chunk 篡改）与 missing（refId 无元数据）都必须
/// fail closed——零 Record / 零 ref / 零 outbox，blob 元数据保持 staged，
/// 关库重开后仍全空/仍 staged（C1 的事务内原子校验 + C3 的 handle 解析）。
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/drift_record_blob_unit_of_work.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/media/drift_media_acquisition_adapter.dart';
import 'package:persistence_drift/media/media_source.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/xiang/xiang_module_registry.dart';
import 'package:persistence_drift/xiang/xiang_reading_repository_impl.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_media/repository_interface_media.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';

const _scope = 'scope-c3';
RequestContext _ctx() => RequestContext(scopeUid: _scope);

const List<int> _sampleJpegBytes = [
  0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
];

XiangReading _reading(String uuid, MediaReference mediaRef) => XiangReading(
      uuid: uuid,
      methodId: 'xiang_face',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 8, 30, 4, 0),
      evidence: [
        XiangEvidence(order: 0, role: 'image', mediaRef: mediaRef),
      ],
      observations: const [],
      tagSelections: const [],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dbFile;
  late String blobRoot;
  late PersistenceDriftDatabase db;
  late BlobMetadataRepository metaRepo;
  late DriftLocalBlobStore blobStore;
  late DriftRecordBlobUnitOfWork uow;
  late DriftOutboxStore outboxStore;
  late LocalRecordRepository store;
  late XiangReadingRepositoryImpl repo;
  late DriftRecordDataSource recordDs;

  void openComposition() {
    db = PersistenceDriftDatabase(NativeDatabase(dbFile));
    metaRepo = BlobMetadataRepository(db: db, scopeUid: _scope);
    final resolver = BlobCipherRegistry();
    resolver.register(_scope, const IdentityBlobCipher());
    blobStore = DriftLocalBlobStore(
      scopeUid: _scope,
      metadataRepository: metaRepo,
      cipherResolver: resolver,
      rootDir: blobRoot,
      db: db,
    );
    outboxStore = DriftOutboxStore(dao: OutboxRecordsDao(db));
    final registry = RecordAdapterRegistry([XiangModuleRegistry.codec()]);
    uow = DriftRecordBlobUnitOfWork(
      db: db,
      scopeUid: _scope,
      blobStore: blobStore,
      adapterRegistry: registry,
      outboxStore: outboxStore,
    );
    recordDs = DriftRecordDataSource(db, scopeUid: _scope);
    store = LocalRecordRepository(recordDs, registry, outboxStore: outboxStore);
    repo = XiangReadingRepositoryImpl(
      store: store,
      codec: XiangModuleRegistry.codec(),
      unitOfWork: uow,
      blobMetadataRepository: metaRepo,
    );
  }

  /// 生产等价采集：真实 DriftLocalBlobStore 写盘 staged blob 并铸造 refId。
  Future<MediaReference> acquire({List<int>? bytes}) async {
    final adapter = DriftMediaAcquisitionAdapter(
      blobStore: blobStore,
      picker: (role, {maxWidth, maxHeight, maxDurationMs}) async =>
          MediaSourceData(
        bytes: bytes ?? _sampleJpegBytes,
        mimeType: 'image/jpeg',
        width: 640,
        height: 480,
      ),
    );
    final result = await adapter.acquireImage(role: MediaRole.evidenceImage);
    return result.reference;
  }

  Future<void> expectNoWrites(String uuid) async {
    expect(await recordDs.getRecord(uuid), isNull, reason: 'Record 必须零行');
    final refs = await (db.select(
      db.blobRefs,
    )..where((t) => t.ownerRecordUuid.equals(uuid))).get();
    expect(refs, isEmpty, reason: 'blob ref 必须零行');
    final outbox = await outboxStore.peekBatch(
      scopeUid: _scope,
      peerId: const PeerId('cloud'),
      channel: Channel.cloud,
      limit: 10,
    );
    expect(outbox, isEmpty, reason: 'outbox 必须零行');
  }

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'xiang_reading',
      StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
    );
    // RecordOutboxMapper.entityType 恒为 'record_meta'（共享通用审计/外发），
    // 通道过滤按它查表，故须注册（照 C1 文件组先例）。
    StoragePolicyRegistry.register(
      'record_meta',
      StoragePolicy.private(carriers: const {Carrier.row, Carrier.blob}),
    );
    tempDir = Directory.systemTemp.createTempSync('xiang_c3_');
    dbFile = File('${tempDir.path}/app.sqlite');
    blobRoot = '${tempDir.path}/blobs';
    Directory(blobRoot).createSync(recursive: true);
    openComposition();
  });

  tearDown(() async {
    await db.close();
    StoragePolicyRegistry.clearForTesting();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'RED→GREEN：真实 staged 图经共享 UoW 落库 → 一 Record/一 ref/一 outbox/'
    'committed 元数据/字节可读回',
    () async {
      final ref = await acquire();
      final result = await repo.put(_reading('c3-ok', ref), _ctx());

      expect(result, isA<Ok>(), reason: 'put 必须成功（GREEN 期望）');
      expect(result, isA<Ok<Rev>>());

      // 恰好一条 scoped Xiang Record
      final metas = await store.listRecords(module: 'xiang', limit: 10);
      expect(metas, hasLength(1));
      expect(metas.single.uuid, 'c3-ok');
      expect(metas.single.scopeUid, _scope);

      // 恰好一条匹配 blob ref（owner = record uuid，manifest = refId）
      final refRows = await (db.select(
        db.blobRefs,
      )..where((t) => t.ownerRecordUuid.equals('c3-ok'))).get();
      expect(refRows, hasLength(1));
      expect(refRows.single.cipherManifestId, ref.refId);

      // 恰好一条 outbox
      final outbox = await outboxStore.peekBatch(
        scopeUid: _scope,
        peerId: const PeerId('cloud'),
        channel: Channel.cloud,
        limit: 10,
      );
      expect(outbox, hasLength(1));

      // 元数据 committed（status=1）
      final meta = await metaRepo.getMeta(ref.refId);
      expect(meta, isNotNull);
      expect(meta!.status, 1, reason: 'UoW 必须把 staged 提升为 committed');

      // 字节可完整读回
      final handle = await metaRepo.getHandle(ref.refId);
      expect(handle, isNotNull);
      final read = await blobStore.openRead(handle!);
      expect(read, isA<BlobOk>());
      final bytes = await (read as BlobOk).plaintext.expand((b) => b).toList();
      expect(bytes, _sampleJpegBytes);
    },
  );

  test(
    'corrupt：磁盘 chunk 篡改 → put Err，零 Record/ref/outbox，元数据仍 staged，重启仍空',
    () async {
      // 真实单 chunk staged blob（16384 字节 → 1 chunk）
      final bytes = List<int>.generate(16384, (i) => i % 251);
      final ref = await acquire(bytes: bytes);

      // 篡改磁盘 chunk 文件（C1 校验在事务内流消费时发现）
      final chunkFile = File('$blobRoot/$_scope/${ref.refId}/0.bin');
      expect(chunkFile.existsSync(), isTrue, reason: 'chunk 文件必须已写盘');
      await chunkFile.writeAsBytes([99, 99, 99]);

      final result = await repo.put(_reading('c3-corrupt', ref), _ctx());
      expect(result, isA<Err>(), reason: 'corrupt 引用必须 fail closed');

      await expectNoWrites('c3-corrupt');
      expect(
        (await metaRepo.getMeta(ref.refId))!.status,
        0,
        reason: '失败后 blob 元数据必须仍为 staged',
      );

      // 重启（关库 → 同文件重开）后仍全空、仍 staged
      await db.close();
      openComposition();
      await expectNoWrites('c3-corrupt');
      expect(
        (await metaRepo.getMeta(ref.refId))!.status,
        0,
        reason: '重启后 blob 元数据必须仍为 staged',
      );
    },
  );

  test(
    'missing：refId 无 blob 元数据 → put Err，零 Record/ref/outbox',
    () async {
      final ghost = MediaReference(
        refId: 'no-such-cipher-manifest',
        version: 1,
        role: MediaRole.evidenceImage,
        mimeType: 'image/jpeg',
        createdAtUtc: DateTime.utc(2026, 8, 30),
      );
      final result = await repo.put(_reading('c3-missing', ghost), _ctx());
      expect(result, isA<Err>(), reason: '缺失 handle 必须 fail closed');

      await expectNoWrites('c3-missing');

      // 重启后仍零写入
      await db.close();
      openComposition();
      await expectNoWrites('c3-missing');
    },
  );
}
