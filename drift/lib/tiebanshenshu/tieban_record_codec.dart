import 'dart:convert';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class TiebanRecordCodec implements RecordModuleCodec<TiebanDivinationRecordContract> {
  @override String get module => 'tiebanshenshu';
  @override String get category => 'divination';
  @override String get divinationType => 'tie_ban';

  @override String uuidOf(TiebanDivinationRecordContract c) => c.uuid;

  @override
  TiebanDivinationRecordContract withUuid(TiebanDivinationRecordContract c, String uuid) {
    return TiebanDivinationRecordContract(
      uuid: uuid, question: c.question, birthDatetimeJson: c.birthDatetimeJson,
      birthGanZhiJson: c.birthGanZhiJson, calculationResultJson: c.calculationResultJson,
      matchedTiaoWenIdsJson: c.matchedTiaoWenIdsJson, paramsJson: c.paramsJson,
      createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(TiebanDivinationRecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'birthDatetimeJson': c.birthDatetimeJson, 'birthGanZhiJson': c.birthGanZhiJson,
      'calculationResultJson': c.calculationResultJson,
      'matchedTiaoWenIdsJson': c.matchedTiaoWenIdsJson,
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
  TiebanDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return TiebanDivinationRecordContract(
      uuid: meta.uuid, question: meta.question,
      birthDatetimeJson: d['birthDatetimeJson'], birthGanZhiJson: d['birthGanZhiJson'],
      calculationResultJson: d['calculationResultJson'],
      matchedTiaoWenIdsJson: d['matchedTiaoWenIdsJson'],
      paramsJson: d['paramsJson'], createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt, deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final tags = <SearchTag>[];
    if (d['birthGanZhiJson'] != null) tags.add(SearchTag('birth_gan_zhi', '${d['birthGanZhiJson']}'));
    return tags;
  }
}
