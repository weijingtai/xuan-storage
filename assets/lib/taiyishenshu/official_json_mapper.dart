import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart'
    show TaiYiSchool, DeityDefinition, SchoolEpochConfig, DeityAlgorithmSpec;
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/taiyi/core/chart_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_override.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';

// ---------------------------------------------------------------------------
// TaiYiSchool → TaiYiSchoolContract (read-only assets side)
// ---------------------------------------------------------------------------

extension TaiYiSchoolAssetMapper on TaiYiSchool {
  TaiYiSchoolContract toContract() {
    return TaiYiSchoolContract(
      id: id,
      name: name,
      source: source,
      epoch: epoch.toContract(),
      deityIds: deityIds,
      overrides: overrides,
      wenChangStayRule: wenChangStayRule,
      useTwelveJiShen: useTwelveJiShen,
      palaceFormula: palaceFormula,
      eightDoorMode: eightDoorMode,
      chartConfigs: {
        for (final e in chartConfigs.entries) e.key: e.value.toJson(),
      },
      deityConfigs: {
        for (final e in deityConfigs.entries) e.key: e.value.toJson(),
      },
      privateDeities: privateDeities,
      sourceId: sourceId,
      rootOfficialId: rootOfficialId,
      lineage: lineage,
    );
  }
}

// ---------------------------------------------------------------------------
// DeityDefinition → DeityDefinitionContract (read-only assets side)
// ---------------------------------------------------------------------------

extension DeityDefinitionAssetMapper on DeityDefinition {
  DeityDefinitionContract toContract() {
    return DeityDefinitionContract(
      id: id,
      name: name,
      layer: layer.name,
      algorithm: DeityAlgorithmSpecContract(
        templateId: algorithm.templateId.name,
        params: algorithm.params,
      ),
      priority: priority,
      description: description,
      source: source,
      tier: tier,
      chartTypes: chartTypes,
      schoolScopes: schoolScopes,
      displayStyle: displayStyle,
      color: color,
      sourceId: sourceId,
      rootOfficialId: rootOfficialId,
      lineage: lineage,
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers for epoch mapping
// ---------------------------------------------------------------------------

extension _SchoolEpochConfigAssetMapper on SchoolEpochConfig {
  SchoolEpochConfigContract toContract() {
    return SchoolEpochConfigContract(
      ancientBase: ancientBase,
      epochYear: epochYear,
      correction: correction,
      tropicalYear: tropicalYear,
      ancientMonthBase: ancientMonthBase,
      ancientDayBase: ancientDayBase,
      ancientHourBase: ancientHourBase,
      zhangSui: zhangSui,
      zhangYue: zhangYue,
      dayOffset: dayOffset,
      hourOffset: hourOffset,
    );
  }
}
