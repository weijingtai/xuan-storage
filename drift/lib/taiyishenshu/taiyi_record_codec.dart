import 'dart:convert';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class TaiyiRecordCodec implements RecordModuleCodec<TaiyiDivinationRecordContract> {
  @override String get module => 'taiyishenshu';
  @override String get category => 'divination';
  @override String get divinationType => 'tai_yi';

  @override String uuidOf(TaiyiDivinationRecordContract c) => c.uuid;

  @override
  TaiyiDivinationRecordContract withUuid(TaiyiDivinationRecordContract c, String uuid) {
    return TaiyiDivinationRecordContract(
      uuid: uuid, question: c.question, datetimeJson: c.datetimeJson,
      schoolId: c.schoolId, juNumber: c.juNumber,
      taiYiPalaceJson: c.taiYiPalaceJson, ninePalaceJson: c.ninePalaceJson,
      deitiesJson: c.deitiesJson, paramsJson: c.paramsJson,
      createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(TaiyiDivinationRecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'datetimeJson': c.datetimeJson, 'schoolId': c.schoolId,
      'juNumber': c.juNumber, 'taiYiPalaceJson': c.taiYiPalaceJson,
      'ninePalaceJson': c.ninePalaceJson, 'deitiesJson': c.deitiesJson,
      'paramsJson': c.paramsJson,
    };
    final meta = RecordMeta(
      uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType, question: c.question,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': c.uuid}),
      createdAt: c.createdAt, updatedAt: c.updatedAt,
      deletedAt: c.deletedAt, rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  TaiyiDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return TaiyiDivinationRecordContract(
      uuid: meta.uuid, question: meta.question, datetimeJson: d['datetimeJson'],
      schoolId: d['schoolId'], juNumber: d['juNumber'],
      taiYiPalaceJson: d['taiYiPalaceJson'], ninePalaceJson: d['ninePalaceJson'],
      deitiesJson: d['deitiesJson'], paramsJson: d['paramsJson'],
      createdAt: meta.createdAt, updatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final tags = <SearchTag>[];
    if (d['schoolId'] != null) tags.add(SearchTag('school_id', '${d['schoolId']}'));
    return tags;
  }
}
