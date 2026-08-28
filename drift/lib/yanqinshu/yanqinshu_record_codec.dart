import 'dart:convert';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_yanqinshu/repository_interface_yanqinshu.dart';

class YanqinshuRecordCodec
    implements RecordModuleCodec<YanqinshuDivinationRecordContract> {
  @override
  String get module => 'yanqinshu';

  @override
  String get category => 'divination';

  @override
  String get divinationType => 'yan_qin_shu';

  @override
  String uuidOf(YanqinshuDivinationRecordContract c) => c.uuid;

  @override
  YanqinshuDivinationRecordContract withUuid(
    YanqinshuDivinationRecordContract c,
    String uuid,
  ) {
    return YanqinshuDivinationRecordContract(
      uuid: uuid,
      question: c.question,
      technique: c.technique,
      schoolId: c.schoolId,
      lunarDateJson: c.lunarDateJson,
      ganzhiJson: c.ganzhiJson,
      paramsJson: c.paramsJson,
      baseDataJson: c.baseDataJson,
      viewDataJson: c.viewDataJson,
      conclusionJson: c.conclusionJson,
      sourceMetadataJson: c.sourceMetadataJson,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(
    YanqinshuDivinationRecordContract c, {
    required String scopeUid,
  }) {
    final data = <String, dynamic>{
      'question': c.question,
      'technique': c.technique,
      'schoolId': c.schoolId,
      'lunarDateJson': c.lunarDateJson,
      'ganzhiJson': c.ganzhiJson,
      'paramsJson': c.paramsJson,
      'baseDataJson': c.baseDataJson,
      'viewDataJson': c.viewDataJson,
      'conclusionJson': c.conclusionJson,
      'sourceMetadataJson': c.sourceMetadataJson,
    };
    final meta = RecordMeta(
      uuid: c.uuid,
      scopeUid: scopeUid,
      module: module,
      category: category,
      divinationType: divinationType,
      question: c.question,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({
        'recordUuid': c.uuid,
        'technique': c.technique,
      }),
      occurredAtUtc: null,
      reckoningType: null,
      timezoneStr: null,
      latitude: null,
      longitude: null,
      locationName: null,
      spacetimeJson: null,
      gender: null,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      deletedAt: c.deletedAt,
      rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  YanqinshuDivinationRecordContract decode(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  ) {
    if (meta.module != module) {
      throw RecordCodecMismatch(
        message: 'module mismatch: expected $module got ${meta.module}',
      );
    }
    final d =
        moduleData ??
        (meta.moduleDataJson != null
            ? jsonDecode(meta.moduleDataJson!)
            : const <String, dynamic>{});
    return YanqinshuDivinationRecordContract(
      uuid: meta.uuid,
      question: meta.question,
      technique: d['technique'] as String? ?? 'fate',
      schoolId: d['schoolId'] as String?,
      lunarDateJson: d['lunarDateJson'] as String?,
      ganzhiJson: d['ganzhiJson'] as String?,
      paramsJson: d['paramsJson'] as String?,
      baseDataJson: d['baseDataJson'] as String?,
      viewDataJson: d['viewDataJson'] as String?,
      conclusionJson: d['conclusionJson'] as String?,
      sourceMetadataJson: d['sourceMetadataJson'] as String?,
      createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  ) {
    final d =
        moduleData ??
        (meta.moduleDataJson != null
            ? jsonDecode(meta.moduleDataJson!)
            : const <String, dynamic>{});
    final tags = <SearchTag>[];
    if (d['technique'] != null)
      tags.add(SearchTag('technique', '${d['technique']}'));
    if (d['schoolId'] != null)
      tags.add(SearchTag('school_id', '${d['schoolId']}'));
    return tags;
  }
}
