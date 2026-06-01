import 'package:drift/drift.dart';

class CaseParticipants extends Table {
  @override
  String get tableName => 't_case_participants';

  TextColumn get uuid => text().named('uuid')();
  TextColumn get caseUuid => text().named('case_uuid')();
  TextColumn get recordUuid => text().nullable().named('record_uuid')();
  TextColumn get name => text().named('name')();
  TextColumn get role => text().named('role')();
  TextColumn get seekerUuid => text().nullable().named('seeker_uuid')();

  @override
  Set<Column> get primaryKey => {uuid};
}
