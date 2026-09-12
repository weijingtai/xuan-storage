// ACT-12A: 01A 返工（LEC-012 时间形状校验与 ReminderChannel 形状测试）
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:test/test.dart';

void main() {
  group('[LEC-012] TimeRange validation', () {
    test('valid UTC half-open range returns null', () {
      final range = TimeRange(
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 0, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 2, 0, 0),
      );
      expect(range.validate(), isNull);
    });

    test('non-UTC start or end returns nonUtcTime', () {
      final nonUtcStart = TimeRange(
        startInclusiveUtc: DateTime(2026, 1, 1, 0, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 2, 0, 0),
      );
      expect(nonUtcStart.validate(), equals('nonUtcTime'));

      final nonUtcEnd = TimeRange(
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 0, 0),
        endExclusiveUtc: DateTime(2026, 1, 2, 0, 0),
      );
      expect(nonUtcEnd.validate(), equals('nonUtcTime'));
    });

    test('empty or inverted range returns emptyOrInvertedRange', () {
      final empty = TimeRange(
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 12, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 1, 12, 0),
      );
      expect(empty.validate(), equals('emptyOrInvertedRange'));

      final inverted = TimeRange(
        startInclusiveUtc: DateTime.utc(2026, 1, 2, 0, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 1, 0, 0),
      );
      expect(inverted.validate(), equals('emptyOrInvertedRange'));
    });
  });

  group('[LEC-012] IntervalTime validation', () {
    test('valid interval returns null', () {
      final interval = IntervalTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1, 8, 0),
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 8, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 1, 12, 0),
        calculationTimezoneId: 'Asia/Shanghai',
        precision: TimePrecision.hour,
      );
      expect(interval.validate(), isNull);
    });

    test('non-UTC timestamp returns nonUtcTime', () {
      final interval = IntervalTime(
        effectiveStartUtc: DateTime(2026, 1, 1, 8, 0),
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 8, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 1, 12, 0),
        calculationTimezoneId: 'Asia/Shanghai',
        precision: TimePrecision.hour,
      );
      expect(interval.validate(), equals('nonUtcTime'));
    });

    test('empty or inverted interval returns emptyOrInvertedRange', () {
      final interval = IntervalTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1, 8, 0),
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 12, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 1, 8, 0),
        calculationTimezoneId: 'Asia/Shanghai',
        precision: TimePrecision.hour,
      );
      expect(interval.validate(), equals('emptyOrInvertedRange'));
    });

    test('coarse precision returns precisionShapeMismatch', () {
      final interval = IntervalTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1, 8, 0),
        startInclusiveUtc: DateTime.utc(2026, 1, 1, 8, 0),
        endExclusiveUtc: DateTime.utc(2026, 1, 1, 12, 0),
        calculationTimezoneId: 'Asia/Shanghai',
        precision: TimePrecision.day,
      );
      expect(interval.validate(), equals('precisionShapeMismatch'));
    });
  });

  group('[LEC-012] CivilSpanTime validation', () {
    test('valid civil span returns null', () {
      final span = CivilSpanTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1, 0, 0),
        startCivilInclusive: DateTime(2026, 1, 1),
        endCivilExclusive: DateTime(2026, 1, 2),
        calendarSystem: 'chineseLunar',
        timezoneId: 'Asia/Shanghai',
        precision: TimePrecision.day,
      );
      expect(span.validate(), isNull);
    });

    test('non-UTC effectiveStart returns nonUtcTime', () {
      final span = CivilSpanTime(
        effectiveStartUtc: DateTime(2026, 1, 1, 0, 0),
        startCivilInclusive: DateTime(2026, 1, 1),
        endCivilExclusive: DateTime(2026, 1, 2),
        calendarSystem: 'chineseLunar',
        timezoneId: 'Asia/Shanghai',
        precision: TimePrecision.day,
      );
      expect(span.validate(), equals('nonUtcTime'));
    });

    test('empty or inverted civil boundaries return emptyOrInvertedRange', () {
      final span = CivilSpanTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1, 0, 0),
        startCivilInclusive: DateTime(2026, 1, 2),
        endCivilExclusive: DateTime(2026, 1, 1),
        calendarSystem: 'chineseLunar',
        timezoneId: 'Asia/Shanghai',
        precision: TimePrecision.day,
      );
      expect(span.validate(), equals('emptyOrInvertedRange'));
    });

    test('sub-day precision returns precisionShapeMismatch', () {
      final span = CivilSpanTime(
        effectiveStartUtc: DateTime.utc(2026, 1, 1, 0, 0),
        startCivilInclusive: DateTime(2026, 1, 1),
        endCivilExclusive: DateTime(2026, 1, 2),
        calendarSystem: 'chineseLunar',
        timezoneId: 'Asia/Shanghai',
        precision: TimePrecision.minute,
      );
      expect(span.validate(), equals('precisionShapeMismatch'));
    });
  });

  group('ReminderChannel shape roundtrip', () {
    test('selectors 8 categories and deliveryPolicy all fields construct and read back', () {
      final channel = ReminderChannel(
        channelId: 'ch-test-1',
        ownerScopeId: 'owner-scope-1',
        name: 'VIP Channel',
        enabled: true,
        selectors: const ReminderChannelSelectors(
          subjectIds: ['subj-1', 'subj-2'],
          profileIds: ['prof-1'],
          divinationSelectors: [
            ReminderDivinationSelector(
              providerId: 'prov-1',
              divinationTypeKey: 'bazi',
              subDivinationTypeKey: 'sub-bazi',
            ),
          ],
          eventTypeIds: ['event-type-1'],
          directionIds: ['dir-1', 'dir-2'],
          sourceSeverityRefs: [
            SourceSeverityRef(
              providerId: 'prov-1',
              schemeId: 'scheme-1',
              schemeVersion: 'v1',
              code: 'sev-code',
            ),
          ],
          userImportanceRefs: [
            UserImportanceRef(
              ownerScopeId: 'owner-scope-1',
              catalogId: 'cat-1',
              catalogRevision: 1,
              levelId: 'high',
            ),
          ],
          notificationPriorityRefs: [
            NotificationPriorityRef(
              ownerScopeId: 'owner-scope-1',
              catalogId: 'prio-cat-1',
              catalogRevision: 2,
              priorityId: 'urgent',
            ),
          ],
        ),
        deliveryPolicy: const ReminderDeliveryPolicy(
          leadTimes: [Duration(minutes: 15), Duration(hours: 1)],
          quietHours: '23:00-07:00',
          mergeWindow: Duration(hours: 2),
          deliveryMode: DeliveryMode.immediate,
          groupingMode: GroupingMode.each,
        ),
        revision: 1,
      );

      expect(channel.channelId, equals('ch-test-1'));
      expect(channel.ownerScopeId, equals('owner-scope-1'));
      expect(channel.name, equals('VIP Channel'));
      expect(channel.enabled, isTrue);
      expect(channel.revision, equals(1));

      final sel = channel.selectors;
      expect(sel.subjectIds, equals(['subj-1', 'subj-2']));
      expect(sel.profileIds, equals(['prof-1']));
      expect(sel.divinationSelectors.single.providerId, equals('prov-1'));
      expect(sel.divinationSelectors.single.divinationTypeKey, equals('bazi'));
      expect(sel.divinationSelectors.single.subDivinationTypeKey, equals('sub-bazi'));
      expect(sel.eventTypeIds, equals(['event-type-1']));
      expect(sel.directionIds, equals(['dir-1', 'dir-2']));
      expect(sel.sourceSeverityRefs.single.code, equals('sev-code'));
      expect(sel.userImportanceRefs.single.levelId, equals('high'));
      expect(sel.notificationPriorityRefs.single.priorityId, equals('urgent'));

      final pol = channel.deliveryPolicy;
      expect(pol.leadTimes, equals([const Duration(minutes: 15), const Duration(hours: 1)]));
      expect(pol.quietHours, equals('23:00-07:00'));
      expect(pol.mergeWindow, equals(const Duration(hours: 2)));
      expect(pol.deliveryMode, equals(DeliveryMode.immediate));
      expect(pol.groupingMode, equals(GroupingMode.each));
    });
  });
}
