import 'package:drift/drift.dart';
import 'package:metaphysics_core/enums/enum_panel_type.dart';

class Panels extends Table {
  @override
  String get tableName => "t_panels";
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  // [单盘、合盘、合婚(合盘的一种，但)、同参(俗称‘穿’)、校验]
  IntColumn get panelType => intEnum<EnumPanelType>().named('panel_type')();
  // 一对一关系
  IntColumn get skillId =>
      integer().named('skill_id')();

  // 随机起盘（如，三式从阴阳遁局中随机选取），手动指定，时间起盘，数字起盘、测字等。
  TextColumn get divinateType => text().named('divinate_type')();
  // 当为时间起卦是，这个uuid指向的是 TimingDivinations 中的uuid
  TextColumn get divinateUuid => text().named('divinate_uuid')();

  @override
  Set<Column> get primaryKey => {uuid};
}