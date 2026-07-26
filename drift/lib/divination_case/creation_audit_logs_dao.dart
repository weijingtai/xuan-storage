import 'package:drift/drift.dart';

import '../persistence_drift.dart';
import 'creation_audit_logs_table.dart';

part 'creation_audit_logs_dao.g.dart';

/// 创建流审计日志 DAO
@DriftAccessor(tables: [CreationAuditLogs])
class CreationAuditLogsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$CreationAuditLogsDaoMixin {
  CreationAuditLogsDao(super.db);

  /// 插入一条审计记录
  Future<int> insertAuditLog({
    required String caseUuid,
    required DateTime auditedAt,
    required String changeType,
    required String entityType,
    String? entityUuid,
    String? oldJson,
    String? newJson,
    String? summary,
    String? operatorId,
  }) {
    return into(creationAuditLogs).insert(
      CreationAuditLogsCompanion.insert(
        caseUuid: caseUuid,
        auditedAt: auditedAt,
        changeType: changeType,
        entityType: entityType,
        entityUuid: Value(entityUuid),
        oldJson: Value(oldJson),
        newJson: Value(newJson),
        summary: Value(summary),
        operatorId: Value(operatorId),
      ),
    );
  }

  /// 按案例 UUID 查询审计记录（最新在前）
  Future<List<CreationAuditLog>> getAuditLogsByCaseUuid(String caseUuid) {
    return (select(creationAuditLogs)
          ..where((t) => t.caseUuid.equals(caseUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.auditedAt)]))
        .get();
  }

  /// 按案例 UUID 查询审计记录（流式）
  Stream<List<CreationAuditLog>> watchAuditLogsByCaseUuid(String caseUuid) {
    return (select(creationAuditLogs)
          ..where((t) => t.caseUuid.equals(caseUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.auditedAt)]))
        .watch();
  }

  /// 按时间范围查询
  Future<List<CreationAuditLog>> getAuditLogsByTimeRange({
    required DateTime start,
    required DateTime end,
  }) {
    return (select(creationAuditLogs)
          ..where(
              (t) => t.auditedAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.auditedAt)]))
        .get();
  }

  /// 删除某案例的所有审计记录
  Future<int> deleteAuditLogsByCaseUuid(String caseUuid) {
    return (delete(creationAuditLogs)
          ..where((t) => t.caseUuid.equals(caseUuid)))
        .go();
  }
}
