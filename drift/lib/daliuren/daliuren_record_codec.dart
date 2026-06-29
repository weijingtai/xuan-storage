import 'dart:convert';
import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class DaliurenRecordCodec implements RecordModuleCodec<DaliurenDivinationRecordContract> {
  @override String get module => 'daliuren';
  @override String get category => 'divination';
  @override String get divinationType => 'da_liu_ren';

  @override String uuidOf(DaliurenDivinationRecordContract c) => c.uuid;

  @override
  DaliurenDivinationRecordContract withUuid(DaliurenDivinationRecordContract c, String uuid) {
    return DaliurenDivinationRecordContract(
      uuid: uuid, question: c.question, lunarDateJson: c.lunarDateJson,
      ganzhiJson: c.ganzhiJson, juNumber: c.juNumber, juName: c.juName,
      schoolId: c.schoolId, yueJiangJson: c.yueJiangJson,
      riYueJson: c.riYueJson, sanChuanJson: c.sanChuanJson,
      siKeJson: c.siKeJson, twelveTianJinJson: c.twelveTianJinJson,
      paramsJson: c.paramsJson, createdAt: c.createdAt,
      updatedAt: c.updatedAt, deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(DaliurenDivinationRecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'question': c.question, 'lunarDateJson': c.lunarDateJson,
      'ganzhiJson': c.ganzhiJson, 'juNumber': c.juNumber,
      'juName': c.juName, 'schoolId': c.schoolId,
      'yueJiangJson': c.yueJiangJson, 'riYueJson': c.riYueJson,
      'sanChuanJson': c.sanChuanJson, 'siKeJson': c.siKeJson,
      'twelveTianJinJson': c.twelveTianJinJson, 'paramsJson': c.paramsJson,
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
  DaliurenDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return DaliurenDivinationRecordContract(
      uuid: meta.uuid, question: meta.question, lunarDateJson: d['lunarDateJson'],
      ganzhiJson: d['ganzhiJson'], juNumber: d['juNumber'], juName: d['juName'],
      schoolId: d['schoolId'], yueJiangJson: d['yueJiangJson'],
      riYueJson: d['riYueJson'], sanChuanJson: d['sanChuanJson'],
      siKeJson: d['siKeJson'], twelveTianJinJson: d['twelveTianJinJson'],
      paramsJson: d['paramsJson'], createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt, deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final tags = <SearchTag>[];
    if (d['schoolId'] != null) tags.add(SearchTag('school_id', '${d['schoolId']}'));
    if (d['juName'] != null) tags.add(SearchTag('ju_name', '${d['juName']}'));
    return tags;
  }
}
