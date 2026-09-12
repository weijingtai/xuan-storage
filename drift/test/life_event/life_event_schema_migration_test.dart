// ACT-15A：LifeEventDatabase schema v1 冻结与迁移骨架测试。
//
// 验证五个契约：
// 1. schema 导出与代码一致性（SchemaVerifier + drift_schema_v1.json 28 表逐一匹配）。
// 2. v1 全新建库（onCreate 28 表全部建出、10 条索引全部存在、validateDatabaseSchema 通过）。
// 3. stepwise 迁移骨架可执行性（v1->v1 零变更、逐级 stepwise 调度与缺失抛错）。
// 4. 旧开发库拒绝静默使用（缺表时 beforeOpen 抛带 schemaMismatch 错误码的异常且零写入）。
// 5. 定向回归（外部测试套件维持全通）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/life_event/life_event_database.dart';
import 'package:persistence_drift/life_event/life_event_migrations.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'generated_migrations/schema.dart';

void main() {
  group('ACT-15A schema v1 freeze & migration skeleton', () {
    test('1. schema 导出与代码一致：drift_schema_v1.json 与当前表集 28 张表逐一匹配', () async {
      // 1a. 校验 drift_schema_v1.json 文件实体
      final schemaFile = File('drift_schemas/life_event/drift_schema_v1.json');
      expect(schemaFile.existsSync(), isTrue,
          reason: 'drift_schema_v1.json 必须作为冻结基线存在');

      final jsonContent =
          jsonDecode(schemaFile.readAsStringSync()) as Map<String, dynamic>;
      final entities = (jsonContent['entities'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .where((e) => e['type'] == 'table')
          .toList();

      expect(entities.length, 28,
          reason: 'ACT-15A 冻结导出必须恰好包含 28 张物理表');

      final exportedTableNames = entities
          .map((e) => (e['data'] as Map<String, dynamic>)['name'] as String)
          .toSet();

      for (final table in kLifeEventRequiredTables) {
        expect(exportedTableNames.contains(table), isTrue,
            reason: '导出文件中缺少表: $table');
      }

      // 1b. 校验代码中全部表的列集合与导出文件严格双向一致
      final columnsByTableInExport = <String, Set<String>>{
        for (final entity in entities)
          (entity['data'] as Map<String, dynamic>)['name'] as String:
              ((entity['data'] as Map<String, dynamic>)['columns']
                      as List<dynamic>)
                  .map((c) => (c as Map<String, dynamic>)['name'] as String)
                  .toSet(),
      };

      final memDb = LifeEventDatabase(NativeDatabase.memory());
      for (final table in memDb.allTables) {
        final expectedCols = columnsByTableInExport[table.actualTableName];
        expect(expectedCols, isNotNull,
            reason: '代码中表 ${table.actualTableName} 未在导出文件中声明');
        final actualCols = table.columnsByName.keys.toSet();
        expect(actualCols, equals(expectedCols),
            reason:
                '表 ${table.actualTableName} 代码列集与导出列集不一致。代码改动了表或列，必须重新执行 drift_dev schema dump 更新 drift_schema_v1.json');
      }
      await memDb.close();

      // 1c. 使用 SchemaVerifier 校验生成的 schema_v1 与真实数据库定义一致
      final verifier = SchemaVerifier(GeneratedHelper());
      final connection = await verifier.startAt(1);
      final db = LifeEventDatabase(connection);
      await verifier.migrateAndValidate(
        db,
        1,
        options: const ValidationOptions(validateDropped: true),
      );
      await db.close();
    });

    test('2. v1 全新建库：onCreate 建出 28 张表与全部 10 条索引，validateDatabaseSchema 通过', () async {
      final db = LifeEventDatabase(NativeDatabase.memory());

      // 触发开库并执行 onCreate / beforeOpen
      await db.customSelect('SELECT 1').get();

      // 验证 28 张表全部存在
      final tablesResult = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';",
      ).get();
      final tableNames = tablesResult.map((r) => r.read<String>('name')).toSet();
      expect(tableNames.length, 28);
      for (final table in kLifeEventRequiredTables) {
        expect(tableNames.contains(table), isTrue,
            reason: '新建库缺失必需表: $table');
      }

      // 验证全部 10 条自定义索引
      final indexResult = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name NOT LIKE 'sqlite_%';",
      ).get();
      final indexNames = indexResult.map((r) => r.read<String>('name')).toSet();

      for (final idx in kLifeEventExpectedIndexes) {
        expect(indexNames.contains(idx), isTrue,
            reason: '新建库缺失预期索引: $idx');
      }

      // ACT-06 复合索引与 unique 索引
      expect(indexNames.contains('idx_le_projection_owner'), isTrue);
      expect(indexNames.contains('idx_le_projection_type'), isTrue);
      expect(indexNames.contains('uq_le_receipt'), isTrue);

      // ACT-12 5 条索引
      expect(indexNames.contains('idx_le_reminder_schedule_due'), isTrue);
      expect(indexNames.contains('idx_le_reminder_delivery_schedule'), isTrue);
      expect(indexNames.contains('idx_le_reminder_definition_owner'), isTrue);
      expect(indexNames.contains('idx_le_reminder_channel_owner'), isTrue);
      expect(indexNames.contains('idx_le_reminder_aggregate_owner'), isTrue);

      // ACT-15 2 条索引
      expect(indexNames.contains('idx_le_external_event_query'), isTrue);
      expect(indexNames.contains('idx_le_external_event_subject'), isTrue);

      // SchemaVerifier.validateDatabaseSchema
      await db.validateDatabaseSchema();
      await db.close();
    });

    test('3. 迁移骨架可执行：stepwise 调度、v1->v1 零变更与缺失步骤抛错', () async {
      // 3a. SchemaVerifier 模拟 v1 -> v1 零变更迁移
      final verifier = SchemaVerifier(GeneratedHelper());
      final connection = await verifier.startAt(1);
      final db = LifeEventDatabase(connection);
      await verifier.migrateAndValidate(db, 1);
      await db.close();

      // 3b. 模拟 Migrator 调度测试
      var step1To2Executed = false;
      final testSteps = <int, LifeEventMigrationStep>{
        1: (m) async {
          step1To2Executed = true;
        },
      };

      // 从 1 到 1：无需迁移（0 步执行）
      final mockDb = LifeEventDatabase(NativeDatabase.memory());
      final migrator = Migrator(mockDb);
      await lifeEventStepwiseMigration(migrator, 1, 1, steps: testSteps);
      expect(step1To2Executed, isFalse);

      // 从 1 到 2：执行注册的 step
      await lifeEventStepwiseMigration(migrator, 1, 2, steps: testSteps);
      expect(step1To2Executed, isTrue);

      // 缺失 stepwise step 抛 StateError（Design §17.5 铁律）
      expect(
        () => lifeEventStepwiseMigration(migrator, 2, 3, steps: testSteps),
        throwsA(isA<StateError>()),
      );

      await mockDb.close();
    });

    test('4. 旧开发库拒绝静默使用：缺少 t_le_reminder_* 的库在 beforeOpen 抛出 schemaMismatch 且零写入', () async {
      final tmpDir = Directory.systemTemp.createTempSync('life-event-legacy-test-');
      final legacyFile = File('${tmpDir.path}/legacy_dev_v1.db');

      try {
        // 创建一个缺少 t_le_reminder_* 的开发库文件（模拟 ACT-12 前建的库）
        final rawDb = sql.sqlite3.open(legacyFile.path);
        rawDb.execute('PRAGMA user_version = 1;');
        // 仅建 ACT-06 的 9 张表
        for (final table in kLifeEventRequiredTables.take(9)) {
          rawDb.execute('CREATE TABLE $table (id TEXT PRIMARY KEY);');
        }
        final rawTablesBefore = rawDb
            .select("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';")
            .map((row) => row['name'] as String)
            .toSet();
        expect(rawTablesBefore.length, 9);
        expect(rawTablesBefore.any((t) => t.startsWith('t_le_reminder_')), isFalse);
        rawDb.dispose();

        // 尝试以 LifeEventDatabase 打开该旧库
        final db = LifeEventDatabase(NativeDatabase(legacyFile));

        expect(
          () => db.customSelect('SELECT 1').get(),
          throwsA(
            isA<LifeEventSchemaMismatchException>()
                .having((e) => e.code, 'code', 'schemaMismatch')
                .having(
                  (e) => e.missingTables,
                  'missingTables',
                  contains('t_le_reminder_definitions'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('schema mismatch'),
                ),
          ),
        );

        await db.close();

        // 验证零写入：重新用只读 sqlite 打开，确认依然只有原先的 9 张表，绝无新增表
        final rawVerify = sql.sqlite3.open(legacyFile.path);
        final rawTablesAfter = rawVerify
            .select("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';")
            .map((row) => row['name'] as String)
            .toSet();

        expect(rawTablesAfter.length, 9,
            reason: '开库失败前必须严格零写入，不得自动补建表');
        expect(rawTablesAfter.any((t) => t.startsWith('t_le_reminder_')), isFalse);
        rawVerify.dispose();
      } finally {
        try {
          tmpDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });
  });
}
