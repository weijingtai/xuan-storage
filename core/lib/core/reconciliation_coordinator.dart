/// S1c 全量对齐编排器（ACT-D）。
///
/// 四阶段消息序列（设计稿 §3.1 定稿）在【发起方】与【对端】两侧各有一个
/// 编排角色。本编排器把两侧的纯编排逻辑集中实现，传输与持久化全部经
/// 端口注入：
///
/// - 发起方（[reconcileAsInitiator]）：分片发本地清单，收对端比对后回传的
///   ②a 终态（落库）、处理 ②b 索求（读本地终态回 ②b'），最后发 ④ 游标确认。
/// - 应答方（[handleRemoteManifest]）：收到发起方的清单分片后跑双遍历比对，
///   发 ②a 终态 / ②b 索求；收到对方回应的 ②b' 终态时落库。
///
/// ⚠ 本编排器不持有传输：channel 底层收到 reconciliation 流上的消息后，
/// 按消息类型把 [ManifestChunk] 喂给 [handleRemoteManifest]、[EntityTerminal]
/// 喂给 [handleRemoteTerminals]、[EntityRequest] 喂给 [handleRemoteRequests]。
///
/// 【测试模式】契约测试（ACT-F）用「同步内存 channel + 双 fake」把两台
/// [ReconciliationCoordinator] 接成一次握手：发起方 `sendManifestChunk` →
/// channel 同步转发到应答方 `handleRemoteManifest` → 应答方回传 → channel
/// 同步转发回发起方。因 channel 同步，`reconcileAsInitiator` 返回时握手已
/// 全部完成，累积在 [_incomingResult] 里的结果即可作为本次运行结果。
///
/// 【会话并发】一次 reconcile 会话对应一个 (scopeUid, entityType)；同一
/// 编排器实例不应并发跑两次发起方会话（由上层 Serial 串行）。
library;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:persistence_core/model/reconciliation.dart';
import 'package:persistence_core/model/reconciliation_ports.dart';

/// 一次全量对齐（单个 (scopeUid, entityType)）的编排结果。
///
/// 除 [ReconciliationResult] 外补充本端【发出】的观测计数：
/// - [terminalsSent]：本端发出的终态条数（②a 或回应 ②b'）。
/// - [requestsSent]：本端发出的索求条数（②b）。
class ReconciliationRun {
  /// 构造一个 [ReconciliationRun]。
  const ReconciliationRun({
    required this.result,
    required this.terminalsSent,
    required this.requestsSent,
  });

  /// 落库汇总（对端终态过仲裁器 + 同事务写的结果）。
  final ReconciliationResult result;

  /// 本端发出的终态条数。
  final int terminalsSent;

  /// 本端发出的索求条数。
  final int requestsSent;
}

/// S1c 全量对齐编排器（发起方 + 应答方双角色）。
class ReconciliationCoordinator {
  /// 构造一个 [ReconciliationCoordinator]。
  ///
  /// 参数说明：
  /// - [source]：读本地 `t_entity_stamp` 生成清单分片。
  /// - [store]：读/写实体终态（回应索求时读本地终态）。
  /// - [channel]：与对端交换对齐消息的通道。
  /// - [comparator]：双遍历五类比对器（纯函数）。
  /// - [applier]：把对端终态过仲裁器 + 同事务落库。
  ReconciliationCoordinator({
    required ManifestSource source,
    required TerminalStore store,
    required RemoteTerminalChannel channel,
    required ManifestComparator comparator,
    required LocalReconciliationApplier applier,
  })  : _source = source,
        _store = store,
        _channel = channel,
        _comparator = comparator,
        _applier = applier;

  final ManifestSource _source;
  final TerminalStore _store;
  final RemoteTerminalChannel _channel;
  final ManifestComparator _comparator;
  final LocalReconciliationApplier _applier;

  /// 测试访问器：契约测试用它把本协调器的 channel 换成「同步握手」目标。
  @visibleForTesting
  RemoteTerminalChannel get channelForTest => _channel;

