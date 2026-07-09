import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  test('getDecisionLinksForWorkItem returns links for associated records', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    final repo = DriftDivinationCaseRepository(db);

    // 插入一条 t_record_meta，关联 work_item_uuid
    await db.into(db.tRecordMeta).insert(TRecordMetaCompanion.insert(
      uuid: 'record-1',
      scopeUid: 'scope-x',
      module: 'test',
      category: 'divination',
      divinationType: 'test_type',
      workItemUuid: const Value('work-item-1'),
      createdAt: DateTime.now(),
    ));

    // 创建两条 decision_link：一条从 record-1 出发，一条指向 record-1
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'dl-case-1',
      sourceUuid: 'record-1',
      targetUuid: 'tgt-1',
      intent: 'from_record',
      linkType: const Value('sequential'),
      scopeUid: 'scope-x',
      createdAtMs: 1000,
      updatedAtMs: 1000,
    ));
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'dl-case-2',
      sourceUuid: 'src-1',
      targetUuid: 'record-1',
      intent: 'to_record',
      linkType: const Value('sequential'),
      scopeUid: 'scope-x',
      createdAtMs: 2000,
      updatedAtMs: 2000,
    ));

    final links = await repo.getDecisionLinksForWorkItem('work-item-1', 'scope-x');
    expect(links.length, equals(2));

    final ids = links.map((l) => l.id).toSet();
    expect(ids, contains('dl-case-1'));
    expect(ids, contains('dl-case-2'));

    await db.close();
  });
}
