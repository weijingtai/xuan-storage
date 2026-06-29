import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';
import '../record/base_record_backed_repository.dart';
import 'daliuren_record_codec.dart';

class RecordBackedDaliurenRepository
    extends BaseRecordBackedRepository<DaliurenDivinationRecordContract>
    implements DaliurenRecordRepository {

  RecordBackedDaliurenRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> saveRecord(DaliurenDivinationRecordContract r) => save(r);
  @override Future<List<DaliurenDivinationRecordContract>> getAllRecords() => getAll();
  @override Stream<List<DaliurenDivinationRecordContract>> watchAllRecords() => watchAll();
  @override Future<DaliurenDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);
}
