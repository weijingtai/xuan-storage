import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedQimenRepository
    extends BaseRecordBackedRepository<QimenDivinationRecordContract>
    implements QimenRecordRepository {

  RecordBackedQimenRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> put(QimenDivinationRecordContract r) => save(r);
  @override Future<List<QimenDivinationRecordContract>> query([Map<String, Object?>? criteria]) => getAll();
  @override Stream<List<QimenDivinationRecordContract>> watchAll() => watchAll();
  @override Future<QimenDivinationRecordContract?> get(String u) => getByUuid(u);
  @override Future<bool> delete(String u) => softDelete(u);
}
