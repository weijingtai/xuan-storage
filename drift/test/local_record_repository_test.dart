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
    expect((await repo.listRecords()).single.uuid, 'a');
    final tags = await db.customSelect(
        "SELECT index_key FROM t_record_search_index WHERE record_uuid='a'").get();
    expect(tags.single.read<String>('index_key'), 'upper_gua');
  });
}
