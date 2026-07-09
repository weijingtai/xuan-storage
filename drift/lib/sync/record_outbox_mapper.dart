import 'dart:convert';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';

class RecordOutboxMapper {
  static const entityType = 'record_meta';
  static const opUpsert = 'UPSERT';
  static const opDelete = 'DELETE';

  static OutboxRecord toOutboxRecord({
    required RecordMeta meta,
    Map<String, dynamic>? moduleData,
    List<SearchTag> tags = const [],
    required String opType,
    Uuid? uuid,
  }) {
    final effectiveUuid = uuid ?? const Uuid();
    final payload = <String, dynamic>{
      'meta': metaToJson(meta),
      if (moduleData != null) 'moduleData': moduleData,
      'searchTags': tags.map((t) => {'key': t.key, 'value': t.value}).toList(),
    };
    return OutboxRecord(
      operationId: effectiveUuid.v7(),
      scopeUid: meta.scopeUid,
      entityType: entityType,
      entityId: meta.uuid,
      opType: opType,
      payloadJson: jsonEncode(payload),
      createdAtUtc: DateTime.now().toUtc(),
      attempt: 0,
    );
  }

  static Map<String, dynamic> metaToJson(RecordMeta meta) => {
        'uuid': meta.uuid, 'scopeUid': meta.scopeUid, 'module': meta.module,
        'category': meta.category, 'divinationType': meta.divinationType,
        'caseUuid': meta.caseUuid, 'workItemUuid': meta.workItemUuid,
        'seekerUuid': meta.seekerUuid, 'question': meta.question,
        'detail': meta.detail, 'tag': meta.tag, 'directPredict': meta.directPredict,
        'verificationStatus': meta.verificationStatus, 'seekerName': meta.seekerName,
        'gender': meta.gender, 'fateYear': meta.fateYear,
        'moduleDataJson': meta.moduleDataJson, 'navParamsJson': meta.navParamsJson,
        'createdAt': meta.createdAt.toUtc().toIso8601String(),
        'updatedAt': meta.updatedAt?.toUtc().toIso8601String(),
        'deletedAt': meta.deletedAt?.toUtc().toIso8601String(),
        'rev': meta.rev,
      };
}
