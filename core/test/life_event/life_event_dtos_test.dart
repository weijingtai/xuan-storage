import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:test/test.dart';

void main() {
  group('LifeProfileRecord', () {
    test('constructs with all fields and round-trips equality', () {
      final profile = LifeProfileRecord(
        profileId: 'profile-1',
        ownerScopeId: 'scope-a',
        subjectId: 'subject-1',
        displayLabel: '主档案',
        birthInput: BirthInput(
          civilDateTime: DateTime.utc(1990, 5, 12, 8, 30),
          precision: BirthPrecision.minute,
          isTimeKnown: true,
          calendarSystem: BirthCalendarSystem.gregorian,
        ),
        placeRef: 'Shanghai',
        coordinates: GeoCoordinates(
          latitudeDeg: 31.2304,
          longitudeDeg: 121.4737,
          altitudeMeters: null,
          geodeticDatum: 'WGS84',
        ),
        timezoneId: 'Asia/Shanghai',
        timeConversionPolicyId: 'true-solar-v1',
        dayBoundaryPolicyId: 'zi-chu-v1',
        rectificationPolicyId: null,
        profileRevision: 1,
        isDefault: true,
        lifecycleStatus: 'active',
      );
      expect(profile.profileId, 'profile-1');
      expect(profile.birthInput.precision, BirthPrecision.minute);
      expect(profile.coordinates!.latitudeDeg, 31.2304);
      expect(profile.timezoneId, 'Asia/Shanghai');
      expect(profile.dayBoundaryPolicyId, 'zi-chu-v1');
    });

    test('profileRevision is carried distinctly', () {
      final base = LifeProfileRecord(
        profileId: 'profile-1',
        ownerScopeId: 'scope-a',
        subjectId: 'subject-1',
        displayLabel: '主档案',
        birthInput: BirthInput(
          civilDateTime: DateTime.utc(1990, 5, 12, 8, 30),
          precision: BirthPrecision.minute,
          isTimeKnown: true,
          calendarSystem: BirthCalendarSystem.gregorian,
        ),
        placeRef: null,
        coordinates: null,
        timezoneId: 'Asia/Shanghai',
        timeConversionPolicyId: 'true-solar-v1',
        dayBoundaryPolicyId: 'zi-chu-v1',
        rectificationPolicyId: null,
        profileRevision: 1,
        isDefault: true,
        lifecycleStatus: 'active',
      );
      expect(base.profileRevision, 1);
      final bumped = LifeProfileRecord(
        profileId: 'profile-1',
        ownerScopeId: 'scope-a',
        subjectId: 'subject-1',
        displayLabel: '主档案',
        birthInput: base.birthInput,
        placeRef: null,
        coordinates: null,
        timezoneId: 'Asia/Shanghai',
        timeConversionPolicyId: 'true-solar-v1',
        dayBoundaryPolicyId: 'zi-chu-v1',
        rectificationPolicyId: null,
        profileRevision: 2,
        isDefault: true,
        lifecycleStatus: 'active',
      );
      expect(bumped.profileRevision, 2);
    });
  });

  group('SaveLifeProfileResult / SaveChartSnapshotResult', () {
    test('outcomes are distinguishable', () {
      expect(SaveLifeProfileOutcome.saved, isNot(equals(SaveLifeProfileOutcome.revisionConflict)));
      final r = SaveLifeProfileResult(
        outcome: SaveLifeProfileOutcome.saved,
        profileRevision: 3,
      );
      expect(r.outcome, SaveLifeProfileOutcome.saved);
      expect(r.profileRevision, 3);

      final c = SaveChartSnapshotResult(
        outcome: SaveChartSnapshotOutcome.staleProfileRevision,
        chartSnapshotId: 'snap-1',
        snapshotRevision: 'r2',
      );
      expect(c.outcome, SaveChartSnapshotOutcome.staleProfileRevision);
      expect(c.chartSnapshotId, 'snap-1');
    });
  });

  group('ChartSnapshotRef', () {
    test('carries providerId and divinationTypeKey', () {
      final ref = ChartSnapshotRef(
        chartSnapshotId: 'snap-1',
        profileId: 'profile-1',
        providerId: 'qi_zheng_si_yu.life_events',
        divinationTypeKey: 'qi_zheng_si_yu',
        subDivinationTypeKey: null,
        snapshotRevision: 'v1',
        algorithmVersion: 'algo-1',
        inputFingerprint: 'fp-1',
        createdAt: DateTime.utc(2026, 9, 9),
      );
      expect(ref.providerId, 'qi_zheng_si_yu.life_events');
      expect(ref.divinationTypeKey, 'qi_zheng_si_yu');
      expect(ref.subDivinationTypeKey, isNull);
    });
  });

  group('LifeEventTime hierarchy', () {
    test('three tagged time shapes are distinct', () {
      final instant = InstantTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1),
        instantUtc: DateTime.utc(2026, 1, 1, 12),
        calculationTimezoneId: 'Asia/Shanghai',
        precision: TimePrecision.hour,
      );
      final interval = IntervalTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1),
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 8),
        endExclusiveUtc: DateTime.utc(2026, 1, 1, 12),
        calculationTimezoneId: 'Asia/Shanghai',
        precision: TimePrecision.hour,
      );
      expect(instant, isA<LifeEventTime>());
      expect(interval, isA<LifeEventTime>());
      expect(instant, isNot(equals(interval)));
      expect(interval.endExclusiveUtc.isAfter(interval.startInclusiveUtc), isTrue);
    });

    test('CivilSpanTime keeps civil boundaries and calendar system', () {
      final span = CivilSpanTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1),
        startCivilInclusive: DateTime(2026, 1, 1),
        endCivilExclusive: DateTime(2026, 1, 2),
        calendarSystem: 'chineseLunar',
        timezoneId: 'Asia/Shanghai',
        precision: TimePrecision.day,
      );
      expect(span.calendarSystem, 'chineseLunar');
      expect(span.timezoneId, 'Asia/Shanghai');
      expect(span.endCivilExclusive.isAfter(span.startCivilInclusive), isTrue);
    });
  });

  group('TypedScalar hierarchy', () {
    test('all scalar kinds construct and equal', () {
      final text = TextScalar(fieldId: 'f', schemaVersion: 'v1', value: 'x');
      final num = NumberScalar(fieldId: 'f', schemaVersion: 'v1', value: 3.5);
      final bool = BooleanScalar(fieldId: 'f', schemaVersion: 'v1', value: true);
      final en = EnumScalar(fieldId: 'f', schemaVersion: 'v1', code: 'c', catalogVersion: 'cv');
      final multi = MultiEnumScalar(fieldId: 'f', schemaVersion: 'v1', codes: ['a', 'b'], catalogVersion: 'cv');
      expect(text, isA<TypedScalar>());
      expect(num, isA<TypedScalar>());
      expect(bool, isA<TypedScalar>());
      expect(en, isA<TypedScalar>());
      expect(multi, isA<TypedScalar>());
      expect(multi.codes, ['a', 'b']);
    });

    test('UnknownScalar round-trips rawEncoded', () {
      final raw = 'raw:encoded:payload';
      final unknown = UnknownScalar(fieldId: 'f', schemaVersion: 'v1', rawEncoded: raw);
      expect(unknown.rawEncoded, raw);
      expect(unknown.fieldId, 'f');
      final copy = UnknownScalar(fieldId: 'f', schemaVersion: 'v1', rawEncoded: raw);
      expect(copy.rawEncoded, raw);
      expect(copy.fieldId, 'f');
      expect(copy.schemaVersion, 'v1');
    });

    test('sealed hierarchy permits exhaustive switching', () {
      TypedScalar scalar = TextScalar(fieldId: 'f', schemaVersion: 'v1', value: 'x');
      final kind = switch (scalar) {
        TextScalar() => 'text',
        NumberScalar() => 'number',
        BooleanScalar() => 'boolean',
        EnumScalar() => 'enum',
        MultiEnumScalar() => 'multi',
        UnknownScalar() => 'unknown',
      };
      expect(kind, 'text');
    });
  });

  group('EventProjection', () {
    test('carries coverageGeneration and typed evidence refs', () {
      final projection = EventProjection(
        projectionId: 'proj-1',
        projectionIdAlgorithmVersion: 'v1',
        coverageId: 'cov-1',
        coverageGeneration: 3,
        sourceRef: SourceRef(
          providerId: 'qi_zheng_si_yu.life_events',
          sourceEventId: 'evt-1',
          eventRevision: 'r1',
        ),
        ownerScopeId: 'scope-a',
        subjectId: 'subject-1',
        profileId: 'profile-1',
        chartSnapshotId: 'snap-1',
        divinationTypeKey: 'qi_zheng_si_yu',
        subDivinationTypeKey: null,
        eventTypeId: 'year_cycle',
        eventTime: InstantTime(
          effectiveStartUtc: DateTime.utc(2026, 1, 1),
          instantUtc: DateTime.utc(2026, 1, 1, 12),
          calculationTimezoneId: 'Asia/Shanghai',
          precision: TimePrecision.hour,
        ),
        projectedParticipants: const [],
        projectedFactValues: const [],
        factSummary: 'summary',
        evidenceRef: 'evidence-1',
        astronomyEventRef: AstronomyEventRef(
          astronomyProviderId: 'sweph',
          datasetProfileId: 'ds-1',
          bodyId: 'sun',
          astronomyEventId: 'ae-1',
          dataVersion: 'dv-1',
        ),
        astronomyEvidenceRef: null,
        profileMatchEvidenceRef: ProfileMatchEvidenceRef(
          providerId: 'qi_zheng_si_yu',
          evidenceId: 'ev-2',
          evidenceRevision: 'r1',
          evidenceSchemaId: 'schema-1',
          schemaVersion: 'v1',
        ),
        sourceSeverityRef: null,
        sourceVersions: SourceVersions(
          providerVersion: '1.0.0',
          algorithmVersion: 'algo-1',
          ruleVersion: null,
          dataVersion: null,
        ),
        projectionLifecycleStatus: ProjectionLifecycleStatus.active,
        indexedAt: DateTime.utc(2026, 9, 9),
      );
      expect(projection.coverageGeneration, 3);
      expect(projection.astronomyEventRef!.bodyId, 'sun');
      expect(projection.profileMatchEvidenceRef!.evidenceId, 'ev-2');
      expect(projection.sourceVersions.providerVersion, '1.0.0');
    });
  });

  group('CoverageManifest / ShardReceipt / Commit', () {
    test('manifest fields express status and counts', () {
      final manifest = CoverageManifest(
        coverageId: 'cov-1',
        coverageSeriesId: 'series-1',
        coverageGeneration: 2,
        manifestRevision: 5,
        servingState: ServingState.active,
        profileId: 'profile-1',
        chartSnapshotId: 'snap-1',
        chartSnapshotRevision: 'r1',
        providerId: 'qi_zheng_si_yu.life_events',
        providerVersion: '1.0.0',
        algorithmVersion: 'algo-1',
        dataVersion: null,
        eventTypeId: 'year_cycle',
        eventTypeSchemaVersion: 'v1',
        capabilityDescriptorVersion: 'v1',
        capabilityDigest: 'cap-digest',
        requestedRange: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        coveredRanges: [
          TimeRange(
            startInclusiveUtc: DateTime.utc(2026, 1, 1),
            endExclusiveUtc: DateTime.utc(2027, 1, 1),
          ),
        ],
        status: CoverageStatus.complete,
        inputFingerprint: 'fp-1',
        expectedShardCount: 3,
        completedShardCount: 3,
        sourceEventCount: 42,
        outputDigest: 'out-digest',
        startedAt: DateTime.utc(2026, 9, 1),
        completedAt: DateTime.utc(2026, 9, 2),
        lastErrorCode: null,
      );
      expect(manifest.status, CoverageStatus.complete);
      expect(manifest.servingState, ServingState.active);
      expect(manifest.completedShardCount, manifest.expectedShardCount);
    });

    test('shard receipt carries digest and idempotency fields', () {
      final receipt = ShardReceipt(
        coverageId: 'cov-1',
        shardId: 'shard-1',
        coverageGeneration: 2,
        requestedRange: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2026, 7, 1),
        ),
        coveredRange: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2026, 7, 1),
        ),
        eventCount: 20,
        contentDigest: 'content-1',
        persistedCount: 20,
        persistedDigest: 'persisted-1',
        isCompleteForCoveredRange: true,
        inputFingerprint: 'fp-1',
        committedAt: DateTime.utc(2026, 9, 2),
      );
      expect(receipt.receiptIdentity, isA<ReceiptIdentity>());
      expect(receipt.contentDigest, 'content-1');
      expect(receipt.isCompleteForCoveredRange, isTrue);
    });

    test('commit result covers conflicts and active switch', () {
      final ok = CommitValidatedShardResult(
        outcome: CommitValidatedShardOutcome.applied,
        manifestRevision: 6,
        coverageGeneration: 2,
        seriesRevision: 3,
        activeCoverageId: 'cov-1',
        receiptIdentity: ReceiptIdentity(coverageId: 'cov-1', shardId: 'shard-1'),
        persistedCount: 20,
        persistedDigest: 'persisted-1',
        coverageStatus: CoverageStatus.complete,
        servingState: ServingState.active,
        completedShardCount: 3,
        expectedShardCount: 3,
      );
      final conflict = CommitValidatedShardResult(
        outcome: CommitValidatedShardOutcome.receiptDigestConflict,
        manifestRevision: 6,
        coverageGeneration: 2,
        seriesRevision: 3,
        activeCoverageId: null,
        receiptIdentity: ReceiptIdentity(coverageId: 'cov-1', shardId: 'shard-1'),
        persistedCount: 0,
        persistedDigest: '',
        coverageStatus: CoverageStatus.partial,
        servingState: ServingState.candidate,
        completedShardCount: 1,
        expectedShardCount: 3,
      );
      expect(ok.outcome, CommitValidatedShardOutcome.applied);
      expect(conflict.outcome, CommitValidatedShardOutcome.receiptDigestConflict);
    });
  });

  group('Reminder / Channel / Aggregate', () {
    test('reminder definition round-trips selectors', () {
      final definition = ReminderDefinition(
        reminderId: 'rem-1',
        ownerScopeId: 'scope-a',
        selectionRef: OccurrenceSelectionRef(selectionId: 'sel-1', revision: 2),
        notificationTitleOverride: null,
        notificationBodyOverride: null,
        notificationPriorityRef: NotificationPriorityRef(
          ownerScopeId: 'scope-a',
          catalogId: 'cat-1',
          catalogRevision: 1,
          priorityId: 'high',
        ),
        channelIds: const ['push'],
        leadTimes: const [Duration(hours: 1)],
        repeatPolicy: null,
        mergePolicy: 'latest',
        enabled: true,
        revision: 1,
      );
      expect(definition.selectionRef, isA<OccurrenceSelectionRef>());
      expect(definition.channelIds, ['push']);
      expect(definition.leadTimes.single, Duration(hours: 1));
    });

    test('aggregate reminder keeps contributors unflattened', () {
      final aggregate = AggregateReminder(
        aggregateId: 'agg-1',
        ownerScopeId: 'scope-a',
        subjectId: 'subject-1',
        displayTimeWindow: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2026, 1, 2),
        ),
        directionIds: const ['d1'],
        effectiveNotificationPriorityRef: NotificationPriorityRef(
          ownerScopeId: 'scope-a',
          catalogId: 'cat-1',
          catalogRevision: 1,
          priorityId: 'high',
        ),
        displayTitle: 'title',
        userInterpretation: null,
        contributors: [
          AggregateReminderContributor(
            providerId: 'qi_zheng_si_yu.life_events',
            divinationTypeKey: 'qi_zheng_si_yu',
            subDivinationTypeKey: null,
            profileId: 'profile-1',
            chartSnapshotId: 'snap-1',
            sourceEventId: 'evt-1',
            eventRevision: 'r1',
            eventTypeId: 'year_cycle',
            factSummary: 's',
            evidenceRef: 'ev-ref',
            sourceSeverityRef: null,
            sourceVersions: SourceVersions(
              providerVersion: '1.0.0',
              algorithmVersion: 'algo-1',
              ruleVersion: null,
              dataVersion: null,
            ),
            annotationRef: null,
            directionIds: const ['d1'],
            userImportanceRef: null,
            reminderId: 'rem-1',
          ),
        ],
      );
      expect(aggregate.contributors.single.reminderId, 'rem-1');
      expect(aggregate.contributors.single.directionIds, ['d1']);
    });
  });

  group('ScheduledNotification target XOR', () {
    ScheduledNotification base({
      String? reminderId,
      String? aggregateId,
    }) =>
        ScheduledNotification(
          scheduleId: 'schedule-1',
          ownerScopeId: 'scope-a',
          reminderId: reminderId,
          aggregateId: aggregateId,
          fireAtUtc: DateTime.utc(2026, 1, 1, 8),
          displayTimezoneId: 'Asia/Shanghai',
          channelRevision: 1,
          sourceRevisionFingerprint: 'fp-1',
          status: ScheduleStatus.scheduled,
          claimToken: null,
          leaseExpiresAtUtc: null,
        );

    test('both null rejects with invalidScheduleTarget', () {
      expect(
        base(reminderId: null, aggregateId: null).validateTarget(),
        SaveReminderOutcome.invalidScheduleTarget,
      );
    });

    test('both set rejects with invalidScheduleTarget', () {
      expect(
        base(reminderId: 'rem-1', aggregateId: 'agg-1').validateTarget(),
        SaveReminderOutcome.invalidScheduleTarget,
      );
    });

    test('exactly one non-null is accepted', () {
      expect(
        base(reminderId: 'rem-1', aggregateId: null).validateTarget(),
        isNull,
      );
      expect(
        base(reminderId: null, aggregateId: 'agg-1').validateTarget(),
        isNull,
      );
    });
  });

  group('ExternalCalendarEvent', () {
    test('constructs with origin and event time', () {
      final event = ExternalCalendarEvent(
        ownerScopeId: 'scope-a',
        externalEventId: 'ext-1',
        revision: 'r1',
        originType: ExternalOriginType.divinationCase,
        originId: 'case-1',
        relatedSubjectIds: const ['subject-1'],
        usedProfileRefs: const ['profile-1'],
        divinationTypeKey: 'qi_zheng_si_yu',
        subDivinationTypeKey: null,
        eventTime: InstantTime(
          effectiveStartUtc: DateTime.utc(2026, 1, 1),
          instantUtc: DateTime.utc(2026, 1, 1, 12),
          calculationTimezoneId: 'Asia/Shanghai',
          precision: TimePrecision.hour,
        ),
        factSummary: 'summary',
        evidenceRef: null,
        lifecycleStatus: 'active',
      );
      expect(event.originType, ExternalOriginType.divinationCase);
      expect(event.relatedSubjectIds, ['subject-1']);
    });
  });
}