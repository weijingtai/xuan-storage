// ACT-06：Drift/SQLite 原子存储适配器。
//
// 与 In-Memory 参考实现共享同一合同（lifeEventStorageContractSuite）：
// receipt-first 判定顺序（receipt → digest → CAS → payload → receipt → progress），
// 全部写入在一个 SQLite transaction 内完成，任一阶段失败全部回滚。
//
// 不 import calendar / 具体术数 submodule；只消费 persistence_core DTO 与本地表。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';

import 'life_event_database.dart';

/// Drift 原子存储实现。
final class DriftLifeEventStorage
    implements LifeEventCoverageGenerationPort, LifeEventShardCommitPort {
  final LifeEventDatabase _db;

  DriftLifeEventStorage(this._db);

  // ── 测试/快照辅助 ──

  Future<Map<String, ShardReceipt>> readReceipts() async {
    final rows = await _db.select(_db.lifeEventShardReceipts).get();
    return {for (final r in rows) '${r.coverageId}\u0000${r.shardId}': _receipt(r)};
  }

  Future<Map<String, CoverageManifest>> readManifests() async {
    final rows = await _db.select(_db.lifeEventCoverageManifests).get();
    return {for (final r in rows) r.coverageId: _manifest(r)};
  }

  Future<List<LifeEventCoverageSeriesHeadRow>> readHeads() async =>
      _db.select(_db.lifeEventCoverageSeriesHeads).get();

  // ── LifeEventCoverageGenerationPort ──

  @override
  Future<CreateCoverageGenerationResult> createOrReplaceCandidate(
    CreateCoverageGenerationRequest request,
  ) async {
    return _db.transaction(() async {
      final head = await (_db.select(_db.lifeEventCoverageSeriesHeads)
            ..where((t) => t.coverageSeriesId.equals(request.coverageSeriesId)))
          .getSingleOrNull();
      if (head != null && head.seriesRevision != request.expectedSeriesRevision) {
        return CreateCoverageGenerationResult(
          outcome: CreateCoverageGenerationOutcome.seriesRevisionConflict,
          coverageId: null,
          coverageGeneration: null,
          seriesRevision: head.seriesRevision,
          activeCoverageId: head.activeCoverageId,
          candidateCoverageId: head.candidateCoverageId,
          desiredRange: _rangeFrom(head.desiredRangeStartMs, head.desiredRangeEndMs),
        );
      }
      final shrinks = head != null &&
          (request.desiredRange.startInclusiveUtc.isAfter(
                DateTime.fromMillisecondsSinceEpoch(head.desiredRangeStartMs),
              ) ||
              request.desiredRange.endExclusiveUtc.isBefore(
                DateTime.fromMillisecondsSinceEpoch(head.desiredRangeEndMs),
              ));
      if (shrinks) {
        return CreateCoverageGenerationResult(
          outcome: CreateCoverageGenerationOutcome.rangeShrinkUnsupported,
          coverageId: null,
          coverageGeneration: null,
          seriesRevision: head.seriesRevision,
          activeCoverageId: head.activeCoverageId,
          candidateCoverageId: head.candidateCoverageId,
          desiredRange: _rangeFrom(head.desiredRangeStartMs, head.desiredRangeEndMs),
        );
      }

      final seriesRevision = (head?.seriesRevision ?? 0) + 1;
      final coverageId = 'cov-${request.coverageSeriesId}-$seriesRevision';
      await _db.into(_db.lifeEventCoverageSeriesHeads).insert(
        LifeEventCoverageSeriesHeadRow(
          coverageSeriesId: request.coverageSeriesId,
          ownerScopeId: '',
          profileId: '',
          chartSnapshotId: request.chartSnapshotId,
          providerId: request.providerId,
          eventTypeId: request.eventTypeId,
          seriesRevision: seriesRevision,
          activeCoverageId: head?.activeCoverageId,
          candidateCoverageId: coverageId,
          desiredRangeStartMs: request.desiredRange.startInclusiveUtc.millisecondsSinceEpoch,
          desiredRangeEndMs: request.desiredRange.endExclusiveUtc.millisecondsSinceEpoch,
        ),
        mode: InsertMode.insertOrReplace,
      );
      return CreateCoverageGenerationResult(
        outcome: CreateCoverageGenerationOutcome.created,
        coverageId: coverageId,
        coverageGeneration: seriesRevision,
        seriesRevision: seriesRevision,
        activeCoverageId: head?.activeCoverageId,
        candidateCoverageId: coverageId,
        desiredRange: request.desiredRange,
      );
    });
  }

  // ── LifeEventShardCommitPort ──

  @override
  Future<CommitValidatedShardResult> commitValidatedShard(
    CommitValidatedShardRequest request,
  ) async {
    return _db.transaction(() async {
      final receiptKey = request.receiptIdentity;

      // 1. receipt-first：已存在 → 幂等或 digest 冲突，零写入。
      final existing = await _findReceipt(receiptKey.coverageId, receiptKey.shardId);
      if (existing != null) {
        if (existing.contentDigest == request.contentDigest) {
          return _result(
            outcome: CommitValidatedShardOutcome.idempotentReplay,
            request: request,
            persistedCount: existing.persistedCount,
            persistedDigest: existing.persistedDigest,
            manifest: await _findManifest(request.coverageId),
          );
        }
        return _result(
          outcome: CommitValidatedShardOutcome.receiptDigestConflict,
          request: request,
        );
      }

      // 2. receipt 不存在：manifest revision CAS。
      final manifestRow = await _findManifestRow(request.coverageId);
      final currentManifestRevision = manifestRow?.manifestRevision ?? 0;
      if (request.expectedManifestRevision != currentManifestRevision) {
        return _result(
          outcome: CommitValidatedShardOutcome.revisionConflict,
          request: request,
        );
      }

      // 3. complete 前置：series-head CAS + receipts 收齐检查。
      if (request.requestedCoverageTransition == CoverageTransition.complete) {
        final head = await _headForCoverage(request.coverageId);
        final headMatches = head != null &&
            head.candidateCoverageId == request.expectedCandidateCoverageId &&
            head.seriesRevision == request.expectedSeriesRevision;
        if (!headMatches) {
          return _result(
            outcome: CommitValidatedShardOutcome.activeSwitchConflict,
            request: request,
          );
        }
        final committed =
            await _countReceiptsForCoverage(request.coverageId);
        final expected = _expectedShardCount(request.coverageId);
        if (expected != null && expected > 0 && committed + 1 < expected) {
          return _result(
            outcome: CommitValidatedShardOutcome.activeSwitchConflict,
            request: request,
          );
        }
      }

      // 4. 原子写入 payload + receipt + manifest progress。
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      for (final p in request.projections) {
        await _db.into(_db.lifeEventProjections).insert(
          _projectionRow(p),
          mode: InsertMode.insertOrIgnore,
        );
      }
      await _db.into(_db.lifeEventShardReceipts).insert(
        LifeEventShardReceiptRow(
          coverageId: request.coverageId,
          shardId: receiptKey.shardId,
          coverageGeneration: request.coverageGeneration,
          requestedRangeStartMs: request.requestedRange.startInclusiveUtc.millisecondsSinceEpoch,
          requestedRangeEndMs: request.requestedRange.endExclusiveUtc.millisecondsSinceEpoch,
          coveredRangeStartMs: request.coveredRange.startInclusiveUtc.millisecondsSinceEpoch,
          coveredRangeEndMs: request.coveredRange.endExclusiveUtc.millisecondsSinceEpoch,
          eventCount: request.eventCount,
          contentDigest: request.contentDigest,
          persistedCount: request.projections.length,
          persistedDigest: request.contentDigest,
          isCompleteForCoveredRange: request.isCompleteForCoveredRange,
          inputFingerprint: request.inputFingerprint,
          committedAtMs: nowMs,
        ),
      );

      final isComplete = request.requestedCoverageTransition ==
          CoverageTransition.complete;
      final completedShardCount =
          await _countReceiptsForCoverage(request.coverageId);
      final manifest = await _upsertManifest(
        request: request,
        currentRevision: currentManifestRevision,
        completedShardCount: completedShardCount,
        isComplete: isComplete,
        nowMs: nowMs,
      );

      // 5. complete：切换 active/historical（同一事务）。
      if (isComplete) {
        final head = await _headForCoverage(request.coverageId);
        if (head != null) {
          final oldActiveId = head.activeCoverageId;
          if (oldActiveId != null && oldActiveId != request.coverageId) {
            final old = await _findManifestRow(oldActiveId);
            if (old != null) {
              await (_db.update(_db.lifeEventCoverageManifests)
                    ..where((t) => t.coverageId.equals(oldActiveId)))
                  .write(LifeEventCoverageManifestsCompanion(
                    servingState: Value(ServingState.historical.index),
                  ));
            }
          }
          await (_db.update(_db.lifeEventCoverageSeriesHeads)
                ..where((t) => t.coverageSeriesId.equals(head.coverageSeriesId)))
              .write(LifeEventCoverageSeriesHeadsCompanion(
                activeCoverageId: Value(request.coverageId),
                candidateCoverageId: const Value(null),
              ));
        }
      }

      return _result(
        outcome: CommitValidatedShardOutcome.applied,
        request: request,
        persistedCount: request.projections.length,
        persistedDigest: request.contentDigest,
        manifestRevision: manifest.manifestRevision,
        coverageStatus: manifest.status,
        servingState: manifest.servingState,
        completedShardCount: completedShardCount,
        expectedShardCount: _expectedShardCount(request.coverageId) ?? 0,
      );
    });
  }

  // ── helpers ──

  int? _expectedShardCount(String coverageId) => null;

  Future<LifeEventShardReceiptRow?> _findReceipt(
    String coverageId,
    String shardId,
  ) async {
    return (_db.select(_db.lifeEventShardReceipts)
          ..where((t) =>
              t.coverageId.equals(coverageId) & t.shardId.equals(shardId)))
        .getSingleOrNull();
  }

  Future<LifeEventCoverageManifestRow?> _findManifestRow(String coverageId) async {
    return (_db.select(_db.lifeEventCoverageManifests)
          ..where((t) => t.coverageId.equals(coverageId)))
        .getSingleOrNull();
  }

  Future<CoverageManifest?> _findManifest(String coverageId) async {
    final row = await _findManifestRow(coverageId);
    return row == null ? null : _manifest(row);
  }

  Future<LifeEventCoverageSeriesHeadRow?> _headForCoverage(
    String coverageId,
  ) async {
    final rows = await (_db.select(_db.lifeEventCoverageSeriesHeads)
          ..where((t) =>
              t.candidateCoverageId.equals(coverageId) |
              t.activeCoverageId.equals(coverageId)))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> _countReceiptsForCoverage(String coverageId) async {
    final row = await (_db.selectOnly(_db.lifeEventShardReceipts)
          ..addColumns([_db.lifeEventShardReceipts.coverageId.count()])
          ..where(_db.lifeEventShardReceipts.coverageId.equals(coverageId)))
        .getSingle();
    return row.read(_db.lifeEventShardReceipts.coverageId.count()) ?? 0;
  }

  Future<CoverageManifest> _upsertManifest({
    required CommitValidatedShardRequest request,
    required int currentRevision,
    required int completedShardCount,
    required bool isComplete,
    required int nowMs,
  }) async {
    final existing = await _findManifestRow(request.coverageId);
    final manifest = CoverageManifest(
      coverageId: request.coverageId,
      coverageSeriesId: existing?.coverageSeriesId ?? '',
      coverageGeneration: request.coverageGeneration,
      manifestRevision: currentRevision + 1,
      servingState: isComplete ? ServingState.active : ServingState.candidate,
      profileId: existing?.profileId ?? '',
      chartSnapshotId: existing?.chartSnapshotId ?? '',
      chartSnapshotRevision: existing?.chartSnapshotRevision ?? '',
      providerId: existing?.providerId ?? request.providerId,
      providerVersion: existing?.providerVersion ?? request.providerVersion,
      algorithmVersion: existing?.algorithmVersion ?? request.algorithmVersion,
      dataVersion: existing?.dataVersion ?? request.dataVersion,
      eventTypeId: existing?.eventTypeId ?? request.eventTypeId,
      eventTypeSchemaVersion:
          existing?.eventTypeSchemaVersion ?? request.eventTypeSchemaVersion,
      capabilityDescriptorVersion: '',
      capabilityDigest: '',
      requestedRange: existing == null
          ? request.requestedRange
          : _rangeFrom(existing.requestedRangeStartMs, existing.requestedRangeEndMs),
      coveredRanges: [
        if (existing != null && existing.coveredRangesJson.isNotEmpty)
          ..._decodeRanges(existing.coveredRangesJson),
        request.coveredRange,
      ],
      status: isComplete
          ? CoverageStatus.complete
          : (existing == null
                ? CoverageStatus.running
                : CoverageStatus.values[existing.status]),
      inputFingerprint: request.inputFingerprint,
      expectedShardCount: 0,
      completedShardCount: completedShardCount,
      sourceEventCount: (existing?.sourceEventCount ?? 0) + request.eventCount,
      outputDigest: request.contentDigest,
      startedAt: existing == null
          ? DateTime.fromMillisecondsSinceEpoch(nowMs)
          : DateTime.fromMillisecondsSinceEpoch(existing.startedAtMs),
      completedAt: isComplete
          ? DateTime.fromMillisecondsSinceEpoch(nowMs)
          : existing == null || existing.completedAtMs == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(existing.completedAtMs!),
      lastErrorCode: isComplete ? null : existing?.lastErrorCode,
    );
    await _db.into(_db.lifeEventCoverageManifests).insert(
      _manifestRow(manifest),
      mode: InsertMode.insertOrReplace,
    );
    return manifest;
  }

  LifeEventProjectionRow _projectionRow(EventProjection p) {
    return LifeEventProjectionRow(
      projectionId: p.projectionId,
      coverageId: p.coverageId,
      coverageGeneration: p.coverageGeneration,
      sourceProviderId: p.sourceRef.providerId,
      sourceEventId: p.sourceRef.sourceEventId,
      eventRevision: p.sourceRef.eventRevision,
      ownerScopeId: p.ownerScopeId,
      subjectId: p.subjectId,
      profileId: p.profileId,
      chartSnapshotId: p.chartSnapshotId,
      divinationTypeKey: p.divinationTypeKey,
      subDivinationTypeKey: p.subDivinationTypeKey,
      eventTypeId: p.eventTypeId,
      effectiveStartMs: p.eventTime.effectiveStartUtc.millisecondsSinceEpoch,
      precisionRank: _precisionRank(p.eventTime),
      projectionJson: jsonEncode(_projectionToJson(p)),
      lifecycleStatus: p.projectionLifecycleStatus.index,
    );
  }

  ShardReceipt _receipt(LifeEventShardReceiptRow r) {
    return ShardReceipt(
      coverageId: r.coverageId,
      shardId: r.shardId,
      coverageGeneration: r.coverageGeneration,
      requestedRange: _rangeFrom(r.requestedRangeStartMs, r.requestedRangeEndMs),
      coveredRange: _rangeFrom(r.coveredRangeStartMs, r.coveredRangeEndMs),
      eventCount: r.eventCount,
      contentDigest: r.contentDigest,
      persistedCount: r.persistedCount,
      persistedDigest: r.persistedDigest,
      isCompleteForCoveredRange: r.isCompleteForCoveredRange,
      inputFingerprint: r.inputFingerprint,
      committedAt: DateTime.fromMillisecondsSinceEpoch(r.committedAtMs),
    );
  }

  CoverageManifest _manifest(LifeEventCoverageManifestRow r) {
    return CoverageManifest(
      coverageId: r.coverageId,
      coverageSeriesId: r.coverageSeriesId,
      coverageGeneration: r.coverageGeneration,
      manifestRevision: r.manifestRevision,
      servingState: ServingState.values[r.servingState],
      profileId: r.profileId,
      chartSnapshotId: r.chartSnapshotId,
      chartSnapshotRevision: r.chartSnapshotRevision,
      providerId: r.providerId,
      providerVersion: r.providerVersion,
      algorithmVersion: r.algorithmVersion,
      dataVersion: r.dataVersion,
      eventTypeId: r.eventTypeId,
      eventTypeSchemaVersion: r.eventTypeSchemaVersion,
      capabilityDescriptorVersion: '',
      capabilityDigest: '',
      requestedRange: _rangeFrom(r.requestedRangeStartMs, r.requestedRangeEndMs),
      coveredRanges: _decodeRanges(r.coveredRangesJson),
      status: CoverageStatus.values[r.status],
      inputFingerprint: r.inputFingerprint,
      expectedShardCount: r.expectedShardCount,
      completedShardCount: r.completedShardCount,
      sourceEventCount: r.sourceEventCount,
      outputDigest: r.outputDigest,
      startedAt: DateTime.fromMillisecondsSinceEpoch(r.startedAtMs),
      completedAt: r.completedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(r.completedAtMs!),
      lastErrorCode: r.lastErrorCode,
    );
  }

  LifeEventCoverageManifestRow _manifestRow(CoverageManifest m) {
    return LifeEventCoverageManifestRow(
      coverageId: m.coverageId,
      coverageSeriesId: m.coverageSeriesId,
      coverageGeneration: m.coverageGeneration,
      manifestRevision: m.manifestRevision,
      servingState: m.servingState.index,
      profileId: m.profileId,
      chartSnapshotId: m.chartSnapshotId,
      chartSnapshotRevision: m.chartSnapshotRevision,
      providerId: m.providerId,
      providerVersion: m.providerVersion,
      algorithmVersion: m.algorithmVersion,
      dataVersion: m.dataVersion,
      eventTypeId: m.eventTypeId,
      eventTypeSchemaVersion: m.eventTypeSchemaVersion,
      requestedRangeStartMs: m.requestedRange.startInclusiveUtc.millisecondsSinceEpoch,
      requestedRangeEndMs: m.requestedRange.endExclusiveUtc.millisecondsSinceEpoch,
      coveredRangesJson: jsonEncode(
        m.coveredRanges
            .map(
              (r) => [
                r.startInclusiveUtc.millisecondsSinceEpoch,
                r.endExclusiveUtc.millisecondsSinceEpoch,
              ],
            )
            .toList(),
      ),
      status: m.status.index,
      inputFingerprint: m.inputFingerprint,
      expectedShardCount: m.expectedShardCount,
      completedShardCount: m.completedShardCount,
      sourceEventCount: m.sourceEventCount,
      outputDigest: m.outputDigest,
      startedAtMs: m.startedAt.millisecondsSinceEpoch,
      completedAtMs: m.completedAt?.millisecondsSinceEpoch,
      lastErrorCode: m.lastErrorCode,
    );
  }

  List<TimeRange> _decodeRanges(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => _rangeFrom((e as List)[0] as int, e[1] as int))
        .toList();
  }

  TimeRange _rangeFrom(int startMs, int endMs) => TimeRange(
        startInclusiveUtc: DateTime.fromMillisecondsSinceEpoch(startMs),
        endExclusiveUtc: DateTime.fromMillisecondsSinceEpoch(endMs),
      );

  int _precisionRank(LifeEventTime t) {
    final p = t is InstantTime
        ? t.precision
        : t is IntervalTime
            ? t.precision
            : (t as CivilSpanTime).precision;
    return p.index;
  }

  Map<String, dynamic> _projectionToJson(EventProjection p) => {
        'projectionId': p.projectionId,
        'coverageId': p.coverageId,
        'coverageGeneration': p.coverageGeneration,
        'ownerScopeId': p.ownerScopeId,
        'subjectId': p.subjectId,
        'profileId': p.profileId,
        'chartSnapshotId': p.chartSnapshotId,
        'divinationTypeKey': p.divinationTypeKey,
        'subDivinationTypeKey': p.subDivinationTypeKey,
        'eventTypeId': p.eventTypeId,
        'factSummary': p.factSummary,
        'evidenceRef': p.evidenceRef,
        'indexedAtMs': p.indexedAt.millisecondsSinceEpoch,
      };

  CommitValidatedShardResult _result({
    required CommitValidatedShardOutcome outcome,
    required CommitValidatedShardRequest request,
    int persistedCount = 0,
    String persistedDigest = '',
    int manifestRevision = 0,
    CoverageStatus? coverageStatus,
    ServingState? servingState,
    int completedShardCount = 0,
    int expectedShardCount = 0,
    CoverageManifest? manifest,
  }) {
    return CommitValidatedShardResult(
      outcome: outcome,
      manifestRevision: manifestRevision,
      coverageGeneration: request.coverageGeneration,
      seriesRevision: 0,
      activeCoverageId: null,
      receiptIdentity: request.receiptIdentity,
      persistedCount: persistedCount,
      persistedDigest: persistedDigest,
      coverageStatus:
          coverageStatus ?? manifest?.status ?? CoverageStatus.notRequested,
      servingState:
          servingState ?? manifest?.servingState ?? ServingState.candidate,
      completedShardCount: completedShardCount,
      expectedShardCount: expectedShardCount,
    );
  }
}