import 'package:drift/drift.dart';
import 'package:metaphysics_core/datamodel/sub_divination_type_data_model.dart';

@UseRowClass(SubDivinationTypeDataModel)
class SubDivinationTypes extends Table {
  @override
  String get tableName => "t_sub_divination_types";

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  DateTimeColumn get hiddenAt => dateTime().nullable().named('hidden_at')();
  TextColumn get name => text().named('name')();

  BoolColumn get isCustomized => boolean().named('is_customized')();
  BoolColumn get isAvailable => boolean().named('is_available')();

  @override
  Set<Column> get primaryKey => {uuid};
}
