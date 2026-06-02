/// Storage-local DTO for CardTemplateSetting.
/// Uses rowTypeKey: String instead of RowType enum to avoid depending on xuan-four-zhu-card.
class CardTemplateSettingDto {
  const CardTemplateSettingDto({
    required this.templateUuid,
    required this.createdAt,
    required this.modifiedAt,
    this.isHiddenTitlePillar,
    this.showInCellTitleByRowTypeKey,
    this.overrides,
  });

  final String templateUuid;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool? isHiddenTitlePillar;
  final Map<String, bool>? showInCellTitleByRowTypeKey;
  final CardTemplateSettingOverrideDto? overrides;

  Map<String, dynamic> toJson() => {
    'templateUuid': templateUuid,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'isHiddenTitlePillar': isHiddenTitlePillar,
    'showInCellTitleByRowTypeKey': showInCellTitleByRowTypeKey,
    'overrides': overrides?.toJson(),
  };

  factory CardTemplateSettingDto.fromJson(Map<String, dynamic> json) {
    return CardTemplateSettingDto(
      templateUuid: json['templateUuid'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      isHiddenTitlePillar: json['isHiddenTitlePillar'] as bool?,
      showInCellTitleByRowTypeKey: (json['showInCellTitleByRowTypeKey'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as bool)),
      overrides: json['overrides'] != null
          ? CardTemplateSettingOverrideDto.fromJson(json['overrides'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CardTemplateSettingOverrideDto {
  const CardTemplateSettingOverrideDto({
    this.isHiddenTitlePillar,
    this.showInCellTitleByRowTypeKey,
  });

  final bool? isHiddenTitlePillar;
  final Map<String, bool>? showInCellTitleByRowTypeKey;

  Map<String, dynamic> toJson() => {
    'isHiddenTitlePillar': isHiddenTitlePillar,
    'showInCellTitleByRowTypeKey': showInCellTitleByRowTypeKey,
  };

  factory CardTemplateSettingOverrideDto.fromJson(Map<String, dynamic> json) {
    return CardTemplateSettingOverrideDto(
      isHiddenTitlePillar: json['isHiddenTitlePillar'] as bool?,
      showInCellTitleByRowTypeKey: (json['showInCellTitleByRowTypeKey'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as bool)),
    );
  }
}
