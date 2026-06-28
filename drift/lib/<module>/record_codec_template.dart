import 'dart:convert';
import 'package:repository_interface_record/repository_interface_record.dart';

// Template class demonstrating how to implement RecordModuleCodec.
// Replace `DummyRecord` with the actual record contract type.
class DummyRecord {
  final String uuid;
  final String question;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  DummyRecord({
    required this.uuid,
    required this.question,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
}

class TemplateRecordCodec implements RecordModuleCodec<DummyRecord> {
  @override String get module => 'template_module';
  @override String get category => 'divination';
  @override String get divinationType => 'template_type';

  @override String uuidOf(DummyRecord c) => c.uuid;

  @override
  DummyRecord withUuid(DummyRecord c, String uuid) {
    return DummyRecord(
      uuid: uuid,
      question: c.question,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      deletedAt: c.deletedAt,
    );
  }

  @override
  EncodedRecord encode(DummyRecord c, {required String scopeUid}) {
    final data = <String, dynamic>{};
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
  DummyRecord decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return DummyRecord(
      uuid: meta.uuid,
      question: meta.question ?? '',
      createdAt: meta.createdAt,
      updatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return [
      SearchTag('example_key', '${d['example_value'] ?? ''}'),
    ];
  }
}
