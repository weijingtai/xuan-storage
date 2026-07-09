import 'package:drift/drift.dart' hide isNotNull, isNull;
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
import 'package:persistence_drift/seeker/record_backed_seeker_repository.dart';

SeekerModel _seeker(String uuid, {DateTime? deletedAt}) => SeekerModel(
  uuid: uuid, username: 'u-$uuid', nickname: null,
  gender: Gender.male,
  timingType: DateTimeType.solar, datetime: DateTime(2026, 6, 29),
  yearGanZhi: JiaZi.JIA_CHEN, monthGanZhi: JiaZi.GENG_WU,
  dayGanZhi: JiaZi.JIA_CHEN, timeGanZhi: JiaZi.JI_SI,
  lunarMonth: 5, isLeapMonth: false, lunarDay: 15,
  createdAt: DateTime(2026, 6, 29, 8, 0),
  lastUpdatedAt: DateTime(2026, 6, 29, 10, 0),
  deletedAt: deletedAt,
);

RecordBackedSeekerRepository _makeRepo(PersistenceDriftDatabase db, String scope) {
  final ds = DriftRecordDataSource(db, scopeUid: scope);
  final codec = SeekerRecordCodec();
  final registry = RecordAdapterRegistry([codec]);
  final store = LocalRecordRepository(ds, registry);
  return RecordBackedSeekerRepository(store: store, codec: codec);
}

void main() {
  group('Seeker E2E', () {
    test('full lifecycle: create → read → soft-delete → verify deleted', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = _makeRepo(db, 'scope-1');

      final savedUuid = await repo.saveSeeker(_seeker('s1'));
      expect(savedUuid, 's1');

      final read = await repo.getSeekerByUuid('s1');
      expect(read, isNotNull);
      expect(read!.username, 'u-s1');

      final deleted = await repo.softDeleteSeeker('s1');
      expect(deleted, true);

      final afterDelete = await repo.getSeekerByUuid('s1');
      expect(afterDelete, isNotNull);
      expect(afterDelete!.deletedAt, isNotNull);

      final allAfterDelete = await repo.getAllSeekers();
      expect(allAfterDelete.where((s) => s.uuid == 's1').toList(), isEmpty);
    });

    test('scope isolation: seeker from scope A not visible in scope B', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repoA = _makeRepo(db, 'scope-a');
      final repoB = _makeRepo(db, 'scope-b');

      await repoA.saveSeeker(_seeker('s1'));
      await repoB.saveSeeker(_seeker('s2'));

      final allA = await repoA.getAllSeekers();
      expect(allA.length, 1);
      expect(allA.first.uuid, 's1');

      final allB = await repoB.getAllSeekers();
      expect(allB.length, 1);
      expect(allB.first.uuid, 's2');
    });

    test('concurrent seekers from same scope', () async {
      final db = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = _makeRepo(db, 'scope-1');

      await Future.wait([
        repo.saveSeeker(_seeker('s1')),
        repo.saveSeeker(_seeker('s2')),
        repo.saveSeeker(_seeker('s3')),
      ]);

      final all = await repo.getAllSeekers();
      expect(all.length, 3);
      expect(all.map((s) => s.uuid).toSet(), equals({'s1', 's2', 's3'}));
    });
  });
}
