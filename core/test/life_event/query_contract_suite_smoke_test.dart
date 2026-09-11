// ACT-05A-S: 查询共享合同套件冒烟测试（In-Memory 参考实现验证）
import 'dart:async';
import 'dart:convert';

import 'package:persistence_core/life_event/life_event_dtos.dart';
import 'package:persistence_core/life_event/life_event_ports.dart';
import 'package:persistence_core/test_support/life_event_query_contract_suite.dart';

int _precisionRank(LifeEventTime t) {
  if (t is InstantTime) return t.precision.index;
  if (t is IntervalTime) return t.precision.index;
  if (t is CivilSpanTime) return t.precision.index;
  return 0;
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

final class _MinimalInMemoryStorage
    implements
        LifeEventCoverageGenerationPort,
        LifeEventShardCommitPort,
        LifeEventProjectionQueryPort,
        LifeEventCoverageQueryPort {
  final Map<String, CoverageSeriesHead> _heads = {};
  final Map<String, CoverageManifest> _manifests = {};
  final Map<String, ShardReceipt> _receipts = {};
  final Map<String, EventProjection> _projections = {};

  @override
  Future<CreateCoverageGenerationResult> createOrReplaceCandidate(
    CreateCoverageGenerationRequest request,
  ) async {
    final head = _heads[request.coverageSeriesId];
    if (head != null && head.seriesRevision != request.expectedSeriesRevision) {
      return CreateCoverageGenerationResult(
        outcome: CreateCoverageGenerationOutcome.seriesRevisionConflict,
        coverageId: null,
        coverageGeneration: null,
        seriesRevision: head.seriesRevision,
        activeCoverageId: head.activeCoverageId,
        candidateCoverageId: head.candidateCoverageId,
        desiredRange: head.desiredRange,
      );
    }
    final shrinks = head != null &&
        (request.desiredRange.startInclusiveUtc.isAfter(head.desiredRange.startInclusiveUtc) ||
            request.desiredRange.endExclusiveUtc.isBefore(head.desiredRange.endExclusiveUtc));
    if (shrinks) {
      return CreateCoverageGenerationResult(
        outcome: CreateCoverageGenerationOutcome.rangeShrinkUnsupported,
        coverageId: null,
        coverageGeneration: null,
        seriesRevision: head.seriesRevision,
        activeCoverageId: head.activeCoverageId,
        candidateCoverageId: head.candidateCoverageId,
        desiredRange: head.desiredRange,
      );
    }

    final seriesRevision = (head?.seriesRevision ?? 0) + 1;
    final coverageId = 'cov-${request.coverageSeriesId}-$seriesRevision';
    final newHead = CoverageSeriesHead(
      coverageSeriesId: request.coverageSeriesId,
      ownerScopeId: head?.ownerScopeId ?? '',
      profileId: head?.profileId ?? '',
      chartSnapshotId: request.chartSnapshotId,
      providerId: request.providerId,
      eventTypeId: request.eventTypeId,
      seriesRevision: seriesRevision,
      activeCoverageId: head?.activeCoverageId,
      candidateCoverageId: coverageId,
      desiredRange: request.desiredRange,
    );
    _heads[request.coverageSeriesId] = newHead;

    return CreateCoverageGenerationResult(
      outcome: CreateCoverageGenerationOutcome.created,
      coverageId: coverageId,
      coverageGeneration: seriesRevision,
      seriesRevision: seriesRevision,
      activeCoverageId: head?.activeCoverageId,
      candidateCoverageId: coverageId,
      desiredRange: request.desiredRange,
    );
  }

  @override
  Future<CommitValidatedShardResult> commitValidatedShard(
    CommitValidatedShardRequest request,
  ) async {
    final receiptKey = '${request.coverageId}\u0000${request.receiptIdentity.shardId}';
    final existingReceipt = _receipts[receiptKey];
    if (existingReceipt != null) {
      if (existingReceipt.contentDigest == request.contentDigest) {
        return CommitValidatedShardResult(
          outcome: CommitValidatedShardOutcome.idempotentReplay,
          manifestRevision: _manifests[request.coverageId]?.manifestRevision ?? 0,
          coverageGeneration: request.coverageGeneration,
          seriesRevision: 0,
          activeCoverageId: null,
          receiptIdentity: request.receiptIdentity,
          persistedCount: existingReceipt.persistedCount,
          persistedDigest: existingReceipt.persistedDigest,
          coverageStatus: CoverageStatus.complete,
          servingState: ServingState.active,
          completedShardCount: 1,
          expectedShardCount: 1,
        );
      }
      return CommitValidatedShardResult(
        outcome: CommitValidatedShardOutcome.receiptDigestConflict,
        manifestRevision: 0,
        coverageGeneration: request.coverageGeneration,
        seriesRevision: 0,
        activeCoverageId: null,
        receiptIdentity: request.receiptIdentity,
        persistedCount: 0,
        persistedDigest: '',
        coverageStatus: CoverageStatus.failed,
        servingState: ServingState.candidate,
        completedShardCount: 0,
        expectedShardCount: 0,
      );
    }

    final manifest = _manifests[request.coverageId];
    final currentRevision = manifest?.manifestRevision ?? 0;
    if (request.expectedManifestRevision != currentRevision) {
      return CommitValidatedShardResult(
        outcome: CommitValidatedShardOutcome.revisionConflict,
        manifestRevision: currentRevision,
        coverageGeneration: request.coverageGeneration,
        seriesRevision: 0,
        activeCoverageId: null,
        receiptIdentity: request.receiptIdentity,
        persistedCount: 0,
        persistedDigest: '',
        coverageStatus: CoverageStatus.failed,
        servingState: ServingState.candidate,
        completedShardCount: 0,
        expectedShardCount: 0,
      );
    }

    CoverageSeriesHead? head;
    for (final h in _heads.values) {
      if (h.candidateCoverageId == request.coverageId || h.activeCoverageId == request.coverageId) {
        head = h;
        break;
      }
    }

    final isComplete = request.requestedCoverageTransition == CoverageTransition.complete;
    if (isComplete && head != null) {
      final headMatches = head.candidateCoverageId == request.expectedCandidateCoverageId &&
          head.seriesRevision == request.expectedSeriesRevision;
      if (!headMatches) {
        return CommitValidatedShardResult(
          outcome: CommitValidatedShardOutcome.activeSwitchConflict,
          manifestRevision: currentRevision,
          coverageGeneration: request.coverageGeneration,
          seriesRevision: head.seriesRevision,
          activeCoverageId: head.activeCoverageId,
          receiptIdentity: request.receiptIdentity,
          persistedCount: 0,
          persistedDigest: '',
          coverageStatus: CoverageStatus.failed,
          servingState: ServingState.candidate,
          completedShardCount: 0,
          expectedShardCount: 0,
        );
      }
    }

    // 写入 projections
    final firstProj = request.projections.isNotEmpty ? request.projections.first : null;
    for (final p in request.projections) {
      _projections[p.projectionId] = p;
    }

    // 写入 receipt
    _receipts[receiptKey] = ShardReceipt(
      coverageId: request.coverageId,
      shardId: request.receiptIdentity.shardId,
      coverageGeneration: request.coverageGeneration,
      requestedRange: request.requestedRange,
      coveredRange: request.coveredRange,
      eventCount: request.eventCount,
      contentDigest: request.contentDigest,
      persistedCount: request.projections.length,
      persistedDigest: request.contentDigest,
      isCompleteForCoveredRange: request.isCompleteForCoveredRange,
      inputFingerprint: request.inputFingerprint,
      committedAt: DateTime.now().toUtc(),
    );

    // 更新 head 的 ownerScopeId 与 profileId
    if (head != null && firstProj != null) {
      head = CoverageSeriesHead(
        coverageSeriesId: head.coverageSeriesId,
        ownerScopeId: head.ownerScopeId.isNotEmpty ? head.ownerScopeId : firstProj.ownerScopeId,
        profileId: head.profileId.isNotEmpty ? head.profileId : firstProj.profileId,
        chartSnapshotId: head.chartSnapshotId,
        providerId: head.providerId,
        eventTypeId: head.eventTypeId,
        seriesRevision: head.seriesRevision,
        activeCoverageId: head.activeCoverageId,
        candidateCoverageId: head.candidateCoverageId,
        desiredRange: head.desiredRange,
      );
      _heads[head.coverageSeriesId] = head;
    }

    // 更新 manifest
    final updatedManifest = CoverageManifest(
      coverageId: request.coverageId,
      coverageSeriesId: head?.coverageSeriesId ?? manifest?.coverageSeriesId ?? '',
      coverageGeneration: request.coverageGeneration,
      manifestRevision: currentRevision + 1,
      servingState: isComplete ? ServingState.active : ServingState.candidate,
      profileId: head?.profileId ?? firstProj?.profileId ?? '',
      chartSnapshotId: head?.chartSnapshotId ?? request.inputFingerprint,
      chartSnapshotRevision: 'v1',
      providerId: request.providerId,
      providerVersion: request.providerVersion,
      algorithmVersion: request.algorithmVersion,
      dataVersion: request.dataVersion,
      eventTypeId: request.eventTypeId,
      eventTypeSchemaVersion: request.eventTypeSchemaVersion,
      capabilityDescriptorVersion: '',
      capabilityDigest: '',
      requestedRange: request.requestedRange,
      coveredRanges: [request.coveredRange],
      status: isComplete ? CoverageStatus.complete : CoverageStatus.running,
      inputFingerprint: request.inputFingerprint,
      expectedShardCount: 1,
      completedShardCount: 1,
      sourceEventCount: request.eventCount,
      outputDigest: request.contentDigest,
      startedAt: manifest?.startedAt ?? DateTime.now().toUtc(),
      completedAt: isComplete ? DateTime.now().toUtc() : null,
      lastErrorCode: null,
    );
    _manifests[request.coverageId] = updatedManifest;

    if (isComplete && head != null) {
      final oldActiveId = head.activeCoverageId;
      if (oldActiveId != null && oldActiveId != request.coverageId) {
        final oldManifest = _manifests[oldActiveId];
        if (oldManifest != null) {
          _manifests[oldActiveId] = CoverageManifest(
            coverageId: oldManifest.coverageId,
            coverageSeriesId: oldManifest.coverageSeriesId,
            coverageGeneration: oldManifest.coverageGeneration,
            manifestRevision: oldManifest.manifestRevision,
            servingState: ServingState.historical,
            profileId: oldManifest.profileId,
            chartSnapshotId: oldManifest.chartSnapshotId,
            chartSnapshotRevision: oldManifest.chartSnapshotRevision,
            providerId: oldManifest.providerId,
            providerVersion: oldManifest.providerVersion,
            algorithmVersion: oldManifest.algorithmVersion,
            dataVersion: oldManifest.dataVersion,
            eventTypeId: oldManifest.eventTypeId,
            eventTypeSchemaVersion: oldManifest.eventTypeSchemaVersion,
            capabilityDescriptorVersion: oldManifest.capabilityDescriptorVersion,
            capabilityDigest: oldManifest.capabilityDigest,
            requestedRange: oldManifest.requestedRange,
            coveredRanges: oldManifest.coveredRanges,
            status: oldManifest.status,
            inputFingerprint: oldManifest.inputFingerprint,
            expectedShardCount: oldManifest.expectedShardCount,
            completedShardCount: oldManifest.completedShardCount,
            sourceEventCount: oldManifest.sourceEventCount,
            outputDigest: oldManifest.outputDigest,
            startedAt: oldManifest.startedAt,
            completedAt: oldManifest.completedAt,
            lastErrorCode: oldManifest.lastErrorCode,
          );
        }
      }
      _heads[head.coverageSeriesId] = CoverageSeriesHead(
        coverageSeriesId: head.coverageSeriesId,
        ownerScopeId: head.ownerScopeId,
        profileId: head.profileId,
        chartSnapshotId: head.chartSnapshotId,
        providerId: head.providerId,
        eventTypeId: head.eventTypeId,
        seriesRevision: head.seriesRevision,
        activeCoverageId: request.coverageId,
        candidateCoverageId: null,
        desiredRange: head.desiredRange,
      );
    }

    return CommitValidatedShardResult(
      outcome: CommitValidatedShardOutcome.applied,
      manifestRevision: updatedManifest.manifestRevision,
      coverageGeneration: request.coverageGeneration,
      seriesRevision: head?.seriesRevision ?? 0,
      activeCoverageId: head?.activeCoverageId,
      receiptIdentity: request.receiptIdentity,
      persistedCount: request.projections.length,
      persistedDigest: request.contentDigest,
      coverageStatus: updatedManifest.status,
      servingState: updatedManifest.servingState,
      completedShardCount: 1,
      expectedShardCount: 1,
    );
  }

  @override
  Future<ProjectionQueryPage> queryProjections(ProjectionStorageQuery request) async {
    if (request.sortKey != 'effectiveStart') {
      return const ProjectionQueryPage(items: [], nextPageToken: null);
    }

    // 匹配 heads
    final matchingHeads = _heads.values.where((h) {
      if (h.ownerScopeId != request.ownerScopeId) return false;
      if (request.profileIds.isNotEmpty && !request.profileIds.contains(h.profileId)) return false;
      if (request.chartSnapshotIds.isNotEmpty && !request.chartSnapshotIds.contains(h.chartSnapshotId)) return false;
      if (request.providerIds.isNotEmpty && !request.providerIds.contains(h.providerId)) return false;
      if (request.eventTypeIds.isNotEmpty && !request.eventTypeIds.contains(h.eventTypeId)) return false;
      return true;
    }).toList();

    final eligibleCoverageIds = <String>{};
    for (final h in matchingHeads) {
      if (h.activeCoverageId != null) {
        eligibleCoverageIds.add(h.activeCoverageId!);
      }
      if (request.includeHistoricalGenerations) {
        for (final m in _manifests.values) {
          if (m.coverageSeriesId == h.coverageSeriesId && m.servingState == ServingState.historical) {
            eligibleCoverageIds.add(m.coverageId);
          }
        }
      }
    }

    if (eligibleCoverageIds.isEmpty) {
      return const ProjectionQueryPage(items: [], nextPageToken: null);
    }

    final filtered = _projections.values.where((p) {
      if (p.ownerScopeId != request.ownerScopeId) return false;
      if (!eligibleCoverageIds.contains(p.coverageId)) return false;
      if (request.profileIds.isNotEmpty && !request.profileIds.contains(p.profileId)) return false;
      if (request.chartSnapshotIds.isNotEmpty && !request.chartSnapshotIds.contains(p.chartSnapshotId)) return false;
      if (request.providerIds.isNotEmpty && !request.providerIds.contains(p.sourceRef.providerId)) return false;
      if (request.eventTypeIds.isNotEmpty && !request.eventTypeIds.contains(p.eventTypeId)) return false;
      if (!request.includeWithdrawn && p.projectionLifecycleStatus == ProjectionLifecycleStatus.withdrawn) return false;

      // 时间范围相交（半开区间）
      final pStart = p.eventTime.effectiveStartUtc;
      final range = request.range;
      if (p.eventTime is IntervalTime) {
        final interval = p.eventTime as IntervalTime;
        if (!interval.startInclusiveUtc.isBefore(range.endExclusiveUtc)) return false;
        if (!interval.endExclusiveUtc.isAfter(range.startInclusiveUtc)) return false;
      } else {
        if (pStart.isBefore(range.startInclusiveUtc) || !pStart.isBefore(range.endExclusiveUtc)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Keyset 排序
    filtered.sort((a, b) {
      final aStart = a.eventTime.effectiveStartUtc.millisecondsSinceEpoch;
      final bStart = b.eventTime.effectiveStartUtc.millisecondsSinceEpoch;
      final startCmp = aStart.compareTo(bStart);
      if (startCmp != 0) return startCmp;

      final aRank = _precisionRank(a.eventTime);
      final bRank = _precisionRank(b.eventTime);
      final rankCmp = aRank.compareTo(bRank);
      if (rankCmp != 0) return rankCmp;

      return a.projectionId.compareTo(b.projectionId);
    });

    // Keyset 分页 token 过滤
    final decoded = _decodePageToken(request.pageToken);
    var candidateItems = filtered;
    if (decoded != null) {
      final (tMs, tRank, tId) = decoded;
      candidateItems = filtered.where((p) {
        final startMs = p.eventTime.effectiveStartUtc.millisecondsSinceEpoch;
        final rank = _precisionRank(p.eventTime);
        if (startMs > tMs) return true;
        if (startMs == tMs && rank > tRank) return true;
        if (startMs == tMs && rank == tRank && p.projectionId.compareTo(tId) > 0) return true;
        return false;
      }).toList();
    }

    final hasMore = candidateItems.length > request.pageSize;
    final pageItems = candidateItems.take(request.pageSize).toList();
    String? nextPageToken;
    if (hasMore && pageItems.isNotEmpty) {
      final last = pageItems.last;
      nextPageToken = _encodePageToken(
        last.eventTime.effectiveStartUtc.millisecondsSinceEpoch,
        _precisionRank(last.eventTime),
        last.projectionId,
      );
    }

    return ProjectionQueryPage(items: pageItems, nextPageToken: nextPageToken);
  }

  @override
  Future<CoverageStoragePage> queryCoverage(CoverageStorageQuery request) async {
    final matchingHeads = _heads.values.where((h) {
      if (h.ownerScopeId != request.ownerScopeId) return false;
      if (request.profileIds.isNotEmpty && !request.profileIds.contains(h.profileId)) return false;
      if (request.chartSnapshotIds.isNotEmpty && !request.chartSnapshotIds.contains(h.chartSnapshotId)) return false;
      if (request.providerIds.isNotEmpty && !request.providerIds.contains(h.providerId)) return false;
      if (request.eventTypeIds.isNotEmpty && !request.eventTypeIds.contains(h.eventTypeId)) return false;
      // desiredRange 相交
      if (!h.desiredRange.startInclusiveUtc.isBefore(request.range.endExclusiveUtc)) return false;
      if (!h.desiredRange.endExclusiveUtc.isAfter(request.range.startInclusiveUtc)) return false;
      return true;
    }).toList();

    final matchingManifests = <CoverageManifest>[];
    for (final h in matchingHeads) {
      if (h.activeCoverageId != null) {
        final activeM = _manifests[h.activeCoverageId];
        if (activeM != null) matchingManifests.add(activeM);
      }
      if (request.includeHistoricalGenerations) {
        for (final m in _manifests.values) {
          if (m.coverageSeriesId == h.coverageSeriesId && m.servingState == ServingState.historical) {
            matchingManifests.add(m);
          }
        }
      }
    }

    return CoverageStoragePage(heads: matchingHeads, manifests: matchingManifests);
  }
}

void main() {
  runLifeEventQueryContractSuite(
    makeStorage: () => _MinimalInMemoryStorage(),
  );
}
