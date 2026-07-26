import 'package:drift/drift.dart';

/// 创建流审计日志表
/// 记录案例草稿的每次保存变更（old→new）
class CreationAuditLogs extends Table {
  @override
  String get tableName => 't_creation_audit_logs';

  /// 自增主键
  IntColumn get id => integer().autoIncrement()();

  /// 关联案例 UUID
  TextColumn get caseUuid => text().named('case_uuid')();

  /// 审计时间
  DateTimeColumn get auditedAt => dateTime().named('audited_at')();

  /// 变更类型：create / update / delete
  TextColumn get changeType => text().named('change_type')();

  /// 变更实体类型：case / judgement / work_item / panel_ref
  TextColumn get entityType => text().named('entity_type')();

  /// 变更实体 UUID
  TextColumn get entityUuid => text().nullable().named('entity_uuid')();

  /// 变更前 JSON（旧值）
  TextColumn get oldJson => text().nullable().named('old_json')();

  /// 变更后 JSON（新值）
  TextColumn get newJson => text().nullable().named('new_json')();

  /// 变更摘要（人可读）
  TextColumn get summary => text().nullable().named('summary')();

  /// 操作者标识（预留）
  TextColumn get operatorId => text().nullable().named('operator_id')();

  // 本仓 drift 版本不会自动创建此处声明的索引，实际创建见 persistence_drift.dart 的 _createAuditLogIndices()。
  @override
  List<Index> get indexes => [
        Index(
          'idx_audit_case_uuid',
          'CREATE INDEX idx_audit_case_uuid ON t_creation_audit_logs(case_uuid);',
        ),
        Index(
          'idx_audit_audited_at',
          'CREATE INDEX idx_audit_audited_at ON t_creation_audit_logs(audited_at DESC);',
        ),
      ];
}
