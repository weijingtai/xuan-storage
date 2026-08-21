import 'package:repository_interface_yanqinshu/repository_interface_yanqinshu.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedYanqinshuRepository
    extends BaseRecordBackedRepository<YanqinshuDivinationRecordContract>
    implements YanqinshuRecordRepository {

  RecordBackedYanqinshuRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override
  Future<String> saveRecord(YanqinshuDivinationRecordContract r) => save(r);

  @override
  Future<List<YanqinshuDivinationRecordContract>> getAllRecords() => getAll();

  @override
  Stream<List<YanqinshuDivinationRecordContract>> watchAllRecords() => watchAll();

  @override
  Future<YanqinshuDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);

  @override
  Future<bool> softDeleteRecord(String u) => softDelete(u);
}
