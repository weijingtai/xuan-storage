import 'dart:convert';

import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'record_outbox_mapper.dart';

/// 本地回填器：把远端 [RemoteChange] 应用进本地 record 库，并接入
/// HLC 仲裁（ACT 09）与同事务戳写入（ACT 08）。
///
/// 【scope 绑定】：一个实例只服务一个 scope（[scopeUid] 进构造参数）。
/// 四个数据回调里的三个（applyRecord / deleteRecord / readLocalRecord）
/// 都锚在同一个按 scope 构造的 [DriftRecordDataSource] 上 ——
/// DriftRecordDataSource 构造时固定 scopeUid，三个方法全用实例字段过滤。
/// 跨 scope 复用已彻底删除：需要处理另一个 scope 就另建一个实例。
class RecordLocalApplier implements LocalApplier {
  /// 本 applier 绑定的 scope。**一个实例只服务一个 scope**。
  /// [applyRemoteChanges] 收到不同的 scopeUid 时【拒绝处理】。
  final String scopeUid;

  final Future<void> Function(RecordMeta meta, List<SearchTag> tags) applyRecord;
  final Future<bool> Function(String uuid) deleteRecord;

  /// 读本地实体是否存在。用于区分 local stamp == null 的两种现实
  /// （本地无实体 / 本地有实体但边表无戳）。返回 null 表示无实体。
  /// 与 applyRecord / deleteRecord 同源：都来自【同一个】
  /// 按 scopeUid 构造的 DriftRecordDataSource。
  final Future<RecordMeta?> Function(String uuid) readLocalRecord;

  /// 读本地 HLC 戳。转发 ACT 08 的 getEntityStamp，
  /// scopeUid 用【构造时绑定的那个】。边表无该行时返回 null。
  final Future<EntityStampRow?> Function(String entityId) readLocalStamp;

  /// 同事务写入。转发 ACT 08 的 applyWithStamp（A13 的生产落地点），
  /// scopeUid 用【构造时绑定的那个】。
  /// applier【不得】自己 transaction(...) 里分别写记录和戳。
  final Future<void> Function({
    required String entityType,
    required String entityId,
    required int hlcPacked,
    required String deviceId,
    required Future<void> Function() write,
  }) applyWithStamp;

  /// 冲突仲裁器。字段类型是抽象接口 [ConflictArbiter]（纯函数、无 IO），
  /// 生产实例化具体类 `const HlcConflictArbiter()`。
  final ConflictArbiter arbiter;

  /// 本设备 HLC 时钟（ACT 08）。每条带 hlcPacked 的入站变更在仲裁【之前】
  /// 必须 observe 它的戳（因果性：收一次别人的东西，自己的钟被顶上去一次）。
  /// 可空：未注入时钟的构造点跳过 observe（生产接入时传入真实时钟）。
  final HlcClock? clock;

  RecordLocalApplier({
    required this.scopeUid,
    required this.applyRecord,
    required this.deleteRecord,
    required this.readLocalRecord,
    required this.readLocalStamp,
    required this.applyWithStamp,
    required this.arbiter,
    this.clock,
  });

  // ignore: annotate_overrides — LocalApplier 未定义 canApply，此为扩展方法
  bool canApply(String entityType) => entityType == RecordOutboxMapper.entityType;

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    // scope 不匹配：调用方 bug，绝不能让游标推进，一条都不许应用。
    if (scopeUid != this.scopeUid) {
      return LocalApplyResult(
        canAdvanceCursor: false,
        appliedCount: 0,
        outcomes: const [],
        lastError: SyncError(
          code: SyncErrorCode.unknown,
          message: 'scope 不匹配: 调用方传 $scopeUid，applier 绑定 ${this.scopeUid}',
        ),
      );
    }

    if (entityType != RecordOutboxMapper.entityType) {
      return LocalApplyResult(
        canAdvanceCursor: false, appliedCount: 0, outcomes: const [], lastError: null,
      );
    }

    final outcomes = <ChangeApplyOutcome>[];
    var applied = 0;

