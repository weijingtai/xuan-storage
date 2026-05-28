import 'package:drift/drift.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:persistence_drift/tables/seekers_table.dart';
import 'package:common/datamodel/divination_request_info_datamodel.dart';


@UseRowClass(DivinationRequestInfoDataModel)
class Divinations extends Table {
  @override
  String get tableName => "t_divinations";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  // [命理、运程、占测、择吉、化解、运筹、堪舆]
  TextColumn get divinationTypeUuid =>
      text().named('divination_type_uuid')();

  TextColumn get fateYear => text().nullable().named("fate_year")();

  TextColumn get question => text().nullable().named('question')();
  TextColumn get detail => text().nullable().named('detail')();

  // 卜问求测人的uuid, 当本字段为空时说明求测人以前未进行过卜问 （可以为空，表示为卦师自己的客源）
  TextColumn get ownerSeekerUuid =>
      text().nullable().named('seeker_uuid').references(Seekers, #uuid)();
  // 部分卜问需要求测人性别，如果求测人不提供如八字等详细生辰信息时用此字段
  // 当求测人提供自己全部的生辰信息时应尽量避免使用本字段。
  TextColumn get gender => textEnum<Gender>().nullable()();
  TextColumn get seekerName => text().nullable().named('seeker_name')();
  // 吉凶、中平/ 夭寿、穷通、贤愚
  TextColumn get tinyPredict => text().nullable().named('tiny_predict')();
  // 直断，12~24字内
  TextColumn get directlyPredict =>
      text().nullable().named('directly_predict')();

  @override
  Set<Column> get primaryKey => {uuid};
}