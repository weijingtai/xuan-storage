import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
import '../record/base_record_backed_repository.dart';
import 'qimen_record_codec.dart';

class RecordBackedQimenRepository
    extends BaseRecordBackedRepository<QimenDivinationRecordContract>
    implements QimenRecordRepository {

  RecordBackedQimenRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> saveRecord(QimenDivinationRecordContract r) => save(r);
  @override Future<List<QimenDivinationRecordContract>> getAllRecords() => getAll();
  @override Stream<List<QimenDivinationRecordContract>> watchAllRecords() => watchAll();
  @override Future<QimenDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);
}
