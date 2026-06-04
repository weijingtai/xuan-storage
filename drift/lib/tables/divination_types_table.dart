import 'package:drift/drift.dart';
import 'package:metaphysics_core/datamodel/divination_type_data_model.dart';

@UseRowClass(DivinationTypeDataModel)
class DivinationTypes extends Table {
  @override
  String get tableName => "t_divination_types";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get name => text().named('name')();
  TextColumn get description => text().named('description')();

  BoolColumn get isCustomized => boolean().named('is_customized')();
  BoolColumn get isAvailable => boolean().named('is_available')();

  @override
  Set<Column> get primaryKey => {uuid};
}
