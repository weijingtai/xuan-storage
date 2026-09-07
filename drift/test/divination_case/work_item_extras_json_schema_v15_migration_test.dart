import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T7: Drift Schema v14 -> v15 Migration (WorkItem extrasJson)', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('workitem-v15-migration-test-');
      dbFile = File('${tempDir.path}/test_v14.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV14SchemaWithData(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 14;');
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
          conclusion TEXT
        );
      ''');

      // Populate 3 pre-existing work items into v14 database
      sqliteDb.execute('''
        INSERT INTO t_divination_cases (uuid, scope_uid, title, main_question, status, created_at, updated_at)
        VALUES ('case_14_1', 'scope_test', '测试案例14', '升级验证', 'open', 1725400000000, 1725400000000);

        INSERT INTO t_divination_work_items (uuid, scope_uid, case_uuid, parent_work_item_uuid, title, purpose, method_group, order_index, status, summary, conclusion)
        VALUES ('item_1', 'scope_test', 'case_14_1', NULL, '事项一', '目的1', 'lifePattern', 1, 'completed', '总结1', '结论1');

        INSERT INTO t_divination_work_items (uuid, scope_uid, case_uuid, parent_work_item_uuid, title, purpose, method_group, order_index, status, summary, conclusion)
        VALUES ('item_2', 'scope_test', 'case_14_1', 'item_1', '事项二', '目的2', 'eventDivination', 2, 'inProgress', NULL, NULL);

        INSERT INTO t_divination_work_items (uuid, scope_uid, case_uuid, parent_work_item_uuid, title, purpose, method_group, order_index, status, summary, conclusion)
        VALUES ('item_3', 'scope_test', 'case_14_1', 'item_1', '事项三', '目的3', 'strategy', 3, 'planned', NULL, NULL);
      ''');
    }

    test('schema 14 库升 15：既有 work item 条数不变、extras_json 为 NULL', () async {
      // 1. Setup real v14 database fixture
      final sqliteDb = sqlite3.open(dbFile.path);
      createV14SchemaWithData(sqliteDb);
      sqliteDb.dispose();

      // 2. Open via Drift and trigger onUpgrade (from 14 to latest schema)
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      expect(db.schemaVersion, kPersistenceDriftSchemaVersion);

      // 3. Verify t_divination_work_items has the new column
      final workItemCols = (await db.customSelect(
        'SELECT name FROM pragma_table_info("t_divination_work_items")',
      ).get()).map((r) => r.read<String>('name')).toSet();
      expect(
        workItemCols,
        contains('extras_json'),
        reason: 't_divination_work_items 必须在 v15 迁移后包含 extras_json 列',
      );

      // 4. Verify 3 pre-existing items: count intact, all extras_json are NULL
      final items = await (db.select(db.divinationWorkItems)
            ..orderBy([(t) => OrderingTerm.asc(t.order)]))
          .get();
      expect(items.length, 3, reason: '既有 3 条 work item 一条不少');

      expect(items[0].uuid, 'item_1');
      expect(items[0].title, '事项一');
      expect(items[0].extrasJson, isNull, reason: '历史数据的 extras_json 必须为 NULL');

      expect(items[1].uuid, 'item_2');
      expect(items[1].parentWorkItemUuid, 'item_1');
      expect(items[1].extrasJson, isNull, reason: '历史数据的 extras_json 必须为 NULL');

      expect(items[2].uuid, 'item_3');
      expect(items[2].extrasJson, isNull, reason: '历史数据的 extras_json 必须为 NULL');

      // 5. Verify writing a new item with extrasJson works
      await db.into(db.divinationWorkItems).insert(
        DivinationWorkItemsCompanion.insert(
          uuid: 'item_new_4',
          scopeUid: const Value('scope_test'),
          caseUuid: 'case_14_1',
          title: '事项四（含溯源）',
          purpose: '目的4',
          methodGroup: 'lifePattern',
          order: 4,
          status: 'planned',
          extrasJson: const Value('{"stageKey":"marriageMatch"}'),
        ),
      );

      final newItem = await (db.select(db.divinationWorkItems)
            ..where((t) => t.uuid.equals('item_new_4')))
          .getSingle();
      expect(newItem.extrasJson, '{"stageKey":"marriageMatch"}');

      await db.close();
    });
  });
}
