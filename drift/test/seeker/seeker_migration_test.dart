import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:metaphysics_core/enums/enum_gender.dart';
import 'package:metaphysics_core/enums/enum_datetime_type.dart';
import 'package:metaphysics_core/enums/enum_jia_zi.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/record/drift_record_data_source.dart';
import 'package:persistence_drift/record/local_record_repository.dart';
import 'package:persistence_drift/record/record_adapter_registry.dart';
import 'package:persistence_drift/seeker/seeker_record_codec.dart';
import 'package:persistence_drift/seeker/seeker_migration.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

SeekerModel _makeSeeker(String uuid, {DateTime? deletedAt, String? divUuid}) {
  return SeekerModel(
    uuid: uuid,
    username: '测试',
    nickname: '测',
    gender: Gender.male,
    timingType: DateTimeType.solar,
    datetime: DateTime(2026, 6, 29),
    yearGanZhi: JiaZi.JIA_CHEN,
    monthGanZhi: JiaZi.GENG_WU,
    dayGanZhi: JiaZi.JIA_CHEN,
    timeGanZhi: JiaZi.JI_SI,
    lunarMonth: 5,
    isLeapMonth: false,
    lunarDay: 15,
    createdAt: DateTime(2026, 6, 29, 8, 0),
    lastUpdatedAt: DateTime(2026, 6, 29, 10, 0),
    deletedAt: deletedAt,
    divinationUuid: divUuid ?? 'div-$uuid',
  );
}

void main() {
  late PersistenceDriftDatabase db;
  late SeekersDao oldDao;
  late DriftRecordDataSource ds;
  late LocalRecordRepository store;
  late SeekerRecordCodec codec;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    oldDao = SeekersDao(db);
    ds = DriftRecordDataSource(db, scopeUid: 'test-scope');
    codec = SeekerRecordCodec();
    final registry = RecordAdapterRegistry([codec]);
    store = LocalRecordRepository(ds, registry);
  });

  tearDown(() => db.close());

  group('SeekerMigration', () {
    test('migrateAllSeekers copies non-deleted seekers to t_record_meta', () async {
      await oldDao.insertSeeker(SeekersCompanion.insert(
        uuid: 's1', gender: Gender.male, createdAt: DateTime(2026, 6, 29, 8, 0),
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, lunarDay: 15, divinationUuid: 'div-s1',
      ));
      await oldDao.insertSeeker(SeekersCompanion.insert(
        uuid: 's2', gender: Gender.female, createdAt: DateTime(2026, 6, 29, 8, 0),
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, lunarDay: 15, divinationUuid: 'div-s2',
      ));

      final migration = SeekerMigration(oldDao, store, codec);
      final count = await migration.migrateAll();

      expect(count, 2);

      final results = await ds.listRecords(module: 'seeker');
      expect(results.length, 2);
      expect(results.any((r) => r.uuid == 's1'), true);
      expect(results.any((r) => r.uuid == 's2'), true);
    });

    test('soft-deleted seekers are skipped', () async {
      await oldDao.insertSeeker(SeekersCompanion.insert(
        uuid: 's1', gender: Gender.male, createdAt: DateTime(2026, 6, 29, 8, 0),
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, lunarDay: 15, divinationUuid: 'div-s1',
      ));
      await oldDao.insertSeeker(SeekersCompanion.insert(
        uuid: 's2', gender: Gender.female, createdAt: DateTime(2026, 6, 29, 8, 0),
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, lunarDay: 15, divinationUuid: 'div-s2',
        deletedAt: Value(DateTime(2026, 6, 30)),
      ));

      final migration = SeekerMigration(oldDao, store, codec);
      final count = await migration.migrateAll();

      expect(count, 1);

      final results = await ds.listRecords(module: 'seeker');
      expect(results.length, 1);
      expect(results.first.uuid, 's1');
    });

    test('migrated seeker roundtrips through codec', () async {
      await oldDao.insertSeeker(SeekersCompanion.insert(
        uuid: 's1', gender: Gender.male, createdAt: DateTime(2026, 6, 29, 8, 0),
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, lunarDay: 15, divinationUuid: 'div-s1',
      ));

      final migration = SeekerMigration(oldDao, store, codec);
      await migration.migrateAll();

      final meta = await ds.getRecord('s1');
      expect(meta, isNotNull);
      final decoded = codec.decode(meta!, null);
      expect(decoded.uuid, 's1');
      expect(decoded.gender, Gender.male);
    });

    test('migration is idempotent', () async {
      await oldDao.insertSeeker(SeekersCompanion.insert(
        uuid: 's1', gender: Gender.male, createdAt: DateTime(2026, 6, 29, 8, 0),
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, lunarDay: 15, divinationUuid: 'div-s1',
      ));

      final migration = SeekerMigration(oldDao, store, codec);
      await migration.migrateAll();
      await migration.migrateAll();

      final results = await ds.listRecords(module: 'seeker');
      expect(results.length, 1);
    });
  });
}
