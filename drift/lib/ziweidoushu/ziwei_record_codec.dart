import 'dart:convert';
import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class ZiweiRecordCodec implements RecordModuleCodec<ZiweiDivinationRecordContract> {
  @override String get module => 'ziweidoushu';
  @override String get category => 'divination';
  @override String get divinationType => 'zi_wei';

  @override String uuidOf(ZiweiDivinationRecordContract c) => c.uuid;

  @override
  ZiweiDivinationRecordContract withUuid(ZiweiDivinationRecordContract c, String uuid) {
    return ZiweiDivinationRecordContract(
      uuid: uuid, question: c.question, birthDatetimeJson: c.birthDatetimeJson,
      isMale: c.isMale, chartRequestJson: c.chartRequestJson,
      chartResultJson: c.chartResultJson,
      fourTransformationsJson: c.fourTransformationsJson,
      paramsJson: c.paramsJson, createdAt: c.createdAt,
      updatedAt: c.updatedAt, deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(ZiweiDivinationRecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'birthDatetimeJson': c.birthDatetimeJson, 'isMale': c.isMale,
      'chartRequestJson': c.chartRequestJson, 'chartResultJson': c.chartResultJson,
      'fourTransformationsJson': c.fourTransformationsJson,
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
  ZiweiDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return ZiweiDivinationRecordContract(
      uuid: meta.uuid, question: meta.question,
      birthDatetimeJson: d['birthDatetimeJson'], isMale: d['isMale'],
      chartRequestJson: d['chartRequestJson'], chartResultJson: d['chartResultJson'],
      fourTransformationsJson: d['fourTransformationsJson'],
      paramsJson: d['paramsJson'], createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt, deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final tags = <SearchTag>[];
    if (d['birthDatetimeJson'] != null) tags.add(SearchTag('birth_datetime', '${d['birthDatetimeJson']}'));
    return tags;
  }
}
