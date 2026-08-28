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

  OutboxStore? get _outbox => _outboxStore;

  @override
  String get scopeUid => _ds.scopeUid;

  @override
  Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) async {
    final tags =
        _registry.forModule(record.module)?.extractSearchTags(record, moduleData) ??
            const <SearchTag>[];

    await _ds.db.transaction(() async {
      await _ds.saveRecord(record, tags);

      final outbox = _outbox;
      if (outbox != null) {
        final outboxRecord = RecordOutboxMapper.toOutboxRecord(
          meta: record, moduleData: moduleData, tags: tags, opType: RecordOutboxMapper.opUpsert,
        );
        await outbox.enqueue(outboxRecord);
      }
    });
  }

  @override
  Future<RecordMeta?> getRecord(String uuid, {required String module}) async {
    final record = await _ds.getRecord(uuid);
    if (record == null || record.module != module) return null;
    return record;
  }

  @override
  Future<List<RecordMeta>> listRecords({
    required String module,
    String? category,
    String? divinationType,
    required int limit,
    String? cursor,
    RecordSortBy sortBy = RecordSortBy.auto,
  }) =>
      _ds.listRecords(
          module: module, category: category, divinationType: divinationType,
          limit: limit, cursor: cursor, sortBy: sortBy);

  @override
  Future<bool> softDeleteRecord(String uuid, {required String module}) async {
    return _ds.db.transaction(() async {
      final meta = await _ds.getRecord(uuid);
      if (meta == null || meta.module != module) {
        return false;
      }
      final deleted = await _ds.softDeleteRecord(uuid);
      if (deleted) {
        final outbox = _outbox;
        if (outbox != null) {
          final outboxRecord = RecordOutboxMapper.toOutboxRecord(
            meta: meta.copyWith(deletedAt: DateTime.now().toUtc()),
            opType: RecordOutboxMapper.opDelete,
          );
          await outbox.enqueue(outboxRecord);
        }
      }
      return deleted;
    });
  }

  /// Restore (un-soft-delete) a previously soft-deleted record.
  ///
  /// Clears the [RecordMeta.deletedAt] field, re-persists the record and
  /// its search index, and enqueues an UPSERT outbox entry so peers learn
  /// about the restoration. All operations run within a single Drift transaction boundary.
  ///
  /// Returns `true` if the record was restored, `false` if the uuid was
  /// not found or was already active (not soft-deleted).
  Future<bool> restoreRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) async {
    return _ds.db.transaction(() async {
      final tags =
          _registry.forModule(record.module)?.extractSearchTags(record, moduleData) ??
              const <SearchTag>[];
      final restored = await _ds.restoreRecord(record, tags);
      if (restored) {
        final outbox = _outbox;
        if (outbox != null) {
          final outboxRecord = RecordOutboxMapper.toOutboxRecord(
            meta: record, moduleData: moduleData, tags: tags, opType: RecordOutboxMapper.opUpsert,
          );
          await outbox.enqueue(outboxRecord);
        }
      }
      return restored;
    });
  }

  /// Apply a remote record directly to local storage without touching the
  /// outbox (anti-loop prevention — remote-originated writes must never
  /// re-enter the outbox).
  ///
  /// Delegates to [DriftRecordDataSource.applyRemoteRecord] which runs in
  /// a single drift transaction (record + search index atomic).
  Future<void> applyRemoteRecord(RecordMeta record, List<SearchTag> tags) =>
      _ds.applyRemoteRecord(record, tags);

  @override
  Stream<List<RecordMeta>> watchRecords({
    required String module,
    String? category,
    RecordSortBy sortBy = RecordSortBy.auto,
  }) =>
      _ds.watchRecords(module: module, category: category, sortBy: sortBy);

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
