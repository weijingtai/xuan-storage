// ACT-10：用户判断与个人规则 Drift 持久化适配器。
//
// 实现 LifeEventUserRuleStore 的四套 typed 方法（LEC-030，无联合入口）：
// 所有写入在单个 SQLite transaction 内完成，revision CAS 冲突零写入，
// ownerScope 是每次读写条件。另有方向目录的自有方法（saveDirection /
// queryDirections），供服务层注入；表结构见 life_event_user_rule_tables.dart。
//
// typed predicate（FilterExpression / TypedScalar）与用户原文以带 kind 标签的
// JSON 无损往返，禁止无版本 dynamic blob。不依赖 Flutter 或具体术数包。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';

import 'life_event_database.dart';

/// Drift 用户规则存储实现。
final class DriftLifeEventUserRuleStore implements LifeEventUserRuleStore {
  final LifeEventDatabase _db;

  DriftLifeEventUserRuleStore(this._db);

  // ---------------------------------------------------------------------
  // 方向目录（自有方法：契约接口不含方向；drift 表承担持久化）
  // ---------------------------------------------------------------------

  Future<void> saveDirection(UserDirection value) async {
    await _db.into(_db.lifeEventUserDirections).insertOnConflictUpdate(
      LifeEventUserDirectionRow(
        directionId: value.directionId,
        ownerScopeId: value.ownerScopeId,
        label: value.label,
        color: value.color,
        sortOrder: value.sortOrder,
        archivedAtMs: value.archivedAt?.millisecondsSinceEpoch,
      ),
    );
  }

