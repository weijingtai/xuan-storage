// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creation_audit_logs_dao.dart';

// ignore_for_file: type=lint
mixin _$CreationAuditLogsDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $CreationAuditLogsTable get creationAuditLogs =>
      attachedDatabase.creationAuditLogs;
  CreationAuditLogsDaoManager get managers => CreationAuditLogsDaoManager(this);
}

class CreationAuditLogsDaoManager {
  final _$CreationAuditLogsDaoMixin _db;
  CreationAuditLogsDaoManager(this._db);
  $$CreationAuditLogsTableTableManager get creationAuditLogs =>
      $$CreationAuditLogsTableTableManager(
        _db.attachedDatabase,
        _db.creationAuditLogs,
      );
}
