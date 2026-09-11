// ACT-15：ExternalCalendarEvent Drift 持久化适配器。
//
// 铁律：
// - 实现 ExternalCalendarEventStore（save, query），外加 countRevisions 供审计证明；
// - 单事务完成 CAS 校验、旧 latest 置 false、插入新 revision + subjects；
// - 绝不 import / 调用 Coverage、Shard、Projection 端口；
// - 不推断 usedProfileRefs。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';

import 'life_event_database.dart';

/// Drift 外部日历事件存储实现。
final class DriftExternalCalendarEventStore implements ExternalCalendarEventStore {
  final LifeEventDatabase _db;

  DriftExternalCalendarEventStore(this._db);

  @override
  Future<SaveExternalEventResult> save(SaveExternalEventRequest request) async {
    // 作用域隔离断言：ownerScopeId 必须与事件一致
    if (request.ownerScopeId != request.event.ownerScopeId) {
      return SaveExternalEventResult(
        outcome: 'ownerScopeMismatch',
        revision: request.event.revision,
      );
    }

    return _db.transaction(() async {
      // 1. 查找当前 latest 记录
      final existingLatest = await (_db.select(_db.lifeEventExternalEvents)
            ..where((t) =>
                t.ownerScopeId.equals(request.ownerScopeId) &
                t.externalEventId.equals(request.event.externalEventId) &
                t.isLatest.equals(true)))
          .getSingleOrNull();

      // 2. CAS 校验
      if (request.expectedRevision == null) {
        if (existingLatest != null) {
          return SaveExternalEventResult(
            outcome: 'revisionConflict',
            revision: existingLatest.revision,
          );
        }
      } else {
        if (existingLatest == null ||
            existingLatest.revision != request.expectedRevision ||
            request.event.revision == existingLatest.revision) {
          return SaveExternalEventResult(
            outcome: 'revisionConflict',
            revision: existingLatest?.revision ?? '',
          );
        }
      }

      // 3. 将旧 latest 标记为 false
      if (existingLatest != null) {
        await (_db.update(_db.lifeEventExternalEvents)
              ..where((t) =>
                  t.ownerScopeId.equals(request.ownerScopeId) &
                  t.externalEventId.equals(request.event.externalEventId) &
                  t.isLatest.equals(true)))
            .write(const LifeEventExternalEventsCompanion(isLatest: Value(false)));
      }

      // 4. 解析时间列
      final time = request.event.eventTime;
      final String timeKind;
      final int startMs = time.effectiveStartUtc.millisecondsSinceEpoch;
      final int? endMs;
      final int? precisionIndex;

      switch (time) {
        case InstantTime t:
          timeKind = 'instant';
          endMs = null;
          precisionIndex = t.precision.index;
        case IntervalTime t:
          timeKind = 'interval';
          endMs = t.endExclusiveUtc.millisecondsSinceEpoch;
          precisionIndex = t.precision.index;
        case CivilSpanTime t:
          timeKind = 'civilSpan';
          endMs = t.endCivilExclusive.millisecondsSinceEpoch;
          precisionIndex = t.precision.index;
      }

      // 5. 插入新 revision
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _db.into(_db.lifeEventExternalEvents).insert(
            LifeEventExternalEventRow(
              ownerScopeId: request.ownerScopeId,
              externalEventId: request.event.externalEventId,
              revision: request.event.revision,
              originType: request.event.originType.name,
              originId: request.event.originId,
              divinationTypeKey: request.event.divinationTypeKey,
              subDivinationTypeKey: request.event.subDivinationTypeKey,
              eventTimeKind: timeKind,
              eventStartMs: startMs,
              eventEndMs: endMs,
              eventPrecision: precisionIndex,
              factSummary: request.event.factSummary,
              evidenceRef: request.event.evidenceRef,
              lifecycleStatus: request.event.lifecycleStatus,
              usedProfileRefsJson: jsonEncode(request.event.usedProfileRefs),
              savedAtMs: nowMs,
              isLatest: true,
            ),
          );

      // 6. 插入 subjects（按顺序 position 写入）
      final subjects = request.event.relatedSubjectIds;
      for (var i = 0; i < subjects.length; i++) {
        await _db.into(_db.lifeEventExternalEventSubjects).insert(
              LifeEventExternalEventSubjectRow(
                ownerScopeId: request.ownerScopeId,
                externalEventId: request.event.externalEventId,
                revision: request.event.revision,
                subjectId: subjects[i],
                position: i,
              ),
            );
      }

      return SaveExternalEventResult(
        outcome: 'saved',
        revision: request.event.revision,
      );
    });
  }

