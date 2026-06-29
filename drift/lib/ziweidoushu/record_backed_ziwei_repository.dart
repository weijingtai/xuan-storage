import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedZiweiRepository
    extends BaseRecordBackedRepository<ZiweiDivinationRecordContract>
    implements ZiweiRecordRepository {

  RecordBackedZiweiRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> saveRecord(ZiweiDivinationRecordContract r) => save(r);
  @override Future<List<ZiweiDivinationRecordContract>> getAllRecords() => getAll();
  @override Stream<List<ZiweiDivinationRecordContract>> watchAllRecords() => watchAll();
  @override Future<ZiweiDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);
}