  // 本端在【收到对端消息】过程中累积的落库结果（②a / ②b' 的 applier 输出）。
  int _incomingRecords = 0;
  int _incomingConflicts = 0;
  int _terminalsSent = 0;
  int _requestsSent = 0;

  /// 以【发起方】角色跑一次全量对齐。
  ///
  /// 流程（设计稿 §3.1 线序的发起方侧）：
  /// 1. 分片发本地清单（chunkSeq 从 0 递增，直到 [ManifestSource] 返回空片
  ///    或单片不满 [manifestPageSize]）。
  /// 2. 对端收到全部清单后跑双遍历，回传 ②a 终态 / ②b 索求；本端
  ///    [handleRemoteTerminals] / [handleRemoteRequests] 逐条处理。
  /// 3. 最后发 ④ [CursorAdvance] 游标确认（recordsReconciled/blobsPending
  ///    用累积的对端落库结果填充）。
  ///
  /// 返回：本次运行的落库汇总 + 本端发出计数。发清单期间的收到消息经由
  /// channel 同步路由（测试模式）或异步路由（生产，由上层聚合结果）。
  Future<ReconciliationRun> reconcileAsInitiator({
    required String scopeUid,
    required String entityType,
    int manifestPageSize = 500,
  }) async {
    _resetCounters();

    // ① 分片发本地清单。
    var chunkSeq = 0;
    while (true) {
      final chunk = await _source.readManifestChunk(
        scopeUid: scopeUid,
        entityType: entityType,
        chunkSeq: chunkSeq,
        pageSize: manifestPageSize,
      );
      if (chunk == null) break;
      await _channel.sendManifestChunk(chunk);
      chunkSeq += 1;
      if (chunk.entries.length < manifestPageSize) break;
    }

    // ④ 游标确认：把「本端清单已全部发出」+「对端处理结果已收到」固化为
    // 本次运行的汇总。计数取累积值（对端落库结果 + 本端发出的终态/索求）。
    await _channel.sendCursorAdvance(CursorAdvance(
      scopeUid: scopeUid,
      entityType: entityType,
      recordsReconciled: _incomingRecords,
      blobsPending: 0,
    ));

    final result = ReconciliationResult(
      scopeUid: scopeUid,
      entityType: entityType,
      recordsReconciled: _incomingRecords,
      blobsPending: 0,
      conflictsLogged: _incomingConflicts,
    );
    return ReconciliationRun(
      result: result,
      terminalsSent: _terminalsSent,
      requestsSent: _requestsSent,
    );
  }

