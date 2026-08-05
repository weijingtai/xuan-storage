/// schema v9 迁移测试（S1d · blob 落地层三表）。
///
/// 体例照抄 `creation_audit_logs_schema_v6_migration_test.dart`：
/// 「手工建旧库 → 触发升级 → 逐字段比对」。
///
/// ⚠ 本文件比既有范例多做一件事：**验证旧数据在迁移后逐字段未丢**。
/// 派工单验收项 13 的原文是「逐字段比对**旧数据未丢**」，而既有范例只验证了
/// 新表可用，没有验证旧数据存活 —— 那样的测试无法抓住「迁移里 DROP 了旧表」
/// 这个突变。
///
/// ⚠ 版本号说明：v7 属 S1b（尚未合并），v8 属 S1d。人类 2026-08-03 裁定
/// 「S1b 先合并，S1d 用 v8」。本分支基线为 v6，故此处从 v6 直升 v8；
/// rebase 到含 S1b 的 main 后应补 v7→v8 的链路用例。
library;

// drift 与 matcher 都导出 isNull，此处用 matcher 的版本。
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('schema v9 · blob 三表迁移', () {
    test('v8 旧库升到 v9：三张 blob 表可用', () async {
      final sqliteDb = sqlite3.openInMemory();
      sqliteDb.execute('PRAGMA user_version = 8;');

      final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
      addTearDown(db.close);

      await _assertBlobTablesRoundTrip(db, 'manifest-migrated');
      await _assertBlobIndexes(db);
    });

    test('全新库：三张 blob 表可用', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await _assertBlobTablesRoundTrip(db, 'manifest-new');
      await _assertBlobIndexes(db);
    });

    test('schemaVersion 是 9', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      expect(db.schemaVersion, 9);
    });

    /// ⚠ 这是本文件最重要的一条：迁移不得丢失既有数据。
    ///
    /// 突变验证：若在 `from < 8` 分支里 DROP 掉 `t_record_meta`，本测试变红；
    /// 而只验证「新表可用」的测试对该突变完全无感。
    test('v8 旧库里的既有数据，升到 v9 后逐字段未丢', () async {
      final sqliteDb = sqlite3.openInMemory();

      // 手工建 v6 形态的 t_record_meta（只建本测试需要的列）。
      sqliteDb.execute('''
        CREATE TABLE t_record_meta (
          uuid TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          category TEXT NOT NULL,
          module TEXT NOT NULL,
          divination_type TEXT,
          title TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          occurred_at_utc INTEGER,
          deleted_at INTEGER,
          payload_json TEXT
        );
      ''');
      sqliteDb.execute('''
        INSERT INTO t_record_meta
          (uuid, scope_uid, category, module, divination_type, title,
           created_at, updated_at, occurred_at_utc, deleted_at, payload_json)
        VALUES
          ('rec-keep-1', 'scope-a', 'private', 'meihua', 'meihuayishu',
           '迁移前就存在的记录', 1750000000, 1750000001, 1750000002, NULL,
           '{"k":"v"}');
      ''');
      sqliteDb.execute('PRAGMA user_version = 8;');

      final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
      addTearDown(db.close);

      // 触发升级：任一次查询都会驱动 drift 跑 onUpgrade。
      await _assertBlobTablesRoundTrip(db, 'manifest-coexist');

      // 逐字段比对旧数据。
      final rows = await db
          .customSelect(
            "SELECT uuid, scope_uid, category, module, divination_type, title, "
            "created_at, updated_at, occurred_at_utc, deleted_at, payload_json "
            "FROM t_record_meta WHERE uuid = 'rec-keep-1'",
          )
          .get();

      expect(rows.length, 1, reason: '迁移后旧记录必须还在');
      final row = rows.single;
      expect(row.read<String>('uuid'), 'rec-keep-1');
      expect(row.read<String>('scope_uid'), 'scope-a');
      expect(row.read<String>('category'), 'private');
      expect(row.read<String>('module'), 'meihua');
      expect(row.read<String>('divination_type'), 'meihuayishu');
      expect(row.read<String>('title'), '迁移前就存在的记录');
      expect(row.read<int>('created_at'), 1750000000);
      expect(row.read<int>('updated_at'), 1750000001);
      expect(row.read<int>('occurred_at_utc'), 1750000002);
      expect(row.read<int?>('deleted_at'), isNull);
      expect(row.read<String>('payload_json'), '{"k":"v"}');
    });
  });
}

