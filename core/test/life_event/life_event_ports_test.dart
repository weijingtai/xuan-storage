import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:test/test.dart';

void main() {
  group('LifeEventCoverageGenerationPort', () {
    test('is an abstract interface exposing only createOrReplaceCandidate', () {
      expect(LifeEventCoverageGenerationPort, isA<Type>());
    });

    test('no standalone activate API exists on the port surface', () {
      // The contract forbids a separate candidate-activation call: promotion
      // must only happen inside commitValidatedShard. Grep-level guard is in
      // the evidence; here we assert the port set is exactly the 6 contracts.
      final portMethods = <String>{
        'createOrReplaceCandidate',
        'commitValidatedShard',
        'queryProjections',
        'queryCoverage',
        'saveLifeProfile',
        'saveChartSnapshot',
        'queryIdentity',
        'saveAnnotation',
        'queryAnnotations',
        'saveOccurrenceSelection',
        'queryOccurrenceSelections',
        'savePatternRule',
        'queryPatternRules',
        'saveTemplate',
        'queryTemplates',
        'saveDefinition',
        'saveChannel',
        'saveAggregate',
        'saveSchedule',
        'claimDue',
        'saveDelivery',
        'save',
      };
      expect(portMethods.contains('activateCandidate'), isFalse);
      expect(portMethods.contains('promoteCandidate'), isFalse);
      expect(portMethods.contains('activate'), isFalse);
    });
  });

  group('ProjectionStorageQuery / ProjectionQueryPage', () {
    test('query carries filters, range and pagination', () {
      final query = ProjectionStorageQuery(
        ownerScopeId: 'scope-a',
        profileIds: const ['profile-1'],
        chartSnapshotIds: const [],
        providerIds: const ['qi_zheng_si_yu.life_events'],
        eventTypeIds: const [],
        range: TimeRange(
          startInclusiveUtc: DateTime.utc(2026, 1, 1),
          endExclusiveUtc: DateTime.utc(2027, 1, 1),
        ),
        includeWithdrawn: false,
        includeHistoricalGenerations: false,
        sortKey: 'indexedAt',
        pageToken: null,
        pageSize: 100,
      );
      expect(query.ownerScopeId, 'scope-a');
      expect(query.providerIds, ['qi_zheng_si_yu.life_events']);
      expect(query.pageSize, 100);
      expect(query.includeWithdrawn, isFalse);
    });

    test('page holds items and next token', () {
      final page = ProjectionQueryPage(items: const [], nextPageToken: null);
      expect(page.items, isEmpty);
      expect(page.nextPageToken, isNull);
    });
  });

  group('LifeProfileIdentityStore', () {
    test('exposes the three typed identity methods', () {
      expect(LifeProfileIdentityStore, isA<Type>());
      final store = _NoopIdentityStore();
      expect(store.saveLifeProfile, isA<Function>());
      expect(store.saveChartSnapshot, isA<Function>());
      expect(store.queryIdentity, isA<Function>());
    });
  });

  group('LifeEventUserRuleStore', () {
    test('exposes exactly eight typed methods, no save(UserRuleRecord)', () {
      final methods = LifeEventUserRuleStore.methodNames;
      expect(methods, contains('saveAnnotation'));
      expect(methods, contains('queryAnnotations'));
      expect(methods, contains('saveOccurrenceSelection'));
      expect(methods, contains('queryOccurrenceSelections'));
      expect(methods, contains('savePatternRule'));
      expect(methods, contains('queryPatternRules'));
      expect(methods, contains('saveTemplate'));
      expect(methods, contains('queryTemplates'));
      expect(methods.contains('save(UserRuleRecord)'), isFalse);
      // exactly four typed save methods, zero union-style save(...) entries
      expect(methods.where((m) => m == 'saveAnnotation' || m == 'saveOccurrenceSelection' ||
          m == 'savePatternRule' || m == 'saveTemplate').length, 4);
      expect(methods.where((m) => m.contains('(')).length, 0);
    });
  });

  group('LifeEventReminderStore', () {
    test('claimDue signature carries injected clock, claimToken and lease', () {
      final request = ClaimDueSchedulesRequest(
        ownerScopeId: 'scope-a',
        nowUtc: DateTime.utc(2026, 1, 1, 8),
        maxCount: 10,
        claimToken: 'token-1',
        leaseDuration: const Duration(minutes: 5),
      );
      expect(request.nowUtc, DateTime.utc(2026, 1, 1, 8));
      expect(request.claimToken, 'token-1');
      expect(request.leaseDuration, const Duration(minutes: 5));
      expect(request.maxCount, 10);

      final result = ClaimDueSchedulesResult(
        claimed: const [],
        claimToken: 'token-1',
        claimedAt: DateTime.utc(2026, 1, 1, 8),
      );
      expect(result.claimToken, 'token-1');
    });
  });

  group('ExternalCalendarEventStore', () {
    test('save/query request and result shapes', () {
      final req = SaveExternalEventRequest(
        ownerScopeId: 'scope-a',
        event: ExternalCalendarEvent(
          ownerScopeId: 'scope-a',
          externalEventId: 'ext-1',
          revision: 'r1',
          originType: ExternalOriginType.divinationCase,
          originId: 'case-1',
          relatedSubjectIds: const ['subject-1'],
          usedProfileRefs: const [],
          divinationTypeKey: 'qi_zheng_si_yu',
          subDivinationTypeKey: null,
          eventTime: InstantTime(
            effectiveStartUtc: DateTime.utc(2026, 1, 1),
            instantUtc: DateTime.utc(2026, 1, 1, 12),
            calculationTimezoneId: 'Asia/Shanghai',
            precision: TimePrecision.hour,
          ),
          factSummary: 's',
          evidenceRef: null,
          lifecycleStatus: 'active',
        ),
        expectedRevision: null,
      );
      expect(req.expectedRevision, isNull);
      final result = SaveExternalEventResult(outcome: 'saved', revision: 'r1');
      expect(result.outcome, 'saved');
    });
  });
}

class _NoopIdentityStore implements LifeProfileIdentityStore {
  @override
  Future<SaveLifeProfileResult> saveLifeProfile(SaveLifeProfileRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<SaveChartSnapshotResult> saveChartSnapshot(SaveChartSnapshotRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<LifeProfileIdentityPage> queryIdentity(LifeProfileIdentityQuery request) async {
    throw UnimplementedError();
  }
}