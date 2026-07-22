import 'dart:convert';
import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

RecordMeta _m(String id, String category, DateTime createdAt, {DateTime? occurredAt}) => RecordMeta(
      uuid: id, scopeUid: 's1', module: 'meihua', category: category,
      divinationType: 'mei_hua', createdAt: createdAt,
      occurredAtUtc: occurredAt,
      rev: 1);

void main() {
  late PersistenceDriftDatabase db;
  late DriftRecordDataSource ds;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    ds = DriftRecordDataSource(db, scopeUid: 's1');
  });

  tearDown(() => db.close());

  test('divination auto sort uses occurredAtUtc', () async {
    // A divination created later but occurred earlier
    await ds.saveRecord(_m('a', 'divination', DateTime.utc(2026, 1, 2), occurredAt: DateTime.utc(2026, 1, 10)), const []);
    await ds.saveRecord(_m('b', 'divination', DateTime.utc(2026, 1, 1), occurredAt: DateTime.utc(2026, 1, 11)), const []);
    
    // Auto sort for divination: occurredAtUtc DESC, then createdAt DESC, then uuid ASC.
    // 'b' occurred at 11th, 'a' at 10th. So 'b' should be first.
    final list = await ds.listRecords(category: 'divination', sortBy: RecordSortBy.auto);
    expect(list.map((r) => r.uuid).toList(), ['b', 'a']);
  });

  test('destiny auto sort keeps createdAt', () async {
    // Destiny should ignore occurredAtUtc for auto sort
    await ds.saveRecord(_m('a', 'destiny', DateTime.utc(2026, 1, 2), occurredAt: DateTime.utc(2026, 1, 10)), const []);
    await ds.saveRecord(_m('b', 'destiny', DateTime.utc(2026, 1, 1), occurredAt: DateTime.utc(2026, 1, 11)), const []);
    
    // Auto sort for destiny: createdAt DESC
    // 'a' created at 2nd, 'b' at 1st. So 'a' should be first.
    final list = await ds.listRecords(category: 'destiny', sortBy: RecordSortBy.auto);
    expect(list.map((r) => r.uuid).toList(), ['a', 'b']);
  });

  test('occurredAt cursor uses matching sort key', () async {
    await ds.saveRecord(_m('a', 'divination', DateTime.utc(2026, 1, 2), occurredAt: DateTime.utc(2026, 1, 10)), const []);
    await ds.saveRecord(_m('b', 'divination', DateTime.utc(2026, 1, 1), occurredAt: DateTime.utc(2026, 1, 11)), const []);
    await ds.saveRecord(_m('c', 'divination', DateTime.utc(2026, 1, 3), occurredAt: DateTime.utc(2026, 1, 12)), const []);

    // order should be c, b, a
    final page1 = await ds.listRecords(category: 'divination', sortBy: RecordSortBy.occurredAtDesc, limit: 1);
    expect(page1.map((r) => r.uuid).toList(), ['c']);

    final cursor = DriftRecordDataSource.encodeCursor(page1.last, RecordSortBy.occurredAtDesc);
    final page2 = await ds.listRecords(category: 'divination', sortBy: RecordSortBy.occurredAtDesc, limit: 2, cursor: cursor);
    expect(page2.map((r) => r.uuid).toList(), ['b', 'a']);
  });
}
