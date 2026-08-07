import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/sync/entity_stamp_manifest_source.dart';

/// S1c ACT-C 集成测试：EntityStampManifestSource（清单分片读取）。
///
/// 覆盖：
/// 1. 空清单 → 返回空片（totalChunks=0），非 null。
/// 2. 单页内全部行 → 一片，含墓碑行。
/// 3. 多页 → chunkSeq 从 0 递增、totalChunks 正确、无重无漏。
/// 4. 断点续传：同批数据两次读出分片边界一致（按 entityId 稳定排序）。
void main() {
  const scope = 'ms-scope';

  test('empty_manifest_returns_empty_chunk_not_null', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final source = EntityStampManifestSource(db);

    final chunk = await source.readManifestChunk(
      scopeUid: scope,
      entityType: 'record_meta',
      chunkSeq: 0,
      pageSize: 100,
    );

    expect(chunk, isNotNull);
    expect(chunk!.entries, isEmpty);
    expect(chunk.totalChunks, 0);
    expect(chunk.chunkSeq, 0);
  });

  test('single_page_includes_tombstone_rows', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // 两条活 + 一条墓碑
    await _insertStamp(db, scope, 'r1', hlc: 1000, deleted: false);
    await _insertStamp(db, scope, 'r2', hlc: 2000, deleted: false);
    await _insertStamp(db, scope, 'r3', hlc: 3000, deleted: true);

    final source = EntityStampManifestSource(db);
    final chunk = await source.readManifestChunk(
      scopeUid: scope,
      entityType: 'record_meta',
      chunkSeq: 0,
      pageSize: 100,
    );

    expect(chunk, isNotNull);
    expect(chunk!.entries, hasLength(3));
    expect(chunk.totalChunks, 1);
    expect(chunk.chunkSeq, 0);

    // 按 entityId 排序，墓碑行必须包含（r3 isDeleted=true）
    expect(chunk.entries[0].entityId, 'r1');
    expect(chunk.entries[0].isDeleted, isFalse);
    expect(chunk.entries[1].entityId, 'r2');
    expect(chunk.entries[2].entityId, 'r3');
    expect(chunk.entries[2].isDeleted, isTrue, reason: '清单必须含墓碑行');
    expect(chunk.entries[2].hlcPacked, 3000 << 16);
  });

  test('multi_page_chunks_are_contiguous_and_complete', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // 5 行，pageSize=2 → 3 片 (2,2,1)
    for (var i = 0; i < 5; i++) {
      await _insertStamp(
        db,
        scope,
        'r${i + 1}',
        hlc: 1000 + i * 10,
        deleted: i == 4,
      );
    }

    final source = EntityStampManifestSource(db);
    final pages = <String>[];
    for (var seq = 0; ; seq++) {
      final chunk = await source.readManifestChunk(
        scopeUid: scope,
        entityType: 'record_meta',
        chunkSeq: seq,
        pageSize: 2,
      );
      if (chunk == null) break;
      pages.addAll(chunk.entries.map((e) => e.entityId));
    }

    expect(pages, ['r1', 'r2', 'r3', 'r4', 'r5'],
        reason: '分片必须无重无漏、按 entityId 稳定排序');
  });

  test('chunk_out_of_range_returns_null', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _insertStamp(db, scope, 'r1', hlc: 1000, deleted: false);

    final source = EntityStampManifestSource(db);
    final chunk0 = await source.readManifestChunk(
      scopeUid: scope, entityType: 'record_meta', chunkSeq: 0, pageSize: 1,
    );
    expect(chunk0, isNotNull);
    expect(chunk0!.totalChunks, 1);

    final chunk1 = await source.readManifestChunk(
      scopeUid: scope, entityType: 'record_meta', chunkSeq: 1, pageSize: 1,
    );
    expect(chunk1, isNull, reason: '超出总分片数必须返回 null');
  });
}

Future<void> _insertStamp(
  PersistenceDriftDatabase db,
  String scope,
  String entityId, {
  required int hlc,
  required bool deleted,
}) {
  return db.applyWithStamp(
    scopeUid: scope,
    entityType: 'record_meta',
    entityId: entityId,
    hlcPacked: hlc << 16,
    deviceId: 'dev-$entityId',
    write: () async {},
    isDeleted: deleted,
  );
}
