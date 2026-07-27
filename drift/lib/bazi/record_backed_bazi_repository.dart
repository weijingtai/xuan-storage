import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedBaziRepository
    extends BaseRecordBackedRepository<BaziRecordContract>
    implements BaziRecordRepository {

  RecordBackedBaziRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override
  Future<List<BaziRecordContract>> listRecords(String caseUuid) =>
      getAllByIndex('case_uuid', caseUuid);

  @override
  Future<BaziRecordContract?> getRecord(String uuid) => getByUuid(uuid);

  @override
  Future<void> saveRecord(BaziRecordContract record) async {
    await save(record);
  }

  @override
  Future<void> deleteRecord(String uuid) async {
    await softDelete(uuid);
  }
}
