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
  Future<bool> delete(String u) => softDeleteLegacy(u);

  // ── 遗留别名（旧调用方与既有测试的过渡层，M4 随适配层一并退场） ──

  @Deprecated('M4 退场：改用 L0 切片')
  Future<String> saveRecord(YanqinshuDivinationRecordContract r) => save(r);

  @Deprecated('M4 退场：改用 L0 切片')
  Future<List<YanqinshuDivinationRecordContract>> getAllRecords() => getAll();

  @Deprecated('M4 退场：改用 L0 切片')
  Future<YanqinshuDivinationRecordContract?> getRecordByUuid(String uuid) => getByUuid(uuid);

  @Deprecated('M4 退场：改用 L0 切片')
  Future<bool> softDeleteRecord(String uuid) => softDeleteLegacy(uuid);

  @Deprecated('M4 退场：改用 L0 切片')
  Stream<List<YanqinshuDivinationRecordContract>> watchAllRecords() => watchAll();
}
