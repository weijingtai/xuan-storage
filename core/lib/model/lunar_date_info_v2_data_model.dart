import 'package:json_annotation/json_annotation.dart';
import 'package:metaphysics_core/models/lunar_date_info_v2_logic_model.dart';

part 'lunar_date_info_v2_data_model.g.dart';

/// 数据层数据模型
///
/// 纯持久化用途，包含序列化字段。
/// 由 storage 层使用（如 Drift @UseRowClass），
/// 上层不应直接使用此模型，应通过 LogicModel 或 UIModel。
@JsonSerializable()
class LunarDateInfoV2DataModel {
  /// 计算结果捆绑包（序列化后的 JSON）。
  final Map<String, dynamic> bundleJson;

  /// 当前使用的日期时间类型（存储为字符串）。
  final String inUsed;

  const LunarDateInfoV2DataModel({
    required this.bundleJson,
    required this.inUsed,
  });

  factory LunarDateInfoV2DataModel.fromJson(Map<String, dynamic> json) =>
      _$LunarDateInfoV2DataModelFromJson(json);

  Map<String, dynamic> toJson() => _$LunarDateInfoV2DataModelToJson(this);

  /// 从 LogicModel 转换为 DataModel（业务层 → 数据层）。
  factory LunarDateInfoV2DataModel.fromLogicModel(
    LunarDateInfoV2LogicModel logic,
  ) {
    return LunarDateInfoV2DataModel(
      bundleJson: logic.bundle.toJson(),
      inUsed: logic.inUsed.name,
    );
  }
}
