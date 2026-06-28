import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedMeiHuaRepository
    extends BaseRecordBackedRepository<MeiHuaDivinationRecordContract>
    implements MeiHuaDivinationRecordRepository {

  RecordBackedMeiHuaRepository(
    ScopedRecordStore store,
    RecordModuleCodec<MeiHuaDivinationRecordContract> codec, [
    dynamic _,
  ]) : super(store: store, codec: codec);

  @override Future<String> saveRecord(MeiHuaDivinationRecordContract r) => save(r);
  @override Future<List<MeiHuaDivinationRecordContract>> getAllRecords() => getAll();
  @override Stream<List<MeiHuaDivinationRecordContract>> watchAllRecords() => watchAll();
  @override Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(String d) =>
      getFirstByIndex('divination_uuid', d);
  @override Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(String d) =>
      watchFirstByIndex('divination_uuid', d);
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);
}
