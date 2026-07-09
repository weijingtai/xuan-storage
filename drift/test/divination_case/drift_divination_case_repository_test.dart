import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:divination_case/divination_case.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/divination_case/drift_divination_case_repository.dart';

void main() {
  late PersistenceDriftDatabase db;
  late DriftDivinationCaseRepository repository;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    repository = DriftDivinationCaseRepository(db);
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
}
