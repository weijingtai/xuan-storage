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
  Future<String> put(YanqinshuDivinationRecordContract r) => save(r);

  @override
  Future<List<YanqinshuDivinationRecordContract>> query([Map<String, Object?>? criteria]) => getAll();

  @override
  Stream<List<YanqinshuDivinationRecordContract>> watchAll() => super.watchAll();

  @override
  Future<YanqinshuDivinationRecordContract?> get(String u) => getByUuid(u);

  @override
  Future<bool> delete(String u) => softDelete(u);
}
