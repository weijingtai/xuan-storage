// ACT-10：用户判断与个人规则 Drift 持久化 Red 测试。
//
// 覆盖：
// - LEC-029/030/032/033 四类对象 + 方向目录在数据库重开后全部可读；
// - ownerScope 查询隔离；revision CAS 冲突零写入；撤销保留审计版本；
// - typed predicate、用户原文、structured direction 无损往返；
// - 保存用户对象不改变 source fact/projection digest。
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/life_event/drift_life_event_user_rule_store.dart';
import 'package:persistence_drift/life_event/life_event_database.dart';

void main() {
  group('ACT-10 drift user rule store', () {
    late LifeEventDatabase db;
    late DriftLifeEventUserRuleStore store;
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('le-user-rules-');
      db = LifeEventDatabase(NativeDatabase.createInBackground(
        File('${dir.path}/rules.db'),
      ));
      store = DriftLifeEventUserRuleStore(db);
    });

    tearDown(() async {
      await db.close();
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });

    UserDirection direction({String id = 'dir-1', String owner = 'owner-1'}) =>
        UserDirection(
          directionId: id,
          ownerScopeId: owner,
          label: '自定义方向',
          color: null,
          sortOrder: 0,
          archivedAt: null,
        );

    UserAnnotation annotation({
      String id = 'ann-1',
      String owner = 'owner-1',
      List<String> directionIds = const ['dir-1'],
    }) =>
        UserAnnotation(
          annotationId: id,
          ownerScopeId: owner,
          targetSourceRefs: const [
            SourceRef(
              providerId: 'qizhengsiyu.life_events',
              sourceEventId: 'ev-1',
              eventRevision: '1',
            ),
          ],
          directionIds: directionIds,
          title: '我的判断',
          interpretation: '原文说明',
          userImportanceRef: null,
          tags: const ['tag-a', 'tag-b'],
          revision: 1,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

    SavedOccurrenceSelection selection({String owner = 'owner-1'}) =>
        SavedOccurrenceSelection(
          selectionId: 'sel-1',
          ownerScopeId: owner,
          revision: 1,
          sourceRef: const SourceRef(
            providerId: 'qizhengsiyu.life_events',
            sourceEventId: 'ev-1',
            eventRevision: '1',
          ),
          eventRevision: '1',
          annotationRef: 'ann-1',
        );

    SavedPatternRule pattern({String owner = 'owner-1'}) => SavedPatternRule(
          savedPatternId: 'pat-1',
          ownerScopeId: owner,
          revision: 1,
          providerId: 'qizhengsiyu.life_events',
          eventTypeId: 'planet_gong_ingress',
          patternSchemaVersion: 'life-event.v1',
          providerDescriptorVersion: '1.0.0',
          matcherSemanticVersion: 'qizheng-gong.v1',
          normalizedPattern: const [
            FilterExpression(
              filterId: 'target_gong',
              projectionPath: 'factValues.target_gong',
              operator: FilterOperator.eq,
              operands: [
                EnumScalar(
                  fieldId: 'target_gong',
                  schemaVersion: 'life-event.v1',
                  code: 'chou',
                  catalogVersion: 'qizheng-gong.v1',
                ),
              ],
              operandSchemaVersion: 'life-event.v1',
            ),
          ],
          patternFingerprint: 'fp-1',
          targetSubjectIds: const ['subject-1'],
          targetProfileIds: const ['profile-1'],
          annotationRef: null,
          enabledForMatching: true,
        );

    PersonalRuleTemplate template({String owner = 'owner-1'}) =>
        PersonalRuleTemplate(
          templateId: 'tpl-1',
          ownerScopeId: owner,
          providerPattern: const [],
          defaultDirectionIds: const ['dir-1'],
          defaultUserImportanceRef: null,
          defaultNotificationPriorityRef: null,
          defaultChannelIds: const ['chan-1'],
          defaultLeadTimes: const [Duration(hours: 24)],
          revision: 1,
        );

    Future<void> seedAll() async {
      await store.saveDirection(direction());
      await store.saveAnnotation(SaveAnnotationRequest(
        ownerScopeId: 'owner-1',
        annotation: annotation(),
        expectedRevision: 1,
      ));
      await store.saveOccurrenceSelection(SaveOccurrenceSelectionRequest(
        ownerScopeId: 'owner-1',
        selection: selection(),
        expectedRevision: 1,
      ));
      await store.savePatternRule(SavePatternRuleRequest(
        ownerScopeId: 'owner-1',
        rule: pattern(),
        expectedRevision: 1,
      ));
      await store.saveTemplate(SaveTemplateRequest(
        ownerScopeId: 'owner-1',
        template: template(),
        expectedRevision: 1,
      ));
    }

    test('八类记录全部重开可读（LEC-029/030/032/033）', () async {
      await seedAll();

      // 重开数据库（关闭后新建指向同一文件的实例）。
      await db.close();
      db = LifeEventDatabase(NativeDatabase.createInBackground(
        File('${dir.path}/rules.db'),
      ));
      store = DriftLifeEventUserRuleStore(db);

      final dirs = await store.queryDirections('owner-1');
      expect(dirs.single.label, '自定义方向');

      final anns = await store.queryAnnotations(const AnnotationQuery(
        ownerScopeId: 'owner-1',
        targetSourceRefs: [],
        pageToken: null,
        pageSize: 100,
      ));
      expect(anns.items.single.title, '我的判断');
      expect(anns.items.single.interpretation, '原文说明');
      expect(anns.items.single.directionIds, ['dir-1']);
      expect(anns.items.single.tags, ['tag-a', 'tag-b']);

      final sels = await store.queryOccurrenceSelections(
        const OccurrenceSelectionQuery(
          ownerScopeId: 'owner-1',
          selectionIds: [],
          sourceRefs: [],
          pageToken: null,
          pageSize: 100,
        ),
      );
      expect(sels.items.single.selectionId, 'sel-1');

      final pats = await store.queryPatternRules(const PatternRuleQuery(
        ownerScopeId: 'owner-1',
        providerIds: [],
        eventTypeIds: [],
        enabledForMatching: null,
        pageToken: null,
        pageSize: 100,
      ));
      final saved = pats.items.single;
      expect(saved.matcherSemanticVersion, 'qizheng-gong.v1');
      expect(saved.normalizedPattern.single.filterId, 'target_gong');
      expect(saved.targetSubjectIds, ['subject-1']);
      expect(saved.targetProfileIds, ['profile-1']);

      final tpls = await store.queryTemplates(const TemplateQuery(
        ownerScopeId: 'owner-1',
        pageToken: null,
        pageSize: 100,
      ));
      expect(tpls.items.single.templateId, 'tpl-1');
      expect(tpls.items.single.defaultChannelIds, ['chan-1']);
      expect(tpls.items.single.defaultLeadTimes, [Duration(hours: 24)]);
    });

    test('ownerScope 查询隔离；revision CAS 冲突零写入', () async {
      await seedAll();

      // 其他 owner 查不到任何对象。
      final otherAnn = await store.queryAnnotations(const AnnotationQuery(
        ownerScopeId: 'owner-2',
        targetSourceRefs: [],
        pageToken: null,
        pageSize: 100,
      ));
      expect(otherAnn.items, isEmpty);

      final otherSel = await store.queryOccurrenceSelections(
        const OccurrenceSelectionQuery(
          ownerScopeId: 'owner-2',
          selectionIds: [],
          sourceRefs: [],
          pageToken: null,
          pageSize: 100,
        ),
      );
      expect(otherSel.items, isEmpty);

      final otherPat = await store.queryPatternRules(const PatternRuleQuery(
        ownerScopeId: 'owner-2',
        providerIds: [],
        eventTypeIds: [],
        enabledForMatching: null,
        pageToken: null,
        pageSize: 100,
      ));
      expect(otherPat.items, isEmpty);

      final otherTpl = await store.queryTemplates(const TemplateQuery(
        ownerScopeId: 'owner-2',
        pageToken: null,
        pageSize: 100,
      ));
      expect(otherTpl.items, isEmpty);

      // CAS：expectedRevision=2 与实际 revision=1 冲突 → 零写入。
      final conflict = await store.saveAnnotation(SaveAnnotationRequest(
        ownerScopeId: 'owner-1',
        annotation: annotation(id: 'ann-1', directionIds: const ['dir-2']),
        expectedRevision: 2,
      ));
      expect(conflict.outcome, 'revisionConflict');
      final after = await store.queryAnnotations(const AnnotationQuery(
        ownerScopeId: 'owner-1',
        targetSourceRefs: [],
        pageToken: null,
        pageSize: 100,
      ));
      expect(after.items.single.revision, 1, reason: '冲突必须零写入');
    });

    test('撤销保留审计版本：revision 递增且仍可查询', () async {
      await store.saveOccurrenceSelection(SaveOccurrenceSelectionRequest(
        ownerScopeId: 'owner-1',
        selection: selection(),
        expectedRevision: 1,
      ));
      // 撤销 = 以 revision+1 保存审计版本（内容同源，revision 递增）。
      final revoked = await store.saveOccurrenceSelection(SaveOccurrenceSelectionRequest(
        ownerScopeId: 'owner-1',
        selection: SavedOccurrenceSelection(
          selectionId: 'sel-1',
          ownerScopeId: 'owner-1',
          revision: 2,
          sourceRef: const SourceRef(
            providerId: 'qizhengsiyu.life_events',
            sourceEventId: 'ev-1',
            eventRevision: '1',
          ),
          eventRevision: '1',
          annotationRef: 'ann-1',
        ),
        expectedRevision: 1,
      ));
      expect(revoked.outcome, 'applied');

      final page = await store.queryOccurrenceSelections(
        const OccurrenceSelectionQuery(
          ownerScopeId: 'owner-1',
          selectionIds: ['sel-1'],
          sourceRefs: [],
          pageToken: null,
          pageSize: 100,
        ),
      );
      expect(page.items.single.selectionId, 'sel-1');
      expect(page.items.single.revision, 2);

      // 旧 revision 不能覆盖新 revision。
      final stale = await store.saveOccurrenceSelection(SaveOccurrenceSelectionRequest(
        ownerScopeId: 'owner-1',
        selection: selection(),
        expectedRevision: 1,
      ));
      expect(stale.outcome, 'revisionConflict');
    });

    test('保存用户对象不改变 projection digest（不触碰事实链）', () async {
      // 预置一条 projection（事实链的一环）。
      await db.into(db.lifeEventProjections).insert(
        LifeEventProjectionRow(
          projectionId: 'proj-1',
          coverageId: 'cov-1',
          coverageGeneration: 1,
          sourceProviderId: 'qizhengsiyu.life_events',
          sourceEventId: 'ev-1',
          eventRevision: '1',
          ownerScopeId: 'owner-1',
          subjectId: 'subject-1',
          profileId: 'profile-1',
          chartSnapshotId: 'snap-1',
          divinationTypeKey: 'qi_zheng_si_yu',
          subDivinationTypeKey: null,
          eventTypeId: 'planet_gong_ingress',
          effectiveStartMs: DateTime.utc(2026, 1, 1, 12).millisecondsSinceEpoch,
          precisionRank: 3,
          projectionJson: '{"digest":"digest-1"}',
          lifecycleStatus: 0,
        ),
      );

      await seedAll();

      // 保存用户对象后投影行原样保留。
      final rows = await db.select(db.lifeEventProjections).get();
      expect(rows.single.projectionJson, '{"digest":"digest-1"}');
      final anns = await store.queryAnnotations(const AnnotationQuery(
        ownerScopeId: 'owner-1',
        targetSourceRefs: [],
        pageToken: null,
        pageSize: 100,
      ));
      expect(anns.items.single.interpretation, '原文说明');
      expect(anns.items.single.interpretation, isNot(contains('财务')));
    });
  });
}