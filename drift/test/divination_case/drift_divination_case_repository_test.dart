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
}