/// 三张 blob 表的写入-读回逐字段比对。
Future<void> _assertBlobTablesRoundTrip(
  PersistenceDriftDatabase db,
  String manifestId,
) async {
  final stagedAt = DateTime.utc(2026, 8, 3, 10, 30);
  final accessAt = DateTime.utc(2026, 8, 3, 11, 45);

  // ── t_blob_meta ──────────────────────────────────────────
  await db.into(db.blobMetas).insert(
        BlobMetasCompanion.insert(
          cipherManifestId: manifestId,
          scopeUid: 'scope-a',
          plaintextSha256: 'a' * 64,
          cipherId: 'identity',
          keyVersion: 1,
          totalBytes: 32768,
          chunkCount: 2,
          mimeType: 'image/jpeg',
          tier: 0,
          visibility: 0,
          stagedAtUtc: stagedAt,
          lastAccessAtUtc: accessAt,
          externalId: const Value('attachment-42'),
        ),
      );

  final metaRow = await (db.select(db.blobMetas)
        ..where((t) => t.cipherManifestId.equals(manifestId)))
      .getSingle();

  expect(metaRow.cipherManifestId, manifestId);
  expect(metaRow.scopeUid, 'scope-a');
  expect(metaRow.plaintextSha256, 'a' * 64);
  expect(metaRow.cipherId, 'identity');
  expect(metaRow.keyVersion, 1);
  expect(metaRow.totalBytes, 32768);
  expect(metaRow.chunkCount, 2);
  expect(metaRow.mimeType, 'image/jpeg');
  expect(metaRow.tier, 0);
  expect(metaRow.visibility, 0);
  expect(metaRow.status, 0, reason: 'status 默认值必须是 staged(0)');
  expect(metaRow.stagedAtUtc, stagedAt);
  expect(metaRow.lastAccessAtUtc, accessAt);
  expect(metaRow.externalId, 'attachment-42');

  // ── t_blob_chunk ─────────────────────────────────────────
  await db.into(db.blobChunks).insert(
        BlobChunksCompanion.insert(
          cipherManifestId: manifestId,
          chunkIndex: 0,
          cipherBytesLen: 16384,
          chunkSha256: 'b' * 64,
        ),
      );
  await db.into(db.blobChunks).insert(
        BlobChunksCompanion.insert(
          cipherManifestId: manifestId,
          chunkIndex: 1,
          cipherBytesLen: 16384,
          chunkSha256: 'c' * 64,
        ),
      );

  final chunkRows = await (db.select(db.blobChunks)
        ..where((t) => t.cipherManifestId.equals(manifestId))
        ..orderBy([(t) => OrderingTerm.asc(t.chunkIndex)]))
      .get();

  expect(chunkRows.length, 2);
  expect(chunkRows[0].chunkIndex, 0);
  expect(chunkRows[0].cipherBytesLen, 16384);
  expect(chunkRows[0].chunkSha256, 'b' * 64);
  expect(chunkRows[1].chunkIndex, 1);
  expect(chunkRows[1].chunkSha256, 'c' * 64);

  // 复合主键必须生效：同 (manifest, index) 再插必须冲突。
  await expectLater(
    db.into(db.blobChunks).insert(
          BlobChunksCompanion.insert(
            cipherManifestId: manifestId,
            chunkIndex: 0,
            cipherBytesLen: 999,
            chunkSha256: 'd' * 64,
          ),
        ),
    throwsA(isA<SqliteException>()),
    reason: '(cipher_manifest_id, chunk_index) 必须是复合主键',
  );

  // ── t_blob_ref ───────────────────────────────────────────
  await db.into(db.blobRefs).insert(
        BlobRefsCompanion.insert(
          ownerRecordUuid: 'rec-1',
          cipherManifestId: manifestId,
        ),
      );

  final refRows = await (db.select(db.blobRefs)
        ..where((t) => t.cipherManifestId.equals(manifestId)))
      .get();
  expect(refRows.length, 1);
  expect(refRows.single.ownerRecordUuid, 'rec-1');
  expect(refRows.single.cipherManifestId, manifestId);

  // 幂等性的结构保证：同 (owner, manifest) 再插必须冲突。
  await expectLater(
    db.into(db.blobRefs).insert(
          BlobRefsCompanion.insert(
            ownerRecordUuid: 'rec-1',
            cipherManifestId: manifestId,
          ),
        ),
    throwsA(isA<SqliteException>()),
    reason: '(owner_record_uuid, cipher_manifest_id) 必须是复合主键',
  );
}

/// blob 三表的索引必须齐备。
Future<void> _assertBlobIndexes(PersistenceDriftDatabase db) async {
  final rows = await db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type='index' "
        "AND tbl_name IN ('t_blob_meta','t_blob_ref') "
        "AND name LIKE 'idx_blob%' ORDER BY name",
      )
      .get();
  final indexNames = rows.map((row) => row.read<String>('name')).toList();

  expect(indexNames, [
    'idx_blob_external_id',
    'idx_blob_plaintext_sha',
    'idx_blob_ref_manifest',
    'idx_blob_scope_tier_access',
    'idx_blob_status_staged',
  ]);
}
