import 'dart:io';

import 'package:divination_case/divination_case.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_account/repository_interface_account_fakes.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:sqlite3/sqlite3.dart';

/// SW1-T1：案卷创建流 6 张表加 scope_uid 列并回填（schema v10 → v11）。
///
/// 覆盖 5 项硬性要求：
/// 1. schema v10 库升级到 v11 后 6 张表都有 scope_uid 列
/// 2. 回填正确性：v10 旧库含案卷数据 + t_record_meta，升级后 6 张表 scope
///    与 record_meta 一致
/// 3. 孤儿行（record_meta 里无对应记录）scope_uid 仍为 NULL，不误填默认值
/// 4. 写路径：scope A 下建案卷 → 6 张表的行 scope 都是 A
/// 5. handover(A→B) 后 6 张表的行 scope 都变成 B
void main() {
  group('schema v10 → v11 案卷创建流 6 表 scope_uid 迁移', () {
    // v10 版 6 张表（无 scope_uid 列）+ t_record_meta（带 scope_uid）
    void createV10Schema(Database sqliteDb) {
      sqliteDb.execute('''
        CREATE TABLE t_divination_cases (
          uuid TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          main_question TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER,
          final_summary TEXT,
          extras_json TEXT
        );
        CREATE TABLE t_divination_work_items (
          uuid TEXT NOT NULL PRIMARY KEY,
          case_uuid TEXT NOT NULL,
          parent_work_item_uuid TEXT,
          title TEXT NOT NULL,
          purpose TEXT NOT NULL,
          method_group TEXT NOT NULL,
          order_index INTEGER NOT NULL,
          status TEXT NOT NULL,
          summary TEXT,
          conclusion TEXT
        );
        CREATE TABLE t_case_participants (
          uuid TEXT NOT NULL PRIMARY KEY,
          case_uuid TEXT NOT NULL,
          record_uuid TEXT,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          seeker_uuid TEXT
        );
        CREATE TABLE t_panel_refs (
          uuid TEXT NOT NULL PRIMARY KEY,
          module TEXT NOT NULL,
          panel_uuid TEXT NOT NULL,
          panel_type TEXT NOT NULL,
          role TEXT NOT NULL,
          title TEXT
        );
        CREATE TABLE t_work_item_panel_refs (
          uuid TEXT NOT NULL PRIMARY KEY,
          work_item_uuid TEXT NOT NULL,
          panel_ref_uuid TEXT NOT NULL,
          role TEXT NOT NULL,
          order_index INTEGER NOT NULL
        );
        CREATE TABLE t_creation_audit_logs (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          case_uuid TEXT NOT NULL,
          audited_at INTEGER NOT NULL,
          change_type TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_uuid TEXT,
          old_json TEXT,
          new_json TEXT,
          summary TEXT,
          operator_id TEXT
        );
        CREATE TABLE t_record_meta (
          uuid TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          module TEXT NOT NULL,
          category TEXT NOT NULL,
          divination_type TEXT NOT NULL,
          case_uuid TEXT,
          work_item_uuid TEXT,
          seeker_uuid TEXT,
          question TEXT,
          detail TEXT,
          tag TEXT,
          direct_predict TEXT,
          verification_status TEXT,
          seeker_name TEXT,
          gender TEXT,
          fate_year TEXT,
          module_data_json TEXT,
          nav_params_json TEXT,
          occurred_at_utc INTEGER,
          reckoning_type TEXT,
          timezone_str TEXT,
          latitude REAL,
          longitude REAL,
          location_name TEXT,
          spacetime_json TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          deleted_at INTEGER,
          rev INTEGER NOT NULL DEFAULT 1
        );
        PRAGMA user_version = 10;
      ''');
    }

    Future<List<String>> scopeUidForTable(
      PersistenceDriftDatabase db,
      String tableName,
    ) async {
      final rows = await db.customSelect(
        'SELECT scope_uid FROM "$tableName" ORDER BY rowid',
      ).get();
      return rows.map((r) => r.read<String>('scope_uid')).toList();
    }

    test('v10 库升级 v11 后 6 张表都有 scope_uid 列', () async {
      final sqliteDb = sqlite3.openInMemory();
      createV10Schema(sqliteDb);

      final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
      addTearDown(db.close);

      for (final tableName in [
        't_divination_cases',
        't_divination_work_items',
        't_case_participants',
        't_panel_refs',
        't_work_item_panel_refs',
        't_creation_audit_logs',
      ]) {
        final cols = await db.customSelect(
          'SELECT name FROM pragma_table_info("$tableName")',
        ).get();
        final hasScope = cols.any((r) => r.read<String>('name') == 'scope_uid');
        expect(hasScope, isTrue, reason: '$tableName 应含 scope_uid 列');
      }
    });

    test('回填正确性：6 张表 scope 与 t_record_meta 一致（两级传递）', () async {
      final sqliteDb = sqlite3.openInMemory();
      createV10Schema(sqliteDb);
      // scope-a：有完整 record_meta 关联
      sqliteDb.execute('''
        INSERT INTO t_record_meta (uuid, scope_uid, module, category, divination_type,
          case_uuid, work_item_uuid, created_at)
        VALUES ('rec-a', 'scope-a', 'divination_case', 'record', 'general',
          'case-a', 'workitem-a', 1);
        INSERT INTO t_divination_cases (uuid, title, main_question, status,
          created_at, updated_at)
        VALUES ('case-a', '甲', '问', 'open', 1, 1);
        INSERT INTO t_divination_work_items (uuid, case_uuid, title, purpose,
          method_group, order_index, status)
        VALUES ('workitem-a', 'case-a', '乙', 'p', 'other', 0, 'planned');
        INSERT INTO t_case_participants (uuid, case_uuid, name, role)
        VALUES ('part-a', 'case-a', '张三', 'primarySeeker');
        INSERT INTO t_panel_refs (uuid, module, panel_uuid, panel_type, role)
        VALUES ('panelref-a', 'liuyao', 'p1', 'yao', 'main');
        INSERT INTO t_work_item_panel_refs (uuid, work_item_uuid, panel_ref_uuid,
          role, order_index)
        VALUES ('wipr-a', 'workitem-a', 'panelref-a', 'main', 0);
        INSERT INTO t_creation_audit_logs (case_uuid, audited_at, change_type,
          entity_type)
        VALUES ('case-a', 1, 'create', 'case');
      ''');

      final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
      addTearDown(db.close);

      // 第一级：case / workitem 直接反查 record_meta
      expect(await scopeUidForTable(db, 't_divination_cases'), ['scope-a']);
      expect(await scopeUidForTable(db, 't_divination_work_items'), ['scope-a']);
      // 第二级：participants / audit 经 case_uuid → case
      expect(await scopeUidForTable(db, 't_case_participants'), ['scope-a']);
      expect(await scopeUidForTable(db, 't_creation_audit_logs'), ['scope-a']);
      // 第二级：wipr 经 work_item_uuid → work item
      expect(await scopeUidForTable(db, 't_work_item_panel_refs'), ['scope-a']);
      // 第二级：panel_refs 经 work_item_panel_refs(panel_ref_uuid) 反查 work item
      expect(await scopeUidForTable(db, 't_panel_refs'), ['scope-a']);
    });

    test('孤儿行 scope_uid 保持 NULL，不误填默认值', () async {
      final sqliteDb = sqlite3.openInMemory();
      createV10Schema(sqliteDb);
      // 6 张表各造一条无 record_meta 关联的孤儿行
      sqliteDb.execute('''
        INSERT INTO t_divination_cases (uuid, title, main_question, status,
          created_at, updated_at)
        VALUES ('case-orphan', '孤', '问', 'open', 1, 1);
        INSERT INTO t_divination_work_items (uuid, case_uuid, title, purpose,
          method_group, order_index, status)
        VALUES ('wi-orphan', 'case-orphan', '孤', 'p', 'other', 0, 'planned');
        INSERT INTO t_case_participants (uuid, case_uuid, name, role)
        VALUES ('part-orphan', 'case-orphan', '孤', 'primarySeeker');
        INSERT INTO t_panel_refs (uuid, module, panel_uuid, panel_type, role)
        VALUES ('pr-orphan', 'liuyao', 'pX', 'yao', 'main');
        INSERT INTO t_work_item_panel_refs (uuid, work_item_uuid, panel_ref_uuid,
          role, order_index)
        VALUES ('wipr-orphan', 'wi-orphan', 'pr-orphan', 'main', 0);
        INSERT INTO t_creation_audit_logs (case_uuid, audited_at, change_type,
          entity_type)
        VALUES ('case-orphan', 1, 'create', 'case');
      ''');

      final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
      addTearDown(db.close);

      for (final tableName in [
        't_divination_cases',
        't_divination_work_items',
        't_case_participants',
        't_panel_refs',
        't_work_item_panel_refs',
        't_creation_audit_logs',
      ]) {
        final rows = await db.customSelect(
          'SELECT scope_uid FROM "$tableName"',
        ).get();
        expect(rows.single.read<String?>('scope_uid'), isNull,
            reason: '$tableName 孤儿行 scope_uid 应为 NULL');
      }
    });
  });

  group('写路径与 handover：案卷创建流 6 表随 scope 落位', () {
    late Directory blobBase;
    late Directory backupDir;
    late File dbFile;
    late PersistenceDriftDatabase db;
    late DriftScopeBootstrapStore bootstrapStore;
    late DriftScopeLedger ledger;

    setUp(() async {
      blobBase = await Directory.systemTemp.createTemp('sw1-t1-blob');
      backupDir = await Directory.systemTemp.createTemp('sw1-t1-backup');
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

    Future<List<String>> scopeUidForTable(String tableName) async {
      final rows = await db.customSelect(
        'SELECT scope_uid FROM "$tableName" ORDER BY rowid',
      ).get();
      return rows.map((r) => r.read<String>('scope_uid')).toList();
    }

    Future<void> createCaseUnderScopeA() async {
      final repo = repoFor('scope-a');
      await repo.saveCase(DivinationCaseModel(
        uuid: 'case-w1',
        title: '写路径案卷',
        mainQuestion: 'scope A 下建案卷',
        status: DivinationCaseStatus.open,
        createdAt: DateTime.utc(2026, 3, 1),
        updatedAt: DateTime.utc(2026, 3, 1),
      ));
      await repo.saveWorkItem(DivinationWorkItemModel(
        uuid: 'wi-w1',
        caseUuid: 'case-w1',
        title: '工作项',
        purpose: '占',
        methodGroup: DivinationMethodGroup.other,
        order: 0,
        status: DivinationWorkItemStatus.planned,
      ));
      await repo.saveParticipant(DivinationParticipantModel(
        uuid: 'part-w1',
        caseUuid: 'case-w1',
        name: '张三',
        role: DivinationParticipantRole.primarySeeker,
      ));
      await repo.savePanelRef(PanelRefModel(
        uuid: 'pr-w1',
        module: 'liuyao',
        panelUuid: 'p-w1',
        panelType: 'yao',
        role: PanelRefRole.main,
      ));
      await repo.attachPanelRefToWorkItem(WorkItemPanelRefModel(
        uuid: 'wipr-w1',
        workItemUuid: 'wi-w1',
        panelRefUuid: 'pr-w1',
        role: PanelRefRole.main,
        order: 0,
      ));
      await db.creationAuditLogsDao.insertAuditLog(
        caseUuid: 'case-w1',
        auditedAt: DateTime.utc(2026, 3, 1),
        changeType: 'create',
        entityType: 'case',
        scopeUid: 'scope-a',
      );
    }

    test('写路径：scope A 下建案卷 → 6 张表 scope 都是 A', () async {
      await createCaseUnderScopeA();

      expect(await scopeUidForTable('t_divination_cases'), ['scope-a']);
      expect(await scopeUidForTable('t_divination_work_items'), ['scope-a']);
      expect(await scopeUidForTable('t_case_participants'), ['scope-a']);
      expect(await scopeUidForTable('t_panel_refs'), ['scope-a']);
      expect(await scopeUidForTable('t_work_item_panel_refs'), ['scope-a']);
      expect(await scopeUidForTable('t_creation_audit_logs'), ['scope-a']);
      // 无任何行落 'default'
      for (final tableName in [
        't_divination_cases',
        't_divination_work_items',
        't_case_participants',
        't_panel_refs',
        't_work_item_panel_refs',
        't_creation_audit_logs',
      ]) {
        final rows = await db.customSelect(
          'SELECT scope_uid FROM "$tableName" WHERE scope_uid = \'default\'',
        ).get();
        expect(rows, isEmpty, reason: '$tableName 不应有 default 行');
      }
    });

    test('handover(A→B) 后 6 张表 scope 都变成 B', () async {
      await createCaseUnderScopeA();
      await runHandover('scope-a', 'scope-b');

      for (final tableName in [
        't_divination_cases',
        't_divination_work_items',
        't_case_participants',
        't_panel_refs',
        't_work_item_panel_refs',
        't_creation_audit_logs',
      ]) {
        final rows = await db.customSelect(
          'SELECT scope_uid FROM "$tableName"',
        ).get();
        expect(rows, isNotEmpty, reason: '$tableName 应有行');
        expect(
          rows.map((r) => r.read<String>('scope_uid')).toSet(),
          {'scope-b'},
          reason: '$tableName handover 后应全部为 scope-b',
        );
      }
    });
  });
}