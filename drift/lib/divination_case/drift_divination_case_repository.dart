import 'package:divination_case/divination_case.dart';
import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

import '../seeker/seeker_module_registry.dart';
import 'divination_cases_table.dart';
import 'divination_work_items_table.dart';
import 'case_participants_table.dart';
import 'panel_refs_table.dart';
import 'work_item_panel_refs_table.dart';

class DriftDivinationCaseRepository
    implements
        DivinationCaseRepository,
        DivinationRecordRepository,
        DivinationWorkItemRepository,
        DivinationParticipantRepository,
        PanelRefRepository {
  DriftDivinationCaseRepository(this.db);
  final PersistenceDriftDatabase db;

  // --- DivinationCaseRepository ---

  @override
  Future<DivinationCaseModel?> getCase(String uuid) async {
    final query = db.select(db.divinationCases)
      ..where((t) => t.uuid.equals(uuid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _caseFromRow(row);
  }

  @override
  Future<List<DivinationCaseModel>> listCases({bool includeDeleted = false}) async {
    final query = db.select(db.divinationCases);
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    final rows = await query.get();
    return rows.map(_caseFromRow).toList();
  }

  @override
  Future<void> saveCase(DivinationCaseModel model) async {
    await db.into(db.divinationCases).insertOnConflictUpdate(_caseToRow(model));
  }

  DivinationCaseModel _caseFromRow(DivinationCase row) {
    return DivinationCaseModel(
      uuid: row.uuid,
      title: row.title,
      mainQuestion: row.mainQuestion,
      status: DivinationCaseStatus.values.byName(row.status),
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      deletedAt: row.deletedAt?.toUtc(),
      finalSummary: row.finalSummary,
    );
  }

  DivinationCasesCompanion _caseToRow(DivinationCaseModel model) {
    return DivinationCasesCompanion.insert(
      uuid: model.uuid,
      title: model.title,
      mainQuestion: model.mainQuestion,
      status: model.status.name,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: Value(model.deletedAt),
      finalSummary: Value(model.finalSummary),
    );
  }

  // --- DivinationRecordRepository ---
  // Note: No dedicated Drift table for records yet; stub implementation.

  @override
  Future<List<DivinationRecordModel>> listRecordsForCase(String caseUuid) async {
    return [];
  }

  @override
  Future<DivinationRecordModel?> getRecord(String uuid) async {
    return null;
  }

  @override
  Future<void> saveRecord(DivinationRecordModel model) async {
    // No Drift table for records in this migration phase.
  }

  // --- DivinationWorkItemRepository ---

  @override
  Future<List<DivinationWorkItemModel>> listWorkItemsForCase(String caseUuid) async {
    final query = db.select(db.divinationWorkItems)
      ..where((t) => t.caseUuid.equals(caseUuid));
    final rows = await query.get();
    return rows.map(_workItemFromRow).toList();
  }

  @override
  Future<DivinationWorkItemModel?> getWorkItem(String uuid) async {
    final query = db.select(db.divinationWorkItems)
      ..where((t) => t.uuid.equals(uuid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _workItemFromRow(row);
  }

  @override
  Future<void> saveWorkItem(DivinationWorkItemModel model) async {
    await db.into(db.divinationWorkItems).insertOnConflictUpdate(_workItemToRow(model));
  }

  DivinationWorkItemModel _workItemFromRow(DivinationWorkItem row) {
    return DivinationWorkItemModel(
      uuid: row.uuid,
      caseUuid: row.caseUuid,
      parentWorkItemUuid: row.parentWorkItemUuid,
      title: row.title,
      purpose: row.purpose,
      methodGroup: DivinationMethodGroup.values.byName(row.methodGroup),
      order: row.order,
      status: DivinationWorkItemStatus.values.byName(row.status),
      summary: row.summary,
      conclusion: row.conclusion,
    );
  }

  DivinationWorkItemsCompanion _workItemToRow(DivinationWorkItemModel model) {
    return DivinationWorkItemsCompanion.insert(
      uuid: model.uuid,
      caseUuid: model.caseUuid,
      parentWorkItemUuid: Value(model.parentWorkItemUuid),
      title: model.title,
      purpose: model.purpose,
      methodGroup: model.methodGroup.name,
      order: model.order,
      status: model.status.name,
      summary: Value(model.summary),
      conclusion: Value(model.conclusion),
    );
  }

  // --- DivinationParticipantRepository ---

  @override
  Future<List<DivinationParticipantModel>> listParticipantsForCase(String caseUuid) async {
    final query = db.select(db.caseParticipants)
      ..where((t) => t.caseUuid.equals(caseUuid));
    final rows = await query.get();
    return rows.map(_participantFromRow).toList();
  }

  @override
  Future<void> saveParticipant(DivinationParticipantModel model) async {
    await db.into(db.caseParticipants).insertOnConflictUpdate(_participantToRow(model));
  }

  DivinationParticipantModel _participantFromRow(CaseParticipant row) {
    return DivinationParticipantModel(
      uuid: row.uuid,
      caseUuid: row.caseUuid,
      recordUuid: row.recordUuid,
      name: row.name,
      role: DivinationParticipantRole.values.byName(row.role),
      seekerUuid: row.seekerUuid,
    );
  }

  CaseParticipantsCompanion _participantToRow(DivinationParticipantModel model) {
    return CaseParticipantsCompanion.insert(
      uuid: model.uuid,
      caseUuid: model.caseUuid,
      recordUuid: Value(model.recordUuid),
      name: model.name,
      role: model.role.name,
      seekerUuid: Value(model.seekerUuid),
    );
  }

  /// 通过 t_record_meta (module='seeker') 解析 seeker 名称。
  /// 返回 nickname ?? username, 如果不存在则返回 null。
  Future<String?> resolveSeekerName(String seekerUuid, ScopedRecordStore store) async {
    final repo = SeekerModuleRegistry.repository(store: store);
    final seeker = await repo.getSeekerByUuid(seekerUuid);
    return seeker?.nickname ?? seeker?.username;
  }

  // --- PanelRefRepository ---

  @override
  Future<PanelRefModel?> getPanelRef(String uuid) async {
    final query = db.select(db.panelRefs)
      ..where((t) => t.uuid.equals(uuid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _panelRefFromRow(row);
  }

  @override
  Future<void> savePanelRef(PanelRefModel model) async {
    await db.into(db.panelRefs).insertOnConflictUpdate(_panelRefToRow(model));
  }

  @override
  Future<List<WorkItemPanelRefModel>> listPanelRefsForWorkItem(String workItemUuid) async {
    final query = db.select(db.workItemPanelRefs)
      ..where((t) => t.workItemUuid.equals(workItemUuid));
    final rows = await query.get();
    return rows.map(_workItemPanelRefFromRow).toList();
  }

  @override
  Future<void> attachPanelRefToWorkItem(WorkItemPanelRefModel model) async {
    await db.into(db.workItemPanelRefs).insertOnConflictUpdate(_workItemPanelRefToRow(model));
  }

  PanelRefModel _panelRefFromRow(PanelRef row) {
    return PanelRefModel(
      uuid: row.uuid,
      module: row.module,
      panelUuid: row.panelUuid,
      panelType: row.panelType,
      role: PanelRefRole.values.byName(row.role),
      title: row.title,
    );
  }

  PanelRefsCompanion _panelRefToRow(PanelRefModel model) {
    return PanelRefsCompanion.insert(
      uuid: model.uuid,
      module: model.module,
      panelUuid: model.panelUuid,
      panelType: model.panelType,
      role: model.role.name,
      title: Value(model.title),
    );
  }

  WorkItemPanelRefModel _workItemPanelRefFromRow(WorkItemPanelRef row) {
    return WorkItemPanelRefModel(
      uuid: row.uuid,
      workItemUuid: row.workItemUuid,
      panelRefUuid: row.panelRefUuid,
      role: PanelRefRole.values.byName(row.role),
      order: row.order,
    );
  }

  WorkItemPanelRefsCompanion _workItemPanelRefToRow(WorkItemPanelRefModel model) {
    return WorkItemPanelRefsCompanion.insert(
      uuid: model.uuid,
      workItemUuid: model.workItemUuid,
      panelRefUuid: model.panelRefUuid,
      role: model.role.name,
      order: model.order,
    );
  }

  /// 通过 work_item_uuid 找到关联的 t_record_meta，再查询其 decision_links。
  Future<List<DecisionLinkRow>> getDecisionLinksForWorkItem(
      String workItemUuid, String scopeUid) async {
    final records = await (db.select(db.tRecordMeta)
          ..where((t) => t.workItemUuid.equals(workItemUuid) & t.scopeUid.equals(scopeUid)))
        .get();
    if (records.isEmpty) return [];
    final recordUuids = records.map((r) => r.uuid).toSet();
    final results = <DecisionLinkRow>[];
    for (final uuid in recordUuids) {
      final asSource = await db.decisionLinksDao.listBySource(uuid, scopeUid);
      final asTarget = await db.decisionLinksDao.listByTarget(uuid, scopeUid);
      results.addAll(asSource);
      results.addAll(asTarget);
    }
    return results;
  }
}
