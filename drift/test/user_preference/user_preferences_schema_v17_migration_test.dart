import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('K9: Drift Schema v16 -> v17 Migration (t_user_preferences)', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp
          .createTemp('user-preferences-v17-migration-test-');
      dbFile = File('${tempDir.path}/test_v16.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV16SchemaWithData(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 16;');
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

        CREATE TABLE t_case_judgements (
          uuid TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          case_uuid TEXT NOT NULL,
          work_item_uuid TEXT,
          technique_id TEXT,
          module TEXT,
          text TEXT NOT NULL,
          detail_text TEXT,
          indicator_label TEXT,
          pattern_label TEXT,
          status TEXT NOT NULL,
          key_basis TEXT,
          attached_to_kind TEXT,
          order_index INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');

      // 插入 v16 既有数据
      sqliteDb.execute('''
        INSERT INTO t_divination_cases (uuid, scope_uid, title, main_question, status, created_at, updated_at)
        VALUES ('case_16_1', 'scope_test', '测试案例16', '升级验证', 'open', 1725500000000, 1725500000000);

        INSERT INTO t_case_judgements (uuid, scope_uid, case_uuid, text, status, order_index, created_at, updated_at)
        VALUES ('j_16_1', 'scope_test', 'case_16_1', '测试断语', 'confirmed', 0, 1725500000000, 1725500000000);
      ''');
    }

    test('schema 16 升 17：既有数据条数不变、t_user_preferences 表与索引创建成功且可写 (K9)', () async {
      // 1. 设置真实的 v16 数据库 fixture
      final sqliteDb = sqlite3.open(dbFile.path);
      createV16SchemaWithData(sqliteDb);
      sqliteDb.dispose();

      // 2. 使用 Drift 打开并触发 onUpgrade（from 16 to 17）
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      expect(db.schemaVersion, 17);
      expect(db.schemaVersion, kPersistenceDriftSchemaVersion);

      // 3. 验证 t_user_preferences 表结构与列
      final columns = (await db.customSelect(
        'SELECT name FROM pragma_table_info("t_user_preferences")',
      ).get()).map((r) => r.read<String>('name')).toSet();

      final expectedColumns = {
        'scope_uid',
        'key',
        'value',
        'updated_at',
      };

      for (final col in expectedColumns) {
        expect(
          columns.contains(col),
          isTrue,
          reason: 't_user_preferences 必须包含列 $col',
        );
      }

      // 4. 验证索引存在
      final indexRows = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 't_user_preferences'",
      ).get();
      final indexNames = indexRows.map((r) => r.read<String>('name')).toSet();
      expect(
        indexNames,
        contains('idx_user_preferences_scope'),
        reason: '索引 idx_user_preferences_scope 必须创建',
      );

      // 5. 验证既有数据不受影响（既有数据条数不变）
      final cases = await db.select(db.divinationCases).get();
      expect(cases.length, 1);
      expect(cases.single.uuid, 'case_16_1');

      final judgements = await db.select(db.caseJudgements).get();
      expect(judgements.length, 1);
      expect(judgements.single.uuid, 'j_16_1');

      // 6. 验证新表可写与偏好读写 (DriftUserPreferenceStore)
      final store = DriftUserPreferenceStore(db);

      // 写入 scope-A 偏好
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'history_view_mode',
        value: 'split',
      );

      // 写入 scope-B 偏好
      await store.setPreference(
        scopeUid: 'scope-B',
        key: 'history_view_mode',
        value: 'combined',
      );

      // 读回并断言 scope 隔离
      final prefA = await store.getPreference(
        scopeUid: 'scope-A',
        key: 'history_view_mode',
      );
      final prefB = await store.getPreference(
        scopeUid: 'scope-B',
        key: 'history_view_mode',
      );
      expect(prefA, 'split');
      expect(prefB, 'combined');

      // 更新测试 (Upsert)
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'history_view_mode',
        value: 'combined',
      );
      final prefAUpdated = await store.getPreference(
        scopeUid: 'scope-A',
        key: 'history_view_mode',
      );
      expect(prefAUpdated, 'combined');

      // getAllPreferences
      await store.setPreference(
        scopeUid: 'scope-A',
        key: 'another_key',
        value: '123',
      );
      final allA = await store.getAllPreferences(scopeUid: 'scope-A');
      expect(allA, {'history_view_mode': 'combined', 'another_key': '123'});

      // removePreference
      await store.removePreference(scopeUid: 'scope-A', key: 'another_key');
      final allAAfterRemove = await store.getAllPreferences(scopeUid: 'scope-A');
      expect(allAAfterRemove, {'history_view_mode': 'combined'});

      await db.close();
    });
  });
}
