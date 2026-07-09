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
  late PersistenceDriftDatabase db;
  late DriftRecordDataSource ds;
  late OutboxRecordsDao dao;
  late DriftOutboxStore outboxStore;
  late RecordAdapterRegistry registry;
  late LocalRecordRepository repo;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    ds = DriftRecordDataSource(db, scopeUid: 'test-scope-c2');
    dao = OutboxRecordsDao(db);
    outboxStore = DriftOutboxStore(dao: dao);
    registry = RecordAdapterRegistry([_TagAdapter()]);
    repo = LocalRecordRepository(ds, registry, outboxStore: outboxStore);
  });

  tearDown(() async => await db.close());

  test('saveRecord enqueues OutboxRecord with entity_type record_meta', () async {
    final meta = RecordMeta(
      uuid: 'c2-save-uuid', scopeUid: 'test-scope-c2',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
    );
    await repo.saveRecord(meta);

    final rows = await outboxStore.peekBatch(scopeUid: 'test-scope-c2', limit: 100);
    expect(rows, hasLength(1));
    expect(rows.single.entityType, 'record_meta');
    expect(rows.single.entityId, meta.uuid);
  });

  test('outbox record payload contains original meta fields', () async {
    final meta = RecordMeta(
      uuid: 'c2-payload-uuid', scopeUid: 'test-scope-c2',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
      question: '出门吉否？',
    );
    await repo.saveRecord(meta);

    final rows = await outboxStore.peekBatch(scopeUid: 'test-scope-c2', limit: 100);
    expect(rows.single.payloadJson, contains(meta.uuid));
    expect(rows.single.payloadJson, contains('出门吉否？'));
  });

  test('outbox record has status pending', () async {
    final meta = RecordMeta(
      uuid: 'c2-status-uuid', scopeUid: 'test-scope-c2',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
    );
    await repo.saveRecord(meta);

    final rows = await outboxStore.peekBatch(scopeUid: 'test-scope-c2', limit: 100);
    expect(rows.single.attempt, 0);
  });

  test('save without outbox store still works (backward compat)', () async {
    final repoNoStore = LocalRecordRepository(ds, registry);
    final meta = RecordMeta(
      uuid: 'c2-nostore-uuid', scopeUid: 'test-scope-c2',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
    );
    await repoNoStore.saveRecord(meta);

    final found = await ds.getRecord('c2-nostore-uuid');
    expect(found, isNotNull);
    expect(found!.uuid, 'c2-nostore-uuid');
  });

  // ── C6: soft-delete outbox enqueue ──

  test('softDelete enqueues DELETE OutboxRecord', () async {
    final meta = RecordMeta(
      uuid: 'c6-del-uuid', scopeUid: 'test-scope-c2',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
    );
    await repo.saveRecord(meta);
    await repo.softDeleteRecord('c6-del-uuid', module: 'meihua');

    final rows = await outboxStore.peekBatch(scopeUid: 'test-scope-c2', limit: 100);
    final deleteRows = rows.where((r) => r.opType == 'DELETE').toList();
    expect(deleteRows, hasLength(1));
    expect(deleteRows.single.entityId, 'c6-del-uuid');
  });

  test('DELETE outbox record has opType DELETE and entity_type record_meta', () async {
    final meta = RecordMeta(
      uuid: 'c6-del2-uuid', scopeUid: 'test-scope-c2',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
    );
    await repo.saveRecord(meta);
    await repo.softDeleteRecord('c6-del2-uuid', module: 'meihua');

    final rows = await outboxStore.peekBatch(scopeUid: 'test-scope-c2', limit: 100);
    final deleteRows = rows.where((r) => r.opType == 'DELETE').toList();
    expect(deleteRows.single.opType, 'DELETE');
    expect(deleteRows.single.entityType, 'record_meta');
  });

  test('softDelete without outbox store still works', () async {
    final repoNoStore = LocalRecordRepository(ds, registry);
    final meta = RecordMeta(
      uuid: 'c6-nostore-uuid', scopeUid: 'test-scope-c2',
      module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.now(),
    );
    await ds.saveRecord(meta, const []);

    final deleted = await repoNoStore.softDeleteRecord('c6-nostore-uuid', module: 'meihua');
    expect(deleted, isTrue);
    final found = await ds.getRecord('c6-nostore-uuid');
    expect(found, isNotNull);
    expect(found!.deletedAt, isNotNull);
  });
}
