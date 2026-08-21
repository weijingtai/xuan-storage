import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

/// SW2 / LK-B Down 方案自动化回退验证测试
///
/// 验证 4 步 Down 机制：
/// 1. 迁移前记录全库行数与全表数据 SHA-256 哈希
/// 2. 执行物理备份：<db>.pre_v12.bak
/// 3. 执行 v11 → v12 迁移（添加 scope_uid 等列）
/// 4. 模拟回退：用备份文件覆盖回去，再次比对全库行数与全表哈希，验证逐字节一致
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Scope Migration Rollback (Down 方案) 自动化验证', () {
    late Directory tempDir;
    late File dbFile;
    late File backupFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('rollback-test-');
      dbFile = File('${tempDir.path}/persistence_v11.sqlite');
      backupFile = File('${tempDir.path}/persistence_v11.sqlite.pre_v12.bak');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    /// 计算 SQLite 数据库所有表的数据指纹（行数 + 内容 SHA256）
    Map<String, String> computeDatabaseFingerprint(File file) {
      final db = sqlite3.open(file.path);
      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      final fingerprint = <String, String>{};
      for (final row in tables) {
        final tableName = row['name'] as String;
        final rows = db.select('SELECT * FROM "$tableName"');
        final count = rows.length;
        final buffer = StringBuffer();
        for (final r in rows) {
          buffer.write(r.values.toString());
        }
        final hash = sha256.convert(utf8.encode(buffer.toString())).toString();
        fingerprint[tableName] = 'count:$count;sha256:$hash';
      }
      db.dispose();
      return fingerprint;
    }

    test('物理备份与回退：升级后回退覆盖，全表内容与哈希完全一致', () async {
      // 1. 造一个 v11 数据库并写入真实数据（包含 t_timing_divinations, t_seekers, t_skill_classes）
      final rawDb = sqlite3.open(dbFile.path);
      rawDb.execute('PRAGMA user_version = 11;');
      rawDb.execute('''
        CREATE TABLE t_timing_divinations (
          uuid TEXT NOT NULL PRIMARY KEY,
          created_at INTEGER NOT NULL,
          last_updated_at INTEGER,
          deleted_at INTEGER,
          divination_uuid TEXT NOT NULL,
          timing_type INTEGER NOT NULL,
          datetime INTEGER NOT NULL,
          is_manual INTEGER NOT NULL DEFAULT 0,
          year_gan_zhi INTEGER NOT NULL,
          month_gan_zhi INTEGER NOT NULL,
          day_gan_zhi INTEGER NOT NULL,
          time_gan_zhi INTEGER NOT NULL,
          lunar_month INTEGER NOT NULL,
          is_leap_month INTEGER NOT NULL DEFAULT 0,
          lunar_day INTEGER NOT NULL,
          timing_info_uuid TEXT NOT NULL,
          location_json TEXT,
          info_list_json TEXT,
          current_calendar_uuid TEXT
        );
        CREATE TABLE t_seekers (
          uuid TEXT NOT NULL PRIMARY KEY,
          username TEXT,
          nickname TEXT,
          gender TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          last_updated_at INTEGER,
          deleted_at INTEGER,
          timing_type INTEGER NOT NULL,
          datetime INTEGER NOT NULL,
          year_gan_zhi INTEGER NOT NULL,
          month_gan_zhi INTEGER NOT NULL,
          day_gan_zhi INTEGER NOT NULL,
          time_gan_zhi INTEGER NOT NULL,
          lunar_month INTEGER NOT NULL,
          is_leap_month INTEGER NOT NULL DEFAULT 0,
          lunar_day INTEGER NOT NULL,
          divination_uuid TEXT NOT NULL,
          timing_info_uuid TEXT,
          info_list_json TEXT,
          location_json TEXT,
          current_calendar_uuid TEXT
        );
        CREATE TABLE t_skill_classes (
          uuid TEXT NOT NULL PRIMARY KEY,
          created_at INTEGER NOT NULL,
          last_updated_at INTEGER NOT NULL,
          deleted_at INTEGER,
          skill_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          specification TEXT NOT NULL,
          feature TEXT NOT NULL,
          is_customized INTEGER NOT NULL
        );
        CREATE TABLE t_record_meta (
          uuid TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          module TEXT NOT NULL,
          category TEXT NOT NULL,
          divination_type TEXT NOT NULL,
          question TEXT,
          module_data_json TEXT,
          nav_params_json TEXT,
          occurred_at_utc INTEGER,
          reckoning_type TEXT,
          timezone_str TEXT,
          latitude REAL,
          longitude REAL,
          location_name TEXT,
          spacetime_json TEXT,
          gender TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER,
          rev INTEGER NOT NULL DEFAULT 1
        );
      ''');

      // 插入测试数据
      rawDb.execute('''
        INSERT INTO t_timing_divinations (
          uuid, created_at, divination_uuid, timing_type, datetime,
          year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi,
          lunar_month, lunar_day, timing_info_uuid
        ) VALUES (
          't1', 1700000000, 'rec-1', 1, 1700000000,
          0, 0, 0, 0, 1, 1, 'info-1'
        );
        INSERT INTO t_seekers (
          uuid, gender, created_at, timing_type, datetime,
          year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi,
          lunar_month, lunar_day, divination_uuid
        ) VALUES (
          's1', 'MALE', 1700000000, 1, 1700000000,
          0, 0, 0, 0, 1, 1, 'rec-1'
        );
        INSERT INTO t_skill_classes (
          uuid, created_at, last_updated_at, skill_id, name, specification, feature, is_customized
        ) VALUES (
          'sk1', 1700000000, 1700000000, 1, 'Class1', 'Spec1', 'Feat1', 0
        );
        INSERT INTO t_record_meta (
          uuid, scope_uid, module, category, divination_type, created_at, updated_at
        ) VALUES (
          'rec-1', 'scope-alpha', 'timing', 'divination', 'timing', 1700000000, 1700000000
        );
      ''');
      rawDb.dispose();

      // 记录迁移前的全库指纹
      final preFingerprint = computeDatabaseFingerprint(dbFile);
      expect(preFingerprint['t_timing_divinations'], contains('count:1'));
      expect(preFingerprint['t_seekers'], contains('count:1'));
      expect(preFingerprint['t_skill_classes'], contains('count:1'));

      // 2. 物理备份：复制为 .pre_v12.bak
      dbFile.copySync(backupFile.path);
      expect(backupFile.existsSync(), isTrue);

      // 3. 执行升级：使用 PersistenceDriftDatabase 打开触发 onUpgrade (v11 → v12)
      final upgradedDb = PersistenceDriftDatabase(NativeDatabase(dbFile));
      // 触发打开并完成迁移
      final timingCols = await upgradedDb.customSelect('SELECT name FROM pragma_table_info("t_timing_divinations")').get();
      expect(timingCols.any((r) => r.read<String>('name') == 'scope_uid'), isTrue, reason: '升级后必须有 scope_uid 列');
      final seekerCols = await upgradedDb.customSelect('SELECT name FROM pragma_table_info("t_seekers")').get();
      expect(seekerCols.any((r) => r.read<String>('name') == 'scope_uid'), isTrue, reason: '升级后必须有 scope_uid 列');
      final skillCols = await upgradedDb.customSelect('SELECT name FROM pragma_table_info("t_skill_classes")').get();
      expect(skillCols.any((r) => r.read<String>('name') == 'scope_uid'), isTrue, reason: '升级后必须有 scope_uid 列');

      // 验证回填：t1 的 scope_uid 应该被回填为 scope-alpha
      final timingRow = await upgradedDb.customSelect('SELECT scope_uid FROM t_timing_divinations WHERE uuid = ?', variables: [Variable.withString('t1')]).getSingle();
      expect(timingRow.read<String?>('scope_uid'), equals('scope-alpha'));

      await upgradedDb.close();

      // 4. 执行回退动作：覆盖回备份文件
      backupFile.copySync(dbFile.path);

      // 5. 验证回退后的全库指纹与迁移前完全一致
      final postRollbackFingerprint = computeDatabaseFingerprint(dbFile);
      expect(postRollbackFingerprint, equals(preFingerprint), reason: '回退后的全库各表行数与内容哈希必须与迁移前逐字节一致');

      // 再次打开验证 schema 确实回到了 v11
      final rawPostDb = sqlite3.open(dbFile.path);
      final userVersion = rawPostDb.userVersion;
      expect(userVersion, equals(11), reason: '回退后版本号必须恢复为 11');
      final rollbackCols = rawPostDb.select('SELECT name FROM pragma_table_info("t_timing_divinations")');
      expect(rollbackCols.any((r) => r['name'] == 'scope_uid'), isFalse, reason: '回退后不应有 scope_uid 列');
      rawPostDb.dispose();
    });
  });
}
