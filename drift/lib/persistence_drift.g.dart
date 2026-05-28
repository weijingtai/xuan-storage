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
        divinationSubDivinationTypeMappers
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
}
