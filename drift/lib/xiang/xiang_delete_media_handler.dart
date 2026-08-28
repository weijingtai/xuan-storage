import 'dart:convert';

import 'package:drift/drift.dart' show Value, OrderingTerm;
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/xiang/xiang_deletion_audit_event.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// 相法删除媒体处理 + 审计持久化（TDD-T7，FA12 单一方针）。
///
/// 职责：
/// 1) 删除记录时，统计其引用的媒体 refId 列表；
/// 2) 通过 [LocalBlobStore] 引用生命周期处理引用：**仅当没有其他记录引用
///    同一媒体时才回收实际资源**（共享引用不误删）；
/// 3) 审计事件持久化落库到共享 [CreationAuditLogs] 通用审计表（跨 repository
///    实例仍可查），只含操作/时间/操作者/媒体引用计数，不记录敏感内容。
final class XiangDeleteMediaHandler {
  final LocalBlobStore blobStore;
  final ScopedRecordStore store;
  final PersistenceDriftDatabase db;

  XiangDeleteMediaHandler({
    required this.blobStore,
    required this.store,
    required this.db,
  });

  /// 删除 [uuid] 记录：读记录统计媒体引用 → 软删 → 清空该记录 blob 引用 →
  /// 逐媒体检查全库引用，无其他记录引用时回收实际资源 → 审计落库。
  Future<void> handleDelete(String uuid) async {
    final meta = await store.getRecord(uuid, module: 'xiang');
    final mediaRefIds = <String>[];
    if (meta != null && meta.deletedAt == null) {
      mediaRefIds.addAll(_collectMediaRefIds(meta.moduleDataJson));
    }

    await store.softDeleteRecord(uuid, module: 'xiang');

    // 清空该记录对 blob 的引用声明（幂等全量声明）。
    await blobStore.reconcileRefs(ownerRecordUuid: 'xiang:$uuid', handles: {});

    // 逐媒体检查全库引用：仅当无其他记录引用时才删除实际资源。
    for (final refId in mediaRefIds) {
      final stillReferenced = await _isReferencedElsewhere(refId, uuid);
      if (!stillReferenced) {
        await _evictBlobByRefId(refId);
      }
    }

    // 审计持久化落库（共享通用审计表）。
    await db
        .into(db.creationAuditLogs)
        .insert(
          CreationAuditLogsCompanion.insert(
            caseUuid: uuid,
            auditedAt: DateTime.now().toUtc(),
            changeType: 'delete',
            entityType: 'xiang_reading',
            entityUuid: Value(uuid),
            oldJson: Value(jsonEncode({'mediaRefIds': mediaRefIds})),
            newJson: Value(null),
            summary: Value(
              'xiang reading deleted, mediaRefCount=${mediaRefIds.length}',
            ),
            operatorId: Value(store.scopeUid),
          ),
        );
  }

  /// 查询本 scope 的相法删除审计（持久化，跨实例可查）。
  Future<List<XiangDeletionAuditEvent>> queryAuditLogs() async {
    final rows =
        await (db.select(db.creationAuditLogs)
              ..where((t) => t.entityType.equals('xiang_reading'))
              ..where((t) => t.changeType.equals('delete'))
              ..orderBy([(t) => OrderingTerm.desc(t.auditedAt)]))
            .get();
    return rows.map((r) {
      final summary = r.summary ?? '';
      final count =
          RegExp(
            r'mediaRefCount=(\d+)',
          ).firstMatch(summary)?.group(1)?.let(int.parse) ??
          0;
      return XiangDeletionAuditEvent(
        operation: 'reading.delete',
        recordedAt: r.auditedAt,
        operatorUid: r.operatorId ?? store.scopeUid,
        mediaRefCount: count,
      );
    }).toList();
  }

  // ── 内部 ──

  List<String> _collectMediaRefIds(String? json) {
    if (json == null || json.isEmpty) return const [];
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return const [];
    }
    final evidence = data['evidence'];
    if (evidence is! List) return const [];
    final ids = <String>[];
    for (final e in evidence) {
      if (e is Map<String, dynamic>) {
        final mediaRef = e['mediaRef'];
        if (mediaRef is Map<String, dynamic>) {
          final refId = mediaRef['refId'];
          if (refId is String && refId.isNotEmpty) ids.add(refId);
        }
      }
    }
    return ids;
  }

  Future<bool> _isReferencedElsewhere(String refId, String excludeUuid) async {
    final metas = await store.listRecords(module: 'xiang', limit: 1000);
    for (final m in metas) {
      if (m.uuid == excludeUuid) continue;
      if (_collectMediaRefIds(m.moduleDataJson).contains(refId)) return true;
    }
    return false;
  }

  Future<void> _evictBlobByRefId(String refId) async {
    final blobs = await blobStore.list(tier: BlobTier.sourceOfTruth).toList();
    for (final entry in blobs) {
      if (entry.handle.cipherManifestId == refId) {
        await blobStore.evictByExternalId(refId);
        break;
      }
    }
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
