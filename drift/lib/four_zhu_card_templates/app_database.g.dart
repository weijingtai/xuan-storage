// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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

class $LayoutTemplatesTable extends LayoutTemplates
    with TableInfo<$LayoutTemplatesTable, LayoutTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LayoutTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<String> collectionId =
      GeneratedColumn<String>('collection_id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _templateJsonMeta =
      const VerificationMeta('templateJson');
  @override
  late final GeneratedColumn<String> templateJson = GeneratedColumn<String>(
      'template_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        collectionId,
        name,
        description,
        templateJson,
        version,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_layout_templates';
  @override
  VerificationContext validateIntegrity(Insertable<LayoutTemplateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
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
    }
    if (data.containsKey('template_json')) {
      context.handle(
          _templateJsonMeta,
          templateJson.isAcceptableOrUnknown(
              data['template_json']!, _templateJsonMeta));
    } else if (isInserting) {
      context.missing(_templateJsonMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LayoutTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LayoutTemplateRow(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      templateJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_json'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $LayoutTemplatesTable createAlias(String alias) {
    return $LayoutTemplatesTable(attachedDatabase, alias);
  }
}

class LayoutTemplateRow extends DataClass
    implements Insertable<LayoutTemplateRow> {
  final String uuid;
  final String collectionId;
  final String name;
  final String? description;
  final String templateJson;
  final int version;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LayoutTemplateRow(
      {required this.uuid,
      required this.collectionId,
      required this.name,
      this.description,
      required this.templateJson,
      required this.version,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['collection_id'] = Variable<String>(collectionId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['template_json'] = Variable<String>(templateJson);
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LayoutTemplatesCompanion toCompanion(bool nullToAbsent) {
    return LayoutTemplatesCompanion(
      uuid: Value(uuid),
      collectionId: Value(collectionId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      templateJson: Value(templateJson),
      version: Value(version),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LayoutTemplateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LayoutTemplateRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      templateJson: serializer.fromJson<String>(json['templateJson']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'collectionId': serializer.toJson<String>(collectionId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'templateJson': serializer.toJson<String>(templateJson),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LayoutTemplateRow copyWith(
          {String? uuid,
          String? collectionId,
          String? name,
          Value<String?> description = const Value.absent(),
          String? templateJson,
          int? version,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      LayoutTemplateRow(
        uuid: uuid ?? this.uuid,
        collectionId: collectionId ?? this.collectionId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        templateJson: templateJson ?? this.templateJson,
        version: version ?? this.version,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  LayoutTemplateRow copyWithCompanion(LayoutTemplatesCompanion data) {
    return LayoutTemplateRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      templateJson: data.templateJson.present
          ? data.templateJson.value
          : this.templateJson,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LayoutTemplateRow(')
          ..write('uuid: $uuid, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('templateJson: $templateJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, collectionId, name, description,
      templateJson, version, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayoutTemplateRow &&
          other.uuid == this.uuid &&
          other.collectionId == this.collectionId &&
          other.name == this.name &&
          other.description == this.description &&
          other.templateJson == this.templateJson &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LayoutTemplatesCompanion extends UpdateCompanion<LayoutTemplateRow> {
  final Value<String> uuid;
  final Value<String> collectionId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> templateJson;
  final Value<int> version;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LayoutTemplatesCompanion({
    this.uuid = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.templateJson = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LayoutTemplatesCompanion.insert({
    required String uuid,
    required String collectionId,
    required String name,
    this.description = const Value.absent(),
    required String templateJson,
    required int version,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        collectionId = Value(collectionId),
        name = Value(name),
        templateJson = Value(templateJson),
        version = Value(version),
        updatedAt = Value(updatedAt);
  static Insertable<LayoutTemplateRow> custom({
    Expression<String>? uuid,
    Expression<String>? collectionId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? templateJson,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (collectionId != null) 'collection_id': collectionId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (templateJson != null) 'template_json': templateJson,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LayoutTemplatesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? collectionId,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? templateJson,
      Value<int>? version,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return LayoutTemplatesCompanion(
      uuid: uuid ?? this.uuid,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      description: description ?? this.description,
      templateJson: templateJson ?? this.templateJson,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (templateJson.present) {
      map['template_json'] = Variable<String>(templateJson.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LayoutTemplatesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('templateJson: $templateJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTemplateMetasTable extends CardTemplateMetas
    with TableInfo<$CardTemplateMetasTable, CardTemplateMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTemplateMetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _templateUuidMeta =
      const VerificationMeta('templateUuid');
  @override
  late final GeneratedColumn<String> templateUuid = GeneratedColumn<String>(
      'template_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modifiedAtMeta =
      const VerificationMeta('modifiedAt');
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
      'modified_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _authorUuidMeta =
      const VerificationMeta('authorUuid');
  @override
  late final GeneratedColumn<String> authorUuid = GeneratedColumn<String>(
      'author_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createFromCardUuidMeta =
      const VerificationMeta('createFromCardUuid');
  @override
  late final GeneratedColumn<String> createFromCardUuid =
      GeneratedColumn<String>('create_from_card_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        templateUuid,
        createdAt,
        modifiedAt,
        deletedAt,
        authorUuid,
        createFromCardUuid,
        isCustomized
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_card_template_meta';
  @override
  VerificationContext validateIntegrity(Insertable<CardTemplateMeta> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_uuid')) {
      context.handle(
          _templateUuidMeta,
          templateUuid.isAcceptableOrUnknown(
              data['template_uuid']!, _templateUuidMeta));
    } else if (isInserting) {
      context.missing(_templateUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
          _modifiedAtMeta,
          modifiedAt.isAcceptableOrUnknown(
              data['modified_at']!, _modifiedAtMeta));
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('author_uuid')) {
      context.handle(
          _authorUuidMeta,
          authorUuid.isAcceptableOrUnknown(
              data['author_uuid']!, _authorUuidMeta));
    }
    if (data.containsKey('create_from_card_uuid')) {
      context.handle(
          _createFromCardUuidMeta,
          createFromCardUuid.isAcceptableOrUnknown(
              data['create_from_card_uuid']!, _createFromCardUuidMeta));
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {templateUuid};
  @override
  CardTemplateMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTemplateMeta(
      templateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      modifiedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modified_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      authorUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_uuid']),
      createFromCardUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}create_from_card_uuid']),
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized']),
    );
  }

  @override
  $CardTemplateMetasTable createAlias(String alias) {
    return $CardTemplateMetasTable(attachedDatabase, alias);
  }
}

class CardTemplateMeta extends DataClass
    implements Insertable<CardTemplateMeta> {
  final String templateUuid;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  final String? authorUuid;
  final String? createFromCardUuid;
  final bool? isCustomized;
  const CardTemplateMeta(
      {required this.templateUuid,
      required this.createdAt,
      required this.modifiedAt,
      this.deletedAt,
      this.authorUuid,
      this.createFromCardUuid,
      this.isCustomized});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['template_uuid'] = Variable<String>(templateUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || authorUuid != null) {
      map['author_uuid'] = Variable<String>(authorUuid);
    }
    if (!nullToAbsent || createFromCardUuid != null) {
      map['create_from_card_uuid'] = Variable<String>(createFromCardUuid);
    }
    if (!nullToAbsent || isCustomized != null) {
      map['is_customized'] = Variable<bool>(isCustomized);
    }
    return map;
  }

  CardTemplateMetasCompanion toCompanion(bool nullToAbsent) {
    return CardTemplateMetasCompanion(
      templateUuid: Value(templateUuid),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      authorUuid: authorUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(authorUuid),
      createFromCardUuid: createFromCardUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(createFromCardUuid),
      isCustomized: isCustomized == null && nullToAbsent
          ? const Value.absent()
          : Value(isCustomized),
    );
  }

  factory CardTemplateMeta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTemplateMeta(
      templateUuid: serializer.fromJson<String>(json['templateUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      authorUuid: serializer.fromJson<String?>(json['authorUuid']),
      createFromCardUuid:
          serializer.fromJson<String?>(json['createFromCardUuid']),
      isCustomized: serializer.fromJson<bool?>(json['isCustomized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateUuid': serializer.toJson<String>(templateUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'authorUuid': serializer.toJson<String?>(authorUuid),
      'createFromCardUuid': serializer.toJson<String?>(createFromCardUuid),
      'isCustomized': serializer.toJson<bool?>(isCustomized),
    };
  }

  CardTemplateMeta copyWith(
          {String? templateUuid,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> authorUuid = const Value.absent(),
          Value<String?> createFromCardUuid = const Value.absent(),
          Value<bool?> isCustomized = const Value.absent()}) =>
      CardTemplateMeta(
        templateUuid: templateUuid ?? this.templateUuid,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        authorUuid: authorUuid.present ? authorUuid.value : this.authorUuid,
        createFromCardUuid: createFromCardUuid.present
            ? createFromCardUuid.value
            : this.createFromCardUuid,
        isCustomized:
            isCustomized.present ? isCustomized.value : this.isCustomized,
      );
  CardTemplateMeta copyWithCompanion(CardTemplateMetasCompanion data) {
    return CardTemplateMeta(
      templateUuid: data.templateUuid.present
          ? data.templateUuid.value
          : this.templateUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      authorUuid:
          data.authorUuid.present ? data.authorUuid.value : this.authorUuid,
      createFromCardUuid: data.createFromCardUuid.present
          ? data.createFromCardUuid.value
          : this.createFromCardUuid,
      isCustomized: data.isCustomized.present
          ? data.isCustomized.value
          : this.isCustomized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateMeta(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('authorUuid: $authorUuid, ')
          ..write('createFromCardUuid: $createFromCardUuid, ')
          ..write('isCustomized: $isCustomized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(templateUuid, createdAt, modifiedAt,
      deletedAt, authorUuid, createFromCardUuid, isCustomized);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTemplateMeta &&
          other.templateUuid == this.templateUuid &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deletedAt == this.deletedAt &&
          other.authorUuid == this.authorUuid &&
          other.createFromCardUuid == this.createFromCardUuid &&
          other.isCustomized == this.isCustomized);
}

class CardTemplateMetasCompanion extends UpdateCompanion<CardTemplateMeta> {
  final Value<String> templateUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> authorUuid;
  final Value<String?> createFromCardUuid;
  final Value<bool?> isCustomized;
  final Value<int> rowid;
  const CardTemplateMetasCompanion({
    this.templateUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.authorUuid = const Value.absent(),
    this.createFromCardUuid = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTemplateMetasCompanion.insert({
    required String templateUuid,
    required DateTime createdAt,
    required DateTime modifiedAt,
    this.deletedAt = const Value.absent(),
    this.authorUuid = const Value.absent(),
    this.createFromCardUuid = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : templateUuid = Value(templateUuid),
        createdAt = Value(createdAt),
        modifiedAt = Value(modifiedAt);
  static Insertable<CardTemplateMeta> custom({
    Expression<String>? templateUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? authorUuid,
    Expression<String>? createFromCardUuid,
    Expression<bool>? isCustomized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (templateUuid != null) 'template_uuid': templateUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (authorUuid != null) 'author_uuid': authorUuid,
      if (createFromCardUuid != null)
        'create_from_card_uuid': createFromCardUuid,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTemplateMetasCompanion copyWith(
      {Value<String>? templateUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? authorUuid,
      Value<String?>? createFromCardUuid,
      Value<bool?>? isCustomized,
      Value<int>? rowid}) {
    return CardTemplateMetasCompanion(
      templateUuid: templateUuid ?? this.templateUuid,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      authorUuid: authorUuid ?? this.authorUuid,
      createFromCardUuid: createFromCardUuid ?? this.createFromCardUuid,
      isCustomized: isCustomized ?? this.isCustomized,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (templateUuid.present) {
      map['template_uuid'] = Variable<String>(templateUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (authorUuid.present) {
      map['author_uuid'] = Variable<String>(authorUuid.value);
    }
    if (createFromCardUuid.present) {
      map['create_from_card_uuid'] = Variable<String>(createFromCardUuid.value);
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
    return (StringBuffer('CardTemplateMetasCompanion(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('authorUuid: $authorUuid, ')
          ..write('createFromCardUuid: $createFromCardUuid, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTemplateSettingsTable extends CardTemplateSettings
    with TableInfo<$CardTemplateSettingsTable, CardTemplateSettingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTemplateSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _templateUuidMeta =
      const VerificationMeta('templateUuid');
  @override
  late final GeneratedColumn<String> templateUuid = GeneratedColumn<String>(
      'template_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modifiedAtMeta =
      const VerificationMeta('modifiedAt');
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
      'modified_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _settingJsonMeta =
      const VerificationMeta('settingJson');
  @override
  late final GeneratedColumn<String> settingJson = GeneratedColumn<String>(
      'setting_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [templateUuid, createdAt, modifiedAt, deletedAt, settingJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_card_template_setting';
  @override
  VerificationContext validateIntegrity(
      Insertable<CardTemplateSettingRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_uuid')) {
      context.handle(
          _templateUuidMeta,
          templateUuid.isAcceptableOrUnknown(
              data['template_uuid']!, _templateUuidMeta));
    } else if (isInserting) {
      context.missing(_templateUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
          _modifiedAtMeta,
          modifiedAt.isAcceptableOrUnknown(
              data['modified_at']!, _modifiedAtMeta));
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('setting_json')) {
      context.handle(
          _settingJsonMeta,
          settingJson.isAcceptableOrUnknown(
              data['setting_json']!, _settingJsonMeta));
    } else if (isInserting) {
      context.missing(_settingJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {templateUuid};
  @override
  CardTemplateSettingRecord map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTemplateSettingRecord(
      templateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      modifiedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modified_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      settingJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_json'])!,
    );
  }

  @override
  $CardTemplateSettingsTable createAlias(String alias) {
    return $CardTemplateSettingsTable(attachedDatabase, alias);
  }
}

class CardTemplateSettingRecord extends DataClass
    implements Insertable<CardTemplateSettingRecord> {
  final String templateUuid;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  final String settingJson;
  const CardTemplateSettingRecord(
      {required this.templateUuid,
      required this.createdAt,
      required this.modifiedAt,
      this.deletedAt,
      required this.settingJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['template_uuid'] = Variable<String>(templateUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['setting_json'] = Variable<String>(settingJson);
    return map;
  }

  CardTemplateSettingsCompanion toCompanion(bool nullToAbsent) {
    return CardTemplateSettingsCompanion(
      templateUuid: Value(templateUuid),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      settingJson: Value(settingJson),
    );
  }

  factory CardTemplateSettingRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTemplateSettingRecord(
      templateUuid: serializer.fromJson<String>(json['templateUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      settingJson: serializer.fromJson<String>(json['settingJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateUuid': serializer.toJson<String>(templateUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'settingJson': serializer.toJson<String>(settingJson),
    };
  }

  CardTemplateSettingRecord copyWith(
          {String? templateUuid,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? settingJson}) =>
      CardTemplateSettingRecord(
        templateUuid: templateUuid ?? this.templateUuid,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        settingJson: settingJson ?? this.settingJson,
      );
  CardTemplateSettingRecord copyWithCompanion(
      CardTemplateSettingsCompanion data) {
    return CardTemplateSettingRecord(
      templateUuid: data.templateUuid.present
          ? data.templateUuid.value
          : this.templateUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      settingJson:
          data.settingJson.present ? data.settingJson.value : this.settingJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSettingRecord(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('settingJson: $settingJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(templateUuid, createdAt, modifiedAt, deletedAt, settingJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTemplateSettingRecord &&
          other.templateUuid == this.templateUuid &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deletedAt == this.deletedAt &&
          other.settingJson == this.settingJson);
}

class CardTemplateSettingsCompanion
    extends UpdateCompanion<CardTemplateSettingRecord> {
  final Value<String> templateUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> settingJson;
  final Value<int> rowid;
  const CardTemplateSettingsCompanion({
    this.templateUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.settingJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTemplateSettingsCompanion.insert({
    required String templateUuid,
    required DateTime createdAt,
    required DateTime modifiedAt,
    this.deletedAt = const Value.absent(),
    required String settingJson,
    this.rowid = const Value.absent(),
  })  : templateUuid = Value(templateUuid),
        createdAt = Value(createdAt),
        modifiedAt = Value(modifiedAt),
        settingJson = Value(settingJson);
  static Insertable<CardTemplateSettingRecord> custom({
    Expression<String>? templateUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? settingJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (templateUuid != null) 'template_uuid': templateUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (settingJson != null) 'setting_json': settingJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTemplateSettingsCompanion copyWith(
      {Value<String>? templateUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? settingJson,
      Value<int>? rowid}) {
    return CardTemplateSettingsCompanion(
      templateUuid: templateUuid ?? this.templateUuid,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      settingJson: settingJson ?? this.settingJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (templateUuid.present) {
      map['template_uuid'] = Variable<String>(templateUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (settingJson.present) {
      map['setting_json'] = Variable<String>(settingJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSettingsCompanion(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('settingJson: $settingJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTemplateSkillUsagesTable extends CardTemplateSkillUsages
    with TableInfo<$CardTemplateSkillUsagesTable, CardTemplateSkillUsage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTemplateSkillUsagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _queryUuidMeta =
      const VerificationMeta('queryUuid');
  @override
  late final GeneratedColumn<String> queryUuid = GeneratedColumn<String>(
      'query_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateUuidMeta =
      const VerificationMeta('templateUuid');
  @override
  late final GeneratedColumn<String> templateUuid = GeneratedColumn<String>(
      'template_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<int> skillId = GeneratedColumn<int>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<String> usedAt = GeneratedColumn<String>(
      'used_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        queryUuid,
        templateUuid,
        skillId,
        usedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_card_template_skill_usage';
  @override
  VerificationContext validateIntegrity(
      Insertable<CardTemplateSkillUsage> instance,
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
    if (data.containsKey('query_uuid')) {
      context.handle(_queryUuidMeta,
          queryUuid.isAcceptableOrUnknown(data['query_uuid']!, _queryUuidMeta));
    } else if (isInserting) {
      context.missing(_queryUuidMeta);
    }
    if (data.containsKey('template_uuid')) {
      context.handle(
          _templateUuidMeta,
          templateUuid.isAcceptableOrUnknown(
              data['template_uuid']!, _templateUuidMeta));
    } else if (isInserting) {
      context.missing(_templateUuidMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(_usedAtMeta,
          usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta));
    } else if (isInserting) {
      context.missing(_usedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardTemplateSkillUsage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTemplateSkillUsage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      queryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query_uuid'])!,
      templateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_uuid'])!,
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_id'])!,
      usedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}used_at'])!,
    );
  }

  @override
  $CardTemplateSkillUsagesTable createAlias(String alias) {
    return $CardTemplateSkillUsagesTable(attachedDatabase, alias);
  }
}

class CardTemplateSkillUsage extends DataClass
    implements Insertable<CardTemplateSkillUsage> {
  final int id;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String queryUuid;
  final String templateUuid;
  final int skillId;
  final String usedAt;
  const CardTemplateSkillUsage(
      {required this.id,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.queryUuid,
      required this.templateUuid,
      required this.skillId,
      required this.usedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['query_uuid'] = Variable<String>(queryUuid);
    map['template_uuid'] = Variable<String>(templateUuid);
    map['skill_id'] = Variable<int>(skillId);
    map['used_at'] = Variable<String>(usedAt);
    return map;
  }

  CardTemplateSkillUsagesCompanion toCompanion(bool nullToAbsent) {
    return CardTemplateSkillUsagesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      queryUuid: Value(queryUuid),
      templateUuid: Value(templateUuid),
      skillId: Value(skillId),
      usedAt: Value(usedAt),
    );
  }

  factory CardTemplateSkillUsage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTemplateSkillUsage(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      queryUuid: serializer.fromJson<String>(json['queryUuid']),
      templateUuid: serializer.fromJson<String>(json['templateUuid']),
      skillId: serializer.fromJson<int>(json['skillId']),
      usedAt: serializer.fromJson<String>(json['usedAt']),
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
      'queryUuid': serializer.toJson<String>(queryUuid),
      'templateUuid': serializer.toJson<String>(templateUuid),
      'skillId': serializer.toJson<int>(skillId),
      'usedAt': serializer.toJson<String>(usedAt),
    };
  }

  CardTemplateSkillUsage copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? queryUuid,
          String? templateUuid,
          int? skillId,
          String? usedAt}) =>
      CardTemplateSkillUsage(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        queryUuid: queryUuid ?? this.queryUuid,
        templateUuid: templateUuid ?? this.templateUuid,
        skillId: skillId ?? this.skillId,
        usedAt: usedAt ?? this.usedAt,
      );
  CardTemplateSkillUsage copyWithCompanion(
      CardTemplateSkillUsagesCompanion data) {
    return CardTemplateSkillUsage(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      queryUuid: data.queryUuid.present ? data.queryUuid.value : this.queryUuid,
      templateUuid: data.templateUuid.present
          ? data.templateUuid.value
          : this.templateUuid,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSkillUsage(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('templateUuid: $templateUuid, ')
          ..write('skillId: $skillId, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, lastUpdatedAt, deletedAt,
      queryUuid, templateUuid, skillId, usedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTemplateSkillUsage &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.queryUuid == this.queryUuid &&
          other.templateUuid == this.templateUuid &&
          other.skillId == this.skillId &&
          other.usedAt == this.usedAt);
}

class CardTemplateSkillUsagesCompanion
    extends UpdateCompanion<CardTemplateSkillUsage> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> queryUuid;
  final Value<String> templateUuid;
  final Value<int> skillId;
  final Value<String> usedAt;
  const CardTemplateSkillUsagesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.queryUuid = const Value.absent(),
    this.templateUuid = const Value.absent(),
    this.skillId = const Value.absent(),
    this.usedAt = const Value.absent(),
  });
  CardTemplateSkillUsagesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String queryUuid,
    required String templateUuid,
    required int skillId,
    required String usedAt,
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        queryUuid = Value(queryUuid),
        templateUuid = Value(templateUuid),
        skillId = Value(skillId),
        usedAt = Value(usedAt);
  static Insertable<CardTemplateSkillUsage> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? queryUuid,
    Expression<String>? templateUuid,
    Expression<int>? skillId,
    Expression<String>? usedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (queryUuid != null) 'query_uuid': queryUuid,
      if (templateUuid != null) 'template_uuid': templateUuid,
      if (skillId != null) 'skill_id': skillId,
      if (usedAt != null) 'used_at': usedAt,
    });
  }

  CardTemplateSkillUsagesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? queryUuid,
      Value<String>? templateUuid,
      Value<int>? skillId,
      Value<String>? usedAt}) {
    return CardTemplateSkillUsagesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      queryUuid: queryUuid ?? this.queryUuid,
      templateUuid: templateUuid ?? this.templateUuid,
      skillId: skillId ?? this.skillId,
      usedAt: usedAt ?? this.usedAt,
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
    if (queryUuid.present) {
      map['query_uuid'] = Variable<String>(queryUuid.value);
    }
    if (templateUuid.present) {
      map['template_uuid'] = Variable<String>(templateUuid.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<int>(skillId.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<String>(usedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSkillUsagesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('templateUuid: $templateUuid, ')
          ..write('skillId: $skillId, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }
}

class $MarketTemplateInstallsTable extends MarketTemplateInstalls
    with TableInfo<$MarketTemplateInstallsTable, MarketTemplateInstall> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketTemplateInstallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localTemplateUuidMeta =
      const VerificationMeta('localTemplateUuid');
  @override
  late final GeneratedColumn<String> localTemplateUuid =
      GeneratedColumn<String>('local_template_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _marketTemplateIdMeta =
      const VerificationMeta('marketTemplateId');
  @override
  late final GeneratedColumn<String> marketTemplateId = GeneratedColumn<String>(
      'market_template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _marketVersionIdMeta =
      const VerificationMeta('marketVersionId');
  @override
  late final GeneratedColumn<String> marketVersionId = GeneratedColumn<String>(
      'market_version_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _installedAtMeta =
      const VerificationMeta('installedAt');
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
      'installed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pinnedAtMeta =
      const VerificationMeta('pinnedAt');
  @override
  late final GeneratedColumn<DateTime> pinnedAt = GeneratedColumn<DateTime>(
      'pinned_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastCheckedAtMeta =
      const VerificationMeta('lastCheckedAt');
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>('last_checked_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localTemplateUuid,
        marketTemplateId,
        marketVersionId,
        installedAt,
        pinnedAt,
        lastCheckedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_market_template_installs';
  @override
  VerificationContext validateIntegrity(
      Insertable<MarketTemplateInstall> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_template_uuid')) {
      context.handle(
          _localTemplateUuidMeta,
          localTemplateUuid.isAcceptableOrUnknown(
              data['local_template_uuid']!, _localTemplateUuidMeta));
    } else if (isInserting) {
      context.missing(_localTemplateUuidMeta);
    }
    if (data.containsKey('market_template_id')) {
      context.handle(
          _marketTemplateIdMeta,
          marketTemplateId.isAcceptableOrUnknown(
              data['market_template_id']!, _marketTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_marketTemplateIdMeta);
    }
    if (data.containsKey('market_version_id')) {
      context.handle(
          _marketVersionIdMeta,
          marketVersionId.isAcceptableOrUnknown(
              data['market_version_id']!, _marketVersionIdMeta));
    } else if (isInserting) {
      context.missing(_marketVersionIdMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
          _installedAtMeta,
          installedAt.isAcceptableOrUnknown(
              data['installed_at']!, _installedAtMeta));
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('pinned_at')) {
      context.handle(_pinnedAtMeta,
          pinnedAt.isAcceptableOrUnknown(data['pinned_at']!, _pinnedAtMeta));
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
          _lastCheckedAtMeta,
          lastCheckedAt.isAcceptableOrUnknown(
              data['last_checked_at']!, _lastCheckedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localTemplateUuid};
  @override
  MarketTemplateInstall map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketTemplateInstall(
      localTemplateUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_template_uuid'])!,
      marketTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}market_template_id'])!,
      marketVersionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}market_version_id'])!,
      installedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}installed_at'])!,
      pinnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}pinned_at']),
      lastCheckedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_checked_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $MarketTemplateInstallsTable createAlias(String alias) {
    return $MarketTemplateInstallsTable(attachedDatabase, alias);
  }
}

class MarketTemplateInstall extends DataClass
    implements Insertable<MarketTemplateInstall> {
  final String localTemplateUuid;
  final String marketTemplateId;
  final String marketVersionId;
  final DateTime installedAt;
  final DateTime? pinnedAt;
  final DateTime? lastCheckedAt;
  final DateTime? deletedAt;
  const MarketTemplateInstall(
      {required this.localTemplateUuid,
      required this.marketTemplateId,
      required this.marketVersionId,
      required this.installedAt,
      this.pinnedAt,
      this.lastCheckedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_template_uuid'] = Variable<String>(localTemplateUuid);
    map['market_template_id'] = Variable<String>(marketTemplateId);
    map['market_version_id'] = Variable<String>(marketVersionId);
    map['installed_at'] = Variable<DateTime>(installedAt);
    if (!nullToAbsent || pinnedAt != null) {
      map['pinned_at'] = Variable<DateTime>(pinnedAt);
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  MarketTemplateInstallsCompanion toCompanion(bool nullToAbsent) {
    return MarketTemplateInstallsCompanion(
      localTemplateUuid: Value(localTemplateUuid),
      marketTemplateId: Value(marketTemplateId),
      marketVersionId: Value(marketVersionId),
      installedAt: Value(installedAt),
      pinnedAt: pinnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedAt),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory MarketTemplateInstall.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketTemplateInstall(
      localTemplateUuid: serializer.fromJson<String>(json['localTemplateUuid']),
      marketTemplateId: serializer.fromJson<String>(json['marketTemplateId']),
      marketVersionId: serializer.fromJson<String>(json['marketVersionId']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      pinnedAt: serializer.fromJson<DateTime?>(json['pinnedAt']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localTemplateUuid': serializer.toJson<String>(localTemplateUuid),
      'marketTemplateId': serializer.toJson<String>(marketTemplateId),
      'marketVersionId': serializer.toJson<String>(marketVersionId),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'pinnedAt': serializer.toJson<DateTime?>(pinnedAt),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  MarketTemplateInstall copyWith(
          {String? localTemplateUuid,
          String? marketTemplateId,
          String? marketVersionId,
          DateTime? installedAt,
          Value<DateTime?> pinnedAt = const Value.absent(),
          Value<DateTime?> lastCheckedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      MarketTemplateInstall(
        localTemplateUuid: localTemplateUuid ?? this.localTemplateUuid,
        marketTemplateId: marketTemplateId ?? this.marketTemplateId,
        marketVersionId: marketVersionId ?? this.marketVersionId,
        installedAt: installedAt ?? this.installedAt,
        pinnedAt: pinnedAt.present ? pinnedAt.value : this.pinnedAt,
        lastCheckedAt:
            lastCheckedAt.present ? lastCheckedAt.value : this.lastCheckedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  MarketTemplateInstall copyWithCompanion(
      MarketTemplateInstallsCompanion data) {
    return MarketTemplateInstall(
      localTemplateUuid: data.localTemplateUuid.present
          ? data.localTemplateUuid.value
          : this.localTemplateUuid,
      marketTemplateId: data.marketTemplateId.present
          ? data.marketTemplateId.value
          : this.marketTemplateId,
      marketVersionId: data.marketVersionId.present
          ? data.marketVersionId.value
          : this.marketVersionId,
      installedAt:
          data.installedAt.present ? data.installedAt.value : this.installedAt,
      pinnedAt: data.pinnedAt.present ? data.pinnedAt.value : this.pinnedAt,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketTemplateInstall(')
          ..write('localTemplateUuid: $localTemplateUuid, ')
          ..write('marketTemplateId: $marketTemplateId, ')
          ..write('marketVersionId: $marketVersionId, ')
          ..write('installedAt: $installedAt, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localTemplateUuid, marketTemplateId,
      marketVersionId, installedAt, pinnedAt, lastCheckedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketTemplateInstall &&
          other.localTemplateUuid == this.localTemplateUuid &&
          other.marketTemplateId == this.marketTemplateId &&
          other.marketVersionId == this.marketVersionId &&
          other.installedAt == this.installedAt &&
          other.pinnedAt == this.pinnedAt &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.deletedAt == this.deletedAt);
}

class MarketTemplateInstallsCompanion
    extends UpdateCompanion<MarketTemplateInstall> {
  final Value<String> localTemplateUuid;
  final Value<String> marketTemplateId;
  final Value<String> marketVersionId;
  final Value<DateTime> installedAt;
  final Value<DateTime?> pinnedAt;
  final Value<DateTime?> lastCheckedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const MarketTemplateInstallsCompanion({
    this.localTemplateUuid = const Value.absent(),
    this.marketTemplateId = const Value.absent(),
    this.marketVersionId = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketTemplateInstallsCompanion.insert({
    required String localTemplateUuid,
    required String marketTemplateId,
    required String marketVersionId,
    required DateTime installedAt,
    this.pinnedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : localTemplateUuid = Value(localTemplateUuid),
        marketTemplateId = Value(marketTemplateId),
        marketVersionId = Value(marketVersionId),
        installedAt = Value(installedAt);
  static Insertable<MarketTemplateInstall> custom({
    Expression<String>? localTemplateUuid,
    Expression<String>? marketTemplateId,
    Expression<String>? marketVersionId,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? pinnedAt,
    Expression<DateTime>? lastCheckedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localTemplateUuid != null) 'local_template_uuid': localTemplateUuid,
      if (marketTemplateId != null) 'market_template_id': marketTemplateId,
      if (marketVersionId != null) 'market_version_id': marketVersionId,
      if (installedAt != null) 'installed_at': installedAt,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketTemplateInstallsCompanion copyWith(
      {Value<String>? localTemplateUuid,
      Value<String>? marketTemplateId,
      Value<String>? marketVersionId,
      Value<DateTime>? installedAt,
      Value<DateTime?>? pinnedAt,
      Value<DateTime?>? lastCheckedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return MarketTemplateInstallsCompanion(
      localTemplateUuid: localTemplateUuid ?? this.localTemplateUuid,
      marketTemplateId: marketTemplateId ?? this.marketTemplateId,
      marketVersionId: marketVersionId ?? this.marketVersionId,
      installedAt: installedAt ?? this.installedAt,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localTemplateUuid.present) {
      map['local_template_uuid'] = Variable<String>(localTemplateUuid.value);
    }
    if (marketTemplateId.present) {
      map['market_template_id'] = Variable<String>(marketTemplateId.value);
    }
    if (marketVersionId.present) {
      map['market_version_id'] = Variable<String>(marketVersionId.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (pinnedAt.present) {
      map['pinned_at'] = Variable<DateTime>(pinnedAt.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketTemplateInstallsCompanion(')
          ..write('localTemplateUuid: $localTemplateUuid, ')
          ..write('marketTemplateId: $marketTemplateId, ')
          ..write('marketVersionId: $marketVersionId, ')
          ..write('installedAt: $installedAt, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DaYunRecordsTable daYunRecords = $DaYunRecordsTable(this);
  late final $TaiYuanRecordsTable taiYuanRecords = $TaiYuanRecordsTable(this);
  late final $LayoutTemplatesTable layoutTemplates =
      $LayoutTemplatesTable(this);
  late final $CardTemplateMetasTable cardTemplateMetas =
      $CardTemplateMetasTable(this);
  late final $CardTemplateSettingsTable cardTemplateSettings =
      $CardTemplateSettingsTable(this);
  late final $CardTemplateSkillUsagesTable cardTemplateSkillUsages =
      $CardTemplateSkillUsagesTable(this);
  late final $MarketTemplateInstallsTable marketTemplateInstalls =
      $MarketTemplateInstallsTable(this);
  late final CardTemplateMetaDao cardTemplateMetaDao =
      CardTemplateMetaDao(this as AppDatabase);
  late final CardTemplateSettingDao cardTemplateSettingDao =
      CardTemplateSettingDao(this as AppDatabase);
  late final CardTemplateSkillUsageDao cardTemplateSkillUsageDao =
      CardTemplateSkillUsageDao(this as AppDatabase);
  late final LayoutTemplatesDao layoutTemplatesDao =
      LayoutTemplatesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        daYunRecords,
        taiYuanRecords,
        layoutTemplates,
        cardTemplateMetas,
        cardTemplateSettings,
        cardTemplateSkillUsages,
        marketTemplateInstalls
      ];
}

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
    extends Composer<_$AppDatabase, $DaYunRecordsTable> {
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
    extends Composer<_$AppDatabase, $DaYunRecordsTable> {
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
    extends Composer<_$AppDatabase, $DaYunRecordsTable> {
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
    _$AppDatabase,
    $DaYunRecordsTable,
    DaYunRecord,
    $$DaYunRecordsTableFilterComposer,
    $$DaYunRecordsTableOrderingComposer,
    $$DaYunRecordsTableAnnotationComposer,
    $$DaYunRecordsTableCreateCompanionBuilder,
    $$DaYunRecordsTableUpdateCompanionBuilder,
    (
      DaYunRecord,
      BaseReferences<_$AppDatabase, $DaYunRecordsTable, DaYunRecord>
    ),
    DaYunRecord,
    PrefetchHooks Function()> {
  $$DaYunRecordsTableTableManager(_$AppDatabase db, $DaYunRecordsTable table)
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
    _$AppDatabase,
    $DaYunRecordsTable,
    DaYunRecord,
    $$DaYunRecordsTableFilterComposer,
    $$DaYunRecordsTableOrderingComposer,
    $$DaYunRecordsTableAnnotationComposer,
    $$DaYunRecordsTableCreateCompanionBuilder,
    $$DaYunRecordsTableUpdateCompanionBuilder,
    (
      DaYunRecord,
      BaseReferences<_$AppDatabase, $DaYunRecordsTable, DaYunRecord>
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
    extends Composer<_$AppDatabase, $TaiYuanRecordsTable> {
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
    extends Composer<_$AppDatabase, $TaiYuanRecordsTable> {
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
    extends Composer<_$AppDatabase, $TaiYuanRecordsTable> {
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
    _$AppDatabase,
    $TaiYuanRecordsTable,
    TaiYuanRecord,
    $$TaiYuanRecordsTableFilterComposer,
    $$TaiYuanRecordsTableOrderingComposer,
    $$TaiYuanRecordsTableAnnotationComposer,
    $$TaiYuanRecordsTableCreateCompanionBuilder,
    $$TaiYuanRecordsTableUpdateCompanionBuilder,
    (
      TaiYuanRecord,
      BaseReferences<_$AppDatabase, $TaiYuanRecordsTable, TaiYuanRecord>
    ),
    TaiYuanRecord,
    PrefetchHooks Function()> {
  $$TaiYuanRecordsTableTableManager(
      _$AppDatabase db, $TaiYuanRecordsTable table)
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
    _$AppDatabase,
    $TaiYuanRecordsTable,
    TaiYuanRecord,
    $$TaiYuanRecordsTableFilterComposer,
    $$TaiYuanRecordsTableOrderingComposer,
    $$TaiYuanRecordsTableAnnotationComposer,
    $$TaiYuanRecordsTableCreateCompanionBuilder,
    $$TaiYuanRecordsTableUpdateCompanionBuilder,
    (
      TaiYuanRecord,
      BaseReferences<_$AppDatabase, $TaiYuanRecordsTable, TaiYuanRecord>
    ),
    TaiYuanRecord,
    PrefetchHooks Function()>;
typedef $$LayoutTemplatesTableCreateCompanionBuilder = LayoutTemplatesCompanion
    Function({
  required String uuid,
  required String collectionId,
  required String name,
  Value<String?> description,
  required String templateJson,
  required int version,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$LayoutTemplatesTableUpdateCompanionBuilder = LayoutTemplatesCompanion
    Function({
  Value<String> uuid,
  Value<String> collectionId,
  Value<String> name,
  Value<String?> description,
  Value<String> templateJson,
  Value<int> version,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$LayoutTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $LayoutTemplatesTable> {
  $$LayoutTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateJson => $composableBuilder(
      column: $table.templateJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$LayoutTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LayoutTemplatesTable> {
  $$LayoutTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionId => $composableBuilder(
      column: $table.collectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateJson => $composableBuilder(
      column: $table.templateJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$LayoutTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LayoutTemplatesTable> {
  $$LayoutTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get templateJson => $composableBuilder(
      column: $table.templateJson, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LayoutTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LayoutTemplatesTable,
    LayoutTemplateRow,
    $$LayoutTemplatesTableFilterComposer,
    $$LayoutTemplatesTableOrderingComposer,
    $$LayoutTemplatesTableAnnotationComposer,
    $$LayoutTemplatesTableCreateCompanionBuilder,
    $$LayoutTemplatesTableUpdateCompanionBuilder,
    (
      LayoutTemplateRow,
      BaseReferences<_$AppDatabase, $LayoutTemplatesTable, LayoutTemplateRow>
    ),
    LayoutTemplateRow,
    PrefetchHooks Function()> {
  $$LayoutTemplatesTableTableManager(
      _$AppDatabase db, $LayoutTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LayoutTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LayoutTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LayoutTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> collectionId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> templateJson = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LayoutTemplatesCompanion(
            uuid: uuid,
            collectionId: collectionId,
            name: name,
            description: description,
            templateJson: templateJson,
            version: version,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String collectionId,
            required String name,
            Value<String?> description = const Value.absent(),
            required String templateJson,
            required int version,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LayoutTemplatesCompanion.insert(
            uuid: uuid,
            collectionId: collectionId,
            name: name,
            description: description,
            templateJson: templateJson,
            version: version,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LayoutTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LayoutTemplatesTable,
    LayoutTemplateRow,
    $$LayoutTemplatesTableFilterComposer,
    $$LayoutTemplatesTableOrderingComposer,
    $$LayoutTemplatesTableAnnotationComposer,
    $$LayoutTemplatesTableCreateCompanionBuilder,
    $$LayoutTemplatesTableUpdateCompanionBuilder,
    (
      LayoutTemplateRow,
      BaseReferences<_$AppDatabase, $LayoutTemplatesTable, LayoutTemplateRow>
    ),
    LayoutTemplateRow,
    PrefetchHooks Function()>;
typedef $$CardTemplateMetasTableCreateCompanionBuilder
    = CardTemplateMetasCompanion Function({
  required String templateUuid,
  required DateTime createdAt,
  required DateTime modifiedAt,
  Value<DateTime?> deletedAt,
  Value<String?> authorUuid,
  Value<String?> createFromCardUuid,
  Value<bool?> isCustomized,
  Value<int> rowid,
});
typedef $$CardTemplateMetasTableUpdateCompanionBuilder
    = CardTemplateMetasCompanion Function({
  Value<String> templateUuid,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deletedAt,
  Value<String?> authorUuid,
  Value<String?> createFromCardUuid,
  Value<bool?> isCustomized,
  Value<int> rowid,
});

class $$CardTemplateMetasTableFilterComposer
    extends Composer<_$AppDatabase, $CardTemplateMetasTable> {
  $$CardTemplateMetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorUuid => $composableBuilder(
      column: $table.authorUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createFromCardUuid => $composableBuilder(
      column: $table.createFromCardUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));
}

class $$CardTemplateMetasTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTemplateMetasTable> {
  $$CardTemplateMetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorUuid => $composableBuilder(
      column: $table.authorUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createFromCardUuid => $composableBuilder(
      column: $table.createFromCardUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));
}

class $$CardTemplateMetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTemplateMetasTable> {
  $$CardTemplateMetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get authorUuid => $composableBuilder(
      column: $table.authorUuid, builder: (column) => column);

  GeneratedColumn<String> get createFromCardUuid => $composableBuilder(
      column: $table.createFromCardUuid, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);
}

class $$CardTemplateMetasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTemplateMetasTable,
    CardTemplateMeta,
    $$CardTemplateMetasTableFilterComposer,
    $$CardTemplateMetasTableOrderingComposer,
    $$CardTemplateMetasTableAnnotationComposer,
    $$CardTemplateMetasTableCreateCompanionBuilder,
    $$CardTemplateMetasTableUpdateCompanionBuilder,
    (
      CardTemplateMeta,
      BaseReferences<_$AppDatabase, $CardTemplateMetasTable, CardTemplateMeta>
    ),
    CardTemplateMeta,
    PrefetchHooks Function()> {
  $$CardTemplateMetasTableTableManager(
      _$AppDatabase db, $CardTemplateMetasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTemplateMetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTemplateMetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTemplateMetasTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> templateUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> authorUuid = const Value.absent(),
            Value<String?> createFromCardUuid = const Value.absent(),
            Value<bool?> isCustomized = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateMetasCompanion(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            authorUuid: authorUuid,
            createFromCardUuid: createFromCardUuid,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String templateUuid,
            required DateTime createdAt,
            required DateTime modifiedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> authorUuid = const Value.absent(),
            Value<String?> createFromCardUuid = const Value.absent(),
            Value<bool?> isCustomized = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateMetasCompanion.insert(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            authorUuid: authorUuid,
            createFromCardUuid: createFromCardUuid,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardTemplateMetasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardTemplateMetasTable,
    CardTemplateMeta,
    $$CardTemplateMetasTableFilterComposer,
    $$CardTemplateMetasTableOrderingComposer,
    $$CardTemplateMetasTableAnnotationComposer,
    $$CardTemplateMetasTableCreateCompanionBuilder,
    $$CardTemplateMetasTableUpdateCompanionBuilder,
    (
      CardTemplateMeta,
      BaseReferences<_$AppDatabase, $CardTemplateMetasTable, CardTemplateMeta>
    ),
    CardTemplateMeta,
    PrefetchHooks Function()>;
typedef $$CardTemplateSettingsTableCreateCompanionBuilder
    = CardTemplateSettingsCompanion Function({
  required String templateUuid,
  required DateTime createdAt,
  required DateTime modifiedAt,
  Value<DateTime?> deletedAt,
  required String settingJson,
  Value<int> rowid,
});
typedef $$CardTemplateSettingsTableUpdateCompanionBuilder
    = CardTemplateSettingsCompanion Function({
  Value<String> templateUuid,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deletedAt,
  Value<String> settingJson,
  Value<int> rowid,
});

class $$CardTemplateSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTemplateSettingsTable> {
  $$CardTemplateSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingJson => $composableBuilder(
      column: $table.settingJson, builder: (column) => ColumnFilters(column));
}

class $$CardTemplateSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTemplateSettingsTable> {
  $$CardTemplateSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingJson => $composableBuilder(
      column: $table.settingJson, builder: (column) => ColumnOrderings(column));
}

class $$CardTemplateSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTemplateSettingsTable> {
  $$CardTemplateSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get settingJson => $composableBuilder(
      column: $table.settingJson, builder: (column) => column);
}

class $$CardTemplateSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTemplateSettingsTable,
    CardTemplateSettingRecord,
    $$CardTemplateSettingsTableFilterComposer,
    $$CardTemplateSettingsTableOrderingComposer,
    $$CardTemplateSettingsTableAnnotationComposer,
    $$CardTemplateSettingsTableCreateCompanionBuilder,
    $$CardTemplateSettingsTableUpdateCompanionBuilder,
    (
      CardTemplateSettingRecord,
      BaseReferences<_$AppDatabase, $CardTemplateSettingsTable,
          CardTemplateSettingRecord>
    ),
    CardTemplateSettingRecord,
    PrefetchHooks Function()> {
  $$CardTemplateSettingsTableTableManager(
      _$AppDatabase db, $CardTemplateSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTemplateSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTemplateSettingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTemplateSettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> templateUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> settingJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateSettingsCompanion(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            settingJson: settingJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String templateUuid,
            required DateTime createdAt,
            required DateTime modifiedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String settingJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateSettingsCompanion.insert(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            settingJson: settingJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardTemplateSettingsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CardTemplateSettingsTable,
        CardTemplateSettingRecord,
        $$CardTemplateSettingsTableFilterComposer,
        $$CardTemplateSettingsTableOrderingComposer,
        $$CardTemplateSettingsTableAnnotationComposer,
        $$CardTemplateSettingsTableCreateCompanionBuilder,
        $$CardTemplateSettingsTableUpdateCompanionBuilder,
        (
          CardTemplateSettingRecord,
          BaseReferences<_$AppDatabase, $CardTemplateSettingsTable,
              CardTemplateSettingRecord>
        ),
        CardTemplateSettingRecord,
        PrefetchHooks Function()>;
typedef $$CardTemplateSkillUsagesTableCreateCompanionBuilder
    = CardTemplateSkillUsagesCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String queryUuid,
  required String templateUuid,
  required int skillId,
  required String usedAt,
});
typedef $$CardTemplateSkillUsagesTableUpdateCompanionBuilder
    = CardTemplateSkillUsagesCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> queryUuid,
  Value<String> templateUuid,
  Value<int> skillId,
  Value<String> usedAt,
});

class $$CardTemplateSkillUsagesTableFilterComposer
    extends Composer<_$AppDatabase, $CardTemplateSkillUsagesTable> {
  $$CardTemplateSkillUsagesTableFilterComposer({
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

  ColumnFilters<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnFilters(column));
}

class $$CardTemplateSkillUsagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTemplateSkillUsagesTable> {
  $$CardTemplateSkillUsagesTableOrderingComposer({
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

  ColumnOrderings<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnOrderings(column));
}

class $$CardTemplateSkillUsagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTemplateSkillUsagesTable> {
  $$CardTemplateSkillUsagesTableAnnotationComposer({
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

  GeneratedColumn<String> get queryUuid =>
      $composableBuilder(column: $table.queryUuid, builder: (column) => column);

  GeneratedColumn<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => column);

  GeneratedColumn<int> get skillId =>
      $composableBuilder(column: $table.skillId, builder: (column) => column);

  GeneratedColumn<String> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);
}

class $$CardTemplateSkillUsagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTemplateSkillUsagesTable,
    CardTemplateSkillUsage,
    $$CardTemplateSkillUsagesTableFilterComposer,
    $$CardTemplateSkillUsagesTableOrderingComposer,
    $$CardTemplateSkillUsagesTableAnnotationComposer,
    $$CardTemplateSkillUsagesTableCreateCompanionBuilder,
    $$CardTemplateSkillUsagesTableUpdateCompanionBuilder,
    (
      CardTemplateSkillUsage,
      BaseReferences<_$AppDatabase, $CardTemplateSkillUsagesTable,
          CardTemplateSkillUsage>
    ),
    CardTemplateSkillUsage,
    PrefetchHooks Function()> {
  $$CardTemplateSkillUsagesTableTableManager(
      _$AppDatabase db, $CardTemplateSkillUsagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTemplateSkillUsagesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTemplateSkillUsagesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTemplateSkillUsagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> queryUuid = const Value.absent(),
            Value<String> templateUuid = const Value.absent(),
            Value<int> skillId = const Value.absent(),
            Value<String> usedAt = const Value.absent(),
          }) =>
              CardTemplateSkillUsagesCompanion(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            queryUuid: queryUuid,
            templateUuid: templateUuid,
            skillId: skillId,
            usedAt: usedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String queryUuid,
            required String templateUuid,
            required int skillId,
            required String usedAt,
          }) =>
              CardTemplateSkillUsagesCompanion.insert(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            queryUuid: queryUuid,
            templateUuid: templateUuid,
            skillId: skillId,
            usedAt: usedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardTemplateSkillUsagesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CardTemplateSkillUsagesTable,
        CardTemplateSkillUsage,
        $$CardTemplateSkillUsagesTableFilterComposer,
        $$CardTemplateSkillUsagesTableOrderingComposer,
        $$CardTemplateSkillUsagesTableAnnotationComposer,
        $$CardTemplateSkillUsagesTableCreateCompanionBuilder,
        $$CardTemplateSkillUsagesTableUpdateCompanionBuilder,
        (
          CardTemplateSkillUsage,
          BaseReferences<_$AppDatabase, $CardTemplateSkillUsagesTable,
              CardTemplateSkillUsage>
        ),
        CardTemplateSkillUsage,
        PrefetchHooks Function()>;
typedef $$MarketTemplateInstallsTableCreateCompanionBuilder
    = MarketTemplateInstallsCompanion Function({
  required String localTemplateUuid,
  required String marketTemplateId,
  required String marketVersionId,
  required DateTime installedAt,
  Value<DateTime?> pinnedAt,
  Value<DateTime?> lastCheckedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$MarketTemplateInstallsTableUpdateCompanionBuilder
    = MarketTemplateInstallsCompanion Function({
  Value<String> localTemplateUuid,
  Value<String> marketTemplateId,
  Value<String> marketVersionId,
  Value<DateTime> installedAt,
  Value<DateTime?> pinnedAt,
  Value<DateTime?> lastCheckedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$MarketTemplateInstallsTableFilterComposer
    extends Composer<_$AppDatabase, $MarketTemplateInstallsTable> {
  $$MarketTemplateInstallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localTemplateUuid => $composableBuilder(
      column: $table.localTemplateUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get marketTemplateId => $composableBuilder(
      column: $table.marketTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get marketVersionId => $composableBuilder(
      column: $table.marketVersionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pinnedAt => $composableBuilder(
      column: $table.pinnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$MarketTemplateInstallsTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketTemplateInstallsTable> {
  $$MarketTemplateInstallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localTemplateUuid => $composableBuilder(
      column: $table.localTemplateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get marketTemplateId => $composableBuilder(
      column: $table.marketTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get marketVersionId => $composableBuilder(
      column: $table.marketVersionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pinnedAt => $composableBuilder(
      column: $table.pinnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$MarketTemplateInstallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketTemplateInstallsTable> {
  $$MarketTemplateInstallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localTemplateUuid => $composableBuilder(
      column: $table.localTemplateUuid, builder: (column) => column);

  GeneratedColumn<String> get marketTemplateId => $composableBuilder(
      column: $table.marketTemplateId, builder: (column) => column);

  GeneratedColumn<String> get marketVersionId => $composableBuilder(
      column: $table.marketVersionId, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$MarketTemplateInstallsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MarketTemplateInstallsTable,
    MarketTemplateInstall,
    $$MarketTemplateInstallsTableFilterComposer,
    $$MarketTemplateInstallsTableOrderingComposer,
    $$MarketTemplateInstallsTableAnnotationComposer,
    $$MarketTemplateInstallsTableCreateCompanionBuilder,
    $$MarketTemplateInstallsTableUpdateCompanionBuilder,
    (
      MarketTemplateInstall,
      BaseReferences<_$AppDatabase, $MarketTemplateInstallsTable,
          MarketTemplateInstall>
    ),
    MarketTemplateInstall,
    PrefetchHooks Function()> {
  $$MarketTemplateInstallsTableTableManager(
      _$AppDatabase db, $MarketTemplateInstallsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketTemplateInstallsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketTemplateInstallsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarketTemplateInstallsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localTemplateUuid = const Value.absent(),
            Value<String> marketTemplateId = const Value.absent(),
            Value<String> marketVersionId = const Value.absent(),
            Value<DateTime> installedAt = const Value.absent(),
            Value<DateTime?> pinnedAt = const Value.absent(),
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MarketTemplateInstallsCompanion(
            localTemplateUuid: localTemplateUuid,
            marketTemplateId: marketTemplateId,
            marketVersionId: marketVersionId,
            installedAt: installedAt,
            pinnedAt: pinnedAt,
            lastCheckedAt: lastCheckedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localTemplateUuid,
            required String marketTemplateId,
            required String marketVersionId,
            required DateTime installedAt,
            Value<DateTime?> pinnedAt = const Value.absent(),
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MarketTemplateInstallsCompanion.insert(
            localTemplateUuid: localTemplateUuid,
            marketTemplateId: marketTemplateId,
            marketVersionId: marketVersionId,
            installedAt: installedAt,
            pinnedAt: pinnedAt,
            lastCheckedAt: lastCheckedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MarketTemplateInstallsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MarketTemplateInstallsTable,
        MarketTemplateInstall,
        $$MarketTemplateInstallsTableFilterComposer,
        $$MarketTemplateInstallsTableOrderingComposer,
        $$MarketTemplateInstallsTableAnnotationComposer,
        $$MarketTemplateInstallsTableCreateCompanionBuilder,
        $$MarketTemplateInstallsTableUpdateCompanionBuilder,
        (
          MarketTemplateInstall,
          BaseReferences<_$AppDatabase, $MarketTemplateInstallsTable,
              MarketTemplateInstall>
        ),
        MarketTemplateInstall,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DaYunRecordsTableTableManager get daYunRecords =>
      $$DaYunRecordsTableTableManager(_db, _db.daYunRecords);
  $$TaiYuanRecordsTableTableManager get taiYuanRecords =>
      $$TaiYuanRecordsTableTableManager(_db, _db.taiYuanRecords);
  $$LayoutTemplatesTableTableManager get layoutTemplates =>
      $$LayoutTemplatesTableTableManager(_db, _db.layoutTemplates);
  $$CardTemplateMetasTableTableManager get cardTemplateMetas =>
      $$CardTemplateMetasTableTableManager(_db, _db.cardTemplateMetas);
  $$CardTemplateSettingsTableTableManager get cardTemplateSettings =>
      $$CardTemplateSettingsTableTableManager(_db, _db.cardTemplateSettings);
  $$CardTemplateSkillUsagesTableTableManager get cardTemplateSkillUsages =>
      $$CardTemplateSkillUsagesTableTableManager(
          _db, _db.cardTemplateSkillUsages);
  $$MarketTemplateInstallsTableTableManager get marketTemplateInstalls =>
      $$MarketTemplateInstallsTableTableManager(
          _db, _db.marketTemplateInstalls);
}