  /// 【应答方】处理收到的一片清单分片。
  ///
  /// 对端（应答方）收到发起方的清单后跑双遍历比对（设计稿 §3.1②）：
  /// - 【遍历自己清单】：
  ///   · 本地有 / 对方无 → 发 ②a 终态给对方。
  ///   · 双方都有，本地更新 → 发 ②a 终态给对方。
  ///   · 双方都有，对方更新 → 发 ②b 索求给对方。
  ///   · 版本相同 → 跳过。
  /// - 【遍历收到清单】本地无 / 对方有 → 发 ②b 索求（新设备入网核心路径）。
  ///
  /// 分片可能被切成多片；本方法处理单片。单片内只需本片 + 本地全量清单的
  /// 行——比对按行独立（每行只跟同一 entityId 的行比），无需跨片状态。
  Future<void> handleRemoteManifest(ManifestChunk chunk) async {
    // 本地清单（按 entityId 索引）。
    final localByEntityId = <String, ManifestEntry>{};
    var localSeq = 0;
    while (true) {
      final localChunk = await _source.readManifestChunk(
        scopeUid: chunk.scopeUid,
        entityType: chunk.entityType,
        chunkSeq: localSeq,
        pageSize: 500,
      );
      if (localChunk == null) break;
      for (final e in localChunk.entries) {
        localByEntityId[e.entityId] = e;
      }
      localSeq += 1;
      if (localChunk.entries.length < 500) break;
    }

    final terminalsToSend = <EntityTerminal>[];
    final requestsToSend = <EntityRequest>[];

    // 【遍历自己清单】+ 收到的远端清单。
    for (final local in localByEntityId.values) {
      final remote = _findRemote(chunk, local.entityId);
      final decision = _comparator.classifyLocalEntry(
        local: local,
        remote: remote,
      );
      switch (decision) {
        case ManifestComparatorDecision.sendTerminal:
          final terminal = await _store.readTerminal(
            scopeUid: chunk.scopeUid,
            entityType: chunk.entityType,
            entityId: local.entityId,
          );
          if (terminal != null) terminalsToSend.add(terminal);
        case ManifestComparatorDecision.requestTerminal:
          requestsToSend.add(EntityRequest(
            scopeUid: chunk.scopeUid,
            entityType: chunk.entityType,
            entityId: local.entityId,
          ));
        case ManifestComparatorDecision.skip:
          break;
      }
    }

    // 【遍历收到清单】本地无 / 对方有 → 索求（新设备入网核心路径）。
    for (final remote in chunk.entries) {
      if (localByEntityId.containsKey(remote.entityId)) continue;
      requestsToSend.add(EntityRequest(
        scopeUid: chunk.scopeUid,
        entityType: chunk.entityType,
        entityId: remote.entityId,
      ));
    }

    if (terminalsToSend.isNotEmpty) {
      await _channel.sendTerminals(terminalsToSend);
      _terminalsSent += terminalsToSend.length;
    }
    if (requestsToSend.isNotEmpty) {
      await _channel.requestTerminals(requestsToSend);
      _requestsSent += requestsToSend.length;
    }
  }

  /// 【应答方】处理收到的终态（②a 来自对端主动，或 ②b' 回应本端索求）。
  ///
  /// 两种来源的终态【同一路径落库】：对端发来的终态视为「对端认为你应该
  /// 拥有的状态」，一律过 [applier]（内含仲裁 + 同事务写），保证「增量收过、
  /// 全量再收」语义一致。结果累积进 [ReconciliationResult] 计数。
  Future<ReconciliationResult> handleRemoteTerminals({
    required String scopeUid,
    required String entityType,
    required List<EntityTerminal> terminals,
  }) async {
    final result = await _applier.applyTerminals(
      scopeUid: scopeUid,
      entityType: entityType,
      terminals: terminals,
    );
    _incomingRecords += result.recordsReconciled;
    _incomingConflicts += result.conflictsLogged;
    return result;
  }

  /// 【应答方】处理收到的索求（②b）：读本地终态并回 ②b' 终态。
  ///
  /// 对端索求「本地有 / 对端无」或「本地更新」的实体终态时，本端读本地
  /// 终态（含 payload）并回传。墓碑也回（isDeleted=true，无 payload）——
  /// 删除同样要传到对端（S1c §3.2① 定稿）。
  Future<void> handleRemoteRequests({
    required String scopeUid,
    required String entityType,
    required List<EntityRequest> requests,
  }) async {
    final terminals = <EntityTerminal>[];
    for (final req in requests) {
      final terminal = await _store.readTerminal(
        scopeUid: scopeUid,
        entityType: entityType,
        entityId: req.entityId,
      );
      if (terminal != null) terminals.add(terminal);
    }
    if (terminals.isNotEmpty) {
      await _channel.sendTerminals(terminals);
      _terminalsSent += terminals.length;
    }
  }

  void _resetCounters() {
    _incomingRecords = 0;
    _incomingConflicts = 0;
    _terminalsSent = 0;
    _requestsSent = 0;
  }

  ManifestEntry? _findRemote(ManifestChunk chunk, String entityId) {
    for (final e in chunk.entries) {
      if (e.entityId == entityId) return e;
    }
    return null;
  }
}
