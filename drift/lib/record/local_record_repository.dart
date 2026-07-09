import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import '../sync/record_outbox_mapper.dart';
import 'drift_record_data_source.dart';
import 'record_adapter_registry.dart';

class LocalRecordRepository implements ScopedRecordStore {
  final DriftRecordDataSource _ds;
  final RecordAdapterRegistry _registry;
  final OutboxStore? _outboxStore;

  LocalRecordRepository(this._ds, this._registry, {OutboxStore? outboxStore})
      : _outboxStore = outboxStore;

  @override
  String get scopeUid => _ds.scopeUid;

  @override
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) async {
    final tags =
        _registry.forModule(record.module)?.extractSearchTags(record, moduleData) ??
            const <SearchTag>[];
    await _ds.saveRecord(record, tags);

    if (_outboxStore != null) {
      try {
        final outboxRecord = RecordOutboxMapper.toOutboxRecord(
          meta: record, moduleData: moduleData, tags: tags, opType: RecordOutboxMapper.opUpsert,
        );
        await _outboxStore!.enqueue(outboxRecord);
      } catch (_) {
      }
    }
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
  Future<bool> softDeleteRecord(String uuid, {required String module}) async {
    final deleted = await _ds.softDeleteRecord(uuid);
    if (deleted && _outboxStore != null) {
      try {
        final meta = await _ds.getRecord(uuid);
        if (meta != null) {
          final outboxRecord = RecordOutboxMapper.toOutboxRecord(
            meta: meta, opType: RecordOutboxMapper.opDelete,
          );
          await _outboxStore!.enqueue(outboxRecord);
        }
      } catch (_) {
      }
    }
    return deleted;
  }

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

