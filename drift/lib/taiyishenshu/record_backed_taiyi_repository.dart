import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedTaiyiRepository
    extends BaseRecordBackedRepository<TaiyiDivinationRecordContract>
    implements TaiyiRecordRepository {

  RecordBackedTaiyiRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> put(TaiyiDivinationRecordContract r) => save(r);
  @override Future<List<TaiyiDivinationRecordContract>> query([Map<String, Object?>? criteria]) => getAll();
  @override Stream<List<TaiyiDivinationRecordContract>> watchByIndex([Map<String, Object?>? criteria]) => watchAll();
  @override Future<TaiyiDivinationRecordContract?> get(String id) => getByUuid(id);
  @override Future<bool> delete(String id) => softDelete(id);
}
