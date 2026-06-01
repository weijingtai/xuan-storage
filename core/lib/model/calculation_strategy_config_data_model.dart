import 'package:json_annotation/json_annotation.dart';
import 'package:metaphysics_core/models/calculation_strategy_config_logic_model.dart';
import 'package:metaphysics_core/enums/datetime_strategy_enums.dart';

part 'calculation_strategy_config_data_model.g.dart';

/// 数据层：计算策略配置
///
/// 纯持久化用途，用于 JSON 序列化和 Drift 存储。
/// 上层不应直接使用此模型，应通过 LogicModel。
@JsonSerializable()
class CalculationStrategyConfigDataModel {
  /// 子时策略（存储为字符串）
  final String ziStrategy;

  /// 节气类型（存储为字符串）
  final String jieQiType;

  /// 节气策略（存储为字符串）
  final String jieQiStrategy;

  const CalculationStrategyConfigDataModel({
    required this.ziStrategy,
    required this.jieQiType,
    required this.jieQiStrategy,
  });

  factory CalculationStrategyConfigDataModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CalculationStrategyConfigDataModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CalculationStrategyConfigDataModelToJson(this);

  /// 从 LogicModel 转换为 DataModel（业务层 → 数据层）
  factory CalculationStrategyConfigDataModel.fromLogicModel(
    CalculationStrategyConfigLogicModel logic,
  ) {
    return CalculationStrategyConfigDataModel(
      ziStrategy: logic.ziStrategy.name,
      jieQiType: logic.jieQiType.name,
      jieQiStrategy: logic.jieQiStrategy.name,
    );
  }

  /// 从 DataModel 转换为 LogicModel（数据层 → 业务层）
  CalculationStrategyConfigLogicModel toLogicModel() {
    return CalculationStrategyConfigLogicModel(
      ziStrategy: ZiShiStrategy.values.byName(ziStrategy),
      jieQiType: JieQiType.values.byName(jieQiType),
      jieQiStrategy: JieQiStrategy.values.byName(jieQiStrategy),
    );
  }
}
