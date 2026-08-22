import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedDaliurenRepository
    extends BaseRecordBackedRepository<DaliurenDivinationRecordContract>
    implements DaliurenRecordRepository {

  RecordBackedDaliurenRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> put(DaliurenDivinationRecordContract r) => save(r);
  @override Future<List<DaliurenDivinationRecordContract>> query([Map<String, Object?>? criteria]) => getAll();
  @override Stream<List<DaliurenDivinationRecordContract>> watchAll() => watchAll();
  @override Future<DaliurenDivinationRecordContract?> get(String id) => getByUuid(id);
  @override Future<bool> delete(String id) => softDelete(id);
}
