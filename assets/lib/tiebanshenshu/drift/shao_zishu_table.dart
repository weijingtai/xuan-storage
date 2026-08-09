import 'package:drift/drift.dart';

/// 少子术文档表（datasetId: `tiebanshenshu.shaozishu`）。
///
/// 源数据：12 个地支 txt（如 子.txt，511 行），整文件存取，
/// 消费方（shaozi_tiao_wen_repository）按行解析。TXT 非 JSON，
/// 载荷列命名为 `payload_text`。
@DataClassName('ShaoZiShuDocumentEntry')
class ShaoZiShuDocuments extends Table {
  @override
  String get tableName => 'shaozishu_document';

  TextColumn get fileName => text().named('file_name')();
  TextColumn get payloadText => text().named('payload_text')();

  @override
  Set<Column> get primaryKey => {fileName};
}
