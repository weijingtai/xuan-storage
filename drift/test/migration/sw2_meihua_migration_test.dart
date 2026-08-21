import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/meihuayishu/meihua_database.dart';
import 'package:persistence_drift/meihuayishu/drift_meihua_divination_record_repository.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:sqlite3/sqlite3.dart';

/// SW2：MeiHuaDatabase schema v1 → v2 迁移与 MeiHuaGuaInfos 跨 scope 隔离测试
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeiHuaDatabase v1 → v2 迁移与跨 scope 读写隔离测试', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('meihua-migration-test-');
      dbFile = File('${tempDir.path}/meihua_v1.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV1Schema(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 1;');
      sqliteDb.execute('''
        CREATE TABLE t_meihua_gua_info (
          uuid TEXT NOT NULL PRIMARY KEY,
          divination_uuid TEXT NOT NULL,
          question TEXT,
          original_upper_gua INTEGER NOT NULL,
          original_lower_gua INTEGER NOT NULL,
          changing_yao INTEGER NOT NULL,
          changed_upper_gua INTEGER NOT NULL,
          changed_lower_gua INTEGER NOT NULL,
          hu_upper_gua INTEGER NOT NULL,
          hu_lower_gua INTEGER NOT NULL,
          method TEXT NOT NULL,
          params_json TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');
    }

    test('1. v1 升级到 v2 后具备 scope_uid 列与索引', () async {
      final rawDb = sqlite3.open(dbFile.path);
      createV1Schema(rawDb);
      rawDb.dispose();

      final db = MeiHuaDatabase(NativeDatabase(dbFile));
      expect(db.schemaVersion, equals(2));

      final cols = await db.customSelect('SELECT name FROM pragma_table_info("t_meihua_gua_info")').get();
      expect(
        cols.any((r) => r.read<String>('name') == 'scope_uid'),
        isTrue,
        reason: 't_meihua_gua_info 必须包含 scope_uid 列',
      );

      final indices = await db.customSelect("SELECT name FROM sqlite_master WHERE type='index'").get();
      final indexNames = indices.map((r) => r.read<String>('name')).toSet();
      expect(indexNames, contains('idx_meihua_gua_info_scope'));

      await db.close();
    });

    test('2. (A5) 梅花 DAO 与 Repository 跨 scope 读写隔离测试', () async {
      final db = MeiHuaDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final repoA = DriftMeiHuaDivinationRecordRepository(db, scopeUid: 'scope-user-A');
      final repoB = DriftMeiHuaDivinationRecordRepository(db, scopeUid: 'scope-user-B');

      final now = DateTime.now();
      final recordA = MeiHuaDivinationRecordContract(
        uuid: 'm-rec-A',
        divinationUuid: 'div-A',
        question: 'Question A',
        originalUpperGua: 1,
        originalLowerGua: 2,
        changingYao: 3,
        changedUpperGua: 4,
        changedLowerGua: 5,
        huUpperGua: 6,
        huLowerGua: 7,
        method: 'time',
        paramsJson: '{}',
        createdAt: now,
        updatedAt: now,
      );

      // Scope A 写入
      final savedUuid = await repoA.saveRecord(recordA);
      expect(savedUuid, equals('m-rec-A'));

      // Scope A 读：能读到
      final listA = await repoA.getAllRecords();
      expect(listA, hasLength(1));
      expect(listA.first.uuid, equals('m-rec-A'));
      expect(await repoA.getRecordByUuid('m-rec-A'), isNotNull);
      expect(await repoA.getRecordByDivinationUuid('div-A'), isNotNull);

      // Scope B 读：读不到（A5 断言）
      final listB = await repoB.getAllRecords();
      expect(listB, isEmpty, reason: 'Scope B 绝不应该读到 Scope A 的梅花记录');
      expect(await repoB.getRecordByUuid('m-rec-A'), isNull, reason: 'getRecordByUuid 必须做 scope 隔离');
      expect(await repoB.getRecordByDivinationUuid('div-A'), isNull, reason: 'getRecordByDivinationUuid 必须做 scope 隔离');
    });
  });
}
