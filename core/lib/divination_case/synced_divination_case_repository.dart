import 'package:divination_case/divination_case.dart';

class SyncedDivinationCaseRepository
    implements
        DivinationCaseRepository,
        DivinationRecordRepository,
        DivinationWorkItemRepository,
        DivinationParticipantRepository,
        PanelRefRepository {
  SyncedDivinationCaseRepository({
    required this.local,
    required this.remote,
  });

  final DivinationCaseRepository local;
  final DivinationCaseRepository remote;

  // --- DivinationCaseRepository ---

  @override
  Future<DivinationCaseModel?> getCase(String uuid) async {
    final localResult = await local.getCase(uuid);
    if (localResult != null) return localResult;
    try {
      return await remote.getCase(uuid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DivinationCaseModel>> listCases({bool includeDeleted = false}) async {
    return local.listCases(includeDeleted: includeDeleted);
  }

  @override
  Future<void> saveCase(DivinationCaseModel model) async {
    await local.saveCase(model);
    try {
      await remote.saveCase(model);
    } catch (_) {
      // Remote failure does not block local write.
    }
  }

  // --- DivinationRecordRepository ---

  @override
  Future<List<DivinationRecordModel>> listRecordsForCase(String caseUuid) async {
    return [];
  }

  @override
  Future<DivinationRecordModel?> getRecord(String uuid) async {
    return null;
  }

  @override
  Future<void> saveRecord(DivinationRecordModel model) async {}

  // --- DivinationWorkItemRepository ---

  @override
  Future<List<DivinationWorkItemModel>> listWorkItemsForCase(String caseUuid) async {
    return [];
  }

  @override
  Future<DivinationWorkItemModel?> getWorkItem(String uuid) async {
    return null;
  }

  @override
  Future<void> saveWorkItem(DivinationWorkItemModel model) async {}

  // --- DivinationParticipantRepository ---

  @override
  Future<List<DivinationParticipantModel>> listParticipantsForCase(String caseUuid) async {
    return [];
  }

  @override
  Future<void> saveParticipant(DivinationParticipantModel model) async {}

  // --- PanelRefRepository ---

  @override
  Future<PanelRefModel?> getPanelRef(String uuid) async {
    return null;
  }

  @override
  Future<void> savePanelRef(PanelRefModel model) async {}

  @override
  Future<List<WorkItemPanelRefModel>> listPanelRefsForWorkItem(String workItemUuid) async {
    return [];
  }

  @override
  Future<void> attachPanelRefToWorkItem(WorkItemPanelRefModel model) async {}
}
