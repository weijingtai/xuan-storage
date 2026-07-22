// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datetime_details_bundle_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateTimeDetailsBundleDataModel _$DateTimeDetailsBundleDataModelFromJson(
  Map<String, dynamic> json,
) => DateTimeDetailsBundleDataModel(
  calculationConfigJson: json['calculationConfigJson'] as Map<String, dynamic>,
  standeredDatetime: json['standeredDatetime'] as String,
  standeredChineseInfoJson:
      json['standeredChineseInfoJson'] as Map<String, dynamic>,
  utcDatetime: json['utcDatetime'] as String,
  timezoneStr: json['timezoneStr'] as String,
  isDST: json['isDST'] as bool?,
  removeDSTDatetime: json['removeDSTDatetime'] as String?,
  removeDSTChineseInfoJson:
      json['removeDSTChineseInfoJson'] as Map<String, dynamic>?,
  meanSolarDatetime: json['meanSolarDatetime'] as String?,
  meanSolarChineseInfoJson:
      json['meanSolarChineseInfoJson'] as Map<String, dynamic>?,
  trueSolarDatetime: json['trueSolarDatetime'] as String?,
  trueSolarChineseInfoJson:
      json['trueSolarChineseInfoJson'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DateTimeDetailsBundleDataModelToJson(
  DateTimeDetailsBundleDataModel instance,
) => <String, dynamic>{
  'calculationConfigJson': instance.calculationConfigJson,
  'standeredDatetime': instance.standeredDatetime,
  'standeredChineseInfoJson': instance.standeredChineseInfoJson,
  'utcDatetime': instance.utcDatetime,
  'timezoneStr': instance.timezoneStr,
  'isDST': instance.isDST,
  'removeDSTDatetime': instance.removeDSTDatetime,
  'removeDSTChineseInfoJson': instance.removeDSTChineseInfoJson,
  'meanSolarDatetime': instance.meanSolarDatetime,
  'meanSolarChineseInfoJson': instance.meanSolarChineseInfoJson,
  'trueSolarDatetime': instance.trueSolarDatetime,
  'trueSolarChineseInfoJson': instance.trueSolarChineseInfoJson,
};
