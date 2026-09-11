// ACT-15: DriftExternalCalendarEventStore 单元与集成测试
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:persistence_core/test_support/external_calendar_event_store_contract_suite.dart';
import 'package:persistence_drift/life_event/drift_external_calendar_event_store.dart';
import 'package:persistence_drift/life_event/life_event_database.dart';

Future<String> _computeCoverageSnapshot(LifeEventDatabase db) async {
  final projs = await (db.select(db.lifeEventProjections)
        ..orderBy([(t) => OrderingTerm.asc(t.projectionId)]))
      .get();
  final heads = await (db.select(db.lifeEventCoverageSeriesHeads)
        ..orderBy([(t) => OrderingTerm.asc(t.coverageSeriesId)]))
      .get();
  final manifests = await (db.select(db.lifeEventCoverageManifests)
        ..orderBy([(t) => OrderingTerm.asc(t.coverageId)]))
      .get();
  final receipts = await (db.select(db.lifeEventShardReceipts)
        ..orderBy([
          (t) => OrderingTerm.asc(t.coverageId),
          (t) => OrderingTerm.asc(t.shardId),
        ]))
      .get();

  final buf = StringBuffer();
  buf.writeln('projections:${projs.length}');
  for (final p in projs) {
    buf.writeln('${p.projectionId}:${p.ownerScopeId}:${p.profileId}:${p.effectiveStartMs}:${p.lifecycleStatus}');
  }
  buf.writeln('heads:${heads.length}');
  for (final h in heads) {
    buf.writeln('${h.coverageSeriesId}:${h.ownerScopeId}:${h.profileId}:${h.activeCoverageId}:${h.seriesRevision}');
  }
  buf.writeln('manifests:${manifests.length}');
  for (final m in manifests) {
    buf.writeln('${m.coverageId}:${m.coverageSeriesId}:${m.profileId}:${m.coverageGeneration}:${m.status}');
  }
  buf.writeln('receipts:${receipts.length}');
  for (final r in receipts) {
    buf.writeln('${r.coverageId}:${r.shardId}:${r.eventCount}:${r.persistedCount}');
  }

  final bytes = utf8.encode(buf.toString());
  return sha256.convert(bytes).toString();
}

