import 'dart:convert';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class QiZhengRecordCodec implements RecordModuleCodec<QiZhengSiYuPanContract> {
  @override String get module => 'qizhengsiyu';
  @override String get category => 'divination';
  @override String get divinationType => 'qi_zheng';

  @override String uuidOf(QiZhengSiYuPanContract c) => c.uuid;

  @override
  QiZhengSiYuPanContract withUuid(QiZhengSiYuPanContract c, String uuid) {
    return QiZhengSiYuPanContract(
      uuid: uuid,
      createdAt: c.createdAt,
      lastUpdatedAt: c.lastUpdatedAt,
      deletedAt: c.deletedAt,
      divinationRequestInfoUuid: c.divinationRequestInfoUuid,
      divinationDatetimeJson: c.divinationDatetimeJson,
      panelConfigJson: c.panelConfigJson,
      panelModelJson: c.panelModelJson,
    );
  }

  @override
  EncodedRecord encode(QiZhengSiYuPanContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'divinationRequestInfoUuid': c.divinationRequestInfoUuid,
      'divinationDatetimeJson': c.divinationDatetimeJson,
      'panelConfigJson': c.panelConfigJson,
      'panelModelJson': c.panelModelJson,
    };
    final meta = RecordMeta(
      uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': c.uuid}),
      createdAt: c.createdAt, updatedAt: c.lastUpdatedAt,
      deletedAt: c.deletedAt, rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  QiZhengSiYuPanContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return QiZhengSiYuPanContract(
      uuid: meta.uuid, createdAt: meta.createdAt,
      lastUpdatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
      divinationRequestInfoUuid: d['divinationRequestInfoUuid'],
      divinationDatetimeJson: d['divinationDatetimeJson'],
      panelConfigJson: d['panelConfigJson'],
      panelModelJson: d['panelModelJson'],
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final tags = <SearchTag>[];
    final requestUuid = d['divinationRequestInfoUuid'];
    if (requestUuid != null && '$requestUuid'.isNotEmpty) {
      tags.add(SearchTag('divination_request_info_uuid', '$requestUuid'));
    }
    return tags;
  }
}