  Future<List<UserDirection>> queryDirections(String ownerScopeId) async {
    final rows = await (_db.select(_db.lifeEventUserDirections)
          ..where((t) => t.ownerScopeId.equals(ownerScopeId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(_direction).toList();
  }

  // ---------------------------------------------------------------------
  // 批注
  // ---------------------------------------------------------------------

  @override
  Future<SaveAnnotationResult> saveAnnotation(SaveAnnotationRequest request) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.lifeEventUserAnnotations)
            ..where((t) => t.annotationId.equals(request.annotation.annotationId)))
          .getSingleOrNull();
      if (existing != null && existing.revision != request.expectedRevision) {
        return const SaveAnnotationResult(outcome: 'revisionConflict', revision: 0);
      }
      final ann = request.annotation;
      await _db.into(_db.lifeEventUserAnnotations).insertOnConflictUpdate(
        LifeEventUserAnnotationRow(
          annotationId: ann.annotationId,
          ownerScopeId: ann.ownerScopeId,
          title: ann.title,
          interpretation: ann.interpretation,
          importanceOwnerScopeId: ann.userImportanceRef?.ownerScopeId,
          importanceCatalogId: ann.userImportanceRef?.catalogId,
          importanceCatalogRevision: ann.userImportanceRef?.catalogRevision,
          importanceLevelId: ann.userImportanceRef?.levelId,
          tagsJson: jsonEncode(ann.tags),
          revision: ann.revision,
          createdAtMs: ann.createdAt.millisecondsSinceEpoch,
          updatedAtMs: ann.updatedAt.millisecondsSinceEpoch,
        ),
      );
      await _replaceAnnotationRefs(ann.annotationId, ann.targetSourceRefs, ann.directionIds);
      return SaveAnnotationResult(outcome: 'applied', revision: ann.revision);
    });
  }

  @override
  Future<AnnotationPage> queryAnnotations(AnnotationQuery query) async {
    final rows = await (_db.select(_db.lifeEventUserAnnotations)
          ..where((t) => t.ownerScopeId.equals(query.ownerScopeId)))
        .get();
    final items = <UserAnnotation>[];
    for (final row in rows) {
      final targets = await _annotationTargets(row.annotationId);
      final directions = await _annotationDirections(row.annotationId);
      if (query.targetSourceRefs.isNotEmpty &&
          !targets.any((t) => query.targetSourceRefs.contains(t))) {
        continue;
      }
      items.add(_annotation(row, targets, directions));
    }
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return AnnotationPage(items: items, nextPageToken: null);
  }

  // ---------------------------------------------------------------------
  // 单次事件选择
  // ---------------------------------------------------------------------

  @override
  Future<SaveOccurrenceSelectionResult> saveOccurrenceSelection(
    SaveOccurrenceSelectionRequest request,
  ) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.lifeEventOccurrenceSelections)
            ..where((t) => t.selectionId.equals(request.selection.selectionId)))
          .getSingleOrNull();
      if (existing != null && existing.revision != request.expectedRevision) {
        return const SaveOccurrenceSelectionResult(
          outcome: 'revisionConflict',
          revision: 0,
        );
      }
      final s = request.selection;
      await _db.into(_db.lifeEventOccurrenceSelections).insertOnConflictUpdate(
        LifeEventOccurrenceSelectionRow(
          selectionId: s.selectionId,
          ownerScopeId: s.ownerScopeId,
          revision: s.revision,
          sourceProviderId: s.sourceRef.providerId,
          sourceEventId: s.sourceRef.sourceEventId,
          sourceEventRevision: s.sourceRef.eventRevision,
          eventRevision: s.eventRevision,
          annotationRef: s.annotationRef,
        ),
      );
      return SaveOccurrenceSelectionResult(outcome: 'applied', revision: s.revision);
    });
  }

  @override
  Future<OccurrenceSelectionPage> queryOccurrenceSelections(
    OccurrenceSelectionQuery query,
  ) async {
    final q = _db.select(_db.lifeEventOccurrenceSelections)
      ..where((t) => t.ownerScopeId.equals(query.ownerScopeId));
    if (query.selectionIds.isNotEmpty) {
      q.where((t) => t.selectionId.isIn(query.selectionIds));
    }
    if (query.sourceRefs.isNotEmpty) {
      q.where((t) {
        final exprs = query.sourceRefs.map((ref) {
          return t.sourceProviderId.equals(ref.providerId) &
              t.sourceEventId.equals(ref.sourceEventId);
        });
        return exprs.reduce((a, b) => a | b);
      });
    }
    final rows = await q.get();
    final items = rows
        .map((r) => SavedOccurrenceSelection(
              selectionId: r.selectionId,
              ownerScopeId: r.ownerScopeId,
              revision: r.revision,
              sourceRef: SourceRef(
                providerId: r.sourceProviderId,
                sourceEventId: r.sourceEventId,
                eventRevision: r.sourceEventRevision,
              ),
              eventRevision: r.eventRevision,
              annotationRef: r.annotationRef,
            ))
        .toList();
    items.sort((a, b) => a.selectionId.compareTo(b.selectionId));
    return OccurrenceSelectionPage(items: items, nextPageToken: null);
  }

  // ---------------------------------------------------------------------
  // 持续条件规则
  // ---------------------------------------------------------------------

  @override
  Future<SavePatternRuleResult> savePatternRule(SavePatternRuleRequest request) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.lifeEventPatternRules)
            ..where((t) => t.savedPatternId.equals(request.rule.savedPatternId)))
          .getSingleOrNull();
      if (existing != null && existing.revision != request.expectedRevision) {
        return const SavePatternRuleResult(outcome: 'revisionConflict', revision: 0);
      }
      final r = request.rule;
      await _db.into(_db.lifeEventPatternRules).insertOnConflictUpdate(
        LifeEventPatternRuleRow(
          savedPatternId: r.savedPatternId,
          ownerScopeId: r.ownerScopeId,
          revision: r.revision,
          providerId: r.providerId,
          eventTypeId: r.eventTypeId,
          patternSchemaVersion: r.patternSchemaVersion,
          providerDescriptorVersion: r.providerDescriptorVersion,
          matcherSemanticVersion: r.matcherSemanticVersion,
          normalizedPatternJson: jsonEncode([
            for (final f in r.normalizedPattern) filterExpressionToJson(f),
          ]),
          patternFingerprint: r.patternFingerprint,
          annotationRef: r.annotationRef,
          enabledForMatching: r.enabledForMatching,
        ),
      );
      await (_db.delete(_db.lifeEventPatternTargetRefs)
            ..where((t) => t.savedPatternId.equals(r.savedPatternId)))
          .go();
      await _db.batch((b) {
        b.insertAll(
          _db.lifeEventPatternTargetRefs,
          [
            for (final s in r.targetSubjectIds)
              LifeEventPatternTargetRefRow(
                savedPatternId: r.savedPatternId,
                targetType: 'subject',
                targetId: s,
              ),
            for (final p in r.targetProfileIds)
              LifeEventPatternTargetRefRow(
                savedPatternId: r.savedPatternId,
                targetType: 'profile',
                targetId: p,
              ),
          ],
        );
      });
      return SavePatternRuleResult(outcome: 'applied', revision: r.revision);
    });
  }

  @override
  Future<PatternRulePage> queryPatternRules(PatternRuleQuery query) async {
    final q = _db.select(_db.lifeEventPatternRules)
      ..where((t) => t.ownerScopeId.equals(query.ownerScopeId));
    if (query.providerIds.isNotEmpty) {
      q.where((t) => t.providerId.isIn(query.providerIds));
    }
    if (query.eventTypeIds.isNotEmpty) {
      q.where((t) => t.eventTypeId.isIn(query.eventTypeIds));
    }
    if (query.enabledForMatching != null) {
      q.where((t) => t.enabledForMatching.equals(query.enabledForMatching!));
    }
    final rows = await q.get();
    final items = <SavedPatternRule>[];
    for (final row in rows) {
      final targets = await _patternTargets(row.savedPatternId);
      final json = jsonDecode(row.normalizedPatternJson) as List<dynamic>;
      items.add(SavedPatternRule(
        savedPatternId: row.savedPatternId,
        ownerScopeId: row.ownerScopeId,
        revision: row.revision,
        providerId: row.providerId,
        eventTypeId: row.eventTypeId,
        patternSchemaVersion: row.patternSchemaVersion,
        providerDescriptorVersion: row.providerDescriptorVersion,
        matcherSemanticVersion: row.matcherSemanticVersion,
        normalizedPattern: [
          for (final e in json) filterExpressionFromJson(e as Map<String, dynamic>),
        ],
        patternFingerprint: row.patternFingerprint,
        targetSubjectIds: targets['subject'] ?? const [],
        targetProfileIds: targets['profile'] ?? const [],
        annotationRef: row.annotationRef,
        enabledForMatching: row.enabledForMatching,
      ));
    }
    items.sort((a, b) => a.savedPatternId.compareTo(b.savedPatternId));
    return PatternRulePage(items: items, nextPageToken: null);
  }

  // ---------------------------------------------------------------------
  // 个人模板
  // ---------------------------------------------------------------------

  @override
  Future<SaveTemplateResult> saveTemplate(SaveTemplateRequest request) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.lifeEventRuleTemplates)
            ..where((t) => t.templateId.equals(request.template.templateId)))
          .getSingleOrNull();
      if (existing != null && existing.revision != request.expectedRevision) {
        return const SaveTemplateResult(outcome: 'revisionConflict', revision: 0);
      }
      final t = request.template;
      await _db.into(_db.lifeEventRuleTemplates).insertOnConflictUpdate(
        LifeEventRuleTemplateRow(
          templateId: t.templateId,
          ownerScopeId: t.ownerScopeId,
          revision: t.revision,
          providerPatternJson: jsonEncode([
            for (final f in t.providerPattern) filterExpressionToJson(f),
          ]),
          defaultDirectionIdsJson: jsonEncode(t.defaultDirectionIds),
          importanceOwnerScopeId: t.defaultUserImportanceRef?.ownerScopeId,
          importanceCatalogId: t.defaultUserImportanceRef?.catalogId,
          importanceCatalogRevision: t.defaultUserImportanceRef?.catalogRevision,
          importanceLevelId: t.defaultUserImportanceRef?.levelId,
          priorityOwnerScopeId: t.defaultNotificationPriorityRef?.ownerScopeId,
          priorityCatalogId: t.defaultNotificationPriorityRef?.catalogId,
          priorityCatalogRevision: t.defaultNotificationPriorityRef?.catalogRevision,
          priorityId: t.defaultNotificationPriorityRef?.priorityId,
          defaultChannelIdsJson: jsonEncode(t.defaultChannelIds),
          defaultLeadTimesMsJson: jsonEncode([
            for (final d in t.defaultLeadTimes) d.inMilliseconds,
          ]),
        ),
      );
      return SaveTemplateResult(outcome: 'applied', revision: t.revision);
    });
  }

  @override
  Future<TemplatePage> queryTemplates(TemplateQuery query) async {
    final rows = await (_db.select(_db.lifeEventRuleTemplates)
          ..where((t) => t.ownerScopeId.equals(query.ownerScopeId)))
        .get();
    final items = rows.map((r) {
      final patternJson = jsonDecode(r.providerPatternJson) as List<dynamic>;
      return PersonalRuleTemplate(
        templateId: r.templateId,
        ownerScopeId: r.ownerScopeId,
        providerPattern: [
          for (final e in patternJson)
            filterExpressionFromJson(e as Map<String, dynamic>),
        ],
        defaultDirectionIds: (jsonDecode(r.defaultDirectionIdsJson) as List<dynamic>)
            .cast<String>(),
        defaultUserImportanceRef: _templateImportanceRef(r),
        defaultNotificationPriorityRef: _priorityRef(r),
        defaultChannelIds: (jsonDecode(r.defaultChannelIdsJson) as List<dynamic>)
            .cast<String>(),
        defaultLeadTimes: [
          for (final ms in jsonDecode(r.defaultLeadTimesMsJson) as List<dynamic>)
            Duration(milliseconds: ms as int),
        ],
        revision: r.revision,
      );
    }).toList();
    items.sort((a, b) => a.templateId.compareTo(b.templateId));
    return TemplatePage(items: items, nextPageToken: null);
  }

  // ---------------------------------------------------------------------
  // 私有辅助
  // ---------------------------------------------------------------------

  Future<void> _replaceAnnotationRefs(
    String annotationId,
    List<SourceRef> targets,
    List<String> directionIds,
  ) async {
    await _db.batch((b) {
      b.deleteWhere(
        _db.lifeEventAnnotationTargetRefs,
        (t) => t.annotationId.equals(annotationId),
      );
      b.deleteWhere(
        _db.lifeEventAnnotationDirectionRefs,
        (t) => t.annotationId.equals(annotationId),
      );
      b.insertAll(
        _db.lifeEventAnnotationTargetRefs,
        [
          for (final t in targets)
            LifeEventAnnotationTargetRefRow(
              annotationId: annotationId,
              providerId: t.providerId,
              sourceEventId: t.sourceEventId,
              eventRevision: t.eventRevision,
            ),
        ],
      );
      b.insertAll(
        _db.lifeEventAnnotationDirectionRefs,
        [
          for (final d in directionIds)
            LifeEventAnnotationDirectionRefRow(
              annotationId: annotationId,
              directionId: d,
            ),
        ],
      );
    });
  }

  Future<List<SourceRef>> _annotationTargets(String annotationId) async {
    final rows = await (_db.select(_db.lifeEventAnnotationTargetRefs)
          ..where((t) => t.annotationId.equals(annotationId)))
        .get();
    return [
      for (final r in rows)
        SourceRef(
          providerId: r.providerId,
          sourceEventId: r.sourceEventId,
          eventRevision: r.eventRevision,
        ),
    ];
  }

  Future<List<String>> _annotationDirections(String annotationId) async {
    final rows = await (_db.select(_db.lifeEventAnnotationDirectionRefs)
          ..where((t) => t.annotationId.equals(annotationId)))
        .get();
    return [for (final r in rows) r.directionId];
  }

  Future<Map<String, List<String>>> _patternTargets(String savedPatternId) async {
    final rows = await (_db.select(_db.lifeEventPatternTargetRefs)
          ..where((t) => t.savedPatternId.equals(savedPatternId)))
        .get();
    final result = <String, List<String>>{};
    for (final r in rows) {
      result.putIfAbsent(r.targetType, () => []).add(r.targetId);
    }
    return result;
  }

  UserDirection _direction(LifeEventUserDirectionRow r) => UserDirection(
        directionId: r.directionId,
        ownerScopeId: r.ownerScopeId,
        label: r.label,
        color: r.color,
        sortOrder: r.sortOrder,
        archivedAt: r.archivedAtMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(r.archivedAtMs!),
      );

  UserAnnotation _annotation(
    LifeEventUserAnnotationRow r,
    List<SourceRef> targets,
    List<String> directions,
  ) =>
      UserAnnotation(
        annotationId: r.annotationId,
        ownerScopeId: r.ownerScopeId,
        targetSourceRefs: targets,
        directionIds: directions,
        title: r.title,
        interpretation: r.interpretation,
        userImportanceRef: _importanceRef(r),
        tags: (jsonDecode(r.tagsJson) as List<dynamic>).cast<String>(),
        revision: r.revision,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAtMs),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r.updatedAtMs),
      );

  UserImportanceRef? _importanceRef(LifeEventUserAnnotationRow r) {
    final owner = r.importanceOwnerScopeId;
    final catalog = r.importanceCatalogId;
    final revision = r.importanceCatalogRevision;
    final level = r.importanceLevelId;
    if (owner == null || catalog == null || revision == null || level == null) {
      return null;
    }
    return UserImportanceRef(
      ownerScopeId: owner,
      catalogId: catalog,
      catalogRevision: revision,
      levelId: level,
    );
  }

  UserImportanceRef? _templateImportanceRef(LifeEventRuleTemplateRow r) {
    final owner = r.importanceOwnerScopeId;
    final catalog = r.importanceCatalogId;
    final revision = r.importanceCatalogRevision;
    final level = r.importanceLevelId;
    if (owner == null || catalog == null || revision == null || level == null) {
      return null;
    }
    return UserImportanceRef(
      ownerScopeId: owner,
      catalogId: catalog,
      catalogRevision: revision,
      levelId: level,
    );
  }

  NotificationPriorityRef? _priorityRef(LifeEventRuleTemplateRow r) {
    final owner = r.priorityOwnerScopeId;
    final catalog = r.priorityCatalogId;
    final revision = r.priorityCatalogRevision;
    final priority = r.priorityId;
    if (owner == null || catalog == null || revision == null || priority == null) {
      return null;
    }
    return NotificationPriorityRef(
      ownerScopeId: owner,
      catalogId: catalog,
      catalogRevision: revision,
      priorityId: priority,
    );
  }
}

