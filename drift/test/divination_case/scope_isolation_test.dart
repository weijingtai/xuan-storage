import 'dart:io';

import 'package:divination_case/divination_case.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_account/repository_interface_account_fakes.dart';

void main() {
  group('DriftDivinationCaseRepository scope 隔离', () {
    late PersistenceDriftDatabase db;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    DriftDivinationCaseRepository repoFor(String scopeUid) =>
        DriftDivinationCaseRepository(
          db,
          store: LocalRecordRepository(
            DriftRecordDataSource(db, scopeUid: scopeUid),
            RecordAdapterRegistry([]),
          ),
        );

    DivinationRecordModel recordFor(String uuid, String caseUuid) =>
        DivinationRecordModel(
          uuid: uuid,
          caseUuid: caseUuid,
          question: 'question-$uuid',
          detail: 'detail-$uuid',
          directlyPredict: 'yes',
          order: 0,
          createdAt: DateTime.utc(2026, 1, 1),
        );

    Future<List<TRecordMetaData>> rowsWithScope(String scopeUid) =>
        (db.select(db.tRecordMeta)
              ..where((t) => t.scopeUid.equals(scopeUid)))
            .get();

    test('scope A 写入的案卷记录 scope_uid == A（不是 default）', () async {
      final repo = repoFor('scope-a');
      await repo.saveRecord(recordFor('rec-a1', 'case-a1'));

      final rows = await rowsWithScope('scope-a');
      expect(rows, hasLength(1));
      expect(rows.single.uuid, 'rec-a1');
      expect(rows.single.scopeUid, 'scope-a');
      // 修复后不应再有任何记录落到 'default'
      expect(await rowsWithScope('default'), isEmpty);
    });

    test('scope A 与 scope B 写入互不可见、scope 不同', () async {
      final repoA = repoFor('scope-a');
      final repoB = repoFor('scope-b');
      await repoA.saveRecord(recordFor('rec-a1', 'case-a1'));
      await repoB.saveRecord(recordFor('rec-b1', 'case-b1'));

      final rowsA = await rowsWithScope('scope-a');
      final rowsB = await rowsWithScope('scope-b');
      expect(rowsA.single.uuid, 'rec-a1');
      expect(rowsB.single.uuid, 'rec-b1');
      expect(rowsA.single.scopeUid, isNot(rowsB.single.scopeUid));
      expect(rowsA.map((r) => r.uuid), isNot(contains('rec-b1')));
      expect(rowsB.map((r) => r.uuid), isNot(contains('rec-a1')));
    });
  });

  group('案卷记录 handover（匿名转正）', () {
    late Directory blobBase;
    late Directory backupDir;
    late File dbFile;
    late PersistenceDriftDatabase db;
    late DriftScopeBootstrapStore bootstrapStore;
    late DriftScopeLedger ledger;

    setUp(() async {
      blobBase = await Directory.systemTemp.createTemp('case-repo-handover-blob');
      backupDir = await Directory.systemTemp.createTemp('case-repo-handover-backup');
      dbFile = File('${blobBase.path}/persistence.sqlite');
      db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      bootstrapStore = DriftScopeBootstrapStore(db);
      ledger = DriftScopeLedger(db: db, bootstrapStore: bootstrapStore);
    });

    tearDown(() async {
      await db.close();
      await blobBase.delete(recursive: true);
      await backupDir.delete(recursive: true);
    });

    DriftDivinationCaseRepository repoFor(String scopeUid) =>
        DriftDivinationCaseRepository(
          db,
          store: LocalRecordRepository(
            DriftRecordDataSource(db, scopeUid: scopeUid),
            RecordAdapterRegistry([]),
          ),
        );

    Future<void> runHandover(String from, String to) async {
      final handover = DriftScopeHandoverService(
        db: db,
        ledger: ledger,
        blobDirForScope: (scope) => '${blobBase.path}/blob-$scope',
        backupService: DriftSqliteFileBackupService(
          db: db,
          backupDirectory: backupDir,
        ),
      );
      await handover.handover(fromScope: from, toScope: to);
    }

    Future<List<TRecordMetaData>> recordsInScope(String scopeUid) =>
        (db.select(db.tRecordMeta)
              ..where((t) => t.scopeUid.equals(scopeUid)))
            .get();

    test('scope A 存案卷 → handover(A→B) → 案卷 scope 变 B 且 B 能读到', () async {
      // 匿名槽位即 scope A：案卷记录写入 scope A
      final repoA = repoFor('scope-a');
      await repoA.saveRecord(DivinationRecordModel(
        uuid: 'rec-handover-1',
        caseUuid: 'case-handover-1',
        question: '转正后能否看到',
        detail: 'handover 场景',
        directlyPredict: 'yes',
        order: 0,
        createdAt: DateTime.utc(2026, 2, 1),
      ));

      // 修复后：写入行的 scope 必须是 A（真实 uuid），而不是 'default'
      expect(await recordsInScope('scope-a'), hasLength(1));
      expect(await recordsInScope('default'), isEmpty);

      // 用户转正：handover 把 scope A 下全部数据 owner 改为 B
      await runHandover('scope-a', 'scope-b');

      // 案卷记录的 scope 已变为 B
      final rowsB = await recordsInScope('scope-b');
      expect(rowsB, hasLength(1));
      expect(rowsB.single.uuid, 'rec-handover-1');
      expect(rowsB.single.scopeUid, 'scope-b');
      // 原 scope A 下已搬空
      expect(await recordsInScope('scope-a'), isEmpty);

      // B 能读到自己的案卷记录
      final repoB = repoFor('scope-b');
      final fetched = await repoB.getRecord('rec-handover-1');
      expect(fetched, isNotNull);
      expect(fetched!.uuid, 'rec-handover-1');
      expect(fetched.caseUuid, 'case-handover-1');
    });
  });
}