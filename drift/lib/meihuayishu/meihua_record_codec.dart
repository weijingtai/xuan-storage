import 'dart:convert';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class MeiHuaRecordCodec implements RecordModuleCodec<MeiHuaDivinationRecordContract> {
  @override String get module => 'meihua';
  @override String get category => 'divination';
  @override String get divinationType => 'mei_hua';

  @override String uuidOf(MeiHuaDivinationRecordContract c) => c.uuid;

  @override
  MeiHuaDivinationRecordContract withUuid(MeiHuaDivinationRecordContract c, String uuid) {
    return MeiHuaDivinationRecordContract(
      uuid: uuid, divinationUuid: c.divinationUuid.isNotEmpty ? c.divinationUuid : uuid,
      question: c.question, originalUpperGua: c.originalUpperGua,
      originalLowerGua: c.originalLowerGua, changingYao: c.changingYao,
      changedUpperGua: c.changedUpperGua, changedLowerGua: c.changedLowerGua,
      huUpperGua: c.huUpperGua, huLowerGua: c.huLowerGua,
      method: c.method, paramsJson: c.paramsJson,
      createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(MeiHuaDivinationRecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'divinationUuid': c.divinationUuid, 'originalUpperGua': c.originalUpperGua,
      'originalLowerGua': c.originalLowerGua, 'changingYao': c.changingYao,
      'changedUpperGua': c.changedUpperGua, 'changedLowerGua': c.changedLowerGua,
      'huUpperGua': c.huUpperGua, 'huLowerGua': c.huLowerGua,
      'method': c.method, 'paramsJson': c.paramsJson,
    };
    final meta = RecordMeta(
      uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType, question: c.question,
      moduleDataJson: jsonEncode(data), navParamsJson: jsonEncode({'recordUuid': c.uuid}),
      createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt, rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  MeiHuaDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return MeiHuaDivinationRecordContract(
      uuid: meta.uuid, divinationUuid: d['divinationUuid'] ?? meta.uuid,
      question: meta.question, originalUpperGua: d['originalUpperGua'],
      originalLowerGua: d['originalLowerGua'], changingYao: d['changingYao'],
      changedUpperGua: d['changedUpperGua'], changedLowerGua: d['changedLowerGua'],
      huUpperGua: d['huUpperGua'], huLowerGua: d['huLowerGua'],
      method: d['method'], paramsJson: d['paramsJson'],
      createdAt: meta.createdAt, updatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return [
      SearchTag('divination_uuid', '${d['divinationUuid']}'),
      SearchTag('upper_gua', '${d['originalUpperGua']}'),
      SearchTag('lower_gua', '${d['originalLowerGua']}'),
      SearchTag('changing_yao', '${d['changingYao']}'),
    ];
  }
}
