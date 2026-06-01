import 'package:divination_case/divination_case.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDivinationCaseRepository
    implements
        DivinationCaseRepository,
        DivinationRecordRepository,
        DivinationWorkItemRepository,
        DivinationParticipantRepository,
        PanelRefRepository {
  FirebaseDivinationCaseRepository(this._db);
  final FirebaseDatabase _db;

  DatabaseReference _ref(String path) => _db.ref(path);

  // --- DivinationCaseRepository ---

  @override
  Future<DivinationCaseModel?> getCase(String uuid) async {
    final snapshot = await _ref('divination_cases/\$uuid').get();
    if (!snapshot.exists) return null;
    return _caseFromMap(Map<String, dynamic>.from(snapshot.value as Map));
  }

  @override
  Future<List<DivinationCaseModel>> listCases({bool includeDeleted = false}) async {
    final snapshot = await _ref('divination_cases').get();
    if (!snapshot.exists) return [];
    final map = Map<String, dynamic>.from(snapshot.value as Map);
    final results = <DivinationCaseModel>[];
    for (final entry in map.entries) {
      final row = Map<String, dynamic>.from(entry.value as Map);
      final model = _caseFromMap(row);
      if (includeDeleted || model.deletedAt == null) {
        results.add(model);
      }
    }
    return results;
  }

  @override
  Future<void> saveCase(DivinationCaseModel model) async {
    await _ref('divination_cases/\${model.uuid}').set(_caseToMap(model));
  }

  DivinationCaseModel _caseFromMap(Map<String, dynamic> map) {
    return DivinationCaseModel(
      uuid: map['uuid'] as String,
      title: map['title'] as String,
      mainQuestion: map['main_question'] as String,
      status: DivinationCaseStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      finalSummary: map['final_summary'] as String?,
    );
  }

  Map<String, dynamic> _caseToMap(DivinationCaseModel model) {
    return {
      'uuid': model.uuid,
      'title': model.title,
      'main_question': model.mainQuestion,
      'status': model.status.name,
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': model.updatedAt.toIso8601String(),
      'deleted_at': model.deletedAt?.toIso8601String(),
      'final_summary': model.finalSummary,
    };
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
