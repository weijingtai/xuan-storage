import 'dart:convert';
import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class QimenRecordCodec implements RecordModuleCodec<QimenDivinationRecordContract> {
  @override String get module => 'qimendunjia';
  @override String get category => 'divination';
  @override String get divinationType => 'qi_men';

  @override String uuidOf(QimenDivinationRecordContract c) => c.uuid;

  @override
  QimenDivinationRecordContract withUuid(QimenDivinationRecordContract c, String uuid) {
    return QimenDivinationRecordContract(
      uuid: uuid, question: c.question, datetimeJson: c.datetimeJson,
      juType: c.juType, juNumber: c.juNumber, paiPanJson: c.paiPanJson,
      shiJiJson: c.shiJiJson, yueJiangJson: c.yueJiangJson,
      paramsJson: c.paramsJson, createdAt: c.createdAt,
      updatedAt: c.updatedAt, deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(QimenDivinationRecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'datetimeJson': c.datetimeJson, 'juType': c.juType,
      'juNumber': c.juNumber, 'paiPanJson': c.paiPanJson,
      'shiJiJson': c.shiJiJson, 'yueJiangJson': c.yueJiangJson,
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
  QimenDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return QimenDivinationRecordContract(
      uuid: meta.uuid, question: meta.question, datetimeJson: d['datetimeJson'],
      juType: d['juType'], juNumber: d['juNumber'], paiPanJson: d['paiPanJson'],
      shiJiJson: d['shiJiJson'], yueJiangJson: d['yueJiangJson'],
      paramsJson: d['paramsJson'], createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt, deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final tags = <SearchTag>[];
    if (d['juType'] != null) tags.add(SearchTag('ju_type', '${d['juType']}'));
    if (d['juNumber'] != null) tags.add(SearchTag('ju_number', '${d['juNumber']}'));
    return tags;
  }
}
