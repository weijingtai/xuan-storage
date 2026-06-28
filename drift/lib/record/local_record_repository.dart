import 'package:repository_interface_record/repository_interface_record.dart';
import 'drift_record_data_source.dart';
import 'record_adapter_registry.dart';

class LocalRecordRepository implements ScopedRecordStore {
  final DriftRecordDataSource _ds;
  final RecordAdapterRegistry _registry;
  LocalRecordRepository(this._ds, this._registry);

  @override
  String get scopeUid => _ds.scopeUid;

  @override
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) {
    final tags =
        _registry.forModule(record.module)?.extractSearchTags(record, moduleData) ??
            const <SearchTag>[];
    return _ds.saveRecord(record, tags);
  }

  @override
  Future<RecordMeta?> getRecord(String uuid, {required String module}) => _ds.getRecord(uuid);

  @override
  Future<List<RecordMeta>> listRecords({
    required String module,
    String? category,
    String? divinationType,
    required int limit,
    String? cursor,
  }) =>
      _ds.listRecords(
          module: module, category: category, divinationType: divinationType,
          limit: limit, cursor: cursor);

  @override
  Future<bool> softDeleteRecord(String uuid, {required String module}) => _ds.softDeleteRecord(uuid);

  @override
  Stream<List<RecordMeta>> watchRecords({required String module}) =>
      _ds.watchRecords(module: module);

  @override
  Future<List<RecordMeta>> findByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
    required int limit,
  }) =>
      _ds.findByIndex(
          module: module, indexKey: indexKey, indexValue: indexValue, limit: limit);

  @override
  Stream<List<RecordMeta>> watchByIndex({
    required String module,
    required String indexKey,
    required String indexValue,
  }) =>
      _ds.watchByIndex(module: module, indexKey: indexKey, indexValue: indexValue);
}

