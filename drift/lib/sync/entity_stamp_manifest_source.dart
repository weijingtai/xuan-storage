import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';
import '../persistence_drift.dart';

/// 清单数据源的 drift 实现：直接读 `t_entity_stamp` 生成清单分片。
///
/// 映射契约（S1c §2.3 / §3.2① 定稿）：
/// - 清单含【全部未压缩戳行，含 `is_deleted=true` 墓碑行】。
/// - 按 (scopeUid, entityType) 分片，[ManifestChunk.chunkSeq] 从 0 递增，
///   [ManifestChunk.totalChunks] 正确填总分片数。
/// - 分片内按 entityId 稳定排序（保证同批数据两次读出的分片边界一致，
///   断点续传才可靠，S1c §3.2② 定稿）。
///
/// 【实现说明】本实现一次性读出该 (scopeUid, entityType) 的全部戳行再内存
/// 分片。record 实体单账号行数在千级以下，t_entity_stamp 是窄表（5 列），
/// 全读的成本可接受；若未来单分片实体量上十万，再换 keyset 游标分页
/// （WHERE entity_id > last）以保持分片边界稳定。
class EntityStampManifestSource extends DatabaseAccessor<PersistenceDriftDatabase>
    implements ManifestSource {
  /// 构造一个 [EntityStampManifestSource]。
  ///
  /// [db] 用于读 `t_entity_stamp`（读全部未压缩戳行）。
  EntityStampManifestSource(super.db);

  @override
  Future<ManifestChunk?> readManifestChunk({
    required String scopeUid,
    required String entityType,
    required int chunkSeq,
    required int pageSize,
  }) async {
    if (chunkSeq < 0) {
      throw ArgumentError.value(chunkSeq, 'chunkSeq', '必须 >= 0');
    }
    if (pageSize <= 0) {
      throw ArgumentError.value(pageSize, 'pageSize', '必须 > 0');
    }

    final rows = await (select(db.entityStamps)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.entityType.equals(entityType),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.entityId)]))
        .get();

    if (rows.isEmpty) {
      // 契约：该 (scopeUid, entityType) 有实体类型但清单为空 → 返回空片，
      // 不是 null（null 留给「没有可对齐的实体类型」）。
      return ManifestChunk(
        scopeUid: scopeUid,
        entityType: entityType,
        chunkSeq: chunkSeq,
        totalChunks: 0,
        entries: const [],
      );
    }

    final totalChunks = (rows.length + pageSize - 1) ~/ pageSize;
    if (chunkSeq >= totalChunks) {
      return null;
    }

    final start = chunkSeq * pageSize;
    final end = (start + pageSize).clamp(0, rows.length);
    final entries = rows.sublist(start, end).map((r) {
      return ManifestEntry(
        entityId: r.entityId,
        hlcPacked: r.hlcPacked,
        deviceId: r.deviceId,
        isDeleted: r.isDeleted,
      );
    }).toList();

    return ManifestChunk(
      scopeUid: scopeUid,
      entityType: entityType,
      chunkSeq: chunkSeq,
      totalChunks: totalChunks,
      entries: entries,
    );
  }
}
