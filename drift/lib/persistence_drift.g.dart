// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistence_drift.dart';

// ignore_for_file: type=lint
mixin _$OutboxRecordsDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $OutboxRecordsTable get outboxRecords => attachedDatabase.outboxRecords;
  OutboxRecordsDaoManager get managers => OutboxRecordsDaoManager(this);
}

class OutboxRecordsDaoManager {
  final _$OutboxRecordsDaoMixin _db;
  OutboxRecordsDaoManager(this._db);
  $$OutboxRecordsTableTableManager get outboxRecords =>
      $$OutboxRecordsTableTableManager(_db.attachedDatabase, _db.outboxRecords);
}

mixin _$SyncStatesDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $SyncStatesTable get syncStates => attachedDatabase.syncStates;
  SyncStatesDaoManager get managers => SyncStatesDaoManager(this);
}

class SyncStatesDaoManager {
  final _$SyncStatesDaoMixin _db;
  SyncStatesDaoManager(this._db);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db.attachedDatabase, _db.syncStates);
}

class $OutboxRecordsTable extends OutboxRecords
    with TableInfo<$OutboxRecordsTable, OutboxRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta =
      const VerificationMeta('operationId');
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
      'operation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeUidMeta =
      const VerificationMeta('scopeUid');
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
      'scope_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
      'op_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadSummaryMeta =
      const VerificationMeta('payloadSummary');
  @override
  late final GeneratedColumn<String> payloadSummary = GeneratedColumn<String>(
      'payload_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadHashMeta =
      const VerificationMeta('payloadHash');
  @override
  late final GeneratedColumn<String> payloadHash = GeneratedColumn<String>(
      'payload_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptMeta =
      const VerificationMeta('attempt');
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
      'attempt', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _lastErrorCodeMeta =
      const VerificationMeta('lastErrorCode');
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
      'last_error_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMessageMeta =
      const VerificationMeta('lastErrorMessage');
  @override
  late final GeneratedColumn<String> lastErrorMessage = GeneratedColumn<String>(
      'last_error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastAttemptAtUtcMeta =
      const VerificationMeta('lastAttemptAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAtUtc =
      GeneratedColumn<DateTime>('last_attempt_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _succeededAtUtcMeta =
      const VerificationMeta('succeededAtUtc');
  @override
  late final GeneratedColumn<DateTime> succeededAtUtc =
      GeneratedColumn<DateTime>('succeeded_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        operationId,
        scopeUid,
        entityType,
        entityId,
        opType,
        payloadJson,
        payloadSummary,
        payloadHash,
        createdAtUtc,
        attempt,
        status,
        lastErrorCode,
        lastErrorMessage,
        lastAttemptAtUtc,
        succeededAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
          _operationIdMeta,
          operationId.isAcceptableOrUnknown(
              data['operation_id']!, _operationIdMeta));
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('scope_uid')) {
      context.handle(_scopeUidMeta,
          scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta));
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(_opTypeMeta,
          opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta));
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('payload_summary')) {
      context.handle(
          _payloadSummaryMeta,
          payloadSummary.isAcceptableOrUnknown(
              data['payload_summary']!, _payloadSummaryMeta));
    }
    if (data.containsKey('payload_hash')) {
      context.handle(
          _payloadHashMeta,
          payloadHash.isAcceptableOrUnknown(
              data['payload_hash']!, _payloadHashMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(_attemptMeta,
          attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
          _lastErrorCodeMeta,
          lastErrorCode.isAcceptableOrUnknown(
              data['last_error_code']!, _lastErrorCodeMeta));
    }
    if (data.containsKey('last_error_message')) {
      context.handle(
          _lastErrorMessageMeta,
          lastErrorMessage.isAcceptableOrUnknown(
              data['last_error_message']!, _lastErrorMessageMeta));
    }
    if (data.containsKey('last_attempt_at_utc')) {
      context.handle(
          _lastAttemptAtUtcMeta,
          lastAttemptAtUtc.isAcceptableOrUnknown(
              data['last_attempt_at_utc']!, _lastAttemptAtUtcMeta));
    }
    if (data.containsKey('succeeded_at_utc')) {
      context.handle(
          _succeededAtUtcMeta,
          succeededAtUtc.isAcceptableOrUnknown(
              data['succeeded_at_utc']!, _succeededAtUtcMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  OutboxRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRecordRow(
      operationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_id'])!,
      scopeUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_uid'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      opType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}op_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      payloadSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_summary']),
      payloadHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_hash']),
      createdAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}created_at_utc'])!,
      attempt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      lastErrorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error_code']),
      lastErrorMessage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_error_message']),
      lastAttemptAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at_utc']),
      succeededAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}succeeded_at_utc']),
    );
  }

  @override
  $OutboxRecordsTable createAlias(String alias) {
    return $OutboxRecordsTable(attachedDatabase, alias);
  }
}

class OutboxRecordRow extends DataClass implements Insertable<OutboxRecordRow> {
  final String operationId;
  final String scopeUid;
  final String entityType;
  final String entityId;
  final String opType;
  final String payloadJson;
  final String? payloadSummary;
  final String? payloadHash;
  final DateTime createdAtUtc;
  final int attempt;
  final String status;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final DateTime? lastAttemptAtUtc;
  final DateTime? succeededAtUtc;
  const OutboxRecordRow(
      {required this.operationId,
      required this.scopeUid,
      required this.entityType,
      required this.entityId,
      required this.opType,
      required this.payloadJson,
      this.payloadSummary,
      this.payloadHash,
      required this.createdAtUtc,
      required this.attempt,
      required this.status,
      this.lastErrorCode,
      this.lastErrorMessage,
      this.lastAttemptAtUtc,
      this.succeededAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['scope_uid'] = Variable<String>(scopeUid);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op_type'] = Variable<String>(opType);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || payloadSummary != null) {
      map['payload_summary'] = Variable<String>(payloadSummary);
    }
    if (!nullToAbsent || payloadHash != null) {
      map['payload_hash'] = Variable<String>(payloadHash);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['attempt'] = Variable<int>(attempt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastErrorMessage != null) {
      map['last_error_message'] = Variable<String>(lastErrorMessage);
    }
    if (!nullToAbsent || lastAttemptAtUtc != null) {
      map['last_attempt_at_utc'] = Variable<DateTime>(lastAttemptAtUtc);
    }
    if (!nullToAbsent || succeededAtUtc != null) {
      map['succeeded_at_utc'] = Variable<DateTime>(succeededAtUtc);
    }
    return map;
  }

  OutboxRecordsCompanion toCompanion(bool nullToAbsent) {
    return OutboxRecordsCompanion(
      operationId: Value(operationId),
      scopeUid: Value(scopeUid),
      entityType: Value(entityType),
      entityId: Value(entityId),
      opType: Value(opType),
      payloadJson: Value(payloadJson),
      payloadSummary: payloadSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadSummary),
      payloadHash: payloadHash == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadHash),
      createdAtUtc: Value(createdAtUtc),
      attempt: Value(attempt),
      status: Value(status),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastErrorMessage: lastErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorMessage),
      lastAttemptAtUtc: lastAttemptAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAtUtc),
      succeededAtUtc: succeededAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(succeededAtUtc),
    );
  }

  factory OutboxRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRecordRow(
      operationId: serializer.fromJson<String>(json['operationId']),
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      opType: serializer.fromJson<String>(json['opType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      payloadSummary: serializer.fromJson<String?>(json['payloadSummary']),
      payloadHash: serializer.fromJson<String?>(json['payloadHash']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      attempt: serializer.fromJson<int>(json['attempt']),
      status: serializer.fromJson<String>(json['status']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastErrorMessage: serializer.fromJson<String?>(json['lastErrorMessage']),
      lastAttemptAtUtc:
          serializer.fromJson<DateTime?>(json['lastAttemptAtUtc']),
      succeededAtUtc: serializer.fromJson<DateTime?>(json['succeededAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'scopeUid': serializer.toJson<String>(scopeUid),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'opType': serializer.toJson<String>(opType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'payloadSummary': serializer.toJson<String?>(payloadSummary),
      'payloadHash': serializer.toJson<String?>(payloadHash),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'attempt': serializer.toJson<int>(attempt),
      'status': serializer.toJson<String>(status),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastErrorMessage': serializer.toJson<String?>(lastErrorMessage),
      'lastAttemptAtUtc': serializer.toJson<DateTime?>(lastAttemptAtUtc),
      'succeededAtUtc': serializer.toJson<DateTime?>(succeededAtUtc),
    };
  }

  OutboxRecordRow copyWith(
          {String? operationId,
          String? scopeUid,
          String? entityType,
          String? entityId,
          String? opType,
          String? payloadJson,
          Value<String?> payloadSummary = const Value.absent(),
          Value<String?> payloadHash = const Value.absent(),
          DateTime? createdAtUtc,
          int? attempt,
          String? status,
          Value<String?> lastErrorCode = const Value.absent(),
          Value<String?> lastErrorMessage = const Value.absent(),
          Value<DateTime?> lastAttemptAtUtc = const Value.absent(),
          Value<DateTime?> succeededAtUtc = const Value.absent()}) =>
      OutboxRecordRow(
        operationId: operationId ?? this.operationId,
        scopeUid: scopeUid ?? this.scopeUid,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        opType: opType ?? this.opType,
        payloadJson: payloadJson ?? this.payloadJson,
        payloadSummary:
            payloadSummary.present ? payloadSummary.value : this.payloadSummary,
        payloadHash: payloadHash.present ? payloadHash.value : this.payloadHash,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
        attempt: attempt ?? this.attempt,
        status: status ?? this.status,
        lastErrorCode:
            lastErrorCode.present ? lastErrorCode.value : this.lastErrorCode,
        lastErrorMessage: lastErrorMessage.present
            ? lastErrorMessage.value
            : this.lastErrorMessage,
        lastAttemptAtUtc: lastAttemptAtUtc.present
            ? lastAttemptAtUtc.value
            : this.lastAttemptAtUtc,
        succeededAtUtc:
            succeededAtUtc.present ? succeededAtUtc.value : this.succeededAtUtc,
      );
  OutboxRecordRow copyWithCompanion(OutboxRecordsCompanion data) {
    return OutboxRecordRow(
      operationId:
          data.operationId.present ? data.operationId.value : this.operationId,
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      opType: data.opType.present ? data.opType.value : this.opType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      payloadSummary: data.payloadSummary.present
          ? data.payloadSummary.value
          : this.payloadSummary,
      payloadHash:
          data.payloadHash.present ? data.payloadHash.value : this.payloadHash,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      status: data.status.present ? data.status.value : this.status,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastErrorMessage: data.lastErrorMessage.present
          ? data.lastErrorMessage.value
          : this.lastErrorMessage,
      lastAttemptAtUtc: data.lastAttemptAtUtc.present
          ? data.lastAttemptAtUtc.value
          : this.lastAttemptAtUtc,
      succeededAtUtc: data.succeededAtUtc.present
          ? data.succeededAtUtc.value
          : this.succeededAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRecordRow(')
          ..write('operationId: $operationId, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadSummary: $payloadSummary, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('lastAttemptAtUtc: $lastAttemptAtUtc, ')
          ..write('succeededAtUtc: $succeededAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      operationId,
      scopeUid,
      entityType,
      entityId,
      opType,
      payloadJson,
      payloadSummary,
      payloadHash,
      createdAtUtc,
      attempt,
      status,
      lastErrorCode,
      lastErrorMessage,
      lastAttemptAtUtc,
      succeededAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRecordRow &&
          other.operationId == this.operationId &&
          other.scopeUid == this.scopeUid &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.opType == this.opType &&
          other.payloadJson == this.payloadJson &&
          other.payloadSummary == this.payloadSummary &&
          other.payloadHash == this.payloadHash &&
          other.createdAtUtc == this.createdAtUtc &&
          other.attempt == this.attempt &&
          other.status == this.status &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastErrorMessage == this.lastErrorMessage &&
          other.lastAttemptAtUtc == this.lastAttemptAtUtc &&
          other.succeededAtUtc == this.succeededAtUtc);
}

class OutboxRecordsCompanion extends UpdateCompanion<OutboxRecordRow> {
  final Value<String> operationId;
  final Value<String> scopeUid;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> opType;
  final Value<String> payloadJson;
  final Value<String?> payloadSummary;
  final Value<String?> payloadHash;
  final Value<DateTime> createdAtUtc;
  final Value<int> attempt;
  final Value<String> status;
  final Value<String?> lastErrorCode;
  final Value<String?> lastErrorMessage;
  final Value<DateTime?> lastAttemptAtUtc;
  final Value<DateTime?> succeededAtUtc;
  final Value<int> rowid;
  const OutboxRecordsCompanion({
    this.operationId = const Value.absent(),
    this.scopeUid = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.opType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.payloadSummary = const Value.absent(),
    this.payloadHash = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.attempt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.lastAttemptAtUtc = const Value.absent(),
    this.succeededAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxRecordsCompanion.insert({
    required String operationId,
    required String scopeUid,
    required String entityType,
    required String entityId,
    required String opType,
    required String payloadJson,
    this.payloadSummary = const Value.absent(),
    this.payloadHash = const Value.absent(),
    required DateTime createdAtUtc,
    this.attempt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.lastAttemptAtUtc = const Value.absent(),
    this.succeededAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : operationId = Value(operationId),
        scopeUid = Value(scopeUid),
        entityType = Value(entityType),
        entityId = Value(entityId),
        opType = Value(opType),
        payloadJson = Value(payloadJson),
        createdAtUtc = Value(createdAtUtc);
  static Insertable<OutboxRecordRow> custom({
    Expression<String>? operationId,
    Expression<String>? scopeUid,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? opType,
    Expression<String>? payloadJson,
    Expression<String>? payloadSummary,
    Expression<String>? payloadHash,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? attempt,
    Expression<String>? status,
    Expression<String>? lastErrorCode,
    Expression<String>? lastErrorMessage,
    Expression<DateTime>? lastAttemptAtUtc,
    Expression<DateTime>? succeededAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (opType != null) 'op_type': opType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (payloadSummary != null) 'payload_summary': payloadSummary,
      if (payloadHash != null) 'payload_hash': payloadHash,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (attempt != null) 'attempt': attempt,
      if (status != null) 'status': status,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastErrorMessage != null) 'last_error_message': lastErrorMessage,
      if (lastAttemptAtUtc != null) 'last_attempt_at_utc': lastAttemptAtUtc,
      if (succeededAtUtc != null) 'succeeded_at_utc': succeededAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxRecordsCompanion copyWith(
      {Value<String>? operationId,
      Value<String>? scopeUid,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? opType,
      Value<String>? payloadJson,
      Value<String?>? payloadSummary,
      Value<String?>? payloadHash,
      Value<DateTime>? createdAtUtc,
      Value<int>? attempt,
      Value<String>? status,
      Value<String?>? lastErrorCode,
      Value<String?>? lastErrorMessage,
      Value<DateTime?>? lastAttemptAtUtc,
      Value<DateTime?>? succeededAtUtc,
      Value<int>? rowid}) {
    return OutboxRecordsCompanion(
      operationId: operationId ?? this.operationId,
      scopeUid: scopeUid ?? this.scopeUid,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payloadJson: payloadJson ?? this.payloadJson,
      payloadSummary: payloadSummary ?? this.payloadSummary,
      payloadHash: payloadHash ?? this.payloadHash,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      attempt: attempt ?? this.attempt,
      status: status ?? this.status,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      lastAttemptAtUtc: lastAttemptAtUtc ?? this.lastAttemptAtUtc,
      succeededAtUtc: succeededAtUtc ?? this.succeededAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (payloadSummary.present) {
      map['payload_summary'] = Variable<String>(payloadSummary.value);
    }
    if (payloadHash.present) {
      map['payload_hash'] = Variable<String>(payloadHash.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastErrorMessage.present) {
      map['last_error_message'] = Variable<String>(lastErrorMessage.value);
    }
    if (lastAttemptAtUtc.present) {
      map['last_attempt_at_utc'] = Variable<DateTime>(lastAttemptAtUtc.value);
    }
    if (succeededAtUtc.present) {
      map['succeeded_at_utc'] = Variable<DateTime>(succeededAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRecordsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadSummary: $payloadSummary, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('lastAttemptAtUtc: $lastAttemptAtUtc, ')
          ..write('succeededAtUtc: $succeededAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeUidMeta =
      const VerificationMeta('scopeUid');
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
      'scope_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorTypeMeta =
      const VerificationMeta('cursorType');
  @override
  late final GeneratedColumn<String> cursorType = GeneratedColumn<String>(
      'cursor_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _serverUpdatedAtUtcMeta =
      const VerificationMeta('serverUpdatedAtUtc');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAtUtc =
      GeneratedColumn<DateTime>('server_updated_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tieBreakerMeta =
      const VerificationMeta('tieBreaker');
  @override
  late final GeneratedColumn<String> tieBreaker = GeneratedColumn<String>(
      'tie_breaker', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cursorUpdatedAtUtcMeta =
      const VerificationMeta('cursorUpdatedAtUtc');
  @override
  late final GeneratedColumn<DateTime> cursorUpdatedAtUtc =
      GeneratedColumn<DateTime>('cursor_updated_at_utc', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastPulledAtUtcMeta =
      const VerificationMeta('lastPulledAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastPulledAtUtc =
      GeneratedColumn<DateTime>('last_pulled_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastPushedAtUtcMeta =
      const VerificationMeta('lastPushedAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastPushedAtUtc =
      GeneratedColumn<DateTime>('last_pushed_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        scopeUid,
        entityType,
        cursorType,
        revision,
        serverUpdatedAtUtc,
        tieBreaker,
        cursorUpdatedAtUtc,
        lastPulledAtUtc,
        lastPushedAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_uid')) {
      context.handle(_scopeUidMeta,
          scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta));
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('cursor_type')) {
      context.handle(
          _cursorTypeMeta,
          cursorType.isAcceptableOrUnknown(
              data['cursor_type']!, _cursorTypeMeta));
    } else if (isInserting) {
      context.missing(_cursorTypeMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('server_updated_at_utc')) {
      context.handle(
          _serverUpdatedAtUtcMeta,
          serverUpdatedAtUtc.isAcceptableOrUnknown(
              data['server_updated_at_utc']!, _serverUpdatedAtUtcMeta));
    }
    if (data.containsKey('tie_breaker')) {
      context.handle(
          _tieBreakerMeta,
          tieBreaker.isAcceptableOrUnknown(
              data['tie_breaker']!, _tieBreakerMeta));
    }
    if (data.containsKey('cursor_updated_at_utc')) {
      context.handle(
          _cursorUpdatedAtUtcMeta,
          cursorUpdatedAtUtc.isAcceptableOrUnknown(
              data['cursor_updated_at_utc']!, _cursorUpdatedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_cursorUpdatedAtUtcMeta);
    }
    if (data.containsKey('last_pulled_at_utc')) {
      context.handle(
          _lastPulledAtUtcMeta,
          lastPulledAtUtc.isAcceptableOrUnknown(
              data['last_pulled_at_utc']!, _lastPulledAtUtcMeta));
    }
    if (data.containsKey('last_pushed_at_utc')) {
      context.handle(
          _lastPushedAtUtcMeta,
          lastPushedAtUtc.isAcceptableOrUnknown(
              data['last_pushed_at_utc']!, _lastPushedAtUtcMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeUid, entityType};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      scopeUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_uid'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      cursorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cursor_type'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision']),
      serverUpdatedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}server_updated_at_utc']),
      tieBreaker: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tie_breaker']),
      cursorUpdatedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}cursor_updated_at_utc'])!,
      lastPulledAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_pulled_at_utc']),
      lastPushedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_pushed_at_utc']),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String scopeUid;
  final String entityType;
  final String cursorType;
  final int? revision;
  final DateTime? serverUpdatedAtUtc;
  final String? tieBreaker;
  final DateTime cursorUpdatedAtUtc;
  final DateTime? lastPulledAtUtc;
  final DateTime? lastPushedAtUtc;
  const SyncStateRow(
      {required this.scopeUid,
      required this.entityType,
      required this.cursorType,
      this.revision,
      this.serverUpdatedAtUtc,
      this.tieBreaker,
      required this.cursorUpdatedAtUtc,
      this.lastPulledAtUtc,
      this.lastPushedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_uid'] = Variable<String>(scopeUid);
    map['entity_type'] = Variable<String>(entityType);
    map['cursor_type'] = Variable<String>(cursorType);
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || serverUpdatedAtUtc != null) {
      map['server_updated_at_utc'] = Variable<DateTime>(serverUpdatedAtUtc);
    }
    if (!nullToAbsent || tieBreaker != null) {
      map['tie_breaker'] = Variable<String>(tieBreaker);
    }
    map['cursor_updated_at_utc'] = Variable<DateTime>(cursorUpdatedAtUtc);
    if (!nullToAbsent || lastPulledAtUtc != null) {
      map['last_pulled_at_utc'] = Variable<DateTime>(lastPulledAtUtc);
    }
    if (!nullToAbsent || lastPushedAtUtc != null) {
      map['last_pushed_at_utc'] = Variable<DateTime>(lastPushedAtUtc);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      scopeUid: Value(scopeUid),
      entityType: Value(entityType),
      cursorType: Value(cursorType),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      serverUpdatedAtUtc: serverUpdatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAtUtc),
      tieBreaker: tieBreaker == null && nullToAbsent
          ? const Value.absent()
          : Value(tieBreaker),
      cursorUpdatedAtUtc: Value(cursorUpdatedAtUtc),
      lastPulledAtUtc: lastPulledAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAtUtc),
      lastPushedAtUtc: lastPushedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAtUtc),
    );
  }

  factory SyncStateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      entityType: serializer.fromJson<String>(json['entityType']),
      cursorType: serializer.fromJson<String>(json['cursorType']),
      revision: serializer.fromJson<int?>(json['revision']),
      serverUpdatedAtUtc:
          serializer.fromJson<DateTime?>(json['serverUpdatedAtUtc']),
      tieBreaker: serializer.fromJson<String?>(json['tieBreaker']),
      cursorUpdatedAtUtc:
          serializer.fromJson<DateTime>(json['cursorUpdatedAtUtc']),
      lastPulledAtUtc: serializer.fromJson<DateTime?>(json['lastPulledAtUtc']),
      lastPushedAtUtc: serializer.fromJson<DateTime?>(json['lastPushedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeUid': serializer.toJson<String>(scopeUid),
      'entityType': serializer.toJson<String>(entityType),
      'cursorType': serializer.toJson<String>(cursorType),
      'revision': serializer.toJson<int?>(revision),
      'serverUpdatedAtUtc': serializer.toJson<DateTime?>(serverUpdatedAtUtc),
      'tieBreaker': serializer.toJson<String?>(tieBreaker),
      'cursorUpdatedAtUtc': serializer.toJson<DateTime>(cursorUpdatedAtUtc),
      'lastPulledAtUtc': serializer.toJson<DateTime?>(lastPulledAtUtc),
      'lastPushedAtUtc': serializer.toJson<DateTime?>(lastPushedAtUtc),
    };
  }

  SyncStateRow copyWith(
          {String? scopeUid,
          String? entityType,
          String? cursorType,
          Value<int?> revision = const Value.absent(),
          Value<DateTime?> serverUpdatedAtUtc = const Value.absent(),
          Value<String?> tieBreaker = const Value.absent(),
          DateTime? cursorUpdatedAtUtc,
          Value<DateTime?> lastPulledAtUtc = const Value.absent(),
          Value<DateTime?> lastPushedAtUtc = const Value.absent()}) =>
      SyncStateRow(
        scopeUid: scopeUid ?? this.scopeUid,
        entityType: entityType ?? this.entityType,
        cursorType: cursorType ?? this.cursorType,
        revision: revision.present ? revision.value : this.revision,
        serverUpdatedAtUtc: serverUpdatedAtUtc.present
            ? serverUpdatedAtUtc.value
            : this.serverUpdatedAtUtc,
        tieBreaker: tieBreaker.present ? tieBreaker.value : this.tieBreaker,
        cursorUpdatedAtUtc: cursorUpdatedAtUtc ?? this.cursorUpdatedAtUtc,
        lastPulledAtUtc: lastPulledAtUtc.present
            ? lastPulledAtUtc.value
            : this.lastPulledAtUtc,
        lastPushedAtUtc: lastPushedAtUtc.present
            ? lastPushedAtUtc.value
            : this.lastPushedAtUtc,
      );
  SyncStateRow copyWithCompanion(SyncStatesCompanion data) {
    return SyncStateRow(
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      cursorType:
          data.cursorType.present ? data.cursorType.value : this.cursorType,
      revision: data.revision.present ? data.revision.value : this.revision,
      serverUpdatedAtUtc: data.serverUpdatedAtUtc.present
          ? data.serverUpdatedAtUtc.value
          : this.serverUpdatedAtUtc,
      tieBreaker:
          data.tieBreaker.present ? data.tieBreaker.value : this.tieBreaker,
      cursorUpdatedAtUtc: data.cursorUpdatedAtUtc.present
          ? data.cursorUpdatedAtUtc.value
          : this.cursorUpdatedAtUtc,
      lastPulledAtUtc: data.lastPulledAtUtc.present
          ? data.lastPulledAtUtc.value
          : this.lastPulledAtUtc,
      lastPushedAtUtc: data.lastPushedAtUtc.present
          ? data.lastPushedAtUtc.value
          : this.lastPushedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('cursorType: $cursorType, ')
          ..write('revision: $revision, ')
          ..write('serverUpdatedAtUtc: $serverUpdatedAtUtc, ')
          ..write('tieBreaker: $tieBreaker, ')
          ..write('cursorUpdatedAtUtc: $cursorUpdatedAtUtc, ')
          ..write('lastPulledAtUtc: $lastPulledAtUtc, ')
          ..write('lastPushedAtUtc: $lastPushedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      scopeUid,
      entityType,
      cursorType,
      revision,
      serverUpdatedAtUtc,
      tieBreaker,
      cursorUpdatedAtUtc,
      lastPulledAtUtc,
      lastPushedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.scopeUid == this.scopeUid &&
          other.entityType == this.entityType &&
          other.cursorType == this.cursorType &&
          other.revision == this.revision &&
          other.serverUpdatedAtUtc == this.serverUpdatedAtUtc &&
          other.tieBreaker == this.tieBreaker &&
          other.cursorUpdatedAtUtc == this.cursorUpdatedAtUtc &&
          other.lastPulledAtUtc == this.lastPulledAtUtc &&
          other.lastPushedAtUtc == this.lastPushedAtUtc);
}

class SyncStatesCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> scopeUid;
  final Value<String> entityType;
  final Value<String> cursorType;
  final Value<int?> revision;
  final Value<DateTime?> serverUpdatedAtUtc;
  final Value<String?> tieBreaker;
  final Value<DateTime> cursorUpdatedAtUtc;
  final Value<DateTime?> lastPulledAtUtc;
  final Value<DateTime?> lastPushedAtUtc;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.scopeUid = const Value.absent(),
    this.entityType = const Value.absent(),
    this.cursorType = const Value.absent(),
    this.revision = const Value.absent(),
    this.serverUpdatedAtUtc = const Value.absent(),
    this.tieBreaker = const Value.absent(),
    this.cursorUpdatedAtUtc = const Value.absent(),
    this.lastPulledAtUtc = const Value.absent(),
    this.lastPushedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String scopeUid,
    required String entityType,
    required String cursorType,
    this.revision = const Value.absent(),
    this.serverUpdatedAtUtc = const Value.absent(),
    this.tieBreaker = const Value.absent(),
    required DateTime cursorUpdatedAtUtc,
    this.lastPulledAtUtc = const Value.absent(),
    this.lastPushedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : scopeUid = Value(scopeUid),
        entityType = Value(entityType),
        cursorType = Value(cursorType),
        cursorUpdatedAtUtc = Value(cursorUpdatedAtUtc);
  static Insertable<SyncStateRow> custom({
    Expression<String>? scopeUid,
    Expression<String>? entityType,
    Expression<String>? cursorType,
    Expression<int>? revision,
    Expression<DateTime>? serverUpdatedAtUtc,
    Expression<String>? tieBreaker,
    Expression<DateTime>? cursorUpdatedAtUtc,
    Expression<DateTime>? lastPulledAtUtc,
    Expression<DateTime>? lastPushedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (entityType != null) 'entity_type': entityType,
      if (cursorType != null) 'cursor_type': cursorType,
      if (revision != null) 'revision': revision,
      if (serverUpdatedAtUtc != null)
        'server_updated_at_utc': serverUpdatedAtUtc,
      if (tieBreaker != null) 'tie_breaker': tieBreaker,
      if (cursorUpdatedAtUtc != null)
        'cursor_updated_at_utc': cursorUpdatedAtUtc,
      if (lastPulledAtUtc != null) 'last_pulled_at_utc': lastPulledAtUtc,
      if (lastPushedAtUtc != null) 'last_pushed_at_utc': lastPushedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith(
      {Value<String>? scopeUid,
      Value<String>? entityType,
      Value<String>? cursorType,
      Value<int?>? revision,
      Value<DateTime?>? serverUpdatedAtUtc,
      Value<String?>? tieBreaker,
      Value<DateTime>? cursorUpdatedAtUtc,
      Value<DateTime?>? lastPulledAtUtc,
      Value<DateTime?>? lastPushedAtUtc,
      Value<int>? rowid}) {
    return SyncStatesCompanion(
      scopeUid: scopeUid ?? this.scopeUid,
      entityType: entityType ?? this.entityType,
      cursorType: cursorType ?? this.cursorType,
      revision: revision ?? this.revision,
      serverUpdatedAtUtc: serverUpdatedAtUtc ?? this.serverUpdatedAtUtc,
      tieBreaker: tieBreaker ?? this.tieBreaker,
      cursorUpdatedAtUtc: cursorUpdatedAtUtc ?? this.cursorUpdatedAtUtc,
      lastPulledAtUtc: lastPulledAtUtc ?? this.lastPulledAtUtc,
      lastPushedAtUtc: lastPushedAtUtc ?? this.lastPushedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (cursorType.present) {
      map['cursor_type'] = Variable<String>(cursorType.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverUpdatedAtUtc.present) {
      map['server_updated_at_utc'] =
          Variable<DateTime>(serverUpdatedAtUtc.value);
    }
    if (tieBreaker.present) {
      map['tie_breaker'] = Variable<String>(tieBreaker.value);
    }
    if (cursorUpdatedAtUtc.present) {
      map['cursor_updated_at_utc'] =
          Variable<DateTime>(cursorUpdatedAtUtc.value);
    }
    if (lastPulledAtUtc.present) {
      map['last_pulled_at_utc'] = Variable<DateTime>(lastPulledAtUtc.value);
    }
    if (lastPushedAtUtc.present) {
      map['last_pushed_at_utc'] = Variable<DateTime>(lastPushedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('cursorType: $cursorType, ')
          ..write('revision: $revision, ')
          ..write('serverUpdatedAtUtc: $serverUpdatedAtUtc, ')
          ..write('tieBreaker: $tieBreaker, ')
          ..write('cursorUpdatedAtUtc: $cursorUpdatedAtUtc, ')
          ..write('lastPulledAtUtc: $lastPulledAtUtc, ')
          ..write('lastPushedAtUtc: $lastPushedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeekersTable extends Seekers with TableInfo<$SeekersTable, SeekerModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeekersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Gender, String> gender =
      GeneratedColumn<String>('gender', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Gender>($SeekersTable.$convertergender);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTimeType, int> timingType =
      GeneratedColumn<int>('timing_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTimeType>($SeekersTable.$convertertimingType);
  static const VerificationMeta _datetimeMeta =
      const VerificationMeta('datetime');
  @override
  late final GeneratedColumn<DateTime> datetime = GeneratedColumn<DateTime>(
      'datetime', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> yearGanZhi =
      GeneratedColumn<int>('year_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$converteryearGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> monthGanZhi =
      GeneratedColumn<int>('month_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$convertermonthGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> dayGanZhi =
      GeneratedColumn<int>('day_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$converterdayGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> timeGanZhi =
      GeneratedColumn<int>('time_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$convertertimeGanZhi);
  static const VerificationMeta _lunarMonthMeta =
      const VerificationMeta('lunarMonth');
  @override
  late final GeneratedColumn<int> lunarMonth = GeneratedColumn<int>(
      'lunar_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isLeapMonthMeta =
      const VerificationMeta('isLeapMonth');
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
      'is_leap_month', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_leap_month" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lunarDayMeta =
      const VerificationMeta('lunarDay');
  @override
  late final GeneratedColumn<int> lunarDay = GeneratedColumn<int>(
      'lunar_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timingInfoUuidMeta =
      const VerificationMeta('timingInfoUuid');
  @override
  late final GeneratedColumn<String> timingInfoUuid = GeneratedColumn<String>(
      'timing_info_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?,
      String> timingInfoListJson = GeneratedColumn<String>(
          'info_list_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false)
      .withConverter<List<DivinationDatetimeModel>?>(
          $SeekersTable.$convertertimingInfoListJsonn);
  @override
  late final GeneratedColumnWithTypeConverter<Location?, String> location =
      GeneratedColumn<String>('location_json', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Location?>($SeekersTable.$converterlocation);
  static const VerificationMeta _currentCalendarUuidMeta =
      const VerificationMeta('currentCalendarUuid');
  @override
  late final GeneratedColumn<String> currentCalendarUuid =
      GeneratedColumn<String>('current_calendar_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        username,
        nickname,
        gender,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        timingType,
        datetime,
        yearGanZhi,
        monthGanZhi,
        dayGanZhi,
        timeGanZhi,
        lunarMonth,
        isLeapMonth,
        lunarDay,
        divinationUuid,
        timingInfoUuid,
        timingInfoListJson,
        location,
        currentCalendarUuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_seekers';
  @override
  VerificationContext validateIntegrity(Insertable<SeekerModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('datetime')) {
      context.handle(_datetimeMeta,
          datetime.isAcceptableOrUnknown(data['datetime']!, _datetimeMeta));
    } else if (isInserting) {
      context.missing(_datetimeMeta);
    }
    if (data.containsKey('lunar_month')) {
      context.handle(
          _lunarMonthMeta,
          lunarMonth.isAcceptableOrUnknown(
              data['lunar_month']!, _lunarMonthMeta));
    } else if (isInserting) {
      context.missing(_lunarMonthMeta);
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
          _isLeapMonthMeta,
          isLeapMonth.isAcceptableOrUnknown(
              data['is_leap_month']!, _isLeapMonthMeta));
    }
    if (data.containsKey('lunar_day')) {
      context.handle(_lunarDayMeta,
          lunarDay.isAcceptableOrUnknown(data['lunar_day']!, _lunarDayMeta));
    } else if (isInserting) {
      context.missing(_lunarDayMeta);
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('timing_info_uuid')) {
      context.handle(
          _timingInfoUuidMeta,
          timingInfoUuid.isAcceptableOrUnknown(
              data['timing_info_uuid']!, _timingInfoUuidMeta));
    }
    if (data.containsKey('current_calendar_uuid')) {
      context.handle(
          _currentCalendarUuidMeta,
          currentCalendarUuid.isAcceptableOrUnknown(
              data['current_calendar_uuid']!, _currentCalendarUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SeekerModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeekerModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      location: $SeekersTable.$converterlocation.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_json'])),
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      timingType: $SeekersTable.$convertertimingType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timing_type'])!),
      datetime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datetime'])!,
      yearGanZhi: $SeekersTable.$converteryearGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year_gan_zhi'])!),
      monthGanZhi: $SeekersTable.$convertermonthGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month_gan_zhi'])!),
      dayGanZhi: $SeekersTable.$converterdayGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_gan_zhi'])!),
      timeGanZhi: $SeekersTable.$convertertimeGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_gan_zhi'])!),
      lunarMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_month'])!,
      isLeapMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_leap_month'])!,
      lunarDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_day'])!,
      timingInfoUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}timing_info_uuid']),
      timingInfoListJson: $SeekersTable.$convertertimingInfoListJsonn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}info_list_json'])),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname']),
      gender: $SeekersTable.$convertergender.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!),
    );
  }

  @override
  $SeekersTable createAlias(String alias) {
    return $SeekersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Gender, String, String> $convertergender =
      const EnumNameConverter<Gender>(Gender.values);
  static JsonTypeConverter2<DateTimeType, int, int> $convertertimingType =
      const EnumIndexConverter<DateTimeType>(DateTimeType.values);
  static JsonTypeConverter2<JiaZi, int, int> $converteryearGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertermonthGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $converterdayGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertertimeGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static TypeConverter<List<DivinationDatetimeModel>, String>
      $convertertimingInfoListJson = const DivinationDatetimeModelConverter();
  static TypeConverter<List<DivinationDatetimeModel>?, String?>
      $convertertimingInfoListJsonn =
      NullAwareTypeConverter.wrap($convertertimingInfoListJson);
  static TypeConverter<Location?, String?> $converterlocation =
      const NullableLocationConverter();
}

class SeekersCompanion extends UpdateCompanion<SeekerModel> {
  final Value<String> uuid;
  final Value<String?> username;
  final Value<String?> nickname;
  final Value<Gender> gender;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTimeType> timingType;
  final Value<DateTime> datetime;
  final Value<JiaZi> yearGanZhi;
  final Value<JiaZi> monthGanZhi;
  final Value<JiaZi> dayGanZhi;
  final Value<JiaZi> timeGanZhi;
  final Value<int> lunarMonth;
  final Value<bool> isLeapMonth;
  final Value<int> lunarDay;
  final Value<String> divinationUuid;
  final Value<String?> timingInfoUuid;
  final Value<List<DivinationDatetimeModel>?> timingInfoListJson;
  final Value<Location?> location;
  final Value<String?> currentCalendarUuid;
  final Value<int> rowid;
  const SeekersCompanion({
    this.uuid = const Value.absent(),
    this.username = const Value.absent(),
    this.nickname = const Value.absent(),
    this.gender = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.timingType = const Value.absent(),
    this.datetime = const Value.absent(),
    this.yearGanZhi = const Value.absent(),
    this.monthGanZhi = const Value.absent(),
    this.dayGanZhi = const Value.absent(),
    this.timeGanZhi = const Value.absent(),
    this.lunarMonth = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.lunarDay = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.timingInfoUuid = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.location = const Value.absent(),
    this.currentCalendarUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeekersCompanion.insert({
    required String uuid,
    this.username = const Value.absent(),
    this.nickname = const Value.absent(),
    required Gender gender,
    required DateTime createdAt,
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTimeType timingType,
    required DateTime datetime,
    required JiaZi yearGanZhi,
    required JiaZi monthGanZhi,
    required JiaZi dayGanZhi,
    required JiaZi timeGanZhi,
    required int lunarMonth,
    this.isLeapMonth = const Value.absent(),
    required int lunarDay,
    required String divinationUuid,
    this.timingInfoUuid = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.location = const Value.absent(),
    this.currentCalendarUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        gender = Value(gender),
        createdAt = Value(createdAt),
        timingType = Value(timingType),
        datetime = Value(datetime),
        yearGanZhi = Value(yearGanZhi),
        monthGanZhi = Value(monthGanZhi),
        dayGanZhi = Value(dayGanZhi),
        timeGanZhi = Value(timeGanZhi),
        lunarMonth = Value(lunarMonth),
        lunarDay = Value(lunarDay),
        divinationUuid = Value(divinationUuid);
  static Insertable<SeekerModel> custom({
    Expression<String>? uuid,
    Expression<String>? username,
    Expression<String>? nickname,
    Expression<String>? gender,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? timingType,
    Expression<DateTime>? datetime,
    Expression<int>? yearGanZhi,
    Expression<int>? monthGanZhi,
    Expression<int>? dayGanZhi,
    Expression<int>? timeGanZhi,
    Expression<int>? lunarMonth,
    Expression<bool>? isLeapMonth,
    Expression<int>? lunarDay,
    Expression<String>? divinationUuid,
    Expression<String>? timingInfoUuid,
    Expression<String>? timingInfoListJson,
    Expression<String>? location,
    Expression<String>? currentCalendarUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (username != null) 'username': username,
      if (nickname != null) 'nickname': nickname,
      if (gender != null) 'gender': gender,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (timingType != null) 'timing_type': timingType,
      if (datetime != null) 'datetime': datetime,
      if (yearGanZhi != null) 'year_gan_zhi': yearGanZhi,
      if (monthGanZhi != null) 'month_gan_zhi': monthGanZhi,
      if (dayGanZhi != null) 'day_gan_zhi': dayGanZhi,
      if (timeGanZhi != null) 'time_gan_zhi': timeGanZhi,
      if (lunarMonth != null) 'lunar_month': lunarMonth,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (lunarDay != null) 'lunar_day': lunarDay,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (timingInfoUuid != null) 'timing_info_uuid': timingInfoUuid,
      if (timingInfoListJson != null) 'info_list_json': timingInfoListJson,
      if (location != null) 'location_json': location,
      if (currentCalendarUuid != null)
        'current_calendar_uuid': currentCalendarUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeekersCompanion copyWith(
      {Value<String>? uuid,
      Value<String?>? username,
      Value<String?>? nickname,
      Value<Gender>? gender,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTimeType>? timingType,
      Value<DateTime>? datetime,
      Value<JiaZi>? yearGanZhi,
      Value<JiaZi>? monthGanZhi,
      Value<JiaZi>? dayGanZhi,
      Value<JiaZi>? timeGanZhi,
      Value<int>? lunarMonth,
      Value<bool>? isLeapMonth,
      Value<int>? lunarDay,
      Value<String>? divinationUuid,
      Value<String?>? timingInfoUuid,
      Value<List<DivinationDatetimeModel>?>? timingInfoListJson,
      Value<Location?>? location,
      Value<String?>? currentCalendarUuid,
      Value<int>? rowid}) {
    return SeekersCompanion(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      timingType: timingType ?? this.timingType,
      datetime: datetime ?? this.datetime,
      yearGanZhi: yearGanZhi ?? this.yearGanZhi,
      monthGanZhi: monthGanZhi ?? this.monthGanZhi,
      dayGanZhi: dayGanZhi ?? this.dayGanZhi,
      timeGanZhi: timeGanZhi ?? this.timeGanZhi,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      timingInfoUuid: timingInfoUuid ?? this.timingInfoUuid,
      timingInfoListJson: timingInfoListJson ?? this.timingInfoListJson,
      location: location ?? this.location,
      currentCalendarUuid: currentCalendarUuid ?? this.currentCalendarUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (gender.present) {
      map['gender'] =
          Variable<String>($SeekersTable.$convertergender.toSql(gender.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (timingType.present) {
      map['timing_type'] = Variable<int>(
          $SeekersTable.$convertertimingType.toSql(timingType.value));
    }
    if (datetime.present) {
      map['datetime'] = Variable<DateTime>(datetime.value);
    }
    if (yearGanZhi.present) {
      map['year_gan_zhi'] = Variable<int>(
          $SeekersTable.$converteryearGanZhi.toSql(yearGanZhi.value));
    }
    if (monthGanZhi.present) {
      map['month_gan_zhi'] = Variable<int>(
          $SeekersTable.$convertermonthGanZhi.toSql(monthGanZhi.value));
    }
    if (dayGanZhi.present) {
      map['day_gan_zhi'] = Variable<int>(
          $SeekersTable.$converterdayGanZhi.toSql(dayGanZhi.value));
    }
    if (timeGanZhi.present) {
      map['time_gan_zhi'] = Variable<int>(
          $SeekersTable.$convertertimeGanZhi.toSql(timeGanZhi.value));
    }
    if (lunarMonth.present) {
      map['lunar_month'] = Variable<int>(lunarMonth.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (lunarDay.present) {
      map['lunar_day'] = Variable<int>(lunarDay.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (timingInfoUuid.present) {
      map['timing_info_uuid'] = Variable<String>(timingInfoUuid.value);
    }
    if (timingInfoListJson.present) {
      map['info_list_json'] = Variable<String>($SeekersTable
          .$convertertimingInfoListJsonn
          .toSql(timingInfoListJson.value));
    }
    if (location.present) {
      map['location_json'] = Variable<String>(
          $SeekersTable.$converterlocation.toSql(location.value));
    }
    if (currentCalendarUuid.present) {
      map['current_calendar_uuid'] =
          Variable<String>(currentCalendarUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeekersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('username: $username, ')
          ..write('nickname: $nickname, ')
          ..write('gender: $gender, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('timingType: $timingType, ')
          ..write('datetime: $datetime, ')
          ..write('yearGanZhi: $yearGanZhi, ')
          ..write('monthGanZhi: $monthGanZhi, ')
          ..write('dayGanZhi: $dayGanZhi, ')
          ..write('timeGanZhi: $timeGanZhi, ')
          ..write('lunarMonth: $lunarMonth, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('lunarDay: $lunarDay, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('timingInfoUuid: $timingInfoUuid, ')
          ..write('timingInfoListJson: $timingInfoListJson, ')
          ..write('location: $location, ')
          ..write('currentCalendarUuid: $currentCalendarUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationsTable extends Divinations
    with TableInfo<$DivinationsTable, DivinationRequestInfoDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _divinationTypeUuidMeta =
      const VerificationMeta('divinationTypeUuid');
  @override
  late final GeneratedColumn<String> divinationTypeUuid =
      GeneratedColumn<String>('divination_type_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fateYearMeta =
      const VerificationMeta('fateYear');
  @override
  late final GeneratedColumn<String> fateYear = GeneratedColumn<String>(
      'fate_year', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerSeekerUuidMeta =
      const VerificationMeta('ownerSeekerUuid');
  @override
  late final GeneratedColumn<String> ownerSeekerUuid = GeneratedColumn<String>(
      'seeker_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_seekers (uuid)'));
  @override
  late final GeneratedColumnWithTypeConverter<Gender?, String> gender =
      GeneratedColumn<String>('gender', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Gender?>($DivinationsTable.$convertergendern);
  static const VerificationMeta _seekerNameMeta =
      const VerificationMeta('seekerName');
  @override
  late final GeneratedColumn<String> seekerName = GeneratedColumn<String>(
      'seeker_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tinyPredictMeta =
      const VerificationMeta('tinyPredict');
  @override
  late final GeneratedColumn<String> tinyPredict = GeneratedColumn<String>(
      'tiny_predict', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _directlyPredictMeta =
      const VerificationMeta('directlyPredict');
  @override
  late final GeneratedColumn<String> directlyPredict = GeneratedColumn<String>(
      'directly_predict', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        divinationTypeUuid,
        fateYear,
        question,
        detail,
        ownerSeekerUuid,
        gender,
        seekerName,
        tinyPredict,
        directlyPredict
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divinations';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationRequestInfoDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('divination_type_uuid')) {
      context.handle(
          _divinationTypeUuidMeta,
          divinationTypeUuid.isAcceptableOrUnknown(
              data['divination_type_uuid']!, _divinationTypeUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationTypeUuidMeta);
    }
    if (data.containsKey('fate_year')) {
      context.handle(_fateYearMeta,
          fateYear.isAcceptableOrUnknown(data['fate_year']!, _fateYearMeta));
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    if (data.containsKey('seeker_uuid')) {
      context.handle(
          _ownerSeekerUuidMeta,
          ownerSeekerUuid.isAcceptableOrUnknown(
              data['seeker_uuid']!, _ownerSeekerUuidMeta));
    }
    if (data.containsKey('seeker_name')) {
      context.handle(
          _seekerNameMeta,
          seekerName.isAcceptableOrUnknown(
              data['seeker_name']!, _seekerNameMeta));
    }
    if (data.containsKey('tiny_predict')) {
      context.handle(
          _tinyPredictMeta,
          tinyPredict.isAcceptableOrUnknown(
              data['tiny_predict']!, _tinyPredictMeta));
    }
    if (data.containsKey('directly_predict')) {
      context.handle(
          _directlyPredictMeta,
          directlyPredict.isAcceptableOrUnknown(
              data['directly_predict']!, _directlyPredictMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  DivinationRequestInfoDataModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationRequestInfoDataModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      divinationTypeUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_type_uuid'])!,
      fateYear: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fate_year']),
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question']),
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
      ownerSeekerUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_uuid']),
      gender: $DivinationsTable.$convertergendern.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])),
      seekerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_name']),
      tinyPredict: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tiny_predict']),
      directlyPredict: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}directly_predict']),
    );
  }

  @override
  $DivinationsTable createAlias(String alias) {
    return $DivinationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Gender, String, String> $convertergender =
      const EnumNameConverter<Gender>(Gender.values);
  static JsonTypeConverter2<Gender?, String?, String?> $convertergendern =
      JsonTypeConverter2.asNullable($convertergender);
}

class DivinationsCompanion
    extends UpdateCompanion<DivinationRequestInfoDataModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> divinationTypeUuid;
  final Value<String?> fateYear;
  final Value<String?> question;
  final Value<String?> detail;
  final Value<String?> ownerSeekerUuid;
  final Value<Gender?> gender;
  final Value<String?> seekerName;
  final Value<String?> tinyPredict;
  final Value<String?> directlyPredict;
  final Value<int> rowid;
  const DivinationsCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.divinationTypeUuid = const Value.absent(),
    this.fateYear = const Value.absent(),
    this.question = const Value.absent(),
    this.detail = const Value.absent(),
    this.ownerSeekerUuid = const Value.absent(),
    this.gender = const Value.absent(),
    this.seekerName = const Value.absent(),
    this.tinyPredict = const Value.absent(),
    this.directlyPredict = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationsCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String divinationTypeUuid,
    this.fateYear = const Value.absent(),
    this.question = const Value.absent(),
    this.detail = const Value.absent(),
    this.ownerSeekerUuid = const Value.absent(),
    this.gender = const Value.absent(),
    this.seekerName = const Value.absent(),
    this.tinyPredict = const Value.absent(),
    this.directlyPredict = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        divinationTypeUuid = Value(divinationTypeUuid);
  static Insertable<DivinationRequestInfoDataModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? divinationTypeUuid,
    Expression<String>? fateYear,
    Expression<String>? question,
    Expression<String>? detail,
    Expression<String>? ownerSeekerUuid,
    Expression<String>? gender,
    Expression<String>? seekerName,
    Expression<String>? tinyPredict,
    Expression<String>? directlyPredict,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (divinationTypeUuid != null)
        'divination_type_uuid': divinationTypeUuid,
      if (fateYear != null) 'fate_year': fateYear,
      if (question != null) 'question': question,
      if (detail != null) 'detail': detail,
      if (ownerSeekerUuid != null) 'seeker_uuid': ownerSeekerUuid,
      if (gender != null) 'gender': gender,
      if (seekerName != null) 'seeker_name': seekerName,
      if (tinyPredict != null) 'tiny_predict': tinyPredict,
      if (directlyPredict != null) 'directly_predict': directlyPredict,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationsCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? divinationTypeUuid,
      Value<String?>? fateYear,
      Value<String?>? question,
      Value<String?>? detail,
      Value<String?>? ownerSeekerUuid,
      Value<Gender?>? gender,
      Value<String?>? seekerName,
      Value<String?>? tinyPredict,
      Value<String?>? directlyPredict,
      Value<int>? rowid}) {
    return DivinationsCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationTypeUuid: divinationTypeUuid ?? this.divinationTypeUuid,
      fateYear: fateYear ?? this.fateYear,
      question: question ?? this.question,
      detail: detail ?? this.detail,
      ownerSeekerUuid: ownerSeekerUuid ?? this.ownerSeekerUuid,
      gender: gender ?? this.gender,
      seekerName: seekerName ?? this.seekerName,
      tinyPredict: tinyPredict ?? this.tinyPredict,
      directlyPredict: directlyPredict ?? this.directlyPredict,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (divinationTypeUuid.present) {
      map['divination_type_uuid'] = Variable<String>(divinationTypeUuid.value);
    }
    if (fateYear.present) {
      map['fate_year'] = Variable<String>(fateYear.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (ownerSeekerUuid.present) {
      map['seeker_uuid'] = Variable<String>(ownerSeekerUuid.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(
          $DivinationsTable.$convertergendern.toSql(gender.value));
    }
    if (seekerName.present) {
      map['seeker_name'] = Variable<String>(seekerName.value);
    }
    if (tinyPredict.present) {
      map['tiny_predict'] = Variable<String>(tinyPredict.value);
    }
    if (directlyPredict.present) {
      map['directly_predict'] = Variable<String>(directlyPredict.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationTypeUuid: $divinationTypeUuid, ')
          ..write('fateYear: $fateYear, ')
          ..write('question: $question, ')
          ..write('detail: $detail, ')
          ..write('ownerSeekerUuid: $ownerSeekerUuid, ')
          ..write('gender: $gender, ')
          ..write('seekerName: $seekerName, ')
          ..write('tinyPredict: $tinyPredict, ')
          ..write('directlyPredict: $directlyPredict, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeekerDivinationMappersTable extends SeekerDivinationMappers
    with TableInfo<$SeekerDivinationMappersTable, SeekerDivinationMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeekerDivinationMappersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_divinations (uuid)'));
  static const VerificationMeta _seekerUuidMeta =
      const VerificationMeta('seekerUuid');
  @override
  late final GeneratedColumn<String> seekerUuid = GeneratedColumn<String>(
      'seeker_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_seekers (uuid)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, lastUpdatedAt, deletedAt, divinationUuid, seekerUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_seeker_divination_mapper';
  @override
  VerificationContext validateIntegrity(
      Insertable<SeekerDivinationMapper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('seeker_uuid')) {
      context.handle(
          _seekerUuidMeta,
          seekerUuid.isAcceptableOrUnknown(
              data['seeker_uuid']!, _seekerUuidMeta));
    } else if (isInserting) {
      context.missing(_seekerUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeekerDivinationMapper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeekerDivinationMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      seekerUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_uuid'])!,
    );
  }

  @override
  $SeekerDivinationMappersTable createAlias(String alias) {
    return $SeekerDivinationMappersTable(attachedDatabase, alias);
  }
}

class SeekerDivinationMapper extends DataClass
    implements Insertable<SeekerDivinationMapper> {
  final int id;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String divinationUuid;
  final String seekerUuid;
  const SeekerDivinationMapper(
      {required this.id,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.divinationUuid,
      required this.seekerUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['divination_uuid'] = Variable<String>(divinationUuid);
    map['seeker_uuid'] = Variable<String>(seekerUuid);
    return map;
  }

  SeekerDivinationMappersCompanion toCompanion(bool nullToAbsent) {
    return SeekerDivinationMappersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      divinationUuid: Value(divinationUuid),
      seekerUuid: Value(seekerUuid),
    );
  }

  factory SeekerDivinationMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeekerDivinationMapper(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      divinationUuid: serializer.fromJson<String>(json['divinationUuid']),
      seekerUuid: serializer.fromJson<String>(json['seekerUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'divinationUuid': serializer.toJson<String>(divinationUuid),
      'seekerUuid': serializer.toJson<String>(seekerUuid),
    };
  }

  SeekerDivinationMapper copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? divinationUuid,
          String? seekerUuid}) =>
      SeekerDivinationMapper(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        divinationUuid: divinationUuid ?? this.divinationUuid,
        seekerUuid: seekerUuid ?? this.seekerUuid,
      );
  SeekerDivinationMapper copyWithCompanion(
      SeekerDivinationMappersCompanion data) {
    return SeekerDivinationMapper(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      divinationUuid: data.divinationUuid.present
          ? data.divinationUuid.value
          : this.divinationUuid,
      seekerUuid:
          data.seekerUuid.present ? data.seekerUuid.value : this.seekerUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeekerDivinationMapper(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('seekerUuid: $seekerUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, lastUpdatedAt, deletedAt, divinationUuid, seekerUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeekerDivinationMapper &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.divinationUuid == this.divinationUuid &&
          other.seekerUuid == this.seekerUuid);
}

class SeekerDivinationMappersCompanion
    extends UpdateCompanion<SeekerDivinationMapper> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> divinationUuid;
  final Value<String> seekerUuid;
  const SeekerDivinationMappersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.seekerUuid = const Value.absent(),
  });
  SeekerDivinationMappersCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String divinationUuid,
    required String seekerUuid,
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        divinationUuid = Value(divinationUuid),
        seekerUuid = Value(seekerUuid);
  static Insertable<SeekerDivinationMapper> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? divinationUuid,
    Expression<String>? seekerUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (seekerUuid != null) 'seeker_uuid': seekerUuid,
    });
  }

  SeekerDivinationMappersCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? divinationUuid,
      Value<String>? seekerUuid}) {
    return SeekerDivinationMappersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      seekerUuid: seekerUuid ?? this.seekerUuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (seekerUuid.present) {
      map['seeker_uuid'] = Variable<String>(seekerUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeekerDivinationMappersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('seekerUuid: $seekerUuid')
          ..write(')'))
        .toString();
  }
}

class $CombinedDivinationsTable extends CombinedDivinations
    with TableInfo<$CombinedDivinationsTable, CombinedDivination> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CombinedDivinationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_divinations (uuid)'));
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, createdAt, lastUpdatedAt, deletedAt, order, divinationUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_combined_divinations';
  @override
  VerificationContext validateIntegrity(Insertable<CombinedDivination> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  CombinedDivination map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CombinedDivination(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
    );
  }

  @override
  $CombinedDivinationsTable createAlias(String alias) {
    return $CombinedDivinationsTable(attachedDatabase, alias);
  }
}

class CombinedDivination extends DataClass
    implements Insertable<CombinedDivination> {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final int order;
  final String divinationUuid;
  const CombinedDivination(
      {required this.uuid,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.order,
      required this.divinationUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['order'] = Variable<int>(order);
    map['divination_uuid'] = Variable<String>(divinationUuid);
    return map;
  }

  CombinedDivinationsCompanion toCompanion(bool nullToAbsent) {
    return CombinedDivinationsCompanion(
      uuid: Value(uuid),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      order: Value(order),
      divinationUuid: Value(divinationUuid),
    );
  }

  factory CombinedDivination.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CombinedDivination(
      uuid: serializer.fromJson<String>(json['uuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      order: serializer.fromJson<int>(json['order']),
      divinationUuid: serializer.fromJson<String>(json['divinationUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'order': serializer.toJson<int>(order),
      'divinationUuid': serializer.toJson<String>(divinationUuid),
    };
  }

  CombinedDivination copyWith(
          {String? uuid,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? order,
          String? divinationUuid}) =>
      CombinedDivination(
        uuid: uuid ?? this.uuid,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        order: order ?? this.order,
        divinationUuid: divinationUuid ?? this.divinationUuid,
      );
  CombinedDivination copyWithCompanion(CombinedDivinationsCompanion data) {
    return CombinedDivination(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      order: data.order.present ? data.order.value : this.order,
      divinationUuid: data.divinationUuid.present
          ? data.divinationUuid.value
          : this.divinationUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CombinedDivination(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('order: $order, ')
          ..write('divinationUuid: $divinationUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, createdAt, lastUpdatedAt, deletedAt, order, divinationUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CombinedDivination &&
          other.uuid == this.uuid &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.order == this.order &&
          other.divinationUuid == this.divinationUuid);
}

class CombinedDivinationsCompanion extends UpdateCompanion<CombinedDivination> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> order;
  final Value<String> divinationUuid;
  final Value<int> rowid;
  const CombinedDivinationsCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.order = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CombinedDivinationsCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required int order,
    required String divinationUuid,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        order = Value(order),
        divinationUuid = Value(divinationUuid);
  static Insertable<CombinedDivination> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? order,
    Expression<String>? divinationUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (order != null) 'order': order,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CombinedDivinationsCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? order,
      Value<String>? divinationUuid,
      Value<int>? rowid}) {
    return CombinedDivinationsCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      order: order ?? this.order,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CombinedDivinationsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('order: $order, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecisionLinksTable extends DecisionLinks
    with TableInfo<$DecisionLinksTable, DecisionLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceUuidMeta =
      const VerificationMeta('sourceUuid');
  @override
  late final GeneratedColumn<String> sourceUuid = GeneratedColumn<String>(
      'source_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetUuidMeta =
      const VerificationMeta('targetUuid');
  @override
  late final GeneratedColumn<String> targetUuid = GeneratedColumn<String>(
      'target_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intentMeta = const VerificationMeta('intent');
  @override
  late final GeneratedColumn<String> intent = GeneratedColumn<String>(
      'intent', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextSnapshotJsonMeta =
      const VerificationMeta('contextSnapshotJson');
  @override
  late final GeneratedColumn<String> contextSnapshotJson =
      GeneratedColumn<String>('context_snapshot_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMsMeta =
      const VerificationMeta('createdAtMs');
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
      'created_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMsMeta =
      const VerificationMeta('deletedAtMs');
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
      'deleted_at_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _scopeUidMeta =
      const VerificationMeta('scopeUid');
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
      'scope_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unknownFieldsMeta =
      const VerificationMeta('unknownFields');
  @override
  late final GeneratedColumn<String> unknownFields = GeneratedColumn<String>(
      'unknown_fields', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceUuid,
        targetUuid,
        intent,
        contextSnapshotJson,
        createdAtMs,
        updatedAtMs,
        deletedAtMs,
        scopeUid,
        unknownFields
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_decision_links';
  @override
  VerificationContext validateIntegrity(Insertable<DecisionLinkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_uuid')) {
      context.handle(
          _sourceUuidMeta,
          sourceUuid.isAcceptableOrUnknown(
              data['source_uuid']!, _sourceUuidMeta));
    } else if (isInserting) {
      context.missing(_sourceUuidMeta);
    }
    if (data.containsKey('target_uuid')) {
      context.handle(
          _targetUuidMeta,
          targetUuid.isAcceptableOrUnknown(
              data['target_uuid']!, _targetUuidMeta));
    } else if (isInserting) {
      context.missing(_targetUuidMeta);
    }
    if (data.containsKey('intent')) {
      context.handle(_intentMeta,
          intent.isAcceptableOrUnknown(data['intent']!, _intentMeta));
    } else if (isInserting) {
      context.missing(_intentMeta);
    }
    if (data.containsKey('context_snapshot_json')) {
      context.handle(
          _contextSnapshotJsonMeta,
          contextSnapshotJson.isAcceptableOrUnknown(
              data['context_snapshot_json']!, _contextSnapshotJsonMeta));
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
          _createdAtMsMeta,
          createdAtMs.isAcceptableOrUnknown(
              data['created_at_ms']!, _createdAtMsMeta));
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
          _deletedAtMsMeta,
          deletedAtMs.isAcceptableOrUnknown(
              data['deleted_at_ms']!, _deletedAtMsMeta));
    }
    if (data.containsKey('scope_uid')) {
      context.handle(_scopeUidMeta,
          scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta));
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('unknown_fields')) {
      context.handle(
          _unknownFieldsMeta,
          unknownFields.isAcceptableOrUnknown(
              data['unknown_fields']!, _unknownFieldsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DecisionLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DecisionLinkRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_uuid'])!,
      targetUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_uuid'])!,
      intent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intent'])!,
      contextSnapshotJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}context_snapshot_json']),
      createdAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at_ms'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
      deletedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at_ms']),
      scopeUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_uid'])!,
      unknownFields: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unknown_fields']),
    );
  }

  @override
  $DecisionLinksTable createAlias(String alias) {
    return $DecisionLinksTable(attachedDatabase, alias);
  }
}

class DecisionLinkRow extends DataClass implements Insertable<DecisionLinkRow> {
  final String id;
  final String sourceUuid;
  final String targetUuid;
  final String intent;
  final String? contextSnapshotJson;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  final String scopeUid;
  final String? unknownFields;
  const DecisionLinkRow(
      {required this.id,
      required this.sourceUuid,
      required this.targetUuid,
      required this.intent,
      this.contextSnapshotJson,
      required this.createdAtMs,
      required this.updatedAtMs,
      this.deletedAtMs,
      required this.scopeUid,
      this.unknownFields});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_uuid'] = Variable<String>(sourceUuid);
    map['target_uuid'] = Variable<String>(targetUuid);
    map['intent'] = Variable<String>(intent);
    if (!nullToAbsent || contextSnapshotJson != null) {
      map['context_snapshot_json'] = Variable<String>(contextSnapshotJson);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['scope_uid'] = Variable<String>(scopeUid);
    if (!nullToAbsent || unknownFields != null) {
      map['unknown_fields'] = Variable<String>(unknownFields);
    }
    return map;
  }

  DecisionLinksCompanion toCompanion(bool nullToAbsent) {
    return DecisionLinksCompanion(
      id: Value(id),
      sourceUuid: Value(sourceUuid),
      targetUuid: Value(targetUuid),
      intent: Value(intent),
      contextSnapshotJson: contextSnapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(contextSnapshotJson),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      scopeUid: Value(scopeUid),
      unknownFields: unknownFields == null && nullToAbsent
          ? const Value.absent()
          : Value(unknownFields),
    );
  }

  factory DecisionLinkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DecisionLinkRow(
      id: serializer.fromJson<String>(json['id']),
      sourceUuid: serializer.fromJson<String>(json['sourceUuid']),
      targetUuid: serializer.fromJson<String>(json['targetUuid']),
      intent: serializer.fromJson<String>(json['intent']),
      contextSnapshotJson:
          serializer.fromJson<String?>(json['contextSnapshotJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      unknownFields: serializer.fromJson<String?>(json['unknownFields']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceUuid': serializer.toJson<String>(sourceUuid),
      'targetUuid': serializer.toJson<String>(targetUuid),
      'intent': serializer.toJson<String>(intent),
      'contextSnapshotJson': serializer.toJson<String?>(contextSnapshotJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'scopeUid': serializer.toJson<String>(scopeUid),
      'unknownFields': serializer.toJson<String?>(unknownFields),
    };
  }

  DecisionLinkRow copyWith(
          {String? id,
          String? sourceUuid,
          String? targetUuid,
          String? intent,
          Value<String?> contextSnapshotJson = const Value.absent(),
          int? createdAtMs,
          int? updatedAtMs,
          Value<int?> deletedAtMs = const Value.absent(),
          String? scopeUid,
          Value<String?> unknownFields = const Value.absent()}) =>
      DecisionLinkRow(
        id: id ?? this.id,
        sourceUuid: sourceUuid ?? this.sourceUuid,
        targetUuid: targetUuid ?? this.targetUuid,
        intent: intent ?? this.intent,
        contextSnapshotJson: contextSnapshotJson.present
            ? contextSnapshotJson.value
            : this.contextSnapshotJson,
        createdAtMs: createdAtMs ?? this.createdAtMs,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
        scopeUid: scopeUid ?? this.scopeUid,
        unknownFields:
            unknownFields.present ? unknownFields.value : this.unknownFields,
      );
  DecisionLinkRow copyWithCompanion(DecisionLinksCompanion data) {
    return DecisionLinkRow(
      id: data.id.present ? data.id.value : this.id,
      sourceUuid:
          data.sourceUuid.present ? data.sourceUuid.value : this.sourceUuid,
      targetUuid:
          data.targetUuid.present ? data.targetUuid.value : this.targetUuid,
      intent: data.intent.present ? data.intent.value : this.intent,
      contextSnapshotJson: data.contextSnapshotJson.present
          ? data.contextSnapshotJson.value
          : this.contextSnapshotJson,
      createdAtMs:
          data.createdAtMs.present ? data.createdAtMs.value : this.createdAtMs,
      updatedAtMs:
          data.updatedAtMs.present ? data.updatedAtMs.value : this.updatedAtMs,
      deletedAtMs:
          data.deletedAtMs.present ? data.deletedAtMs.value : this.deletedAtMs,
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      unknownFields: data.unknownFields.present
          ? data.unknownFields.value
          : this.unknownFields,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DecisionLinkRow(')
          ..write('id: $id, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('targetUuid: $targetUuid, ')
          ..write('intent: $intent, ')
          ..write('contextSnapshotJson: $contextSnapshotJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('unknownFields: $unknownFields')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sourceUuid,
      targetUuid,
      intent,
      contextSnapshotJson,
      createdAtMs,
      updatedAtMs,
      deletedAtMs,
      scopeUid,
      unknownFields);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DecisionLinkRow &&
          other.id == this.id &&
          other.sourceUuid == this.sourceUuid &&
          other.targetUuid == this.targetUuid &&
          other.intent == this.intent &&
          other.contextSnapshotJson == this.contextSnapshotJson &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs &&
          other.scopeUid == this.scopeUid &&
          other.unknownFields == this.unknownFields);
}

class DecisionLinksCompanion extends UpdateCompanion<DecisionLinkRow> {
  final Value<String> id;
  final Value<String> sourceUuid;
  final Value<String> targetUuid;
  final Value<String> intent;
  final Value<String?> contextSnapshotJson;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<String> scopeUid;
  final Value<String?> unknownFields;
  final Value<int> rowid;
  const DecisionLinksCompanion({
    this.id = const Value.absent(),
    this.sourceUuid = const Value.absent(),
    this.targetUuid = const Value.absent(),
    this.intent = const Value.absent(),
    this.contextSnapshotJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.scopeUid = const Value.absent(),
    this.unknownFields = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionLinksCompanion.insert({
    required String id,
    required String sourceUuid,
    required String targetUuid,
    required String intent,
    this.contextSnapshotJson = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    required String scopeUid,
    this.unknownFields = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceUuid = Value(sourceUuid),
        targetUuid = Value(targetUuid),
        intent = Value(intent),
        createdAtMs = Value(createdAtMs),
        updatedAtMs = Value(updatedAtMs),
        scopeUid = Value(scopeUid);
  static Insertable<DecisionLinkRow> custom({
    Expression<String>? id,
    Expression<String>? sourceUuid,
    Expression<String>? targetUuid,
    Expression<String>? intent,
    Expression<String>? contextSnapshotJson,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<String>? scopeUid,
    Expression<String>? unknownFields,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceUuid != null) 'source_uuid': sourceUuid,
      if (targetUuid != null) 'target_uuid': targetUuid,
      if (intent != null) 'intent': intent,
      if (contextSnapshotJson != null)
        'context_snapshot_json': contextSnapshotJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (unknownFields != null) 'unknown_fields': unknownFields,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionLinksCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceUuid,
      Value<String>? targetUuid,
      Value<String>? intent,
      Value<String?>? contextSnapshotJson,
      Value<int>? createdAtMs,
      Value<int>? updatedAtMs,
      Value<int?>? deletedAtMs,
      Value<String>? scopeUid,
      Value<String?>? unknownFields,
      Value<int>? rowid}) {
    return DecisionLinksCompanion(
      id: id ?? this.id,
      sourceUuid: sourceUuid ?? this.sourceUuid,
      targetUuid: targetUuid ?? this.targetUuid,
      intent: intent ?? this.intent,
      contextSnapshotJson: contextSnapshotJson ?? this.contextSnapshotJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      scopeUid: scopeUid ?? this.scopeUid,
      unknownFields: unknownFields ?? this.unknownFields,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceUuid.present) {
      map['source_uuid'] = Variable<String>(sourceUuid.value);
    }
    if (targetUuid.present) {
      map['target_uuid'] = Variable<String>(targetUuid.value);
    }
    if (intent.present) {
      map['intent'] = Variable<String>(intent.value);
    }
    if (contextSnapshotJson.present) {
      map['context_snapshot_json'] =
          Variable<String>(contextSnapshotJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (unknownFields.present) {
      map['unknown_fields'] = Variable<String>(unknownFields.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionLinksCompanion(')
          ..write('id: $id, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('targetUuid: $targetUuid, ')
          ..write('intent: $intent, ')
          ..write('contextSnapshotJson: $contextSnapshotJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('unknownFields: $unknownFields, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationTagsTable extends DivinationTags
    with TableInfo<$DivinationTagsTable, DivinationTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagKeyMeta = const VerificationMeta('tagKey');
  @override
  late final GeneratedColumn<String> tagKey = GeneratedColumn<String>(
      'tag_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagValueMeta =
      const VerificationMeta('tagValue');
  @override
  late final GeneratedColumn<String> tagValue = GeneratedColumn<String>(
      'tag_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeUidMeta =
      const VerificationMeta('scopeUid');
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
      'scope_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMsMeta =
      const VerificationMeta('createdAtMs');
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
      'created_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [divinationUuid, domain, tagKey, tagValue, scopeUid, createdAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_tags';
  @override
  VerificationContext validateIntegrity(Insertable<DivinationTagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('tag_key')) {
      context.handle(_tagKeyMeta,
          tagKey.isAcceptableOrUnknown(data['tag_key']!, _tagKeyMeta));
    } else if (isInserting) {
      context.missing(_tagKeyMeta);
    }
    if (data.containsKey('tag_value')) {
      context.handle(_tagValueMeta,
          tagValue.isAcceptableOrUnknown(data['tag_value']!, _tagValueMeta));
    } else if (isInserting) {
      context.missing(_tagValueMeta);
    }
    if (data.containsKey('scope_uid')) {
      context.handle(_scopeUidMeta,
          scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta));
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
          _createdAtMsMeta,
          createdAtMs.isAcceptableOrUnknown(
              data['created_at_ms']!, _createdAtMsMeta));
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {divinationUuid, domain, tagKey, tagValue};
  @override
  DivinationTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationTagRow(
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      tagKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_key'])!,
      tagValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_value'])!,
      scopeUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_uid'])!,
      createdAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at_ms'])!,
    );
  }

  @override
  $DivinationTagsTable createAlias(String alias) {
    return $DivinationTagsTable(attachedDatabase, alias);
  }
}

class DivinationTagRow extends DataClass
    implements Insertable<DivinationTagRow> {
  final String divinationUuid;
  final String domain;
  final String tagKey;
  final String tagValue;
  final String scopeUid;
  final int createdAtMs;
  const DivinationTagRow(
      {required this.divinationUuid,
      required this.domain,
      required this.tagKey,
      required this.tagValue,
      required this.scopeUid,
      required this.createdAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['divination_uuid'] = Variable<String>(divinationUuid);
    map['domain'] = Variable<String>(domain);
    map['tag_key'] = Variable<String>(tagKey);
    map['tag_value'] = Variable<String>(tagValue);
    map['scope_uid'] = Variable<String>(scopeUid);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  DivinationTagsCompanion toCompanion(bool nullToAbsent) {
    return DivinationTagsCompanion(
      divinationUuid: Value(divinationUuid),
      domain: Value(domain),
      tagKey: Value(tagKey),
      tagValue: Value(tagValue),
      scopeUid: Value(scopeUid),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory DivinationTagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationTagRow(
      divinationUuid: serializer.fromJson<String>(json['divinationUuid']),
      domain: serializer.fromJson<String>(json['domain']),
      tagKey: serializer.fromJson<String>(json['tagKey']),
      tagValue: serializer.fromJson<String>(json['tagValue']),
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'divinationUuid': serializer.toJson<String>(divinationUuid),
      'domain': serializer.toJson<String>(domain),
      'tagKey': serializer.toJson<String>(tagKey),
      'tagValue': serializer.toJson<String>(tagValue),
      'scopeUid': serializer.toJson<String>(scopeUid),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  DivinationTagRow copyWith(
          {String? divinationUuid,
          String? domain,
          String? tagKey,
          String? tagValue,
          String? scopeUid,
          int? createdAtMs}) =>
      DivinationTagRow(
        divinationUuid: divinationUuid ?? this.divinationUuid,
        domain: domain ?? this.domain,
        tagKey: tagKey ?? this.tagKey,
        tagValue: tagValue ?? this.tagValue,
        scopeUid: scopeUid ?? this.scopeUid,
        createdAtMs: createdAtMs ?? this.createdAtMs,
      );
  DivinationTagRow copyWithCompanion(DivinationTagsCompanion data) {
    return DivinationTagRow(
      divinationUuid: data.divinationUuid.present
          ? data.divinationUuid.value
          : this.divinationUuid,
      domain: data.domain.present ? data.domain.value : this.domain,
      tagKey: data.tagKey.present ? data.tagKey.value : this.tagKey,
      tagValue: data.tagValue.present ? data.tagValue.value : this.tagValue,
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      createdAtMs:
          data.createdAtMs.present ? data.createdAtMs.value : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationTagRow(')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('domain: $domain, ')
          ..write('tagKey: $tagKey, ')
          ..write('tagValue: $tagValue, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      divinationUuid, domain, tagKey, tagValue, scopeUid, createdAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationTagRow &&
          other.divinationUuid == this.divinationUuid &&
          other.domain == this.domain &&
          other.tagKey == this.tagKey &&
          other.tagValue == this.tagValue &&
          other.scopeUid == this.scopeUid &&
          other.createdAtMs == this.createdAtMs);
}

class DivinationTagsCompanion extends UpdateCompanion<DivinationTagRow> {
  final Value<String> divinationUuid;
  final Value<String> domain;
  final Value<String> tagKey;
  final Value<String> tagValue;
  final Value<String> scopeUid;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const DivinationTagsCompanion({
    this.divinationUuid = const Value.absent(),
    this.domain = const Value.absent(),
    this.tagKey = const Value.absent(),
    this.tagValue = const Value.absent(),
    this.scopeUid = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationTagsCompanion.insert({
    required String divinationUuid,
    required String domain,
    required String tagKey,
    required String tagValue,
    required String scopeUid,
    required int createdAtMs,
    this.rowid = const Value.absent(),
  })  : divinationUuid = Value(divinationUuid),
        domain = Value(domain),
        tagKey = Value(tagKey),
        tagValue = Value(tagValue),
        scopeUid = Value(scopeUid),
        createdAtMs = Value(createdAtMs);
  static Insertable<DivinationTagRow> custom({
    Expression<String>? divinationUuid,
    Expression<String>? domain,
    Expression<String>? tagKey,
    Expression<String>? tagValue,
    Expression<String>? scopeUid,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (domain != null) 'domain': domain,
      if (tagKey != null) 'tag_key': tagKey,
      if (tagValue != null) 'tag_value': tagValue,
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationTagsCompanion copyWith(
      {Value<String>? divinationUuid,
      Value<String>? domain,
      Value<String>? tagKey,
      Value<String>? tagValue,
      Value<String>? scopeUid,
      Value<int>? createdAtMs,
      Value<int>? rowid}) {
    return DivinationTagsCompanion(
      divinationUuid: divinationUuid ?? this.divinationUuid,
      domain: domain ?? this.domain,
      tagKey: tagKey ?? this.tagKey,
      tagValue: tagValue ?? this.tagValue,
      scopeUid: scopeUid ?? this.scopeUid,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (tagKey.present) {
      map['tag_key'] = Variable<String>(tagKey.value);
    }
    if (tagValue.present) {
      map['tag_value'] = Variable<String>(tagValue.value);
    }
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationTagsCompanion(')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('domain: $domain, ')
          ..write('tagKey: $tagKey, ')
          ..write('tagValue: $tagValue, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationTypesTable extends DivinationTypes
    with TableInfo<$DivinationTypesTable, DivinationTypeDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        name,
        description,
        isCustomized,
        isAvailable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_types';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationTypeDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    } else if (isInserting) {
      context.missing(_isCustomizedMeta);
    }
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    } else if (isInserting) {
      context.missing(_isAvailableMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  DivinationTypeDataModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationTypeDataModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
    );
  }

  @override
  $DivinationTypesTable createAlias(String alias) {
    return $DivinationTypesTable(attachedDatabase, alias);
  }
}

class DivinationTypesCompanion
    extends UpdateCompanion<DivinationTypeDataModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> description;
  final Value<bool> isCustomized;
  final Value<bool> isAvailable;
  final Value<int> rowid;
  const DivinationTypesCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationTypesCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String description,
    required bool isCustomized,
    required bool isAvailable,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        name = Value(name),
        description = Value(description),
        isCustomized = Value(isCustomized),
        isAvailable = Value(isAvailable);
  static Insertable<DivinationTypeDataModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isCustomized,
    Expression<bool>? isAvailable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (isAvailable != null) 'is_available': isAvailable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationTypesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? name,
      Value<String>? description,
      Value<bool>? isCustomized,
      Value<bool>? isAvailable,
      Value<int>? rowid}) {
    return DivinationTypesCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustomized: isCustomized ?? this.isCustomized,
      isAvailable: isAvailable ?? this.isAvailable,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isCustomized.present) {
      map['is_customized'] = Variable<bool>(isCustomized.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationTypesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubDivinationTypesTable extends SubDivinationTypes
    with TableInfo<$SubDivinationTypesTable, SubDivinationTypeDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubDivinationTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _hiddenAtMeta =
      const VerificationMeta('hiddenAt');
  @override
  late final GeneratedColumn<DateTime> hiddenAt = GeneratedColumn<DateTime>(
      'hidden_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        lastUpdatedAt,
        deletedAt,
        hiddenAt,
        name,
        isCustomized,
        isAvailable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_sub_divination_types';
  @override
  VerificationContext validateIntegrity(
      Insertable<SubDivinationTypeDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('hidden_at')) {
      context.handle(_hiddenAtMeta,
          hiddenAt.isAcceptableOrUnknown(data['hidden_at']!, _hiddenAtMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    } else if (isInserting) {
      context.missing(_isCustomizedMeta);
    }
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    } else if (isInserting) {
      context.missing(_isAvailableMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SubDivinationTypeDataModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubDivinationTypeDataModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      hiddenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}hidden_at']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
    );
  }

  @override
  $SubDivinationTypesTable createAlias(String alias) {
    return $SubDivinationTypesTable(attachedDatabase, alias);
  }
}

class SubDivinationTypesCompanion
    extends UpdateCompanion<SubDivinationTypeDataModel> {
  final Value<String> uuid;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> hiddenAt;
  final Value<String> name;
  final Value<bool> isCustomized;
  final Value<bool> isAvailable;
  final Value<int> rowid;
  const SubDivinationTypesCompanion({
    this.uuid = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    this.name = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubDivinationTypesCompanion.insert({
    required String uuid,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    required String name,
    required bool isCustomized,
    required bool isAvailable,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        lastUpdatedAt = Value(lastUpdatedAt),
        name = Value(name),
        isCustomized = Value(isCustomized),
        isAvailable = Value(isAvailable);
  static Insertable<SubDivinationTypeDataModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? hiddenAt,
    Expression<String>? name,
    Expression<bool>? isCustomized,
    Expression<bool>? isAvailable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hiddenAt != null) 'hidden_at': hiddenAt,
      if (name != null) 'name': name,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (isAvailable != null) 'is_available': isAvailable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubDivinationTypesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime?>? hiddenAt,
      Value<String>? name,
      Value<bool>? isCustomized,
      Value<bool>? isAvailable,
      Value<int>? rowid}) {
    return SubDivinationTypesCompanion(
      uuid: uuid ?? this.uuid,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      name: name ?? this.name,
      isCustomized: isCustomized ?? this.isCustomized,
      isAvailable: isAvailable ?? this.isAvailable,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hiddenAt.present) {
      map['hidden_at'] = Variable<DateTime>(hiddenAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCustomized.present) {
      map['is_customized'] = Variable<bool>(isCustomized.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubDivinationTypesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('name: $name, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationSubDivinationTypeMappersTable
    extends DivinationSubDivinationTypeMappers
    with
        TableInfo<$DivinationSubDivinationTypeMappersTable,
            DivinationSubDivinationTypeMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationSubDivinationTypeMappersTable(this.attachedDatabase,
      [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeUuidMeta =
      const VerificationMeta('typeUuid');
  @override
  late final GeneratedColumn<String> typeUuid = GeneratedColumn<String>(
      'divination_type_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_divination_types (uuid)'));
  static const VerificationMeta _subTypeUuidMeta =
      const VerificationMeta('subTypeUuid');
  @override
  late final GeneratedColumn<String> subTypeUuid = GeneratedColumn<String>(
      'sub_divination_type_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_sub_divination_types (uuid)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, typeUuid, subTypeUuid, createdAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_sub_divination_type_mappers';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationSubDivinationTypeMapper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('divination_type_uuid')) {
      context.handle(
          _typeUuidMeta,
          typeUuid.isAcceptableOrUnknown(
              data['divination_type_uuid']!, _typeUuidMeta));
    } else if (isInserting) {
      context.missing(_typeUuidMeta);
    }
    if (data.containsKey('sub_divination_type_uuid')) {
      context.handle(
          _subTypeUuidMeta,
          subTypeUuid.isAcceptableOrUnknown(
              data['sub_divination_type_uuid']!, _subTypeUuidMeta));
    } else if (isInserting) {
      context.missing(_subTypeUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DivinationSubDivinationTypeMapper map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationSubDivinationTypeMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      typeUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_type_uuid'])!,
      subTypeUuid: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}sub_divination_type_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DivinationSubDivinationTypeMappersTable createAlias(String alias) {
    return $DivinationSubDivinationTypeMappersTable(attachedDatabase, alias);
  }
}

class DivinationSubDivinationTypeMapper extends DataClass
    implements Insertable<DivinationSubDivinationTypeMapper> {
  final int id;
  final String typeUuid;
  final String subTypeUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const DivinationSubDivinationTypeMapper(
      {required this.id,
      required this.typeUuid,
      required this.subTypeUuid,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['divination_type_uuid'] = Variable<String>(typeUuid);
    map['sub_divination_type_uuid'] = Variable<String>(subTypeUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DivinationSubDivinationTypeMappersCompanion toCompanion(bool nullToAbsent) {
    return DivinationSubDivinationTypeMappersCompanion(
      id: Value(id),
      typeUuid: Value(typeUuid),
      subTypeUuid: Value(subTypeUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DivinationSubDivinationTypeMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationSubDivinationTypeMapper(
      id: serializer.fromJson<int>(json['id']),
      typeUuid: serializer.fromJson<String>(json['typeUuid']),
      subTypeUuid: serializer.fromJson<String>(json['subTypeUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typeUuid': serializer.toJson<String>(typeUuid),
      'subTypeUuid': serializer.toJson<String>(subTypeUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DivinationSubDivinationTypeMapper copyWith(
          {int? id,
          String? typeUuid,
          String? subTypeUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      DivinationSubDivinationTypeMapper(
        id: id ?? this.id,
        typeUuid: typeUuid ?? this.typeUuid,
        subTypeUuid: subTypeUuid ?? this.subTypeUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  DivinationSubDivinationTypeMapper copyWithCompanion(
      DivinationSubDivinationTypeMappersCompanion data) {
    return DivinationSubDivinationTypeMapper(
      id: data.id.present ? data.id.value : this.id,
      typeUuid: data.typeUuid.present ? data.typeUuid.value : this.typeUuid,
      subTypeUuid:
          data.subTypeUuid.present ? data.subTypeUuid.value : this.subTypeUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationSubDivinationTypeMapper(')
          ..write('id: $id, ')
          ..write('typeUuid: $typeUuid, ')
          ..write('subTypeUuid: $subTypeUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, typeUuid, subTypeUuid, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationSubDivinationTypeMapper &&
          other.id == this.id &&
          other.typeUuid == this.typeUuid &&
          other.subTypeUuid == this.subTypeUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class DivinationSubDivinationTypeMappersCompanion
    extends UpdateCompanion<DivinationSubDivinationTypeMapper> {
  final Value<int> id;
  final Value<String> typeUuid;
  final Value<String> subTypeUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const DivinationSubDivinationTypeMappersCompanion({
    this.id = const Value.absent(),
    this.typeUuid = const Value.absent(),
    this.subTypeUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DivinationSubDivinationTypeMappersCompanion.insert({
    this.id = const Value.absent(),
    required String typeUuid,
    required String subTypeUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
  })  : typeUuid = Value(typeUuid),
        subTypeUuid = Value(subTypeUuid),
        createdAt = Value(createdAt);
  static Insertable<DivinationSubDivinationTypeMapper> custom({
    Expression<int>? id,
    Expression<String>? typeUuid,
    Expression<String>? subTypeUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeUuid != null) 'divination_type_uuid': typeUuid,
      if (subTypeUuid != null) 'sub_divination_type_uuid': subTypeUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DivinationSubDivinationTypeMappersCompanion copyWith(
      {Value<int>? id,
      Value<String>? typeUuid,
      Value<String>? subTypeUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt}) {
    return DivinationSubDivinationTypeMappersCompanion(
      id: id ?? this.id,
      typeUuid: typeUuid ?? this.typeUuid,
      subTypeUuid: subTypeUuid ?? this.subTypeUuid,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typeUuid.present) {
      map['divination_type_uuid'] = Variable<String>(typeUuid.value);
    }
    if (subTypeUuid.present) {
      map['sub_divination_type_uuid'] = Variable<String>(subTypeUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationSubDivinationTypeMappersCompanion(')
          ..write('id: $id, ')
          ..write('typeUuid: $typeUuid, ')
          ..write('subTypeUuid: $subTypeUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $DivinationCalendarsTable extends DivinationCalendars
    with TableInfo<$DivinationCalendarsTable, DivinationCalendar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationCalendarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _sourceUuidMeta =
      const VerificationMeta('sourceUuid');
  @override
  late final GeneratedColumn<String> sourceUuid = GeneratedColumn<String>(
      'source_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentTaiYuanUuidMeta =
      const VerificationMeta('currentTaiYuanUuid');
  @override
  late final GeneratedColumn<String> currentTaiYuanUuid =
      GeneratedColumn<String>('current_tai_yuan_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentDaYunUuidMeta =
      const VerificationMeta('currentDaYunUuid');
  @override
  late final GeneratedColumn<String> currentDaYunUuid = GeneratedColumn<String>(
      'current_da_yun_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, sourceUuid, sourceType, currentTaiYuanUuid, currentDaYunUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_calendars';
  @override
  VerificationContext validateIntegrity(Insertable<DivinationCalendar> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('source_uuid')) {
      context.handle(
          _sourceUuidMeta,
          sourceUuid.isAcceptableOrUnknown(
              data['source_uuid']!, _sourceUuidMeta));
    } else if (isInserting) {
      context.missing(_sourceUuidMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('current_tai_yuan_uuid')) {
      context.handle(
          _currentTaiYuanUuidMeta,
          currentTaiYuanUuid.isAcceptableOrUnknown(
              data['current_tai_yuan_uuid']!, _currentTaiYuanUuidMeta));
    }
    if (data.containsKey('current_da_yun_uuid')) {
      context.handle(
          _currentDaYunUuidMeta,
          currentDaYunUuid.isAcceptableOrUnknown(
              data['current_da_yun_uuid']!, _currentDaYunUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  DivinationCalendar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationCalendar(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      sourceUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_uuid'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      currentTaiYuanUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_tai_yuan_uuid']),
      currentDaYunUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_da_yun_uuid']),
    );
  }

  @override
  $DivinationCalendarsTable createAlias(String alias) {
    return $DivinationCalendarsTable(attachedDatabase, alias);
  }
}

class DivinationCalendar extends DataClass
    implements Insertable<DivinationCalendar> {
  final String uuid;
  final String sourceUuid;
  final String sourceType;
  final String? currentTaiYuanUuid;
  final String? currentDaYunUuid;
  const DivinationCalendar(
      {required this.uuid,
      required this.sourceUuid,
      required this.sourceType,
      this.currentTaiYuanUuid,
      this.currentDaYunUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['source_uuid'] = Variable<String>(sourceUuid);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || currentTaiYuanUuid != null) {
      map['current_tai_yuan_uuid'] = Variable<String>(currentTaiYuanUuid);
    }
    if (!nullToAbsent || currentDaYunUuid != null) {
      map['current_da_yun_uuid'] = Variable<String>(currentDaYunUuid);
    }
    return map;
  }

  DivinationCalendarsCompanion toCompanion(bool nullToAbsent) {
    return DivinationCalendarsCompanion(
      uuid: Value(uuid),
      sourceUuid: Value(sourceUuid),
      sourceType: Value(sourceType),
      currentTaiYuanUuid: currentTaiYuanUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTaiYuanUuid),
      currentDaYunUuid: currentDaYunUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(currentDaYunUuid),
    );
  }

  factory DivinationCalendar.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationCalendar(
      uuid: serializer.fromJson<String>(json['uuid']),
      sourceUuid: serializer.fromJson<String>(json['sourceUuid']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      currentTaiYuanUuid:
          serializer.fromJson<String?>(json['currentTaiYuanUuid']),
      currentDaYunUuid: serializer.fromJson<String?>(json['currentDaYunUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'sourceUuid': serializer.toJson<String>(sourceUuid),
      'sourceType': serializer.toJson<String>(sourceType),
      'currentTaiYuanUuid': serializer.toJson<String?>(currentTaiYuanUuid),
      'currentDaYunUuid': serializer.toJson<String?>(currentDaYunUuid),
    };
  }

  DivinationCalendar copyWith(
          {String? uuid,
          String? sourceUuid,
          String? sourceType,
          Value<String?> currentTaiYuanUuid = const Value.absent(),
          Value<String?> currentDaYunUuid = const Value.absent()}) =>
      DivinationCalendar(
        uuid: uuid ?? this.uuid,
        sourceUuid: sourceUuid ?? this.sourceUuid,
        sourceType: sourceType ?? this.sourceType,
        currentTaiYuanUuid: currentTaiYuanUuid.present
            ? currentTaiYuanUuid.value
            : this.currentTaiYuanUuid,
        currentDaYunUuid: currentDaYunUuid.present
            ? currentDaYunUuid.value
            : this.currentDaYunUuid,
      );
  DivinationCalendar copyWithCompanion(DivinationCalendarsCompanion data) {
    return DivinationCalendar(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      sourceUuid:
          data.sourceUuid.present ? data.sourceUuid.value : this.sourceUuid,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      currentTaiYuanUuid: data.currentTaiYuanUuid.present
          ? data.currentTaiYuanUuid.value
          : this.currentTaiYuanUuid,
      currentDaYunUuid: data.currentDaYunUuid.present
          ? data.currentDaYunUuid.value
          : this.currentDaYunUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationCalendar(')
          ..write('uuid: $uuid, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('sourceType: $sourceType, ')
          ..write('currentTaiYuanUuid: $currentTaiYuanUuid, ')
          ..write('currentDaYunUuid: $currentDaYunUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, sourceUuid, sourceType, currentTaiYuanUuid, currentDaYunUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationCalendar &&
          other.uuid == this.uuid &&
          other.sourceUuid == this.sourceUuid &&
          other.sourceType == this.sourceType &&
          other.currentTaiYuanUuid == this.currentTaiYuanUuid &&
          other.currentDaYunUuid == this.currentDaYunUuid);
}

class DivinationCalendarsCompanion extends UpdateCompanion<DivinationCalendar> {
  final Value<String> uuid;
  final Value<String> sourceUuid;
  final Value<String> sourceType;
  final Value<String?> currentTaiYuanUuid;
  final Value<String?> currentDaYunUuid;
  final Value<int> rowid;
  const DivinationCalendarsCompanion({
    this.uuid = const Value.absent(),
    this.sourceUuid = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.currentTaiYuanUuid = const Value.absent(),
    this.currentDaYunUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationCalendarsCompanion.insert({
    required String uuid,
    required String sourceUuid,
    required String sourceType,
    this.currentTaiYuanUuid = const Value.absent(),
    this.currentDaYunUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        sourceUuid = Value(sourceUuid),
        sourceType = Value(sourceType);
  static Insertable<DivinationCalendar> custom({
    Expression<String>? uuid,
    Expression<String>? sourceUuid,
    Expression<String>? sourceType,
    Expression<String>? currentTaiYuanUuid,
    Expression<String>? currentDaYunUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (sourceUuid != null) 'source_uuid': sourceUuid,
      if (sourceType != null) 'source_type': sourceType,
      if (currentTaiYuanUuid != null)
        'current_tai_yuan_uuid': currentTaiYuanUuid,
      if (currentDaYunUuid != null) 'current_da_yun_uuid': currentDaYunUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationCalendarsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? sourceUuid,
      Value<String>? sourceType,
      Value<String?>? currentTaiYuanUuid,
      Value<String?>? currentDaYunUuid,
      Value<int>? rowid}) {
    return DivinationCalendarsCompanion(
      uuid: uuid ?? this.uuid,
      sourceUuid: sourceUuid ?? this.sourceUuid,
      sourceType: sourceType ?? this.sourceType,
      currentTaiYuanUuid: currentTaiYuanUuid ?? this.currentTaiYuanUuid,
      currentDaYunUuid: currentDaYunUuid ?? this.currentDaYunUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (sourceUuid.present) {
      map['source_uuid'] = Variable<String>(sourceUuid.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (currentTaiYuanUuid.present) {
      map['current_tai_yuan_uuid'] = Variable<String>(currentTaiYuanUuid.value);
    }
    if (currentDaYunUuid.present) {
      map['current_da_yun_uuid'] = Variable<String>(currentDaYunUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationCalendarsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('sourceType: $sourceType, ')
          ..write('currentTaiYuanUuid: $currentTaiYuanUuid, ')
          ..write('currentDaYunUuid: $currentDaYunUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimingDivinationsTable extends TimingDivinations
    with TableInfo<$TimingDivinationsTable, TimingDivinationModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimingDivinationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTimeType, int> timingType =
      GeneratedColumn<int>('timing_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTimeType>(
              $TimingDivinationsTable.$convertertimingType);
  static const VerificationMeta _datetimeMeta =
      const VerificationMeta('datetime');
  @override
  late final GeneratedColumn<DateTime> datetime = GeneratedColumn<DateTime>(
      'datetime', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isManualMeta =
      const VerificationMeta('isManual');
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
      'is_manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_manual" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> yearGanZhi =
      GeneratedColumn<int>('year_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$converteryearGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> monthGanZhi =
      GeneratedColumn<int>('month_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$convertermonthGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> dayGanZhi =
      GeneratedColumn<int>('day_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$converterdayGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> timeGanZhi =
      GeneratedColumn<int>('time_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$convertertimeGanZhi);
  static const VerificationMeta _lunarMonthMeta =
      const VerificationMeta('lunarMonth');
  @override
  late final GeneratedColumn<int> lunarMonth = GeneratedColumn<int>(
      'lunar_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isLeapMonthMeta =
      const VerificationMeta('isLeapMonth');
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
      'is_leap_month', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_leap_month" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lunarDayMeta =
      const VerificationMeta('lunarDay');
  @override
  late final GeneratedColumn<int> lunarDay = GeneratedColumn<int>(
      'lunar_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timingInfoUuidMeta =
      const VerificationMeta('timingInfoUuid');
  @override
  late final GeneratedColumn<String> timingInfoUuid = GeneratedColumn<String>(
      'timing_info_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Location?, String> location =
      GeneratedColumn<String>('location_json', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Location?>($TimingDivinationsTable.$converterlocation);
  @override
  late final GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?,
      String> timingInfoListJson = GeneratedColumn<String>(
          'info_list_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false)
      .withConverter<List<DivinationDatetimeModel>?>(
          $TimingDivinationsTable.$convertertimingInfoListJsonn);
  static const VerificationMeta _currentCalendarUuidMeta =
      const VerificationMeta('currentCalendarUuid');
  @override
  late final GeneratedColumn<String> currentCalendarUuid =
      GeneratedColumn<String>('current_calendar_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        divinationUuid,
        timingType,
        datetime,
        isManual,
        yearGanZhi,
        monthGanZhi,
        dayGanZhi,
        timeGanZhi,
        lunarMonth,
        isLeapMonth,
        lunarDay,
        timingInfoUuid,
        location,
        timingInfoListJson,
        currentCalendarUuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_timing_divinations';
  @override
  VerificationContext validateIntegrity(
      Insertable<TimingDivinationModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('datetime')) {
      context.handle(_datetimeMeta,
          datetime.isAcceptableOrUnknown(data['datetime']!, _datetimeMeta));
    } else if (isInserting) {
      context.missing(_datetimeMeta);
    }
    if (data.containsKey('is_manual')) {
      context.handle(_isManualMeta,
          isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta));
    }
    if (data.containsKey('lunar_month')) {
      context.handle(
          _lunarMonthMeta,
          lunarMonth.isAcceptableOrUnknown(
              data['lunar_month']!, _lunarMonthMeta));
    } else if (isInserting) {
      context.missing(_lunarMonthMeta);
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
          _isLeapMonthMeta,
          isLeapMonth.isAcceptableOrUnknown(
              data['is_leap_month']!, _isLeapMonthMeta));
    }
    if (data.containsKey('lunar_day')) {
      context.handle(_lunarDayMeta,
          lunarDay.isAcceptableOrUnknown(data['lunar_day']!, _lunarDayMeta));
    } else if (isInserting) {
      context.missing(_lunarDayMeta);
    }
    if (data.containsKey('timing_info_uuid')) {
      context.handle(
          _timingInfoUuidMeta,
          timingInfoUuid.isAcceptableOrUnknown(
              data['timing_info_uuid']!, _timingInfoUuidMeta));
    } else if (isInserting) {
      context.missing(_timingInfoUuidMeta);
    }
    if (data.containsKey('current_calendar_uuid')) {
      context.handle(
          _currentCalendarUuidMeta,
          currentCalendarUuid.isAcceptableOrUnknown(
              data['current_calendar_uuid']!, _currentCalendarUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  TimingDivinationModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimingDivinationModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      timingType: $TimingDivinationsTable.$convertertimingType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}timing_type'])!),
      datetime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datetime'])!,
      isManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_manual'])!,
      yearGanZhi: $TimingDivinationsTable.$converteryearGanZhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}year_gan_zhi'])!),
      monthGanZhi: $TimingDivinationsTable.$convertermonthGanZhi.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}month_gan_zhi'])!),
      dayGanZhi: $TimingDivinationsTable.$converterdayGanZhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}day_gan_zhi'])!),
      timeGanZhi: $TimingDivinationsTable.$convertertimeGanZhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}time_gan_zhi'])!),
      lunarMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_month'])!,
      isLeapMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_leap_month'])!,
      lunarDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_day'])!,
      timingInfoUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}timing_info_uuid'])!,
      location: $TimingDivinationsTable.$converterlocation.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}location_json'])),
      timingInfoListJson: $TimingDivinationsTable.$convertertimingInfoListJsonn
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}info_list_json'])),
    );
  }

  @override
  $TimingDivinationsTable createAlias(String alias) {
    return $TimingDivinationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DateTimeType, int, int> $convertertimingType =
      const EnumIndexConverter<DateTimeType>(DateTimeType.values);
  static JsonTypeConverter2<JiaZi, int, int> $converteryearGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertermonthGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $converterdayGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertertimeGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static TypeConverter<Location?, String?> $converterlocation =
      const NullableLocationConverter();
  static TypeConverter<List<DivinationDatetimeModel>, String>
      $convertertimingInfoListJson = const DivinationDatetimeModelConverter();
  static TypeConverter<List<DivinationDatetimeModel>?, String?>
      $convertertimingInfoListJsonn =
      NullAwareTypeConverter.wrap($convertertimingInfoListJson);
}

class TimingDivinationsCompanion
    extends UpdateCompanion<TimingDivinationModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> divinationUuid;
  final Value<DateTimeType> timingType;
  final Value<DateTime> datetime;
  final Value<bool> isManual;
  final Value<JiaZi> yearGanZhi;
  final Value<JiaZi> monthGanZhi;
  final Value<JiaZi> dayGanZhi;
  final Value<JiaZi> timeGanZhi;
  final Value<int> lunarMonth;
  final Value<bool> isLeapMonth;
  final Value<int> lunarDay;
  final Value<String> timingInfoUuid;
  final Value<Location?> location;
  final Value<List<DivinationDatetimeModel>?> timingInfoListJson;
  final Value<String?> currentCalendarUuid;
  final Value<int> rowid;
  const TimingDivinationsCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.timingType = const Value.absent(),
    this.datetime = const Value.absent(),
    this.isManual = const Value.absent(),
    this.yearGanZhi = const Value.absent(),
    this.monthGanZhi = const Value.absent(),
    this.dayGanZhi = const Value.absent(),
    this.timeGanZhi = const Value.absent(),
    this.lunarMonth = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.lunarDay = const Value.absent(),
    this.timingInfoUuid = const Value.absent(),
    this.location = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.currentCalendarUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimingDivinationsCompanion.insert({
    required String uuid,
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String divinationUuid,
    required DateTimeType timingType,
    required DateTime datetime,
    this.isManual = const Value.absent(),
    required JiaZi yearGanZhi,
    required JiaZi monthGanZhi,
    required JiaZi dayGanZhi,
    required JiaZi timeGanZhi,
    required int lunarMonth,
    this.isLeapMonth = const Value.absent(),
    required int lunarDay,
    required String timingInfoUuid,
    this.location = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.currentCalendarUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        divinationUuid = Value(divinationUuid),
        timingType = Value(timingType),
        datetime = Value(datetime),
        yearGanZhi = Value(yearGanZhi),
        monthGanZhi = Value(monthGanZhi),
        dayGanZhi = Value(dayGanZhi),
        timeGanZhi = Value(timeGanZhi),
        lunarMonth = Value(lunarMonth),
        lunarDay = Value(lunarDay),
        timingInfoUuid = Value(timingInfoUuid);
  static Insertable<TimingDivinationModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? divinationUuid,
    Expression<int>? timingType,
    Expression<DateTime>? datetime,
    Expression<bool>? isManual,
    Expression<int>? yearGanZhi,
    Expression<int>? monthGanZhi,
    Expression<int>? dayGanZhi,
    Expression<int>? timeGanZhi,
    Expression<int>? lunarMonth,
    Expression<bool>? isLeapMonth,
    Expression<int>? lunarDay,
    Expression<String>? timingInfoUuid,
    Expression<String>? location,
    Expression<String>? timingInfoListJson,
    Expression<String>? currentCalendarUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (timingType != null) 'timing_type': timingType,
      if (datetime != null) 'datetime': datetime,
      if (isManual != null) 'is_manual': isManual,
      if (yearGanZhi != null) 'year_gan_zhi': yearGanZhi,
      if (monthGanZhi != null) 'month_gan_zhi': monthGanZhi,
      if (dayGanZhi != null) 'day_gan_zhi': dayGanZhi,
      if (timeGanZhi != null) 'time_gan_zhi': timeGanZhi,
      if (lunarMonth != null) 'lunar_month': lunarMonth,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (lunarDay != null) 'lunar_day': lunarDay,
      if (timingInfoUuid != null) 'timing_info_uuid': timingInfoUuid,
      if (location != null) 'location_json': location,
      if (timingInfoListJson != null) 'info_list_json': timingInfoListJson,
      if (currentCalendarUuid != null)
        'current_calendar_uuid': currentCalendarUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimingDivinationsCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? divinationUuid,
      Value<DateTimeType>? timingType,
      Value<DateTime>? datetime,
      Value<bool>? isManual,
      Value<JiaZi>? yearGanZhi,
      Value<JiaZi>? monthGanZhi,
      Value<JiaZi>? dayGanZhi,
      Value<JiaZi>? timeGanZhi,
      Value<int>? lunarMonth,
      Value<bool>? isLeapMonth,
      Value<int>? lunarDay,
      Value<String>? timingInfoUuid,
      Value<Location?>? location,
      Value<List<DivinationDatetimeModel>?>? timingInfoListJson,
      Value<String?>? currentCalendarUuid,
      Value<int>? rowid}) {
    return TimingDivinationsCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      timingType: timingType ?? this.timingType,
      datetime: datetime ?? this.datetime,
      isManual: isManual ?? this.isManual,
      yearGanZhi: yearGanZhi ?? this.yearGanZhi,
      monthGanZhi: monthGanZhi ?? this.monthGanZhi,
      dayGanZhi: dayGanZhi ?? this.dayGanZhi,
      timeGanZhi: timeGanZhi ?? this.timeGanZhi,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      timingInfoUuid: timingInfoUuid ?? this.timingInfoUuid,
      location: location ?? this.location,
      timingInfoListJson: timingInfoListJson ?? this.timingInfoListJson,
      currentCalendarUuid: currentCalendarUuid ?? this.currentCalendarUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (timingType.present) {
      map['timing_type'] = Variable<int>(
          $TimingDivinationsTable.$convertertimingType.toSql(timingType.value));
    }
    if (datetime.present) {
      map['datetime'] = Variable<DateTime>(datetime.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (yearGanZhi.present) {
      map['year_gan_zhi'] = Variable<int>(
          $TimingDivinationsTable.$converteryearGanZhi.toSql(yearGanZhi.value));
    }
    if (monthGanZhi.present) {
      map['month_gan_zhi'] = Variable<int>($TimingDivinationsTable
          .$convertermonthGanZhi
          .toSql(monthGanZhi.value));
    }
    if (dayGanZhi.present) {
      map['day_gan_zhi'] = Variable<int>(
          $TimingDivinationsTable.$converterdayGanZhi.toSql(dayGanZhi.value));
    }
    if (timeGanZhi.present) {
      map['time_gan_zhi'] = Variable<int>(
          $TimingDivinationsTable.$convertertimeGanZhi.toSql(timeGanZhi.value));
    }
    if (lunarMonth.present) {
      map['lunar_month'] = Variable<int>(lunarMonth.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (lunarDay.present) {
      map['lunar_day'] = Variable<int>(lunarDay.value);
    }
    if (timingInfoUuid.present) {
      map['timing_info_uuid'] = Variable<String>(timingInfoUuid.value);
    }
    if (location.present) {
      map['location_json'] = Variable<String>(
          $TimingDivinationsTable.$converterlocation.toSql(location.value));
    }
    if (timingInfoListJson.present) {
      map['info_list_json'] = Variable<String>($TimingDivinationsTable
          .$convertertimingInfoListJsonn
          .toSql(timingInfoListJson.value));
    }
    if (currentCalendarUuid.present) {
      map['current_calendar_uuid'] =
          Variable<String>(currentCalendarUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimingDivinationsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('timingType: $timingType, ')
          ..write('datetime: $datetime, ')
          ..write('isManual: $isManual, ')
          ..write('yearGanZhi: $yearGanZhi, ')
          ..write('monthGanZhi: $monthGanZhi, ')
          ..write('dayGanZhi: $dayGanZhi, ')
          ..write('timeGanZhi: $timeGanZhi, ')
          ..write('lunarMonth: $lunarMonth, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('lunarDay: $lunarDay, ')
          ..write('timingInfoUuid: $timingInfoUuid, ')
          ..write('location: $location, ')
          ..write('timingInfoListJson: $timingInfoListJson, ')
          ..write('currentCalendarUuid: $currentCalendarUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PanelsTable extends Panels with TableInfo<$PanelsTable, Panel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PanelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<EnumPanelType, int> panelType =
      GeneratedColumn<int>('panel_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<EnumPanelType>($PanelsTable.$converterpanelType);
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<int> skillId = GeneratedColumn<int>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _divinateTypeMeta =
      const VerificationMeta('divinateType');
  @override
  late final GeneratedColumn<String> divinateType = GeneratedColumn<String>(
      'divinate_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _divinateUuidMeta =
      const VerificationMeta('divinateUuid');
  @override
  late final GeneratedColumn<String> divinateUuid = GeneratedColumn<String>(
      'divinate_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        createdAt,
        lastUpdatedAt,
        deletedAt,
        uuid,
        panelType,
        skillId,
        divinateType,
        divinateUuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_panels';
  @override
  VerificationContext validateIntegrity(Insertable<Panel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('divinate_type')) {
      context.handle(
          _divinateTypeMeta,
          divinateType.isAcceptableOrUnknown(
              data['divinate_type']!, _divinateTypeMeta));
    } else if (isInserting) {
      context.missing(_divinateTypeMeta);
    }
    if (data.containsKey('divinate_uuid')) {
      context.handle(
          _divinateUuidMeta,
          divinateUuid.isAcceptableOrUnknown(
              data['divinate_uuid']!, _divinateUuidMeta));
    } else if (isInserting) {
      context.missing(_divinateUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Panel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Panel(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      panelType: $PanelsTable.$converterpanelType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}panel_type'])!),
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_id'])!,
      divinateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}divinate_type'])!,
      divinateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}divinate_uuid'])!,
    );
  }

  @override
  $PanelsTable createAlias(String alias) {
    return $PanelsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EnumPanelType, int, int> $converterpanelType =
      const EnumIndexConverter<EnumPanelType>(EnumPanelType.values);
}

class Panel extends DataClass implements Insertable<Panel> {
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String uuid;
  final EnumPanelType panelType;
  final int skillId;
  final String divinateType;
  final String divinateUuid;
  const Panel(
      {required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.uuid,
      required this.panelType,
      required this.skillId,
      required this.divinateType,
      required this.divinateUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['uuid'] = Variable<String>(uuid);
    {
      map['panel_type'] =
          Variable<int>($PanelsTable.$converterpanelType.toSql(panelType));
    }
    map['skill_id'] = Variable<int>(skillId);
    map['divinate_type'] = Variable<String>(divinateType);
    map['divinate_uuid'] = Variable<String>(divinateUuid);
    return map;
  }

  PanelsCompanion toCompanion(bool nullToAbsent) {
    return PanelsCompanion(
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      uuid: Value(uuid),
      panelType: Value(panelType),
      skillId: Value(skillId),
      divinateType: Value(divinateType),
      divinateUuid: Value(divinateUuid),
    );
  }

  factory Panel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Panel(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      panelType: $PanelsTable.$converterpanelType
          .fromJson(serializer.fromJson<int>(json['panelType'])),
      skillId: serializer.fromJson<int>(json['skillId']),
      divinateType: serializer.fromJson<String>(json['divinateType']),
      divinateUuid: serializer.fromJson<String>(json['divinateUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'uuid': serializer.toJson<String>(uuid),
      'panelType': serializer
          .toJson<int>($PanelsTable.$converterpanelType.toJson(panelType)),
      'skillId': serializer.toJson<int>(skillId),
      'divinateType': serializer.toJson<String>(divinateType),
      'divinateUuid': serializer.toJson<String>(divinateUuid),
    };
  }

  Panel copyWith(
          {DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? uuid,
          EnumPanelType? panelType,
          int? skillId,
          String? divinateType,
          String? divinateUuid}) =>
      Panel(
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        uuid: uuid ?? this.uuid,
        panelType: panelType ?? this.panelType,
        skillId: skillId ?? this.skillId,
        divinateType: divinateType ?? this.divinateType,
        divinateUuid: divinateUuid ?? this.divinateUuid,
      );
  Panel copyWithCompanion(PanelsCompanion data) {
    return Panel(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      panelType: data.panelType.present ? data.panelType.value : this.panelType,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      divinateType: data.divinateType.present
          ? data.divinateType.value
          : this.divinateType,
      divinateUuid: data.divinateUuid.present
          ? data.divinateUuid.value
          : this.divinateUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Panel(')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('uuid: $uuid, ')
          ..write('panelType: $panelType, ')
          ..write('skillId: $skillId, ')
          ..write('divinateType: $divinateType, ')
          ..write('divinateUuid: $divinateUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, lastUpdatedAt, deletedAt, uuid,
      panelType, skillId, divinateType, divinateUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Panel &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.uuid == this.uuid &&
          other.panelType == this.panelType &&
          other.skillId == this.skillId &&
          other.divinateType == this.divinateType &&
          other.divinateUuid == this.divinateUuid);
}

class PanelsCompanion extends UpdateCompanion<Panel> {
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> uuid;
  final Value<EnumPanelType> panelType;
  final Value<int> skillId;
  final Value<String> divinateType;
  final Value<String> divinateUuid;
  final Value<int> rowid;
  const PanelsCompanion({
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.panelType = const Value.absent(),
    this.skillId = const Value.absent(),
    this.divinateType = const Value.absent(),
    this.divinateUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PanelsCompanion.insert({
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String uuid,
    required EnumPanelType panelType,
    required int skillId,
    required String divinateType,
    required String divinateUuid,
    this.rowid = const Value.absent(),
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        uuid = Value(uuid),
        panelType = Value(panelType),
        skillId = Value(skillId),
        divinateType = Value(divinateType),
        divinateUuid = Value(divinateUuid);
  static Insertable<Panel> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? uuid,
    Expression<int>? panelType,
    Expression<int>? skillId,
    Expression<String>? divinateType,
    Expression<String>? divinateUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (uuid != null) 'uuid': uuid,
      if (panelType != null) 'panel_type': panelType,
      if (skillId != null) 'skill_id': skillId,
      if (divinateType != null) 'divinate_type': divinateType,
      if (divinateUuid != null) 'divinate_uuid': divinateUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PanelsCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? uuid,
      Value<EnumPanelType>? panelType,
      Value<int>? skillId,
      Value<String>? divinateType,
      Value<String>? divinateUuid,
      Value<int>? rowid}) {
    return PanelsCompanion(
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      uuid: uuid ?? this.uuid,
      panelType: panelType ?? this.panelType,
      skillId: skillId ?? this.skillId,
      divinateType: divinateType ?? this.divinateType,
      divinateUuid: divinateUuid ?? this.divinateUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (panelType.present) {
      map['panel_type'] = Variable<int>(
          $PanelsTable.$converterpanelType.toSql(panelType.value));
    }
    if (skillId.present) {
      map['skill_id'] = Variable<int>(skillId.value);
    }
    if (divinateType.present) {
      map['divinate_type'] = Variable<String>(divinateType.value);
    }
    if (divinateUuid.present) {
      map['divinate_uuid'] = Variable<String>(divinateUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PanelsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('uuid: $uuid, ')
          ..write('panelType: $panelType, ')
          ..write('skillId: $skillId, ')
          ..write('divinateType: $divinateType, ')
          ..write('divinateUuid: $divinateUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationPanelMappersTable extends DivinationPanelMappers
    with TableInfo<$DivinationPanelMappersTable, DivinationPanelMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationPanelMappersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _panelUuidMeta =
      const VerificationMeta('panelUuid');
  @override
  late final GeneratedColumn<String> panelUuid = GeneratedColumn<String>(
      'panel_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, divinationUuid, panelUuid, createdAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_panel_mappers';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationPanelMapper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('panel_uuid')) {
      context.handle(_panelUuidMeta,
          panelUuid.isAcceptableOrUnknown(data['panel_uuid']!, _panelUuidMeta));
    } else if (isInserting) {
      context.missing(_panelUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DivinationPanelMapper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationPanelMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      panelUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DivinationPanelMappersTable createAlias(String alias) {
    return $DivinationPanelMappersTable(attachedDatabase, alias);
  }
}

class DivinationPanelMapper extends DataClass
    implements Insertable<DivinationPanelMapper> {
  final int id;
  final String divinationUuid;
  final String panelUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const DivinationPanelMapper(
      {required this.id,
      required this.divinationUuid,
      required this.panelUuid,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['divination_uuid'] = Variable<String>(divinationUuid);
    map['panel_uuid'] = Variable<String>(panelUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DivinationPanelMappersCompanion toCompanion(bool nullToAbsent) {
    return DivinationPanelMappersCompanion(
      id: Value(id),
      divinationUuid: Value(divinationUuid),
      panelUuid: Value(panelUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DivinationPanelMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationPanelMapper(
      id: serializer.fromJson<int>(json['id']),
      divinationUuid: serializer.fromJson<String>(json['divinationUuid']),
      panelUuid: serializer.fromJson<String>(json['panelUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'divinationUuid': serializer.toJson<String>(divinationUuid),
      'panelUuid': serializer.toJson<String>(panelUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DivinationPanelMapper copyWith(
          {int? id,
          String? divinationUuid,
          String? panelUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      DivinationPanelMapper(
        id: id ?? this.id,
        divinationUuid: divinationUuid ?? this.divinationUuid,
        panelUuid: panelUuid ?? this.panelUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  DivinationPanelMapper copyWithCompanion(
      DivinationPanelMappersCompanion data) {
    return DivinationPanelMapper(
      id: data.id.present ? data.id.value : this.id,
      divinationUuid: data.divinationUuid.present
          ? data.divinationUuid.value
          : this.divinationUuid,
      panelUuid: data.panelUuid.present ? data.panelUuid.value : this.panelUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationPanelMapper(')
          ..write('id: $id, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, divinationUuid, panelUuid, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationPanelMapper &&
          other.id == this.id &&
          other.divinationUuid == this.divinationUuid &&
          other.panelUuid == this.panelUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class DivinationPanelMappersCompanion
    extends UpdateCompanion<DivinationPanelMapper> {
  final Value<int> id;
  final Value<String> divinationUuid;
  final Value<String> panelUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const DivinationPanelMappersCompanion({
    this.id = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.panelUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DivinationPanelMappersCompanion.insert({
    this.id = const Value.absent(),
    required String divinationUuid,
    required String panelUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
  })  : divinationUuid = Value(divinationUuid),
        panelUuid = Value(panelUuid),
        createdAt = Value(createdAt);
  static Insertable<DivinationPanelMapper> custom({
    Expression<int>? id,
    Expression<String>? divinationUuid,
    Expression<String>? panelUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (panelUuid != null) 'panel_uuid': panelUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DivinationPanelMappersCompanion copyWith(
      {Value<int>? id,
      Value<String>? divinationUuid,
      Value<String>? panelUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt}) {
    return DivinationPanelMappersCompanion(
      id: id ?? this.id,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      panelUuid: panelUuid ?? this.panelUuid,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (panelUuid.present) {
      map['panel_uuid'] = Variable<String>(panelUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationPanelMappersCompanion(')
          ..write('id: $id, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PanelSkillClassMappersTable extends PanelSkillClassMappers
    with TableInfo<$PanelSkillClassMappersTable, PanelSkillClassMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PanelSkillClassMappersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _panelUuidMeta =
      const VerificationMeta('panelUuid');
  @override
  late final GeneratedColumn<String> panelUuid = GeneratedColumn<String>(
      'panel_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skillClassUuidMeta =
      const VerificationMeta('skillClassUuid');
  @override
  late final GeneratedColumn<String> skillClassUuid = GeneratedColumn<String>(
      'skill_class_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, panelUuid, skillClassUuid, createdAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_panel_skill_class_mapper';
  @override
  VerificationContext validateIntegrity(
      Insertable<PanelSkillClassMapper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('panel_uuid')) {
      context.handle(_panelUuidMeta,
          panelUuid.isAcceptableOrUnknown(data['panel_uuid']!, _panelUuidMeta));
    } else if (isInserting) {
      context.missing(_panelUuidMeta);
    }
    if (data.containsKey('skill_class_uuid')) {
      context.handle(
          _skillClassUuidMeta,
          skillClassUuid.isAcceptableOrUnknown(
              data['skill_class_uuid']!, _skillClassUuidMeta));
    } else if (isInserting) {
      context.missing(_skillClassUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PanelSkillClassMapper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PanelSkillClassMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      panelUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_uuid'])!,
      skillClassUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}skill_class_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PanelSkillClassMappersTable createAlias(String alias) {
    return $PanelSkillClassMappersTable(attachedDatabase, alias);
  }
}

class PanelSkillClassMapper extends DataClass
    implements Insertable<PanelSkillClassMapper> {
  final int id;
  final String panelUuid;
  final String skillClassUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const PanelSkillClassMapper(
      {required this.id,
      required this.panelUuid,
      required this.skillClassUuid,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['panel_uuid'] = Variable<String>(panelUuid);
    map['skill_class_uuid'] = Variable<String>(skillClassUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PanelSkillClassMappersCompanion toCompanion(bool nullToAbsent) {
    return PanelSkillClassMappersCompanion(
      id: Value(id),
      panelUuid: Value(panelUuid),
      skillClassUuid: Value(skillClassUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PanelSkillClassMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PanelSkillClassMapper(
      id: serializer.fromJson<int>(json['id']),
      panelUuid: serializer.fromJson<String>(json['panelUuid']),
      skillClassUuid: serializer.fromJson<String>(json['skillClassUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'panelUuid': serializer.toJson<String>(panelUuid),
      'skillClassUuid': serializer.toJson<String>(skillClassUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PanelSkillClassMapper copyWith(
          {int? id,
          String? panelUuid,
          String? skillClassUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      PanelSkillClassMapper(
        id: id ?? this.id,
        panelUuid: panelUuid ?? this.panelUuid,
        skillClassUuid: skillClassUuid ?? this.skillClassUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  PanelSkillClassMapper copyWithCompanion(
      PanelSkillClassMappersCompanion data) {
    return PanelSkillClassMapper(
      id: data.id.present ? data.id.value : this.id,
      panelUuid: data.panelUuid.present ? data.panelUuid.value : this.panelUuid,
      skillClassUuid: data.skillClassUuid.present
          ? data.skillClassUuid.value
          : this.skillClassUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PanelSkillClassMapper(')
          ..write('id: $id, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('skillClassUuid: $skillClassUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, panelUuid, skillClassUuid, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PanelSkillClassMapper &&
          other.id == this.id &&
          other.panelUuid == this.panelUuid &&
          other.skillClassUuid == this.skillClassUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class PanelSkillClassMappersCompanion
    extends UpdateCompanion<PanelSkillClassMapper> {
  final Value<int> id;
  final Value<String> panelUuid;
  final Value<String> skillClassUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const PanelSkillClassMappersCompanion({
    this.id = const Value.absent(),
    this.panelUuid = const Value.absent(),
    this.skillClassUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PanelSkillClassMappersCompanion.insert({
    this.id = const Value.absent(),
    required String panelUuid,
    required String skillClassUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
  })  : panelUuid = Value(panelUuid),
        skillClassUuid = Value(skillClassUuid),
        createdAt = Value(createdAt);
  static Insertable<PanelSkillClassMapper> custom({
    Expression<int>? id,
    Expression<String>? panelUuid,
    Expression<String>? skillClassUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (panelUuid != null) 'panel_uuid': panelUuid,
      if (skillClassUuid != null) 'skill_class_uuid': skillClassUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  PanelSkillClassMappersCompanion copyWith(
      {Value<int>? id,
      Value<String>? panelUuid,
      Value<String>? skillClassUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt}) {
    return PanelSkillClassMappersCompanion(
      id: id ?? this.id,
      panelUuid: panelUuid ?? this.panelUuid,
      skillClassUuid: skillClassUuid ?? this.skillClassUuid,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (panelUuid.present) {
      map['panel_uuid'] = Variable<String>(panelUuid.value);
    }
    if (skillClassUuid.present) {
      map['skill_class_uuid'] = Variable<String>(skillClassUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PanelSkillClassMappersCompanion(')
          ..write('id: $id, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('skillClassUuid: $skillClassUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $SkillsTable extends Skills with TableInfo<$SkillsTable, Skill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionsMeta =
      const VerificationMeta('descriptions');
  @override
  late final GeneratedColumn<String> descriptions = GeneratedColumn<String>(
      'descriptions', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        isAvailable,
        name,
        descriptions
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_skills';
  @override
  VerificationContext validateIntegrity(Insertable<Skill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    } else if (isInserting) {
      context.missing(_isAvailableMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('descriptions')) {
      context.handle(
          _descriptionsMeta,
          descriptions.isAcceptableOrUnknown(
              data['descriptions']!, _descriptionsMeta));
    } else if (isInserting) {
      context.missing(_descriptionsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Skill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      descriptions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descriptions'])!,
    );
  }

  @override
  $SkillsTable createAlias(String alias) {
    return $SkillsTable(attachedDatabase, alias);
  }
}

class Skill extends DataClass implements Insertable<Skill> {
  final int id;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final bool isAvailable;
  final String name;
  final String descriptions;
  const Skill(
      {required this.id,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.isAvailable,
      required this.name,
      required this.descriptions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_available'] = Variable<bool>(isAvailable);
    map['name'] = Variable<String>(name);
    map['descriptions'] = Variable<String>(descriptions);
    return map;
  }

  SkillsCompanion toCompanion(bool nullToAbsent) {
    return SkillsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isAvailable: Value(isAvailable),
      name: Value(name),
      descriptions: Value(descriptions),
    );
  }

  factory Skill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skill(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      name: serializer.fromJson<String>(json['name']),
      descriptions: serializer.fromJson<String>(json['descriptions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'name': serializer.toJson<String>(name),
      'descriptions': serializer.toJson<String>(descriptions),
    };
  }

  Skill copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? isAvailable,
          String? name,
          String? descriptions}) =>
      Skill(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isAvailable: isAvailable ?? this.isAvailable,
        name: name ?? this.name,
        descriptions: descriptions ?? this.descriptions,
      );
  Skill copyWithCompanion(SkillsCompanion data) {
    return Skill(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isAvailable:
          data.isAvailable.present ? data.isAvailable.value : this.isAvailable,
      name: data.name.present ? data.name.value : this.name,
      descriptions: data.descriptions.present
          ? data.descriptions.value
          : this.descriptions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Skill(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('name: $name, ')
          ..write('descriptions: $descriptions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, lastUpdatedAt, deletedAt, isAvailable, name, descriptions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skill &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isAvailable == this.isAvailable &&
          other.name == this.name &&
          other.descriptions == this.descriptions);
}

class SkillsCompanion extends UpdateCompanion<Skill> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isAvailable;
  final Value<String> name;
  final Value<String> descriptions;
  const SkillsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.name = const Value.absent(),
    this.descriptions = const Value.absent(),
  });
  SkillsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required bool isAvailable,
    required String name,
    required String descriptions,
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        isAvailable = Value(isAvailable),
        name = Value(name),
        descriptions = Value(descriptions);
  static Insertable<Skill> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isAvailable,
    Expression<String>? name,
    Expression<String>? descriptions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isAvailable != null) 'is_available': isAvailable,
      if (name != null) 'name': name,
      if (descriptions != null) 'descriptions': descriptions,
    });
  }

  SkillsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? isAvailable,
      Value<String>? name,
      Value<String>? descriptions}) {
    return SkillsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      name: name ?? this.name,
      descriptions: descriptions ?? this.descriptions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (descriptions.present) {
      map['descriptions'] = Variable<String>(descriptions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('name: $name, ')
          ..write('descriptions: $descriptions')
          ..write(')'))
        .toString();
  }
}

class $SkillClassesTable extends SkillClasses
    with TableInfo<$SkillClassesTable, SkillClass> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<int> skillId = GeneratedColumn<int>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specificationMeta =
      const VerificationMeta('specification');
  @override
  late final GeneratedColumn<String> specification = GeneratedColumn<String>(
      'specification', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _featureMeta =
      const VerificationMeta('feature');
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
      'feature', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        skillId,
        name,
        specification,
        feature,
        isCustomized
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_skill_classes';
  @override
  VerificationContext validateIntegrity(Insertable<SkillClass> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('specification')) {
      context.handle(
          _specificationMeta,
          specification.isAcceptableOrUnknown(
              data['specification']!, _specificationMeta));
    } else if (isInserting) {
      context.missing(_specificationMeta);
    }
    if (data.containsKey('feature')) {
      context.handle(_featureMeta,
          feature.isAcceptableOrUnknown(data['feature']!, _featureMeta));
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    } else if (isInserting) {
      context.missing(_isCustomizedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SkillClass map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkillClass(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      specification: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specification'])!,
      feature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feature'])!,
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
    );
  }

  @override
  $SkillClassesTable createAlias(String alias) {
    return $SkillClassesTable(attachedDatabase, alias);
  }
}

class SkillClass extends DataClass implements Insertable<SkillClass> {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final int skillId;
  final String name;
  final String specification;
  final String feature;
  final bool isCustomized;
  const SkillClass(
      {required this.uuid,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.skillId,
      required this.name,
      required this.specification,
      required this.feature,
      required this.isCustomized});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['skill_id'] = Variable<int>(skillId);
    map['name'] = Variable<String>(name);
    map['specification'] = Variable<String>(specification);
    map['feature'] = Variable<String>(feature);
    map['is_customized'] = Variable<bool>(isCustomized);
    return map;
  }

  SkillClassesCompanion toCompanion(bool nullToAbsent) {
    return SkillClassesCompanion(
      uuid: Value(uuid),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      skillId: Value(skillId),
      name: Value(name),
      specification: Value(specification),
      feature: Value(feature),
      isCustomized: Value(isCustomized),
    );
  }

  factory SkillClass.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkillClass(
      uuid: serializer.fromJson<String>(json['uuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      skillId: serializer.fromJson<int>(json['skillId']),
      name: serializer.fromJson<String>(json['name']),
      specification: serializer.fromJson<String>(json['specification']),
      feature: serializer.fromJson<String>(json['feature']),
      isCustomized: serializer.fromJson<bool>(json['isCustomized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'skillId': serializer.toJson<int>(skillId),
      'name': serializer.toJson<String>(name),
      'specification': serializer.toJson<String>(specification),
      'feature': serializer.toJson<String>(feature),
      'isCustomized': serializer.toJson<bool>(isCustomized),
    };
  }

  SkillClass copyWith(
          {String? uuid,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? skillId,
          String? name,
          String? specification,
          String? feature,
          bool? isCustomized}) =>
      SkillClass(
        uuid: uuid ?? this.uuid,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        skillId: skillId ?? this.skillId,
        name: name ?? this.name,
        specification: specification ?? this.specification,
        feature: feature ?? this.feature,
        isCustomized: isCustomized ?? this.isCustomized,
      );
  SkillClass copyWithCompanion(SkillClassesCompanion data) {
    return SkillClass(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      name: data.name.present ? data.name.value : this.name,
      specification: data.specification.present
          ? data.specification.value
          : this.specification,
      feature: data.feature.present ? data.feature.value : this.feature,
      isCustomized: data.isCustomized.present
          ? data.isCustomized.value
          : this.isCustomized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkillClass(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('skillId: $skillId, ')
          ..write('name: $name, ')
          ..write('specification: $specification, ')
          ..write('feature: $feature, ')
          ..write('isCustomized: $isCustomized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, createdAt, lastUpdatedAt, deletedAt,
      skillId, name, specification, feature, isCustomized);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkillClass &&
          other.uuid == this.uuid &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.skillId == this.skillId &&
          other.name == this.name &&
          other.specification == this.specification &&
          other.feature == this.feature &&
          other.isCustomized == this.isCustomized);
}

class SkillClassesCompanion extends UpdateCompanion<SkillClass> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> skillId;
  final Value<String> name;
  final Value<String> specification;
  final Value<String> feature;
  final Value<bool> isCustomized;
  final Value<int> rowid;
  const SkillClassesCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.skillId = const Value.absent(),
    this.name = const Value.absent(),
    this.specification = const Value.absent(),
    this.feature = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkillClassesCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required int skillId,
    required String name,
    required String specification,
    required String feature,
    required bool isCustomized,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        skillId = Value(skillId),
        name = Value(name),
        specification = Value(specification),
        feature = Value(feature),
        isCustomized = Value(isCustomized);
  static Insertable<SkillClass> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? skillId,
    Expression<String>? name,
    Expression<String>? specification,
    Expression<String>? feature,
    Expression<bool>? isCustomized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (skillId != null) 'skill_id': skillId,
      if (name != null) 'name': name,
      if (specification != null) 'specification': specification,
      if (feature != null) 'feature': feature,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkillClassesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? skillId,
      Value<String>? name,
      Value<String>? specification,
      Value<String>? feature,
      Value<bool>? isCustomized,
      Value<int>? rowid}) {
    return SkillClassesCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      skillId: skillId ?? this.skillId,
      name: name ?? this.name,
      specification: specification ?? this.specification,
      feature: feature ?? this.feature,
      isCustomized: isCustomized ?? this.isCustomized,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<int>(skillId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (specification.present) {
      map['specification'] = Variable<String>(specification.value);
    }
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (isCustomized.present) {
      map['is_customized'] = Variable<bool>(isCustomized.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillClassesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('skillId: $skillId, ')
          ..write('name: $name, ')
          ..write('specification: $specification, ')
          ..write('feature: $feature, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DaYunRecordsTable extends DaYunRecords
    with TableInfo<$DaYunRecordsTable, DaYunRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaYunRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _sourceUuidMeta =
      const VerificationMeta('sourceUuid');
  @override
  late final GeneratedColumn<String> sourceUuid = GeneratedColumn<String>(
      'source_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jieQiTypeMeta =
      const VerificationMeta('jieQiType');
  @override
  late final GeneratedColumn<String> jieQiType = GeneratedColumn<String>(
      'jie_qi_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _precisionMeta =
      const VerificationMeta('precision');
  @override
  late final GeneratedColumn<String> precision = GeneratedColumn<String>(
      'precision', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, sourceUuid, jieQiType, precision, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_da_yun_records';
  @override
  VerificationContext validateIntegrity(Insertable<DaYunRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('source_uuid')) {
      context.handle(
          _sourceUuidMeta,
          sourceUuid.isAcceptableOrUnknown(
              data['source_uuid']!, _sourceUuidMeta));
    } else if (isInserting) {
      context.missing(_sourceUuidMeta);
    }
    if (data.containsKey('jie_qi_type')) {
      context.handle(
          _jieQiTypeMeta,
          jieQiType.isAcceptableOrUnknown(
              data['jie_qi_type']!, _jieQiTypeMeta));
    } else if (isInserting) {
      context.missing(_jieQiTypeMeta);
    }
    if (data.containsKey('precision')) {
      context.handle(_precisionMeta,
          precision.isAcceptableOrUnknown(data['precision']!, _precisionMeta));
    } else if (isInserting) {
      context.missing(_precisionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  DaYunRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DaYunRecord(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      sourceUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_uuid'])!,
      jieQiType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jie_qi_type'])!,
      precision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}precision'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DaYunRecordsTable createAlias(String alias) {
    return $DaYunRecordsTable(attachedDatabase, alias);
  }
}

class DaYunRecord extends DataClass implements Insertable<DaYunRecord> {
  final String uuid;
  final String sourceUuid;
  final String jieQiType;
  final String precision;
  final DateTime createdAt;
  const DaYunRecord(
      {required this.uuid,
      required this.sourceUuid,
      required this.jieQiType,
      required this.precision,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['source_uuid'] = Variable<String>(sourceUuid);
    map['jie_qi_type'] = Variable<String>(jieQiType);
    map['precision'] = Variable<String>(precision);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DaYunRecordsCompanion toCompanion(bool nullToAbsent) {
    return DaYunRecordsCompanion(
      uuid: Value(uuid),
      sourceUuid: Value(sourceUuid),
      jieQiType: Value(jieQiType),
      precision: Value(precision),
      createdAt: Value(createdAt),
    );
  }

  factory DaYunRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DaYunRecord(
      uuid: serializer.fromJson<String>(json['uuid']),
      sourceUuid: serializer.fromJson<String>(json['sourceUuid']),
      jieQiType: serializer.fromJson<String>(json['jieQiType']),
      precision: serializer.fromJson<String>(json['precision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'sourceUuid': serializer.toJson<String>(sourceUuid),
      'jieQiType': serializer.toJson<String>(jieQiType),
      'precision': serializer.toJson<String>(precision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DaYunRecord copyWith(
          {String? uuid,
          String? sourceUuid,
          String? jieQiType,
          String? precision,
          DateTime? createdAt}) =>
      DaYunRecord(
        uuid: uuid ?? this.uuid,
        sourceUuid: sourceUuid ?? this.sourceUuid,
        jieQiType: jieQiType ?? this.jieQiType,
        precision: precision ?? this.precision,
        createdAt: createdAt ?? this.createdAt,
      );
  DaYunRecord copyWithCompanion(DaYunRecordsCompanion data) {
    return DaYunRecord(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      sourceUuid:
          data.sourceUuid.present ? data.sourceUuid.value : this.sourceUuid,
      jieQiType: data.jieQiType.present ? data.jieQiType.value : this.jieQiType,
      precision: data.precision.present ? data.precision.value : this.precision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DaYunRecord(')
          ..write('uuid: $uuid, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('jieQiType: $jieQiType, ')
          ..write('precision: $precision, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, sourceUuid, jieQiType, precision, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DaYunRecord &&
          other.uuid == this.uuid &&
          other.sourceUuid == this.sourceUuid &&
          other.jieQiType == this.jieQiType &&
          other.precision == this.precision &&
          other.createdAt == this.createdAt);
}

class DaYunRecordsCompanion extends UpdateCompanion<DaYunRecord> {
  final Value<String> uuid;
  final Value<String> sourceUuid;
  final Value<String> jieQiType;
  final Value<String> precision;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DaYunRecordsCompanion({
    this.uuid = const Value.absent(),
    this.sourceUuid = const Value.absent(),
    this.jieQiType = const Value.absent(),
    this.precision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DaYunRecordsCompanion.insert({
    required String uuid,
    required String sourceUuid,
    required String jieQiType,
    required String precision,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        sourceUuid = Value(sourceUuid),
        jieQiType = Value(jieQiType),
        precision = Value(precision),
        createdAt = Value(createdAt);
  static Insertable<DaYunRecord> custom({
    Expression<String>? uuid,
    Expression<String>? sourceUuid,
    Expression<String>? jieQiType,
    Expression<String>? precision,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (sourceUuid != null) 'source_uuid': sourceUuid,
      if (jieQiType != null) 'jie_qi_type': jieQiType,
      if (precision != null) 'precision': precision,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DaYunRecordsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? sourceUuid,
      Value<String>? jieQiType,
      Value<String>? precision,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DaYunRecordsCompanion(
      uuid: uuid ?? this.uuid,
      sourceUuid: sourceUuid ?? this.sourceUuid,
      jieQiType: jieQiType ?? this.jieQiType,
      precision: precision ?? this.precision,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (sourceUuid.present) {
      map['source_uuid'] = Variable<String>(sourceUuid.value);
    }
    if (jieQiType.present) {
      map['jie_qi_type'] = Variable<String>(jieQiType.value);
    }
    if (precision.present) {
      map['precision'] = Variable<String>(precision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaYunRecordsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('jieQiType: $jieQiType, ')
          ..write('precision: $precision, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaiYuanRecordsTable extends TaiYuanRecords
    with TableInfo<$TaiYuanRecordsTable, TaiYuanRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaiYuanRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _calendarUuidMeta =
      const VerificationMeta('calendarUuid');
  @override
  late final GeneratedColumn<String> calendarUuid = GeneratedColumn<String>(
      'calendar_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _strategyMeta =
      const VerificationMeta('strategy');
  @override
  late final GeneratedColumn<String> strategy = GeneratedColumn<String>(
      'strategy', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pillarMeta = const VerificationMeta('pillar');
  @override
  late final GeneratedColumn<String> pillar = GeneratedColumn<String>(
      'pillar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, calendarUuid, strategy, pillar, description, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_tai_yuan_records';
  @override
  VerificationContext validateIntegrity(Insertable<TaiYuanRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('calendar_uuid')) {
      context.handle(
          _calendarUuidMeta,
          calendarUuid.isAcceptableOrUnknown(
              data['calendar_uuid']!, _calendarUuidMeta));
    } else if (isInserting) {
      context.missing(_calendarUuidMeta);
    }
    if (data.containsKey('strategy')) {
      context.handle(_strategyMeta,
          strategy.isAcceptableOrUnknown(data['strategy']!, _strategyMeta));
    } else if (isInserting) {
      context.missing(_strategyMeta);
    }
    if (data.containsKey('pillar')) {
      context.handle(_pillarMeta,
          pillar.isAcceptableOrUnknown(data['pillar']!, _pillarMeta));
    } else if (isInserting) {
      context.missing(_pillarMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  TaiYuanRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaiYuanRecord(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      calendarUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}calendar_uuid'])!,
      strategy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}strategy'])!,
      pillar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pillar'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TaiYuanRecordsTable createAlias(String alias) {
    return $TaiYuanRecordsTable(attachedDatabase, alias);
  }
}

class TaiYuanRecord extends DataClass implements Insertable<TaiYuanRecord> {
  final String uuid;
  final String calendarUuid;
  final String strategy;
  final String pillar;
  final String? description;
  final DateTime createdAt;
  const TaiYuanRecord(
      {required this.uuid,
      required this.calendarUuid,
      required this.strategy,
      required this.pillar,
      this.description,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['calendar_uuid'] = Variable<String>(calendarUuid);
    map['strategy'] = Variable<String>(strategy);
    map['pillar'] = Variable<String>(pillar);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaiYuanRecordsCompanion toCompanion(bool nullToAbsent) {
    return TaiYuanRecordsCompanion(
      uuid: Value(uuid),
      calendarUuid: Value(calendarUuid),
      strategy: Value(strategy),
      pillar: Value(pillar),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory TaiYuanRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaiYuanRecord(
      uuid: serializer.fromJson<String>(json['uuid']),
      calendarUuid: serializer.fromJson<String>(json['calendarUuid']),
      strategy: serializer.fromJson<String>(json['strategy']),
      pillar: serializer.fromJson<String>(json['pillar']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'calendarUuid': serializer.toJson<String>(calendarUuid),
      'strategy': serializer.toJson<String>(strategy),
      'pillar': serializer.toJson<String>(pillar),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaiYuanRecord copyWith(
          {String? uuid,
          String? calendarUuid,
          String? strategy,
          String? pillar,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt}) =>
      TaiYuanRecord(
        uuid: uuid ?? this.uuid,
        calendarUuid: calendarUuid ?? this.calendarUuid,
        strategy: strategy ?? this.strategy,
        pillar: pillar ?? this.pillar,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
      );
  TaiYuanRecord copyWithCompanion(TaiYuanRecordsCompanion data) {
    return TaiYuanRecord(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      calendarUuid: data.calendarUuid.present
          ? data.calendarUuid.value
          : this.calendarUuid,
      strategy: data.strategy.present ? data.strategy.value : this.strategy,
      pillar: data.pillar.present ? data.pillar.value : this.pillar,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaiYuanRecord(')
          ..write('uuid: $uuid, ')
          ..write('calendarUuid: $calendarUuid, ')
          ..write('strategy: $strategy, ')
          ..write('pillar: $pillar, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, calendarUuid, strategy, pillar, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaiYuanRecord &&
          other.uuid == this.uuid &&
          other.calendarUuid == this.calendarUuid &&
          other.strategy == this.strategy &&
          other.pillar == this.pillar &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class TaiYuanRecordsCompanion extends UpdateCompanion<TaiYuanRecord> {
  final Value<String> uuid;
  final Value<String> calendarUuid;
  final Value<String> strategy;
  final Value<String> pillar;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TaiYuanRecordsCompanion({
    this.uuid = const Value.absent(),
    this.calendarUuid = const Value.absent(),
    this.strategy = const Value.absent(),
    this.pillar = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaiYuanRecordsCompanion.insert({
    required String uuid,
    required String calendarUuid,
    required String strategy,
    required String pillar,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        calendarUuid = Value(calendarUuid),
        strategy = Value(strategy),
        pillar = Value(pillar),
        createdAt = Value(createdAt);
  static Insertable<TaiYuanRecord> custom({
    Expression<String>? uuid,
    Expression<String>? calendarUuid,
    Expression<String>? strategy,
    Expression<String>? pillar,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (calendarUuid != null) 'calendar_uuid': calendarUuid,
      if (strategy != null) 'strategy': strategy,
      if (pillar != null) 'pillar': pillar,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaiYuanRecordsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? calendarUuid,
      Value<String>? strategy,
      Value<String>? pillar,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TaiYuanRecordsCompanion(
      uuid: uuid ?? this.uuid,
      calendarUuid: calendarUuid ?? this.calendarUuid,
      strategy: strategy ?? this.strategy,
      pillar: pillar ?? this.pillar,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (calendarUuid.present) {
      map['calendar_uuid'] = Variable<String>(calendarUuid.value);
    }
    if (strategy.present) {
      map['strategy'] = Variable<String>(strategy.value);
    }
    if (pillar.present) {
      map['pillar'] = Variable<String>(pillar.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaiYuanRecordsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('calendarUuid: $calendarUuid, ')
          ..write('strategy: $strategy, ')
          ..write('pillar: $pillar, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationCasesTable extends DivinationCases
    with TableInfo<$DivinationCasesTable, DivinationCase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationCasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mainQuestionMeta =
      const VerificationMeta('mainQuestion');
  @override
  late final GeneratedColumn<String> mainQuestion = GeneratedColumn<String>(
      'main_question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _finalSummaryMeta =
      const VerificationMeta('finalSummary');
  @override
  late final GeneratedColumn<String> finalSummary = GeneratedColumn<String>(
      'final_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        title,
        mainQuestion,
        status,
        createdAt,
        updatedAt,
        deletedAt,
        finalSummary
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_cases';
  @override
  VerificationContext validateIntegrity(Insertable<DivinationCase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('main_question')) {
      context.handle(
          _mainQuestionMeta,
          mainQuestion.isAcceptableOrUnknown(
              data['main_question']!, _mainQuestionMeta));
    } else if (isInserting) {
      context.missing(_mainQuestionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('final_summary')) {
      context.handle(
          _finalSummaryMeta,
          finalSummary.isAcceptableOrUnknown(
              data['final_summary']!, _finalSummaryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  DivinationCase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationCase(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      mainQuestion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}main_question'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      finalSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}final_summary']),
    );
  }

  @override
  $DivinationCasesTable createAlias(String alias) {
    return $DivinationCasesTable(attachedDatabase, alias);
  }
}

class DivinationCase extends DataClass implements Insertable<DivinationCase> {
  final String uuid;
  final String title;
  final String mainQuestion;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? finalSummary;
  const DivinationCase(
      {required this.uuid,
      required this.title,
      required this.mainQuestion,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.finalSummary});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['main_question'] = Variable<String>(mainQuestion);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || finalSummary != null) {
      map['final_summary'] = Variable<String>(finalSummary);
    }
    return map;
  }

  DivinationCasesCompanion toCompanion(bool nullToAbsent) {
    return DivinationCasesCompanion(
      uuid: Value(uuid),
      title: Value(title),
      mainQuestion: Value(mainQuestion),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      finalSummary: finalSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(finalSummary),
    );
  }

  factory DivinationCase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationCase(
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      mainQuestion: serializer.fromJson<String>(json['mainQuestion']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      finalSummary: serializer.fromJson<String?>(json['finalSummary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'mainQuestion': serializer.toJson<String>(mainQuestion),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'finalSummary': serializer.toJson<String?>(finalSummary),
    };
  }

  DivinationCase copyWith(
          {String? uuid,
          String? title,
          String? mainQuestion,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> finalSummary = const Value.absent()}) =>
      DivinationCase(
        uuid: uuid ?? this.uuid,
        title: title ?? this.title,
        mainQuestion: mainQuestion ?? this.mainQuestion,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        finalSummary:
            finalSummary.present ? finalSummary.value : this.finalSummary,
      );
  DivinationCase copyWithCompanion(DivinationCasesCompanion data) {
    return DivinationCase(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      mainQuestion: data.mainQuestion.present
          ? data.mainQuestion.value
          : this.mainQuestion,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      finalSummary: data.finalSummary.present
          ? data.finalSummary.value
          : this.finalSummary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationCase(')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('mainQuestion: $mainQuestion, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('finalSummary: $finalSummary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, title, mainQuestion, status, createdAt,
      updatedAt, deletedAt, finalSummary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationCase &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.mainQuestion == this.mainQuestion &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.finalSummary == this.finalSummary);
}

class DivinationCasesCompanion extends UpdateCompanion<DivinationCase> {
  final Value<String> uuid;
  final Value<String> title;
  final Value<String> mainQuestion;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> finalSummary;
  final Value<int> rowid;
  const DivinationCasesCompanion({
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.mainQuestion = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.finalSummary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationCasesCompanion.insert({
    required String uuid,
    required String title,
    required String mainQuestion,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.finalSummary = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        title = Value(title),
        mainQuestion = Value(mainQuestion),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DivinationCase> custom({
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<String>? mainQuestion,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? finalSummary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (mainQuestion != null) 'main_question': mainQuestion,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (finalSummary != null) 'final_summary': finalSummary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationCasesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? title,
      Value<String>? mainQuestion,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? finalSummary,
      Value<int>? rowid}) {
    return DivinationCasesCompanion(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      mainQuestion: mainQuestion ?? this.mainQuestion,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      finalSummary: finalSummary ?? this.finalSummary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (mainQuestion.present) {
      map['main_question'] = Variable<String>(mainQuestion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (finalSummary.present) {
      map['final_summary'] = Variable<String>(finalSummary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationCasesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('mainQuestion: $mainQuestion, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('finalSummary: $finalSummary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationWorkItemsTable extends DivinationWorkItems
    with TableInfo<$DivinationWorkItemsTable, DivinationWorkItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationWorkItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseUuidMeta =
      const VerificationMeta('caseUuid');
  @override
  late final GeneratedColumn<String> caseUuid = GeneratedColumn<String>(
      'case_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentWorkItemUuidMeta =
      const VerificationMeta('parentWorkItemUuid');
  @override
  late final GeneratedColumn<String> parentWorkItemUuid =
      GeneratedColumn<String>('parent_work_item_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodGroupMeta =
      const VerificationMeta('methodGroup');
  @override
  late final GeneratedColumn<String> methodGroup = GeneratedColumn<String>(
      'method_group', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conclusionMeta =
      const VerificationMeta('conclusion');
  @override
  late final GeneratedColumn<String> conclusion = GeneratedColumn<String>(
      'conclusion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        caseUuid,
        parentWorkItemUuid,
        title,
        purpose,
        methodGroup,
        order,
        status,
        summary,
        conclusion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_work_items';
  @override
  VerificationContext validateIntegrity(Insertable<DivinationWorkItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('case_uuid')) {
      context.handle(_caseUuidMeta,
          caseUuid.isAcceptableOrUnknown(data['case_uuid']!, _caseUuidMeta));
    } else if (isInserting) {
      context.missing(_caseUuidMeta);
    }
    if (data.containsKey('parent_work_item_uuid')) {
      context.handle(
          _parentWorkItemUuidMeta,
          parentWorkItemUuid.isAcceptableOrUnknown(
              data['parent_work_item_uuid']!, _parentWorkItemUuidMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('method_group')) {
      context.handle(
          _methodGroupMeta,
          methodGroup.isAcceptableOrUnknown(
              data['method_group']!, _methodGroupMeta));
    } else if (isInserting) {
      context.missing(_methodGroupMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(_orderMeta,
          order.isAcceptableOrUnknown(data['order_index']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('conclusion')) {
      context.handle(
          _conclusionMeta,
          conclusion.isAcceptableOrUnknown(
              data['conclusion']!, _conclusionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  DivinationWorkItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationWorkItem(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      caseUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_uuid'])!,
      parentWorkItemUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_work_item_uuid']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      methodGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method_group'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      conclusion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conclusion']),
    );
  }

  @override
  $DivinationWorkItemsTable createAlias(String alias) {
    return $DivinationWorkItemsTable(attachedDatabase, alias);
  }
}

class DivinationWorkItem extends DataClass
    implements Insertable<DivinationWorkItem> {
  final String uuid;
  final String caseUuid;
  final String? parentWorkItemUuid;
  final String title;
  final String purpose;
  final String methodGroup;
  final int order;
  final String status;
  final String? summary;
  final String? conclusion;
  const DivinationWorkItem(
      {required this.uuid,
      required this.caseUuid,
      this.parentWorkItemUuid,
      required this.title,
      required this.purpose,
      required this.methodGroup,
      required this.order,
      required this.status,
      this.summary,
      this.conclusion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['case_uuid'] = Variable<String>(caseUuid);
    if (!nullToAbsent || parentWorkItemUuid != null) {
      map['parent_work_item_uuid'] = Variable<String>(parentWorkItemUuid);
    }
    map['title'] = Variable<String>(title);
    map['purpose'] = Variable<String>(purpose);
    map['method_group'] = Variable<String>(methodGroup);
    map['order_index'] = Variable<int>(order);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || conclusion != null) {
      map['conclusion'] = Variable<String>(conclusion);
    }
    return map;
  }

  DivinationWorkItemsCompanion toCompanion(bool nullToAbsent) {
    return DivinationWorkItemsCompanion(
      uuid: Value(uuid),
      caseUuid: Value(caseUuid),
      parentWorkItemUuid: parentWorkItemUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(parentWorkItemUuid),
      title: Value(title),
      purpose: Value(purpose),
      methodGroup: Value(methodGroup),
      order: Value(order),
      status: Value(status),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      conclusion: conclusion == null && nullToAbsent
          ? const Value.absent()
          : Value(conclusion),
    );
  }

  factory DivinationWorkItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationWorkItem(
      uuid: serializer.fromJson<String>(json['uuid']),
      caseUuid: serializer.fromJson<String>(json['caseUuid']),
      parentWorkItemUuid:
          serializer.fromJson<String?>(json['parentWorkItemUuid']),
      title: serializer.fromJson<String>(json['title']),
      purpose: serializer.fromJson<String>(json['purpose']),
      methodGroup: serializer.fromJson<String>(json['methodGroup']),
      order: serializer.fromJson<int>(json['order']),
      status: serializer.fromJson<String>(json['status']),
      summary: serializer.fromJson<String?>(json['summary']),
      conclusion: serializer.fromJson<String?>(json['conclusion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'caseUuid': serializer.toJson<String>(caseUuid),
      'parentWorkItemUuid': serializer.toJson<String?>(parentWorkItemUuid),
      'title': serializer.toJson<String>(title),
      'purpose': serializer.toJson<String>(purpose),
      'methodGroup': serializer.toJson<String>(methodGroup),
      'order': serializer.toJson<int>(order),
      'status': serializer.toJson<String>(status),
      'summary': serializer.toJson<String?>(summary),
      'conclusion': serializer.toJson<String?>(conclusion),
    };
  }

  DivinationWorkItem copyWith(
          {String? uuid,
          String? caseUuid,
          Value<String?> parentWorkItemUuid = const Value.absent(),
          String? title,
          String? purpose,
          String? methodGroup,
          int? order,
          String? status,
          Value<String?> summary = const Value.absent(),
          Value<String?> conclusion = const Value.absent()}) =>
      DivinationWorkItem(
        uuid: uuid ?? this.uuid,
        caseUuid: caseUuid ?? this.caseUuid,
        parentWorkItemUuid: parentWorkItemUuid.present
            ? parentWorkItemUuid.value
            : this.parentWorkItemUuid,
        title: title ?? this.title,
        purpose: purpose ?? this.purpose,
        methodGroup: methodGroup ?? this.methodGroup,
        order: order ?? this.order,
        status: status ?? this.status,
        summary: summary.present ? summary.value : this.summary,
        conclusion: conclusion.present ? conclusion.value : this.conclusion,
      );
  DivinationWorkItem copyWithCompanion(DivinationWorkItemsCompanion data) {
    return DivinationWorkItem(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      caseUuid: data.caseUuid.present ? data.caseUuid.value : this.caseUuid,
      parentWorkItemUuid: data.parentWorkItemUuid.present
          ? data.parentWorkItemUuid.value
          : this.parentWorkItemUuid,
      title: data.title.present ? data.title.value : this.title,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      methodGroup:
          data.methodGroup.present ? data.methodGroup.value : this.methodGroup,
      order: data.order.present ? data.order.value : this.order,
      status: data.status.present ? data.status.value : this.status,
      summary: data.summary.present ? data.summary.value : this.summary,
      conclusion:
          data.conclusion.present ? data.conclusion.value : this.conclusion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationWorkItem(')
          ..write('uuid: $uuid, ')
          ..write('caseUuid: $caseUuid, ')
          ..write('parentWorkItemUuid: $parentWorkItemUuid, ')
          ..write('title: $title, ')
          ..write('purpose: $purpose, ')
          ..write('methodGroup: $methodGroup, ')
          ..write('order: $order, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('conclusion: $conclusion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, caseUuid, parentWorkItemUuid, title,
      purpose, methodGroup, order, status, summary, conclusion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationWorkItem &&
          other.uuid == this.uuid &&
          other.caseUuid == this.caseUuid &&
          other.parentWorkItemUuid == this.parentWorkItemUuid &&
          other.title == this.title &&
          other.purpose == this.purpose &&
          other.methodGroup == this.methodGroup &&
          other.order == this.order &&
          other.status == this.status &&
          other.summary == this.summary &&
          other.conclusion == this.conclusion);
}

class DivinationWorkItemsCompanion extends UpdateCompanion<DivinationWorkItem> {
  final Value<String> uuid;
  final Value<String> caseUuid;
  final Value<String?> parentWorkItemUuid;
  final Value<String> title;
  final Value<String> purpose;
  final Value<String> methodGroup;
  final Value<int> order;
  final Value<String> status;
  final Value<String?> summary;
  final Value<String?> conclusion;
  final Value<int> rowid;
  const DivinationWorkItemsCompanion({
    this.uuid = const Value.absent(),
    this.caseUuid = const Value.absent(),
    this.parentWorkItemUuid = const Value.absent(),
    this.title = const Value.absent(),
    this.purpose = const Value.absent(),
    this.methodGroup = const Value.absent(),
    this.order = const Value.absent(),
    this.status = const Value.absent(),
    this.summary = const Value.absent(),
    this.conclusion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationWorkItemsCompanion.insert({
    required String uuid,
    required String caseUuid,
    this.parentWorkItemUuid = const Value.absent(),
    required String title,
    required String purpose,
    required String methodGroup,
    required int order,
    required String status,
    this.summary = const Value.absent(),
    this.conclusion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        caseUuid = Value(caseUuid),
        title = Value(title),
        purpose = Value(purpose),
        methodGroup = Value(methodGroup),
        order = Value(order),
        status = Value(status);
  static Insertable<DivinationWorkItem> custom({
    Expression<String>? uuid,
    Expression<String>? caseUuid,
    Expression<String>? parentWorkItemUuid,
    Expression<String>? title,
    Expression<String>? purpose,
    Expression<String>? methodGroup,
    Expression<int>? order,
    Expression<String>? status,
    Expression<String>? summary,
    Expression<String>? conclusion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (caseUuid != null) 'case_uuid': caseUuid,
      if (parentWorkItemUuid != null)
        'parent_work_item_uuid': parentWorkItemUuid,
      if (title != null) 'title': title,
      if (purpose != null) 'purpose': purpose,
      if (methodGroup != null) 'method_group': methodGroup,
      if (order != null) 'order_index': order,
      if (status != null) 'status': status,
      if (summary != null) 'summary': summary,
      if (conclusion != null) 'conclusion': conclusion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationWorkItemsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? caseUuid,
      Value<String?>? parentWorkItemUuid,
      Value<String>? title,
      Value<String>? purpose,
      Value<String>? methodGroup,
      Value<int>? order,
      Value<String>? status,
      Value<String?>? summary,
      Value<String?>? conclusion,
      Value<int>? rowid}) {
    return DivinationWorkItemsCompanion(
      uuid: uuid ?? this.uuid,
      caseUuid: caseUuid ?? this.caseUuid,
      parentWorkItemUuid: parentWorkItemUuid ?? this.parentWorkItemUuid,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      methodGroup: methodGroup ?? this.methodGroup,
      order: order ?? this.order,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      conclusion: conclusion ?? this.conclusion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (caseUuid.present) {
      map['case_uuid'] = Variable<String>(caseUuid.value);
    }
    if (parentWorkItemUuid.present) {
      map['parent_work_item_uuid'] = Variable<String>(parentWorkItemUuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (methodGroup.present) {
      map['method_group'] = Variable<String>(methodGroup.value);
    }
    if (order.present) {
      map['order_index'] = Variable<int>(order.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (conclusion.present) {
      map['conclusion'] = Variable<String>(conclusion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationWorkItemsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('caseUuid: $caseUuid, ')
          ..write('parentWorkItemUuid: $parentWorkItemUuid, ')
          ..write('title: $title, ')
          ..write('purpose: $purpose, ')
          ..write('methodGroup: $methodGroup, ')
          ..write('order: $order, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('conclusion: $conclusion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaseParticipantsTable extends CaseParticipants
    with TableInfo<$CaseParticipantsTable, CaseParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseUuidMeta =
      const VerificationMeta('caseUuid');
  @override
  late final GeneratedColumn<String> caseUuid = GeneratedColumn<String>(
      'case_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordUuidMeta =
      const VerificationMeta('recordUuid');
  @override
  late final GeneratedColumn<String> recordUuid = GeneratedColumn<String>(
      'record_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seekerUuidMeta =
      const VerificationMeta('seekerUuid');
  @override
  late final GeneratedColumn<String> seekerUuid = GeneratedColumn<String>(
      'seeker_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, caseUuid, recordUuid, name, role, seekerUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_case_participants';
  @override
  VerificationContext validateIntegrity(Insertable<CaseParticipant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('case_uuid')) {
      context.handle(_caseUuidMeta,
          caseUuid.isAcceptableOrUnknown(data['case_uuid']!, _caseUuidMeta));
    } else if (isInserting) {
      context.missing(_caseUuidMeta);
    }
    if (data.containsKey('record_uuid')) {
      context.handle(
          _recordUuidMeta,
          recordUuid.isAcceptableOrUnknown(
              data['record_uuid']!, _recordUuidMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('seeker_uuid')) {
      context.handle(
          _seekerUuidMeta,
          seekerUuid.isAcceptableOrUnknown(
              data['seeker_uuid']!, _seekerUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  CaseParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseParticipant(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      caseUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_uuid'])!,
      recordUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_uuid']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      seekerUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_uuid']),
    );
  }

  @override
  $CaseParticipantsTable createAlias(String alias) {
    return $CaseParticipantsTable(attachedDatabase, alias);
  }
}

class CaseParticipant extends DataClass implements Insertable<CaseParticipant> {
  final String uuid;
  final String caseUuid;
  final String? recordUuid;
  final String name;
  final String role;
  final String? seekerUuid;
  const CaseParticipant(
      {required this.uuid,
      required this.caseUuid,
      this.recordUuid,
      required this.name,
      required this.role,
      this.seekerUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['case_uuid'] = Variable<String>(caseUuid);
    if (!nullToAbsent || recordUuid != null) {
      map['record_uuid'] = Variable<String>(recordUuid);
    }
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || seekerUuid != null) {
      map['seeker_uuid'] = Variable<String>(seekerUuid);
    }
    return map;
  }

  CaseParticipantsCompanion toCompanion(bool nullToAbsent) {
    return CaseParticipantsCompanion(
      uuid: Value(uuid),
      caseUuid: Value(caseUuid),
      recordUuid: recordUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(recordUuid),
      name: Value(name),
      role: Value(role),
      seekerUuid: seekerUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(seekerUuid),
    );
  }

  factory CaseParticipant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseParticipant(
      uuid: serializer.fromJson<String>(json['uuid']),
      caseUuid: serializer.fromJson<String>(json['caseUuid']),
      recordUuid: serializer.fromJson<String?>(json['recordUuid']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      seekerUuid: serializer.fromJson<String?>(json['seekerUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'caseUuid': serializer.toJson<String>(caseUuid),
      'recordUuid': serializer.toJson<String?>(recordUuid),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'seekerUuid': serializer.toJson<String?>(seekerUuid),
    };
  }

  CaseParticipant copyWith(
          {String? uuid,
          String? caseUuid,
          Value<String?> recordUuid = const Value.absent(),
          String? name,
          String? role,
          Value<String?> seekerUuid = const Value.absent()}) =>
      CaseParticipant(
        uuid: uuid ?? this.uuid,
        caseUuid: caseUuid ?? this.caseUuid,
        recordUuid: recordUuid.present ? recordUuid.value : this.recordUuid,
        name: name ?? this.name,
        role: role ?? this.role,
        seekerUuid: seekerUuid.present ? seekerUuid.value : this.seekerUuid,
      );
  CaseParticipant copyWithCompanion(CaseParticipantsCompanion data) {
    return CaseParticipant(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      caseUuid: data.caseUuid.present ? data.caseUuid.value : this.caseUuid,
      recordUuid:
          data.recordUuid.present ? data.recordUuid.value : this.recordUuid,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      seekerUuid:
          data.seekerUuid.present ? data.seekerUuid.value : this.seekerUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseParticipant(')
          ..write('uuid: $uuid, ')
          ..write('caseUuid: $caseUuid, ')
          ..write('recordUuid: $recordUuid, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('seekerUuid: $seekerUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, caseUuid, recordUuid, name, role, seekerUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseParticipant &&
          other.uuid == this.uuid &&
          other.caseUuid == this.caseUuid &&
          other.recordUuid == this.recordUuid &&
          other.name == this.name &&
          other.role == this.role &&
          other.seekerUuid == this.seekerUuid);
}

class CaseParticipantsCompanion extends UpdateCompanion<CaseParticipant> {
  final Value<String> uuid;
  final Value<String> caseUuid;
  final Value<String?> recordUuid;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> seekerUuid;
  final Value<int> rowid;
  const CaseParticipantsCompanion({
    this.uuid = const Value.absent(),
    this.caseUuid = const Value.absent(),
    this.recordUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.seekerUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaseParticipantsCompanion.insert({
    required String uuid,
    required String caseUuid,
    this.recordUuid = const Value.absent(),
    required String name,
    required String role,
    this.seekerUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        caseUuid = Value(caseUuid),
        name = Value(name),
        role = Value(role);
  static Insertable<CaseParticipant> custom({
    Expression<String>? uuid,
    Expression<String>? caseUuid,
    Expression<String>? recordUuid,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? seekerUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (caseUuid != null) 'case_uuid': caseUuid,
      if (recordUuid != null) 'record_uuid': recordUuid,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (seekerUuid != null) 'seeker_uuid': seekerUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaseParticipantsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? caseUuid,
      Value<String?>? recordUuid,
      Value<String>? name,
      Value<String>? role,
      Value<String?>? seekerUuid,
      Value<int>? rowid}) {
    return CaseParticipantsCompanion(
      uuid: uuid ?? this.uuid,
      caseUuid: caseUuid ?? this.caseUuid,
      recordUuid: recordUuid ?? this.recordUuid,
      name: name ?? this.name,
      role: role ?? this.role,
      seekerUuid: seekerUuid ?? this.seekerUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (caseUuid.present) {
      map['case_uuid'] = Variable<String>(caseUuid.value);
    }
    if (recordUuid.present) {
      map['record_uuid'] = Variable<String>(recordUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (seekerUuid.present) {
      map['seeker_uuid'] = Variable<String>(seekerUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseParticipantsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('caseUuid: $caseUuid, ')
          ..write('recordUuid: $recordUuid, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('seekerUuid: $seekerUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PanelRefsTable extends PanelRefs
    with TableInfo<$PanelRefsTable, PanelRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PanelRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
      'module', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _panelUuidMeta =
      const VerificationMeta('panelUuid');
  @override
  late final GeneratedColumn<String> panelUuid = GeneratedColumn<String>(
      'panel_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _panelTypeMeta =
      const VerificationMeta('panelType');
  @override
  late final GeneratedColumn<String> panelType = GeneratedColumn<String>(
      'panel_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, module, panelUuid, panelType, role, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_panel_refs';
  @override
  VerificationContext validateIntegrity(Insertable<PanelRef> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('module')) {
      context.handle(_moduleMeta,
          module.isAcceptableOrUnknown(data['module']!, _moduleMeta));
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('panel_uuid')) {
      context.handle(_panelUuidMeta,
          panelUuid.isAcceptableOrUnknown(data['panel_uuid']!, _panelUuidMeta));
    } else if (isInserting) {
      context.missing(_panelUuidMeta);
    }
    if (data.containsKey('panel_type')) {
      context.handle(_panelTypeMeta,
          panelType.isAcceptableOrUnknown(data['panel_type']!, _panelTypeMeta));
    } else if (isInserting) {
      context.missing(_panelTypeMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  PanelRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PanelRef(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      module: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module'])!,
      panelUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_uuid'])!,
      panelType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_type'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
    );
  }

  @override
  $PanelRefsTable createAlias(String alias) {
    return $PanelRefsTable(attachedDatabase, alias);
  }
}

class PanelRef extends DataClass implements Insertable<PanelRef> {
  final String uuid;
  final String module;
  final String panelUuid;
  final String panelType;
  final String role;
  final String? title;
  const PanelRef(
      {required this.uuid,
      required this.module,
      required this.panelUuid,
      required this.panelType,
      required this.role,
      this.title});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['module'] = Variable<String>(module);
    map['panel_uuid'] = Variable<String>(panelUuid);
    map['panel_type'] = Variable<String>(panelType);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    return map;
  }

  PanelRefsCompanion toCompanion(bool nullToAbsent) {
    return PanelRefsCompanion(
      uuid: Value(uuid),
      module: Value(module),
      panelUuid: Value(panelUuid),
      panelType: Value(panelType),
      role: Value(role),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
    );
  }

  factory PanelRef.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PanelRef(
      uuid: serializer.fromJson<String>(json['uuid']),
      module: serializer.fromJson<String>(json['module']),
      panelUuid: serializer.fromJson<String>(json['panelUuid']),
      panelType: serializer.fromJson<String>(json['panelType']),
      role: serializer.fromJson<String>(json['role']),
      title: serializer.fromJson<String?>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'module': serializer.toJson<String>(module),
      'panelUuid': serializer.toJson<String>(panelUuid),
      'panelType': serializer.toJson<String>(panelType),
      'role': serializer.toJson<String>(role),
      'title': serializer.toJson<String?>(title),
    };
  }

  PanelRef copyWith(
          {String? uuid,
          String? module,
          String? panelUuid,
          String? panelType,
          String? role,
          Value<String?> title = const Value.absent()}) =>
      PanelRef(
        uuid: uuid ?? this.uuid,
        module: module ?? this.module,
        panelUuid: panelUuid ?? this.panelUuid,
        panelType: panelType ?? this.panelType,
        role: role ?? this.role,
        title: title.present ? title.value : this.title,
      );
  PanelRef copyWithCompanion(PanelRefsCompanion data) {
    return PanelRef(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      module: data.module.present ? data.module.value : this.module,
      panelUuid: data.panelUuid.present ? data.panelUuid.value : this.panelUuid,
      panelType: data.panelType.present ? data.panelType.value : this.panelType,
      role: data.role.present ? data.role.value : this.role,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PanelRef(')
          ..write('uuid: $uuid, ')
          ..write('module: $module, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('panelType: $panelType, ')
          ..write('role: $role, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, module, panelUuid, panelType, role, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PanelRef &&
          other.uuid == this.uuid &&
          other.module == this.module &&
          other.panelUuid == this.panelUuid &&
          other.panelType == this.panelType &&
          other.role == this.role &&
          other.title == this.title);
}

class PanelRefsCompanion extends UpdateCompanion<PanelRef> {
  final Value<String> uuid;
  final Value<String> module;
  final Value<String> panelUuid;
  final Value<String> panelType;
  final Value<String> role;
  final Value<String?> title;
  final Value<int> rowid;
  const PanelRefsCompanion({
    this.uuid = const Value.absent(),
    this.module = const Value.absent(),
    this.panelUuid = const Value.absent(),
    this.panelType = const Value.absent(),
    this.role = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PanelRefsCompanion.insert({
    required String uuid,
    required String module,
    required String panelUuid,
    required String panelType,
    required String role,
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        module = Value(module),
        panelUuid = Value(panelUuid),
        panelType = Value(panelType),
        role = Value(role);
  static Insertable<PanelRef> custom({
    Expression<String>? uuid,
    Expression<String>? module,
    Expression<String>? panelUuid,
    Expression<String>? panelType,
    Expression<String>? role,
    Expression<String>? title,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (module != null) 'module': module,
      if (panelUuid != null) 'panel_uuid': panelUuid,
      if (panelType != null) 'panel_type': panelType,
      if (role != null) 'role': role,
      if (title != null) 'title': title,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PanelRefsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? module,
      Value<String>? panelUuid,
      Value<String>? panelType,
      Value<String>? role,
      Value<String?>? title,
      Value<int>? rowid}) {
    return PanelRefsCompanion(
      uuid: uuid ?? this.uuid,
      module: module ?? this.module,
      panelUuid: panelUuid ?? this.panelUuid,
      panelType: panelType ?? this.panelType,
      role: role ?? this.role,
      title: title ?? this.title,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (panelUuid.present) {
      map['panel_uuid'] = Variable<String>(panelUuid.value);
    }
    if (panelType.present) {
      map['panel_type'] = Variable<String>(panelType.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PanelRefsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('module: $module, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('panelType: $panelType, ')
          ..write('role: $role, ')
          ..write('title: $title, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkItemPanelRefsTable extends WorkItemPanelRefs
    with TableInfo<$WorkItemPanelRefsTable, WorkItemPanelRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkItemPanelRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workItemUuidMeta =
      const VerificationMeta('workItemUuid');
  @override
  late final GeneratedColumn<String> workItemUuid = GeneratedColumn<String>(
      'work_item_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _panelRefUuidMeta =
      const VerificationMeta('panelRefUuid');
  @override
  late final GeneratedColumn<String> panelRefUuid = GeneratedColumn<String>(
      'panel_ref_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, workItemUuid, panelRefUuid, role, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_work_item_panel_refs';
  @override
  VerificationContext validateIntegrity(Insertable<WorkItemPanelRef> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('work_item_uuid')) {
      context.handle(
          _workItemUuidMeta,
          workItemUuid.isAcceptableOrUnknown(
              data['work_item_uuid']!, _workItemUuidMeta));
    } else if (isInserting) {
      context.missing(_workItemUuidMeta);
    }
    if (data.containsKey('panel_ref_uuid')) {
      context.handle(
          _panelRefUuidMeta,
          panelRefUuid.isAcceptableOrUnknown(
              data['panel_ref_uuid']!, _panelRefUuidMeta));
    } else if (isInserting) {
      context.missing(_panelRefUuidMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(_orderMeta,
          order.isAcceptableOrUnknown(data['order_index']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  WorkItemPanelRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkItemPanelRef(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      workItemUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}work_item_uuid'])!,
      panelRefUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_ref_uuid'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $WorkItemPanelRefsTable createAlias(String alias) {
    return $WorkItemPanelRefsTable(attachedDatabase, alias);
  }
}

class WorkItemPanelRef extends DataClass
    implements Insertable<WorkItemPanelRef> {
  final String uuid;
  final String workItemUuid;
  final String panelRefUuid;
  final String role;
  final int order;
  const WorkItemPanelRef(
      {required this.uuid,
      required this.workItemUuid,
      required this.panelRefUuid,
      required this.role,
      required this.order});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['work_item_uuid'] = Variable<String>(workItemUuid);
    map['panel_ref_uuid'] = Variable<String>(panelRefUuid);
    map['role'] = Variable<String>(role);
    map['order_index'] = Variable<int>(order);
    return map;
  }

  WorkItemPanelRefsCompanion toCompanion(bool nullToAbsent) {
    return WorkItemPanelRefsCompanion(
      uuid: Value(uuid),
      workItemUuid: Value(workItemUuid),
      panelRefUuid: Value(panelRefUuid),
      role: Value(role),
      order: Value(order),
    );
  }

  factory WorkItemPanelRef.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkItemPanelRef(
      uuid: serializer.fromJson<String>(json['uuid']),
      workItemUuid: serializer.fromJson<String>(json['workItemUuid']),
      panelRefUuid: serializer.fromJson<String>(json['panelRefUuid']),
      role: serializer.fromJson<String>(json['role']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'workItemUuid': serializer.toJson<String>(workItemUuid),
      'panelRefUuid': serializer.toJson<String>(panelRefUuid),
      'role': serializer.toJson<String>(role),
      'order': serializer.toJson<int>(order),
    };
  }

  WorkItemPanelRef copyWith(
          {String? uuid,
          String? workItemUuid,
          String? panelRefUuid,
          String? role,
          int? order}) =>
      WorkItemPanelRef(
        uuid: uuid ?? this.uuid,
        workItemUuid: workItemUuid ?? this.workItemUuid,
        panelRefUuid: panelRefUuid ?? this.panelRefUuid,
        role: role ?? this.role,
        order: order ?? this.order,
      );
  WorkItemPanelRef copyWithCompanion(WorkItemPanelRefsCompanion data) {
    return WorkItemPanelRef(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      workItemUuid: data.workItemUuid.present
          ? data.workItemUuid.value
          : this.workItemUuid,
      panelRefUuid: data.panelRefUuid.present
          ? data.panelRefUuid.value
          : this.panelRefUuid,
      role: data.role.present ? data.role.value : this.role,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemPanelRef(')
          ..write('uuid: $uuid, ')
          ..write('workItemUuid: $workItemUuid, ')
          ..write('panelRefUuid: $panelRefUuid, ')
          ..write('role: $role, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, workItemUuid, panelRefUuid, role, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkItemPanelRef &&
          other.uuid == this.uuid &&
          other.workItemUuid == this.workItemUuid &&
          other.panelRefUuid == this.panelRefUuid &&
          other.role == this.role &&
          other.order == this.order);
}

class WorkItemPanelRefsCompanion extends UpdateCompanion<WorkItemPanelRef> {
  final Value<String> uuid;
  final Value<String> workItemUuid;
  final Value<String> panelRefUuid;
  final Value<String> role;
  final Value<int> order;
  final Value<int> rowid;
  const WorkItemPanelRefsCompanion({
    this.uuid = const Value.absent(),
    this.workItemUuid = const Value.absent(),
    this.panelRefUuid = const Value.absent(),
    this.role = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkItemPanelRefsCompanion.insert({
    required String uuid,
    required String workItemUuid,
    required String panelRefUuid,
    required String role,
    required int order,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        workItemUuid = Value(workItemUuid),
        panelRefUuid = Value(panelRefUuid),
        role = Value(role),
        order = Value(order);
  static Insertable<WorkItemPanelRef> custom({
    Expression<String>? uuid,
    Expression<String>? workItemUuid,
    Expression<String>? panelRefUuid,
    Expression<String>? role,
    Expression<int>? order,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (workItemUuid != null) 'work_item_uuid': workItemUuid,
      if (panelRefUuid != null) 'panel_ref_uuid': panelRefUuid,
      if (role != null) 'role': role,
      if (order != null) 'order_index': order,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkItemPanelRefsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? workItemUuid,
      Value<String>? panelRefUuid,
      Value<String>? role,
      Value<int>? order,
      Value<int>? rowid}) {
    return WorkItemPanelRefsCompanion(
      uuid: uuid ?? this.uuid,
      workItemUuid: workItemUuid ?? this.workItemUuid,
      panelRefUuid: panelRefUuid ?? this.panelRefUuid,
      role: role ?? this.role,
      order: order ?? this.order,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (workItemUuid.present) {
      map['work_item_uuid'] = Variable<String>(workItemUuid.value);
    }
    if (panelRefUuid.present) {
      map['panel_ref_uuid'] = Variable<String>(panelRefUuid.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (order.present) {
      map['order_index'] = Variable<int>(order.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemPanelRefsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('workItemUuid: $workItemUuid, ')
          ..write('panelRefUuid: $panelRefUuid, ')
          ..write('role: $role, ')
          ..write('order: $order, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PersistenceDriftDatabase extends GeneratedDatabase {
  _$PersistenceDriftDatabase(QueryExecutor e) : super(e);
  $PersistenceDriftDatabaseManager get managers =>
      $PersistenceDriftDatabaseManager(this);
  late final $OutboxRecordsTable outboxRecords = $OutboxRecordsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $SeekersTable seekers = $SeekersTable(this);
  late final $DivinationsTable divinations = $DivinationsTable(this);
  late final $SeekerDivinationMappersTable seekerDivinationMappers =
      $SeekerDivinationMappersTable(this);
  late final $CombinedDivinationsTable combinedDivinations =
      $CombinedDivinationsTable(this);
  late final $DecisionLinksTable decisionLinks = $DecisionLinksTable(this);
  late final $DivinationTagsTable divinationTags = $DivinationTagsTable(this);
  late final $DivinationTypesTable divinationTypes =
      $DivinationTypesTable(this);
  late final $SubDivinationTypesTable subDivinationTypes =
      $SubDivinationTypesTable(this);
  late final $DivinationSubDivinationTypeMappersTable
      divinationSubDivinationTypeMappers =
      $DivinationSubDivinationTypeMappersTable(this);
  late final $DivinationCalendarsTable divinationCalendars =
      $DivinationCalendarsTable(this);
  late final $TimingDivinationsTable timingDivinations =
      $TimingDivinationsTable(this);
  late final $PanelsTable panels = $PanelsTable(this);
  late final $DivinationPanelMappersTable divinationPanelMappers =
      $DivinationPanelMappersTable(this);
  late final $PanelSkillClassMappersTable panelSkillClassMappers =
      $PanelSkillClassMappersTable(this);
  late final $SkillsTable skills = $SkillsTable(this);
  late final $SkillClassesTable skillClasses = $SkillClassesTable(this);
  late final $DaYunRecordsTable daYunRecords = $DaYunRecordsTable(this);
  late final $TaiYuanRecordsTable taiYuanRecords = $TaiYuanRecordsTable(this);
  late final $DivinationCasesTable divinationCases =
      $DivinationCasesTable(this);
  late final $DivinationWorkItemsTable divinationWorkItems =
      $DivinationWorkItemsTable(this);
  late final $CaseParticipantsTable caseParticipants =
      $CaseParticipantsTable(this);
  late final $PanelRefsTable panelRefs = $PanelRefsTable(this);
  late final $WorkItemPanelRefsTable workItemPanelRefs =
      $WorkItemPanelRefsTable(this);
  late final OutboxRecordsDao outboxRecordsDao =
      OutboxRecordsDao(this as PersistenceDriftDatabase);
  late final SyncStatesDao syncStatesDao =
      SyncStatesDao(this as PersistenceDriftDatabase);
  late final SeekersDao seekersDao =
      SeekersDao(this as PersistenceDriftDatabase);
  late final DivinationsDao divinationsDao =
      DivinationsDao(this as PersistenceDriftDatabase);
  late final SeekerDivinationMappersDao seekerDivinationMappersDao =
      SeekerDivinationMappersDao(this as PersistenceDriftDatabase);
  late final CombinedDivinationsDao combinedDivinationsDao =
      CombinedDivinationsDao(this as PersistenceDriftDatabase);
  late final DecisionLinksDao decisionLinksDao =
      DecisionLinksDao(this as PersistenceDriftDatabase);
  late final DivinationTagsDao divinationTagsDao =
      DivinationTagsDao(this as PersistenceDriftDatabase);
  late final DivinationTypesDao divinationTypesDao =
      DivinationTypesDao(this as PersistenceDriftDatabase);
  late final DivinationSubDivinationTypeMappersDao
      divinationSubDivinationTypeMappersDao =
      DivinationSubDivinationTypeMappersDao(this as PersistenceDriftDatabase);
  late final TimingDivinationsDao timingDivinationsDao =
      TimingDivinationsDao(this as PersistenceDriftDatabase);
  late final PanelsDao panelsDao = PanelsDao(this as PersistenceDriftDatabase);
  late final DivinationPanelMappersDao divinationPanelMappersDao =
      DivinationPanelMappersDao(this as PersistenceDriftDatabase);
  late final PanelSkillClassMappersDao panelSkillClassMappersDao =
      PanelSkillClassMappersDao(this as PersistenceDriftDatabase);
  late final DaYunRecordsDao daYunRecordsDao =
      DaYunRecordsDao(this as PersistenceDriftDatabase);
  late final TaiYuanRecordsDao taiYuanRecordsDao =
      TaiYuanRecordsDao(this as PersistenceDriftDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        outboxRecords,
        syncStates,
        seekers,
        divinations,
        seekerDivinationMappers,
        combinedDivinations,
        decisionLinks,
        divinationTags,
        divinationTypes,
        subDivinationTypes,
        divinationSubDivinationTypeMappers,
        divinationCalendars,
        timingDivinations,
        panels,
        divinationPanelMappers,
        panelSkillClassMappers,
        skills,
        skillClasses,
        daYunRecords,
        taiYuanRecords,
        divinationCases,
        divinationWorkItems,
        caseParticipants,
        panelRefs,
        workItemPanelRefs
      ];
}

typedef $$OutboxRecordsTableCreateCompanionBuilder = OutboxRecordsCompanion
    Function({
  required String operationId,
  required String scopeUid,
  required String entityType,
  required String entityId,
  required String opType,
  required String payloadJson,
  Value<String?> payloadSummary,
  Value<String?> payloadHash,
  required DateTime createdAtUtc,
  Value<int> attempt,
  Value<String> status,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<DateTime?> lastAttemptAtUtc,
  Value<DateTime?> succeededAtUtc,
  Value<int> rowid,
});
typedef $$OutboxRecordsTableUpdateCompanionBuilder = OutboxRecordsCompanion
    Function({
  Value<String> operationId,
  Value<String> scopeUid,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> opType,
  Value<String> payloadJson,
  Value<String?> payloadSummary,
  Value<String?> payloadHash,
  Value<DateTime> createdAtUtc,
  Value<int> attempt,
  Value<String> status,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<DateTime?> lastAttemptAtUtc,
  Value<DateTime?> succeededAtUtc,
  Value<int> rowid,
});

class $$OutboxRecordsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get opType => $composableBuilder(
      column: $table.opType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadSummary => $composableBuilder(
      column: $table.payloadSummary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadHash => $composableBuilder(
      column: $table.payloadHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAtUtc => $composableBuilder(
      column: $table.lastAttemptAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get succeededAtUtc => $composableBuilder(
      column: $table.succeededAtUtc,
      builder: (column) => ColumnFilters(column));
}

class $$OutboxRecordsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get opType => $composableBuilder(
      column: $table.opType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadSummary => $composableBuilder(
      column: $table.payloadSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadHash => $composableBuilder(
      column: $table.payloadHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAtUtc => $composableBuilder(
      column: $table.lastAttemptAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get succeededAtUtc => $composableBuilder(
      column: $table.succeededAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$OutboxRecordsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => column);

  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get payloadSummary => $composableBuilder(
      column: $table.payloadSummary, builder: (column) => column);

  GeneratedColumn<String> get payloadHash => $composableBuilder(
      column: $table.payloadHash, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode, builder: (column) => column);

  GeneratedColumn<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAtUtc => $composableBuilder(
      column: $table.lastAttemptAtUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get succeededAtUtc => $composableBuilder(
      column: $table.succeededAtUtc, builder: (column) => column);
}

class $$OutboxRecordsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $OutboxRecordsTable,
    OutboxRecordRow,
    $$OutboxRecordsTableFilterComposer,
    $$OutboxRecordsTableOrderingComposer,
    $$OutboxRecordsTableAnnotationComposer,
    $$OutboxRecordsTableCreateCompanionBuilder,
    $$OutboxRecordsTableUpdateCompanionBuilder,
    (
      OutboxRecordRow,
      BaseReferences<_$PersistenceDriftDatabase, $OutboxRecordsTable,
          OutboxRecordRow>
    ),
    OutboxRecordRow,
    PrefetchHooks Function()> {
  $$OutboxRecordsTableTableManager(
      _$PersistenceDriftDatabase db, $OutboxRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> operationId = const Value.absent(),
            Value<String> scopeUid = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> opType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> payloadSummary = const Value.absent(),
            Value<String?> payloadHash = const Value.absent(),
            Value<DateTime> createdAtUtc = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> lastErrorCode = const Value.absent(),
            Value<String?> lastErrorMessage = const Value.absent(),
            Value<DateTime?> lastAttemptAtUtc = const Value.absent(),
            Value<DateTime?> succeededAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxRecordsCompanion(
            operationId: operationId,
            scopeUid: scopeUid,
            entityType: entityType,
            entityId: entityId,
            opType: opType,
            payloadJson: payloadJson,
            payloadSummary: payloadSummary,
            payloadHash: payloadHash,
            createdAtUtc: createdAtUtc,
            attempt: attempt,
            status: status,
            lastErrorCode: lastErrorCode,
            lastErrorMessage: lastErrorMessage,
            lastAttemptAtUtc: lastAttemptAtUtc,
            succeededAtUtc: succeededAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String operationId,
            required String scopeUid,
            required String entityType,
            required String entityId,
            required String opType,
            required String payloadJson,
            Value<String?> payloadSummary = const Value.absent(),
            Value<String?> payloadHash = const Value.absent(),
            required DateTime createdAtUtc,
            Value<int> attempt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> lastErrorCode = const Value.absent(),
            Value<String?> lastErrorMessage = const Value.absent(),
            Value<DateTime?> lastAttemptAtUtc = const Value.absent(),
            Value<DateTime?> succeededAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxRecordsCompanion.insert(
            operationId: operationId,
            scopeUid: scopeUid,
            entityType: entityType,
            entityId: entityId,
            opType: opType,
            payloadJson: payloadJson,
            payloadSummary: payloadSummary,
            payloadHash: payloadHash,
            createdAtUtc: createdAtUtc,
            attempt: attempt,
            status: status,
            lastErrorCode: lastErrorCode,
            lastErrorMessage: lastErrorMessage,
            lastAttemptAtUtc: lastAttemptAtUtc,
            succeededAtUtc: succeededAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxRecordsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $OutboxRecordsTable,
    OutboxRecordRow,
    $$OutboxRecordsTableFilterComposer,
    $$OutboxRecordsTableOrderingComposer,
    $$OutboxRecordsTableAnnotationComposer,
    $$OutboxRecordsTableCreateCompanionBuilder,
    $$OutboxRecordsTableUpdateCompanionBuilder,
    (
      OutboxRecordRow,
      BaseReferences<_$PersistenceDriftDatabase, $OutboxRecordsTable,
          OutboxRecordRow>
    ),
    OutboxRecordRow,
    PrefetchHooks Function()>;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String scopeUid,
  required String entityType,
  required String cursorType,
  Value<int?> revision,
  Value<DateTime?> serverUpdatedAtUtc,
  Value<String?> tieBreaker,
  required DateTime cursorUpdatedAtUtc,
  Value<DateTime?> lastPulledAtUtc,
  Value<DateTime?> lastPushedAtUtc,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> scopeUid,
  Value<String> entityType,
  Value<String> cursorType,
  Value<int?> revision,
  Value<DateTime?> serverUpdatedAtUtc,
  Value<String?> tieBreaker,
  Value<DateTime> cursorUpdatedAtUtc,
  Value<DateTime?> lastPulledAtUtc,
  Value<DateTime?> lastPushedAtUtc,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursorType => $composableBuilder(
      column: $table.cursorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAtUtc => $composableBuilder(
      column: $table.serverUpdatedAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tieBreaker => $composableBuilder(
      column: $table.tieBreaker, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cursorUpdatedAtUtc => $composableBuilder(
      column: $table.cursorUpdatedAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPulledAtUtc => $composableBuilder(
      column: $table.lastPulledAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPushedAtUtc => $composableBuilder(
      column: $table.lastPushedAtUtc,
      builder: (column) => ColumnFilters(column));
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursorType => $composableBuilder(
      column: $table.cursorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAtUtc => $composableBuilder(
      column: $table.serverUpdatedAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tieBreaker => $composableBuilder(
      column: $table.tieBreaker, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cursorUpdatedAtUtc => $composableBuilder(
      column: $table.cursorUpdatedAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPulledAtUtc => $composableBuilder(
      column: $table.lastPulledAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPushedAtUtc => $composableBuilder(
      column: $table.lastPushedAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get cursorType => $composableBuilder(
      column: $table.cursorType, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAtUtc => $composableBuilder(
      column: $table.serverUpdatedAtUtc, builder: (column) => column);

  GeneratedColumn<String> get tieBreaker => $composableBuilder(
      column: $table.tieBreaker, builder: (column) => column);

  GeneratedColumn<DateTime> get cursorUpdatedAtUtc => $composableBuilder(
      column: $table.cursorUpdatedAtUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAtUtc => $composableBuilder(
      column: $table.lastPulledAtUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPushedAtUtc => $composableBuilder(
      column: $table.lastPushedAtUtc, builder: (column) => column);
}

class $$SyncStatesTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $SyncStatesTable,
    SyncStateRow,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$PersistenceDriftDatabase, $SyncStatesTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()> {
  $$SyncStatesTableTableManager(
      _$PersistenceDriftDatabase db, $SyncStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> scopeUid = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> cursorType = const Value.absent(),
            Value<int?> revision = const Value.absent(),
            Value<DateTime?> serverUpdatedAtUtc = const Value.absent(),
            Value<String?> tieBreaker = const Value.absent(),
            Value<DateTime> cursorUpdatedAtUtc = const Value.absent(),
            Value<DateTime?> lastPulledAtUtc = const Value.absent(),
            Value<DateTime?> lastPushedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion(
            scopeUid: scopeUid,
            entityType: entityType,
            cursorType: cursorType,
            revision: revision,
            serverUpdatedAtUtc: serverUpdatedAtUtc,
            tieBreaker: tieBreaker,
            cursorUpdatedAtUtc: cursorUpdatedAtUtc,
            lastPulledAtUtc: lastPulledAtUtc,
            lastPushedAtUtc: lastPushedAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String scopeUid,
            required String entityType,
            required String cursorType,
            Value<int?> revision = const Value.absent(),
            Value<DateTime?> serverUpdatedAtUtc = const Value.absent(),
            Value<String?> tieBreaker = const Value.absent(),
            required DateTime cursorUpdatedAtUtc,
            Value<DateTime?> lastPulledAtUtc = const Value.absent(),
            Value<DateTime?> lastPushedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion.insert(
            scopeUid: scopeUid,
            entityType: entityType,
            cursorType: cursorType,
            revision: revision,
            serverUpdatedAtUtc: serverUpdatedAtUtc,
            tieBreaker: tieBreaker,
            cursorUpdatedAtUtc: cursorUpdatedAtUtc,
            lastPulledAtUtc: lastPulledAtUtc,
            lastPushedAtUtc: lastPushedAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStatesTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $SyncStatesTable,
    SyncStateRow,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$PersistenceDriftDatabase, $SyncStatesTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()>;
typedef $$SeekersTableCreateCompanionBuilder = SeekersCompanion Function({
  required String uuid,
  Value<String?> username,
  Value<String?> nickname,
  required Gender gender,
  required DateTime createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required DateTimeType timingType,
  required DateTime datetime,
  required JiaZi yearGanZhi,
  required JiaZi monthGanZhi,
  required JiaZi dayGanZhi,
  required JiaZi timeGanZhi,
  required int lunarMonth,
  Value<bool> isLeapMonth,
  required int lunarDay,
  required String divinationUuid,
  Value<String?> timingInfoUuid,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<Location?> location,
  Value<String?> currentCalendarUuid,
  Value<int> rowid,
});
typedef $$SeekersTableUpdateCompanionBuilder = SeekersCompanion Function({
  Value<String> uuid,
  Value<String?> username,
  Value<String?> nickname,
  Value<Gender> gender,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTimeType> timingType,
  Value<DateTime> datetime,
  Value<JiaZi> yearGanZhi,
  Value<JiaZi> monthGanZhi,
  Value<JiaZi> dayGanZhi,
  Value<JiaZi> timeGanZhi,
  Value<int> lunarMonth,
  Value<bool> isLeapMonth,
  Value<int> lunarDay,
  Value<String> divinationUuid,
  Value<String?> timingInfoUuid,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<Location?> location,
  Value<String?> currentCalendarUuid,
  Value<int> rowid,
});

final class $$SeekersTableReferences extends BaseReferences<
    _$PersistenceDriftDatabase, $SeekersTable, SeekerModel> {
  $$SeekersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DivinationsTable,
      List<DivinationRequestInfoDataModel>> _divinationsRefsTable(
          _$PersistenceDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.divinations,
          aliasName: $_aliasNameGenerator(
              db.seekers.uuid, db.divinations.ownerSeekerUuid));

  $$DivinationsTableProcessedTableManager get divinationsRefs {
    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) =>
            f.ownerSeekerUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_divinationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SeekerDivinationMappersTable,
      List<SeekerDivinationMapper>> _seekerDivinationMappersRefsTable(
          _$PersistenceDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.seekerDivinationMappers,
          aliasName: $_aliasNameGenerator(
              db.seekers.uuid, db.seekerDivinationMappers.seekerUuid));

  $$SeekerDivinationMappersTableProcessedTableManager
      get seekerDivinationMappersRefs {
    final manager = $$SeekerDivinationMappersTableTableManager(
            $_db, $_db.seekerDivinationMappers)
        .filter(
            (f) => f.seekerUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_seekerDivinationMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SeekersTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $SeekersTable> {
  $$SeekersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Gender, Gender, String> get gender =>
      $composableBuilder(
          column: $table.gender,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTimeType, DateTimeType, int>
      get timingType => $composableBuilder(
          column: $table.timingType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get dayGanZhi =>
      $composableBuilder(
          column: $table.dayGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<DivinationDatetimeModel>?,
          List<DivinationDatetimeModel>, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Location?, Location, String> get location =>
      $composableBuilder(
          column: $table.location,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get currentCalendarUuid => $composableBuilder(
      column: $table.currentCalendarUuid,
      builder: (column) => ColumnFilters(column));

  Expression<bool> divinationsRefs(
      Expression<bool> Function($$DivinationsTableFilterComposer f) f) {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.ownerSeekerUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> seekerDivinationMappersRefs(
      Expression<bool> Function($$SeekerDivinationMappersTableFilterComposer f)
          f) {
    final $$SeekerDivinationMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.seekerUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SeekersTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $SeekersTable> {
  $$SeekersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timingType => $composableBuilder(
      column: $table.timingType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get yearGanZhi => $composableBuilder(
      column: $table.yearGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthGanZhi => $composableBuilder(
      column: $table.monthGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayGanZhi => $composableBuilder(
      column: $table.dayGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeGanZhi => $composableBuilder(
      column: $table.timeGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoListJson => $composableBuilder(
      column: $table.timingInfoListJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentCalendarUuid => $composableBuilder(
      column: $table.currentCalendarUuid,
      builder: (column) => ColumnOrderings(column));
}

class $$SeekersTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $SeekersTable> {
  $$SeekersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Gender, String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTimeType, int> get timingType =>
      $composableBuilder(
          column: $table.timingType, builder: (column) => column);

  GeneratedColumn<DateTime> get datetime =>
      $composableBuilder(column: $table.datetime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get dayGanZhi =>
      $composableBuilder(column: $table.dayGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi, builder: (column) => column);

  GeneratedColumn<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => column);

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => column);

  GeneratedColumn<int> get lunarDay =>
      $composableBuilder(column: $table.lunarDay, builder: (column) => column);

  GeneratedColumn<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid, builder: (column) => column);

  GeneratedColumn<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Location?, String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get currentCalendarUuid => $composableBuilder(
      column: $table.currentCalendarUuid, builder: (column) => column);

  Expression<T> divinationsRefs<T extends Object>(
      Expression<T> Function($$DivinationsTableAnnotationComposer a) f) {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.ownerSeekerUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> seekerDivinationMappersRefs<T extends Object>(
      Expression<T> Function($$SeekerDivinationMappersTableAnnotationComposer a)
          f) {
    final $$SeekerDivinationMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.seekerUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SeekersTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $SeekersTable,
    SeekerModel,
    $$SeekersTableFilterComposer,
    $$SeekersTableOrderingComposer,
    $$SeekersTableAnnotationComposer,
    $$SeekersTableCreateCompanionBuilder,
    $$SeekersTableUpdateCompanionBuilder,
    (SeekerModel, $$SeekersTableReferences),
    SeekerModel,
    PrefetchHooks Function(
        {bool divinationsRefs, bool seekerDivinationMappersRefs})> {
  $$SeekersTableTableManager(_$PersistenceDriftDatabase db, $SeekersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeekersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeekersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeekersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<Gender> gender = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTimeType> timingType = const Value.absent(),
            Value<DateTime> datetime = const Value.absent(),
            Value<JiaZi> yearGanZhi = const Value.absent(),
            Value<JiaZi> monthGanZhi = const Value.absent(),
            Value<JiaZi> dayGanZhi = const Value.absent(),
            Value<JiaZi> timeGanZhi = const Value.absent(),
            Value<int> lunarMonth = const Value.absent(),
            Value<bool> isLeapMonth = const Value.absent(),
            Value<int> lunarDay = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<String?> timingInfoUuid = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<Location?> location = const Value.absent(),
            Value<String?> currentCalendarUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SeekersCompanion(
            uuid: uuid,
            username: username,
            nickname: nickname,
            gender: gender,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            timingType: timingType,
            datetime: datetime,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            divinationUuid: divinationUuid,
            timingInfoUuid: timingInfoUuid,
            timingInfoListJson: timingInfoListJson,
            location: location,
            currentCalendarUuid: currentCalendarUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<String?> username = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            required Gender gender,
            required DateTime createdAt,
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required DateTimeType timingType,
            required DateTime datetime,
            required JiaZi yearGanZhi,
            required JiaZi monthGanZhi,
            required JiaZi dayGanZhi,
            required JiaZi timeGanZhi,
            required int lunarMonth,
            Value<bool> isLeapMonth = const Value.absent(),
            required int lunarDay,
            required String divinationUuid,
            Value<String?> timingInfoUuid = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<Location?> location = const Value.absent(),
            Value<String?> currentCalendarUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SeekersCompanion.insert(
            uuid: uuid,
            username: username,
            nickname: nickname,
            gender: gender,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            timingType: timingType,
            datetime: datetime,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            divinationUuid: divinationUuid,
            timingInfoUuid: timingInfoUuid,
            timingInfoListJson: timingInfoListJson,
            location: location,
            currentCalendarUuid: currentCalendarUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SeekersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {divinationsRefs = false, seekerDivinationMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (divinationsRefs) db.divinations,
                if (seekerDivinationMappersRefs) db.seekerDivinationMappers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (divinationsRefs)
                    await $_getPrefetchedData<SeekerModel, $SeekersTable,
                            DivinationRequestInfoDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$SeekersTableReferences._divinationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeekersTableReferences(db, table, p0)
                                .divinationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ownerSeekerUuid == item.uuid),
                        typedResults: items),
                  if (seekerDivinationMappersRefs)
                    await $_getPrefetchedData<SeekerModel, $SeekersTable,
                            SeekerDivinationMapper>(
                        currentTable: table,
                        referencedTable: $$SeekersTableReferences
                            ._seekerDivinationMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeekersTableReferences(db, table, p0)
                                .seekerDivinationMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.seekerUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SeekersTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $SeekersTable,
    SeekerModel,
    $$SeekersTableFilterComposer,
    $$SeekersTableOrderingComposer,
    $$SeekersTableAnnotationComposer,
    $$SeekersTableCreateCompanionBuilder,
    $$SeekersTableUpdateCompanionBuilder,
    (SeekerModel, $$SeekersTableReferences),
    SeekerModel,
    PrefetchHooks Function(
        {bool divinationsRefs, bool seekerDivinationMappersRefs})>;
typedef $$DivinationsTableCreateCompanionBuilder = DivinationsCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String divinationTypeUuid,
  Value<String?> fateYear,
  Value<String?> question,
  Value<String?> detail,
  Value<String?> ownerSeekerUuid,
  Value<Gender?> gender,
  Value<String?> seekerName,
  Value<String?> tinyPredict,
  Value<String?> directlyPredict,
  Value<int> rowid,
});
typedef $$DivinationsTableUpdateCompanionBuilder = DivinationsCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> divinationTypeUuid,
  Value<String?> fateYear,
  Value<String?> question,
  Value<String?> detail,
  Value<String?> ownerSeekerUuid,
  Value<Gender?> gender,
  Value<String?> seekerName,
  Value<String?> tinyPredict,
  Value<String?> directlyPredict,
  Value<int> rowid,
});

final class $$DivinationsTableReferences extends BaseReferences<
    _$PersistenceDriftDatabase,
    $DivinationsTable,
    DivinationRequestInfoDataModel> {
  $$DivinationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeekersTable _ownerSeekerUuidTable(_$PersistenceDriftDatabase db) =>
      db.seekers.createAlias($_aliasNameGenerator(
          db.divinations.ownerSeekerUuid, db.seekers.uuid));

  $$SeekersTableProcessedTableManager? get ownerSeekerUuid {
    final $_column = $_itemColumn<String>('seeker_uuid');
    if ($_column == null) return null;
    final manager = $$SeekersTableTableManager($_db, $_db.seekers)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerSeekerUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SeekerDivinationMappersTable,
      List<SeekerDivinationMapper>> _seekerDivinationMappersRefsTable(
          _$PersistenceDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.seekerDivinationMappers,
          aliasName: $_aliasNameGenerator(
              db.divinations.uuid, db.seekerDivinationMappers.divinationUuid));

  $$SeekerDivinationMappersTableProcessedTableManager
      get seekerDivinationMappersRefs {
    final manager = $$SeekerDivinationMappersTableTableManager(
            $_db, $_db.seekerDivinationMappers)
        .filter((f) =>
            f.divinationUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_seekerDivinationMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CombinedDivinationsTable,
      List<CombinedDivination>> _combinedDivinationsRefsTable(
          _$PersistenceDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.combinedDivinations,
          aliasName: $_aliasNameGenerator(
              db.divinations.uuid, db.combinedDivinations.divinationUuid));

  $$CombinedDivinationsTableProcessedTableManager get combinedDivinationsRefs {
    final manager =
        $$CombinedDivinationsTableTableManager($_db, $_db.combinedDivinations)
            .filter((f) =>
                f.divinationUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_combinedDivinationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DivinationsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationsTable> {
  $$DivinationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinationTypeUuid => $composableBuilder(
      column: $table.divinationTypeUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fateYear => $composableBuilder(
      column: $table.fateYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Gender?, Gender, String> get gender =>
      $composableBuilder(
          column: $table.gender,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get seekerName => $composableBuilder(
      column: $table.seekerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tinyPredict => $composableBuilder(
      column: $table.tinyPredict, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict,
      builder: (column) => ColumnFilters(column));

  $$SeekersTableFilterComposer get ownerSeekerUuid {
    final $$SeekersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerSeekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableFilterComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> seekerDivinationMappersRefs(
      Expression<bool> Function($$SeekerDivinationMappersTableFilterComposer f)
          f) {
    final $$SeekerDivinationMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> combinedDivinationsRefs(
      Expression<bool> Function($$CombinedDivinationsTableFilterComposer f) f) {
    final $$CombinedDivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.combinedDivinations,
        getReferencedColumn: (t) => t.divinationUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CombinedDivinationsTableFilterComposer(
              $db: $db,
              $table: $db.combinedDivinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DivinationsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationsTable> {
  $$DivinationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationTypeUuid => $composableBuilder(
      column: $table.divinationTypeUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fateYear => $composableBuilder(
      column: $table.fateYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seekerName => $composableBuilder(
      column: $table.seekerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tinyPredict => $composableBuilder(
      column: $table.tinyPredict, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict,
      builder: (column) => ColumnOrderings(column));

  $$SeekersTableOrderingComposer get ownerSeekerUuid {
    final $$SeekersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerSeekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableOrderingComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationsTable> {
  $$DivinationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get divinationTypeUuid => $composableBuilder(
      column: $table.divinationTypeUuid, builder: (column) => column);

  GeneratedColumn<String> get fateYear =>
      $composableBuilder(column: $table.fateYear, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Gender?, String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get seekerName => $composableBuilder(
      column: $table.seekerName, builder: (column) => column);

  GeneratedColumn<String> get tinyPredict => $composableBuilder(
      column: $table.tinyPredict, builder: (column) => column);

  GeneratedColumn<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict, builder: (column) => column);

  $$SeekersTableAnnotationComposer get ownerSeekerUuid {
    final $$SeekersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerSeekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableAnnotationComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> seekerDivinationMappersRefs<T extends Object>(
      Expression<T> Function($$SeekerDivinationMappersTableAnnotationComposer a)
          f) {
    final $$SeekerDivinationMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> combinedDivinationsRefs<T extends Object>(
      Expression<T> Function($$CombinedDivinationsTableAnnotationComposer a)
          f) {
    final $$CombinedDivinationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.combinedDivinations,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CombinedDivinationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.combinedDivinations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DivinationsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DivinationsTable,
    DivinationRequestInfoDataModel,
    $$DivinationsTableFilterComposer,
    $$DivinationsTableOrderingComposer,
    $$DivinationsTableAnnotationComposer,
    $$DivinationsTableCreateCompanionBuilder,
    $$DivinationsTableUpdateCompanionBuilder,
    (DivinationRequestInfoDataModel, $$DivinationsTableReferences),
    DivinationRequestInfoDataModel,
    PrefetchHooks Function(
        {bool ownerSeekerUuid,
        bool seekerDivinationMappersRefs,
        bool combinedDivinationsRefs})> {
  $$DivinationsTableTableManager(
      _$PersistenceDriftDatabase db, $DivinationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> divinationTypeUuid = const Value.absent(),
            Value<String?> fateYear = const Value.absent(),
            Value<String?> question = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<String?> ownerSeekerUuid = const Value.absent(),
            Value<Gender?> gender = const Value.absent(),
            Value<String?> seekerName = const Value.absent(),
            Value<String?> tinyPredict = const Value.absent(),
            Value<String?> directlyPredict = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationsCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationTypeUuid: divinationTypeUuid,
            fateYear: fateYear,
            question: question,
            detail: detail,
            ownerSeekerUuid: ownerSeekerUuid,
            gender: gender,
            seekerName: seekerName,
            tinyPredict: tinyPredict,
            directlyPredict: directlyPredict,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String divinationTypeUuid,
            Value<String?> fateYear = const Value.absent(),
            Value<String?> question = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<String?> ownerSeekerUuid = const Value.absent(),
            Value<Gender?> gender = const Value.absent(),
            Value<String?> seekerName = const Value.absent(),
            Value<String?> tinyPredict = const Value.absent(),
            Value<String?> directlyPredict = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationsCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationTypeUuid: divinationTypeUuid,
            fateYear: fateYear,
            question: question,
            detail: detail,
            ownerSeekerUuid: ownerSeekerUuid,
            gender: gender,
            seekerName: seekerName,
            tinyPredict: tinyPredict,
            directlyPredict: directlyPredict,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DivinationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ownerSeekerUuid = false,
              seekerDivinationMappersRefs = false,
              combinedDivinationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (seekerDivinationMappersRefs) db.seekerDivinationMappers,
                if (combinedDivinationsRefs) db.combinedDivinations
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ownerSeekerUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerSeekerUuid,
                    referencedTable:
                        $$DivinationsTableReferences._ownerSeekerUuidTable(db),
                    referencedColumn: $$DivinationsTableReferences
                        ._ownerSeekerUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (seekerDivinationMappersRefs)
                    await $_getPrefetchedData<DivinationRequestInfoDataModel,
                            $DivinationsTable, SeekerDivinationMapper>(
                        currentTable: table,
                        referencedTable: $$DivinationsTableReferences
                            ._seekerDivinationMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationsTableReferences(db, table, p0)
                                .seekerDivinationMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.divinationUuid == item.uuid),
                        typedResults: items),
                  if (combinedDivinationsRefs)
                    await $_getPrefetchedData<DivinationRequestInfoDataModel,
                            $DivinationsTable, CombinedDivination>(
                        currentTable: table,
                        referencedTable: $$DivinationsTableReferences
                            ._combinedDivinationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationsTableReferences(db, table, p0)
                                .combinedDivinationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.divinationUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DivinationsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DivinationsTable,
    DivinationRequestInfoDataModel,
    $$DivinationsTableFilterComposer,
    $$DivinationsTableOrderingComposer,
    $$DivinationsTableAnnotationComposer,
    $$DivinationsTableCreateCompanionBuilder,
    $$DivinationsTableUpdateCompanionBuilder,
    (DivinationRequestInfoDataModel, $$DivinationsTableReferences),
    DivinationRequestInfoDataModel,
    PrefetchHooks Function(
        {bool ownerSeekerUuid,
        bool seekerDivinationMappersRefs,
        bool combinedDivinationsRefs})>;
typedef $$SeekerDivinationMappersTableCreateCompanionBuilder
    = SeekerDivinationMappersCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String divinationUuid,
  required String seekerUuid,
});
typedef $$SeekerDivinationMappersTableUpdateCompanionBuilder
    = SeekerDivinationMappersCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> divinationUuid,
  Value<String> seekerUuid,
});

final class $$SeekerDivinationMappersTableReferences extends BaseReferences<
    _$PersistenceDriftDatabase,
    $SeekerDivinationMappersTable,
    SeekerDivinationMapper> {
  $$SeekerDivinationMappersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DivinationsTable _divinationUuidTable(
          _$PersistenceDriftDatabase db) =>
      db.divinations.createAlias($_aliasNameGenerator(
          db.seekerDivinationMappers.divinationUuid, db.divinations.uuid));

  $$DivinationsTableProcessedTableManager get divinationUuid {
    final $_column = $_itemColumn<String>('divination_uuid')!;

    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_divinationUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SeekersTable _seekerUuidTable(_$PersistenceDriftDatabase db) =>
      db.seekers.createAlias($_aliasNameGenerator(
          db.seekerDivinationMappers.seekerUuid, db.seekers.uuid));

  $$SeekersTableProcessedTableManager get seekerUuid {
    final $_column = $_itemColumn<String>('seeker_uuid')!;

    final manager = $$SeekersTableTableManager($_db, $_db.seekers)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seekerUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SeekerDivinationMappersTableFilterComposer extends Composer<
    _$PersistenceDriftDatabase, $SeekerDivinationMappersTable> {
  $$SeekerDivinationMappersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$DivinationsTableFilterComposer get divinationUuid {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableFilterComposer get seekerUuid {
    final $$SeekersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableFilterComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SeekerDivinationMappersTableOrderingComposer extends Composer<
    _$PersistenceDriftDatabase, $SeekerDivinationMappersTable> {
  $$SeekerDivinationMappersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$DivinationsTableOrderingComposer get divinationUuid {
    final $$DivinationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableOrderingComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableOrderingComposer get seekerUuid {
    final $$SeekersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableOrderingComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SeekerDivinationMappersTableAnnotationComposer extends Composer<
    _$PersistenceDriftDatabase, $SeekerDivinationMappersTable> {
  $$SeekerDivinationMappersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DivinationsTableAnnotationComposer get divinationUuid {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableAnnotationComposer get seekerUuid {
    final $$SeekersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableAnnotationComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SeekerDivinationMappersTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $SeekerDivinationMappersTable,
    SeekerDivinationMapper,
    $$SeekerDivinationMappersTableFilterComposer,
    $$SeekerDivinationMappersTableOrderingComposer,
    $$SeekerDivinationMappersTableAnnotationComposer,
    $$SeekerDivinationMappersTableCreateCompanionBuilder,
    $$SeekerDivinationMappersTableUpdateCompanionBuilder,
    (SeekerDivinationMapper, $$SeekerDivinationMappersTableReferences),
    SeekerDivinationMapper,
    PrefetchHooks Function({bool divinationUuid, bool seekerUuid})> {
  $$SeekerDivinationMappersTableTableManager(
      _$PersistenceDriftDatabase db, $SeekerDivinationMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeekerDivinationMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SeekerDivinationMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeekerDivinationMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<String> seekerUuid = const Value.absent(),
          }) =>
              SeekerDivinationMappersCompanion(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            seekerUuid: seekerUuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String divinationUuid,
            required String seekerUuid,
          }) =>
              SeekerDivinationMappersCompanion.insert(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            seekerUuid: seekerUuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SeekerDivinationMappersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {divinationUuid = false, seekerUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (divinationUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.divinationUuid,
                    referencedTable: $$SeekerDivinationMappersTableReferences
                        ._divinationUuidTable(db),
                    referencedColumn: $$SeekerDivinationMappersTableReferences
                        ._divinationUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (seekerUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seekerUuid,
                    referencedTable: $$SeekerDivinationMappersTableReferences
                        ._seekerUuidTable(db),
                    referencedColumn: $$SeekerDivinationMappersTableReferences
                        ._seekerUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SeekerDivinationMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$PersistenceDriftDatabase,
        $SeekerDivinationMappersTable,
        SeekerDivinationMapper,
        $$SeekerDivinationMappersTableFilterComposer,
        $$SeekerDivinationMappersTableOrderingComposer,
        $$SeekerDivinationMappersTableAnnotationComposer,
        $$SeekerDivinationMappersTableCreateCompanionBuilder,
        $$SeekerDivinationMappersTableUpdateCompanionBuilder,
        (SeekerDivinationMapper, $$SeekerDivinationMappersTableReferences),
        SeekerDivinationMapper,
        PrefetchHooks Function({bool divinationUuid, bool seekerUuid})>;
typedef $$CombinedDivinationsTableCreateCompanionBuilder
    = CombinedDivinationsCompanion Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required int order,
  required String divinationUuid,
  Value<int> rowid,
});
typedef $$CombinedDivinationsTableUpdateCompanionBuilder
    = CombinedDivinationsCompanion Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<int> order,
  Value<String> divinationUuid,
  Value<int> rowid,
});

final class $$CombinedDivinationsTableReferences extends BaseReferences<
    _$PersistenceDriftDatabase, $CombinedDivinationsTable, CombinedDivination> {
  $$CombinedDivinationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DivinationsTable _divinationUuidTable(
          _$PersistenceDriftDatabase db) =>
      db.divinations.createAlias($_aliasNameGenerator(
          db.combinedDivinations.divinationUuid, db.divinations.uuid));

  $$DivinationsTableProcessedTableManager get divinationUuid {
    final $_column = $_itemColumn<String>('divination_uuid')!;

    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_divinationUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CombinedDivinationsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $CombinedDivinationsTable> {
  $$CombinedDivinationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  $$DivinationsTableFilterComposer get divinationUuid {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CombinedDivinationsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $CombinedDivinationsTable> {
  $$CombinedDivinationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  $$DivinationsTableOrderingComposer get divinationUuid {
    final $$DivinationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableOrderingComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CombinedDivinationsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $CombinedDivinationsTable> {
  $$CombinedDivinationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$DivinationsTableAnnotationComposer get divinationUuid {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CombinedDivinationsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $CombinedDivinationsTable,
    CombinedDivination,
    $$CombinedDivinationsTableFilterComposer,
    $$CombinedDivinationsTableOrderingComposer,
    $$CombinedDivinationsTableAnnotationComposer,
    $$CombinedDivinationsTableCreateCompanionBuilder,
    $$CombinedDivinationsTableUpdateCompanionBuilder,
    (CombinedDivination, $$CombinedDivinationsTableReferences),
    CombinedDivination,
    PrefetchHooks Function({bool divinationUuid})> {
  $$CombinedDivinationsTableTableManager(
      _$PersistenceDriftDatabase db, $CombinedDivinationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CombinedDivinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CombinedDivinationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CombinedDivinationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CombinedDivinationsCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            order: order,
            divinationUuid: divinationUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required int order,
            required String divinationUuid,
            Value<int> rowid = const Value.absent(),
          }) =>
              CombinedDivinationsCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            order: order,
            divinationUuid: divinationUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CombinedDivinationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({divinationUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (divinationUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.divinationUuid,
                    referencedTable: $$CombinedDivinationsTableReferences
                        ._divinationUuidTable(db),
                    referencedColumn: $$CombinedDivinationsTableReferences
                        ._divinationUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CombinedDivinationsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $CombinedDivinationsTable,
    CombinedDivination,
    $$CombinedDivinationsTableFilterComposer,
    $$CombinedDivinationsTableOrderingComposer,
    $$CombinedDivinationsTableAnnotationComposer,
    $$CombinedDivinationsTableCreateCompanionBuilder,
    $$CombinedDivinationsTableUpdateCompanionBuilder,
    (CombinedDivination, $$CombinedDivinationsTableReferences),
    CombinedDivination,
    PrefetchHooks Function({bool divinationUuid})>;
typedef $$DecisionLinksTableCreateCompanionBuilder = DecisionLinksCompanion
    Function({
  required String id,
  required String sourceUuid,
  required String targetUuid,
  required String intent,
  Value<String?> contextSnapshotJson,
  required int createdAtMs,
  required int updatedAtMs,
  Value<int?> deletedAtMs,
  required String scopeUid,
  Value<String?> unknownFields,
  Value<int> rowid,
});
typedef $$DecisionLinksTableUpdateCompanionBuilder = DecisionLinksCompanion
    Function({
  Value<String> id,
  Value<String> sourceUuid,
  Value<String> targetUuid,
  Value<String> intent,
  Value<String?> contextSnapshotJson,
  Value<int> createdAtMs,
  Value<int> updatedAtMs,
  Value<int?> deletedAtMs,
  Value<String> scopeUid,
  Value<String?> unknownFields,
  Value<int> rowid,
});

class $$DecisionLinksTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DecisionLinksTable> {
  $$DecisionLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetUuid => $composableBuilder(
      column: $table.targetUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intent => $composableBuilder(
      column: $table.intent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextSnapshotJson => $composableBuilder(
      column: $table.contextSnapshotJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
      column: $table.updatedAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
      column: $table.deletedAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unknownFields => $composableBuilder(
      column: $table.unknownFields, builder: (column) => ColumnFilters(column));
}

class $$DecisionLinksTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DecisionLinksTable> {
  $$DecisionLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetUuid => $composableBuilder(
      column: $table.targetUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intent => $composableBuilder(
      column: $table.intent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextSnapshotJson => $composableBuilder(
      column: $table.contextSnapshotJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
      column: $table.updatedAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
      column: $table.deletedAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unknownFields => $composableBuilder(
      column: $table.unknownFields,
      builder: (column) => ColumnOrderings(column));
}

class $$DecisionLinksTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DecisionLinksTable> {
  $$DecisionLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => column);

  GeneratedColumn<String> get targetUuid => $composableBuilder(
      column: $table.targetUuid, builder: (column) => column);

  GeneratedColumn<String> get intent =>
      $composableBuilder(column: $table.intent, builder: (column) => column);

  GeneratedColumn<String> get contextSnapshotJson => $composableBuilder(
      column: $table.contextSnapshotJson, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
      column: $table.updatedAtMs, builder: (column) => column);

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
      column: $table.deletedAtMs, builder: (column) => column);

  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<String> get unknownFields => $composableBuilder(
      column: $table.unknownFields, builder: (column) => column);
}

class $$DecisionLinksTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DecisionLinksTable,
    DecisionLinkRow,
    $$DecisionLinksTableFilterComposer,
    $$DecisionLinksTableOrderingComposer,
    $$DecisionLinksTableAnnotationComposer,
    $$DecisionLinksTableCreateCompanionBuilder,
    $$DecisionLinksTableUpdateCompanionBuilder,
    (
      DecisionLinkRow,
      BaseReferences<_$PersistenceDriftDatabase, $DecisionLinksTable,
          DecisionLinkRow>
    ),
    DecisionLinkRow,
    PrefetchHooks Function()> {
  $$DecisionLinksTableTableManager(
      _$PersistenceDriftDatabase db, $DecisionLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceUuid = const Value.absent(),
            Value<String> targetUuid = const Value.absent(),
            Value<String> intent = const Value.absent(),
            Value<String?> contextSnapshotJson = const Value.absent(),
            Value<int> createdAtMs = const Value.absent(),
            Value<int> updatedAtMs = const Value.absent(),
            Value<int?> deletedAtMs = const Value.absent(),
            Value<String> scopeUid = const Value.absent(),
            Value<String?> unknownFields = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DecisionLinksCompanion(
            id: id,
            sourceUuid: sourceUuid,
            targetUuid: targetUuid,
            intent: intent,
            contextSnapshotJson: contextSnapshotJson,
            createdAtMs: createdAtMs,
            updatedAtMs: updatedAtMs,
            deletedAtMs: deletedAtMs,
            scopeUid: scopeUid,
            unknownFields: unknownFields,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceUuid,
            required String targetUuid,
            required String intent,
            Value<String?> contextSnapshotJson = const Value.absent(),
            required int createdAtMs,
            required int updatedAtMs,
            Value<int?> deletedAtMs = const Value.absent(),
            required String scopeUid,
            Value<String?> unknownFields = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DecisionLinksCompanion.insert(
            id: id,
            sourceUuid: sourceUuid,
            targetUuid: targetUuid,
            intent: intent,
            contextSnapshotJson: contextSnapshotJson,
            createdAtMs: createdAtMs,
            updatedAtMs: updatedAtMs,
            deletedAtMs: deletedAtMs,
            scopeUid: scopeUid,
            unknownFields: unknownFields,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DecisionLinksTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DecisionLinksTable,
    DecisionLinkRow,
    $$DecisionLinksTableFilterComposer,
    $$DecisionLinksTableOrderingComposer,
    $$DecisionLinksTableAnnotationComposer,
    $$DecisionLinksTableCreateCompanionBuilder,
    $$DecisionLinksTableUpdateCompanionBuilder,
    (
      DecisionLinkRow,
      BaseReferences<_$PersistenceDriftDatabase, $DecisionLinksTable,
          DecisionLinkRow>
    ),
    DecisionLinkRow,
    PrefetchHooks Function()>;
typedef $$DivinationTagsTableCreateCompanionBuilder = DivinationTagsCompanion
    Function({
  required String divinationUuid,
  required String domain,
  required String tagKey,
  required String tagValue,
  required String scopeUid,
  required int createdAtMs,
  Value<int> rowid,
});
typedef $$DivinationTagsTableUpdateCompanionBuilder = DivinationTagsCompanion
    Function({
  Value<String> divinationUuid,
  Value<String> domain,
  Value<String> tagKey,
  Value<String> tagValue,
  Value<String> scopeUid,
  Value<int> createdAtMs,
  Value<int> rowid,
});

class $$DivinationTagsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationTagsTable> {
  $$DivinationTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagKey => $composableBuilder(
      column: $table.tagKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagValue => $composableBuilder(
      column: $table.tagValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => ColumnFilters(column));
}

class $$DivinationTagsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationTagsTable> {
  $$DivinationTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagKey => $composableBuilder(
      column: $table.tagKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagValue => $composableBuilder(
      column: $table.tagValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => ColumnOrderings(column));
}

class $$DivinationTagsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationTagsTable> {
  $$DivinationTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get tagKey =>
      $composableBuilder(column: $table.tagKey, builder: (column) => column);

  GeneratedColumn<String> get tagValue =>
      $composableBuilder(column: $table.tagValue, builder: (column) => column);

  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => column);
}

class $$DivinationTagsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DivinationTagsTable,
    DivinationTagRow,
    $$DivinationTagsTableFilterComposer,
    $$DivinationTagsTableOrderingComposer,
    $$DivinationTagsTableAnnotationComposer,
    $$DivinationTagsTableCreateCompanionBuilder,
    $$DivinationTagsTableUpdateCompanionBuilder,
    (
      DivinationTagRow,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationTagsTable,
          DivinationTagRow>
    ),
    DivinationTagRow,
    PrefetchHooks Function()> {
  $$DivinationTagsTableTableManager(
      _$PersistenceDriftDatabase db, $DivinationTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> divinationUuid = const Value.absent(),
            Value<String> domain = const Value.absent(),
            Value<String> tagKey = const Value.absent(),
            Value<String> tagValue = const Value.absent(),
            Value<String> scopeUid = const Value.absent(),
            Value<int> createdAtMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationTagsCompanion(
            divinationUuid: divinationUuid,
            domain: domain,
            tagKey: tagKey,
            tagValue: tagValue,
            scopeUid: scopeUid,
            createdAtMs: createdAtMs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String divinationUuid,
            required String domain,
            required String tagKey,
            required String tagValue,
            required String scopeUid,
            required int createdAtMs,
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationTagsCompanion.insert(
            divinationUuid: divinationUuid,
            domain: domain,
            tagKey: tagKey,
            tagValue: tagValue,
            scopeUid: scopeUid,
            createdAtMs: createdAtMs,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DivinationTagsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DivinationTagsTable,
    DivinationTagRow,
    $$DivinationTagsTableFilterComposer,
    $$DivinationTagsTableOrderingComposer,
    $$DivinationTagsTableAnnotationComposer,
    $$DivinationTagsTableCreateCompanionBuilder,
    $$DivinationTagsTableUpdateCompanionBuilder,
    (
      DivinationTagRow,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationTagsTable,
          DivinationTagRow>
    ),
    DivinationTagRow,
    PrefetchHooks Function()>;
typedef $$DivinationTypesTableCreateCompanionBuilder = DivinationTypesCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String name,
  required String description,
  required bool isCustomized,
  required bool isAvailable,
  Value<int> rowid,
});
typedef $$DivinationTypesTableUpdateCompanionBuilder = DivinationTypesCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> name,
  Value<String> description,
  Value<bool> isCustomized,
  Value<bool> isAvailable,
  Value<int> rowid,
});

final class $$DivinationTypesTableReferences extends BaseReferences<
    _$PersistenceDriftDatabase,
    $DivinationTypesTable,
    DivinationTypeDataModel> {
  $$DivinationTypesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DivinationSubDivinationTypeMappersTable,
          List<DivinationSubDivinationTypeMapper>>
      _divinationSubDivinationTypeMappersRefsTable(
              _$PersistenceDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.divinationSubDivinationTypeMappers,
              aliasName: $_aliasNameGenerator(db.divinationTypes.uuid,
                  db.divinationSubDivinationTypeMappers.typeUuid));

  $$DivinationSubDivinationTypeMappersTableProcessedTableManager
      get divinationSubDivinationTypeMappersRefs {
    final manager = $$DivinationSubDivinationTypeMappersTableTableManager(
            $_db, $_db.divinationSubDivinationTypeMappers)
        .filter(
            (f) => f.typeUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult
        .readTableOrNull(_divinationSubDivinationTypeMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DivinationTypesTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationTypesTable> {
  $$DivinationTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  Expression<bool> divinationSubDivinationTypeMappersRefs(
      Expression<bool> Function(
              $$DivinationSubDivinationTypeMappersTableFilterComposer f)
          f) {
    final $$DivinationSubDivinationTypeMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.typeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DivinationTypesTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationTypesTable> {
  $$DivinationTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));
}

class $$DivinationTypesTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationTypesTable> {
  $$DivinationTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  Expression<T> divinationSubDivinationTypeMappersRefs<T extends Object>(
      Expression<T> Function(
              $$DivinationSubDivinationTypeMappersTableAnnotationComposer a)
          f) {
    final $$DivinationSubDivinationTypeMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.typeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DivinationTypesTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DivinationTypesTable,
    DivinationTypeDataModel,
    $$DivinationTypesTableFilterComposer,
    $$DivinationTypesTableOrderingComposer,
    $$DivinationTypesTableAnnotationComposer,
    $$DivinationTypesTableCreateCompanionBuilder,
    $$DivinationTypesTableUpdateCompanionBuilder,
    (DivinationTypeDataModel, $$DivinationTypesTableReferences),
    DivinationTypeDataModel,
    PrefetchHooks Function({bool divinationSubDivinationTypeMappersRefs})> {
  $$DivinationTypesTableTableManager(
      _$PersistenceDriftDatabase db, $DivinationTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationTypesCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            name: name,
            description: description,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String name,
            required String description,
            required bool isCustomized,
            required bool isAvailable,
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationTypesCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            name: name,
            description: description,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DivinationTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {divinationSubDivinationTypeMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (divinationSubDivinationTypeMappersRefs)
                  db.divinationSubDivinationTypeMappers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (divinationSubDivinationTypeMappersRefs)
                    await $_getPrefetchedData<
                            DivinationTypeDataModel,
                            $DivinationTypesTable,
                            DivinationSubDivinationTypeMapper>(
                        currentTable: table,
                        referencedTable: $$DivinationTypesTableReferences
                            ._divinationSubDivinationTypeMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationTypesTableReferences(db, table, p0)
                                .divinationSubDivinationTypeMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.typeUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DivinationTypesTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DivinationTypesTable,
    DivinationTypeDataModel,
    $$DivinationTypesTableFilterComposer,
    $$DivinationTypesTableOrderingComposer,
    $$DivinationTypesTableAnnotationComposer,
    $$DivinationTypesTableCreateCompanionBuilder,
    $$DivinationTypesTableUpdateCompanionBuilder,
    (DivinationTypeDataModel, $$DivinationTypesTableReferences),
    DivinationTypeDataModel,
    PrefetchHooks Function({bool divinationSubDivinationTypeMappersRefs})>;
typedef $$SubDivinationTypesTableCreateCompanionBuilder
    = SubDivinationTypesCompanion Function({
  required String uuid,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> hiddenAt,
  required String name,
  required bool isCustomized,
  required bool isAvailable,
  Value<int> rowid,
});
typedef $$SubDivinationTypesTableUpdateCompanionBuilder
    = SubDivinationTypesCompanion Function({
  Value<String> uuid,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> hiddenAt,
  Value<String> name,
  Value<bool> isCustomized,
  Value<bool> isAvailable,
  Value<int> rowid,
});

final class $$SubDivinationTypesTableReferences extends BaseReferences<
    _$PersistenceDriftDatabase,
    $SubDivinationTypesTable,
    SubDivinationTypeDataModel> {
  $$SubDivinationTypesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DivinationSubDivinationTypeMappersTable,
          List<DivinationSubDivinationTypeMapper>>
      _divinationSubDivinationTypeMappersRefsTable(
              _$PersistenceDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.divinationSubDivinationTypeMappers,
              aliasName: $_aliasNameGenerator(db.subDivinationTypes.uuid,
                  db.divinationSubDivinationTypeMappers.subTypeUuid));

  $$DivinationSubDivinationTypeMappersTableProcessedTableManager
      get divinationSubDivinationTypeMappersRefs {
    final manager = $$DivinationSubDivinationTypeMappersTableTableManager(
            $_db, $_db.divinationSubDivinationTypeMappers)
        .filter(
            (f) => f.subTypeUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult
        .readTableOrNull(_divinationSubDivinationTypeMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubDivinationTypesTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $SubDivinationTypesTable> {
  $$SubDivinationTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get hiddenAt => $composableBuilder(
      column: $table.hiddenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  Expression<bool> divinationSubDivinationTypeMappersRefs(
      Expression<bool> Function(
              $$DivinationSubDivinationTypeMappersTableFilterComposer f)
          f) {
    final $$DivinationSubDivinationTypeMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.subTypeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SubDivinationTypesTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $SubDivinationTypesTable> {
  $$SubDivinationTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get hiddenAt => $composableBuilder(
      column: $table.hiddenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));
}

class $$SubDivinationTypesTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $SubDivinationTypesTable> {
  $$SubDivinationTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get hiddenAt =>
      $composableBuilder(column: $table.hiddenAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  Expression<T> divinationSubDivinationTypeMappersRefs<T extends Object>(
      Expression<T> Function(
              $$DivinationSubDivinationTypeMappersTableAnnotationComposer a)
          f) {
    final $$DivinationSubDivinationTypeMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.subTypeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SubDivinationTypesTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $SubDivinationTypesTable,
    SubDivinationTypeDataModel,
    $$SubDivinationTypesTableFilterComposer,
    $$SubDivinationTypesTableOrderingComposer,
    $$SubDivinationTypesTableAnnotationComposer,
    $$SubDivinationTypesTableCreateCompanionBuilder,
    $$SubDivinationTypesTableUpdateCompanionBuilder,
    (SubDivinationTypeDataModel, $$SubDivinationTypesTableReferences),
    SubDivinationTypeDataModel,
    PrefetchHooks Function({bool divinationSubDivinationTypeMappersRefs})> {
  $$SubDivinationTypesTableTableManager(
      _$PersistenceDriftDatabase db, $SubDivinationTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubDivinationTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubDivinationTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubDivinationTypesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> hiddenAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubDivinationTypesCompanion(
            uuid: uuid,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            hiddenAt: hiddenAt,
            name: name,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> hiddenAt = const Value.absent(),
            required String name,
            required bool isCustomized,
            required bool isAvailable,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubDivinationTypesCompanion.insert(
            uuid: uuid,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            hiddenAt: hiddenAt,
            name: name,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubDivinationTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {divinationSubDivinationTypeMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (divinationSubDivinationTypeMappersRefs)
                  db.divinationSubDivinationTypeMappers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (divinationSubDivinationTypeMappersRefs)
                    await $_getPrefetchedData<
                            SubDivinationTypeDataModel,
                            $SubDivinationTypesTable,
                            DivinationSubDivinationTypeMapper>(
                        currentTable: table,
                        referencedTable: $$SubDivinationTypesTableReferences
                            ._divinationSubDivinationTypeMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubDivinationTypesTableReferences(db, table, p0)
                                .divinationSubDivinationTypeMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subTypeUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubDivinationTypesTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $SubDivinationTypesTable,
    SubDivinationTypeDataModel,
    $$SubDivinationTypesTableFilterComposer,
    $$SubDivinationTypesTableOrderingComposer,
    $$SubDivinationTypesTableAnnotationComposer,
    $$SubDivinationTypesTableCreateCompanionBuilder,
    $$SubDivinationTypesTableUpdateCompanionBuilder,
    (SubDivinationTypeDataModel, $$SubDivinationTypesTableReferences),
    SubDivinationTypeDataModel,
    PrefetchHooks Function({bool divinationSubDivinationTypeMappersRefs})>;
typedef $$DivinationSubDivinationTypeMappersTableCreateCompanionBuilder
    = DivinationSubDivinationTypeMappersCompanion Function({
  Value<int> id,
  required String typeUuid,
  required String subTypeUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
});
typedef $$DivinationSubDivinationTypeMappersTableUpdateCompanionBuilder
    = DivinationSubDivinationTypeMappersCompanion Function({
  Value<int> id,
  Value<String> typeUuid,
  Value<String> subTypeUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
});

final class $$DivinationSubDivinationTypeMappersTableReferences
    extends BaseReferences<
        _$PersistenceDriftDatabase,
        $DivinationSubDivinationTypeMappersTable,
        DivinationSubDivinationTypeMapper> {
  $$DivinationSubDivinationTypeMappersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DivinationTypesTable _typeUuidTable(_$PersistenceDriftDatabase db) =>
      db.divinationTypes.createAlias($_aliasNameGenerator(
          db.divinationSubDivinationTypeMappers.typeUuid,
          db.divinationTypes.uuid));

  $$DivinationTypesTableProcessedTableManager get typeUuid {
    final $_column = $_itemColumn<String>('divination_type_uuid')!;

    final manager =
        $$DivinationTypesTableTableManager($_db, $_db.divinationTypes)
            .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubDivinationTypesTable _subTypeUuidTable(
          _$PersistenceDriftDatabase db) =>
      db.subDivinationTypes.createAlias($_aliasNameGenerator(
          db.divinationSubDivinationTypeMappers.subTypeUuid,
          db.subDivinationTypes.uuid));

  $$SubDivinationTypesTableProcessedTableManager get subTypeUuid {
    final $_column = $_itemColumn<String>('sub_divination_type_uuid')!;

    final manager =
        $$SubDivinationTypesTableTableManager($_db, $_db.subDivinationTypes)
            .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subTypeUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DivinationSubDivinationTypeMappersTableFilterComposer extends Composer<
    _$PersistenceDriftDatabase, $DivinationSubDivinationTypeMappersTable> {
  $$DivinationSubDivinationTypeMappersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$DivinationTypesTableFilterComposer get typeUuid {
    final $$DivinationTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableFilterComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubDivinationTypesTableFilterComposer get subTypeUuid {
    final $$SubDivinationTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subTypeUuid,
        referencedTable: $db.subDivinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubDivinationTypesTableFilterComposer(
              $db: $db,
              $table: $db.subDivinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationSubDivinationTypeMappersTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase,
        $DivinationSubDivinationTypeMappersTable> {
  $$DivinationSubDivinationTypeMappersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$DivinationTypesTableOrderingComposer get typeUuid {
    final $$DivinationTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableOrderingComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubDivinationTypesTableOrderingComposer get subTypeUuid {
    final $$SubDivinationTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subTypeUuid,
        referencedTable: $db.subDivinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubDivinationTypesTableOrderingComposer(
              $db: $db,
              $table: $db.subDivinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationSubDivinationTypeMappersTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase,
        $DivinationSubDivinationTypeMappersTable> {
  $$DivinationSubDivinationTypeMappersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DivinationTypesTableAnnotationComposer get typeUuid {
    final $$DivinationTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubDivinationTypesTableAnnotationComposer get subTypeUuid {
    final $$SubDivinationTypesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.subTypeUuid,
            referencedTable: $db.subDivinationTypes,
            getReferencedColumn: (t) => t.uuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubDivinationTypesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subDivinationTypes,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DivinationSubDivinationTypeMappersTableTableManager
    extends RootTableManager<
        _$PersistenceDriftDatabase,
        $DivinationSubDivinationTypeMappersTable,
        DivinationSubDivinationTypeMapper,
        $$DivinationSubDivinationTypeMappersTableFilterComposer,
        $$DivinationSubDivinationTypeMappersTableOrderingComposer,
        $$DivinationSubDivinationTypeMappersTableAnnotationComposer,
        $$DivinationSubDivinationTypeMappersTableCreateCompanionBuilder,
        $$DivinationSubDivinationTypeMappersTableUpdateCompanionBuilder,
        (
          DivinationSubDivinationTypeMapper,
          $$DivinationSubDivinationTypeMappersTableReferences
        ),
        DivinationSubDivinationTypeMapper,
        PrefetchHooks Function({bool typeUuid, bool subTypeUuid})> {
  $$DivinationSubDivinationTypeMappersTableTableManager(
      _$PersistenceDriftDatabase db,
      $DivinationSubDivinationTypeMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationSubDivinationTypeMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationSubDivinationTypeMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationSubDivinationTypeMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> typeUuid = const Value.absent(),
            Value<String> subTypeUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationSubDivinationTypeMappersCompanion(
            id: id,
            typeUuid: typeUuid,
            subTypeUuid: subTypeUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String typeUuid,
            required String subTypeUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationSubDivinationTypeMappersCompanion.insert(
            id: id,
            typeUuid: typeUuid,
            subTypeUuid: subTypeUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DivinationSubDivinationTypeMappersTableReferences(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({typeUuid = false, subTypeUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (typeUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.typeUuid,
                    referencedTable:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._typeUuidTable(db),
                    referencedColumn:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._typeUuidTable(db)
                            .uuid,
                  ) as T;
                }
                if (subTypeUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subTypeUuid,
                    referencedTable:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._subTypeUuidTable(db),
                    referencedColumn:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._subTypeUuidTable(db)
                            .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DivinationSubDivinationTypeMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$PersistenceDriftDatabase,
        $DivinationSubDivinationTypeMappersTable,
        DivinationSubDivinationTypeMapper,
        $$DivinationSubDivinationTypeMappersTableFilterComposer,
        $$DivinationSubDivinationTypeMappersTableOrderingComposer,
        $$DivinationSubDivinationTypeMappersTableAnnotationComposer,
        $$DivinationSubDivinationTypeMappersTableCreateCompanionBuilder,
        $$DivinationSubDivinationTypeMappersTableUpdateCompanionBuilder,
        (
          DivinationSubDivinationTypeMapper,
          $$DivinationSubDivinationTypeMappersTableReferences
        ),
        DivinationSubDivinationTypeMapper,
        PrefetchHooks Function({bool typeUuid, bool subTypeUuid})>;
typedef $$DivinationCalendarsTableCreateCompanionBuilder
    = DivinationCalendarsCompanion Function({
  required String uuid,
  required String sourceUuid,
  required String sourceType,
  Value<String?> currentTaiYuanUuid,
  Value<String?> currentDaYunUuid,
  Value<int> rowid,
});
typedef $$DivinationCalendarsTableUpdateCompanionBuilder
    = DivinationCalendarsCompanion Function({
  Value<String> uuid,
  Value<String> sourceUuid,
  Value<String> sourceType,
  Value<String?> currentTaiYuanUuid,
  Value<String?> currentDaYunUuid,
  Value<int> rowid,
});

class $$DivinationCalendarsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationCalendarsTable> {
  $$DivinationCalendarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentTaiYuanUuid => $composableBuilder(
      column: $table.currentTaiYuanUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentDaYunUuid => $composableBuilder(
      column: $table.currentDaYunUuid,
      builder: (column) => ColumnFilters(column));
}

class $$DivinationCalendarsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationCalendarsTable> {
  $$DivinationCalendarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentTaiYuanUuid => $composableBuilder(
      column: $table.currentTaiYuanUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentDaYunUuid => $composableBuilder(
      column: $table.currentDaYunUuid,
      builder: (column) => ColumnOrderings(column));
}

class $$DivinationCalendarsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationCalendarsTable> {
  $$DivinationCalendarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get currentTaiYuanUuid => $composableBuilder(
      column: $table.currentTaiYuanUuid, builder: (column) => column);

  GeneratedColumn<String> get currentDaYunUuid => $composableBuilder(
      column: $table.currentDaYunUuid, builder: (column) => column);
}

class $$DivinationCalendarsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DivinationCalendarsTable,
    DivinationCalendar,
    $$DivinationCalendarsTableFilterComposer,
    $$DivinationCalendarsTableOrderingComposer,
    $$DivinationCalendarsTableAnnotationComposer,
    $$DivinationCalendarsTableCreateCompanionBuilder,
    $$DivinationCalendarsTableUpdateCompanionBuilder,
    (
      DivinationCalendar,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationCalendarsTable,
          DivinationCalendar>
    ),
    DivinationCalendar,
    PrefetchHooks Function()> {
  $$DivinationCalendarsTableTableManager(
      _$PersistenceDriftDatabase db, $DivinationCalendarsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationCalendarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationCalendarsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationCalendarsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> sourceUuid = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String?> currentTaiYuanUuid = const Value.absent(),
            Value<String?> currentDaYunUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationCalendarsCompanion(
            uuid: uuid,
            sourceUuid: sourceUuid,
            sourceType: sourceType,
            currentTaiYuanUuid: currentTaiYuanUuid,
            currentDaYunUuid: currentDaYunUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String sourceUuid,
            required String sourceType,
            Value<String?> currentTaiYuanUuid = const Value.absent(),
            Value<String?> currentDaYunUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationCalendarsCompanion.insert(
            uuid: uuid,
            sourceUuid: sourceUuid,
            sourceType: sourceType,
            currentTaiYuanUuid: currentTaiYuanUuid,
            currentDaYunUuid: currentDaYunUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DivinationCalendarsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DivinationCalendarsTable,
    DivinationCalendar,
    $$DivinationCalendarsTableFilterComposer,
    $$DivinationCalendarsTableOrderingComposer,
    $$DivinationCalendarsTableAnnotationComposer,
    $$DivinationCalendarsTableCreateCompanionBuilder,
    $$DivinationCalendarsTableUpdateCompanionBuilder,
    (
      DivinationCalendar,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationCalendarsTable,
          DivinationCalendar>
    ),
    DivinationCalendar,
    PrefetchHooks Function()>;
typedef $$TimingDivinationsTableCreateCompanionBuilder
    = TimingDivinationsCompanion Function({
  required String uuid,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String divinationUuid,
  required DateTimeType timingType,
  required DateTime datetime,
  Value<bool> isManual,
  required JiaZi yearGanZhi,
  required JiaZi monthGanZhi,
  required JiaZi dayGanZhi,
  required JiaZi timeGanZhi,
  required int lunarMonth,
  Value<bool> isLeapMonth,
  required int lunarDay,
  required String timingInfoUuid,
  Value<Location?> location,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<String?> currentCalendarUuid,
  Value<int> rowid,
});
typedef $$TimingDivinationsTableUpdateCompanionBuilder
    = TimingDivinationsCompanion Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> divinationUuid,
  Value<DateTimeType> timingType,
  Value<DateTime> datetime,
  Value<bool> isManual,
  Value<JiaZi> yearGanZhi,
  Value<JiaZi> monthGanZhi,
  Value<JiaZi> dayGanZhi,
  Value<JiaZi> timeGanZhi,
  Value<int> lunarMonth,
  Value<bool> isLeapMonth,
  Value<int> lunarDay,
  Value<String> timingInfoUuid,
  Value<Location?> location,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<String?> currentCalendarUuid,
  Value<int> rowid,
});

class $$TimingDivinationsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $TimingDivinationsTable> {
  $$TimingDivinationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTimeType, DateTimeType, int>
      get timingType => $composableBuilder(
          column: $table.timingType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get dayGanZhi =>
      $composableBuilder(
          column: $table.dayGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Location?, Location, String> get location =>
      $composableBuilder(
          column: $table.location,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<DivinationDatetimeModel>?,
          List<DivinationDatetimeModel>, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get currentCalendarUuid => $composableBuilder(
      column: $table.currentCalendarUuid,
      builder: (column) => ColumnFilters(column));
}

class $$TimingDivinationsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $TimingDivinationsTable> {
  $$TimingDivinationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timingType => $composableBuilder(
      column: $table.timingType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get yearGanZhi => $composableBuilder(
      column: $table.yearGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthGanZhi => $composableBuilder(
      column: $table.monthGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayGanZhi => $composableBuilder(
      column: $table.dayGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeGanZhi => $composableBuilder(
      column: $table.timeGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoListJson => $composableBuilder(
      column: $table.timingInfoListJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentCalendarUuid => $composableBuilder(
      column: $table.currentCalendarUuid,
      builder: (column) => ColumnOrderings(column));
}

class $$TimingDivinationsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $TimingDivinationsTable> {
  $$TimingDivinationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTimeType, int> get timingType =>
      $composableBuilder(
          column: $table.timingType, builder: (column) => column);

  GeneratedColumn<DateTime> get datetime =>
      $composableBuilder(column: $table.datetime, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get dayGanZhi =>
      $composableBuilder(column: $table.dayGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi, builder: (column) => column);

  GeneratedColumn<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => column);

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => column);

  GeneratedColumn<int> get lunarDay =>
      $composableBuilder(column: $table.lunarDay, builder: (column) => column);

  GeneratedColumn<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Location?, String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson, builder: (column) => column);

  GeneratedColumn<String> get currentCalendarUuid => $composableBuilder(
      column: $table.currentCalendarUuid, builder: (column) => column);
}

class $$TimingDivinationsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $TimingDivinationsTable,
    TimingDivinationModel,
    $$TimingDivinationsTableFilterComposer,
    $$TimingDivinationsTableOrderingComposer,
    $$TimingDivinationsTableAnnotationComposer,
    $$TimingDivinationsTableCreateCompanionBuilder,
    $$TimingDivinationsTableUpdateCompanionBuilder,
    (
      TimingDivinationModel,
      BaseReferences<_$PersistenceDriftDatabase, $TimingDivinationsTable,
          TimingDivinationModel>
    ),
    TimingDivinationModel,
    PrefetchHooks Function()> {
  $$TimingDivinationsTableTableManager(
      _$PersistenceDriftDatabase db, $TimingDivinationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimingDivinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimingDivinationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimingDivinationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<DateTimeType> timingType = const Value.absent(),
            Value<DateTime> datetime = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<JiaZi> yearGanZhi = const Value.absent(),
            Value<JiaZi> monthGanZhi = const Value.absent(),
            Value<JiaZi> dayGanZhi = const Value.absent(),
            Value<JiaZi> timeGanZhi = const Value.absent(),
            Value<int> lunarMonth = const Value.absent(),
            Value<bool> isLeapMonth = const Value.absent(),
            Value<int> lunarDay = const Value.absent(),
            Value<String> timingInfoUuid = const Value.absent(),
            Value<Location?> location = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<String?> currentCalendarUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimingDivinationsCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            timingType: timingType,
            datetime: datetime,
            isManual: isManual,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            timingInfoUuid: timingInfoUuid,
            location: location,
            timingInfoListJson: timingInfoListJson,
            currentCalendarUuid: currentCalendarUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String divinationUuid,
            required DateTimeType timingType,
            required DateTime datetime,
            Value<bool> isManual = const Value.absent(),
            required JiaZi yearGanZhi,
            required JiaZi monthGanZhi,
            required JiaZi dayGanZhi,
            required JiaZi timeGanZhi,
            required int lunarMonth,
            Value<bool> isLeapMonth = const Value.absent(),
            required int lunarDay,
            required String timingInfoUuid,
            Value<Location?> location = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<String?> currentCalendarUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimingDivinationsCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            timingType: timingType,
            datetime: datetime,
            isManual: isManual,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            timingInfoUuid: timingInfoUuid,
            location: location,
            timingInfoListJson: timingInfoListJson,
            currentCalendarUuid: currentCalendarUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TimingDivinationsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $TimingDivinationsTable,
    TimingDivinationModel,
    $$TimingDivinationsTableFilterComposer,
    $$TimingDivinationsTableOrderingComposer,
    $$TimingDivinationsTableAnnotationComposer,
    $$TimingDivinationsTableCreateCompanionBuilder,
    $$TimingDivinationsTableUpdateCompanionBuilder,
    (
      TimingDivinationModel,
      BaseReferences<_$PersistenceDriftDatabase, $TimingDivinationsTable,
          TimingDivinationModel>
    ),
    TimingDivinationModel,
    PrefetchHooks Function()>;
typedef $$PanelsTableCreateCompanionBuilder = PanelsCompanion Function({
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String uuid,
  required EnumPanelType panelType,
  required int skillId,
  required String divinateType,
  required String divinateUuid,
  Value<int> rowid,
});
typedef $$PanelsTableUpdateCompanionBuilder = PanelsCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> uuid,
  Value<EnumPanelType> panelType,
  Value<int> skillId,
  Value<String> divinateType,
  Value<String> divinateUuid,
  Value<int> rowid,
});

class $$PanelsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelsTable> {
  $$PanelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EnumPanelType, EnumPanelType, int>
      get panelType => $composableBuilder(
          column: $table.panelType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinateType => $composableBuilder(
      column: $table.divinateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinateUuid => $composableBuilder(
      column: $table.divinateUuid, builder: (column) => ColumnFilters(column));
}

class $$PanelsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelsTable> {
  $$PanelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get panelType => $composableBuilder(
      column: $table.panelType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinateType => $composableBuilder(
      column: $table.divinateType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinateUuid => $composableBuilder(
      column: $table.divinateUuid,
      builder: (column) => ColumnOrderings(column));
}

class $$PanelsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelsTable> {
  $$PanelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnumPanelType, int> get panelType =>
      $composableBuilder(column: $table.panelType, builder: (column) => column);

  GeneratedColumn<int> get skillId =>
      $composableBuilder(column: $table.skillId, builder: (column) => column);

  GeneratedColumn<String> get divinateType => $composableBuilder(
      column: $table.divinateType, builder: (column) => column);

  GeneratedColumn<String> get divinateUuid => $composableBuilder(
      column: $table.divinateUuid, builder: (column) => column);
}

class $$PanelsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $PanelsTable,
    Panel,
    $$PanelsTableFilterComposer,
    $$PanelsTableOrderingComposer,
    $$PanelsTableAnnotationComposer,
    $$PanelsTableCreateCompanionBuilder,
    $$PanelsTableUpdateCompanionBuilder,
    (Panel, BaseReferences<_$PersistenceDriftDatabase, $PanelsTable, Panel>),
    Panel,
    PrefetchHooks Function()> {
  $$PanelsTableTableManager(_$PersistenceDriftDatabase db, $PanelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PanelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PanelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PanelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<EnumPanelType> panelType = const Value.absent(),
            Value<int> skillId = const Value.absent(),
            Value<String> divinateType = const Value.absent(),
            Value<String> divinateUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PanelsCompanion(
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            uuid: uuid,
            panelType: panelType,
            skillId: skillId,
            divinateType: divinateType,
            divinateUuid: divinateUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String uuid,
            required EnumPanelType panelType,
            required int skillId,
            required String divinateType,
            required String divinateUuid,
            Value<int> rowid = const Value.absent(),
          }) =>
              PanelsCompanion.insert(
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            uuid: uuid,
            panelType: panelType,
            skillId: skillId,
            divinateType: divinateType,
            divinateUuid: divinateUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PanelsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $PanelsTable,
    Panel,
    $$PanelsTableFilterComposer,
    $$PanelsTableOrderingComposer,
    $$PanelsTableAnnotationComposer,
    $$PanelsTableCreateCompanionBuilder,
    $$PanelsTableUpdateCompanionBuilder,
    (Panel, BaseReferences<_$PersistenceDriftDatabase, $PanelsTable, Panel>),
    Panel,
    PrefetchHooks Function()>;
typedef $$DivinationPanelMappersTableCreateCompanionBuilder
    = DivinationPanelMappersCompanion Function({
  Value<int> id,
  required String divinationUuid,
  required String panelUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
});
typedef $$DivinationPanelMappersTableUpdateCompanionBuilder
    = DivinationPanelMappersCompanion Function({
  Value<int> id,
  Value<String> divinationUuid,
  Value<String> panelUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
});

class $$DivinationPanelMappersTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationPanelMappersTable> {
  $$DivinationPanelMappersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DivinationPanelMappersTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationPanelMappersTable> {
  $$DivinationPanelMappersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DivinationPanelMappersTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationPanelMappersTable> {
  $$DivinationPanelMappersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid, builder: (column) => column);

  GeneratedColumn<String> get panelUuid =>
      $composableBuilder(column: $table.panelUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DivinationPanelMappersTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DivinationPanelMappersTable,
    DivinationPanelMapper,
    $$DivinationPanelMappersTableFilterComposer,
    $$DivinationPanelMappersTableOrderingComposer,
    $$DivinationPanelMappersTableAnnotationComposer,
    $$DivinationPanelMappersTableCreateCompanionBuilder,
    $$DivinationPanelMappersTableUpdateCompanionBuilder,
    (
      DivinationPanelMapper,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationPanelMappersTable,
          DivinationPanelMapper>
    ),
    DivinationPanelMapper,
    PrefetchHooks Function()> {
  $$DivinationPanelMappersTableTableManager(
      _$PersistenceDriftDatabase db, $DivinationPanelMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationPanelMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationPanelMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationPanelMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<String> panelUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationPanelMappersCompanion(
            id: id,
            divinationUuid: divinationUuid,
            panelUuid: panelUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String divinationUuid,
            required String panelUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationPanelMappersCompanion.insert(
            id: id,
            divinationUuid: divinationUuid,
            panelUuid: panelUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DivinationPanelMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$PersistenceDriftDatabase,
        $DivinationPanelMappersTable,
        DivinationPanelMapper,
        $$DivinationPanelMappersTableFilterComposer,
        $$DivinationPanelMappersTableOrderingComposer,
        $$DivinationPanelMappersTableAnnotationComposer,
        $$DivinationPanelMappersTableCreateCompanionBuilder,
        $$DivinationPanelMappersTableUpdateCompanionBuilder,
        (
          DivinationPanelMapper,
          BaseReferences<_$PersistenceDriftDatabase,
              $DivinationPanelMappersTable, DivinationPanelMapper>
        ),
        DivinationPanelMapper,
        PrefetchHooks Function()>;
typedef $$PanelSkillClassMappersTableCreateCompanionBuilder
    = PanelSkillClassMappersCompanion Function({
  Value<int> id,
  required String panelUuid,
  required String skillClassUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
});
typedef $$PanelSkillClassMappersTableUpdateCompanionBuilder
    = PanelSkillClassMappersCompanion Function({
  Value<int> id,
  Value<String> panelUuid,
  Value<String> skillClassUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
});

class $$PanelSkillClassMappersTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelSkillClassMappersTable> {
  $$PanelSkillClassMappersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get skillClassUuid => $composableBuilder(
      column: $table.skillClassUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PanelSkillClassMappersTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelSkillClassMappersTable> {
  $$PanelSkillClassMappersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get skillClassUuid => $composableBuilder(
      column: $table.skillClassUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PanelSkillClassMappersTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelSkillClassMappersTable> {
  $$PanelSkillClassMappersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get panelUuid =>
      $composableBuilder(column: $table.panelUuid, builder: (column) => column);

  GeneratedColumn<String> get skillClassUuid => $composableBuilder(
      column: $table.skillClassUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PanelSkillClassMappersTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $PanelSkillClassMappersTable,
    PanelSkillClassMapper,
    $$PanelSkillClassMappersTableFilterComposer,
    $$PanelSkillClassMappersTableOrderingComposer,
    $$PanelSkillClassMappersTableAnnotationComposer,
    $$PanelSkillClassMappersTableCreateCompanionBuilder,
    $$PanelSkillClassMappersTableUpdateCompanionBuilder,
    (
      PanelSkillClassMapper,
      BaseReferences<_$PersistenceDriftDatabase, $PanelSkillClassMappersTable,
          PanelSkillClassMapper>
    ),
    PanelSkillClassMapper,
    PrefetchHooks Function()> {
  $$PanelSkillClassMappersTableTableManager(
      _$PersistenceDriftDatabase db, $PanelSkillClassMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PanelSkillClassMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PanelSkillClassMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PanelSkillClassMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> panelUuid = const Value.absent(),
            Value<String> skillClassUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PanelSkillClassMappersCompanion(
            id: id,
            panelUuid: panelUuid,
            skillClassUuid: skillClassUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String panelUuid,
            required String skillClassUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PanelSkillClassMappersCompanion.insert(
            id: id,
            panelUuid: panelUuid,
            skillClassUuid: skillClassUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PanelSkillClassMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$PersistenceDriftDatabase,
        $PanelSkillClassMappersTable,
        PanelSkillClassMapper,
        $$PanelSkillClassMappersTableFilterComposer,
        $$PanelSkillClassMappersTableOrderingComposer,
        $$PanelSkillClassMappersTableAnnotationComposer,
        $$PanelSkillClassMappersTableCreateCompanionBuilder,
        $$PanelSkillClassMappersTableUpdateCompanionBuilder,
        (
          PanelSkillClassMapper,
          BaseReferences<_$PersistenceDriftDatabase,
              $PanelSkillClassMappersTable, PanelSkillClassMapper>
        ),
        PanelSkillClassMapper,
        PrefetchHooks Function()>;
typedef $$SkillsTableCreateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required bool isAvailable,
  required String name,
  required String descriptions,
});
typedef $$SkillsTableUpdateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isAvailable,
  Value<String> name,
  Value<String> descriptions,
});

class $$SkillsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $SkillsTable> {
  $$SkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptions => $composableBuilder(
      column: $table.descriptions, builder: (column) => ColumnFilters(column));
}

class $$SkillsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $SkillsTable> {
  $$SkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptions => $composableBuilder(
      column: $table.descriptions,
      builder: (column) => ColumnOrderings(column));
}

class $$SkillsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $SkillsTable> {
  $$SkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get descriptions => $composableBuilder(
      column: $table.descriptions, builder: (column) => column);
}

class $$SkillsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$PersistenceDriftDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()> {
  $$SkillsTableTableManager(_$PersistenceDriftDatabase db, $SkillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> descriptions = const Value.absent(),
          }) =>
              SkillsCompanion(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            isAvailable: isAvailable,
            name: name,
            descriptions: descriptions,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required bool isAvailable,
            required String name,
            required String descriptions,
          }) =>
              SkillsCompanion.insert(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            isAvailable: isAvailable,
            name: name,
            descriptions: descriptions,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SkillsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$PersistenceDriftDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()>;
typedef $$SkillClassesTableCreateCompanionBuilder = SkillClassesCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required int skillId,
  required String name,
  required String specification,
  required String feature,
  required bool isCustomized,
  Value<int> rowid,
});
typedef $$SkillClassesTableUpdateCompanionBuilder = SkillClassesCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<int> skillId,
  Value<String> name,
  Value<String> specification,
  Value<String> feature,
  Value<bool> isCustomized,
  Value<int> rowid,
});

class $$SkillClassesTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $SkillClassesTable> {
  $$SkillClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specification => $composableBuilder(
      column: $table.specification, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));
}

class $$SkillClassesTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $SkillClassesTable> {
  $$SkillClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specification => $composableBuilder(
      column: $table.specification,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));
}

class $$SkillClassesTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $SkillClassesTable> {
  $$SkillClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get skillId =>
      $composableBuilder(column: $table.skillId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get specification => $composableBuilder(
      column: $table.specification, builder: (column) => column);

  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);
}

class $$SkillClassesTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $SkillClassesTable,
    SkillClass,
    $$SkillClassesTableFilterComposer,
    $$SkillClassesTableOrderingComposer,
    $$SkillClassesTableAnnotationComposer,
    $$SkillClassesTableCreateCompanionBuilder,
    $$SkillClassesTableUpdateCompanionBuilder,
    (
      SkillClass,
      BaseReferences<_$PersistenceDriftDatabase, $SkillClassesTable, SkillClass>
    ),
    SkillClass,
    PrefetchHooks Function()> {
  $$SkillClassesTableTableManager(
      _$PersistenceDriftDatabase db, $SkillClassesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkillClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> skillId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> specification = const Value.absent(),
            Value<String> feature = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SkillClassesCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            skillId: skillId,
            name: name,
            specification: specification,
            feature: feature,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required int skillId,
            required String name,
            required String specification,
            required String feature,
            required bool isCustomized,
            Value<int> rowid = const Value.absent(),
          }) =>
              SkillClassesCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            skillId: skillId,
            name: name,
            specification: specification,
            feature: feature,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SkillClassesTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $SkillClassesTable,
    SkillClass,
    $$SkillClassesTableFilterComposer,
    $$SkillClassesTableOrderingComposer,
    $$SkillClassesTableAnnotationComposer,
    $$SkillClassesTableCreateCompanionBuilder,
    $$SkillClassesTableUpdateCompanionBuilder,
    (
      SkillClass,
      BaseReferences<_$PersistenceDriftDatabase, $SkillClassesTable, SkillClass>
    ),
    SkillClass,
    PrefetchHooks Function()>;
typedef $$DaYunRecordsTableCreateCompanionBuilder = DaYunRecordsCompanion
    Function({
  required String uuid,
  required String sourceUuid,
  required String jieQiType,
  required String precision,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DaYunRecordsTableUpdateCompanionBuilder = DaYunRecordsCompanion
    Function({
  Value<String> uuid,
  Value<String> sourceUuid,
  Value<String> jieQiType,
  Value<String> precision,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DaYunRecordsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DaYunRecordsTable> {
  $$DaYunRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jieQiType => $composableBuilder(
      column: $table.jieQiType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get precision => $composableBuilder(
      column: $table.precision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DaYunRecordsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DaYunRecordsTable> {
  $$DaYunRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jieQiType => $composableBuilder(
      column: $table.jieQiType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get precision => $composableBuilder(
      column: $table.precision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DaYunRecordsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DaYunRecordsTable> {
  $$DaYunRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get sourceUuid => $composableBuilder(
      column: $table.sourceUuid, builder: (column) => column);

  GeneratedColumn<String> get jieQiType =>
      $composableBuilder(column: $table.jieQiType, builder: (column) => column);

  GeneratedColumn<String> get precision =>
      $composableBuilder(column: $table.precision, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DaYunRecordsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DaYunRecordsTable,
    DaYunRecord,
    $$DaYunRecordsTableFilterComposer,
    $$DaYunRecordsTableOrderingComposer,
    $$DaYunRecordsTableAnnotationComposer,
    $$DaYunRecordsTableCreateCompanionBuilder,
    $$DaYunRecordsTableUpdateCompanionBuilder,
    (
      DaYunRecord,
      BaseReferences<_$PersistenceDriftDatabase, $DaYunRecordsTable,
          DaYunRecord>
    ),
    DaYunRecord,
    PrefetchHooks Function()> {
  $$DaYunRecordsTableTableManager(
      _$PersistenceDriftDatabase db, $DaYunRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaYunRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaYunRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaYunRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> sourceUuid = const Value.absent(),
            Value<String> jieQiType = const Value.absent(),
            Value<String> precision = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DaYunRecordsCompanion(
            uuid: uuid,
            sourceUuid: sourceUuid,
            jieQiType: jieQiType,
            precision: precision,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String sourceUuid,
            required String jieQiType,
            required String precision,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DaYunRecordsCompanion.insert(
            uuid: uuid,
            sourceUuid: sourceUuid,
            jieQiType: jieQiType,
            precision: precision,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DaYunRecordsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DaYunRecordsTable,
    DaYunRecord,
    $$DaYunRecordsTableFilterComposer,
    $$DaYunRecordsTableOrderingComposer,
    $$DaYunRecordsTableAnnotationComposer,
    $$DaYunRecordsTableCreateCompanionBuilder,
    $$DaYunRecordsTableUpdateCompanionBuilder,
    (
      DaYunRecord,
      BaseReferences<_$PersistenceDriftDatabase, $DaYunRecordsTable,
          DaYunRecord>
    ),
    DaYunRecord,
    PrefetchHooks Function()>;
typedef $$TaiYuanRecordsTableCreateCompanionBuilder = TaiYuanRecordsCompanion
    Function({
  required String uuid,
  required String calendarUuid,
  required String strategy,
  required String pillar,
  Value<String?> description,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TaiYuanRecordsTableUpdateCompanionBuilder = TaiYuanRecordsCompanion
    Function({
  Value<String> uuid,
  Value<String> calendarUuid,
  Value<String> strategy,
  Value<String> pillar,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TaiYuanRecordsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $TaiYuanRecordsTable> {
  $$TaiYuanRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get calendarUuid => $composableBuilder(
      column: $table.calendarUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strategy => $composableBuilder(
      column: $table.strategy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pillar => $composableBuilder(
      column: $table.pillar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TaiYuanRecordsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $TaiYuanRecordsTable> {
  $$TaiYuanRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get calendarUuid => $composableBuilder(
      column: $table.calendarUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strategy => $composableBuilder(
      column: $table.strategy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pillar => $composableBuilder(
      column: $table.pillar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TaiYuanRecordsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $TaiYuanRecordsTable> {
  $$TaiYuanRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get calendarUuid => $composableBuilder(
      column: $table.calendarUuid, builder: (column) => column);

  GeneratedColumn<String> get strategy =>
      $composableBuilder(column: $table.strategy, builder: (column) => column);

  GeneratedColumn<String> get pillar =>
      $composableBuilder(column: $table.pillar, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TaiYuanRecordsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $TaiYuanRecordsTable,
    TaiYuanRecord,
    $$TaiYuanRecordsTableFilterComposer,
    $$TaiYuanRecordsTableOrderingComposer,
    $$TaiYuanRecordsTableAnnotationComposer,
    $$TaiYuanRecordsTableCreateCompanionBuilder,
    $$TaiYuanRecordsTableUpdateCompanionBuilder,
    (
      TaiYuanRecord,
      BaseReferences<_$PersistenceDriftDatabase, $TaiYuanRecordsTable,
          TaiYuanRecord>
    ),
    TaiYuanRecord,
    PrefetchHooks Function()> {
  $$TaiYuanRecordsTableTableManager(
      _$PersistenceDriftDatabase db, $TaiYuanRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaiYuanRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaiYuanRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaiYuanRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> calendarUuid = const Value.absent(),
            Value<String> strategy = const Value.absent(),
            Value<String> pillar = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaiYuanRecordsCompanion(
            uuid: uuid,
            calendarUuid: calendarUuid,
            strategy: strategy,
            pillar: pillar,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String calendarUuid,
            required String strategy,
            required String pillar,
            Value<String?> description = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TaiYuanRecordsCompanion.insert(
            uuid: uuid,
            calendarUuid: calendarUuid,
            strategy: strategy,
            pillar: pillar,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaiYuanRecordsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $TaiYuanRecordsTable,
    TaiYuanRecord,
    $$TaiYuanRecordsTableFilterComposer,
    $$TaiYuanRecordsTableOrderingComposer,
    $$TaiYuanRecordsTableAnnotationComposer,
    $$TaiYuanRecordsTableCreateCompanionBuilder,
    $$TaiYuanRecordsTableUpdateCompanionBuilder,
    (
      TaiYuanRecord,
      BaseReferences<_$PersistenceDriftDatabase, $TaiYuanRecordsTable,
          TaiYuanRecord>
    ),
    TaiYuanRecord,
    PrefetchHooks Function()>;
typedef $$DivinationCasesTableCreateCompanionBuilder = DivinationCasesCompanion
    Function({
  required String uuid,
  required String title,
  required String mainQuestion,
  required String status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> finalSummary,
  Value<int> rowid,
});
typedef $$DivinationCasesTableUpdateCompanionBuilder = DivinationCasesCompanion
    Function({
  Value<String> uuid,
  Value<String> title,
  Value<String> mainQuestion,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> finalSummary,
  Value<int> rowid,
});

class $$DivinationCasesTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationCasesTable> {
  $$DivinationCasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mainQuestion => $composableBuilder(
      column: $table.mainQuestion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get finalSummary => $composableBuilder(
      column: $table.finalSummary, builder: (column) => ColumnFilters(column));
}

class $$DivinationCasesTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationCasesTable> {
  $$DivinationCasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mainQuestion => $composableBuilder(
      column: $table.mainQuestion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get finalSummary => $composableBuilder(
      column: $table.finalSummary,
      builder: (column) => ColumnOrderings(column));
}

class $$DivinationCasesTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationCasesTable> {
  $$DivinationCasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get mainQuestion => $composableBuilder(
      column: $table.mainQuestion, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get finalSummary => $composableBuilder(
      column: $table.finalSummary, builder: (column) => column);
}

class $$DivinationCasesTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DivinationCasesTable,
    DivinationCase,
    $$DivinationCasesTableFilterComposer,
    $$DivinationCasesTableOrderingComposer,
    $$DivinationCasesTableAnnotationComposer,
    $$DivinationCasesTableCreateCompanionBuilder,
    $$DivinationCasesTableUpdateCompanionBuilder,
    (
      DivinationCase,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationCasesTable,
          DivinationCase>
    ),
    DivinationCase,
    PrefetchHooks Function()> {
  $$DivinationCasesTableTableManager(
      _$PersistenceDriftDatabase db, $DivinationCasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationCasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationCasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> mainQuestion = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> finalSummary = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationCasesCompanion(
            uuid: uuid,
            title: title,
            mainQuestion: mainQuestion,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            finalSummary: finalSummary,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String title,
            required String mainQuestion,
            required String status,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> finalSummary = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationCasesCompanion.insert(
            uuid: uuid,
            title: title,
            mainQuestion: mainQuestion,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            finalSummary: finalSummary,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DivinationCasesTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DivinationCasesTable,
    DivinationCase,
    $$DivinationCasesTableFilterComposer,
    $$DivinationCasesTableOrderingComposer,
    $$DivinationCasesTableAnnotationComposer,
    $$DivinationCasesTableCreateCompanionBuilder,
    $$DivinationCasesTableUpdateCompanionBuilder,
    (
      DivinationCase,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationCasesTable,
          DivinationCase>
    ),
    DivinationCase,
    PrefetchHooks Function()>;
typedef $$DivinationWorkItemsTableCreateCompanionBuilder
    = DivinationWorkItemsCompanion Function({
  required String uuid,
  required String caseUuid,
  Value<String?> parentWorkItemUuid,
  required String title,
  required String purpose,
  required String methodGroup,
  required int order,
  required String status,
  Value<String?> summary,
  Value<String?> conclusion,
  Value<int> rowid,
});
typedef $$DivinationWorkItemsTableUpdateCompanionBuilder
    = DivinationWorkItemsCompanion Function({
  Value<String> uuid,
  Value<String> caseUuid,
  Value<String?> parentWorkItemUuid,
  Value<String> title,
  Value<String> purpose,
  Value<String> methodGroup,
  Value<int> order,
  Value<String> status,
  Value<String?> summary,
  Value<String?> conclusion,
  Value<int> rowid,
});

class $$DivinationWorkItemsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationWorkItemsTable> {
  $$DivinationWorkItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseUuid => $composableBuilder(
      column: $table.caseUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentWorkItemUuid => $composableBuilder(
      column: $table.parentWorkItemUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get methodGroup => $composableBuilder(
      column: $table.methodGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conclusion => $composableBuilder(
      column: $table.conclusion, builder: (column) => ColumnFilters(column));
}

class $$DivinationWorkItemsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationWorkItemsTable> {
  $$DivinationWorkItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseUuid => $composableBuilder(
      column: $table.caseUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentWorkItemUuid => $composableBuilder(
      column: $table.parentWorkItemUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get methodGroup => $composableBuilder(
      column: $table.methodGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conclusion => $composableBuilder(
      column: $table.conclusion, builder: (column) => ColumnOrderings(column));
}

class $$DivinationWorkItemsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $DivinationWorkItemsTable> {
  $$DivinationWorkItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get caseUuid =>
      $composableBuilder(column: $table.caseUuid, builder: (column) => column);

  GeneratedColumn<String> get parentWorkItemUuid => $composableBuilder(
      column: $table.parentWorkItemUuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get methodGroup => $composableBuilder(
      column: $table.methodGroup, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get conclusion => $composableBuilder(
      column: $table.conclusion, builder: (column) => column);
}

class $$DivinationWorkItemsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $DivinationWorkItemsTable,
    DivinationWorkItem,
    $$DivinationWorkItemsTableFilterComposer,
    $$DivinationWorkItemsTableOrderingComposer,
    $$DivinationWorkItemsTableAnnotationComposer,
    $$DivinationWorkItemsTableCreateCompanionBuilder,
    $$DivinationWorkItemsTableUpdateCompanionBuilder,
    (
      DivinationWorkItem,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationWorkItemsTable,
          DivinationWorkItem>
    ),
    DivinationWorkItem,
    PrefetchHooks Function()> {
  $$DivinationWorkItemsTableTableManager(
      _$PersistenceDriftDatabase db, $DivinationWorkItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationWorkItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationWorkItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationWorkItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> caseUuid = const Value.absent(),
            Value<String?> parentWorkItemUuid = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            Value<String> methodGroup = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<String?> conclusion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationWorkItemsCompanion(
            uuid: uuid,
            caseUuid: caseUuid,
            parentWorkItemUuid: parentWorkItemUuid,
            title: title,
            purpose: purpose,
            methodGroup: methodGroup,
            order: order,
            status: status,
            summary: summary,
            conclusion: conclusion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String caseUuid,
            Value<String?> parentWorkItemUuid = const Value.absent(),
            required String title,
            required String purpose,
            required String methodGroup,
            required int order,
            required String status,
            Value<String?> summary = const Value.absent(),
            Value<String?> conclusion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationWorkItemsCompanion.insert(
            uuid: uuid,
            caseUuid: caseUuid,
            parentWorkItemUuid: parentWorkItemUuid,
            title: title,
            purpose: purpose,
            methodGroup: methodGroup,
            order: order,
            status: status,
            summary: summary,
            conclusion: conclusion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DivinationWorkItemsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $DivinationWorkItemsTable,
    DivinationWorkItem,
    $$DivinationWorkItemsTableFilterComposer,
    $$DivinationWorkItemsTableOrderingComposer,
    $$DivinationWorkItemsTableAnnotationComposer,
    $$DivinationWorkItemsTableCreateCompanionBuilder,
    $$DivinationWorkItemsTableUpdateCompanionBuilder,
    (
      DivinationWorkItem,
      BaseReferences<_$PersistenceDriftDatabase, $DivinationWorkItemsTable,
          DivinationWorkItem>
    ),
    DivinationWorkItem,
    PrefetchHooks Function()>;
typedef $$CaseParticipantsTableCreateCompanionBuilder
    = CaseParticipantsCompanion Function({
  required String uuid,
  required String caseUuid,
  Value<String?> recordUuid,
  required String name,
  required String role,
  Value<String?> seekerUuid,
  Value<int> rowid,
});
typedef $$CaseParticipantsTableUpdateCompanionBuilder
    = CaseParticipantsCompanion Function({
  Value<String> uuid,
  Value<String> caseUuid,
  Value<String?> recordUuid,
  Value<String> name,
  Value<String> role,
  Value<String?> seekerUuid,
  Value<int> rowid,
});

class $$CaseParticipantsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $CaseParticipantsTable> {
  $$CaseParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseUuid => $composableBuilder(
      column: $table.caseUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordUuid => $composableBuilder(
      column: $table.recordUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => ColumnFilters(column));
}

class $$CaseParticipantsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $CaseParticipantsTable> {
  $$CaseParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseUuid => $composableBuilder(
      column: $table.caseUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordUuid => $composableBuilder(
      column: $table.recordUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => ColumnOrderings(column));
}

class $$CaseParticipantsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $CaseParticipantsTable> {
  $$CaseParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get caseUuid =>
      $composableBuilder(column: $table.caseUuid, builder: (column) => column);

  GeneratedColumn<String> get recordUuid => $composableBuilder(
      column: $table.recordUuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => column);
}

class $$CaseParticipantsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $CaseParticipantsTable,
    CaseParticipant,
    $$CaseParticipantsTableFilterComposer,
    $$CaseParticipantsTableOrderingComposer,
    $$CaseParticipantsTableAnnotationComposer,
    $$CaseParticipantsTableCreateCompanionBuilder,
    $$CaseParticipantsTableUpdateCompanionBuilder,
    (
      CaseParticipant,
      BaseReferences<_$PersistenceDriftDatabase, $CaseParticipantsTable,
          CaseParticipant>
    ),
    CaseParticipant,
    PrefetchHooks Function()> {
  $$CaseParticipantsTableTableManager(
      _$PersistenceDriftDatabase db, $CaseParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> caseUuid = const Value.absent(),
            Value<String?> recordUuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> seekerUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaseParticipantsCompanion(
            uuid: uuid,
            caseUuid: caseUuid,
            recordUuid: recordUuid,
            name: name,
            role: role,
            seekerUuid: seekerUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String caseUuid,
            Value<String?> recordUuid = const Value.absent(),
            required String name,
            required String role,
            Value<String?> seekerUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaseParticipantsCompanion.insert(
            uuid: uuid,
            caseUuid: caseUuid,
            recordUuid: recordUuid,
            name: name,
            role: role,
            seekerUuid: seekerUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CaseParticipantsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $CaseParticipantsTable,
    CaseParticipant,
    $$CaseParticipantsTableFilterComposer,
    $$CaseParticipantsTableOrderingComposer,
    $$CaseParticipantsTableAnnotationComposer,
    $$CaseParticipantsTableCreateCompanionBuilder,
    $$CaseParticipantsTableUpdateCompanionBuilder,
    (
      CaseParticipant,
      BaseReferences<_$PersistenceDriftDatabase, $CaseParticipantsTable,
          CaseParticipant>
    ),
    CaseParticipant,
    PrefetchHooks Function()>;
typedef $$PanelRefsTableCreateCompanionBuilder = PanelRefsCompanion Function({
  required String uuid,
  required String module,
  required String panelUuid,
  required String panelType,
  required String role,
  Value<String?> title,
  Value<int> rowid,
});
typedef $$PanelRefsTableUpdateCompanionBuilder = PanelRefsCompanion Function({
  Value<String> uuid,
  Value<String> module,
  Value<String> panelUuid,
  Value<String> panelType,
  Value<String> role,
  Value<String?> title,
  Value<int> rowid,
});

class $$PanelRefsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelRefsTable> {
  $$PanelRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get module => $composableBuilder(
      column: $table.module, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelType => $composableBuilder(
      column: $table.panelType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));
}

class $$PanelRefsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelRefsTable> {
  $$PanelRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get module => $composableBuilder(
      column: $table.module, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelType => $composableBuilder(
      column: $table.panelType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));
}

class $$PanelRefsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $PanelRefsTable> {
  $$PanelRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get panelUuid =>
      $composableBuilder(column: $table.panelUuid, builder: (column) => column);

  GeneratedColumn<String> get panelType =>
      $composableBuilder(column: $table.panelType, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);
}

class $$PanelRefsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $PanelRefsTable,
    PanelRef,
    $$PanelRefsTableFilterComposer,
    $$PanelRefsTableOrderingComposer,
    $$PanelRefsTableAnnotationComposer,
    $$PanelRefsTableCreateCompanionBuilder,
    $$PanelRefsTableUpdateCompanionBuilder,
    (
      PanelRef,
      BaseReferences<_$PersistenceDriftDatabase, $PanelRefsTable, PanelRef>
    ),
    PanelRef,
    PrefetchHooks Function()> {
  $$PanelRefsTableTableManager(
      _$PersistenceDriftDatabase db, $PanelRefsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PanelRefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PanelRefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PanelRefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> module = const Value.absent(),
            Value<String> panelUuid = const Value.absent(),
            Value<String> panelType = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PanelRefsCompanion(
            uuid: uuid,
            module: module,
            panelUuid: panelUuid,
            panelType: panelType,
            role: role,
            title: title,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String module,
            required String panelUuid,
            required String panelType,
            required String role,
            Value<String?> title = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PanelRefsCompanion.insert(
            uuid: uuid,
            module: module,
            panelUuid: panelUuid,
            panelType: panelType,
            role: role,
            title: title,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PanelRefsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $PanelRefsTable,
    PanelRef,
    $$PanelRefsTableFilterComposer,
    $$PanelRefsTableOrderingComposer,
    $$PanelRefsTableAnnotationComposer,
    $$PanelRefsTableCreateCompanionBuilder,
    $$PanelRefsTableUpdateCompanionBuilder,
    (
      PanelRef,
      BaseReferences<_$PersistenceDriftDatabase, $PanelRefsTable, PanelRef>
    ),
    PanelRef,
    PrefetchHooks Function()>;
typedef $$WorkItemPanelRefsTableCreateCompanionBuilder
    = WorkItemPanelRefsCompanion Function({
  required String uuid,
  required String workItemUuid,
  required String panelRefUuid,
  required String role,
  required int order,
  Value<int> rowid,
});
typedef $$WorkItemPanelRefsTableUpdateCompanionBuilder
    = WorkItemPanelRefsCompanion Function({
  Value<String> uuid,
  Value<String> workItemUuid,
  Value<String> panelRefUuid,
  Value<String> role,
  Value<int> order,
  Value<int> rowid,
});

class $$WorkItemPanelRefsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $WorkItemPanelRefsTable> {
  $$WorkItemPanelRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workItemUuid => $composableBuilder(
      column: $table.workItemUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelRefUuid => $composableBuilder(
      column: $table.panelRefUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));
}

class $$WorkItemPanelRefsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $WorkItemPanelRefsTable> {
  $$WorkItemPanelRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workItemUuid => $composableBuilder(
      column: $table.workItemUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelRefUuid => $composableBuilder(
      column: $table.panelRefUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));
}

class $$WorkItemPanelRefsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $WorkItemPanelRefsTable> {
  $$WorkItemPanelRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get workItemUuid => $composableBuilder(
      column: $table.workItemUuid, builder: (column) => column);

  GeneratedColumn<String> get panelRefUuid => $composableBuilder(
      column: $table.panelRefUuid, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$WorkItemPanelRefsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $WorkItemPanelRefsTable,
    WorkItemPanelRef,
    $$WorkItemPanelRefsTableFilterComposer,
    $$WorkItemPanelRefsTableOrderingComposer,
    $$WorkItemPanelRefsTableAnnotationComposer,
    $$WorkItemPanelRefsTableCreateCompanionBuilder,
    $$WorkItemPanelRefsTableUpdateCompanionBuilder,
    (
      WorkItemPanelRef,
      BaseReferences<_$PersistenceDriftDatabase, $WorkItemPanelRefsTable,
          WorkItemPanelRef>
    ),
    WorkItemPanelRef,
    PrefetchHooks Function()> {
  $$WorkItemPanelRefsTableTableManager(
      _$PersistenceDriftDatabase db, $WorkItemPanelRefsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkItemPanelRefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkItemPanelRefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkItemPanelRefsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> workItemUuid = const Value.absent(),
            Value<String> panelRefUuid = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkItemPanelRefsCompanion(
            uuid: uuid,
            workItemUuid: workItemUuid,
            panelRefUuid: panelRefUuid,
            role: role,
            order: order,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String workItemUuid,
            required String panelRefUuid,
            required String role,
            required int order,
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkItemPanelRefsCompanion.insert(
            uuid: uuid,
            workItemUuid: workItemUuid,
            panelRefUuid: panelRefUuid,
            role: role,
            order: order,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkItemPanelRefsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $WorkItemPanelRefsTable,
    WorkItemPanelRef,
    $$WorkItemPanelRefsTableFilterComposer,
    $$WorkItemPanelRefsTableOrderingComposer,
    $$WorkItemPanelRefsTableAnnotationComposer,
    $$WorkItemPanelRefsTableCreateCompanionBuilder,
    $$WorkItemPanelRefsTableUpdateCompanionBuilder,
    (
      WorkItemPanelRef,
      BaseReferences<_$PersistenceDriftDatabase, $WorkItemPanelRefsTable,
          WorkItemPanelRef>
    ),
    WorkItemPanelRef,
    PrefetchHooks Function()>;

class $PersistenceDriftDatabaseManager {
  final _$PersistenceDriftDatabase _db;
  $PersistenceDriftDatabaseManager(this._db);
  $$OutboxRecordsTableTableManager get outboxRecords =>
      $$OutboxRecordsTableTableManager(_db, _db.outboxRecords);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db, _db.seekers);
  $$DivinationsTableTableManager get divinations =>
      $$DivinationsTableTableManager(_db, _db.divinations);
  $$SeekerDivinationMappersTableTableManager get seekerDivinationMappers =>
      $$SeekerDivinationMappersTableTableManager(
          _db, _db.seekerDivinationMappers);
  $$CombinedDivinationsTableTableManager get combinedDivinations =>
      $$CombinedDivinationsTableTableManager(_db, _db.combinedDivinations);
  $$DecisionLinksTableTableManager get decisionLinks =>
      $$DecisionLinksTableTableManager(_db, _db.decisionLinks);
  $$DivinationTagsTableTableManager get divinationTags =>
      $$DivinationTagsTableTableManager(_db, _db.divinationTags);
  $$DivinationTypesTableTableManager get divinationTypes =>
      $$DivinationTypesTableTableManager(_db, _db.divinationTypes);
  $$SubDivinationTypesTableTableManager get subDivinationTypes =>
      $$SubDivinationTypesTableTableManager(_db, _db.subDivinationTypes);
  $$DivinationSubDivinationTypeMappersTableTableManager
      get divinationSubDivinationTypeMappers =>
          $$DivinationSubDivinationTypeMappersTableTableManager(
              _db, _db.divinationSubDivinationTypeMappers);
  $$DivinationCalendarsTableTableManager get divinationCalendars =>
      $$DivinationCalendarsTableTableManager(_db, _db.divinationCalendars);
  $$TimingDivinationsTableTableManager get timingDivinations =>
      $$TimingDivinationsTableTableManager(_db, _db.timingDivinations);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db, _db.panels);
  $$DivinationPanelMappersTableTableManager get divinationPanelMappers =>
      $$DivinationPanelMappersTableTableManager(
          _db, _db.divinationPanelMappers);
  $$PanelSkillClassMappersTableTableManager get panelSkillClassMappers =>
      $$PanelSkillClassMappersTableTableManager(
          _db, _db.panelSkillClassMappers);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db, _db.skills);
  $$SkillClassesTableTableManager get skillClasses =>
      $$SkillClassesTableTableManager(_db, _db.skillClasses);
  $$DaYunRecordsTableTableManager get daYunRecords =>
      $$DaYunRecordsTableTableManager(_db, _db.daYunRecords);
  $$TaiYuanRecordsTableTableManager get taiYuanRecords =>
      $$TaiYuanRecordsTableTableManager(_db, _db.taiYuanRecords);
  $$DivinationCasesTableTableManager get divinationCases =>
      $$DivinationCasesTableTableManager(_db, _db.divinationCases);
  $$DivinationWorkItemsTableTableManager get divinationWorkItems =>
      $$DivinationWorkItemsTableTableManager(_db, _db.divinationWorkItems);
  $$CaseParticipantsTableTableManager get caseParticipants =>
      $$CaseParticipantsTableTableManager(_db, _db.caseParticipants);
  $$PanelRefsTableTableManager get panelRefs =>
      $$PanelRefsTableTableManager(_db, _db.panelRefs);
  $$WorkItemPanelRefsTableTableManager get workItemPanelRefs =>
      $$WorkItemPanelRefsTableTableManager(_db, _db.workItemPanelRefs);
}
