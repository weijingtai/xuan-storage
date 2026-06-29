import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import '../record/base_record_backed_repository.dart';
import 'tieban_record_codec.dart';

class RecordBackedTiebanRepository
    extends BaseRecordBackedRepository<TiebanDivinationRecordContract>
    implements TiebanRecordRepository {

  RecordBackedTiebanRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> saveRecord(TiebanDivinationRecordContract r) => save(r);
  @override Future<List<TiebanDivinationRecordContract>> getAllRecords() => getAll();
  @override Stream<List<TiebanDivinationRecordContract>> watchAllRecords() => watchAll();
  @override Future<TiebanDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);
}
