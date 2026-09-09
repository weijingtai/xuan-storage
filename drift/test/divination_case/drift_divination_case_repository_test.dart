import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:divination_case/divination_case.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

DivinationCaseModel _caseFixture(String uuid) => DivinationCaseModel(
  uuid: uuid,
  title: 'Fixture case',
  mainQuestion: 'Fixture question',
  status: DivinationCaseStatus.inProgress,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

DivinationWorkItemModel _workItemFixture(String uuid, String caseUuid) =>
    DivinationWorkItemModel(
      uuid: uuid,
      caseUuid: caseUuid,
      title: 'Fixture work item',
      purpose: 'Fixture',
      methodGroup: DivinationMethodGroup.verification,
      order: 0,
      status: DivinationWorkItemStatus.planned,
    );

void main() {
  late PersistenceDriftDatabase db;
  late DriftDivinationCaseRepository repository;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    final ds = DriftRecordDataSource(db, scopeUid: 'scope-a');
    repository = DriftDivinationCaseRepository(
      db,
      store: LocalRecordRepository(ds, RecordAdapterRegistry([])),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('Save and reload case', () async {
    final caseModel = DivinationCaseModel(
      uuid: 'case-1',
      title: 'Test Case',
      mainQuestion: 'What is the outcome?',
      status: DivinationCaseStatus.inProgress,
      createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
      updatedAt: DateTime.utc(2026, 6, 6, 12, 30, 0),
      finalSummary: 'Summary text',
    );

    await repository.saveCase(caseModel);
    final fetched = await repository.getCase('case-1');
    expect(fetched, equals(caseModel));

    final list = await repository.listCases();
    expect(list, contains(caseModel));
  });

  test('Save and reload work items', () async {
    await repository.saveCase(_caseFixture('case-1'));
    final workItem = DivinationWorkItemModel(
      uuid: 'item-1',
      caseUuid: 'case-1',
      parentWorkItemUuid: null,
      title: 'Work Item Title',
      purpose: 'Verification',
      methodGroup: DivinationMethodGroup.verification,
      order: 1,
      status: DivinationWorkItemStatus.planned,
      summary: 'Some summary',
      conclusion: 'Conclusion here',
    );

    await repository.saveWorkItem(workItem);
    final fetched = await repository.getWorkItem('item-1');
    expect(fetched, equals(workItem));

    final list = await repository.listWorkItemsForCase('case-1');
    expect(list, contains(workItem));
  });

  test('Save and reload participants', () async {
    await repository.saveCase(_caseFixture('case-1'));
    final participant = DivinationParticipantModel(
      uuid: 'part-1',
      caseUuid: 'case-1',
      recordUuid: 'rec-1',
      name: 'John Doe',
      role: DivinationParticipantRole.primarySeeker,
      seekerUuid: 'seeker-1',
    );

    await repository.saveParticipant(participant);
    final list = await repository.listParticipantsForCase('case-1');
    expect(list, contains(participant));
  });

  test('Save and reload panel refs and attach to work item', () async {
    await repository.saveCase(_caseFixture('case-1'));
    await repository.saveWorkItem(_workItemFixture('item-1', 'case-1'));
    final panelRef = PanelRefModel(
      uuid: 'panel-1',
      module: 'qimendunjia',
      panelUuid: 'uuid-123',
      panelType: 'hour',
      role: PanelRefRole.main,
      title: 'Main Panel',
    );

    await repository.savePanelRef(panelRef);
    final fetched = await repository.getPanelRef('panel-1');
    expect(fetched, equals(panelRef));

    final workItemPanelRef = WorkItemPanelRefModel(
      uuid: 'wipr-1',
      workItemUuid: 'item-1',
      panelRefUuid: 'panel-1',
      role: PanelRefRole.main,
      order: 1,
    );

    await repository.attachPanelRefToWorkItem(workItemPanelRef);
    final list = await repository.listPanelRefsForWorkItem('item-1');
    expect(list, contains(workItemPanelRef));

    // Batch query tests
    final batchPanels = await repository.getPanelRefsByUuids(['panel-1', 'non-existent']);
    expect(batchPanels, hasLength(1));
    expect(batchPanels.first, equals(panelRef));

    final batchLinks = await repository.listPanelRefsForWorkItems(['item-1', 'non-existent']);
    expect(batchLinks, hasLength(1));
    expect(batchLinks.first, equals(workItemPanelRef));

    // Empty list tests
    expect(await repository.getPanelRefsByUuids([]), isEmpty);
    expect(await repository.listPanelRefsForWorkItems([]), isEmpty);
  });

  test('Save and reload divination record by case uuid and uuid', () async {
    final record = DivinationRecordModel(
      uuid: 'rec-1',
      caseUuid: 'case-1',
      question: 'Will the project succeed?',
      detail: 'Details about the plan',
      directlyPredict: 'Yes',
      order: 0,
      createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
    );

    await repository.saveRecord(record);
    final fetched = await repository.getRecord('rec-1');
    expect(fetched?.uuid, equals('rec-1'));
    expect(fetched?.caseUuid, equals('case-1'));
    expect(fetched?.question, equals('Will the project succeed?'));
    expect(fetched?.directlyPredict, equals('Yes'));

    final list = await repository.listRecordsForCase('case-1');
    expect(list.map((r) => r.uuid), contains('rec-1'));
  });

  test('Double Scope Isolation: Scope B cannot read Scope A data', () async {
    // 1. Create and save entities in scope-a
    final caseModel = DivinationCaseModel(
      uuid: 'case-iso-1',
      title: 'Scope A Case',
      mainQuestion: 'Question A',
      status: DivinationCaseStatus.inProgress,
      createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
      updatedAt: DateTime.utc(2026, 6, 6, 12, 30, 0),
    );
    await repository.saveCase(caseModel);

    final workItem = DivinationWorkItemModel(
      uuid: 'item-iso-1',
      caseUuid: 'case-iso-1',
      parentWorkItemUuid: null,
      title: 'Work Item Scope A',
      purpose: 'Verification',
      methodGroup: DivinationMethodGroup.verification,
      order: 1,
      status: DivinationWorkItemStatus.planned,
    );
    await repository.saveWorkItem(workItem);

    final record = DivinationRecordModel(
      uuid: 'rec-iso-1',
      caseUuid: 'case-iso-1',
      question: 'Question A',
      order: 0,
      createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
    );
    await repository.saveRecord(record);

    final participant = DivinationParticipantModel(
      uuid: 'part-iso-1',
      caseUuid: 'case-iso-1',
      name: 'Alice',
      role: DivinationParticipantRole.primarySeeker,
    );
    await repository.saveParticipant(participant);

    final panelRef = PanelRefModel(
      uuid: 'panel-iso-1',
      module: 'qimendunjia',
      panelUuid: 'uuid-iso-123',
      panelType: 'hour',
      role: PanelRefRole.main,
      title: 'Main Panel',
    );
    await repository.savePanelRef(panelRef);

    final workItemPanelRef = WorkItemPanelRefModel(
      uuid: 'wipr-iso-1',
      workItemUuid: 'item-iso-1',
      panelRefUuid: 'panel-iso-1',
      role: PanelRefRole.main,
      order: 1,
    );
    await repository.attachPanelRefToWorkItem(workItemPanelRef);

    // Verify scope-a can read all of them
    expect(await repository.getCase('case-iso-1'), isNotNull);
    expect(await repository.getWorkItem('item-iso-1'), isNotNull);
    expect(await repository.getRecord('rec-iso-1'), isNotNull);
    expect((await repository.listParticipantsForCase('case-iso-1')).length, 1);
    expect(await repository.getPanelRef('panel-iso-1'), isNotNull);
    expect((await repository.listPanelRefsForWorkItem('item-iso-1')).length, 1);

    // 2. Initialize Scope B repository on the same database
    final dsB = DriftRecordDataSource(db, scopeUid: 'scope-b');
    final repoB = DriftDivinationCaseRepository(
      db,
      store: LocalRecordRepository(dsB, RecordAdapterRegistry([])),
    );

    // 3. Assert Scope B CANNOT read any of Scope A data
    expect(await repoB.getCase('case-iso-1'), isNull);
    expect(
      (await repoB.listCases()).where((c) => c.uuid == 'case-iso-1'),
      isEmpty,
    );

    expect(await repoB.getWorkItem('item-iso-1'), isNull);
    expect(await repoB.listWorkItemsForCase('case-iso-1'), isEmpty);

    expect(await repoB.getRecord('rec-iso-1'), isNull);
    expect(await repoB.listRecordsForCase('case-iso-1'), isEmpty);

    expect(await repoB.listParticipantsForCase('case-iso-1'), isEmpty);

    expect(await repoB.getPanelRef('panel-iso-1'), isNull);
    expect(await repoB.listPanelRefsForWorkItem('item-iso-1'), isEmpty);
    expect(await repoB.getPanelRefsByUuids(['panel-iso-1']), isEmpty);
    expect(await repoB.listPanelRefsForWorkItems(['item-iso-1']), isEmpty);
  });

  test('scope B cannot write relations to scope A entities', () async {
    final sharedDb = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(sharedDb.close);
    DriftDivinationCaseRepository repoFor(String scopeUid) {
      final store = LocalRecordRepository(
        DriftRecordDataSource(sharedDb, scopeUid: scopeUid),
        RecordAdapterRegistry([]),
      );
      return DriftDivinationCaseRepository(sharedDb, store: store);
    }

    final repoA = repoFor('scope-a');
    final repoB = repoFor('scope-b');
    final caseA = DivinationCaseModel(
      uuid: 'case-scope-a',
      title: 'A',
      mainQuestion: 'A',
      status: DivinationCaseStatus.inProgress,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    await repoA.saveCase(caseA);
    final parentA = DivinationWorkItemModel(
      uuid: 'item-parent-a',
      caseUuid: caseA.uuid,
      title: 'Parent',
      purpose: 'test',
      methodGroup: DivinationMethodGroup.verification,
      order: 0,
      status: DivinationWorkItemStatus.planned,
    );
    await repoA.saveWorkItem(parentA);
    final recordA = DivinationRecordModel(
      uuid: 'record-scope-a',
      caseUuid: caseA.uuid,
      question: 'A',
      order: 0,
      createdAt: DateTime.utc(2026),
    );
    await repoA.saveRecord(recordA);
    final panelRefA = PanelRefModel(
      uuid: 'panel-ref-scope-a',
      module: 'divination_case',
      panelUuid: recordA.uuid,
      panelType: 'record',
      role: PanelRefRole.main,
    );
    await repoA.savePanelRef(panelRefA);
    final participantA = const DivinationParticipantModel(
      uuid: 'participant-scope-a',
      caseUuid: 'case-scope-a',
      name: 'A',
      role: DivinationParticipantRole.primarySeeker,
    );
    await repoA.saveParticipant(participantA);
    final wiprA = const WorkItemPanelRefModel(
      uuid: 'wipr-scope-a',
      workItemUuid: 'item-parent-a',
      panelRefUuid: 'panel-ref-scope-a',
      role: PanelRefRole.main,
      order: 0,
    );
    await repoA.attachPanelRefToWorkItem(wiprA);

    await expectLater(
      repoB.saveWorkItem(
        DivinationWorkItemModel(
          uuid: parentA.uuid,
          caseUuid: caseA.uuid,
          parentWorkItemUuid: parentA.uuid,
          title: 'B',
          purpose: 'test',
          methodGroup: DivinationMethodGroup.verification,
          order: 1,
          status: DivinationWorkItemStatus.planned,
        ),
      ),
      throwsStateError,
    );
    await expectLater(
      repoB.saveParticipant(
        const DivinationParticipantModel(
          uuid: 'participant-scope-a',
          caseUuid: 'case-scope-a',
          name: 'B',
          role: DivinationParticipantRole.primarySeeker,
        ),
      ),
      throwsStateError,
    );
    await expectLater(
      repoB.savePanelRef(
        const PanelRefModel(
          uuid: 'panel-ref-scope-a',
          module: 'divination_case',
          panelUuid: 'record-scope-a',
          panelType: 'record',
          role: PanelRefRole.main,
        ),
      ),
      throwsStateError,
    );
    await expectLater(
      repoB.attachPanelRefToWorkItem(
        const WorkItemPanelRefModel(
          uuid: 'wipr-scope-a',
          workItemUuid: 'item-parent-a',
          panelRefUuid: 'panel-ref-scope-a',
          role: PanelRefRole.main,
          order: 0,
        ),
      ),
      throwsStateError,
    );

    expect(await repoB.getWorkItem(parentA.uuid), isNull);
    expect(await repoB.listParticipantsForCase(caseA.uuid), isEmpty);
    expect(await repoB.getPanelRef(panelRefA.uuid), isNull);
    expect(await repoB.listPanelRefsForWorkItem('item-parent-a'), isEmpty);
    expect(await repoA.getWorkItem(parentA.uuid), isNotNull);
    expect(
      await repoA.listParticipantsForCase(caseA.uuid),
      contains(participantA),
    );
    expect(await repoA.getPanelRef(panelRefA.uuid), isNotNull);
    expect(await repoA.listPanelRefsForWorkItem(parentA.uuid), contains(wiprA));
  });

  test(
    'PanelRef rejects a module that does not own the referenced record',
    () async {
      final sharedDb = PersistenceDriftDatabase(NativeDatabase.memory());
      addTearDown(sharedDb.close);
      final store = LocalRecordRepository(
        DriftRecordDataSource(sharedDb, scopeUid: 'scope-a'),
        RecordAdapterRegistry([]),
      );
      final repo = DriftDivinationCaseRepository(sharedDb, store: store);
      await store.saveRecord(
        RecordMeta(
          uuid: 'record-module-a',
          scopeUid: 'scope-a',
          module: 'meihua',
          category: 'divination',
          divinationType: 'mei_hua',
          createdAt: DateTime.utc(2026),
        ),
      );

      await expectLater(
        repo.savePanelRef(
          const PanelRefModel(
            uuid: 'panel-ref-module-mismatch',
            module: 'qimendunjia',
            panelUuid: 'record-module-a',
            panelType: 'record',
            role: PanelRefRole.main,
          ),
        ),
        throwsStateError,
      );
      expect(await repo.getPanelRef('panel-ref-module-mismatch'), isNull);
    },
  );

  test('scope B cannot overwrite scope A case by uuid', () async {
    final sharedDb = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(sharedDb.close);
    DriftDivinationCaseRepository repoFor(String scopeUid) {
      final store = LocalRecordRepository(
        DriftRecordDataSource(sharedDb, scopeUid: scopeUid),
        RecordAdapterRegistry([]),
      );
      return DriftDivinationCaseRepository(sharedDb, store: store);
    }

    final repoA = repoFor('scope-a');
    final repoB = repoFor('scope-b');
    final caseA = _caseFixture('case-overwrite-a');
    await repoA.saveCase(caseA);

    await expectLater(
      repoB.saveCase(
        DivinationCaseModel(
          uuid: caseA.uuid,
          title: 'scope B must not overwrite A',
          mainQuestion: caseA.mainQuestion,
          status: caseA.status,
          createdAt: caseA.createdAt,
          updatedAt: caseA.updatedAt,
        ),
      ),
      throwsStateError,
    );

    expect(await repoA.getCase(caseA.uuid), equals(caseA));
    expect(await repoB.getCase(caseA.uuid), isNull);
    final rows = await sharedDb
        .customSelect(
          "SELECT uuid, scope_uid, title FROM t_divination_cases WHERE uuid = 'case-overwrite-a'",
        )
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.read<String>('scope_uid'), 'scope-a');
    expect(rows.single.read<String>('title'), caseA.title);
  });

  test('T2: Save and reload case judgement with all fields matching', () async {
    await repository.saveCase(_caseFixture('case-j-1'));
    await repository.saveWorkItem(_workItemFixture('item-j-1', 'case-j-1'));

    final judgement = CaseJudgementModel(
      uuid: 'judgement-1',
      scopeUid: 'scope-a',
      caseUuid: 'case-j-1',
      workItemUuid: 'item-j-1',
      techniqueId: 'tech-bazi-1',
      module: 'bazi',
      text: '婚姻美满，夫妻和睦',
      detailText: '日支坐正官得位，喜用神合日主',
      indicatorLabel: '大吉',
      patternLabel: '正官得禄',
      status: 'confirmed',
      keyBasis: '日支坐子水正官',
      attachedToKind: 'stage',
      orderIndex: 0,
      createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
      updatedAt: DateTime.utc(2026, 6, 6, 12, 30, 0),
      deletedAt: null,
    );

    await repository.saveJudgement(judgement);

    final fetched = await repository.getJudgement('judgement-1');
    expect(fetched, isNotNull);
    expect(fetched!.uuid, equals(judgement.uuid));
    expect(fetched.scopeUid, equals('scope-a'));
    expect(fetched.caseUuid, equals(judgement.caseUuid));
    expect(fetched.workItemUuid, equals(judgement.workItemUuid));
    expect(fetched.techniqueId, equals(judgement.techniqueId));
    expect(fetched.module, equals(judgement.module));
    expect(fetched.text, equals(judgement.text));
    expect(fetched.detailText, equals(judgement.detailText));
    expect(fetched.indicatorLabel, equals(judgement.indicatorLabel));
    expect(fetched.patternLabel, equals(judgement.patternLabel));
    expect(fetched.status, equals(judgement.status));
    expect(fetched.keyBasis, equals(judgement.keyBasis));
    expect(fetched.attachedToKind, equals(judgement.attachedToKind));
    expect(fetched.orderIndex, equals(judgement.orderIndex));
    expect(fetched.createdAt, equals(judgement.createdAt));
    expect(fetched.updatedAt, equals(judgement.updatedAt));
    expect(fetched.deletedAt, isNull);
    expect(fetched, equals(judgement));

    final list = await repository.listJudgementsForCase('case-j-1');
    expect(list.length, equals(1));
    expect(list.first, equals(judgement));
  });

  test('T5: Cross-scope query returns empty for judgements', () async {
    final sharedDb = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(sharedDb.close);
    DriftDivinationCaseRepository repoFor(String scopeUid) {
      final store = LocalRecordRepository(
        DriftRecordDataSource(sharedDb, scopeUid: scopeUid),
        RecordAdapterRegistry([]),
      );
      return DriftDivinationCaseRepository(sharedDb, store: store);
    }

    final repoA = repoFor('scope-a');
    final repoB = repoFor('scope-b');

    // 1. Create case, work item, and judgement in Scope A
    final caseA = _caseFixture('case-cross-scope');
    await repoA.saveCase(caseA);
    final itemA = _workItemFixture('item-cross-scope', caseA.uuid);
    await repoA.saveWorkItem(itemA);

    final judgementA = CaseJudgementModel(
      uuid: 'judgement-cross-scope-1',
      scopeUid: 'scope-a',
      caseUuid: caseA.uuid,
      workItemUuid: itemA.uuid,
      techniqueId: 'tech-1',
      module: 'liuyao',
      text: '世爻逢生，谋事必成',
      status: 'confirmed',
      createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
      updatedAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
    );
    await repoA.saveJudgement(judgementA);

    // Verify Scope A can read it
    expect(await repoA.getJudgement('judgement-cross-scope-1'), isNotNull);
    expect(await repoA.listJudgementsForCase(caseA.uuid), hasLength(1));

    // 2. Scope B query returns empty / null
    expect(await repoB.getJudgement('judgement-cross-scope-1'), isNull);
    expect(await repoB.listJudgementsForCase(caseA.uuid), isEmpty);
    expect(
      await repoB.listJudgementsForCase(caseA.uuid, includeDeleted: true),
      isEmpty,
    );

    // 3. Scope B cannot save judgement referencing Scope A case
    await expectLater(
      repoB.saveJudgement(
        CaseJudgementModel(
          uuid: 'judgement-scope-b-rogue',
          scopeUid: 'scope-b',
          caseUuid: caseA.uuid,
          text: 'Rogue judgement',
          status: 'draft',
          createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
          updatedAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
        ),
      ),
      throwsStateError,
    );

    // 4. Scope B cannot overwrite Scope A judgement by uuid
    await expectLater(
      repoB.saveJudgement(
        CaseJudgementModel(
          uuid: judgementA.uuid,
          scopeUid: 'scope-b',
          caseUuid: 'some-other-case',
          text: 'Overwriting scope A judgement',
          status: 'draft',
          createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
          updatedAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
        ),
      ),
      throwsStateError,
    );
  });

  test('T6: Cascade soft delete and restore with case', () async {
    final caseModel = _caseFixture('case-cascade-1');
    await repository.saveCase(caseModel);
    await repository.saveWorkItem(_workItemFixture('item-c-1', 'case-cascade-1'));

    final j1 = CaseJudgementModel(
      uuid: 'judgement-c-1',
      scopeUid: 'scope-a',
      caseUuid: 'case-cascade-1',
      workItemUuid: 'item-c-1',
      text: '断语一：初断吉',
      orderIndex: 0,
      status: 'active',
      createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
      updatedAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
    );
    final j2 = CaseJudgementModel(
      uuid: 'judgement-c-2',
      scopeUid: 'scope-a',
      caseUuid: 'case-cascade-1',
      workItemUuid: 'item-c-1',
      text: '断语二：复断应期在秋',
      orderIndex: 1,
      status: 'active',
      createdAt: DateTime.utc(2026, 6, 6, 12, 10, 0),
      updatedAt: DateTime.utc(2026, 6, 6, 12, 10, 0),
    );

    await repository.saveJudgement(j1);
    await repository.saveJudgement(j2);

    expect(await repository.listJudgementsForCase('case-cascade-1'), hasLength(2));

    // Test individual soft delete and restore
    await repository.softDeleteJudgement('judgement-c-1');
    var activeList = await repository.listJudgementsForCase('case-cascade-1');
    expect(activeList, hasLength(1));
    expect(activeList.first.uuid, 'judgement-c-2');

    var allList = await repository.listJudgementsForCase(
      'case-cascade-1',
      includeDeleted: true,
    );
    expect(allList, hasLength(2));
    expect(allList.firstWhere((j) => j.uuid == 'judgement-c-1').deletedAt, isNotNull);

    await repository.restoreJudgement('judgement-c-1');
    activeList = await repository.listJudgementsForCase('case-cascade-1');
    expect(activeList, hasLength(2));

    // Test cascade delete with case
    await repository.deleteCase('case-cascade-1', cascade: true);

    // Case itself is soft-deleted
    final fetchedCase = await repository.getCase('case-cascade-1');
    expect(fetchedCase?.deletedAt, isNotNull);
    expect((await repository.listCases()).where((c) => c.uuid == 'case-cascade-1'), isEmpty);
    expect((await repository.listCases(includeDeleted: true)).where((c) => c.uuid == 'case-cascade-1'), hasLength(1));

    // Judgements are cascaded soft-deleted
    expect(await repository.listJudgementsForCase('case-cascade-1'), isEmpty);
    final cascadedAll = await repository.listJudgementsForCase(
      'case-cascade-1',
      includeDeleted: true,
    );
    expect(cascadedAll, hasLength(2));
    for (final j in cascadedAll) {
      expect(j.deletedAt, isNotNull);
    }

    // Test cascade restore with case
    await repository.restoreCase('case-cascade-1', cascade: true);

    // Case is restored
    final restoredCase = await repository.getCase('case-cascade-1');
    expect(restoredCase?.deletedAt, isNull);
    expect((await repository.listCases()).where((c) => c.uuid == 'case-cascade-1'), hasLength(1));

    // Judgements are restored
    final restoredJudgements = await repository.listJudgementsForCase('case-cascade-1');
    expect(restoredJudgements, hasLength(2));
    for (final j in restoredJudgements) {
      expect(j.deletedAt, isNull);
    }
  });

  test('T7: listJudgementsForRecords 批量查询单卦断语（scope 隔离 + 哨兵语义）', () async {
    final sharedDb = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(sharedDb.close);
    DriftDivinationCaseRepository repoFor(String scopeUid) {
      final store = LocalRecordRepository(
        DriftRecordDataSource(sharedDb, scopeUid: scopeUid),
        RecordAdapterRegistry([]),
      );
      return DriftDivinationCaseRepository(sharedDb, store: store);
    }

    final repoA = repoFor('scope-a');
    final repoB = repoFor('scope-b');

    // 单卦断语：case_uuid='' 空串哨兵 + record_uuid 非空
    CaseJudgementModel recordJudgement(String uuid, String recordUuid,
        String text, int order) {
      return CaseJudgementModel(
        uuid: uuid,
        scopeUid: 'scope-a',
        caseUuid: '',
        recordUuid: recordUuid,
        text: text,
        status: 'confirmed',
        orderIndex: order,
        createdAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
        updatedAt: DateTime.utc(2026, 6, 6, 12, 0, 0),
      );
    }

    await repoA.saveJudgement(recordJudgement('j-rec-a1', 'rec-a1', '断语A1', 0));
    await repoA.saveJudgement(recordJudgement('j-rec-a2', 'rec-a2', '断语A2', 0));
    await repoA.saveJudgement(recordJudgement('j-rec-a3', 'rec-a3', '断语A3', 0));

    // Scope A：批量查询命中 3 条且按 recordUuid 归属正确
    final batch = await repoA.listJudgementsForRecords([
      'rec-a1',
      'rec-a2',
      'rec-a3',
      'rec-ghost',
    ]);
    expect(batch, hasLength(3));
    expect(batch.map((j) => j.recordUuid).toSet(),
        containsAll(['rec-a1', 'rec-a2', 'rec-a3']));
    expect(batch.every((j) => j.caseUuid == ''), isTrue,
        reason: '单卦断语必须都是空串哨兵归属');

    // 空集合快速返回
    expect(await repoA.listJudgementsForRecords(const []), isEmpty);

    // Scope B：查询 scope A 的 recordUuid 不得捞到任何数据（scope 隔离）
    expect(await repoB.listJudgementsForRecords(['rec-a1', 'rec-a2']), isEmpty);
  });
}
