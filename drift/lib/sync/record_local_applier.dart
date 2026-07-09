import 'dart:convert';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'record_outbox_mapper.dart';

class RecordLocalApplier implements LocalApplier {
  final Future<void> Function(RecordMeta meta, List<SearchTag> tags) applyRecord;
  final Future<bool> Function(String uuid) deleteRecord;

  RecordLocalApplier({
    required this.applyRecord,
    required this.deleteRecord,
  });

  // ignore: annotate_overrides — LocalApplier 未定义 canApply，此为扩展方法
  bool canApply(String entityType) => entityType == RecordOutboxMapper.entityType;

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    if (entityType != RecordOutboxMapper.entityType) {
      return LocalApplyResult(
        canAdvanceCursor: false, appliedCount: 0, outcomes: const [], lastError: null,
      );
    }

    final outcomes = <ChangeApplyOutcome>[];
    var applied = 0;

    for (final change in changes) {
      try {
        final payload = jsonDecode(change.payloadJson) as Map<String, dynamic>;
        final meta = _parseMeta(payload['meta'] as Map<String, dynamic>, scopeUid);
        final tags = _parseTags(payload['searchTags'] as List<dynamic>?);

        if (change.opType == RecordOutboxMapper.opDelete) {
          await deleteRecord(change.entityId);
        } else {
          await applyRecord(meta, tags);
        }

        applied++;
        outcomes.add(ChangeApplyOutcome(
          operationId: change.operationId, entityType: entityType,
          entityId: change.entityId, decision: ChangeApplyDecision.applied,
          reason: null, message: null,
        ));
      } catch (e) {
        outcomes.add(ChangeApplyOutcome(
          operationId: change.operationId, entityType: entityType,
          entityId: change.entityId, decision: ChangeApplyDecision.failed,
          reason: SkipReasonCode.unknown, message: e.toString(),
        ));
      }
    }

    return LocalApplyResult(
      canAdvanceCursor: true, appliedCount: applied,
      outcomes: outcomes, lastError: null,
    );
  }

  RecordMeta _parseMeta(Map<String, dynamic> json, String scopeUid) {
    return RecordMeta(
      uuid: json['uuid'] as String,
      scopeUid: scopeUid,
      module: json['module'] as String,
      category: json['category'] as String,
      divinationType: json['divinationType'] as String,
      caseUuid: json['caseUuid'] as String?,
      workItemUuid: json['workItemUuid'] as String?,
      seekerUuid: json['seekerUuid'] as String?,
      question: json['question'] as String?,
      detail: json['detail'] as String?,
      tag: json['tag'] as String?,
      directPredict: json['directPredict'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      seekerName: json['seekerName'] as String?,
      gender: json['gender'] as String?,
      fateYear: json['fateYear'] as String?,
      moduleDataJson: json['moduleDataJson'] as String?,
      navParamsJson: json['navParamsJson'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      rev: json['rev'] as int? ?? 1,
    );
  }

  List<SearchTag> _parseTags(List<dynamic>? list) {
    if (list == null) return const [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return SearchTag(m['key'] as String, m['value'] as String);
    }).toList();
  }
}
