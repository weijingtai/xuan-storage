import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class _TagAdapter implements ModuleRecordAdapter {
  @override
  String get module => 'meihua';
  @override
  String get category => 'divination';
  @override
  String get divinationType => 'mei_hua';
  @override
  ({RecordMeta meta, Map<String, dynamic>? moduleData}) toRecord(Object m) =>
      throw UnimplementedError();
  @override
  Object fromRecord(RecordMeta meta, Map<String, dynamic>? d) =>
      throw UnimplementedError();
  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? d) =>
      const [SearchTag('upper_gua', '3')];
}

void main() {
  test('C0→C2: record save via LocalRecordRepository enqueues outbox (gap closed)', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final ds = DriftRecordDataSource(db, scopeUid: 'test-scope-c0');
    final dao = OutboxRecordsDao(db);
    final outboxStore = DriftOutboxStore(dao: dao);
    final registry = RecordAdapterRegistry([_TagAdapter()]);
    final repo = LocalRecordRepository(ds, registry, outboxStore: outboxStore);

    final meta = RecordMeta(
      uuid: 'c0-test-uuid', scopeUid: 'test-scope-c0',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
    );
    await repo.saveRecord(meta);

    final outboxRows = await outboxStore.peekBatch(
      scopeUid: 'test-scope-c0', limit: 100,
    );
    expect(outboxRows, isNotEmpty,
      reason: 'After C2: saveRecord via LocalRecordRepository with OutboxStore '
              'enqueues an outbox record.');
    expect(outboxRows.single.entityType, 'record_meta');
    expect(outboxRows.single.entityId, meta.uuid);
  });
}
