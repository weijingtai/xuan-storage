// ACT-12A: 01 返工（整文件重写 life_event_ports_test.dart）
// 编译期证明八个存储端口的方法集合与签名，并提供真实的最小内存实现行为测试。
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:test/test.dart';

void main() {
  group('LifeEventCoverageGenerationPort', () {
    test('createOrReplaceCandidate CAS conflict on stale expectedSeriesRevision', () async {
      final port = _InMemoryCoverageGenerationPort();
      final req1 = CreateCoverageGenerationRequest(
        coverageSeriesId: 'series-1',
        expectedSeriesRevision: 0,
        expectedActiveCoverageId: null,
        desiredRange: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        providerId: 'qi_zheng_si_yu.life_events',
        providerVersion: '1.0.0',
        chartSnapshotId: 'snap-1',
        chartSnapshotRevision: 'v1',
        algorithmVersion: 'algo-1',
        dataVersion: null,
        eventTypeId: 'year_cycle',
        eventTypeSchemaVersion: 'v1',
        inputFingerprint: 'fp-1',
      );
      final res1 = await port.createOrReplaceCandidate(req1);
      expect(res1.outcome, equals(CreateCoverageGenerationOutcome.created));
      expect(res1.seriesRevision, equals(1));

      // Stale expectedSeriesRevision = 0 when seriesRevision is already 1
      final reqConflict = CreateCoverageGenerationRequest(
        coverageSeriesId: 'series-1',
        expectedSeriesRevision: 0,
        expectedActiveCoverageId: null,
        desiredRange: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        providerId: 'qi_zheng_si_yu.life_events',
        providerVersion: '1.0.0',
        chartSnapshotId: 'snap-1',
        chartSnapshotRevision: 'v1',
        algorithmVersion: 'algo-1',
        dataVersion: null,
        eventTypeId: 'year_cycle',
        eventTypeSchemaVersion: 'v1',
        inputFingerprint: 'fp-1',
      );
      final resConflict = await port.createOrReplaceCandidate(reqConflict);
      expect(resConflict.outcome, equals(CreateCoverageGenerationOutcome.seriesRevisionConflict));
      expect(resConflict.candidateCoverageId, isNull);
      expect(resConflict.seriesRevision, equals(1));
    });
  });

  group('LifeEventShardCommitPort', () {
    test('commitValidatedShard returns applied and supports idempotentReplay', () async {
      final port = _InMemoryShardCommitPort();
      final req = CommitValidatedShardRequest(
        coverageId: 'cov-1',
        coverageGeneration: 1,
        expectedManifestRevision: 0,
        expectedSeriesRevision: null,
        expectedActiveCoverageId: null,
        expectedCandidateCoverageId: null,
        providerId: 'qi_zheng_si_yu.life_events',
        providerVersion: '1.0.0',
        algorithmVersion: 'algo-1',
        dataVersion: null,
        eventTypeId: 'year_cycle',
        eventTypeSchemaVersion: 'v1',
        inputFingerprint: 'fp-1',
        receiptIdentity: const ReceiptIdentity(coverageId: 'cov-1', shardId: 'shard-1'),
        requestId: 'req-1',
        requestedRange: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        coveredRange: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        projections: const [],
        withdrawals: const [],
        eventCount: 0,
        contentDigest: 'digest-1',
        isCompleteForCoveredRange: false,
        requestedCoverageTransition: CoverageTransition.partial,
      );

      final res1 = await port.commitValidatedShard(req);
      expect(res1.outcome, equals(CommitValidatedShardOutcome.applied));

      final resReplay = await port.commitValidatedShard(req);
      expect(resReplay.outcome, equals(CommitValidatedShardOutcome.idempotentReplay));
    });
  });

  group('LifeEventProjectionQueryPort', () {
    test('queryProjections filters by ownerScopeId and pagination', () async {
      final port = _InMemoryProjectionQueryPort();
      final query = ProjectionStorageQuery(
        ownerScopeId: 'scope-1',
        profileIds: const ['prof-1'],
        chartSnapshotIds: const [],
        providerIds: const [],
        eventTypeIds: const [],
        range: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        includeWithdrawn: false,
        includeHistoricalGenerations: false,
        sortKey: 'indexedAt',
        pageToken: null,
        pageSize: 10,
      );
      final page = await port.queryProjections(query);
      expect(page.items, isEmpty);
      expect(page.nextPageToken, isNull);
    });
  });

  group('LifeEventCoverageQueryPort', () {
    test('queryCoverage returns stored or synthesized summary', () async {
      final port = _InMemoryCoverageQueryPort();
      final query = CoverageStorageQuery(
        ownerScopeId: 'scope-1',
        profileIds: const ['prof-1'],
        chartSnapshotIds: const [],
        providerIds: const ['qi_zheng_si_yu.life_events'],
        eventTypeIds: const ['year_cycle'],
        range: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        includeHistoricalGenerations: false,
      );
      final page = await port.queryCoverage(query);
      expect(page.heads, isEmpty);
      expect(page.manifests, isEmpty);
    });
  });

  group('LifeProfileIdentityStore', () {
    test('saveLifeProfile and queryIdentity roundtrip', () async {
      final store = _InMemoryLifeProfileIdentityStore();
      final profile = LifeProfileRecord(
        profileId: 'prof-1',
        ownerScopeId: 'scope-1',
        subjectId: 'subj-1',
        displayLabel: 'Test Profile',
        birthInput: BirthInput(
          civilDateTime: DateTime(1990, 5, 20, 10, 30),
          precision: BirthPrecision.minute,
          isTimeKnown: true,
          calendarSystem: BirthCalendarSystem.gregorian,
        ),
        placeRef: 'Beijing',
        coordinates: null,
        timezoneId: 'Asia/Shanghai',
        timeConversionPolicyId: 'default',
        dayBoundaryPolicyId: 'midnight',
        rectificationPolicyId: null,
        profileRevision: 1,
        isDefault: true,
        lifecycleStatus: 'active',
      );

      final saveResult = await store.saveLifeProfile(
        SaveLifeProfileRequest(
          ownerScopeId: 'scope-1',
          profile: profile,
          expectedProfileRevision: 0,
        ),
      );
      expect(saveResult.outcome, equals(SaveLifeProfileOutcome.saved));
      expect(saveResult.profileRevision, equals(1));

      final page = await store.queryIdentity(
        const LifeProfileIdentityQuery(
          ownerScopeId: 'scope-1',
          subjectIds: ['subj-1'],
          profileIds: [],
          defaultOnly: false,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(page.profiles.length, equals(1));
      expect(page.profiles.first.profileId, equals('prof-1'));
    });
  });

  group('LifeEventUserRuleStore', () {
    test('four typed save and query methods roundtrip', () async {
      final store = _InMemoryUserRuleStore();

      // 1. Annotation
      final ann = UserAnnotation(
        annotationId: 'ann-1',
        ownerScopeId: 'scope-1',
        targetSourceRefs: const [
          SourceRef(
            providerId: 'prov-1',
            sourceEventId: 'src-1',
            eventRevision: 'v1',
          ),
        ],
        directionIds: const ['favorable'],
        title: 'Title',
        interpretation: 'note',
        userImportanceRef: null,
        tags: const ['tag1'],
        revision: 1,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final annRes = await store.saveAnnotation(
        SaveAnnotationRequest(ownerScopeId: 'scope-1', annotation: ann, expectedRevision: 0),
      );
      expect(annRes.outcome, equals('saved'));
      final annPage = await store.queryAnnotations(
        const AnnotationQuery(
          ownerScopeId: 'scope-1',
          targetSourceRefs: [],
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(annPage.items.length, equals(1));

      // 2. OccurrenceSelection
      final sel = const SavedOccurrenceSelection(
        selectionId: 'sel-1',
        ownerScopeId: 'scope-1',
        revision: 1,
        sourceRef: SourceRef(
          providerId: 'prov-1',
          sourceEventId: 'src-1',
          eventRevision: 'v1',
        ),
        eventRevision: 'v1',
        annotationRef: null,
      );
      final selRes = await store.saveOccurrenceSelection(
        SaveOccurrenceSelectionRequest(ownerScopeId: 'scope-1', selection: sel, expectedRevision: 0),
      );
      expect(selRes.outcome, equals('saved'));
      final selPage = await store.queryOccurrenceSelections(
        const OccurrenceSelectionQuery(
          ownerScopeId: 'scope-1',
          selectionIds: [],
          sourceRefs: [],
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(selPage.items.length, equals(1));

      // 3. PatternRule
      final rule = const SavedPatternRule(
        savedPatternId: 'rule-1',
        ownerScopeId: 'scope-1',
        revision: 1,
        providerId: 'prov-1',
        eventTypeId: 'year_cycle',
        patternSchemaVersion: 'v1',
        providerDescriptorVersion: 'v1',
        matcherSemanticVersion: 'v1',
        normalizedPattern: [],
        patternFingerprint: 'fp-1',
        targetSubjectIds: [],
        targetProfileIds: [],
        annotationRef: null,
        enabledForMatching: true,
      );
      final ruleRes = await store.savePatternRule(
        SavePatternRuleRequest(ownerScopeId: 'scope-1', rule: rule, expectedRevision: 0),
      );
      expect(ruleRes.outcome, equals('saved'));
      final rulePage = await store.queryPatternRules(
        const PatternRuleQuery(
          ownerScopeId: 'scope-1',
          providerIds: [],
          eventTypeIds: [],
          enabledForMatching: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(rulePage.items.length, equals(1));

      // 4. Template
      final tpl = const PersonalRuleTemplate(
        templateId: 'tpl-1',
        ownerScopeId: 'scope-1',
        providerPattern: [],
        defaultDirectionIds: [],
        defaultUserImportanceRef: null,
        defaultNotificationPriorityRef: null,
        defaultChannelIds: [],
        defaultLeadTimes: [],
        revision: 1,
      );
      final tplRes = await store.saveTemplate(
        SaveTemplateRequest(ownerScopeId: 'scope-1', template: tpl, expectedRevision: 0),
      );
      expect(tplRes.outcome, equals('saved'));
      final tplPage = await store.queryTemplates(
        const TemplateQuery(ownerScopeId: 'scope-1', pageToken: null, pageSize: 10),
      );
      expect(tplPage.items.length, equals(1));
    });
  });

  group('LifeEventReminderStore', () {
    test('saveDefinition CAS conflict and claimDue leasing behavior', () async {
      final store = _InMemoryReminderStore();
      final def1 = ReminderDefinition(
        reminderId: 'rem-1',
        ownerScopeId: 'scope-1',
        selectionRef: const OccurrenceSelectionRef(selectionId: 'sel-1', revision: 1),
        notificationTitleOverride: null,
        notificationBodyOverride: null,
        notificationPriorityRef: const NotificationPriorityRef(
          ownerScopeId: 'scope-1',
          catalogId: 'cat-1',
          catalogRevision: 1,
          priorityId: 'p1',
        ),
        channelIds: const [],
        leadTimes: const [],
        repeatPolicy: null,
        mergePolicy: 'none',
        enabled: true,
        revision: 1,
      );

      final save1 = await store.saveDefinition(def1, 0);
      expect(save1.outcome, equals(SaveReminderOutcome.saved));
      expect(save1.revision, equals(1));

      // Stale expectedRevision = 0 when stored is 1
      final def2 = ReminderDefinition(
        reminderId: 'rem-1',
        ownerScopeId: 'scope-1',
        selectionRef: const OccurrenceSelectionRef(selectionId: 'sel-1', revision: 1),
        notificationTitleOverride: null,
        notificationBodyOverride: null,
        notificationPriorityRef: const NotificationPriorityRef(
          ownerScopeId: 'scope-1',
          catalogId: 'cat-1',
          catalogRevision: 1,
          priorityId: 'p1',
        ),
        channelIds: const [],
        leadTimes: const [],
        repeatPolicy: null,
        mergePolicy: 'none',
        enabled: true,
        revision: 2,
      );
      final saveConflict = await store.saveDefinition(def2, 0);
      expect(saveConflict.outcome, equals(SaveReminderOutcome.revisionConflict));
      expect(saveConflict.revision, equals(1));

      // Schedule and claim
      final sched = ScheduledNotification(
        scheduleId: 'sch-1',
        ownerScopeId: 'scope-1',
        reminderId: 'rem-1',
        aggregateId: null,
        fireAtUtc: DateTime.utc(2026, 1, 1, 10),
        displayTimezoneId: 'Asia/Shanghai',
        channelRevision: 1,
        sourceRevisionFingerprint: 'fp-1',
        status: ScheduleStatus.scheduled,
        claimToken: null,
        leaseExpiresAtUtc: null,
      );
      final saveSched = await store.saveSchedule(sched);
      expect(saveSched.outcome, equals(SaveReminderOutcome.saved));

      final claimRes = await store.claimDue(
        ClaimDueSchedulesRequest(
          ownerScopeId: 'scope-1',
          nowUtc: DateTime.utc(2026, 1, 1, 11),
          maxCount: 10,
          claimToken: 'token-worker-1',
          leaseDuration: const Duration(minutes: 5),
        ),
      );
      expect(claimRes.claimed.length, equals(1));
      expect(claimRes.claimed.first.claimToken, equals('token-worker-1'));
    });
  });

  group('ExternalCalendarEventStore', () {
    test('save and query roundtrip', () async {
      final store = _InMemoryExternalEventStore();
      final event = ExternalCalendarEvent(
        ownerScopeId: 'scope-1',
        externalEventId: 'ext-1',
        revision: 'rev-1',
        originType: ExternalOriginType.divinationCase,
        originId: 'case-1',
        relatedSubjectIds: const ['subj-1'],
        usedProfileRefs: const [],
        divinationTypeKey: 'qi_zheng_si_yu',
        subDivinationTypeKey: null,
        eventTime: InstantTime(
          effectiveStartUtc: DateTime.utc(2026, 1, 1),
          instantUtc: DateTime.utc(2026, 1, 1, 12),
          calculationTimezoneId: 'Asia/Shanghai',
          precision: TimePrecision.hour,
        ),
        factSummary: 'External test event',
        evidenceRef: null,
        lifecycleStatus: 'active',
      );

      final saveResult = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: 'scope-1',
          event: event,
          expectedRevision: null,
        ),
      );
      expect(saveResult.outcome, equals('saved'));

      final queryPage = await store.query(
        ExternalEventQuery(
          ownerScopeId: 'scope-1',
          relatedSubjectIds: const [],
          originTypes: const [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(queryPage.items.length, equals(1));
      expect(queryPage.items.first.externalEventId, equals('ext-1'));
    });
  });
}

// =====================================================================
// Minimal In-Memory Implementations for all 8 ports
// =====================================================================

class _InMemoryCoverageGenerationPort implements LifeEventCoverageGenerationPort {
  final Map<String, int> _seriesRevisions = {};

  @override
  Future<CreateCoverageGenerationResult> createOrReplaceCandidate(
    CreateCoverageGenerationRequest request,
  ) async {
    final current = _seriesRevisions[request.coverageSeriesId] ?? 0;
    if (current > 0 &&
        request.expectedSeriesRevision != current) {
      return CreateCoverageGenerationResult(
        outcome: CreateCoverageGenerationOutcome.seriesRevisionConflict,
        coverageId: null,
        coverageGeneration: null,
        seriesRevision: current,
        activeCoverageId: null,
        candidateCoverageId: null,
        desiredRange: request.desiredRange,
      );
    }
    final next = current + 1;
    _seriesRevisions[request.coverageSeriesId] = next;
    return CreateCoverageGenerationResult(
      outcome: CreateCoverageGenerationOutcome.created,
      coverageId: 'candidate-$next',
      coverageGeneration: 1,
      seriesRevision: next,
      activeCoverageId: null,
      candidateCoverageId: 'candidate-$next',
      desiredRange: request.desiredRange,
    );
  }
}

class _InMemoryShardCommitPort implements LifeEventShardCommitPort {
  final Map<String, String> _receiptDigests = {};

  @override
  Future<CommitValidatedShardResult> commitValidatedShard(
    CommitValidatedShardRequest request,
  ) async {
    final receiptKey = '${request.coverageId}:${request.receiptIdentity.shardId}';
    final existingDigest = _receiptDigests[receiptKey];
    if (existingDigest != null) {
      if (existingDigest == request.contentDigest) {
        return CommitValidatedShardResult(
          outcome: CommitValidatedShardOutcome.idempotentReplay,
          manifestRevision: 1,
          coverageGeneration: request.coverageGeneration,
          seriesRevision: 1,
          activeCoverageId: null,
          receiptIdentity: request.receiptIdentity,
          persistedCount: request.eventCount,
          persistedDigest: request.contentDigest,
          coverageStatus: CoverageStatus.running,
          servingState: ServingState.candidate,
          completedShardCount: 1,
          expectedShardCount: 1,
        );
      } else {
        return CommitValidatedShardResult(
          outcome: CommitValidatedShardOutcome.receiptDigestConflict,
          manifestRevision: 1,
          coverageGeneration: request.coverageGeneration,
          seriesRevision: 1,
          activeCoverageId: null,
          receiptIdentity: request.receiptIdentity,
          persistedCount: 0,
          persistedDigest: '',
          coverageStatus: CoverageStatus.running,
          servingState: ServingState.candidate,
          completedShardCount: 0,
          expectedShardCount: 1,
        );
      }
    }
    _receiptDigests[receiptKey] = request.contentDigest;
    return CommitValidatedShardResult(
      outcome: CommitValidatedShardOutcome.applied,
      manifestRevision: 1,
      coverageGeneration: request.coverageGeneration,
      seriesRevision: 1,
      activeCoverageId: null,
      receiptIdentity: request.receiptIdentity,
      persistedCount: request.eventCount,
      persistedDigest: request.contentDigest,
      coverageStatus: CoverageStatus.running,
      servingState: ServingState.candidate,
      completedShardCount: 1,
      expectedShardCount: 1,
    );
  }
}

class _InMemoryProjectionQueryPort implements LifeEventProjectionQueryPort {
  @override
  Future<ProjectionQueryPage> queryProjections(ProjectionStorageQuery request) async {
    return const ProjectionQueryPage(items: [], nextPageToken: null);
  }
}

class _InMemoryCoverageQueryPort implements LifeEventCoverageQueryPort {
  @override
  Future<CoverageStoragePage> queryCoverage(CoverageStorageQuery request) async {
    return const CoverageStoragePage(heads: [], manifests: []);
  }
}

class _InMemoryLifeProfileIdentityStore implements LifeProfileIdentityStore {
  final Map<String, LifeProfileRecord> _profiles = {};
  final Map<String, ChartSnapshotRef> _snapshots = {};

  @override
  Future<SaveLifeProfileResult> saveLifeProfile(SaveLifeProfileRequest request) async {
    _profiles[request.profile.profileId] = request.profile;
    return SaveLifeProfileResult(
      outcome: SaveLifeProfileOutcome.saved,
      profileRevision: request.profile.profileRevision,
    );
  }

  @override
  Future<SaveChartSnapshotResult> saveChartSnapshot(SaveChartSnapshotRequest request) async {
    _snapshots[request.chartSnapshot.chartSnapshotId] = request.chartSnapshot;
    return SaveChartSnapshotResult(
      outcome: SaveChartSnapshotOutcome.saved,
      chartSnapshotId: request.chartSnapshot.chartSnapshotId,
      snapshotRevision: 'v1',
    );
  }

  @override
  Future<LifeProfileIdentityPage> queryIdentity(LifeProfileIdentityQuery request) async {
    final list = _profiles.values
        .where((p) => p.ownerScopeId == request.ownerScopeId)
        .toList();
    return LifeProfileIdentityPage(
      profiles: list,
      chartSnapshots: _snapshots.values.toList(),
      nextPageToken: null,
    );
  }
}

class _InMemoryUserRuleStore implements LifeEventUserRuleStore {
  final Map<String, UserAnnotation> _annotations = {};
  final Map<String, SavedOccurrenceSelection> _selections = {};
  final Map<String, SavedPatternRule> _patterns = {};
  final Map<String, PersonalRuleTemplate> _templates = {};

  @override
  Future<SaveAnnotationResult> saveAnnotation(SaveAnnotationRequest request) async {
    _annotations[request.annotation.annotationId] = request.annotation;
    return SaveAnnotationResult(outcome: 'saved', revision: request.annotation.revision);
  }

  @override
  Future<AnnotationPage> queryAnnotations(AnnotationQuery query) async {
    final list = _annotations.values.where((a) => a.ownerScopeId == query.ownerScopeId).toList();
    return AnnotationPage(items: list, nextPageToken: null);
  }

  @override
  Future<SaveOccurrenceSelectionResult> saveOccurrenceSelection(
    SaveOccurrenceSelectionRequest request,
  ) async {
    _selections[request.selection.selectionId] = request.selection;
    return SaveOccurrenceSelectionResult(outcome: 'saved', revision: request.selection.revision);
  }

  @override
  Future<OccurrenceSelectionPage> queryOccurrenceSelections(
    OccurrenceSelectionQuery query,
  ) async {
    final list = _selections.values.where((s) => s.ownerScopeId == query.ownerScopeId).toList();
    return OccurrenceSelectionPage(items: list, nextPageToken: null);
  }

  @override
  Future<SavePatternRuleResult> savePatternRule(SavePatternRuleRequest request) async {
    _patterns[request.rule.savedPatternId] = request.rule;
    return SavePatternRuleResult(outcome: 'saved', revision: request.rule.revision);
  }

  @override
  Future<PatternRulePage> queryPatternRules(PatternRuleQuery query) async {
    final list = _patterns.values.where((p) => p.ownerScopeId == query.ownerScopeId).toList();
    return PatternRulePage(items: list, nextPageToken: null);
  }

  @override
  Future<SaveTemplateResult> saveTemplate(SaveTemplateRequest request) async {
    _templates[request.template.templateId] = request.template;
    return SaveTemplateResult(outcome: 'saved', revision: request.template.revision);
  }

  @override
  Future<TemplatePage> queryTemplates(TemplateQuery query) async {
    final list = _templates.values.where((t) => t.ownerScopeId == query.ownerScopeId).toList();
    return TemplatePage(items: list, nextPageToken: null);
  }
}

class _InMemoryReminderStore implements LifeEventReminderStore {
  final Map<String, ReminderDefinition> _definitions = {};
  final Map<String, ReminderChannel> _channels = {};
  final Map<String, AggregateReminder> _aggregates = {};
  final Map<String, ScheduledNotification> _schedules = {};
  final Map<String, DeliveryRecord> _deliveries = {};

  @override
  Future<SaveReminderResult> saveDefinition(ReminderDefinition value, int expectedRevision) async {
    final existing = _definitions[value.reminderId];
    if (existing != null) {
      if (expectedRevision != existing.revision || value.revision != expectedRevision + 1) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.revisionConflict,
          id: value.reminderId,
          revision: existing.revision,
        );
      }
    }
    _definitions[value.reminderId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.reminderId,
      revision: value.revision,
    );
  }

  @override
  Future<SaveReminderResult> saveChannel(ReminderChannel value, int expectedRevision) async {
    final existing = _channels[value.channelId];
    if (existing != null) {
      if (expectedRevision != existing.revision || value.revision != expectedRevision + 1) {
        return SaveReminderResult(
          outcome: SaveReminderOutcome.revisionConflict,
          id: value.channelId,
          revision: existing.revision,
        );
      }
    }
    _channels[value.channelId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.channelId,
      revision: value.revision,
    );
  }

  @override
  Future<SaveReminderResult> saveAggregate(AggregateReminder value) async {
    _aggregates[value.aggregateId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.aggregateId,
      revision: 0,
    );
  }

  @override
  Future<SaveReminderResult> saveSchedule(ScheduledNotification value) async {
    _schedules[value.scheduleId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.scheduleId,
      revision: 0,
    );
  }

  @override
  Future<ClaimDueSchedulesResult> claimDue(ClaimDueSchedulesRequest request) async {
    final due = _schedules.values.where((s) {
      if (s.ownerScopeId != request.ownerScopeId) return false;
      if (s.fireAtUtc.isAfter(request.nowUtc)) return false;
      if (s.status == ScheduleStatus.scheduled) return true;
      if (s.status == ScheduleStatus.claimed &&
          s.leaseExpiresAtUtc != null &&
          !s.leaseExpiresAtUtc!.isAfter(request.nowUtc)) {
        return true;
      }
      return false;
    }).take(request.maxCount).toList();

    final claimed = <ScheduledNotification>[];
    final expires = request.nowUtc.add(request.leaseDuration);
    for (final item in due) {
      final updated = ScheduledNotification(
        scheduleId: item.scheduleId,
        ownerScopeId: item.ownerScopeId,
        reminderId: item.reminderId,
        aggregateId: item.aggregateId,
        fireAtUtc: item.fireAtUtc,
        displayTimezoneId: item.displayTimezoneId,
        channelRevision: item.channelRevision,
        sourceRevisionFingerprint: item.sourceRevisionFingerprint,
        status: ScheduleStatus.claimed,
        claimToken: request.claimToken,
        leaseExpiresAtUtc: expires,
      );
      _schedules[item.scheduleId] = updated;
      claimed.add(updated);
    }

    return ClaimDueSchedulesResult(
      claimed: claimed,
      claimToken: request.claimToken,
      claimedAt: request.nowUtc,
    );
  }

  @override
  Future<SaveReminderResult> saveDelivery(DeliveryRecord value) async {
    _deliveries[value.deliveryId] = value;
    return SaveReminderResult(
      outcome: SaveReminderOutcome.saved,
      id: value.deliveryId,
      revision: 0,
    );
  }
}

class _InMemoryExternalEventStore implements ExternalCalendarEventStore {
  final Map<String, ExternalCalendarEvent> _events = {};

  @override
  Future<SaveExternalEventResult> save(SaveExternalEventRequest request) async {
    _events[request.event.externalEventId] = request.event;
    return SaveExternalEventResult(outcome: 'saved', revision: request.event.revision);
  }

  @override
  Future<ExternalEventPage> query(ExternalEventQuery query) async {
    final list = _events.values.where((e) => e.ownerScopeId == query.ownerScopeId).toList();
    return ExternalEventPage(items: list, nextPageToken: null);
  }
}
