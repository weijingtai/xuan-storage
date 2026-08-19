import 'package:divination_case/divination_case.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:test/test.dart';

import 'package:persistence_core/divination_case/synced_divination_case_repository.dart';

class _FakeCaseRepository
    implements
        DivinationCaseRepository,
        DivinationRecordRepository,
        DivinationWorkItemRepository,
        DivinationParticipantRepository,
        PanelRefRepository {
  final Map<String, DivinationCaseModel> cases = {};
  final Map<String, DivinationWorkItemModel> workItems = {};
  final Map<String, DivinationParticipantModel> participants = {};
  final Map<String, PanelRefModel> panelRefs = {};
  final Map<String, WorkItemPanelRefModel> workItemPanelRefs = {};
  final Map<String, DivinationRecordModel> records = {};

  bool failOnWrite = false;
  XuanError? errorToThrow;

  // --- DivinationCaseRepository ---
  @override
  Future<DivinationCaseModel?> getCase(String uuid) async => cases[uuid];

  @override
  Future<List<DivinationCaseModel>> listCases({bool includeDeleted = false}) async {
    return cases.values.where((m) => includeDeleted || m.deletedAt == null).toList();
  }

  @override
  Future<void> saveCase(DivinationCaseModel model) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (failOnWrite) throw Exception('remote unavailable');
    cases[model.uuid] = model;
  }

  // --- DivinationRecordRepository ---
  @override
  Future<List<DivinationRecordModel>> listRecordsForCase(String caseUuid) async =>
      records.values.toList();

  @override
  Future<DivinationRecordModel?> getRecord(String uuid) async => records[uuid];

  @override
  Future<void> saveRecord(DivinationRecordModel model) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (failOnWrite) throw Exception('remote unavailable');
    records[model.uuid] = model;
  }

  // --- DivinationWorkItemRepository ---
  @override
  Future<List<DivinationWorkItemModel>> listWorkItemsForCase(String caseUuid) async =>
      workItems.values.where((w) => w.caseUuid == caseUuid).toList();

  @override
  Future<DivinationWorkItemModel?> getWorkItem(String uuid) async => workItems[uuid];

  @override
  Future<void> saveWorkItem(DivinationWorkItemModel model) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (failOnWrite) throw Exception('remote unavailable');
    workItems[model.uuid] = model;
  }

  // --- DivinationParticipantRepository ---
  @override
  Future<List<DivinationParticipantModel>> listParticipantsForCase(String caseUuid) async =>
      participants.values.where((p) => p.caseUuid == caseUuid).toList();

  @override
  Future<void> saveParticipant(DivinationParticipantModel model) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (failOnWrite) throw Exception('remote unavailable');
    participants[model.uuid] = model;
  }

  // --- PanelRefRepository ---
  @override
  Future<PanelRefModel?> getPanelRef(String uuid) async => panelRefs[uuid];

  @override
  Future<void> savePanelRef(PanelRefModel model) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (failOnWrite) throw Exception('remote unavailable');
    panelRefs[model.uuid] = model;
  }

  @override
  Future<List<WorkItemPanelRefModel>> listPanelRefsForWorkItem(String workItemUuid) async =>
      workItemPanelRefs.values.where((p) => p.workItemUuid == workItemUuid).toList();

  @override
  Future<void> attachPanelRefToWorkItem(WorkItemPanelRefModel model) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (failOnWrite) throw Exception('remote unavailable');
    workItemPanelRefs[model.uuid] = model;
  }
}

