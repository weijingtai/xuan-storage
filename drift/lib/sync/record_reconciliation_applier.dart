import 'package:persistence_core/persistence_core.dart';
import 'record_local_applier.dart';
import 'record_outbox_mapper.dart';

/// record 实体的全量对齐落库：把从对端收到的【终态批次】应用进本地。
///
/// 复用 [RecordLocalApplier.applyRemoteChanges]（仲裁 + 同事务写 + 冲突
/// 留档全在内），把 [EntityTerminal]（终态）映射为 [RemoteChange]（oplog
/// 事件形态）喂进去 —— S1c §2.2 定稿「传终态不重放 oplog」，这里只在
/// 本地适配层做形态转换，不复用 oplog 传输语义。
///
/// 【scope 绑定】：与 [RecordLocalApplier] 一致，一个实例只服务一个 scope。
class RecordReconciliationApplier implements LocalReconciliationApplier {
  /// 构造一个 [RecordReconciliationApplier]。
  ///
  /// 参数说明：
  /// - [delegate]：被复用的 [RecordLocalApplier]（已绑定 scope 与注入
  ///   applyWithStamp/arbiter/clock）。全量对齐与增量共用同一套落库逻辑，
  ///   保证「增量收过、全量再收」语义一致。
  /// - [nowUtc]：UTC 时钟，用于生成对齐游标（置"现在"）。
  RecordReconciliationApplier({
    required RecordLocalApplier delegate,
    required DateTime Function() nowUtc,
  })  : _delegate = delegate,
        _nowUtc = nowUtc;

  final RecordLocalApplier _delegate;
  final DateTime Function() _nowUtc;

  @override
  Future<ReconciliationResult> applyTerminals({
    required String scopeUid,
    required String entityType,
    required List<EntityTerminal> terminals,
  }) async {
    if (terminals.isEmpty) {
      return ReconciliationResult(
        scopeUid: scopeUid,
        entityType: entityType,
        recordsReconciled: 0,
        blobsPending: 0,
        conflictsLogged: 0,
      );
    }

    final changes = <RemoteChange>[];
    for (final t in terminals) {
      changes.add(RemoteChange(
        // 全量对齐没有远端 operationId：用稳定可去重的合成 id。
        // 前缀 `reconciled:` 保证与增量 oplog 的 operationId 空间不撞。
        operationId: 'reconciled:$entityType:${t.entityId}',
        entityType: entityType,
        entityId: t.entityId,
        opType: t.isDeleted
            ? RecordOutboxMapper.opDelete
            : RecordOutboxMapper.opUpsert,
        cursor: TimestampCursor(
          serverUpdatedAtUtc: _nowUtc(),
          tieBreaker: 'reconciled:${t.entityId}',
        ),
        payloadJson: t.payloadJson ?? '{}',
        serverTimeUtc: null,
        hlcPacked: t.hlcPacked,
        deviceId: t.deviceId,
      ));
    }

    final result = await _delegate.applyRemoteChanges(
      scopeUid: scopeUid,
      entityType: entityType,
      changes: changes,
    );

    // 冲突留档计数 = 本次有被丢弃一方的条数（takeRemote 覆盖本地 /
    // keepLocal 丢远端 都算，S1c §5 定稿「冲突留档必须可观测、可计数」）。
    var conflictsLogged = 0;
    for (final o in result.outcomes) {
      if (o.discardedSide != null) conflictsLogged += 1;
    }

    // record 实体的媒体（图片等）走 BlobHandle / reconcileRefs，不占
    // t_entity_stamp —— 全量对齐（本方法）只处理记录，blob 是独立阶段，
    // 因此对齐完成时 blob 一律 pending（S1c §3.2③ 定稿）。
    return ReconciliationResult(
      scopeUid: scopeUid,
      entityType: entityType,
      recordsReconciled: result.appliedCount,
      blobsPending: 0,
      conflictsLogged: conflictsLogged,
    );
  }
}
