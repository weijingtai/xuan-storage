/// v1 → v9 全链路迁移测试（S1d · 完整迁移链）。
///
/// 验证 v1 形态的数据在 v8→v9 迁移后存活。
/// 测试策略：创建 v8 数据库 → 插入 v1 形态记录 → 升级到 v9 → 验证。
library;

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('v1 → v9 全链路迁移', () {
    /// 创建 v8 数据库（含 v6 需手建的表，设 user_version=8），
    /// 插入 v1 形态记录，升级到 v9，验证记录存活 + blob 三表可用。
    test('v8 旧库 → v9：v1 记录数据存活 + blob 三表可用', () async {
      final sqliteDb = sqlite3.openInMemory();

      // 手建 v6 形态的 t_record_meta（含 v1 就有的列）。
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
      // 插入 v1 形态的记录数据。
      sqliteDb.execute('''
        INSERT INTO t_record_meta
          (uuid, scope_uid, category, module, divination_type, title,
           created_at, updated_at, occurred_at_utc, deleted_at, payload_json)
        VALUES
          ('rec-v1-keep', 'scope-a', 'private', 'meihua', 'meihuayishu',
           'v1 就存在的记录', 1750000000, 1750000001, 1750000002, NULL,
           '{"k":"v"}');
      ''');
      sqliteDb.execute('PRAGMA user_version = 8;');

      final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
      addTearDown(db.close);

      await _assertBlobTablesRoundTrip(db, 'manifest-v1-upgrade');
      await _assertBlobIndexes(db);

      // 逐字段比对旧记录数据存活。
      final rows = await db.customSelect(
        "SELECT uuid, scope_uid, category, module, divination_type, title, "
        "created_at, updated_at, occurred_at_utc, deleted_at, payload_json "
        "FROM t_record_meta WHERE uuid = 'rec-v1-keep'",
      ).get();

      expect(rows.length, 1, reason: 'v1 旧记录在 v9 中必须存活');
      final row = rows.single;
      expect(row.read<String>('uuid'), 'rec-v1-keep');
      expect(row.read<String>('scope_uid'), 'scope-a');
      expect(row.read<String>('category'), 'private');
      expect(row.read<String>('module'), 'meihua');
      expect(row.read<String>('divination_type'), 'meihuayishu');
      expect(row.read<String>('title'), 'v1 就存在的记录');
      expect(row.read<int>('created_at'), 1750000000);
      expect(row.read<int>('updated_at'), 1750000001);
      expect(row.read<int>('occurred_at_utc'), 1750000002);
      expect(row.read<int?>('deleted_at'), isNull);
      expect(row.read<String>('payload_json'), '{"k":"v"}');
    });

    test('blob UTC 列往返：epoch 与 isUtc 均保持', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const stagedEpoch = 1750000000;
      const accessEpoch = 1750000001;
      final stagedAt = DateTime.fromMillisecondsSinceEpoch(
        stagedEpoch * 1000,
        isUtc: true,
      );
      final accessAt = DateTime.fromMillisecondsSinceEpoch(
        accessEpoch * 1000,
        isUtc: true,
      );

      await db.into(db.blobMetas).insert(
            BlobMetasCompanion.insert(
              cipherManifestId: 'utc-test',
              scopeUid: 'scope-a',
              plaintextSha256: 'a' * 64,
              cipherId: 'identity',
              keyVersion: 1,
              totalBytes: 100,
              chunkCount: 1,
              mimeType: 'x/test',
              tier: 0,
              visibility: 0,
              stagedAtUtc: stagedAt,
              lastAccessAtUtc: accessAt,
            ),
          );

      final metaRow = await (db.select(db.blobMetas)
            ..where((t) => t.cipherManifestId.equals('utc-test')))
          .getSingle();

      expect(metaRow.stagedAtUtc.millisecondsSinceEpoch ~/ 1000, stagedEpoch);
      expect(metaRow.lastAccessAtUtc.millisecondsSinceEpoch ~/ 1000, accessEpoch);
      expect(metaRow.stagedAtUtc.isUtc, isTrue,
          reason: 'stagedAtUtc 必须是 UTC');
      expect(metaRow.lastAccessAtUtc.isUtc, isTrue,
          reason: 'lastAccessAtUtc 必须是 UTC');
    });

    test('cipher_manifest_id 主键：重复插入必须冲突', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.into(db.blobMetas).insert(
            BlobMetasCompanion.insert(
              cipherManifestId: 'dup',
              scopeUid: 'scope-a',
              plaintextSha256: 'a' * 64,
              cipherId: 'identity',
              keyVersion: 1,
              totalBytes: 100,
              chunkCount: 1,
              mimeType: 'x/test',
              tier: 0,
              visibility: 0,
              stagedAtUtc: DateTime.utc(2026, 8, 3, 10),
              lastAccessAtUtc: DateTime.utc(2026, 8, 3, 11),
            ),
          );

      await expectLater(
        db.into(db.blobMetas).insert(
              BlobMetasCompanion.insert(
                cipherManifestId: 'dup',
                scopeUid: 'scope-a',
                plaintextSha256: 'b' * 64,
                cipherId: 'identity',
                keyVersion: 1,
                totalBytes: 100,
                chunkCount: 1,
                mimeType: 'x/test',
                tier: 0,
                visibility: 0,
                stagedAtUtc: DateTime.utc(2026, 8, 3, 10),
                lastAccessAtUtc: DateTime.utc(2026, 8, 3, 11),
              ),
            ),
        throwsA(isA<SqliteException>()),
        reason: 'cipher_manifest_id 是主键，重复必须冲突',
      );
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
  expect(metaRow.status, 0);
  expect(metaRow.stagedAtUtc, stagedAt);
  expect(metaRow.lastAccessAtUtc, accessAt);
  expect(metaRow.externalId, 'attachment-42');

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