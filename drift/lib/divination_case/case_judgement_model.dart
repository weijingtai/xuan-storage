class CaseJudgementModel {
  final String uuid;
  final String scopeUid;
  final String caseUuid;
  final String? recordUuid;
  final String? workItemUuid;
  final String? techniqueId;
  final String? module;
  final String text;
  final String? detailText;
  final String? indicatorLabel;
  final String? patternLabel;
  final String status;
  final String? keyBasis;
  final String? attachedToKind;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CaseJudgementModel({
    required this.uuid,
    this.scopeUid = '',
    required this.caseUuid,
    this.recordUuid,
    this.workItemUuid,
    this.techniqueId,
    this.module,
    required this.text,
    this.detailText,
    this.indicatorLabel,
    this.patternLabel,
    required this.status,
    this.keyBasis,
    this.attachedToKind,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  CaseJudgementModel copyWith({
    String? uuid,
    String? scopeUid,
    String? caseUuid,
    String? recordUuid,
    String? workItemUuid,
    String? techniqueId,
    String? module,
    String? text,
    String? detailText,
    String? indicatorLabel,
    String? patternLabel,
    String? status,
    String? keyBasis,
    String? attachedToKind,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearWorkItemUuid = false,
    bool clearTechniqueId = false,
    bool clearModule = false,
    bool clearDetailText = false,
    bool clearIndicatorLabel = false,
    bool clearPatternLabel = false,
    bool clearKeyBasis = false,
    bool clearAttachedToKind = false,
    bool clearDeletedAt = false,
    bool clearRecordUuid = false,
  }) {
    return CaseJudgementModel(
      uuid: uuid ?? this.uuid,
      scopeUid: scopeUid ?? this.scopeUid,
      caseUuid: caseUuid ?? this.caseUuid,
      recordUuid: clearRecordUuid ? null : (recordUuid ?? this.recordUuid),
      workItemUuid: clearWorkItemUuid ? null : (workItemUuid ?? this.workItemUuid),
      techniqueId: clearTechniqueId ? null : (techniqueId ?? this.techniqueId),
      module: clearModule ? null : (module ?? this.module),
      text: text ?? this.text,
      detailText: clearDetailText ? null : (detailText ?? this.detailText),
      indicatorLabel: clearIndicatorLabel ? null : (indicatorLabel ?? this.indicatorLabel),
      patternLabel: clearPatternLabel ? null : (patternLabel ?? this.patternLabel),
      status: status ?? this.status,
      keyBasis: clearKeyBasis ? null : (keyBasis ?? this.keyBasis),
      attachedToKind: clearAttachedToKind ? null : (attachedToKind ?? this.attachedToKind),
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseJudgementModel &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid &&
          scopeUid == other.scopeUid &&
          caseUuid == other.caseUuid &&
          recordUuid == other.recordUuid &&
          workItemUuid == other.workItemUuid &&
          techniqueId == other.techniqueId &&
          module == other.module &&
          text == other.text &&
          detailText == other.detailText &&
          indicatorLabel == other.indicatorLabel &&
          patternLabel == other.patternLabel &&
          status == other.status &&
          keyBasis == other.keyBasis &&
          attachedToKind == other.attachedToKind &&
          orderIndex == other.orderIndex &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hashAll([
        uuid,
        scopeUid,
        caseUuid,
        recordUuid,
        workItemUuid,
        techniqueId,
        module,
        text,
        detailText,
        indicatorLabel,
        patternLabel,
        status,
        keyBasis,
        attachedToKind,
        orderIndex,
        createdAt,
        updatedAt,
        deletedAt,
      ]);

  @override
  String toString() =>
      'CaseJudgementModel(uuid: $uuid, scopeUid: $scopeUid, caseUuid: $caseUuid, '
      'recordUuid: $recordUuid, workItemUuid: $workItemUuid, techniqueId: $techniqueId, module: $module, '
      'text: $text, detailText: $detailText, indicatorLabel: $indicatorLabel, '
      'patternLabel: $patternLabel, status: $status, keyBasis: $keyBasis, '
      'attachedToKind: $attachedToKind, orderIndex: $orderIndex, '
      'createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}
