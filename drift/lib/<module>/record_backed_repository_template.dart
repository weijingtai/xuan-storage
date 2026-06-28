import 'package:repository_interface_record/repository_interface_record.dart';
import '../record/base_record_backed_repository.dart';
import 'record_codec_template.dart';

class RecordBackedTemplateRepository
    extends BaseRecordBackedRepository<DummyRecord> {

  RecordBackedTemplateRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  Future<String> saveRecord(DummyRecord r) => save(r);
  Future<DummyRecord?> getRecordByUuid(String u) => getByUuid(u);
  Future<List<DummyRecord>> getAllRecords() => getAll();
  Future<bool> softDeleteRecord(String u) => softDelete(u);
}
