import 'dart:convert';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class MeihuaRecordAdapter implements ModuleRecordAdapter, RecordModuleCodec<MeiHuaDivinationRecordContract> {
  final String scopeUid;
  MeihuaRecordAdapter({required this.scopeUid});

  @override String get module => 'meihua';
  @override String get category => 'divination';
  @override String get divinationType => 'mei_hua';

  @override String uuidOf(MeiHuaDivinationRecordContract c) => c.uuid;

  @override
  MeiHuaDivinationRecordContract withUuid(MeiHuaDivinationRecordContract c, String uuid) {
    return MeiHuaDivinationRecordContract(
      uuid: uuid,
      divinationUuid: c.divinationUuid.isNotEmpty ? c.divinationUuid : uuid,
      question: c.question,
      originalUpperGua: c.originalUpperGua,
      originalLowerGua: c.originalLowerGua,
      changingYao: c.changingYao,
      changedUpperGua: c.changedUpperGua,
      changedLowerGua: c.changedLowerGua,
      huUpperGua: c.huUpperGua,
      huLowerGua: c.huLowerGua,
      method: c.method,
      paramsJson: c.paramsJson,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(MeiHuaDivinationRecordContract c, {required String scopeUid}) {
    final res = toRecord(c);
    final meta = res.meta;
    if (meta.scopeUid == scopeUid) {
      return res;
    }
    return (
      meta: RecordMeta(
        uuid: meta.uuid,
        scopeUid: scopeUid,
        module: meta.module,
        category: meta.category,
        divinationType: meta.divinationType,
        question: meta.question,
        moduleDataJson: meta.moduleDataJson,
        navParamsJson: meta.navParamsJson,
        createdAt: meta.createdAt,
        updatedAt: meta.updatedAt,
        deletedAt: meta.deletedAt,
        rev: meta.rev,
      ),
      moduleData: res.moduleData,
    );
  }

  @override
  MeiHuaDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    return fromRecord(meta, moduleData) as MeiHuaDivinationRecordContract;
  }

  @override
  ({RecordMeta meta, Map<String, dynamic>? moduleData}) toRecord(Object m) {
    final r = m as MeiHuaDivinationRecordContract;
    final data = <String, dynamic>{
      'divinationUuid': r.divinationUuid,
      'originalUpperGua': r.originalUpperGua,
      'originalLowerGua': r.originalLowerGua,
      'changingYao': r.changingYao,
      'changedUpperGua': r.changedUpperGua,
      'changedLowerGua': r.changedLowerGua,
      'huUpperGua': r.huUpperGua,
      'huLowerGua': r.huLowerGua,
      'method': r.method,
      'paramsJson': r.paramsJson,
    };
    final meta = RecordMeta(
      uuid: r.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType, question: r.question,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': r.uuid}),
      createdAt: r.createdAt, updatedAt: r.updatedAt, deletedAt: r.deletedAt,
      rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  Object fromRecord(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ??
        (meta.moduleDataJson == null
            ? const <String, dynamic>{}
            : jsonDecode(meta.moduleDataJson!) as Map<String, dynamic>);
    return MeiHuaDivinationRecordContract(
      uuid: meta.uuid,
      divinationUuid: d['divinationUuid'] as String? ?? meta.uuid,
      question: meta.question,
      originalUpperGua: d['originalUpperGua'] as int,
      originalLowerGua: d['originalLowerGua'] as int,
      changingYao: d['changingYao'] as int,
      changedUpperGua: d['changedUpperGua'] as int,
      changedLowerGua: d['changedLowerGua'] as int,
      huUpperGua: d['huUpperGua'] as int,
      huLowerGua: d['huLowerGua'] as int,
      method: d['method'] as String,
      paramsJson: d['paramsJson'] as String,
      createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ??
        (meta.moduleDataJson == null
            ? const <String, dynamic>{}
            : jsonDecode(meta.moduleDataJson!) as Map<String, dynamic>);
    return [
      SearchTag('upper_gua', '${d['originalUpperGua']}'),
      SearchTag('lower_gua', '${d['originalLowerGua']}'),
      SearchTag('changing_yao', '${d['changingYao']}'),
      SearchTag('divination_uuid', '${d['divinationUuid']}'),
    ];
  }
}
