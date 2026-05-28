import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
  });
  tearDown(() async => await db.close());

  test('decision_links: upsert + getById roundtrip', () async {
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'dl-1',
      sourceUuid: 'div-a',
      targetUuid: 'div-b',
      intent: 'hua_jie',
      createdAtMs: 1000,
      updatedAtMs: 1000,
      scopeUid: 'user-x',
    ));
    final got = await db.decisionLinksDao.getById('dl-1', 'user-x');
    expect(got?.id, equals('dl-1'));
    expect(got?.intent, equals('hua_jie'));
  });

  test('decision_links: listBySource returns ordered results', () async {
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'dl-2',
      sourceUuid: 'div-a',
      targetUuid: 'div-c',
      intent: 'zeng_qiang',
      createdAtMs: 2000,
      updatedAtMs: 2000,
      scopeUid: 'user-x',
    ));
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'dl-3',
      sourceUuid: 'div-a',
      targetUuid: 'div-d',
      intent: 'yan_zheng',
      createdAtMs: 3000,
      updatedAtMs: 3000,
      scopeUid: 'user-x',
    ));
    final links = await db.decisionLinksDao.listBySource('div-a', 'user-x');
    expect(links.length, equals(2));
    expect(links.first.id, equals('dl-2'));
  });
}