// ---------------------------------------------------------------------------
// typed predicate JSON 编解码（带 kind 标签，无损往返；不落无版本 blob）。
// ---------------------------------------------------------------------------

Map<String, dynamic> filterExpressionToJson(FilterExpression f) => {
      'filterId': f.filterId,
      'projectionPath': f.projectionPath,
      'operator': f.operator.name,
      'operands': [for (final o in f.operands) scalarToJson(o)],
      'operandSchemaVersion': f.operandSchemaVersion,
    };

FilterExpression filterExpressionFromJson(Map<String, dynamic> m) =>
    FilterExpression(
      filterId: m['filterId'] as String,
      projectionPath: m['projectionPath'] as String,
      operator: FilterOperator.values.byName(m['operator'] as String),
      operands: [
        for (final o in m['operands'] as List<dynamic>)
          scalarFromJson(o as Map<String, dynamic>),
      ],
      operandSchemaVersion: m['operandSchemaVersion'] as String,
    );

Map<String, dynamic> scalarToJson(TypedScalar s) => switch (s) {
      TextScalar() => {
          'kind': 'text',
          'fieldId': s.fieldId,
          'schemaVersion': s.schemaVersion,
          'value': s.value,
        },
      NumberScalar() => {
          'kind': 'number',
          'fieldId': s.fieldId,
          'schemaVersion': s.schemaVersion,
          'value': s.value,
        },
      BooleanScalar() => {
          'kind': 'boolean',
          'fieldId': s.fieldId,
          'schemaVersion': s.schemaVersion,
          'value': s.value,
        },
      EnumScalar() => {
          'kind': 'enum',
          'fieldId': s.fieldId,
          'schemaVersion': s.schemaVersion,
          'code': s.code,
          'catalogVersion': s.catalogVersion,
        },
      MultiEnumScalar() => {
          'kind': 'multi_enum',
          'fieldId': s.fieldId,
          'schemaVersion': s.schemaVersion,
          'codes': s.codes,
          'catalogVersion': s.catalogVersion,
        },
      UnknownScalar() => {
          'kind': 'unknown',
          'fieldId': s.fieldId,
          'schemaVersion': s.schemaVersion,
          'rawEncoded': s.rawEncoded,
        },
    };

