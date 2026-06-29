import 'dart:convert';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:spike_typed_record_base/src/ports/record_module_codec.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class MeiHuaRecordCodec implements RecordModuleCodec<MeiHuaDivinationRecordContract> {
  @override
  String get module => 'meihua';

  @override
  String get category => 'divination';

  @override
  String get divinationType => 'mei_hua';

  @override
  String uuidOf(MeiHuaDivinationRecordContract contract) => contract.uuid;

  @override
  MeiHuaDivinationRecordContract withUuid(
      MeiHuaDivinationRecordContract contract, String uuid) {
    return MeiHuaDivinationRecordContract(
      uuid: uuid,
      divinationUuid:
          contract.divinationUuid.isNotEmpty ? contract.divinationUuid : uuid,
      question: contract.question,
      originalUpperGua: contract.originalUpperGua,
      originalLowerGua: contract.originalLowerGua,
      changingYao: contract.changingYao,
      changedUpperGua: contract.changedUpperGua,
      changedLowerGua: contract.changedLowerGua,
      huUpperGua: contract.huUpperGua,
      huLowerGua: contract.huLowerGua,
      method: contract.method,
      paramsJson: contract.paramsJson,
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt,
      deletedAt: contract.deletedAt,
    );
  }

  @override
  EncodedRecord encode(MeiHuaDivinationRecordContract contract,
      {required String scopeUid}) {
    final data = <String, dynamic>{
      'divinationUuid': contract.divinationUuid,
      'originalUpperGua': contract.originalUpperGua,
      'originalLowerGua': contract.originalLowerGua,
      'changingYao': contract.changingYao,
      'changedUpperGua': contract.changedUpperGua,
      'changedLowerGua': contract.changedLowerGua,
      'huUpperGua': contract.huUpperGua,
      'huLowerGua': contract.huLowerGua,
      'method': contract.method,
      'paramsJson': contract.paramsJson,
    };
    final meta = RecordMeta(
      uuid: contract.uuid,
      scopeUid: scopeUid,
      module: module,
      category: category,
      divinationType: divinationType,
      question: contract.question,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': contract.uuid}),
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt,
      deletedAt: contract.deletedAt,
      rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  MeiHuaDivinationRecordContract decode(
      RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) {
      throw RecordCodecMismatch(
        message: 'Expected module $module, got ${meta.module}',
      );
    }
    final d = moduleData ??
        (meta.moduleDataJson != null
            ? jsonDecode(meta.moduleDataJson!) as Map<String, dynamic>
            : const <String, dynamic>{});
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
  List<SearchTag> extractSearchTags(
      RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ??
        (meta.moduleDataJson != null
            ? jsonDecode(meta.moduleDataJson!) as Map<String, dynamic>
            : const <String, dynamic>{});
    return [
      SearchTag('divination_uuid', '${d['divinationUuid']}'),
      SearchTag('upper_gua', '${d['originalUpperGua']}'),
      SearchTag('lower_gua', '${d['originalLowerGua']}'),
      SearchTag('changing_yao', '${d['changingYao']}'),
    ];
  }
}
