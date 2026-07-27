import 'dart:convert';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class BaziRecordCodec implements RecordModuleCodec<BaziRecordContract> {
  @override String get module => 'bazi';
  @override String get category => 'divination';
  @override String get divinationType => 'ba_zi';

  @override String uuidOf(BaziRecordContract c) => c.uuid;

  @override
  BaziRecordContract withUuid(BaziRecordContract c, String uuid) {
    return BaziRecordContract(
      uuid: uuid, caseUuid: c.caseUuid, recordDate: c.recordDate,
      chartSnapshotJson: c.chartSnapshotJson,
      snapshotSchemaVersion: c.snapshotSchemaVersion,
      legacyEightCharsJson: c.legacyEightCharsJson, daYunJson: c.daYunJson,
      note: c.note, createdAt: c.createdAt,
    );
  }

  @override
  EncodedRecord encode(BaziRecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'recordDate': c.recordDate.toIso8601String(),
      'snapshotSchemaVersion': c.snapshotSchemaVersion,
      if (c.chartSnapshotJson != null) 'chartSnapshotJson': c.chartSnapshotJson,
      if (c.legacyEightCharsJson != null) 'legacyEightCharsJson': c.legacyEightCharsJson,
      if (c.daYunJson != null) 'daYunJson': c.daYunJson,
      if (c.note != null) 'note': c.note,
    };
    final meta = RecordMeta(
      uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType, caseUuid: c.caseUuid,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': c.uuid}),
      question: null, detail: null, tag: null, directPredict: null,
      verificationStatus: null, seekerName: null, gender: null, fateYear: null,
      occurredAtUtc: null, reckoningType: null, timezoneStr: null,
      latitude: null, longitude: null, locationName: null, spacetimeJson: null,
      createdAt: c.createdAt, updatedAt: null, deletedAt: null, rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  BaziRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return BaziRecordContract(
      uuid: meta.uuid,
      caseUuid: meta.caseUuid ?? (d['caseUuid'] as String? ?? ''),
      recordDate: d['recordDate'] != null ? DateTime.parse(d['recordDate'] as String) : meta.createdAt,
      chartSnapshotJson: d['chartSnapshotJson'] as String?,
      snapshotSchemaVersion: d['snapshotSchemaVersion'] as int? ?? 1,
      legacyEightCharsJson: d['legacyEightCharsJson'] as String?,
      daYunJson: d['daYunJson'] as String?,
      note: d['note'] as String?,
      createdAt: meta.createdAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    return [
      SearchTag('case_uuid', meta.caseUuid ?? ''),
    ];
  }
}
