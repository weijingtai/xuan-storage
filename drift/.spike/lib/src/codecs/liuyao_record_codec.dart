import 'dart:convert';
import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
import 'package:spike_typed_record_base/src/ports/record_module_codec.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class LiuYaoRecordCodec implements RecordModuleCodec<SixYaoDivinationRecord> {
  @override
  String get module => 'liuyao';

  @override
  String get category => 'divination';

  @override
  String get divinationType => 'liu_yao';

  @override
  String uuidOf(SixYaoDivinationRecord contract) => contract.uuid;

  @override
  SixYaoDivinationRecord withUuid(
      SixYaoDivinationRecord contract, String uuid) {
    return SixYaoDivinationRecord(
      uuid: uuid,
      question: contract.question,
      yaoResults: contract.yaoResults,
      originalGuaId: contract.originalGuaId,
      changedGuaId: contract.changedGuaId,
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt,
      deletedAt: contract.deletedAt,
    );
  }

  @override
  EncodedRecord encode(SixYaoDivinationRecord contract,
      {required String scopeUid}) {
    final yaoJson = contract.yaoResults
        .map((y) => {'index': y.index, 'yaoType': y.yaoType.name})
        .toList();
    final data = <String, dynamic>{
      'yaoResults': yaoJson,
      'originalGuaId': contract.originalGuaId,
      'changedGuaId': contract.changedGuaId,
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
  SixYaoDivinationRecord decode(
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
    final yaoList = (d['yaoResults'] as List<dynamic>?) ?? [];
    final yaoResults = yaoList.map((y) {
      final m = y as Map<String, dynamic>;
      return SixYaoYaoResult(
        index: m['index'] as int,
        yaoType: YaoType.values.firstWhere((t) => t.name == m['yaoType']),
      );
    }).toList();
    return SixYaoDivinationRecord(
      uuid: meta.uuid,
      question: meta.question ?? '',
      yaoResults: yaoResults,
      originalGuaId: d['originalGuaId'] as int,
      changedGuaId: d['changedGuaId'] as int?,
      createdAt: meta.createdAt,
      updatedAt: meta.updatedAt,
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
      SearchTag('original_gua_id', '${d['originalGuaId']}'),
      if (d['changedGuaId'] != null)
        SearchTag('changed_gua_id', '${d['changedGuaId']}'),
    ];
  }
}
