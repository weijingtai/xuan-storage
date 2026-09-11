// ACT-06 / ACT-05A-S：Drift/SQLite 原子持久化与查询适配器。
//
// 与 In-Memory 参考实现共享同一合同（runLifeEventStorageContractSuite / runLifeEventQueryContractSuite）：
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

/// Drift 原子存储与查询实现。
final class DriftLifeEventStorage
    implements
        LifeEventCoverageGenerationPort,
        LifeEventShardCommitPort,
        LifeEventProjectionQueryPort,
        LifeEventCoverageQueryPort {
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
          ownerScopeId: head?.ownerScopeId ?? '',
          profileId: head?.profileId ?? '',
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
          mode: InsertMode.insertOrReplace,
        );
      }

      // 若有 withdrawals，将其标记为 withdrawn
      for (final w in request.withdrawals) {
        await (_db.update(_db.lifeEventProjections)
              ..where((t) =>
                  t.sourceProviderId.equals(w.providerId) &
                  t.sourceEventId.equals(w.sourceEventId)))
            .write(LifeEventProjectionsCompanion(
              lifecycleStatus: Value(ProjectionLifecycleStatus.withdrawn.index),
            ));
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

      // 同步更新 head 的 ownerScopeId 与 profileId
      final firstProj = request.projections.isNotEmpty ? request.projections.first : null;
      if (firstProj != null) {
        final head = await _headForCoverage(request.coverageId);
        if (head != null && (head.ownerScopeId.isEmpty || head.profileId.isEmpty)) {
          await (_db.update(_db.lifeEventCoverageSeriesHeads)
                ..where((t) => t.coverageSeriesId.equals(head.coverageSeriesId)))
              .write(LifeEventCoverageSeriesHeadsCompanion(
                ownerScopeId: Value(head.ownerScopeId.isNotEmpty ? head.ownerScopeId : firstProj.ownerScopeId),
                profileId: Value(head.profileId.isNotEmpty ? head.profileId : firstProj.profileId),
              ));
        }
      }

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

  // ── LifeEventProjectionQueryPort ──

  @override
  Future<ProjectionQueryPage> queryProjections(ProjectionStorageQuery request) async {
    // V1 唯一支持按 effectiveStart 排序；其他值返回空页并在 nextPageToken=null
    if (request.sortKey != 'effectiveStart') {
      return const ProjectionQueryPage(items: [], nextPageToken: null);
    }

    // 1. 查找匹配的 series heads
    var headQuery = _db.select(_db.lifeEventCoverageSeriesHeads)
      ..where((t) => t.ownerScopeId.equals(request.ownerScopeId));

    if (request.profileIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.profileId.isIn(request.profileIds));
    }
    if (request.chartSnapshotIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.chartSnapshotId.isIn(request.chartSnapshotIds));
    }
    if (request.providerIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.providerId.isIn(request.providerIds));
    }
    if (request.eventTypeIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.eventTypeId.isIn(request.eventTypeIds));
    }

    final matchingHeads = await headQuery.get();

    // 2. 收集符合代条件的 coverage IDs（只读 active；若 includeHistoricalGenerations 额外含 historical）
    final eligibleCoverageIds = <String>{};
    for (final h in matchingHeads) {
      if (h.activeCoverageId != null) {
        eligibleCoverageIds.add(h.activeCoverageId!);
      }
      if (request.includeHistoricalGenerations) {
        final histManifests = await (_db.select(_db.lifeEventCoverageManifests)
              ..where((t) =>
                  t.coverageSeriesId.equals(h.coverageSeriesId) &
                  t.servingState.equals(ServingState.historical.index)))
            .get();
        for (final m in histManifests) {
          eligibleCoverageIds.add(m.coverageId);
        }
      }
    }

    if (eligibleCoverageIds.isEmpty) {
      return const ProjectionQueryPage(items: [], nextPageToken: null);
    }

    // 3. 构建投影查询（利用既有索引）
    final startRangeMs = request.range.startInclusiveUtc.millisecondsSinceEpoch;
    final endRangeMs = request.range.endExclusiveUtc.millisecondsSinceEpoch;

    var projQuery = _db.select(_db.lifeEventProjections)
      ..where((t) =>
          t.ownerScopeId.equals(request.ownerScopeId) &
          t.coverageId.isIn(eligibleCoverageIds) &
          t.effectiveStartMs.isBiggerOrEqualValue(startRangeMs) &
          t.effectiveStartMs.isSmallerThanValue(endRangeMs));

    if (request.profileIds.isNotEmpty) {
      projQuery = projQuery..where((t) => t.profileId.isIn(request.profileIds));
    }
    if (request.chartSnapshotIds.isNotEmpty) {
      projQuery = projQuery..where((t) => t.chartSnapshotId.isIn(request.chartSnapshotIds));
    }
    if (request.providerIds.isNotEmpty) {
      projQuery = projQuery..where((t) => t.sourceProviderId.isIn(request.providerIds));
    }
    if (request.eventTypeIds.isNotEmpty) {
      projQuery = projQuery..where((t) => t.eventTypeId.isIn(request.eventTypeIds));
    }
    if (!request.includeWithdrawn) {
      projQuery = projQuery..where((t) =>
          t.lifecycleStatus.isNotValue(ProjectionLifecycleStatus.withdrawn.index));
    }

    // keyset 游标过滤 (effective_start_ms, precision_rank, projection_id) > (?, ?, ?)
    final decodedToken = _decodePageToken(request.pageToken);
    if (decodedToken != null) {
      final (tMs, tRank, tId) = decodedToken;
      final escapedId = tId.replaceAll("'", "''");
      projQuery = projQuery..where((t) => CustomExpression<bool>(
          '(effective_start_ms, precision_rank, projection_id) > ($tMs, $tRank, \'$escapedId\')'));
    }

    projQuery = projQuery
      ..orderBy([
        (t) => OrderingTerm.asc(t.effectiveStartMs),
        (t) => OrderingTerm.asc(t.precisionRank),
        (t) => OrderingTerm.asc(t.projectionId),
      ])
      ..limit(request.pageSize + 1);

    final rows = await projQuery.get();
    final hasMore = rows.length > request.pageSize;
    final pageRows = hasMore ? rows.sublist(0, request.pageSize) : rows;
    final items = pageRows.map(_rowToProjection).toList();

    String? nextPageToken;
    if (hasMore && items.isNotEmpty) {
      final lastRow = pageRows.last;
      nextPageToken = _encodePageToken(
        lastRow.effectiveStartMs,
        lastRow.precisionRank,
        lastRow.projectionId,
      );
    }

    return ProjectionQueryPage(items: items, nextPageToken: nextPageToken);
  }

  // ── LifeEventCoverageQueryPort ──

  @override
  Future<CoverageStoragePage> queryCoverage(CoverageStorageQuery request) async {
    final startRangeMs = request.range.startInclusiveUtc.millisecondsSinceEpoch;
    final endRangeMs = request.range.endExclusiveUtc.millisecondsSinceEpoch;

    var headQuery = _db.select(_db.lifeEventCoverageSeriesHeads)
      ..where((t) =>
          t.ownerScopeId.equals(request.ownerScopeId) &
          t.desiredRangeStartMs.isSmallerThanValue(endRangeMs) &
          t.desiredRangeEndMs.isBiggerThanValue(startRangeMs));

    if (request.profileIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.profileId.isIn(request.profileIds));
    }
    if (request.chartSnapshotIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.chartSnapshotId.isIn(request.chartSnapshotIds));
    }
    if (request.providerIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.providerId.isIn(request.providerIds));
    }
    if (request.eventTypeIds.isNotEmpty) {
      headQuery = headQuery..where((t) => t.eventTypeId.isIn(request.eventTypeIds));
    }

    final headRows = await headQuery.get();
    final heads = headRows.map(_head).toList();

    final matchingManifests = <CoverageManifest>[];
    for (final h in heads) {
      if (h.activeCoverageId != null) {
        final activeRow = await (_db.select(_db.lifeEventCoverageManifests)
              ..where((t) => t.coverageId.equals(h.activeCoverageId!)))
            .getSingleOrNull();
        if (activeRow != null) {
          matchingManifests.add(_manifest(activeRow));
        }
      }
      if (request.includeHistoricalGenerations) {
        final histRows = await (_db.select(_db.lifeEventCoverageManifests)
              ..where((t) =>
                  t.coverageSeriesId.equals(h.coverageSeriesId) &
                  t.servingState.equals(ServingState.historical.index)))
            .get();
        for (final r in histRows) {
          matchingManifests.add(_manifest(r));
        }
      }
    }

    return CoverageStoragePage(heads: heads, manifests: matchingManifests);
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
    final head = await _headForCoverage(request.coverageId);
    final existing = await _findManifestRow(request.coverageId);
    final firstProj = request.projections.isNotEmpty ? request.projections.first : null;
    final seriesId = (existing != null && existing.coverageSeriesId.isNotEmpty)
        ? existing.coverageSeriesId
        : (head?.coverageSeriesId ?? '');
    final profileId = (existing != null && existing.profileId.isNotEmpty)
        ? existing.profileId
        : (head != null && head.profileId.isNotEmpty
            ? head.profileId
            : (firstProj?.profileId ?? ''));
    final chartSnapshotId = (existing != null && existing.chartSnapshotId.isNotEmpty)
        ? existing.chartSnapshotId
        : (head?.chartSnapshotId ?? request.inputFingerprint);

    final manifest = CoverageManifest(
      coverageId: request.coverageId,
      coverageSeriesId: seriesId,
      coverageGeneration: request.coverageGeneration,
      manifestRevision: currentRevision + 1,
      servingState: isComplete ? ServingState.active : ServingState.candidate,
      profileId: profileId,
      chartSnapshotId: chartSnapshotId,
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

  CoverageSeriesHead _head(LifeEventCoverageSeriesHeadRow r) {
    return CoverageSeriesHead(
      coverageSeriesId: r.coverageSeriesId,
      ownerScopeId: r.ownerScopeId,
      profileId: r.profileId,
      chartSnapshotId: r.chartSnapshotId,
      providerId: r.providerId,
      eventTypeId: r.eventTypeId,
      seriesRevision: r.seriesRevision,
      activeCoverageId: r.activeCoverageId,
      candidateCoverageId: r.candidateCoverageId,
      desiredRange: _rangeFrom(r.desiredRangeStartMs, r.desiredRangeEndMs),
    );
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

  String _encodePageToken(int startMs, int rank, String projectionId) {
    return base64Url.encode(utf8.encode('$startMs:$rank:$projectionId'));
  }

  (int, int, String)? _decodePageToken(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final str = utf8.decode(base64Url.decode(token));
      final parts = str.split(':');
      if (parts.length < 3) return null;
      return (int.parse(parts[0]), int.parse(parts[1]), parts.sublist(2).join(':'));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _projectionToJson(EventProjection p) => {
        'projectionId': p.projectionId,
        'projectionIdAlgorithmVersion': p.projectionIdAlgorithmVersion,
        'coverageId': p.coverageId,
        'coverageGeneration': p.coverageGeneration,
        'sourceRef': {
          'providerId': p.sourceRef.providerId,
          'sourceEventId': p.sourceRef.sourceEventId,
          'eventRevision': p.sourceRef.eventRevision,
        },
        'ownerScopeId': p.ownerScopeId,
        'subjectId': p.subjectId,
        'profileId': p.profileId,
        'chartSnapshotId': p.chartSnapshotId,
        'divinationTypeKey': p.divinationTypeKey,
        'subDivinationTypeKey': p.subDivinationTypeKey,
        'eventTypeId': p.eventTypeId,
        'eventTime': _timeToJson(p.eventTime),
        'projectedParticipants': p.projectedParticipants.map(_participantToJson).toList(),
        'projectedFactValues': p.projectedFactValues.map(_scalarToJson).toList(),
        'factSummary': p.factSummary,
        'evidenceRef': p.evidenceRef,
        'astronomyEventRef': p.astronomyEventRef == null ? null : {
          'astronomyProviderId': p.astronomyEventRef!.astronomyProviderId,
          'datasetProfileId': p.astronomyEventRef!.datasetProfileId,
          'bodyId': p.astronomyEventRef!.bodyId,
          'astronomyEventId': p.astronomyEventRef!.astronomyEventId,
          'dataVersion': p.astronomyEventRef!.dataVersion,
        },
        'astronomyEvidenceRef': p.astronomyEvidenceRef == null ? null : {
          'astronomyProviderId': p.astronomyEvidenceRef!.astronomyProviderId,
          'evidenceId': p.astronomyEvidenceRef!.evidenceId,
          'evidenceRevision': p.astronomyEvidenceRef!.evidenceRevision,
          'evidenceSchemaId': p.astronomyEvidenceRef!.evidenceSchemaId,
          'schemaVersion': p.astronomyEvidenceRef!.schemaVersion,
        },
        'profileMatchEvidenceRef': p.profileMatchEvidenceRef == null ? null : {
          'providerId': p.profileMatchEvidenceRef!.providerId,
          'evidenceId': p.profileMatchEvidenceRef!.evidenceId,
          'evidenceRevision': p.profileMatchEvidenceRef!.evidenceRevision,
          'evidenceSchemaId': p.profileMatchEvidenceRef!.evidenceSchemaId,
          'schemaVersion': p.profileMatchEvidenceRef!.schemaVersion,
        },
        'sourceSeverityRef': p.sourceSeverityRef == null ? null : {
          'providerId': p.sourceSeverityRef!.providerId,
          'schemeId': p.sourceSeverityRef!.schemeId,
          'schemeVersion': p.sourceSeverityRef!.schemeVersion,
          'code': p.sourceSeverityRef!.code,
        },
        'sourceVersions': {
          'providerVersion': p.sourceVersions.providerVersion,
          'algorithmVersion': p.sourceVersions.algorithmVersion,
          'ruleVersion': p.sourceVersions.ruleVersion,
          'dataVersion': p.sourceVersions.dataVersion,
        },
        'projectionLifecycleStatus': p.projectionLifecycleStatus.index,
        'indexedAtMs': p.indexedAt.millisecondsSinceEpoch,
      };

  Map<String, dynamic> _timeToJson(LifeEventTime t) {
    if (t is InstantTime) {
      return {
        'kind': 'instant',
        'startMs': t.effectiveStartUtc.millisecondsSinceEpoch,
        'instantMs': t.instantUtc.millisecondsSinceEpoch,
        'tz': t.calculationTimezoneId,
        'precision': t.precision.index,
      };
    } else if (t is IntervalTime) {
      return {
        'kind': 'interval',
        'startMs': t.effectiveStartUtc.millisecondsSinceEpoch,
        'startIncMs': t.startInclusiveUtc.millisecondsSinceEpoch,
        'endExcMs': t.endExclusiveUtc.millisecondsSinceEpoch,
        'tz': t.calculationTimezoneId,
        'precision': t.precision.index,
      };
    } else if (t is CivilSpanTime) {
      return {
        'kind': 'civilSpan',
        'startMs': t.effectiveStartUtc.millisecondsSinceEpoch,
        'startCivilMs': t.startCivilInclusive.millisecondsSinceEpoch,
        'endCivilMs': t.endCivilExclusive.millisecondsSinceEpoch,
        'calendarSystem': t.calendarSystem,
        'tz': t.timezoneId,
        'precision': t.precision.index,
      };
    }
    return {
      'kind': 'instant',
      'startMs': t.effectiveStartUtc.millisecondsSinceEpoch,
      'instantMs': t.effectiveStartUtc.millisecondsSinceEpoch,
      'tz': 'UTC',
      'precision': TimePrecision.second.index,
    };
  }

  Map<String, dynamic> _participantToJson(EventParticipant p) => {
        'roleId': p.roleId,
        'participantKind': p.participantKind,
        'participantId': p.participantId,
        'displayNameKey': p.displayNameKey,
        'attributes': p.attributes.map(_scalarToJson).toList(),
      };

  Map<String, dynamic> _scalarToJson(TypedScalar s) {
    if (s is TextScalar) {
      return {'k': 'text', 'f': s.fieldId, 'v': s.value, 's': s.schemaVersion};
    } else if (s is NumberScalar) {
      return {'k': 'num', 'f': s.fieldId, 'v': s.value, 's': s.schemaVersion};
    } else if (s is BooleanScalar) {
      return {'k': 'bool', 'f': s.fieldId, 'v': s.value, 's': s.schemaVersion};
    } else if (s is EnumScalar) {
      return {'k': 'enum', 'f': s.fieldId, 'c': s.code, 'cv': s.catalogVersion, 's': s.schemaVersion};
    } else if (s is MultiEnumScalar) {
      return {'k': 'menum', 'f': s.fieldId, 'c': s.codes, 'cv': s.catalogVersion, 's': s.schemaVersion};
    } else if (s is UnknownScalar) {
      return {'k': 'unk', 'f': s.fieldId, 'r': s.rawEncoded, 's': s.schemaVersion};
    }
    return {'k': 'unk', 'f': s.fieldId, 'r': '', 's': s.schemaVersion};
  }

  EventProjection _rowToProjection(LifeEventProjectionRow row) {
    Map<String, dynamic>? json;
    if (row.projectionJson.isNotEmpty) {
      try {
        json = jsonDecode(row.projectionJson) as Map<String, dynamic>?;
      } catch (_) {}
    }

    final status = ProjectionLifecycleStatus.values[row.lifecycleStatus];
    final indexedAt = json?['indexedAtMs'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json!['indexedAtMs'] as int, isUtc: true)
        : DateTime.now().toUtc();

    final sourceRef = json?['sourceRef'] != null
        ? SourceRef(
            providerId: json!['sourceRef']['providerId'] as String,
            sourceEventId: json['sourceRef']['sourceEventId'] as String,
            eventRevision: json['sourceRef']['eventRevision'] as String,
          )
        : SourceRef(
            providerId: row.sourceProviderId,
            sourceEventId: row.sourceEventId,
            eventRevision: row.eventRevision,
          );

    final eventTime = json?['eventTime'] != null
        ? _timeFromJson(json!['eventTime'] as Map<String, dynamic>)
        : InstantTime(
            effectiveStartUtc: DateTime.fromMillisecondsSinceEpoch(row.effectiveStartMs, isUtc: true),
            instantUtc: DateTime.fromMillisecondsSinceEpoch(row.effectiveStartMs, isUtc: true),
            calculationTimezoneId: 'UTC',
            precision: TimePrecision.values[row.precisionRank],
          );

    final participants = (json?['projectedParticipants'] as List<dynamic>?)
            ?.map((e) => _participantFromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final factValues = (json?['projectedFactValues'] as List<dynamic>?)
            ?.map((e) => _scalarFromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final sourceVersions = json?['sourceVersions'] != null
        ? SourceVersions(
            providerVersion: json!['sourceVersions']['providerVersion'] as String,
            algorithmVersion: json['sourceVersions']['algorithmVersion'] as String,
            ruleVersion: json['sourceVersions']['ruleVersion'] as String?,
            dataVersion: json['sourceVersions']['dataVersion'] as String?,
          )
        : const SourceVersions(
            providerVersion: '1.0.0',
            algorithmVersion: 'algo-1',
            ruleVersion: null,
            dataVersion: null,
          );

    return EventProjection(
      projectionId: row.projectionId,
      projectionIdAlgorithmVersion: json?['projectionIdAlgorithmVersion'] as String? ?? 'v1',
      coverageId: row.coverageId,
      coverageGeneration: row.coverageGeneration,
      sourceRef: sourceRef,
      ownerScopeId: row.ownerScopeId,
      subjectId: row.subjectId,
      profileId: row.profileId,
      chartSnapshotId: row.chartSnapshotId,
      divinationTypeKey: row.divinationTypeKey,
      subDivinationTypeKey: row.subDivinationTypeKey,
      eventTypeId: row.eventTypeId,
      eventTime: eventTime,
      projectedParticipants: participants,
      projectedFactValues: factValues,
      factSummary: json?['factSummary'] as String? ?? '',
      evidenceRef: json?['evidenceRef'] as String? ?? '',
      astronomyEventRef: json?['astronomyEventRef'] != null
          ? AstronomyEventRef(
              astronomyProviderId: json!['astronomyEventRef']['astronomyProviderId'] as String,
              datasetProfileId: json['astronomyEventRef']['datasetProfileId'] as String,
              bodyId: json['astronomyEventRef']['bodyId'] as String,
              astronomyEventId: json['astronomyEventRef']['astronomyEventId'] as String,
              dataVersion: json['astronomyEventRef']['dataVersion'] as String? ?? 'v1',
            )
          : null,
      astronomyEvidenceRef: json?['astronomyEvidenceRef'] != null
          ? AstronomyEvidenceRef(
              astronomyProviderId: json!['astronomyEvidenceRef']['astronomyProviderId'] as String,
              evidenceId: json['astronomyEvidenceRef']['evidenceId'] as String,
              evidenceRevision: json['astronomyEvidenceRef']['evidenceRevision'] as String,
              evidenceSchemaId: json['astronomyEvidenceRef']['evidenceSchemaId'] as String,
              schemaVersion: json['astronomyEvidenceRef']['schemaVersion'] as String,
            )
          : null,
      profileMatchEvidenceRef: json?['profileMatchEvidenceRef'] != null
          ? ProfileMatchEvidenceRef(
              providerId: json!['profileMatchEvidenceRef']['providerId'] as String,
              evidenceId: json['profileMatchEvidenceRef']['evidenceId'] as String,
              evidenceRevision: json['profileMatchEvidenceRef']['evidenceRevision'] as String,
              evidenceSchemaId: json['profileMatchEvidenceRef']['evidenceSchemaId'] as String,
              schemaVersion: json['profileMatchEvidenceRef']['schemaVersion'] as String,
            )
          : null,
      sourceSeverityRef: json?['sourceSeverityRef'] != null
          ? SourceSeverityRef(
              providerId: json!['sourceSeverityRef']['providerId'] as String,
              schemeId: json['sourceSeverityRef']['schemeId'] as String,
              schemeVersion: json['sourceSeverityRef']['schemeVersion'] as String,
              code: json['sourceSeverityRef']['code'] as String,
            )
          : null,
      sourceVersions: sourceVersions,
      projectionLifecycleStatus: status,
      indexedAt: indexedAt,
    );
  }

  LifeEventTime _timeFromJson(Map<String, dynamic> m) {
    final kind = m['kind'] as String;
    final startUtc = DateTime.fromMillisecondsSinceEpoch(m['startMs'] as int, isUtc: true);
    final prec = TimePrecision.values[m['precision'] as int];
    final tz = m['tz'] as String? ?? 'UTC';

    if (kind == 'interval') {
      return IntervalTime(
        effectiveStartUtc: startUtc,
        startInclusiveUtc: DateTime.fromMillisecondsSinceEpoch(m['startIncMs'] as int, isUtc: true),
        endExclusiveUtc: DateTime.fromMillisecondsSinceEpoch(m['endExcMs'] as int, isUtc: true),
        calculationTimezoneId: tz,
        precision: prec,
      );
    } else if (kind == 'civilSpan') {
      return CivilSpanTime(
        effectiveStartUtc: startUtc,
        startCivilInclusive: DateTime.fromMillisecondsSinceEpoch(m['startCivilMs'] as int, isUtc: true),
        endCivilExclusive: DateTime.fromMillisecondsSinceEpoch(m['endCivilMs'] as int, isUtc: true),
        calendarSystem: m['calendarSystem'] as String? ?? 'gregorian',
        timezoneId: tz,
        precision: prec,
      );
    }
    return InstantTime(
      effectiveStartUtc: startUtc,
      instantUtc: DateTime.fromMillisecondsSinceEpoch(m['instantMs'] as int? ?? m['startMs'] as int, isUtc: true),
      calculationTimezoneId: tz,
      precision: prec,
    );
  }

  EventParticipant _participantFromJson(Map<String, dynamic> m) => EventParticipant(
        roleId: m['roleId'] as String,
        participantKind: m['participantKind'] as String,
        participantId: m['participantId'] as String,
        displayNameKey: m['displayNameKey'] as String?,
        attributes: (m['attributes'] as List<dynamic>?)
                ?.map((a) => _scalarFromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  TypedScalar _scalarFromJson(Map<String, dynamic> json) {
    final k = json['k'] as String;
    final f = json['f'] as String;
    final s = json['s'] as String;
    switch (k) {
      case 'text':
        return TextScalar(fieldId: f, schemaVersion: s, value: json['v'] as String);
      case 'num':
        return NumberScalar(fieldId: f, schemaVersion: s, value: json['v'] as num);
      case 'bool':
        return BooleanScalar(fieldId: f, schemaVersion: s, value: json['v'] as bool);
      case 'enum':
        return EnumScalar(fieldId: f, schemaVersion: s, code: json['c'] as String, catalogVersion: json['cv'] as String);
      case 'menum':
        return MultiEnumScalar(fieldId: f, schemaVersion: s, codes: (json['c'] as List).cast<String>(), catalogVersion: json['cv'] as String);
      default:
        return UnknownScalar(fieldId: f, schemaVersion: s, rawEncoded: json['r'] as String? ?? '');
    }
  }

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