import 'package:json_annotation/json_annotation.dart';
import 'package:metaphysics_core/models/datetime_details_bundle_logic_model.dart';
import 'package:metaphysics_core/models/calculation_strategy_config_logic_model.dart';

part 'datetime_details_bundle_data_model.g.dart';

/// 数据层：日期时间详细计算结果
///
/// 纯持久化用途，包含序列化字段。
/// 由 storage 层使用（如 Drift @UseRowClass），
/// 上层不应直接使用此模型，应通过 LogicModel。
@JsonSerializable()
class DateTimeDetailsBundleDataModel {
  /// 计算策略配置（序列化后的 JSON）
  final Map<String, dynamic> calculationConfigJson;

  /// 标准出生时间（ISO 8601 字符串）
  final String standeredDatetime;

  /// 标准出生时间的中国日期信息（序列化后的 JSON）
  final Map<String, dynamic> standeredChineseInfoJson;

  /// UTC 时间
  final String utcDatetime;

  /// 时区名称
  final String timezoneStr;

  /// 夏令时标志
  final bool? isDST;

  /// 移除夏令时后的时间
  final String? removeDSTDatetime;

  /// 移除夏令时后的中国日期信息
  final Map<String, dynamic>? removeDSTChineseInfoJson;

  /// 平太阳时
  final String? meanSolarDatetime;

  /// 平太阳时的中国日期信息
  final Map<String, dynamic>? meanSolarChineseInfoJson;

  /// 真太阳时
  final String? trueSolarDatetime;

  /// 真太阳时的中国日期信息
  final Map<String, dynamic>? trueSolarChineseInfoJson;

  const DateTimeDetailsBundleDataModel({
    required this.calculationConfigJson,
    required this.standeredDatetime,
    required this.standeredChineseInfoJson,
    required this.utcDatetime,
    required this.timezoneStr,
    this.isDST,
    this.removeDSTDatetime,
    this.removeDSTChineseInfoJson,
    this.meanSolarDatetime,
    this.meanSolarChineseInfoJson,
    this.trueSolarDatetime,
    this.trueSolarChineseInfoJson,
  });

  factory DateTimeDetailsBundleDataModel.fromJson(Map<String, dynamic> json) =>
      _$DateTimeDetailsBundleDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DateTimeDetailsBundleDataModelToJson(this);

  /// 从 LogicModel 转换为 DataModel（业务层 → 数据层）
  factory DateTimeDetailsBundleDataModel.fromLogicModel(
    DateTimeDetailsBundleLogicModel logic,
  ) {
    return DateTimeDetailsBundleDataModel(
      calculationConfigJson: {
        'ziStrategy': logic.calculationConfig.ziStrategy.name,
        'jieQiType': logic.calculationConfig.jieQiType.name,
        'jieQiStrategy': logic.calculationConfig.jieQiStrategy.name,
      },
      standeredDatetime: logic.standeredDatetime.toIso8601String(),
      standeredChineseInfoJson: logic.standeredChineseInfo.toJson(),
      utcDatetime: logic.utcDatetime.toIso8601String(),
      timezoneStr: logic.timezoneStr,
      isDST: logic.isDST,
      removeDSTDatetime: logic.removeDSTDatetime?.toIso8601String(),
      removeDSTChineseInfoJson: logic.removeDSTChineseInfo?.toJson(),
      meanSolarDatetime: logic.meanSolarDatetime?.toIso8601String(),
      meanSolarChineseInfoJson: logic.meanSolarChineseInfo?.toJson(),
      trueSolarDatetime: logic.trueSolarDatetime?.toIso8601String(),
      trueSolarChineseInfoJson: logic.trueSolarChineseInfo?.toJson(),
    );
  }
}
