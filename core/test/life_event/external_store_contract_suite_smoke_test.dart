// ACT-15: ExternalCalendarEventStore 合同套件 Smoke Test
import 'dart:convert';

import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:persistence_core/test_support/external_calendar_event_store_contract_suite.dart';

final class _InMemoryExternalCalendarEventStore implements ExternalCalendarEventStore {
  final List<ExternalCalendarEvent> _events = [];

  @override
  Future<SaveExternalEventResult> save(SaveExternalEventRequest request) async {
    if (request.ownerScopeId != request.event.ownerScopeId) {
      return SaveExternalEventResult(
        outcome: 'ownerScopeMismatch',
        revision: request.event.revision,
      );
    }

    ExternalCalendarEvent? latest;
    for (final r in _events) {
      if (r.ownerScopeId == request.ownerScopeId &&
          r.externalEventId == request.event.externalEventId) {
        latest = r;
      }
    }

    if (request.expectedRevision == null) {
      if (latest != null) {
        return SaveExternalEventResult(
          outcome: 'revisionConflict',
          revision: latest.revision,
        );
      }
    } else {
      if (latest == null ||
          latest.revision != request.expectedRevision ||
          request.event.revision == latest.revision) {
        return SaveExternalEventResult(
          outcome: 'revisionConflict',
          revision: latest?.revision ?? '',
        );
      }
    }

    _events.add(request.event);
    return SaveExternalEventResult(
      outcome: 'saved',
      revision: request.event.revision,
    );
  }

  @override
  Future<ExternalEventPage> query(ExternalEventQuery query) async {
    final latestMap = <String, ExternalCalendarEvent>{};
    for (final r in _events) {
      if (r.ownerScopeId == query.ownerScopeId) {
        latestMap[r.externalEventId] = r;
      }
    }
    var list = latestMap.values.toList();

    if (query.relatedSubjectIds.isNotEmpty) {
      list = list
          .where((e) => e.relatedSubjectIds.any(query.relatedSubjectIds.contains))
          .toList();
    }

    if (query.originTypes.isNotEmpty) {
      list = list.where((e) => query.originTypes.contains(e.originType)).toList();
    }

    if (query.timeRange != null) {
      final rangeStart = query.timeRange!.startInclusiveUtc.millisecondsSinceEpoch;
      final rangeEnd = query.timeRange!.endExclusiveUtc.millisecondsSinceEpoch;
      list = list.where((e) {
        final startMs = e.eventTime.effectiveStartUtc.millisecondsSinceEpoch;
        final int? endMs = switch (e.eventTime) {
          IntervalTime t => t.endExclusiveUtc.millisecondsSinceEpoch,
          CivilSpanTime t => t.endCivilExclusive.millisecondsSinceEpoch,
          _ => null,
        };
        return (startMs < rangeEnd) &&
            ((endMs == null && startMs >= rangeStart) ||
                (endMs != null && endMs > rangeStart));
      }).toList();
    }

    list.sort((a, b) {
      final cmp = a.eventTime.effectiveStartUtc.compareTo(b.eventTime.effectiveStartUtc);
      if (cmp != 0) return cmp;
      return a.externalEventId.compareTo(b.externalEventId);
    });

    if (query.pageToken != null && query.pageToken!.isNotEmpty) {
      final decoded = utf8.decode(base64Url.decode(query.pageToken!));
      final idx = decoded.indexOf(':');
      final tokenMs = int.parse(decoded.substring(0, idx));
      final tokenId = decoded.substring(idx + 1);
      list = list.where((e) {
        final startMs = e.eventTime.effectiveStartUtc.millisecondsSinceEpoch;
        if (startMs > tokenMs) return true;
        if (startMs == tokenMs && e.externalEventId.compareTo(tokenId) > 0) return true;
        return false;
      }).toList();
    }

    final hasMore = list.length > query.pageSize;
    final pageItems = hasMore ? list.sublist(0, query.pageSize) : list;
    String? nextToken;
    if (hasMore && pageItems.isNotEmpty) {
      final last = pageItems.last;
      final lastMs = last.eventTime.effectiveStartUtc.millisecondsSinceEpoch;
      nextToken = base64Url.encode(utf8.encode('$lastMs:${last.externalEventId}'));
    }

    return ExternalEventPage(items: pageItems, nextPageToken: nextToken);
  }
}

void main() {
  runExternalCalendarEventStoreContractSuite(
    makeStore: () => _InMemoryExternalCalendarEventStore(),
  );
}
