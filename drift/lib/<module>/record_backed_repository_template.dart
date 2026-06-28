import 'package:repository_interface_<module>/repository_interface_<module>.dart';
import '../record/base_record_backed_repository.dart';
import 'record_codec_template.dart'; // 假定在该目录下

class RecordBacked<Module>Repository
    extends BaseRecordBackedRepository<<Module>RecordContract>
    implements <Module>RecordRepository {

  RecordBacked<Module>Repository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override Future<String> saveRecord(<Module>RecordContract r) => save(r);
  @override Future<<Module>RecordContract?> getRecordByUuid(String u) => getByUuid(u);
  @override Future<List<<Module>RecordContract>> getAllRecords() => getAll();
  @override Future<bool> softDeleteRecord(String u) => softDelete(u);

  // 模块特有方法示例:
  // @override Future<List<T>> getLatestRecords({int limit = 10}) => getLatest(limit: limit);
  // @override Future<T?> getRecordByXxx(String x) => getFirstByIndex('xxx', x);
}
