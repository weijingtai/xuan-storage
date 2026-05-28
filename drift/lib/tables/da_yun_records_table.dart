import 'package:drift/drift.dart';

@DataClassName('DaYunRecord')
class DaYunRecords extends Table {
  @override
  String get tableName => 't_da_yun_records';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get sourceUuid => text().named('source_uuid')();

  TextColumn get jieQiType => text().named('jie_qi_type')();
  TextColumn get precision => text().named('precision')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
