import 'dart:convert';
import 'package:repository_interface_<module>/repository_interface_<module>.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class <Module>RecordCodec implements RecordModuleCodec<<Module>RecordContract> {
  @override String get module => '<module_key>';        // snake_case, 与 t_record_meta.module 一致
  @override String get category => 'divination';        // 或 'destiny'
  @override String get divinationType => '<type_key>';  // snake_case

  @override String uuidOf(<Module>RecordContract c) => c.uuid;

  @override
  <Module>RecordContract withUuid(<Module>RecordContract c, String uuid) {
    return <Module>RecordContract(
      uuid: uuid,
      // ... 复制其他字段，派生字段 (如 divinationUuid) 空时填 uuid
    );
  }

  @override
  EncodedRecord encode(<Module>RecordContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      // ... 模块特有字段
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
  <Module>RecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return <Module>RecordContract(
      uuid: meta.uuid,
      // ... 从 d 中读取字段
      createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return [
      // 定义搜索索引标签，key 使用 snake_case
      SearchTag('<index_key>', '${d['<field>']}'),
    ];
  }
}
