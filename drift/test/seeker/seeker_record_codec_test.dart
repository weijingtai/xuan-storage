import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:metaphysics_core/enums/enum_gender.dart';
import 'package:metaphysics_core/enums/enum_datetime_type.dart';
import 'package:metaphysics_core/enums/enum_jia_zi.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/record/drift_record_data_source.dart';
import 'package:persistence_drift/record/local_record_repository.dart';
import 'package:persistence_drift/record/record_adapter_registry.dart';
import 'package:persistence_drift/seeker/seeker_record_codec.dart';
import 'package:persistence_drift/seeker/record_backed_seeker_repository.dart';

void main() {
  group('SeekerRecordCodec', () {
    final codec = SeekerRecordCodec();

    final sampleSeeker = SeekerModel(
      uuid: 'test-uuid-1',
      username: '张三',
      nickname: '阿三',
      gender: Gender.male,
      timingType: DateTimeType.solar,
      datetime: DateTime(2026, 6, 29, 10, 30),
      yearGanZhi: JiaZi.JIA_CHEN,
      monthGanZhi: JiaZi.GENG_WU,
      dayGanZhi: JiaZi.JIA_CHEN,
      timeGanZhi: JiaZi.JI_SI,
      lunarMonth: 5,
      isLeapMonth: false,
      lunarDay: 15,
      location: null,
      timingInfoUuid: null,
      timingInfoListJson: null,
      createdAt: DateTime(2026, 6, 29, 8, 0),
      lastUpdatedAt: DateTime(2026, 6, 29, 10, 0),
      deletedAt: null,
      divinationUuid: 'old-div-uuid',
    );

    test('codec module is seeker', () {
      expect(codec.module, 'seeker');
    });

    test('codec category is person', () {
      expect(codec.category, 'person');
    });

    test('encode produces RecordMeta with scopeUid', () {
      final encoded = codec.encode(sampleSeeker, scopeUid: 'scope-1');
      final meta = encoded.meta;
      expect(meta.scopeUid, 'scope-1');
      expect(meta.module, 'seeker');
      expect(meta.category, 'person');
      expect(meta.uuid, 'test-uuid-1');
      expect(meta.seekerName, '阿三');
      expect(meta.gender, 'male');
    });

    test('encode → decode roundtrip preserves fields', () {
      final encoded = codec.encode(sampleSeeker, scopeUid: 'scope-1');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);
      expect(decoded.uuid, sampleSeeker.uuid);
      expect(decoded.username, sampleSeeker.username);
      expect(decoded.nickname, sampleSeeker.nickname);
      expect(decoded.gender, sampleSeeker.gender);
      expect(decoded.timingType, sampleSeeker.timingType);
      expect(decoded.datetime, sampleSeeker.datetime);
      expect(decoded.yearGanZhi, sampleSeeker.yearGanZhi);
      expect(decoded.lunarMonth, sampleSeeker.lunarMonth);
      expect(decoded.lunarDay, sampleSeeker.lunarDay);
    });

    test('decode throws RecordCodecMismatch on wrong module', () {
      final wrongMeta = RecordMeta(
        uuid: 'x', scopeUid: 'x', module: 'liuyao', category: 'divination',
        divinationType: 'liu_yao', createdAt: DateTime.now(), rev: 1,
      );
      expect(
        () => codec.decode(wrongMeta, null),
        throwsA(isA<RecordCodecMismatch>()),
      );
    });

    test('extractSearchTags returns expected tags', () {
      final encoded = codec.encode(sampleSeeker, scopeUid: 'scope-1');
      final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
      expect(tags.any((t) => t.key == 'seeker_name'), true);
      expect(tags.firstWhere((t) => t.key == 'gender').value, 'male');
      expect(tags.firstWhere((t) => t.key == 'lunar_month').value, '5');
    });
  });

  group('RecordBackedSeekerRepository index queries', () {
    late PersistenceDriftDatabase db;
    late RecordBackedSeekerRepository repo;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      final ds = DriftRecordDataSource(db, scopeUid: 'test-scope');
      final codec = SeekerRecordCodec();
      final registry = RecordAdapterRegistry([codec]);
      final store = LocalRecordRepository(ds, registry);
      repo = RecordBackedSeekerRepository(store: store, codec: codec);
    });

    tearDown(() => db.close());

    test('findByUsername returns matching seeker', () async {
      await repo.saveSeeker(SeekerModel(
        uuid: 's1', username: '张三', nickname: null,
        gender: Gender.male,
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      ));
      await repo.saveSeeker(SeekerModel(
        uuid: 's2', username: '李四', nickname: null,
        gender: Gender.female,
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      ));

      final results = await repo.findByUsername('张三');
      expect(results.length, 1);
      expect(results.first.uuid, 's1');
    });

    test('findByGender filters correctly', () async {
      await repo.saveSeeker(SeekerModel(
        uuid: 's1', username: 'a', nickname: null,
        gender: Gender.male,
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      ));
      await repo.saveSeeker(SeekerModel(
        uuid: 's2', username: 'b', nickname: null,
        gender: Gender.female,
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      ));
      await repo.saveSeeker(SeekerModel(
        uuid: 's3', username: 'c', nickname: null,
        gender: Gender.male,
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      ));

      final males = await repo.findByGender(Gender.male);
      expect(males.length, 2);
      expect(males.every((s) => s.gender == Gender.male), true);
    });

    test('findByLunarMonth filters correctly', () async {
      await repo.saveSeeker(SeekerModel(
        uuid: 's1', username: 'a', nickname: null,
        gender: Gender.male,
        timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      ));
      await repo.saveSeeker(SeekerModel(
        uuid: 's2', username: 'b', nickname: null,
        gender: Gender.male,
        timingType: DateTimeType.solar, datetime: DateTime(2026, 9, 15),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 8, isLeapMonth: false, lunarDay: 10,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      ));

      final results = await repo.findByLunarMonth(5);
      expect(results.length, 1);
      expect(results.first.uuid, 's1');
    });
  });
}
