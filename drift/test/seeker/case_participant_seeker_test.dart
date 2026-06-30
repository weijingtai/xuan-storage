import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:metaphysics_core/enums/enum_gender.dart';
import 'package:metaphysics_core/enums/enum_datetime_type.dart';
import 'package:metaphysics_core/enums/enum_jia_zi.dart';
import 'package:persistence_drift/divination_case/drift_divination_case_repository.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/record/drift_record_data_source.dart';
import 'package:persistence_drift/record/local_record_repository.dart';
import 'package:persistence_drift/record/record_adapter_registry.dart';
import 'package:persistence_drift/seeker/seeker_record_codec.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

void main() {
  late PersistenceDriftDatabase db;
  late LocalRecordRepository store;
  late DriftDivinationCaseRepository caseRepo;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    final ds = DriftRecordDataSource(db, scopeUid: 'test-scope');
    final codec = SeekerRecordCodec();
    final registry = RecordAdapterRegistry([codec]);
    store = LocalRecordRepository(ds, registry);
    caseRepo = DriftDivinationCaseRepository(db);
  });

  tearDown(() => db.close());

  group('DriftDivinationCaseRepository - seeker resolution', () {
    test('resolveSeekerName returns nickname from t_record_meta', () async {
      final seeker = SeekerModel(
        uuid: 'seeker-1', username: 'zhangsan', nickname: '张三',
        gender: Gender.male,
        timingType: DateTimeType.solar,
        datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      );
      final c = SeekerRecordCodec();
      final encoded = c.encode(seeker, scopeUid: 'test-scope');
      await store.saveRecord(encoded.meta, moduleData: encoded.moduleData);

      final name = await caseRepo.resolveSeekerName('seeker-1', store);
      expect(name, '张三');
    });

    test('resolveSeekerName falls back to username when nickname is null', () async {
      final seeker = SeekerModel(
        uuid: 'seeker-2', username: '李四', nickname: null,
        gender: Gender.male,
        timingType: DateTimeType.solar,
        datetime: DateTime(2026, 6, 29),
        yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
        dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
        lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
        createdAt: DateTime(2026, 6, 29, 8, 0),
      );
      final c = SeekerRecordCodec();
      final encoded = c.encode(seeker, scopeUid: 'test-scope');
      await store.saveRecord(encoded.meta, moduleData: encoded.moduleData);

      final name = await caseRepo.resolveSeekerName('seeker-2', store);
      expect(name, '李四');
    });

    test('resolveSeekerName returns null for unknown uuid', () async {
      final name = await caseRepo.resolveSeekerName('nonexistent', store);
      expect(name, isNull);
    });
  });
}
