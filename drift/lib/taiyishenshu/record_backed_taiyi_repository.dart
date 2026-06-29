import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import '../record/base_record_backed_repository.dart';
import 'taiyi_record_codec.dart';

class RecordBackedTaiyiRepository
    extends BaseRecordBackedRepository<TaiyiDivinationRecordContract>
    implements TaiyiRecordRepository {

  RecordBackedTaiyiRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> saveRecord(TaiyiDivinationRecordContract r) => save(r);
  @override Future<List<TaiyiDivinationRecordContract>> getAllRecords() => getAll();
  @override Stream<List<TaiyiDivinationRecordContract>> watchAllRecords() => watchAll();
  @override Future<TaiyiDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);
}
