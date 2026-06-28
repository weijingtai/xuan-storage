import 'dart:convert';
import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class LiuYaoRecordCodec implements RecordModuleCodec<SixYaoDivinationRecord> {
  @override String get module => 'liuyao';
  @override String get category => 'divination';
  @override String get divinationType => 'liu_yao';

  @override String uuidOf(SixYaoDivinationRecord c) => c.uuid;

  @override
  SixYaoDivinationRecord withUuid(SixYaoDivinationRecord c, String uuid) {
    return SixYaoDivinationRecord(
      uuid: uuid, question: c.question, yaoResults: c.yaoResults,
      originalGuaId: c.originalGuaId, changedGuaId: c.changedGuaId,
      createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(SixYaoDivinationRecord c, {required String scopeUid}) {
    final yaoJson = c.yaoResults.map((y) => {'index': y.index, 'yaoType': y.yaoType.name}).toList();
    final data = <String, dynamic>{'yaoResults': yaoJson, 'originalGuaId': c.originalGuaId, 'changedGuaId': c.changedGuaId};
    final meta = RecordMeta(
      uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType, question: c.question,
      moduleDataJson: jsonEncode(data), navParamsJson: jsonEncode({'recordUuid': c.uuid}),
      createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt, rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  SixYaoDivinationRecord decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final yaoList = (d['yaoResults'] as List<dynamic>?) ?? [];
    final yaoResults = yaoList.map((y) {
      final m = y as Map<String, dynamic>;
      return SixYaoYaoResult(index: m['index'], yaoType: YaoType.values.firstWhere((t) => t.name == m['yaoType']));
    }).toList();
    return SixYaoDivinationRecord(
      uuid: meta.uuid, question: meta.question ?? '', yaoResults: yaoResults,
      originalGuaId: d['originalGuaId'], changedGuaId: d['changedGuaId'],
      createdAt: meta.createdAt, updatedAt: meta.updatedAt, deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return [
      SearchTag('original_gua_id', '${d['originalGuaId']}'),
      if (d['changedGuaId'] != null) SearchTag('changed_gua_id', '${d['changedGuaId']}'),
    ];
  }
}
