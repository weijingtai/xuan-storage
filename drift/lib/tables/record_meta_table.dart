import 'package:drift/drift.dart';

class TRecordMeta extends Table {
  @override
  String get tableName => 't_record_meta';

  TextColumn get uuid => text()();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get module => text()();
  TextColumn get category => text()();
  TextColumn get divinationType => text().named('divination_type')();
  TextColumn get caseUuid => text().named('case_uuid').nullable()();
  TextColumn get workItemUuid => text().named('work_item_uuid').nullable()();
  TextColumn get seekerUuid => text().named('seeker_uuid').nullable()();
  TextColumn get question => text().nullable()();
  TextColumn get detail => text().nullable()();
  TextColumn get tag => text().nullable()();
  TextColumn get directPredict => text().named('direct_predict').nullable()();
  TextColumn get verificationStatus =>
      text().named('verification_status').nullable()();
  TextColumn get seekerName => text().named('seeker_name').nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get fateYear => text().named('fate_year').nullable()();
  TextColumn get moduleDataJson => text().named('module_data_json').nullable()();
  TextColumn get navParamsJson => text().named('nav_params_json').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  IntColumn get rev => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {uuid};
}
