import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

RecordMeta _m(String id, String scope, {DateTime? at, String? json}) => RecordMeta(
      uuid: id, scopeUid: scope, module: 'meihua', category: 'divination',
      divinationType: 'mei_hua', createdAt: at ?? DateTime.utc(2026),
      moduleDataJson: json, rev: 1);

void main() {
  late PersistenceDriftDatabase db;
  setUp(() => db = PersistenceDriftDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('scope isolation: only own scope visible', () async {
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    final other = DriftRecordDataSource(db, scopeUid: 's2');
    await ds.saveRecord(_m('a', 's1'), const []);
    await other.saveRecord(_m('b', 's2'), const []);
    expect((await ds.listRecords()).map((r) => r.uuid), ['a']);
  });

  test('cursor pagination', () async {
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    for (var i = 0; i < 5; i++) {
      await ds.saveRecord(_m('r$i', 's1', at: DateTime.utc(2026, 1, i + 1)), const []);
    }
    final p1 = await ds.listRecords(limit: 2);
    expect(p1.map((r) => r.uuid), ['r4', 'r3']);
    final p2 = await ds.listRecords(
        limit: 2, cursor: RecordCursor(p1.last.createdAt, p1.last.uuid).encode());
    expect(p2.map((r) => r.uuid), ['r2', 'r1']);
  });

  test('save maintains search index in same txn; soft delete clears it', () async {
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    await ds.saveRecord(_m('a', 's1'),
        const [SearchTag('upper_gua', '3'), SearchTag('lower_gua', '7')]);
    final tags = await db.customSelect(
        "SELECT index_key FROM t_record_search_index WHERE record_uuid='a'").get();
    expect(tags.length, 2);
    await ds.softDeleteRecord('a');
    final after = await db.customSelect(
        "SELECT index_key FROM t_record_search_index WHERE record_uuid='a'").get();
    expect(after, isEmpty);
  });

  test('watch emits on save', () async {
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    final f = ds.watchRecords().firstWhere((l) => l.isNotEmpty);
    await ds.saveRecord(_m('a', 's1'), const []);
    expect((await f).single.uuid, 'a');
  });
}
