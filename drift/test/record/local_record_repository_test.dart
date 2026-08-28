import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

class _TagAdapter implements ModuleRecordAdapter {
  @override String get module => 'meihua';
  @override String get category => 'divination';
  @override String get divinationType => 'mei_hua';
  @override ({RecordMeta meta, Map<String, dynamic>? moduleData}) toRecord(Object m) =>
      throw UnimplementedError();
  @override Object fromRecord(RecordMeta meta, Map<String, dynamic>? d) =>
      throw UnimplementedError();
  @override List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? d) =>
      const [SearchTag('upper_gua', '3')];
}

void main() {
  test('saveRecord persists meta and adapter-derived search tag', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    final repo = LocalRecordRepository(ds, RecordAdapterRegistry([_TagAdapter()]));
    await repo.saveRecord(RecordMeta(
      uuid: 'a', scopeUid: 's1', module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.utc(2026)));
    expect((await repo.listRecords(module: 'meihua', limit: 100)).single.uuid, 'a');
    final tags = await db.customSelect(
        "SELECT index_key FROM t_record_search_index WHERE record_uuid='a'").get();
    expect(tags.single.read<String>('index_key'), 'upper_gua');
  });

  // RED-1: getRecord with invalid module
  test('getRecord returns null for non-existent uuid regardless of module', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    final repo = LocalRecordRepository(ds, RecordAdapterRegistry([]));

    // 不存在的 uuid → null（无论 module 是否有效）
    final result = await repo.getRecord('nonexistent', module: 'meihua');
    expect(result, isNull);
  });

  test('getRecord returns record even when module param does not match stored module', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    final repo = LocalRecordRepository(ds, RecordAdapterRegistry([_TagAdapter()]));

    await repo.saveRecord(RecordMeta(
      uuid: 'b', scopeUid: 's1', module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.utc(2026)));

    // module 参数不匹配但 uuid 存在 → 仍返回记录（当前实现忽略 module）
    final result = await repo.getRecord('b', module: 'nonexistent_module');
    expect(result, isNotNull);
    expect(result!.uuid, 'b');
    expect(result.module, 'meihua');
  });

  test('getRecord returns record for valid uuid with matching module', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    final repo = LocalRecordRepository(ds, RecordAdapterRegistry([_TagAdapter()]));

    await repo.saveRecord(RecordMeta(
      uuid: 'c', scopeUid: 's1', module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: DateTime.utc(2026)));

    final result = await repo.getRecord('c', module: 'meihua');
    expect(result, isNotNull);
    expect(result!.uuid, 'c');
  });
}
