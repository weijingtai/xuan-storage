import 'package:repository_interface_record/repository_interface_record.dart';
import 'drift_record_data_source.dart';
import 'record_adapter_registry.dart';

class LocalRecordRepository implements RecordRepository {
  final DriftRecordDataSource _ds;
  final RecordAdapterRegistry _registry;
  LocalRecordRepository(this._ds, this._registry);

  @override
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) {
    final tags =
        _registry.forModule(record.module)?.extractSearchTags(record, moduleData) ??
            const <SearchTag>[];
    return _ds.saveRecord(record, tags);
  }

  @override
  Future<RecordMeta?> getRecord(String uuid) => _ds.getRecord(uuid);

  @override
  Future<List<RecordMeta>> listRecords({
    String? module, String? category, String? divinationType,
    int limit = 50, String? cursor,
  }) =>
      _ds.listRecords(
          module: module, category: category, divinationType: divinationType,
          limit: limit, cursor: cursor);

  @override
  Future<bool> softDeleteRecord(String uuid) => _ds.softDeleteRecord(uuid);

  @override
  Stream<List<RecordMeta>> watchRecords({String? module, String? category}) =>
      _ds.watchRecords(module: module, category: category);
}
