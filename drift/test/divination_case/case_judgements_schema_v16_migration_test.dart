import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T1: Drift Schema v15 -> v16 Migration (t_case_judgements)', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp
          .createTemp('case-judgements-v16-migration-test-');
      dbFile = File('${tempDir.path}/test_v15.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV15SchemaWithData(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 15;');
      sqliteDb.execute('''
        CREATE TABLE t_divination_cases (
          uuid TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT,
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
          scope_uid TEXT,
          case_uuid TEXT NOT NULL,
          parent_work_item_uuid TEXT,
          title TEXT NOT NULL,
          purpose TEXT NOT NULL,
          method_group TEXT NOT NULL,
          order_index INTEGER NOT NULL,
          status TEXT NOT NULL,
          summary TEXT,
          conclusion TEXT,
          extras_json TEXT
        );
      ''');

      // Populate pre-existing data into v15 database
      sqliteDb.execute('''
        INSERT INTO t_divination_cases (uuid, scope_uid, title, main_question, status, created_at, updated_at)
        VALUES ('case_15_1', 'scope_test', '测试案例15', '升级验证', 'open', 1725500000000, 1725500000000);

        INSERT INTO t_divination_work_items (uuid, scope_uid, case_uuid, parent_work_item_uuid, title, purpose, method_group, order_index, status, summary, conclusion, extras_json)
        VALUES ('item_1', 'scope_test', 'case_15_1', NULL, '事项一', '目的1', 'lifePattern', 1, 'completed', '总结1', '结论1', '{"key":"val"}');
      ''');
    }

    test('schema 15 升 16：既有数据条数不变、t_case_judgements 表与索引创建成功且可写', () async {
      // 1. Setup real v15 database fixture
      final sqliteDb = sqlite3.open(dbFile.path);
      createV15SchemaWithData(sqliteDb);
      sqliteDb.dispose();

      // 2. Open via Drift and trigger onUpgrade (from 15 to 16)
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      expect(db.schemaVersion, 16);
      expect(db.schemaVersion, kPersistenceDriftSchemaVersion);

      // 3. Verify t_case_judgements exists and columns match
      final columns = (await db.customSelect(
        'SELECT name FROM pragma_table_info("t_case_judgements")',
      ).get()).map((r) => r.read<String>('name')).toSet();

      final expectedColumns = {
        'uuid',
        'scope_uid',
        'case_uuid',
        'work_item_uuid',
        'technique_id',
        'module',
        'text',
        'detail_text',
        'indicator_label',
        'pattern_label',
        'status',
        'key_basis',
        'attached_to_kind',
        'order_index',
        'created_at',
        'updated_at',
        'deleted_at',
      };

      for (final col in expectedColumns) {
        expect(
          columns.contains(col),
          isTrue,
          reason: 't_case_judgements 必须包含列 $col',
        );
      }

      // 4. Verify indices exist
      final indexRows = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 't_case_judgements'",
      ).get();
      final indexNames = indexRows.map((r) => r.read<String>('name')).toSet();
      expect(
        indexNames,
        contains('idx_case_judgements_scope_case'),
        reason: '索引 idx_case_judgements_scope_case 必须创建',
      );
      expect(
        indexNames,
        contains('idx_case_judgements_work_item'),
        reason: '索引 idx_case_judgements_work_item 必须创建',
      );

      // 5. Verify pre-existing data is intact
      final cases = await db.select(db.divinationCases).get();
      expect(cases.length, 1);
      expect(cases.single.uuid, 'case_15_1');

      final workItems = await db.select(db.divinationWorkItems).get();
      expect(workItems.length, 1);
      expect(workItems.single.uuid, 'item_1');

      // 6. Verify writing a new judgement to the new table
      final now = DateTime.utc(2026, 9, 7, 12, 0, 0);
      await db.into(db.caseJudgements).insert(
        CaseJudgementsCompanion.insert(
          uuid: 'j_new_1',
          scopeUid: 'scope_test',
          caseUuid: 'case_15_1',
          workItemUuid: const Value('item_1'),
          techniqueId: const Value('tech_1'),
          module: const Value('bazi'),
          judgementText: '婚姻美满',
          detailText: const Value('配偶宫合相'),
          indicatorLabel: const Value('吉'),
          patternLabel: const Value('日禄归时'),
          status: 'confirmed',
          keyBasis: const Value('日支合月支'),
          attachedToKind: const Value('stage'),
          orderIndex: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final inserted = await (db.select(db.caseJudgements)
            ..where((t) => t.uuid.equals('j_new_1')))
          .getSingle();
      expect(inserted.uuid, 'j_new_1');
      expect(inserted.judgementText, '婚姻美满');
      expect(inserted.scopeUid, 'scope_test');
      expect(inserted.caseUuid, 'case_15_1');
      expect(inserted.workItemUuid, 'item_1');
      expect(inserted.techniqueId, 'tech_1');
      expect(inserted.module, 'bazi');
      expect(inserted.indicatorLabel, '吉');
      expect(inserted.patternLabel, '日禄归时');
      expect(inserted.status, 'confirmed');
      expect(inserted.keyBasis, '日支合月支');
      expect(inserted.attachedToKind, 'stage');
      expect(inserted.orderIndex, 0);

      await db.close();
    });
  });
}
