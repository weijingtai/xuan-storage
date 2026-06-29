import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedQiZhengRepository
    extends BaseRecordBackedRepository<QiZhengSiYuPanContract>
    implements QiZhengRecordRepository {

  RecordBackedQiZhengRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> saveRecord(QiZhengSiYuPanContract r) => save(r);
  @override Future<List<QiZhengSiYuPanContract>> getAllRecords() => getAll();
  @override Stream<List<QiZhengSiYuPanContract>> watchAllRecords() => watchAll();
  @override Future<QiZhengSiYuPanContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);
}