  @override
  Future<ExternalEventPage> query(ExternalEventQuery query) async {
    var q = _db.select(_db.lifeEventExternalEvents)
      ..where((t) =>
          t.ownerScopeId.equals(query.ownerScopeId) &
          t.isLatest.equals(true));

    // 1. relatedSubjectIds 交集过滤
    if (query.relatedSubjectIds.isNotEmpty) {
      q = q
        ..where((t) {
          final subquery = _db.selectOnly(_db.lifeEventExternalEventSubjects)
            ..addColumns([_db.lifeEventExternalEventSubjects.externalEventId])
            ..where(_db.lifeEventExternalEventSubjects.ownerScopeId.equals(query.ownerScopeId) &
                _db.lifeEventExternalEventSubjects.subjectId.isIn(query.relatedSubjectIds) &
                _db.lifeEventExternalEventSubjects.externalEventId.equalsExp(t.externalEventId) &
                _db.lifeEventExternalEventSubjects.revision.equalsExp(t.revision));
          return existsQuery(subquery);
        });
    }

    // 2. originTypes 过滤
    if (query.originTypes.isNotEmpty) {
      final names = query.originTypes.map((o) => o.name).toList();
      q = q..where((t) => t.originType.isIn(names));
    }

    // 3. timeRange 半开相交过滤
    if (query.timeRange != null) {
      final startRangeMs = query.timeRange!.startInclusiveUtc.millisecondsSinceEpoch;
      final endRangeMs = query.timeRange!.endExclusiveUtc.millisecondsSinceEpoch;
      q = q
        ..where((t) =>
            t.eventStartMs.isSmallerThanValue(endRangeMs) &
            ((t.eventEndMs.isNull() & t.eventStartMs.isBiggerOrEqualValue(startRangeMs)) |
                (t.eventEndMs.isNotNull() & t.eventEndMs.isBiggerThanValue(startRangeMs))));
    }

    // 4. keyset 游标过滤 (event_start_ms, external_event_id)
    final decoded = _decodePageToken(query.pageToken);
    if (decoded != null) {
      final (tokenStartMs, tokenEventId) = decoded;
      q = q
        ..where((t) =>
            t.eventStartMs.isBiggerThanValue(tokenStartMs) |
            (t.eventStartMs.equals(tokenStartMs) &
                t.externalEventId.isBiggerThanValue(tokenEventId)));
    }

    // 5. 排序与限制
    q = q
      ..orderBy([
        (t) => OrderingTerm.asc(t.eventStartMs),
        (t) => OrderingTerm.asc(t.externalEventId),
      ])
      ..limit(query.pageSize + 1);

    final rows = await q.get();
    final hasMore = rows.length > query.pageSize;
    final pageRows = hasMore ? rows.sublist(0, query.pageSize) : rows;

    if (pageRows.isEmpty) {
      return const ExternalEventPage(items: [], nextPageToken: null);
    }

    // 6. 批量加载关联的主题列表
    final eventIds = pageRows.map((r) => r.externalEventId).toList();
    final subjectRows = await (_db.select(_db.lifeEventExternalEventSubjects)
          ..where((t) =>
              t.ownerScopeId.equals(query.ownerScopeId) &
              t.externalEventId.isIn(eventIds))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    final subjectsMap = <String, List<String>>{};
    for (final s in subjectRows) {
      final key = '${s.externalEventId}:${s.revision}';
      subjectsMap.putIfAbsent(key, () => []).add(s.subjectId);
    }

    final items = pageRows.map((row) {
      final key = '${row.externalEventId}:${row.revision}';
      final subjects = subjectsMap[key] ?? const <String>[];
      return _rowToExternalCalendarEvent(row, subjects);
    }).toList();

    String? nextPageToken;
    if (hasMore && pageRows.isNotEmpty) {
      final last = pageRows.last;
      nextPageToken = _encodePageToken(last.eventStartMs, last.externalEventId);
    }

    return ExternalEventPage(items: items, nextPageToken: nextPageToken);
  }

  /// 适配器自有只读方法（审计证明用，范式同 ACT-12 loadOwnerState）。
  Future<int> countRevisions(String ownerScopeId, String externalEventId) async {
    final countExp = _db.lifeEventExternalEvents.externalEventId.count();
    final query = _db.selectOnly(_db.lifeEventExternalEvents)
      ..addColumns([countExp])
      ..where(_db.lifeEventExternalEvents.ownerScopeId.equals(ownerScopeId) &
          _db.lifeEventExternalEvents.externalEventId.equals(externalEventId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  ExternalCalendarEvent _rowToExternalCalendarEvent(
    LifeEventExternalEventRow row,
    List<String> subjects,
  ) {
    List<String> usedProfiles;
    try {
      usedProfiles = (jsonDecode(row.usedProfileRefsJson) as List<dynamic>)
          .cast<String>();
    } catch (_) {
      usedProfiles = const [];
    }

    final originType = ExternalOriginType.values.byName(row.originType);
    final time = _rowToLifeEventTime(row);

    return ExternalCalendarEvent(
      ownerScopeId: row.ownerScopeId,
      externalEventId: row.externalEventId,
      revision: row.revision,
      originType: originType,
      originId: row.originId,
      relatedSubjectIds: subjects,
      usedProfileRefs: usedProfiles,
      divinationTypeKey: row.divinationTypeKey,
      subDivinationTypeKey: row.subDivinationTypeKey,
      eventTime: time,
      factSummary: row.factSummary,
      evidenceRef: row.evidenceRef,
      lifecycleStatus: row.lifecycleStatus,
    );
  }

  LifeEventTime _rowToLifeEventTime(LifeEventExternalEventRow row) {
    final startUtc =
        DateTime.fromMillisecondsSinceEpoch(row.eventStartMs, isUtc: true);
    final precision = row.eventPrecision != null
        ? TimePrecision.values[row.eventPrecision!]
        : TimePrecision.hour;

    switch (row.eventTimeKind) {
      case 'interval':
        final endUtc = DateTime.fromMillisecondsSinceEpoch(
          row.eventEndMs ?? row.eventStartMs,
          isUtc: true,
        );
        return IntervalTime(
          effectiveStartUtc: startUtc,
          startInclusiveUtc: startUtc,
          endExclusiveUtc: endUtc,
          calculationTimezoneId: 'UTC',
          precision: precision,
        );
      case 'civilSpan':
        final endUtc = DateTime.fromMillisecondsSinceEpoch(
          row.eventEndMs ?? row.eventStartMs,
          isUtc: true,
        );
        return CivilSpanTime(
          effectiveStartUtc: startUtc,
          startCivilInclusive: startUtc,
          endCivilExclusive: endUtc,
          calendarSystem: 'gregorian',
          timezoneId: 'UTC',
          precision: precision,
        );
      case 'instant':
      default:
        return InstantTime(
          effectiveStartUtc: startUtc,
          instantUtc: startUtc,
          calculationTimezoneId: 'UTC',
          precision: precision,
        );
    }
  }

  static String _encodePageToken(int startMs, String eventId) {
    return base64Url.encode(utf8.encode('$startMs:$eventId'));
  }

  static (int, String)? _decodePageToken(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final str = utf8.decode(base64Url.decode(token));
      final idx = str.indexOf(':');
      if (idx < 0) return null;
      final startMs = int.parse(str.substring(0, idx));
      final id = str.substring(idx + 1);
      return (startMs, id);
    } catch (_) {
      return null;
    }
  }
}
