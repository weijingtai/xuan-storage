import 'dart:io';

import 'package:enumeration/enums.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

/// SW2：TimingDivinations / Seekers / SkillClasses 3 表 scope_uid 迁移与隔离测试
///
/// 覆盖：
/// 1. schema v11 升级到 v12 后 3 张表都有 scope_uid 列与索引
/// 2. 回填正确性：反查 t_record_meta 传递 scope_uid
/// 3. 孤儿行保持 NULL，不误填默认值
/// 4. TimingDivinationsDao / SeekersDao / SkillClassesDao 读写带 scope 隔离
/// 5. 跨 scope 隔离（A5）：scope A 写入的数据，scope B 读不到
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('schema v11 → v12 迁移及 DAOs 跨 scope 隔离测试', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sw2-migration-test-');
      dbFile = File('${tempDir.path}/test_v11.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV11Schema(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 11;');
      sqliteDb.execute('''
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
          seeker_uuid TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');
    }

    test('1. 升级后 3 张表均含 scope_uid 列与索引', () async {
      final rawDb = sqlite3.open(dbFile.path);
      createV11Schema(rawDb);
      rawDb.dispose();

      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      expect(db.schemaVersion, equals(12));

      // 验证列已添加
      for (final table in ['t_timing_divinations', 't_seekers', 't_skill_classes']) {
        final cols = await db.customSelect('SELECT name FROM pragma_table_info("$table")').get();
        expect(
          cols.any((r) => r.read<String>('name') == 'scope_uid'),
          isTrue,
          reason: '$table 必须含有 scope_uid 列',
        );
      }

      // 验证索引已创建
      final indices = await db.customSelect("SELECT name FROM sqlite_master WHERE type='index'").get();
      final indexNames = indices.map((r) => r.read<String>('name')).toSet();
      expect(indexNames, contains('idx_timing_divinations_scope'));
      expect(indexNames, contains('idx_seekers_scope'));
      expect(indexNames, contains('idx_skill_classes_scope'));

      await db.close();
    });

    test('2. 回填正确性与孤儿行保持 NULL', () async {
      final rawDb = sqlite3.open(dbFile.path);
      createV11Schema(rawDb);

      // t_record_meta 绑定 scope-1 与 scope-2
      rawDb.execute('''
        INSERT INTO t_record_meta (uuid, scope_uid, module, category, divination_type, seeker_uuid, created_at, updated_at)
        VALUES ('div-1', 'scope-1', 'timing', 'divination', 'timing', 'seeker-1', 1000, 1000);
        INSERT INTO t_record_meta (uuid, scope_uid, module, category, divination_type, seeker_uuid, created_at, updated_at)
        VALUES ('div-2', 'scope-2', 'timing', 'divination', 'timing', 'seeker-2', 2000, 2000);

        -- timing 关联 div-1, div-2 和孤儿 div-orphan
        INSERT INTO t_timing_divinations (uuid, created_at, divination_uuid, timing_type, datetime, year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, lunar_month, lunar_day, timing_info_uuid)
        VALUES ('t-1', 1000, 'div-1', 1, 1000, 0, 0, 0, 0, 1, 1, 'info-1');
        INSERT INTO t_timing_divinations (uuid, created_at, divination_uuid, timing_type, datetime, year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, lunar_month, lunar_day, timing_info_uuid)
        VALUES ('t-2', 2000, 'div-2', 1, 2000, 0, 0, 0, 0, 1, 1, 'info-2');
        INSERT INTO t_timing_divinations (uuid, created_at, divination_uuid, timing_type, datetime, year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, lunar_month, lunar_day, timing_info_uuid)
        VALUES ('t-orphan', 3000, 'div-orphan', 1, 3000, 0, 0, 0, 0, 1, 1, 'info-3');

        -- seekers 关联 seeker-1, seeker-2 和孤儿 seeker-orphan
        INSERT INTO t_seekers (uuid, gender, created_at, timing_type, datetime, year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, lunar_month, lunar_day, divination_uuid)
        VALUES ('seeker-1', 'MALE', 1000, 1, 1000, 0, 0, 0, 0, 1, 1, 'div-1');
        INSERT INTO t_seekers (uuid, gender, created_at, timing_type, datetime, year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, lunar_month, lunar_day, divination_uuid)
        VALUES ('seeker-2', 'FEMALE', 2000, 1, 2000, 0, 0, 0, 0, 1, 1, 'div-2');
        INSERT INTO t_seekers (uuid, gender, created_at, timing_type, datetime, year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, lunar_month, lunar_day, divination_uuid)
        VALUES ('seeker-orphan', 'FEMALE', 3000, 1, 3000, 0, 0, 0, 0, 1, 1, 'div-orphan');
      ''');
      rawDb.dispose();

      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));

      // 验证 timing 回填
      final t1 = await db.customSelect('SELECT scope_uid FROM t_timing_divinations WHERE uuid = "t-1"').getSingle();
      expect(t1.read<String?>('scope_uid'), equals('scope-1'));
      final t2 = await db.customSelect('SELECT scope_uid FROM t_timing_divinations WHERE uuid = "t-2"').getSingle();
      expect(t2.read<String?>('scope_uid'), equals('scope-2'));
      final tOrphan = await db.customSelect('SELECT scope_uid FROM t_timing_divinations WHERE uuid = "t-orphan"').getSingle();
      expect(tOrphan.read<String?>('scope_uid'), isNull);

      // 验证 seekers 回填
      final s1 = await db.customSelect('SELECT scope_uid FROM t_seekers WHERE uuid = "seeker-1"').getSingle();
      expect(s1.read<String?>('scope_uid'), equals('scope-1'));
      final s2 = await db.customSelect('SELECT scope_uid FROM t_seekers WHERE uuid = "seeker-2"').getSingle();
      expect(s2.read<String?>('scope_uid'), equals('scope-2'));
      final sOrphan = await db.customSelect('SELECT scope_uid FROM t_seekers WHERE uuid = "seeker-orphan"').getSingle();
      expect(sOrphan.read<String?>('scope_uid'), isNull);

      await db.close();
    });

    test('3. (A5) DAOs 跨 scope 读写隔离：scope A 写入，scope B 查不到', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final timingDaoA = TimingDivinationsDao(db, scopeUid: 'scope-A');
      final timingDaoB = TimingDivinationsDao(db, scopeUid: 'scope-B');

      final seekerDaoA = SeekersDao(db, scopeUid: 'scope-A');
      final seekerDaoB = SeekersDao(db, scopeUid: 'scope-B');

      final skillDaoA = SkillClassesDao(db, scopeUid: 'scope-A');
      final skillDaoB = SkillClassesDao(db, scopeUid: 'scope-B');

      final now = DateTime.now();

      // Scope A 写入
      await timingDaoA.insertTimingDivination(
        TimingDivinationsCompanion.insert(
          uuid: 'timing-A',
          divinationUuid: 'div-A',
          timingType: DateTimeType.solar,
          datetime: now,
          yearGanZhi: JiaZi.JIA_CHEN,
          monthGanZhi: JiaZi.GENG_WU,
          dayGanZhi: JiaZi.JIA_CHEN,
          timeGanZhi: JiaZi.JI_SI,
          lunarMonth: 1,
          lunarDay: 1,
          timingInfoUuid: 'info-A',
        ),
      );

      await seekerDaoA.insertSeeker(
        SeekersCompanion.insert(
          uuid: 'seeker-A',
          gender: Gender.male,
          createdAt: now,
          timingType: DateTimeType.solar,
          datetime: now,
          yearGanZhi: JiaZi.JIA_CHEN,
          monthGanZhi: JiaZi.GENG_WU,
          dayGanZhi: JiaZi.JIA_CHEN,
          timeGanZhi: JiaZi.JI_SI,
          lunarMonth: 1,
          lunarDay: 1,
          divinationUuid: 'div-A',
        ),
      );

      await skillDaoA.insert(
        SkillClassesCompanion.insert(
          uuid: 'skill-A',
          createdAt: now,
          lastUpdatedAt: now,
          skillId: 101,
          name: 'Skill A',
          specification: 'Spec A',
          feature: 'Feat A',
          isCustomized: true,
        ),
      );

      // Scope A 读：能读到自己的数据
      final timingA = await timingDaoA.getAllTimingDivinations();
      expect(timingA, hasLength(1));
      expect(timingA.single.uuid, equals('timing-A'));

      final seekerA = await seekerDaoA.getAllSeekers();
      expect(seekerA, hasLength(1));
      expect(seekerA.single.uuid, equals('seeker-A'));

      final skillA = await skillDaoA.getAll();
      expect(skillA.any((s) => s.uuid == 'skill-A'), isTrue);

      // Scope B 读：读不到 Scope A 的数据（A5 跨租户隔离核心断言）
      final timingB = await timingDaoB.getAllTimingDivinations();
      expect(timingB, isEmpty, reason: 'Scope B 绝不应该读到 Scope A 的 TimingDivinations');

      final seekerB = await seekerDaoB.getAllSeekers();
      expect(seekerB, isEmpty, reason: 'Scope B 绝不应该读到 Scope A 的 Seekers');

      final skillB = await skillDaoB.getAll();
      expect(skillB.any((s) => s.uuid == 'skill-A'), isFalse, reason: 'Scope B 绝不应该读到 Scope A 的自定义 SkillClass');

      expect(await timingDaoB.getTimingDivinationByUuid('timing-A'), isNull);
      expect(await seekerDaoB.getSeekerByUuid('seeker-A'), isNull);
    });
  });
}