    for (final change in changes) {
      // 每条带 hlcPacked 的变更，在仲裁【之前】调 clock.observe
      // —— 但 applier 不持有 clock 实例（那是 ACT 08 的 HlcClock）。
      // observe 的职责：ACT 08 要求"每一条入站变更都 observe"。
      // 这里通过 remote stamp 的构造触发语义：本 ACT 用 VersionStamp
      // 承载 Hlc，observe 由调用链中的时钟持有者负责（见 record_sync_e2e）。
      final remoteStamp = _remoteStampFrom(change);

      ChangeApplyOutcome? outcome;
      try {
        if (remoteStamp == null) {
          // 无戳的历史条目：走 fail-safe（keepLocal），但仍需读本地判断留档。
          outcome = await _applyStampless(change, scopeUid, entityType);
        } else {
          outcome = await _applyStamped(change, scopeUid, entityType, remoteStamp);
        }
      } catch (e) {
        outcome = ChangeApplyOutcome(
          operationId: change.operationId, entityType: entityType,
          entityId: change.entityId, decision: ChangeApplyDecision.failed,
          reason: SkipReasonCode.unknown, message: e.toString(),
        );
      }

      if (outcome.decision == ChangeApplyDecision.applied) {
        applied += 1;
      }
      outcomes.add(outcome);
    }

