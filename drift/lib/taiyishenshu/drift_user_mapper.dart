import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart'
    show TaiYiSchool, DeityDefinition, SchoolEpochConfig, DeityAlgorithmSpec;
import 'package:taiyishenshu/taiyi/core/algorithm_enums.dart';
import 'package:taiyishenshu/taiyi/core/chart_config.dart';
import 'package:taiyishenshu/taiyi/core/deity_override.dart';
import 'package:taiyishenshu/enums/deity_kind.dart';

// ---------------------------------------------------------------------------
// TaiYiSchool ↔ TaiYiSchoolContract
// ---------------------------------------------------------------------------

extension TaiYiSchoolMapper on TaiYiSchool {
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

extension TaiYiSchoolContractMapper on TaiYiSchoolContract {
  TaiYiSchool toModel() {
    return TaiYiSchool(
      id: id,
      name: name,
      source: source,
      epoch: epoch.toModel(),
      deityIds: deityIds,
      overrides: overrides,
      wenChangStayRule: wenChangStayRule,
      useTwelveJiShen: useTwelveJiShen,
      palaceFormula: palaceFormula,
      eightDoorMode: eightDoorMode,
      chartConfigs: {
        for (final e in chartConfigs.entries)
          e.key: ChartConfig.fromJson(Map<String, dynamic>.from(e.value)),
      },
      deityConfigs: {
        for (final e in deityConfigs.entries)
          e.key: DeityOverride.fromJson(Map<String, dynamic>.from(e.value)),
      },
      privateDeities: privateDeities,
      sourceId: sourceId,
      rootOfficialId: rootOfficialId,
      lineage: lineage,
    );
  }
}

// ---------------------------------------------------------------------------
// SchoolEpochConfig ↔ SchoolEpochConfigContract
// ---------------------------------------------------------------------------

extension _SchoolEpochConfigMapper on SchoolEpochConfig {
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

extension _SchoolEpochConfigContractMapper on SchoolEpochConfigContract {
  SchoolEpochConfig toModel() {
    return SchoolEpochConfig(
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

// ---------------------------------------------------------------------------
// DeityDefinition ↔ DeityDefinitionContract
// ---------------------------------------------------------------------------

extension DeityDefinitionMapper on DeityDefinition {
  DeityDefinitionContract toContract() {
    return DeityDefinitionContract(
      id: id,
      name: name,
      layer: layer.name,
      algorithm: algorithm.toContract(),
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

extension DeityDefinitionContractMapper on DeityDefinitionContract {
  DeityDefinition toModel() {
    return DeityDefinition(
      id: id,
      name: name,
      layer: EnumDeityLayer.values.byName(layer),
      algorithm: algorithm.toModel(),
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
// DeityAlgorithmSpec ↔ DeityAlgorithmSpecContract
// ---------------------------------------------------------------------------

extension _DeityAlgorithmSpecMapper on DeityAlgorithmSpec {
  DeityAlgorithmSpecContract toContract() {
    return DeityAlgorithmSpecContract(
      templateId: templateId.name,
      params: params,
    );
  }
}

extension _DeityAlgorithmSpecContractMapper on DeityAlgorithmSpecContract {
  DeityAlgorithmSpec toModel() {
    return DeityAlgorithmSpec(
      templateId: AlgorithmTemplateId.values.byName(templateId),
      params: params,
    );
  }
}
