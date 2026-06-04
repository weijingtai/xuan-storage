import 'package:drift/drift.dart';
import 'package:metaphysics_core/datamodel/timing_divination_model.dart';
import 'package:metaphysics_core/enums/enum_datetime_type.dart';
import 'package:metaphysics_core/enums/enum_jia_zi.dart';
import 'package:persistence_drift/converters/divination_datetime_model_converter.dart';
import 'package:persistence_drift/converters/nullable_location_converter.dart';

@UseRowClass(TimingDivinationModel)
class TimingDivinations extends Table {
  @override
  String get tableName => "t_timing_divinations";
  // 主键设计
  TextColumn get uuid => text().named('uuid')();

  // 时间追踪
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now()).named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime()
      .nullable()
      .withDefault(currentDateAndTime)
      .named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  // 关联字段
  TextColumn get divinationUuid => text().named('divination_uuid')();

  // 历法核心数据
  IntColumn get timingType =>
      intEnum<DateTimeType>()(); // 使用MappedEnumConverter
  DateTimeColumn get datetime => dateTime().named('datetime')();
  BoolColumn get isManual =>
      boolean().withDefault(const Constant(false)).named('is_manual')();

  // 干支体系， 注意甲子的index=0 而非枚举类型number=1
  IntColumn get yearGanZhi => intEnum<JiaZi>().named('year_gan_zhi')();
  IntColumn get monthGanZhi => intEnum<JiaZi>().named('month_gan_zhi')();
  IntColumn get dayGanZhi => intEnum<JiaZi>().named('day_gan_zhi')();
  IntColumn get timeGanZhi => intEnum<JiaZi>().named('time_gan_zhi')();

  // 阴历数据
  IntColumn get lunarMonth => integer().named('lunar_month')();
  // 是否为闰月
  BoolColumn get isLeapMonth =>
      boolean().withDefault(const Constant(false)).named('is_leap_month')();
  IntColumn get lunarDay => integer().named('lunar_day')();

  TextColumn get timingInfoUuid => text().named('timing_info_uuid')();
  TextColumn get location => text()
      .nullable()
      .map(const NullableLocationConverter())
      .named("location_json")();
  // JSON扩展字段
  TextColumn get timingInfoListJson => text()
      .map(const DivinationDatetimeModelConverter())
      .nullable()
      .named('info_list_json')();

  TextColumn get currentCalendarUuid =>
      text().nullable().named('current_calendar_uuid')();

  @override
  Set<Column> get primaryKey => {uuid};
}