    // canAdvanceCursor：只要存在任何 failed 就不推进（宁可重拉，不可丢）。
    // skipped（已应用/更旧/仲裁 keepLocal）【不】阻止推进 —— 否则游标
    // 永远卡在第一个被仲裁拒绝的位置，同步彻底停摆。
    final firstFailed = outcomes.where(
      (o) => o.decision == ChangeApplyDecision.failed,
    );
    final hasFailed = firstFailed.isNotEmpty;
    return LocalApplyResult(
      canAdvanceCursor: !hasFailed,
      appliedCount: applied,
      outcomes: outcomes,
      lastError: hasFailed
          ? SyncError(
              code: SyncErrorCode.unknown,
              message: '${firstFailed.first.operationId}: ${firstFailed.first.message}',
            )
          : null,
    );
  }

  /// 构造远端 [VersionStamp]。
  ///
  /// 两者（hlcPacked / deviceId）都非空 → fromPacked；任一为空 → null
  /// （不是"补个默认值"）。remote=null 走 ACT 09 的 fail-safe 降级。
  VersionStamp? _remoteStampFrom(RemoteChange change) {
    final packed = change.hlcPacked;
    final deviceId = change.deviceId;
    if (packed == null || deviceId == null) return null;
    return VersionStamp.fromPacked(packed, deviceId);
  }

  /// 远端无戳：fail-safe 方向（keepLocal），但按本地实体是否存在决定留档。
  Future<ChangeApplyOutcome> _applyStampless(
    RemoteChange change,
    String scopeUid,
    String entityType,
  ) async {
    final localMeta = await readLocalRecord(change.entityId);
    if (localMeta == null) {
      // 本地无实体 → 直接应用，无冲突、无留档
      await _applyWrite(change, scopeUid, entityType);
      return ChangeApplyOutcome(
        operationId: change.operationId, entityType: entityType,
        entityId: change.entityId, decision: ChangeApplyDecision.applied,
        reason: null, message: null,
      );
    }
    // 本地有实体但远端无戳：不覆盖（fail-safe），丢弃的远端版本留档。
    return ChangeApplyOutcome(
      operationId: change.operationId, entityType: entityType,
      entityId: change.entityId, decision: ChangeApplyDecision.skipped,
      reason: SkipReasonCode.olderThanLocal,
      message: 'remote 无 HLC 戳（历史条目），本地已有版本，保留本地',
      discardedSide: ConflictSide.remote,
      discardedPayloadJson: change.payloadJson,
      discardedStamp: null,
    );
  }

  /// 远端有戳：读本地实体 + 本地戳 → 仲裁 → 按结果应用或丢弃。
  Future<ChangeApplyOutcome> _applyStamped(
    RemoteChange change,
    String scopeUid,
    String entityType,
    VersionStamp remoteStamp,
  ) async {
    // 每条带 hlcPacked 的入站变更，在仲裁【之前】observe 它的戳 ——
    // 因果性：本地时钟被顶上去，下次本地写入的戳才大于刚收到的远端戳。
    // 漏调不报错，只让因果性静默消失（ACT 08 属性测试 + 本 ACT 的
    // observe_called_on_every_stamped_inbound_change 守着）。
    final clock = this.clock;
    if (clock != null) {
      await clock.observe(remoteStamp.hlc);
    }

    final localMeta = await readLocalRecord(change.entityId);
    final localStampRow = await readLocalStamp(change.entityId);

    VersionStamp? localStamp;
    if (localStampRow != null) {
      localStamp = VersionStamp.fromPacked(localStampRow.hlcPacked, localStampRow.deviceId);
    }

    final decision = arbiter.arbitrate(remote: remoteStamp, local: localStamp);

    switch (decision) {
      case ArbitrationDecision.takeRemote:
        final overwrittenPayload = localMeta == null
            ? null
            : jsonEncode(RecordOutboxMapper.metaToJson(localMeta));
        // 本地有实体（可能是 S1b 之前的历史数据）→ 留档；本地无实体 → 不留档。
        final discardedSide = localMeta == null ? null : ConflictSide.local;
        await _applyWrite(change, scopeUid, entityType);
        return ChangeApplyOutcome(
          operationId: change.operationId, entityType: entityType,
          entityId: change.entityId, decision: ChangeApplyDecision.applied,
          reason: null, message: null,
          discardedSide: discardedSide,
          discardedPayloadJson: overwrittenPayload,
          discardedStamp: localStamp,
        );
      case ArbitrationDecision.keepLocal:
        return ChangeApplyOutcome(
          operationId: change.operationId, entityType: entityType,
          entityId: change.entityId, decision: ChangeApplyDecision.skipped,
          reason: SkipReasonCode.conflictLwwLost,
          message: '仲裁判 keepLocal：本地版本较新，丢弃远端变更',
          discardedSide: ConflictSide.remote,
          discardedPayloadJson: change.payloadJson,
          discardedStamp: remoteStamp,
        );
      case ArbitrationDecision.identical:
        return ChangeApplyOutcome(
          operationId: change.operationId, entityType: entityType,
          entityId: change.entityId, decision: ChangeApplyDecision.skipped,
          reason: SkipReasonCode.alreadyApplied,
          message: '与本地版本相同，无需写入',
        );
    }
  }

  /// 走 ACT 08 的同事务接口写记录 + 戳（A13）。
  ///
  /// 远端【有戳】时用 applyWithStamp（记录与戳同事务落盘）；
  /// 远端【无戳】时只写记录不写边表戳（"没有戳"和"戳很小"是两回事，
  /// 不得把 null 补成 0 —— VERIFICATION 有相应禁令）。
  Future<void> _applyWrite(
    RemoteChange change,
    String scopeUid,
    String entityType,
  ) async {
    final packed = change.hlcPacked;
    final deviceId = change.deviceId;
    final hasStamp = packed != null && deviceId != null;

    if (change.opType == RecordOutboxMapper.opDelete) {
      if (hasStamp) {
        await applyWithStamp(
          entityType: entityType,
          entityId: change.entityId,
          hlcPacked: packed,
          deviceId: deviceId,
          write: () => deleteRecord(change.entityId),
        );
      } else {
        await deleteRecord(change.entityId);
      }
      return;
    }

    final payload = jsonDecode(change.payloadJson) as Map<String, dynamic>;
    final meta = _parseMeta(payload['meta'] as Map<String, dynamic>, scopeUid);
    final tags = _parseTags(payload['searchTags'] as List<dynamic>?);

    if (hasStamp) {
      await applyWithStamp(
        entityType: entityType,
        entityId: change.entityId,
        hlcPacked: packed,
        deviceId: deviceId,
        write: () => applyRecord(meta, tags),
      );
    } else {
      await applyRecord(meta, tags);
    }
  }

  RecordMeta _parseMeta(Map<String, dynamic> json, String scopeUid) {
    return RecordMeta(
      uuid: json['uuid'] as String,
      scopeUid: scopeUid,
      module: json['module'] as String,
      category: json['category'] as String,
      divinationType: json['divinationType'] as String,
      caseUuid: json['caseUuid'] as String?,
      workItemUuid: json['workItemUuid'] as String?,
      seekerUuid: json['seekerUuid'] as String?,
      question: json['question'] as String?,
      detail: json['detail'] as String?,
      tag: json['tag'] as String?,
      directPredict: json['directPredict'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      seekerName: json['seekerName'] as String?,
      gender: json['gender'] as String?,
      fateYear: json['fateYear'] as String?,
      occurredAtUtc: json['occurredAtUtc'] != null ? DateTime.parse(json['occurredAtUtc'] as String) : null,
      reckoningType: json['reckoningType'] as String?,
      timezoneStr: json['timezoneStr'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      spacetimeJson: json['spacetimeJson'] as String?,
      moduleDataJson: json['moduleDataJson'] as String?,
      navParamsJson: json['navParamsJson'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      rev: json['rev'] as int? ?? 1,
    );
  }

  List<SearchTag> _parseTags(List<dynamic>? list) {
    if (list == null) return const [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return SearchTag(m['key'] as String, m['value'] as String);
    }).toList();
  }
}
