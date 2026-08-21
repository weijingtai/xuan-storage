import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/taiyishenshu/taiyi_database.dart';
import 'package:persistence_drift/taiyishenshu/drift_user_repository.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:sqlite3/sqlite3.dart';

/// SW2：TaiYiDatabase schema v1 → v2 迁移与 DriftUserRepository 跨 scope 隔离测试
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaiYiDatabase v1 → v2 迁移与 DriftUserRepository 跨 scope 读写隔离测试', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('taiyi-migration-test-');
      dbFile = File('${tempDir.path}/taiyi_v1.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV1Schema(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 1;');
      sqliteDb.execute('''
        CREATE TABLE user_schools (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          source TEXT NOT NULL DEFAULT 'user',
          content_json TEXT NOT NULL
        );
        CREATE TABLE user_deities (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          source TEXT NOT NULL DEFAULT 'user',
          content_json TEXT NOT NULL
        );
      ''');
    }

    test('1. v1 升级到 v2 后 user_schools 与 user_deities 具备 scope_uid 列与索引', () async {
      final rawDb = sqlite3.open(dbFile.path);
      createV1Schema(rawDb);
      rawDb.dispose();

      final taiyiDb = TaiYiDatabase.withExecutor(NativeDatabase(dbFile));
      await taiyiDb.customSelect('SELECT 1').get();
      expect(taiyiDb.schemaVersion, equals(2));

      final schoolCols = await taiyiDb.customSelect('SELECT name FROM pragma_table_info("user_schools")').get();
      expect(schoolCols.any((r) => r.read<String>('name') == 'scope_uid'), isTrue);

      final deityCols = await taiyiDb.customSelect('SELECT name FROM pragma_table_info("user_deities")').get();
      expect(deityCols.any((r) => r.read<String>('name') == 'scope_uid'), isTrue);

      final indices = await taiyiDb.customSelect("SELECT name FROM sqlite_master WHERE type='index'").get();
      final indexNames = indices.map((r) => r.read<String>('name')).toSet();
      expect(indexNames, contains('idx_user_schools_scope'));
      expect(indexNames, contains('idx_user_deities_scope'));

      await taiyiDb.close();
    });

    test('2. (A5 & LK-C) DriftUserRepository 跨 scope 读写隔离测试', () async {
      final db = TaiYiDatabase.memory();
      addTearDown(db.close);

      final repoA = DriftUserRepository(db, scopeUid: 'scope-user-A');
      final repoB = DriftUserRepository(db, scopeUid: 'scope-user-B');

      const schoolA = TaiYiSchoolContract(
        id: 'school-A',
        name: 'School A',
        source: 'user',
        epoch: SchoolEpochConfigContract(
          ancientBase: 0,
          epochYear: 2026,
          correction: 10,
          tropicalYear: 365.2422,
        ),
        deityIds: ['taiYi'],
      );

      const deityA = DeityDefinitionContract(
        id: 'deity-A',
        name: 'Deity A',
        layer: 'tianPan',
        algorithm: DeityAlgorithmSpecContract(
          templateId: 'steppedCycle',
        ),
      );

      // Scope A 写入
      await repoA.saveSchool(schoolA);
      await repoA.saveDeity(deityA);

      // Scope A 读取：能读到自己的
      final schoolsA = await repoA.loadUserSchools();
      expect(schoolsA, hasLength(1));
      expect(schoolsA.first.id, equals('school-A'));
      expect(await repoA.loadSchool('school-A'), isNotNull);

      final deitiesA = await repoA.loadUserDeities();
      expect(deitiesA, hasLength(1));
      expect(deitiesA.first.id, equals('deity-A'));
      expect(await repoA.loadDeity('deity-A'), isNotNull);

      // Scope B 读取：读不到 Scope A 的自定义数据（LK-C 补 where + A5 核心断言）
      final schoolsB = await repoB.loadUserSchools();
      expect(schoolsB, isEmpty, reason: 'Scope B 绝不能读到 Scope A 的 user schools');
      expect(await repoB.loadSchool('school-A'), isNull, reason: 'loadSchool 必须做 scope 过滤');

      final deitiesB = await repoB.loadUserDeities();
      expect(deitiesB, isEmpty, reason: 'Scope B 绝不能读到 Scope A 的 user deities');
      expect(await repoB.loadDeity('deity-A'), isNull, reason: 'loadDeity 必须做 scope 过滤');

      // Scope B 尝试删除 Scope A 的数据：不能删
      await repoB.deleteSchool('school-A');
      expect(await repoA.loadSchool('school-A'), isNotNull, reason: 'Scope B 删除不应影响 Scope A 的 school');

      await repoB.deleteDeity('deity-A');
      expect(await repoA.loadDeity('deity-A'), isNotNull, reason: 'Scope B 删除不应影响 Scope A 的 deity');
    });
  });
}