ExternalCalendarEvent _makeTestEvent({
  String ownerScopeId = 'owner-1',
  String externalEventId = 'ext-1',
  String revision = 'rev-1',
  ExternalOriginType originType = ExternalOriginType.destinyQuestion,
  String originId = 'origin-1',
  List<String> relatedSubjectIds = const [],
  List<String> usedProfileRefs = const [],
  String divinationTypeKey = 'bazi',
  String? subDivinationTypeKey,
  LifeEventTime? eventTime,
  String factSummary = 'External fact',
  String? evidenceRef = 'evidence-1',
  String lifecycleStatus = 'active',
}) {
  return ExternalCalendarEvent(
    ownerScopeId: ownerScopeId,
    externalEventId: externalEventId,
    revision: revision,
    originType: originType,
    originId: originId,
    relatedSubjectIds: relatedSubjectIds,
    usedProfileRefs: usedProfileRefs,
    divinationTypeKey: divinationTypeKey,
    subDivinationTypeKey: subDivinationTypeKey,
    eventTime: eventTime ??
        InstantTime(
          effectiveStartUtc: DateTime.utc(2026, 6, 1, 12),
          instantUtc: DateTime.utc(2026, 6, 1, 12),
          calculationTimezoneId: 'UTC',
          precision: TimePrecision.hour,
        ),
    factSummary: factSummary,
    evidenceRef: evidenceRef,
    lifecycleStatus: lifecycleStatus,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // 1. 运行共享合同测试套件
  runExternalCalendarEventStoreContractSuite(
    makeStore: () {
      final db = LifeEventDatabase(NativeDatabase.memory());
      return DriftExternalCalendarEventStore(db);
    },
  );

  group('DriftExternalCalendarEventStore 专有与隔离测试', () {
    late LifeEventDatabase db;
    late DriftExternalCalendarEventStore store;

    setUp(() {
      db = LifeEventDatabase(NativeDatabase.memory());
      store = DriftExternalCalendarEventStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('审计保留：同一 externalEventId 保存三个 revision 后 query 只返回最新一条，countRevisions == 3', () async {
      const owner = 'owner-audit';
      const eventId = 'ext-audit-1';

      final r1 = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: owner,
          event: _makeTestEvent(ownerScopeId: owner, externalEventId: eventId, revision: 'rev-1', factSummary: 'First'),
          expectedRevision: null,
        ),
      );
      expect(r1.outcome, 'saved');

      final r2 = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: owner,
          event: _makeTestEvent(ownerScopeId: owner, externalEventId: eventId, revision: 'rev-2', factSummary: 'Second'),
          expectedRevision: 'rev-1',
        ),
      );
      expect(r2.outcome, 'saved');

      final r3 = await store.save(
        SaveExternalEventRequest(
          ownerScopeId: owner,
          event: _makeTestEvent(ownerScopeId: owner, externalEventId: eventId, revision: 'rev-3', factSummary: 'Third'),
          expectedRevision: 'rev-2',
        ),
      );
      expect(r3.outcome, 'saved');

      final page = await store.query(
        const ExternalEventQuery(
          ownerScopeId: owner,
          relatedSubjectIds: [],
          originTypes: [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );
      expect(page.items.length, 1);
      expect(page.items.first.revision, 'rev-3');
      expect(page.items.first.factSummary, 'Third');

      final count = await store.countRevisions(owner, eventId);
      expect(count, 3, reason: '旧 revision 不物理删除，countRevisions 应返回全部 3 个 revision');
    });

    test('Coverage 隔离物理证明：保存 External 前后，四表行数与 digest 完全相同', () async {
      const owner = 'owner-iso';

      // 预先插入一条 Coverage 数据以确保 snapshot 包含非空数据
      await db.into(db.lifeEventCoverageSeriesHeads).insert(
            const LifeEventCoverageSeriesHeadRow(
              coverageSeriesId: 'head-1',
              ownerScopeId: owner,
              profileId: 'prof-1',
              chartSnapshotId: 'snap-1',
              providerId: 'prov-1',
              eventTypeId: 'type-1',
              seriesRevision: 1,
              activeCoverageId: 'cov-1',
              desiredRangeStartMs: 1000,
              desiredRangeEndMs: 5000,
            ),
          );
      await db.into(db.lifeEventCoverageManifests).insert(
            const LifeEventCoverageManifestRow(
              coverageId: 'cov-1',
              coverageSeriesId: 'head-1',
              coverageGeneration: 1,
              manifestRevision: 1,
              servingState: 1,
              profileId: 'prof-1',
              chartSnapshotId: 'snap-1',
              chartSnapshotRevision: '1',
              providerId: 'prov-1',
              providerVersion: '1.0.0',
              algorithmVersion: '1.0.0',
              eventTypeId: 'type-1',
              eventTypeSchemaVersion: '1.0.0',
              requestedRangeStartMs: 1000,
              requestedRangeEndMs: 5000,
              coveredRangesJson: '[]',
              status: 1,
              inputFingerprint: 'fp-1',
              expectedShardCount: 1,
              completedShardCount: 1,
              sourceEventCount: 0,
              outputDigest: 'digest-1',
              startedAtMs: 1000,
            ),
          );

      final snapshotBefore = await _computeCoverageSnapshot(db);

      // 保存外部事件：0 / 1 / N subjects，多个 revision
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: owner,
          event: _makeTestEvent(
            ownerScopeId: owner,
            externalEventId: 'ext-iso-0',
            revision: 'r1',
            relatedSubjectIds: const [],
          ),
          expectedRevision: null,
        ),
      );
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: owner,
          event: _makeTestEvent(
            ownerScopeId: owner,
            externalEventId: 'ext-iso-1',
            revision: 'r1',
            relatedSubjectIds: const ['subj-1'],
          ),
          expectedRevision: null,
        ),
      );
      await store.save(
        SaveExternalEventRequest(
          ownerScopeId: owner,
          event: _makeTestEvent(
            ownerScopeId: owner,
            externalEventId: 'ext-iso-n',
            revision: 'r1',
            relatedSubjectIds: const ['subj-1', 'subj-2', 'subj-3'],
            usedProfileRefs: const ['prof-1'],
          ),
          expectedRevision: null,
        ),
      );

      final snapshotAfter = await _computeCoverageSnapshot(db);
      expect(snapshotAfter, equals(snapshotBefore), reason: 'Coverage 四表行数与 digest 绝不受 External 操作影响');
    });

    test('sqlite_master 结构检查：External 两张表无外键与触发器，无指向 External 的外键与触发器', () async {
      final rows = await db.customSelect(
        "SELECT type, name, tbl_name, sql FROM sqlite_master WHERE type IN ('table', 'trigger')",
      ).get();

      for (final r in rows) {
        final type = r.read<String>('type');
        final name = r.read<String>('name');
        final tblName = r.read<String>('tbl_name');
        final sql = r.read<String?>('sql') ?? '';

        if (tblName == 't_le_external_events' || tblName == 't_le_external_event_subjects') {
          // 本表不得有外键约束
          expect(sql.toUpperCase().contains('REFERENCES'), isFalse,
              reason: '$tblName 不得包含外键定义: $sql');
          // 不得有触发器
          expect(type, isNot('trigger'), reason: '$tblName 不得有触发器: $name');
        } else {
          // 其他表与触发器不得引用 External 表
          expect(sql.contains('t_le_external_events'), isFalse,
              reason: '其他表/触发器 $name 不得引用 t_le_external_events');
          expect(sql.contains('t_le_external_event_subjects'), isFalse,
              reason: '其他表/触发器 $name 不得引用 t_le_external_event_subjects');
        }
      }
    });

    test('[LEC-041] 0/1/N relatedSubjects 重开后无损，且前后 Coverage snapshot 完全相同', () async {
      final tempDir = await Directory.systemTemp.createTemp('act15_reopen_test_');
      final dbFile = File('${tempDir.path}/test_life_event.db');

      const owner = 'owner-lec41';

      // 1. 打开临时文件库并写入初始 Coverage
      var fileDb = LifeEventDatabase(LifeEventDatabase.openNativeFile(dbFile));
      var fileStore = DriftExternalCalendarEventStore(fileDb);

      await fileDb.into(fileDb.lifeEventCoverageSeriesHeads).insert(
            const LifeEventCoverageSeriesHeadRow(
              coverageSeriesId: 'head-lec41',
              ownerScopeId: owner,
              profileId: 'prof-lec41',
              chartSnapshotId: 'snap-lec41',
              providerId: 'prov-lec41',
              eventTypeId: 'type-lec41',
              seriesRevision: 1,
              activeCoverageId: 'cov-lec41',
              desiredRangeStartMs: 2000,
              desiredRangeEndMs: 8000,
            ),
          );

      final snapBefore = await _computeCoverageSnapshot(fileDb);

      // 写入 0/1/N subjects 事件
      final e0 = _makeTestEvent(
        ownerScopeId: owner,
        externalEventId: 'e-zero',
        revision: 'r1',
        relatedSubjectIds: const [],
        usedProfileRefs: const ['prof-explicit-0'],
      );
      final e1 = _makeTestEvent(
        ownerScopeId: owner,
        externalEventId: 'e-one',
        revision: 'r1',
        relatedSubjectIds: const ['subj-alpha'],
        usedProfileRefs: const ['prof-explicit-1'],
      );
      final eN = _makeTestEvent(
        ownerScopeId: owner,
        externalEventId: 'e-many',
        revision: 'r1',
        relatedSubjectIds: const ['subj-x', 'subj-y', 'subj-z'],
        usedProfileRefs: const ['prof-explicit-a', 'prof-explicit-b'],
      );

      await fileStore.save(SaveExternalEventRequest(ownerScopeId: owner, event: e0, expectedRevision: null));
      await fileStore.save(SaveExternalEventRequest(ownerScopeId: owner, event: e1, expectedRevision: null));
      await fileStore.save(SaveExternalEventRequest(ownerScopeId: owner, event: eN, expectedRevision: null));

      final snapAfterWrite = await _computeCoverageSnapshot(fileDb);
      expect(snapAfterWrite, equals(snapBefore));

      // 关闭数据库
      await fileDb.close();

      // 2. 经 openNativeFile 重开
      fileDb = LifeEventDatabase(LifeEventDatabase.openNativeFile(dbFile));
      fileStore = DriftExternalCalendarEventStore(fileDb);

      final snapAfterReopen = await _computeCoverageSnapshot(fileDb);
      expect(snapAfterReopen, equals(snapBefore), reason: '重开后 Coverage snapshot 仍完全一致');

      final page = await fileStore.query(
        const ExternalEventQuery(
          ownerScopeId: owner,
          relatedSubjectIds: [],
          originTypes: [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );

      expect(page.items.length, 3);
      final map = {for (final item in page.items) item.externalEventId: item};

      expect(map['e-zero']!.relatedSubjectIds, isEmpty);
      expect(map['e-zero']!.usedProfileRefs, ['prof-explicit-0']);

      expect(map['e-one']!.relatedSubjectIds, ['subj-alpha']);
      expect(map['e-one']!.usedProfileRefs, ['prof-explicit-1']);

      expect(map['e-many']!.relatedSubjectIds, ['subj-x', 'subj-y', 'subj-z'],
          reason: 'N 个 subject position 顺序必须稳定');
      expect(map['e-many']!.usedProfileRefs, ['prof-explicit-a', 'prof-explicit-b']);

      await fileDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('[LEC-042] usedProfileRefs 仅保存显式值，不做推断', () async {
      const owner = 'owner-lec42';

      final event = _makeTestEvent(
        ownerScopeId: owner,
        externalEventId: 'e-explicit',
        revision: 'r1',
        relatedSubjectIds: const ['subj-without-profile', 'subj-another'],
        usedProfileRefs: const ['profile-explicit-only'],
      );

      await store.save(SaveExternalEventRequest(ownerScopeId: owner, event: event, expectedRevision: null));

      final page = await store.query(
        const ExternalEventQuery(
          ownerScopeId: owner,
          relatedSubjectIds: [],
          originTypes: [],
          timeRange: null,
          pageToken: null,
          pageSize: 10,
        ),
      );

      expect(page.items.length, 1);
      final loaded = page.items.first;
      expect(loaded.relatedSubjectIds, ['subj-without-profile', 'subj-another']);
      expect(loaded.usedProfileRefs, ['profile-explicit-only'],
          reason: 'usedProfileRefs 绝不从 relatedSubjectIds 推断');
    });
  });
}
