import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/in_memory_blob_store.dart';
import 'package:persistence_drift/media/drift_media_acquisition_adapter.dart';
import 'package:persistence_drift/media/media_source.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/record/local_record_repository.dart';
import 'package:persistence_drift/record/record_adapter_registry.dart';
import 'package:persistence_drift/xiang/xiang_delete_media_handler.dart';
import 'package:persistence_drift/xiang/xiang_module_registry.dart';
import 'package:persistence_drift/xiang/xiang_reading_repository_impl.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_media/repository_interface_media.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';

RequestContext _ctx(String id) => RequestContext(scopeUid: id);

/// Helper: put + unwrap
Future<void> _save(XiangReadingRepository repo, XiangReading reading) async {
  final ctx = _ctx(reading.uuid);
  final r = await repo.put(reading, ctx);
  switch (r) {
    case Ok():
      return;
    case Err(:final error):
      throw error;
  }
}

/// Helper: softDelete + unwrap
Future<void> _softDeleteById(XiangReadingRepository repo, String uuid) async {
  final r = await repo.softDelete(uuid, _ctx(uuid));
  switch (r) {
    case Ok():
      return;
    case Err(:final error):
      throw error;
  }
}

/// TDD-T7 — 删除与审计：
/// 1) 删除相法记录时通过 xuan-storage 媒体生命周期处理引用；
/// 2) 仅当媒体没有其他记录引用时才删除实际资源（共享引用不误删）；
/// 3) 审计必须持久化（落库可查），禁止仅进程内 List。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  XiangReading buildReading({
    required String uuid,
    required List<XiangEvidence> evidence,
  }) =>
      XiangReading(
        uuid: uuid,
        methodId: 'xiang_face',
        methodVersion: 1,
        occurredAt: DateTime.utc(2026, 8, 11),
        evidence: evidence,
        observations: const [],
        tagSelections: const [],
      );

  MediaReference ref(String id, MediaRole role) => MediaReference(
        refId: id,
        version: 1,
        role: role,
        mimeType: role == MediaRole.evidenceImage ? 'image/jpeg' : 'video/mp4',
        createdAtUtc: DateTime.utc(2026, 1, 1),
      );

  test('删除记录：审计事件持久化落库可查（非进程内 List）', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    final ds = DriftRecordDataSource(db, scopeUid: 'scope-t7');
    final store = LocalRecordRepository(
      ds,
      RecordAdapterRegistry([XiangModuleRegistry.codec()]),
    );
    final blobStore = InMemoryBlobStore(scopeUid: 'scope-t7');
    final handler = XiangDeleteMediaHandler(
      blobStore: blobStore,
      store: store,
      db: db,
    );
    final repo = XiangReadingRepositoryImpl(
      store: store,
      codec: XiangModuleRegistry.codec(),
      deleteMediaHandler: handler,
    );

    final media = DriftMediaAcquisitionAdapter(
      blobStore: blobStore,
      picker: (role, {maxWidth, maxHeight, maxDurationMs}) async =>
          MediaSourceData(
        bytes: List<int>.generate(256, (i) => i),
        mimeType: 'image/jpeg',
        width: 640,
        height: 480,
      ),
    );
    final acquired = await media.acquireImage(role: MediaRole.evidenceImage);
    final reading = buildReading(
      uuid: 't7-r-1',
      evidence: [
        XiangEvidence(order: 0, role: 'image', mediaRef: acquired.reference),
      ],
    );
    await _save(repo, reading);

    await _softDeleteById(repo, 't7-r-1');

    final audit = await handler.queryAuditLogs();
    expect(audit, isNotEmpty);
    final evt = audit.firstWhere((e) => e.operation == 'reading.delete');
    expect(evt.mediaRefCount, 1);
    expect(evt.operatorUid, 'scope-t7');

    await db.close();
  });

  test('删除后：无其他引用时媒体实际资源被回收', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    final ds = DriftRecordDataSource(db, scopeUid: 'scope-t7');
    final store = LocalRecordRepository(
      ds,
      RecordAdapterRegistry([XiangModuleRegistry.codec()]),
    );
    final blobStore = InMemoryBlobStore(scopeUid: 'scope-t7');
    final handler = XiangDeleteMediaHandler(
      blobStore: blobStore,
      store: store,
      db: db,
    );
    final repo = XiangReadingRepositoryImpl(
      store: store,
      codec: XiangModuleRegistry.codec(),
      deleteMediaHandler: handler,
    );

    final media = DriftMediaAcquisitionAdapter(
      blobStore: blobStore,
      picker: (role, {maxWidth, maxHeight, maxDurationMs}) async =>
          MediaSourceData(
        bytes: List<int>.generate(256, (i) => i),
        mimeType: 'image/jpeg',
        width: 640,
        height: 480,
      ),
    );
    final acquired = await media.acquireImage(role: MediaRole.evidenceImage);
    await _save(
      repo,
      buildReading(
        uuid: 't7-r-2',
        evidence: [
          XiangEvidence(order: 0, role: 'image', mediaRef: acquired.reference),
        ],
      ),
    );

    var blobs = await blobStore.list(tier: BlobTier.sourceOfTruth).toList();
    expect(
      blobs.any((e) => e.handle.cipherManifestId == acquired.reference.refId),
      isTrue,
    );

    await _softDeleteById(repo, 't7-r-2');

    blobs = await blobStore.list(tier: BlobTier.sourceOfTruth).toList();
    expect(
      blobs.any((e) => e.handle.cipherManifestId == acquired.reference.refId),
      isFalse,
    );

    await db.close();
  });

  test('共享引用：另一记录仍引用同一媒体时不误删', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    final ds = DriftRecordDataSource(db, scopeUid: 'scope-t7');
    final store = LocalRecordRepository(
      ds,
      RecordAdapterRegistry([XiangModuleRegistry.codec()]),
    );
    final blobStore = InMemoryBlobStore(scopeUid: 'scope-t7');
    final handler = XiangDeleteMediaHandler(
      blobStore: blobStore,
      store: store,
      db: db,
    );
    final repo = XiangReadingRepositoryImpl(
      store: store,
      codec: XiangModuleRegistry.codec(),
      deleteMediaHandler: handler,
    );

    final media = DriftMediaAcquisitionAdapter(
      blobStore: blobStore,
      picker: (role, {maxWidth, maxHeight, maxDurationMs}) async =>
          MediaSourceData(
        bytes: List<int>.generate(256, (i) => i),
        mimeType: 'image/jpeg',
        width: 640,
        height: 480,
      ),
    );
    final acquired = await media.acquireImage(role: MediaRole.evidenceImage);
    await _save(
      repo,
      buildReading(
        uuid: 't7-r-3a',
        evidence: [
          XiangEvidence(order: 0, role: 'image', mediaRef: acquired.reference),
        ],
      ),
    );
    await _save(
      repo,
      buildReading(
        uuid: 't7-r-3b',
        evidence: [
          XiangEvidence(order: 0, role: 'image', mediaRef: acquired.reference),
        ],
      ),
    );

    await _softDeleteById(repo, 't7-r-3a');

    final blobs = await blobStore.list(tier: BlobTier.sourceOfTruth).toList();
    expect(
      blobs.any((e) => e.handle.cipherManifestId == acquired.reference.refId),
      isTrue,
    );

    await db.close();
  });
}
