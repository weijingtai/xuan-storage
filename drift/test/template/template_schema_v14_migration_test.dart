import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Drift Schema v13 -> v14 Migration Contract (C1)', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('template-v14-migration-test-');
      dbFile = File('${tempDir.path}/test_v13.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV13SchemaWithData(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 13;');
      sqliteDb.execute('''
        CREATE TABLE t_outbox (
          operation_id TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          op_type TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          payload_summary TEXT,
          payload_hash TEXT,
          created_at_utc INTEGER NOT NULL,
          attempt INTEGER NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'pending',
          last_error_code TEXT,
          last_error_message TEXT,
          last_attempt_at_utc INTEGER,
          succeeded_at_utc INTEGER
        );

        CREATE TABLE t_record_meta (
          uuid TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          module TEXT NOT NULL,
          category TEXT NOT NULL,
          divination_type TEXT NOT NULL,
          seeker_uuid TEXT,
          case_uuid TEXT,
          work_item_uuid TEXT,
          created_at INTEGER NOT NULL,
          occurred_at_utc INTEGER NOT NULL,
          deleted_at INTEGER
        );

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

        CREATE TABLE t_im_message (
          message_id TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          conversation_id TEXT NOT NULL,
          sender_uid TEXT NOT NULL,
          content_type TEXT NOT NULL,
          payload_text TEXT NOT NULL,
          created_hlc_packed INTEGER NOT NULL,
          created_hlc_device_id TEXT NOT NULL,
          created_at_utc INTEGER NOT NULL,
          status TEXT NOT NULL,
          is_recalled INTEGER NOT NULL DEFAULT 0,
          acked_at_utc INTEGER,
          delivered_at_utc INTEGER
        );
      ''');

      // Populate pre-existing data into v13 database
      sqliteDb.execute('''
        INSERT INTO t_outbox (operation_id, scope_uid, entity_type, entity_id, op_type, payload_json, created_at_utc)
        VALUES ('op_v13_1', 'scope_alpha', 'case', 'case_1', 'CREATE', '{"v":13}', 1725400000000);

        INSERT INTO t_record_meta (uuid, scope_uid, module, category, divination_type, created_at, occurred_at_utc)
        VALUES ('rec_v13_1', 'scope_alpha', 'bazi', 'career', 'single', 1725400000000, 1725400000000);

        INSERT INTO t_divination_cases (uuid, scope_uid, title, main_question, status, created_at, updated_at)
        VALUES ('case_v13_1', 'scope_alpha', '测试案例13', '能否顺利升级到14？', 'active', 1725400000000, 1725400000000);

        INSERT INTO t_im_message (message_id, scope_uid, conversation_id, sender_uid, content_type, payload_text, created_hlc_packed, created_hlc_device_id, created_at_utc, status)
        VALUES ('msg_v13_1', 'scope_alpha', 'conv_1', 'u1', 'text', 'hello v13', 9999, 'dev1', 1725400000000, 'sent');
      ''');
    }

    test('C1: schema 13->14 迁移：两表建出、既有数据无损', () async {
      // 1. Setup real v13 database fixture
      final sqliteDb = sqlite3.open(dbFile.path);
      createV13SchemaWithData(sqliteDb);
      sqliteDb.dispose();

      // 2. Open via Drift and trigger onUpgrade (from 13 to 14)
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      expect(db.schemaVersion, 14);
      expect(db.schemaVersion, kPersistenceDriftSchemaVersion);

      // 3. Verify pre-existing data remained completely intact
      final outboxRows = await db.customSelect(
        'SELECT * FROM t_outbox WHERE operation_id = ?',
        variables: [const Variable('op_v13_1')],
      ).get();
      expect(outboxRows.length, 1);
      expect(outboxRows.first.read<String>('scope_uid'), 'scope_alpha');
      expect(outboxRows.first.read<String>('payload_json'), '{"v":13}');

      final recordRows = await db.customSelect(
        'SELECT * FROM t_record_meta WHERE uuid = ?',
        variables: [const Variable('rec_v13_1')],
      ).get();
      expect(recordRows.length, 1);
      expect(recordRows.first.read<String>('module'), 'bazi');

      final caseRows = await db.customSelect(
        'SELECT * FROM t_divination_cases WHERE uuid = ?',
        variables: [const Variable('case_v13_1')],
      ).get();
      expect(caseRows.length, 1);
      expect(caseRows.first.read<String>('title'), '测试案例13');

      final imRows = await db.customSelect(
        'SELECT * FROM t_im_message WHERE message_id = ?',
        variables: [const Variable('msg_v13_1')],
      ).get();
      expect(imRows.length, 1);
      expect(imRows.first.read<String>('payload_text'), 'hello v13');

      // 4. Verify both new tables exist in sqlite_master
      final tableNames = [
        't_divination_templates',
        't_template_usage_stats',
      ];
      for (final table in tableNames) {
        final res = await db.customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          variables: [Variable(table)],
        ).get();
        expect(res, isNotEmpty, reason: '表 $table 必须在 v14 迁移后建出');
      }

      // 5. Verify columns of t_divination_templates
      final templateCols = (await db.customSelect(
        'SELECT name FROM pragma_table_info("t_divination_templates")',
      ).get()).map((r) => r.read<String>('name')).toSet();
      expect(
        templateCols,
        containsAll([
          'uuid',
          'scope_uid',
          'template_id',
          'name',
          'category',
          'origin',
          'derived_from',
          'version',
          'definition_json',
          'created_at',
          'updated_at',
          'deleted_at',
        ]),
      );

      // 6. Verify columns of t_template_usage_stats
      final statsCols = (await db.customSelect(
        'SELECT name FROM pragma_table_info("t_template_usage_stats")',
      ).get()).map((r) => r.read<String>('name')).toSet();
      expect(
        statsCols,
        containsAll([
          'template_uuid',
          'scope_uid',
          'use_count',
          'last_used_at',
        ]),
      );

      // 7. Verify indices created
      final idxTemplates = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_divination_templates_scope'",
      ).get();
      expect(idxTemplates, isNotEmpty, reason: 'idx_divination_templates_scope 必须存在');

      final idxStats = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_template_usage_stats_scope'",
      ).get();
      expect(idxStats, isNotEmpty, reason: 'idx_template_usage_stats_scope 必须存在');

      // 8. Verify write and read operations work on migrated database
      final now = DateTime.utc(2026, 9, 4, 12, 0, 0);
      await db.into(db.divinationTemplates).insert(
        DivinationTemplatesCompanion.insert(
          uuid: 'tpl_migrated_1',
          scopeUid: 'scope_alpha',
          templateId: 'user-custom-1',
          name: '自定义测试模板',
          category: '运势',
          origin: 'user',
          version: 1,
          definitionJson: '{"id":"user-custom-1"}',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.into(db.templateUsageStats).insert(
        TemplateUsageStatsCompanion.insert(
          templateUuid: 'tpl_migrated_1',
          scopeUid: 'scope_alpha',
          useCount: const Value(3),
          lastUsedAt: now,
        ),
      );

      final insertedTpl = await (db.select(db.divinationTemplates)
            ..where((t) => t.uuid.equals('tpl_migrated_1')))
          .getSingle();
      expect(insertedTpl.name, '自定义测试模板');
      expect(insertedTpl.origin, 'user');
      expect(insertedTpl.scopeUid, 'scope_alpha');

      final insertedStats = await (db.select(db.templateUsageStats)
            ..where((t) => t.templateUuid.equals('tpl_migrated_1')))
          .getSingle();
      expect(insertedStats.useCount, 3);
      expect(insertedStats.lastUsedAt.toUtc(), now);

      await db.close();
    });
  });
}
