import 'package:divination_case/divination_case.dart';
import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

import '../seeker/seeker_module_registry.dart';

class DriftDivinationCaseRepository
    implements
        DivinationCaseRepository,
        DivinationRecordRepository,
        DivinationWorkItemRepository,
        DivinationParticipantRepository,
        PanelRefRepository {
  DriftDivinationCaseRepository(this.db, {required ScopedRecordStore store})
    : _store = store;
  final PersistenceDriftDatabase db;
  final ScopedRecordStore _store;

  // --- DivinationCaseRepository ---

  @override
  Future<DivinationCaseModel?> getCase(String uuid) async {
    final query = db.select(db.divinationCases)
      ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _caseFromRow(row);
  }

  @override
  Future<List<DivinationCaseModel>> listCases({
    bool includeDeleted = false,
  }) async {
    final query = db.select(db.divinationCases)
      ..where((t) => t.scopeUid.equals(_store.scopeUid));
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    final rows = await query.get();
    return rows.map(_caseFromRow).toList();
  }

  @override
  Future<void> saveCase(DivinationCaseModel model) async {
    final existing = await (db.select(
      db.divinationCases,
    )..where((t) => t.uuid.equals(model.uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('Case ${model.uuid} belongs to another scope');
    }
    await db.into(db.divinationCases).insertOnConflictUpdate(_caseToRow(model));
  }

  Future<void> deleteCase(String uuid, {bool cascade = false}) async {
    final existing = await (db.select(
      db.divinationCases,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('Case $uuid belongs to another scope');
    }
    if (existing == null) return;

    final now = DateTime.now().toUtc();
    await (db.update(db.divinationCases)
          ..where(
            (t) =>
                t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid),
          ))
        .write(DivinationCasesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));

    if (cascade) {
      await (db.update(db.caseJudgements)
            ..where(
              (t) =>
                  t.caseUuid.equals(uuid) &
                  t.scopeUid.equals(_store.scopeUid) &
                  t.deletedAt.isNull(),
            ))
          .write(CaseJudgementsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ));
    }
  }

  Future<void> restoreCase(String uuid, {bool cascade = false}) async {
    final existing = await (db.select(
      db.divinationCases,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('Case $uuid belongs to another scope');
    }
    if (existing == null) return;

    final now = DateTime.now().toUtc();
    await (db.update(db.divinationCases)
          ..where(
            (t) =>
                t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid),
          ))
        .write(DivinationCasesCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ));

    if (cascade) {
      await (db.update(db.caseJudgements)
            ..where(
              (t) =>
                  t.caseUuid.equals(uuid) &
                  t.scopeUid.equals(_store.scopeUid),
            ))
          .write(CaseJudgementsCompanion(
            deletedAt: const Value(null),
            updatedAt: Value(now),
          ));
    }
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
      extrasJson: row.extrasJson,
    );
  }

  DivinationCasesCompanion _caseToRow(DivinationCaseModel model) {
    return DivinationCasesCompanion.insert(
      uuid: model.uuid,
      scopeUid: Value(_store.scopeUid),
      title: model.title,
      mainQuestion: model.mainQuestion,
      status: model.status.name,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: Value(model.deletedAt),
      finalSummary: Value(model.finalSummary),
      extrasJson: Value(model.extrasJson),
    );
  }

  // --- DivinationRecordRepository ---

  @override
  Future<List<DivinationRecordModel>> listRecordsForCase(
    String caseUuid,
  ) async {
    final query = db.select(db.tRecordMeta)
      ..where(
        (t) =>
            t.caseUuid.equals(caseUuid) &
            t.scopeUid.equals(_store.scopeUid) &
            t.deletedAt.isNull(),
      );
    final rows = await query.get();
    return rows.map(_recordFromRow).toList();
  }

  @override
  Future<DivinationRecordModel?> getRecord(String uuid) async {
    final query = db.select(db.tRecordMeta)
      ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _recordFromRow(row);
  }

  @override
  Future<void> saveRecord(DivinationRecordModel model) async {
    final existing =
        await (db.select(db.tRecordMeta)..where(
              (t) =>
                  t.uuid.equals(model.uuid) &
                  t.scopeUid.equals(_store.scopeUid),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await (db.update(db.tRecordMeta)..where(
            (t) =>
                t.uuid.equals(model.uuid) & t.scopeUid.equals(_store.scopeUid),
          ))
          .write(
            TRecordMetaCompanion(
              caseUuid: Value(model.caseUuid),
              question: Value(model.question),
              detail: Value(model.detail),
              directPredict: Value(model.directlyPredict),
              updatedAt: Value(DateTime.now().toUtc()),
              deletedAt: Value(model.deletedAt),
            ),
          );
    } else {
      await db
          .into(db.tRecordMeta)
          .insertOnConflictUpdate(
            TRecordMetaCompanion(
              uuid: Value(model.uuid),
              scopeUid: Value(_store.scopeUid),
              module: const Value('divination_case'),
              category: const Value('record'),
              divinationType: const Value('general'),
              caseUuid: Value(model.caseUuid),
              question: Value(model.question),
              detail: Value(model.detail),
              directPredict: Value(model.directlyPredict),
              createdAt: Value(model.createdAt.toUtc()),
              deletedAt: Value(model.deletedAt),
              rev: const Value(1),
            ),
          );
    }
  }

  DivinationRecordModel _recordFromRow(TRecordMetaData row) {
    return DivinationRecordModel(
      uuid: row.uuid,
      caseUuid: row.caseUuid ?? '',
      question: row.question ?? '',
      detail: row.detail,
      directlyPredict: row.directPredict,
      order: 0,
      createdAt: row.createdAt.toUtc(),
      deletedAt: row.deletedAt?.toUtc(),
    );
  }

  // --- DivinationWorkItemRepository ---

  @override
  Future<List<DivinationWorkItemModel>> listWorkItemsForCase(
    String caseUuid,
  ) async {
    final query = db.select(db.divinationWorkItems)
      ..where(
        (t) => t.caseUuid.equals(caseUuid) & t.scopeUid.equals(_store.scopeUid),
      );
    final rows = await query.get();
    return rows.map(_workItemFromRow).toList();
  }

  @override
  Future<DivinationWorkItemModel?> getWorkItem(String uuid) async {
    final query = db.select(db.divinationWorkItems)
      ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _workItemFromRow(row);
  }

  @override
  Future<void> saveWorkItem(DivinationWorkItemModel model) async {
    await _validateWorkItemWrite(model);
    await db
        .into(db.divinationWorkItems)
        .insertOnConflictUpdate(_workItemToRow(model));
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
      extrasJson: row.extrasJson,
    );
  }

  DivinationWorkItemsCompanion _workItemToRow(DivinationWorkItemModel model) {
    return DivinationWorkItemsCompanion.insert(
      uuid: model.uuid,
      scopeUid: Value(_store.scopeUid),
      caseUuid: model.caseUuid,
      parentWorkItemUuid: Value(model.parentWorkItemUuid),
      title: model.title,
      purpose: model.purpose,
      methodGroup: model.methodGroup.name,
      order: model.order,
      status: model.status.name,
      summary: Value(model.summary),
      conclusion: Value(model.conclusion),
      extrasJson: Value(model.extrasJson),
    );
  }

  // --- DivinationParticipantRepository ---

  @override
  Future<List<DivinationParticipantModel>> listParticipantsForCase(
    String caseUuid,
  ) async {
    final query = db.select(db.caseParticipants)
      ..where(
        (t) => t.caseUuid.equals(caseUuid) & t.scopeUid.equals(_store.scopeUid),
      );
    final rows = await query.get();
    return rows.map(_participantFromRow).toList();
  }

  @override
  Future<void> saveParticipant(DivinationParticipantModel model) async {
    await _validateParticipantWrite(model);
    await db
        .into(db.caseParticipants)
        .insertOnConflictUpdate(_participantToRow(model));
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

  CaseParticipantsCompanion _participantToRow(
    DivinationParticipantModel model,
  ) {
    return CaseParticipantsCompanion.insert(
      uuid: model.uuid,
      scopeUid: Value(_store.scopeUid),
      caseUuid: model.caseUuid,
      recordUuid: Value(model.recordUuid),
      name: model.name,
      role: model.role.name,
      seekerUuid: Value(model.seekerUuid),
    );
  }

  /// 通过 t_record_meta (module='seeker') 解析 seeker 名称。
  /// 返回 nickname ?? username, 如果不存在则返回 null。
  Future<String?> resolveSeekerName(
    String seekerUuid,
    ScopedRecordStore store,
  ) async {
    final repo = SeekerModuleRegistry.repository(store: store);
    final seeker = await repo.getSeekerByUuid(seekerUuid);
    return seeker?.nickname ?? seeker?.username;
  }

  // --- PanelRefRepository ---

  @override
  Future<PanelRefModel?> getPanelRef(String uuid) async {
    final query = db.select(db.panelRefs)
      ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _panelRefFromRow(row);
  }

  @override
  Future<void> savePanelRef(PanelRefModel model) async {
    await _validatePanelRefWrite(model);
    await db.into(db.panelRefs).insertOnConflictUpdate(_panelRefToRow(model));
  }

  @override
  Future<List<WorkItemPanelRefModel>> listPanelRefsForWorkItem(
    String workItemUuid,
  ) async {
    final query = db.select(db.workItemPanelRefs)
      ..where(
        (t) =>
            t.workItemUuid.equals(workItemUuid) &
            t.scopeUid.equals(_store.scopeUid),
      );
    final rows = await query.get();
    return rows.map(_workItemPanelRefFromRow).toList();
  }

  @override
  Future<void> attachPanelRefToWorkItem(WorkItemPanelRefModel model) async {
    await _validateWorkItemPanelRefWrite(model);
    await db
        .into(db.workItemPanelRefs)
        .insertOnConflictUpdate(_workItemPanelRefToRow(model));
  }

  @override
  Future<List<WorkItemPanelRefModel>> listPanelRefsForWorkItems(
    List<String> workItemUuids,
  ) async {
    if (workItemUuids.isEmpty) return const [];
    final results = <WorkItemPanelRefModel>[];
    const chunkSize = 500;
    for (var i = 0; i < workItemUuids.length; i += chunkSize) {
      final chunk = workItemUuids.sublist(
        i,
        i + chunkSize > workItemUuids.length ? workItemUuids.length : i + chunkSize,
      );
      final query = db.select(db.workItemPanelRefs)
        ..where(
          (t) =>
              t.workItemUuid.isIn(chunk) &
              t.scopeUid.equals(_store.scopeUid),
        );
      final rows = await query.get();
      results.addAll(rows.map(_workItemPanelRefFromRow));
    }
    return results;
  }

  @override
  Future<List<PanelRefModel>> getPanelRefsByUuids(List<String> uuids) async {
    if (uuids.isEmpty) return const [];
    final results = <PanelRefModel>[];
    const chunkSize = 500;
    for (var i = 0; i < uuids.length; i += chunkSize) {
      final chunk = uuids.sublist(
        i,
        i + chunkSize > uuids.length ? uuids.length : i + chunkSize,
      );
      final query = db.select(db.panelRefs)
        ..where(
          (t) =>
              t.uuid.isIn(chunk) &
              t.scopeUid.equals(_store.scopeUid),
        );
      final rows = await query.get();
      results.addAll(rows.map(_panelRefFromRow));
    }
    return results;
  }

  Future<void> _validateWorkItemWrite(DivinationWorkItemModel model) async {
    final existing = await (db.select(
      db.divinationWorkItems,
    )..where((t) => t.uuid.equals(model.uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('WorkItem ${model.uuid} belongs to another scope');
    }

    final caseRow =
        await (db.select(db.divinationCases)..where(
              (t) =>
                  t.uuid.equals(model.caseUuid) &
                  t.scopeUid.equals(_store.scopeUid),
            ))
            .getSingleOrNull();
    if (caseRow == null) {
      throw StateError('Case ${model.caseUuid} is not in the current scope');
    }

    final parentUuid = model.parentWorkItemUuid;
    if (parentUuid == null) return;
    final parent = await (db.select(
      db.divinationWorkItems,
    )..where((t) => t.uuid.equals(parentUuid))).getSingleOrNull();
    if (parent == null || parent.scopeUid != _store.scopeUid) {
      throw StateError(
        'Parent WorkItem $parentUuid is not in the current scope',
      );
    }
    if (parent.caseUuid != model.caseUuid) {
      throw StateError('Parent WorkItem $parentUuid belongs to another case');
    }
  }

  Future<void> _validateParticipantWrite(
    DivinationParticipantModel model,
  ) async {
    final existing = await (db.select(
      db.caseParticipants,
    )..where((t) => t.uuid.equals(model.uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('Participant ${model.uuid} belongs to another scope');
    }
    final caseRow =
        await (db.select(db.divinationCases)..where(
              (t) =>
                  t.uuid.equals(model.caseUuid) &
                  t.scopeUid.equals(_store.scopeUid),
            ))
            .getSingleOrNull();
    if (caseRow == null) {
      throw StateError('Case ${model.caseUuid} is not in the current scope');
    }
    final recordUuid = model.recordUuid;
    if (recordUuid == null) return;
    final record = await (db.select(
      db.tRecordMeta,
    )..where((t) => t.uuid.equals(recordUuid))).getSingleOrNull();
    if (record != null && record.scopeUid != _store.scopeUid) {
      throw StateError(
        'Participant record $recordUuid belongs to another scope',
      );
    }
    if (record != null &&
        record.caseUuid != null &&
        record.caseUuid != model.caseUuid) {
      throw StateError(
        'Participant record $recordUuid belongs to another case',
      );
    }
  }

  Future<void> _validatePanelRefWrite(PanelRefModel model) async {
    final existing = await (db.select(
      db.panelRefs,
    )..where((t) => t.uuid.equals(model.uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('PanelRef ${model.uuid} belongs to another scope');
    }

    // PanelRef may target either a record-backed panel or a legacy global
    // panel. Whenever the target is record-backed, enforce both scope and
    // declared module; unresolved external panel IDs remain valid references.
    final record = await (db.select(
      db.tRecordMeta,
    )..where((t) => t.uuid.equals(model.panelUuid))).getSingleOrNull();
    if (record == null) return;
    if (record.scopeUid != _store.scopeUid) {
      throw StateError('Panel ${model.panelUuid} belongs to another scope');
    }
    if (record.module != model.module) {
      throw StateError(
        'Panel ${model.panelUuid} module ${record.module} does not match ${model.module}',
      );
    }
  }

  Future<void> _validateWorkItemPanelRefWrite(
    WorkItemPanelRefModel model,
  ) async {
    final existing = await (db.select(
      db.workItemPanelRefs,
    )..where((t) => t.uuid.equals(model.uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError(
        'WorkItemPanelRef ${model.uuid} belongs to another scope',
      );
    }

    final workItem = await (db.select(
      db.divinationWorkItems,
    )..where((t) => t.uuid.equals(model.workItemUuid))).getSingleOrNull();
    if (workItem == null || workItem.scopeUid != _store.scopeUid) {
      throw StateError(
        'WorkItem ${model.workItemUuid} is not in the current scope',
      );
    }
    final panelRef = await (db.select(
      db.panelRefs,
    )..where((t) => t.uuid.equals(model.panelRefUuid))).getSingleOrNull();
    if (panelRef == null || panelRef.scopeUid != _store.scopeUid) {
      throw StateError(
        'PanelRef ${model.panelRefUuid} is not in the current scope',
      );
    }
    final targetRecord = await (db.select(
      db.tRecordMeta,
    )..where((t) => t.uuid.equals(panelRef.panelUuid))).getSingleOrNull();
    if (targetRecord != null &&
        targetRecord.caseUuid != null &&
        targetRecord.caseUuid != workItem.caseUuid) {
      throw StateError('PanelRef ${model.panelRefUuid} targets another case');
    }
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
      scopeUid: Value(_store.scopeUid),
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

  WorkItemPanelRefsCompanion _workItemPanelRefToRow(
    WorkItemPanelRefModel model,
  ) {
    return WorkItemPanelRefsCompanion.insert(
      uuid: model.uuid,
      scopeUid: Value(_store.scopeUid),
      workItemUuid: model.workItemUuid,
      panelRefUuid: model.panelRefUuid,
      role: model.role.name,
      order: model.order,
    );
  }

  /// 通过 work_item_uuid 找到关联的 t_record_meta，再查询其 decision_links。
  Future<List<DecisionLinkRow>> getDecisionLinksForWorkItem(
    String workItemUuid,
    String scopeUid,
  ) async {
    final records =
        await (db.select(db.tRecordMeta)..where(
              (t) =>
                  t.workItemUuid.equals(workItemUuid) &
                  t.scopeUid.equals(scopeUid),
            ))
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

  // --- CaseJudgements ---

  Future<CaseJudgementModel?> getJudgement(String uuid) async {
    final query = db.select(db.caseJudgements)
      ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid));
    final row = await query.getSingleOrNull();
    return row == null ? null : _judgementFromRow(row);
  }

  Future<List<CaseJudgementModel>> listJudgementsForCase(
    String caseUuid, {
    bool includeDeleted = false,
  }) async {
    final query = db.select(db.caseJudgements)
      ..where(
        (t) =>
            t.caseUuid.equals(caseUuid) &
            // 哨兵过滤：空串 '' 表示「不属于任何 Case」的单卦断语
            t.caseUuid.equals('').not() &
            t.scopeUid.equals(_store.scopeUid),
      );
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.orderIndex),
      (t) => OrderingTerm.asc(t.createdAt),
    ]);
    final rows = await query.get();
    return rows.map(_judgementFromRow).toList();
  }

  /// 按 recordUuid 查询单卦断语（ORDER-J2）。
  /// 单卦断语的 case_uuid 为空串 '' 哨兵，record_uuid 非空。
  Future<List<CaseJudgementModel>> listJudgementsForRecord(
    String recordUuid, {
    bool includeDeleted = false,
  }) async {
    final query = db.select(db.caseJudgements)
      ..where(
        (t) =>
            t.recordUuid.equals(recordUuid) &
            t.scopeUid.equals(_store.scopeUid),
      );
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.orderIndex),
      (t) => OrderingTerm.asc(t.createdAt),
    ]);
    final rows = await query.get();
    return rows.map(_judgementFromRow).toList();
  }

  /// 按 recordUuid 集合批量查询单卦断语（ORDER-J2B）。
  ///
  /// Normal Card 列表分页后以「本页 recordUuid 集合一次批量取」，避免 N+1。
  /// 单卦断语的 case_uuid 为空串 '' 哨兵，record_uuid 非空。
  Future<List<CaseJudgementModel>> listJudgementsForRecords(
    List<String> recordUuids, {
    bool includeDeleted = false,
  }) async {
    if (recordUuids.isEmpty) return const [];
    final results = <CaseJudgementModel>[];
    const chunkSize = 500;
    for (var i = 0; i < recordUuids.length; i += chunkSize) {
      final chunk = recordUuids.sublist(
        i,
        i + chunkSize > recordUuids.length
            ? recordUuids.length
            : i + chunkSize,
      );
      final query = db.select(db.caseJudgements)
        ..where(
          (t) =>
              t.recordUuid.isIn(chunk) &
              t.scopeUid.equals(_store.scopeUid),
        );
      if (!includeDeleted) {
        query.where((t) => t.deletedAt.isNull());
      }
      query.orderBy([
        (t) => OrderingTerm.asc(t.orderIndex),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
      final rows = await query.get();
      results.addAll(rows.map(_judgementFromRow));
    }
    return results;
  }

  Future<void> saveJudgement(CaseJudgementModel model) async {
    await _validateJudgementWrite(model);
    await db
        .into(db.caseJudgements)
        .insertOnConflictUpdate(_judgementToRow(model));
  }

  Future<void> softDeleteJudgement(String uuid) async {
    final existing = await (db.select(
      db.caseJudgements,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('Judgement $uuid belongs to another scope');
    }
    final now = DateTime.now().toUtc();
    await (db.update(db.caseJudgements)
          ..where(
            (t) =>
                t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid),
          ))
        .write(CaseJudgementsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  Future<void> restoreJudgement(String uuid) async {
    final existing = await (db.select(
      db.caseJudgements,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('Judgement $uuid belongs to another scope');
    }
    final now = DateTime.now().toUtc();
    await (db.update(db.caseJudgements)
          ..where(
            (t) =>
                t.uuid.equals(uuid) & t.scopeUid.equals(_store.scopeUid),
          ))
        .write(CaseJudgementsCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ));
  }

  Future<void> _validateJudgementWrite(CaseJudgementModel model) async {
    final existing = await (db.select(
      db.caseJudgements,
    )..where((t) => t.uuid.equals(model.uuid))).getSingleOrNull();
    if (existing != null && existing.scopeUid != _store.scopeUid) {
      throw StateError('Judgement ${model.uuid} belongs to another scope');
    }

    // 哨兵校验（ORDER-J2）：
    // - Case 断语：case_uuid 非空串、record_uuid 为 NULL
    // - 单卦断语：case_uuid 为空串 ''、record_uuid 非空
    // - 两者恰有一个有效，非法组合抛异常
    final caseUuid = model.caseUuid;
    final recordUuid = model.recordUuid;
    final isCaseSentinel = caseUuid == '';
    final hasRecord = recordUuid != null && recordUuid.isNotEmpty;

    if (isCaseSentinel && hasRecord) {
      // 单卦断语：case_uuid 为空串，record_uuid 非空 —— 合法
    } else if (!isCaseSentinel && !hasRecord) {
      // Case 断语：case_uuid 非空串，record_uuid 为 NULL —— 合法
      final caseRow = await (db.select(
        db.divinationCases,
      )..where(
        (t) =>
            t.uuid.equals(caseUuid) &
            t.scopeUid.equals(_store.scopeUid),
      )).getSingleOrNull();
      if (caseRow == null) {
        throw StateError('Case $caseUuid is not in the current scope');
      }
    } else {
      // 非法组合
      throw StateError(
        'Invalid judgement ownership: case_uuid="$caseUuid", record_uuid="$recordUuid". '
        'Either case_uuid (non-empty) OR record_uuid must be set, not both.',
      );
    }

    final workItemUuid = model.workItemUuid;
    if (workItemUuid != null) {
      final workItem = await (db.select(
        db.divinationWorkItems,
      )..where((t) => t.uuid.equals(workItemUuid))).getSingleOrNull();
      if (workItem == null || workItem.scopeUid != _store.scopeUid) {
        throw StateError('WorkItem $workItemUuid is not in the current scope');
      }
      if (!isCaseSentinel && workItem.caseUuid != caseUuid) {
        throw StateError('WorkItem $workItemUuid belongs to another case');
      }
    }
  }

  CaseJudgementModel _judgementFromRow(CaseJudgement row) {
    return CaseJudgementModel(
      uuid: row.uuid,
      scopeUid: row.scopeUid,
      caseUuid: row.caseUuid,
      recordUuid: row.recordUuid,
      workItemUuid: row.workItemUuid,
      techniqueId: row.techniqueId,
      module: row.module,
      text: row.judgementText,
      detailText: row.detailText,
      indicatorLabel: row.indicatorLabel,
      patternLabel: row.patternLabel,
      status: row.status,
      keyBasis: row.keyBasis,
      attachedToKind: row.attachedToKind,
      orderIndex: row.orderIndex,
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      deletedAt: row.deletedAt?.toUtc(),
    );
  }

  CaseJudgementsCompanion _judgementToRow(CaseJudgementModel model) {
    return CaseJudgementsCompanion.insert(
      uuid: model.uuid,
      scopeUid: _store.scopeUid,
      caseUuid: model.caseUuid,
      recordUuid: Value(model.recordUuid),
      workItemUuid: Value(model.workItemUuid),
      techniqueId: Value(model.techniqueId),
      module: Value(model.module),
      judgementText: model.text,
      detailText: Value(model.detailText),
      indicatorLabel: Value(model.indicatorLabel),
      patternLabel: Value(model.patternLabel),
      status: model.status,
      keyBasis: Value(model.keyBasis),
      attachedToKind: Value(model.attachedToKind),
      orderIndex: model.orderIndex,
      createdAt: model.createdAt.toUtc(),
      updatedAt: model.updatedAt.toUtc(),
      deletedAt: Value(model.deletedAt?.toUtc()),
    );
  }
}