void main() {
  test('save case then list cases contains the case', () async {
    final local = _FakeCaseRepository();
    final remote = _FakeCaseRepository();
    final repo = SyncedDivinationCaseRepository(local: local, remote: remote);

    final model = DivinationCaseModel(
      uuid: 'case-1',
      title: 'Test',
      mainQuestion: 'Q?',
      status: DivinationCaseStatus.open,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    await repo.saveCase(model);
    final cases = await repo.listCases();
    expect(cases, contains(model));
  });

  test('remote failure does not block local write and enqueues to outbox', () async {
    final local = _FakeCaseRepository();
    final remote = _FakeCaseRepository()..failOnWrite = true;
    final outbox = Outbox();
    final repo = SyncedDivinationCaseRepository(
      local: local,
      remote: remote,
      outbox: outbox,
    );

    final model = DivinationCaseModel(
      uuid: 'case-2',
      title: 'Test2',
      mainQuestion: 'Q2?',
      status: DivinationCaseStatus.open,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    await repo.saveCase(model);
    final cases = await repo.listCases();
    expect(cases, contains(model));
    expect(outbox.pendingEntries.length, 1);
  });

  test('non-retryable remote error is not swallowed and rethrows', () async {
    final local = _FakeCaseRepository();
    final remote = _FakeCaseRepository()
      ..errorToThrow = const XuanError(
        code: ErrorCode.permissionDenied,
        message: 'Permission denied',
      );
    final repo = SyncedDivinationCaseRepository(local: local, remote: remote);

    final model = DivinationCaseModel(
      uuid: 'case-perm',
      title: 'PermTest',
      mainQuestion: 'Perm?',
      status: DivinationCaseStatus.open,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    expect(
      () => repo.saveCase(model),
      throwsA(isA<XuanError>().having((e) => e.code, 'code', ErrorCode.permissionDenied)),
    );
  });

  test('delegates work items, participants, and panel refs to local repository', () async {
    final local = _FakeCaseRepository();
    final repo = SyncedDivinationCaseRepository(local: local);

    final workItem = DivinationWorkItemModel(
      uuid: 'w1',
      caseUuid: 'case-1',
      title: 'Work item 1',
      purpose: 'Analysis',
      methodGroup: DivinationMethodGroup.lifePattern,
      order: 1,
      status: DivinationWorkItemStatus.planned,
    );
    await repo.saveWorkItem(workItem);
    expect(await repo.getWorkItem('w1'), equals(workItem));
    expect(await repo.listWorkItemsForCase('case-1'), contains(workItem));

    final participant = DivinationParticipantModel(
      uuid: 'p1',
      caseUuid: 'case-1',
      name: 'User 1',
      role: DivinationParticipantRole.primarySeeker,
    );
    await repo.saveParticipant(participant);
    expect(await repo.listParticipantsForCase('case-1'), contains(participant));

    final panelRef = PanelRefModel(
      uuid: 'pr1',
      module: 'bazi',
      panelUuid: 'panel-1',
      panelType: 'natal_chart',
      role: PanelRefRole.main,
    );
    await repo.savePanelRef(panelRef);
    expect(await repo.getPanelRef('pr1'), equals(panelRef));

    final workItemPanelRef = WorkItemPanelRefModel(
      uuid: 'wpr1',
      workItemUuid: 'w1',
      panelRefUuid: 'pr1',
      role: PanelRefRole.main,
      order: 1,
    );
    await repo.attachPanelRefToWorkItem(workItemPanelRef);
    expect(await repo.listPanelRefsForWorkItem('w1'), contains(workItemPanelRef));
  });

  test('delegates divination records to local repository with case_uuid index query', () async {
    final local = _FakeCaseRepository();
    final repo = SyncedDivinationCaseRepository(local: local);

    final record = DivinationRecordModel(
      uuid: 'rec-100',
      caseUuid: 'case-1',
      question: 'Test Record Question',
      detail: 'Record details',
      directlyPredict: 'Favorable',
      order: 0,
      createdAt: DateTime.utc(2026, 6, 1),
    );

    await repo.saveRecord(record);
    final fetched = await repo.getRecord('rec-100');
    expect(fetched, equals(record));

    final recordsForCase = await repo.listRecordsForCase('case-1');
    expect(recordsForCase, contains(record));
  });
}