TypedScalar scalarFromJson(Map<String, dynamic> m) => switch (m['kind'] as String) {
      'text' => TextScalar(
          fieldId: m['fieldId'] as String,
          schemaVersion: m['schemaVersion'] as String,
          value: m['value'] as String,
        ),
      'number' => NumberScalar(
          fieldId: m['fieldId'] as String,
          schemaVersion: m['schemaVersion'] as String,
          value: m['value'] as num,
        ),
      'boolean' => BooleanScalar(
          fieldId: m['fieldId'] as String,
          schemaVersion: m['schemaVersion'] as String,
          value: m['value'] as bool,
        ),
      'enum' => EnumScalar(
          fieldId: m['fieldId'] as String,
          schemaVersion: m['schemaVersion'] as String,
          code: m['code'] as String,
          catalogVersion: m['catalogVersion'] as String,
        ),
      'multi_enum' => MultiEnumScalar(
          fieldId: m['fieldId'] as String,
          schemaVersion: m['schemaVersion'] as String,
          codes: (m['codes'] as List<dynamic>).cast<String>(),
          catalogVersion: m['catalogVersion'] as String,
        ),
      _ => UnknownScalar(
          fieldId: m['fieldId'] as String,
          schemaVersion: m['schemaVersion'] as String,
          rawEncoded: m['rawEncoded'] as String,
        ),
    };