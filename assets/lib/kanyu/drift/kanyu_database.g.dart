// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanyu_database.dart';

// ignore_for_file: type=lint
class $KanyuRuleDocumentsTable extends KanyuRuleDocuments
    with TableInfo<$KanyuRuleDocumentsTable, KanyuRuleDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanyuRuleDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [fileName, payloadJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanyuRuleDocumentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileName};
  @override
  KanyuRuleDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanyuRuleDocumentEntry(
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $KanyuRuleDocumentsTable createAlias(String alias) {
    return $KanyuRuleDocumentsTable(attachedDatabase, alias);
  }
}

class KanyuRuleDocumentEntry extends DataClass
    implements Insertable<KanyuRuleDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const KanyuRuleDocumentEntry({
    required this.fileName,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_name'] = Variable<String>(fileName);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  KanyuRuleDocumentsCompanion toCompanion(bool nullToAbsent) {
    return KanyuRuleDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory KanyuRuleDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanyuRuleDocumentEntry(
      fileName: serializer.fromJson<String>(json['fileName']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileName': serializer.toJson<String>(fileName),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  KanyuRuleDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      KanyuRuleDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  KanyuRuleDocumentEntry copyWithCompanion(KanyuRuleDocumentsCompanion data) {
    return KanyuRuleDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanyuRuleDocumentEntry(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileName, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanyuRuleDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class KanyuRuleDocumentsCompanion
    extends UpdateCompanion<KanyuRuleDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const KanyuRuleDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanyuRuleDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<KanyuRuleDocumentEntry> custom({
    Expression<String>? fileName,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileName != null) 'file_name': fileName,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanyuRuleDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return KanyuRuleDocumentsCompanion(
      fileName: fileName ?? this.fileName,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanyuRuleDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KanyuStaticDataDocumentsTable extends KanyuStaticDataDocuments
    with
        TableInfo<
          $KanyuStaticDataDocumentsTable,
          KanyuStaticDataDocumentEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanyuStaticDataDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [fileName, payloadJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'static_data_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanyuStaticDataDocumentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileName};
  @override
  KanyuStaticDataDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanyuStaticDataDocumentEntry(
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $KanyuStaticDataDocumentsTable createAlias(String alias) {
    return $KanyuStaticDataDocumentsTable(attachedDatabase, alias);
  }
}

class KanyuStaticDataDocumentEntry extends DataClass
    implements Insertable<KanyuStaticDataDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const KanyuStaticDataDocumentEntry({
    required this.fileName,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_name'] = Variable<String>(fileName);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  KanyuStaticDataDocumentsCompanion toCompanion(bool nullToAbsent) {
    return KanyuStaticDataDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory KanyuStaticDataDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanyuStaticDataDocumentEntry(
      fileName: serializer.fromJson<String>(json['fileName']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileName': serializer.toJson<String>(fileName),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  KanyuStaticDataDocumentEntry copyWith({
    String? fileName,
    String? payloadJson,
  }) => KanyuStaticDataDocumentEntry(
    fileName: fileName ?? this.fileName,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  KanyuStaticDataDocumentEntry copyWithCompanion(
    KanyuStaticDataDocumentsCompanion data,
  ) {
    return KanyuStaticDataDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanyuStaticDataDocumentEntry(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileName, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanyuStaticDataDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class KanyuStaticDataDocumentsCompanion
    extends UpdateCompanion<KanyuStaticDataDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const KanyuStaticDataDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanyuStaticDataDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<KanyuStaticDataDocumentEntry> custom({
    Expression<String>? fileName,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileName != null) 'file_name': fileName,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanyuStaticDataDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return KanyuStaticDataDocumentsCompanion(
      fileName: fileName ?? this.fileName,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanyuStaticDataDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KanyuSchemaDocumentsTable extends KanyuSchemaDocuments
    with TableInfo<$KanyuSchemaDocumentsTable, KanyuSchemaDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanyuSchemaDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [fileName, payloadJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanyuSchemaDocumentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileName};
  @override
  KanyuSchemaDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanyuSchemaDocumentEntry(
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  $KanyuSchemaDocumentsTable createAlias(String alias) {
    return $KanyuSchemaDocumentsTable(attachedDatabase, alias);
  }
}

class KanyuSchemaDocumentEntry extends DataClass
    implements Insertable<KanyuSchemaDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const KanyuSchemaDocumentEntry({
    required this.fileName,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_name'] = Variable<String>(fileName);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  KanyuSchemaDocumentsCompanion toCompanion(bool nullToAbsent) {
    return KanyuSchemaDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory KanyuSchemaDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanyuSchemaDocumentEntry(
      fileName: serializer.fromJson<String>(json['fileName']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileName': serializer.toJson<String>(fileName),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  KanyuSchemaDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      KanyuSchemaDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  KanyuSchemaDocumentEntry copyWithCompanion(
    KanyuSchemaDocumentsCompanion data,
  ) {
    return KanyuSchemaDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanyuSchemaDocumentEntry(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileName, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanyuSchemaDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class KanyuSchemaDocumentsCompanion
    extends UpdateCompanion<KanyuSchemaDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const KanyuSchemaDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanyuSchemaDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<KanyuSchemaDocumentEntry> custom({
    Expression<String>? fileName,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileName != null) 'file_name': fileName,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanyuSchemaDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return KanyuSchemaDocumentsCompanion(
      fileName: fileName ?? this.fileName,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanyuSchemaDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KanyuDatasetGenerationsTable extends KanyuDatasetGenerations
    with TableInfo<$KanyuDatasetGenerationsTable, KanyuDatasetGenerationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanyuDatasetGenerationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _datasetIdMeta = const VerificationMeta(
    'datasetId',
  );
  @override
  late final GeneratedColumn<String> datasetId = GeneratedColumn<String>(
    'dataset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadSha256Meta = const VerificationMeta(
    'payloadSha256',
  );
  @override
  late final GeneratedColumn<String> payloadSha256 = GeneratedColumn<String>(
    'payload_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadBytesMeta = const VerificationMeta(
    'payloadBytes',
  );
  @override
  late final GeneratedColumn<int> payloadBytes = GeneratedColumn<int>(
    'payload_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _declaredRowCountMeta = const VerificationMeta(
    'declaredRowCount',
  );
  @override
  late final GeneratedColumn<int> declaredRowCount = GeneratedColumn<int>(
    'declared_row_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installedAtUtcMeta = const VerificationMeta(
    'installedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> installedAtUtc =
      GeneratedColumn<DateTime>(
        'installed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    datasetId,
    generation,
    payloadSha256,
    payloadBytes,
    declaredRowCount,
    status,
    sourceId,
    installedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dataset_generation';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanyuDatasetGenerationEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dataset_id')) {
      context.handle(
        _datasetIdMeta,
        datasetId.isAcceptableOrUnknown(data['dataset_id']!, _datasetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_datasetIdMeta);
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    } else if (isInserting) {
      context.missing(_generationMeta);
    }
    if (data.containsKey('payload_sha256')) {
      context.handle(
        _payloadSha256Meta,
        payloadSha256.isAcceptableOrUnknown(
          data['payload_sha256']!,
          _payloadSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadSha256Meta);
    }
    if (data.containsKey('payload_bytes')) {
      context.handle(
        _payloadBytesMeta,
        payloadBytes.isAcceptableOrUnknown(
          data['payload_bytes']!,
          _payloadBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadBytesMeta);
    }
    if (data.containsKey('declared_row_count')) {
      context.handle(
        _declaredRowCountMeta,
        declaredRowCount.isAcceptableOrUnknown(
          data['declared_row_count']!,
          _declaredRowCountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('installed_at_utc')) {
      context.handle(
        _installedAtUtcMeta,
        installedAtUtc.isAcceptableOrUnknown(
          data['installed_at_utc']!,
          _installedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {datasetId, generation};
  @override
  KanyuDatasetGenerationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanyuDatasetGenerationEntry(
      datasetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dataset_id'],
      )!,
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      payloadSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_sha256'],
      )!,
      payloadBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_bytes'],
      )!,
      declaredRowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}declared_row_count'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      installedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at_utc'],
      ),
    );
  }

  @override
  $KanyuDatasetGenerationsTable createAlias(String alias) {
    return $KanyuDatasetGenerationsTable(attachedDatabase, alias);
  }
}

class KanyuDatasetGenerationEntry extends DataClass
    implements Insertable<KanyuDatasetGenerationEntry> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const KanyuDatasetGenerationEntry({
    required this.datasetId,
    required this.generation,
    required this.payloadSha256,
    required this.payloadBytes,
    this.declaredRowCount,
    required this.status,
    required this.sourceId,
    this.installedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dataset_id'] = Variable<String>(datasetId);
    map['generation'] = Variable<int>(generation);
    map['payload_sha256'] = Variable<String>(payloadSha256);
    map['payload_bytes'] = Variable<int>(payloadBytes);
    if (!nullToAbsent || declaredRowCount != null) {
      map['declared_row_count'] = Variable<int>(declaredRowCount);
    }
    map['status'] = Variable<String>(status);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || installedAtUtc != null) {
      map['installed_at_utc'] = Variable<DateTime>(installedAtUtc);
    }
    return map;
  }

  KanyuDatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return KanyuDatasetGenerationsCompanion(
      datasetId: Value(datasetId),
      generation: Value(generation),
      payloadSha256: Value(payloadSha256),
      payloadBytes: Value(payloadBytes),
      declaredRowCount: declaredRowCount == null && nullToAbsent
          ? const Value.absent()
          : Value(declaredRowCount),
      status: Value(status),
      sourceId: Value(sourceId),
      installedAtUtc: installedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAtUtc),
    );
  }

  factory KanyuDatasetGenerationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanyuDatasetGenerationEntry(
      datasetId: serializer.fromJson<String>(json['datasetId']),
      generation: serializer.fromJson<int>(json['generation']),
      payloadSha256: serializer.fromJson<String>(json['payloadSha256']),
      payloadBytes: serializer.fromJson<int>(json['payloadBytes']),
      declaredRowCount: serializer.fromJson<int?>(json['declaredRowCount']),
      status: serializer.fromJson<String>(json['status']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      installedAtUtc: serializer.fromJson<DateTime?>(json['installedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'datasetId': serializer.toJson<String>(datasetId),
      'generation': serializer.toJson<int>(generation),
      'payloadSha256': serializer.toJson<String>(payloadSha256),
      'payloadBytes': serializer.toJson<int>(payloadBytes),
      'declaredRowCount': serializer.toJson<int?>(declaredRowCount),
      'status': serializer.toJson<String>(status),
      'sourceId': serializer.toJson<String>(sourceId),
      'installedAtUtc': serializer.toJson<DateTime?>(installedAtUtc),
    };
  }

  KanyuDatasetGenerationEntry copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => KanyuDatasetGenerationEntry(
    datasetId: datasetId ?? this.datasetId,
    generation: generation ?? this.generation,
    payloadSha256: payloadSha256 ?? this.payloadSha256,
    payloadBytes: payloadBytes ?? this.payloadBytes,
    declaredRowCount: declaredRowCount.present
        ? declaredRowCount.value
        : this.declaredRowCount,
    status: status ?? this.status,
    sourceId: sourceId ?? this.sourceId,
    installedAtUtc: installedAtUtc.present
        ? installedAtUtc.value
        : this.installedAtUtc,
  );
  KanyuDatasetGenerationEntry copyWithCompanion(
    KanyuDatasetGenerationsCompanion data,
  ) {
    return KanyuDatasetGenerationEntry(
      datasetId: data.datasetId.present ? data.datasetId.value : this.datasetId,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      payloadSha256: data.payloadSha256.present
          ? data.payloadSha256.value
          : this.payloadSha256,
      payloadBytes: data.payloadBytes.present
          ? data.payloadBytes.value
          : this.payloadBytes,
      declaredRowCount: data.declaredRowCount.present
          ? data.declaredRowCount.value
          : this.declaredRowCount,
      status: data.status.present ? data.status.value : this.status,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      installedAtUtc: data.installedAtUtc.present
          ? data.installedAtUtc.value
          : this.installedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanyuDatasetGenerationEntry(')
          ..write('datasetId: $datasetId, ')
          ..write('generation: $generation, ')
          ..write('payloadSha256: $payloadSha256, ')
          ..write('payloadBytes: $payloadBytes, ')
          ..write('declaredRowCount: $declaredRowCount, ')
          ..write('status: $status, ')
          ..write('sourceId: $sourceId, ')
          ..write('installedAtUtc: $installedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    datasetId,
    generation,
    payloadSha256,
    payloadBytes,
    declaredRowCount,
    status,
    sourceId,
    installedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanyuDatasetGenerationEntry &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class KanyuDatasetGenerationsCompanion
    extends UpdateCompanion<KanyuDatasetGenerationEntry> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const KanyuDatasetGenerationsCompanion({
    this.datasetId = const Value.absent(),
    this.generation = const Value.absent(),
    this.payloadSha256 = const Value.absent(),
    this.payloadBytes = const Value.absent(),
    this.declaredRowCount = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.installedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanyuDatasetGenerationsCompanion.insert({
    required String datasetId,
    required int generation,
    required String payloadSha256,
    required int payloadBytes,
    this.declaredRowCount = const Value.absent(),
    required String status,
    required String sourceId,
    this.installedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : datasetId = Value(datasetId),
       generation = Value(generation),
       payloadSha256 = Value(payloadSha256),
       payloadBytes = Value(payloadBytes),
       status = Value(status),
       sourceId = Value(sourceId);
  static Insertable<KanyuDatasetGenerationEntry> custom({
    Expression<String>? datasetId,
    Expression<int>? generation,
    Expression<String>? payloadSha256,
    Expression<int>? payloadBytes,
    Expression<int>? declaredRowCount,
    Expression<String>? status,
    Expression<String>? sourceId,
    Expression<DateTime>? installedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (datasetId != null) 'dataset_id': datasetId,
      if (generation != null) 'generation': generation,
      if (payloadSha256 != null) 'payload_sha256': payloadSha256,
      if (payloadBytes != null) 'payload_bytes': payloadBytes,
      if (declaredRowCount != null) 'declared_row_count': declaredRowCount,
      if (status != null) 'status': status,
      if (sourceId != null) 'source_id': sourceId,
      if (installedAtUtc != null) 'installed_at_utc': installedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanyuDatasetGenerationsCompanion copyWith({
    Value<String>? datasetId,
    Value<int>? generation,
    Value<String>? payloadSha256,
    Value<int>? payloadBytes,
    Value<int?>? declaredRowCount,
    Value<String>? status,
    Value<String>? sourceId,
    Value<DateTime?>? installedAtUtc,
    Value<int>? rowid,
  }) {
    return KanyuDatasetGenerationsCompanion(
      datasetId: datasetId ?? this.datasetId,
      generation: generation ?? this.generation,
      payloadSha256: payloadSha256 ?? this.payloadSha256,
      payloadBytes: payloadBytes ?? this.payloadBytes,
      declaredRowCount: declaredRowCount ?? this.declaredRowCount,
      status: status ?? this.status,
      sourceId: sourceId ?? this.sourceId,
      installedAtUtc: installedAtUtc ?? this.installedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (datasetId.present) {
      map['dataset_id'] = Variable<String>(datasetId.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (payloadSha256.present) {
      map['payload_sha256'] = Variable<String>(payloadSha256.value);
    }
    if (payloadBytes.present) {
      map['payload_bytes'] = Variable<int>(payloadBytes.value);
    }
    if (declaredRowCount.present) {
      map['declared_row_count'] = Variable<int>(declaredRowCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (installedAtUtc.present) {
      map['installed_at_utc'] = Variable<DateTime>(installedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanyuDatasetGenerationsCompanion(')
          ..write('datasetId: $datasetId, ')
          ..write('generation: $generation, ')
          ..write('payloadSha256: $payloadSha256, ')
          ..write('payloadBytes: $payloadBytes, ')
          ..write('declaredRowCount: $declaredRowCount, ')
          ..write('status: $status, ')
          ..write('sourceId: $sourceId, ')
          ..write('installedAtUtc: $installedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$KanyuDatabase extends GeneratedDatabase {
  _$KanyuDatabase(QueryExecutor e) : super(e);
  $KanyuDatabaseManager get managers => $KanyuDatabaseManager(this);
  late final $KanyuRuleDocumentsTable kanyuRuleDocuments =
      $KanyuRuleDocumentsTable(this);
  late final $KanyuStaticDataDocumentsTable kanyuStaticDataDocuments =
      $KanyuStaticDataDocumentsTable(this);
  late final $KanyuSchemaDocumentsTable kanyuSchemaDocuments =
      $KanyuSchemaDocumentsTable(this);
  late final $KanyuDatasetGenerationsTable kanyuDatasetGenerations =
      $KanyuDatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    kanyuRuleDocuments,
    kanyuStaticDataDocuments,
    kanyuSchemaDocuments,
    kanyuDatasetGenerations,
  ];
}

typedef $$KanyuRuleDocumentsTableCreateCompanionBuilder =
    KanyuRuleDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$KanyuRuleDocumentsTableUpdateCompanionBuilder =
    KanyuRuleDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$KanyuRuleDocumentsTableFilterComposer
    extends Composer<_$KanyuDatabase, $KanyuRuleDocumentsTable> {
  $$KanyuRuleDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanyuRuleDocumentsTableOrderingComposer
    extends Composer<_$KanyuDatabase, $KanyuRuleDocumentsTable> {
  $$KanyuRuleDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanyuRuleDocumentsTableAnnotationComposer
    extends Composer<_$KanyuDatabase, $KanyuRuleDocumentsTable> {
  $$KanyuRuleDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$KanyuRuleDocumentsTableTableManager
    extends
        RootTableManager<
          _$KanyuDatabase,
          $KanyuRuleDocumentsTable,
          KanyuRuleDocumentEntry,
          $$KanyuRuleDocumentsTableFilterComposer,
          $$KanyuRuleDocumentsTableOrderingComposer,
          $$KanyuRuleDocumentsTableAnnotationComposer,
          $$KanyuRuleDocumentsTableCreateCompanionBuilder,
          $$KanyuRuleDocumentsTableUpdateCompanionBuilder,
          (
            KanyuRuleDocumentEntry,
            BaseReferences<
              _$KanyuDatabase,
              $KanyuRuleDocumentsTable,
              KanyuRuleDocumentEntry
            >,
          ),
          KanyuRuleDocumentEntry,
          PrefetchHooks Function()
        > {
  $$KanyuRuleDocumentsTableTableManager(
    _$KanyuDatabase db,
    $KanyuRuleDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanyuRuleDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanyuRuleDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanyuRuleDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanyuRuleDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => KanyuRuleDocumentsCompanion.insert(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanyuRuleDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$KanyuDatabase,
      $KanyuRuleDocumentsTable,
      KanyuRuleDocumentEntry,
      $$KanyuRuleDocumentsTableFilterComposer,
      $$KanyuRuleDocumentsTableOrderingComposer,
      $$KanyuRuleDocumentsTableAnnotationComposer,
      $$KanyuRuleDocumentsTableCreateCompanionBuilder,
      $$KanyuRuleDocumentsTableUpdateCompanionBuilder,
      (
        KanyuRuleDocumentEntry,
        BaseReferences<
          _$KanyuDatabase,
          $KanyuRuleDocumentsTable,
          KanyuRuleDocumentEntry
        >,
      ),
      KanyuRuleDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$KanyuStaticDataDocumentsTableCreateCompanionBuilder =
    KanyuStaticDataDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$KanyuStaticDataDocumentsTableUpdateCompanionBuilder =
    KanyuStaticDataDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$KanyuStaticDataDocumentsTableFilterComposer
    extends Composer<_$KanyuDatabase, $KanyuStaticDataDocumentsTable> {
  $$KanyuStaticDataDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanyuStaticDataDocumentsTableOrderingComposer
    extends Composer<_$KanyuDatabase, $KanyuStaticDataDocumentsTable> {
  $$KanyuStaticDataDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanyuStaticDataDocumentsTableAnnotationComposer
    extends Composer<_$KanyuDatabase, $KanyuStaticDataDocumentsTable> {
  $$KanyuStaticDataDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$KanyuStaticDataDocumentsTableTableManager
    extends
        RootTableManager<
          _$KanyuDatabase,
          $KanyuStaticDataDocumentsTable,
          KanyuStaticDataDocumentEntry,
          $$KanyuStaticDataDocumentsTableFilterComposer,
          $$KanyuStaticDataDocumentsTableOrderingComposer,
          $$KanyuStaticDataDocumentsTableAnnotationComposer,
          $$KanyuStaticDataDocumentsTableCreateCompanionBuilder,
          $$KanyuStaticDataDocumentsTableUpdateCompanionBuilder,
          (
            KanyuStaticDataDocumentEntry,
            BaseReferences<
              _$KanyuDatabase,
              $KanyuStaticDataDocumentsTable,
              KanyuStaticDataDocumentEntry
            >,
          ),
          KanyuStaticDataDocumentEntry,
          PrefetchHooks Function()
        > {
  $$KanyuStaticDataDocumentsTableTableManager(
    _$KanyuDatabase db,
    $KanyuStaticDataDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanyuStaticDataDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$KanyuStaticDataDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$KanyuStaticDataDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanyuStaticDataDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => KanyuStaticDataDocumentsCompanion.insert(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanyuStaticDataDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$KanyuDatabase,
      $KanyuStaticDataDocumentsTable,
      KanyuStaticDataDocumentEntry,
      $$KanyuStaticDataDocumentsTableFilterComposer,
      $$KanyuStaticDataDocumentsTableOrderingComposer,
      $$KanyuStaticDataDocumentsTableAnnotationComposer,
      $$KanyuStaticDataDocumentsTableCreateCompanionBuilder,
      $$KanyuStaticDataDocumentsTableUpdateCompanionBuilder,
      (
        KanyuStaticDataDocumentEntry,
        BaseReferences<
          _$KanyuDatabase,
          $KanyuStaticDataDocumentsTable,
          KanyuStaticDataDocumentEntry
        >,
      ),
      KanyuStaticDataDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$KanyuSchemaDocumentsTableCreateCompanionBuilder =
    KanyuSchemaDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$KanyuSchemaDocumentsTableUpdateCompanionBuilder =
    KanyuSchemaDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$KanyuSchemaDocumentsTableFilterComposer
    extends Composer<_$KanyuDatabase, $KanyuSchemaDocumentsTable> {
  $$KanyuSchemaDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanyuSchemaDocumentsTableOrderingComposer
    extends Composer<_$KanyuDatabase, $KanyuSchemaDocumentsTable> {
  $$KanyuSchemaDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanyuSchemaDocumentsTableAnnotationComposer
    extends Composer<_$KanyuDatabase, $KanyuSchemaDocumentsTable> {
  $$KanyuSchemaDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$KanyuSchemaDocumentsTableTableManager
    extends
        RootTableManager<
          _$KanyuDatabase,
          $KanyuSchemaDocumentsTable,
          KanyuSchemaDocumentEntry,
          $$KanyuSchemaDocumentsTableFilterComposer,
          $$KanyuSchemaDocumentsTableOrderingComposer,
          $$KanyuSchemaDocumentsTableAnnotationComposer,
          $$KanyuSchemaDocumentsTableCreateCompanionBuilder,
          $$KanyuSchemaDocumentsTableUpdateCompanionBuilder,
          (
            KanyuSchemaDocumentEntry,
            BaseReferences<
              _$KanyuDatabase,
              $KanyuSchemaDocumentsTable,
              KanyuSchemaDocumentEntry
            >,
          ),
          KanyuSchemaDocumentEntry,
          PrefetchHooks Function()
        > {
  $$KanyuSchemaDocumentsTableTableManager(
    _$KanyuDatabase db,
    $KanyuSchemaDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanyuSchemaDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanyuSchemaDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$KanyuSchemaDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanyuSchemaDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => KanyuSchemaDocumentsCompanion.insert(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanyuSchemaDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$KanyuDatabase,
      $KanyuSchemaDocumentsTable,
      KanyuSchemaDocumentEntry,
      $$KanyuSchemaDocumentsTableFilterComposer,
      $$KanyuSchemaDocumentsTableOrderingComposer,
      $$KanyuSchemaDocumentsTableAnnotationComposer,
      $$KanyuSchemaDocumentsTableCreateCompanionBuilder,
      $$KanyuSchemaDocumentsTableUpdateCompanionBuilder,
      (
        KanyuSchemaDocumentEntry,
        BaseReferences<
          _$KanyuDatabase,
          $KanyuSchemaDocumentsTable,
          KanyuSchemaDocumentEntry
        >,
      ),
      KanyuSchemaDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$KanyuDatasetGenerationsTableCreateCompanionBuilder =
    KanyuDatasetGenerationsCompanion Function({
      required String datasetId,
      required int generation,
      required String payloadSha256,
      required int payloadBytes,
      Value<int?> declaredRowCount,
      required String status,
      required String sourceId,
      Value<DateTime?> installedAtUtc,
      Value<int> rowid,
    });
typedef $$KanyuDatasetGenerationsTableUpdateCompanionBuilder =
    KanyuDatasetGenerationsCompanion Function({
      Value<String> datasetId,
      Value<int> generation,
      Value<String> payloadSha256,
      Value<int> payloadBytes,
      Value<int?> declaredRowCount,
      Value<String> status,
      Value<String> sourceId,
      Value<DateTime?> installedAtUtc,
      Value<int> rowid,
    });

class $$KanyuDatasetGenerationsTableFilterComposer
    extends Composer<_$KanyuDatabase, $KanyuDatasetGenerationsTable> {
  $$KanyuDatasetGenerationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get datasetId => $composableBuilder(
    column: $table.datasetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadBytes => $composableBuilder(
    column: $table.payloadBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get declaredRowCount => $composableBuilder(
    column: $table.declaredRowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAtUtc => $composableBuilder(
    column: $table.installedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanyuDatasetGenerationsTableOrderingComposer
    extends Composer<_$KanyuDatabase, $KanyuDatasetGenerationsTable> {
  $$KanyuDatasetGenerationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get datasetId => $composableBuilder(
    column: $table.datasetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadBytes => $composableBuilder(
    column: $table.payloadBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get declaredRowCount => $composableBuilder(
    column: $table.declaredRowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAtUtc => $composableBuilder(
    column: $table.installedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanyuDatasetGenerationsTableAnnotationComposer
    extends Composer<_$KanyuDatabase, $KanyuDatasetGenerationsTable> {
  $$KanyuDatasetGenerationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get datasetId =>
      $composableBuilder(column: $table.datasetId, builder: (column) => column);

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadBytes => $composableBuilder(
    column: $table.payloadBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get declaredRowCount => $composableBuilder(
    column: $table.declaredRowCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAtUtc => $composableBuilder(
    column: $table.installedAtUtc,
    builder: (column) => column,
  );
}

class $$KanyuDatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$KanyuDatabase,
          $KanyuDatasetGenerationsTable,
          KanyuDatasetGenerationEntry,
          $$KanyuDatasetGenerationsTableFilterComposer,
          $$KanyuDatasetGenerationsTableOrderingComposer,
          $$KanyuDatasetGenerationsTableAnnotationComposer,
          $$KanyuDatasetGenerationsTableCreateCompanionBuilder,
          $$KanyuDatasetGenerationsTableUpdateCompanionBuilder,
          (
            KanyuDatasetGenerationEntry,
            BaseReferences<
              _$KanyuDatabase,
              $KanyuDatasetGenerationsTable,
              KanyuDatasetGenerationEntry
            >,
          ),
          KanyuDatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$KanyuDatasetGenerationsTableTableManager(
    _$KanyuDatabase db,
    $KanyuDatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanyuDatasetGenerationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$KanyuDatasetGenerationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$KanyuDatasetGenerationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> datasetId = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<String> payloadSha256 = const Value.absent(),
                Value<int> payloadBytes = const Value.absent(),
                Value<int?> declaredRowCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<DateTime?> installedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanyuDatasetGenerationsCompanion(
                datasetId: datasetId,
                generation: generation,
                payloadSha256: payloadSha256,
                payloadBytes: payloadBytes,
                declaredRowCount: declaredRowCount,
                status: status,
                sourceId: sourceId,
                installedAtUtc: installedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String datasetId,
                required int generation,
                required String payloadSha256,
                required int payloadBytes,
                Value<int?> declaredRowCount = const Value.absent(),
                required String status,
                required String sourceId,
                Value<DateTime?> installedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanyuDatasetGenerationsCompanion.insert(
                datasetId: datasetId,
                generation: generation,
                payloadSha256: payloadSha256,
                payloadBytes: payloadBytes,
                declaredRowCount: declaredRowCount,
                status: status,
                sourceId: sourceId,
                installedAtUtc: installedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanyuDatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$KanyuDatabase,
      $KanyuDatasetGenerationsTable,
      KanyuDatasetGenerationEntry,
      $$KanyuDatasetGenerationsTableFilterComposer,
      $$KanyuDatasetGenerationsTableOrderingComposer,
      $$KanyuDatasetGenerationsTableAnnotationComposer,
      $$KanyuDatasetGenerationsTableCreateCompanionBuilder,
      $$KanyuDatasetGenerationsTableUpdateCompanionBuilder,
      (
        KanyuDatasetGenerationEntry,
        BaseReferences<
          _$KanyuDatabase,
          $KanyuDatasetGenerationsTable,
          KanyuDatasetGenerationEntry
        >,
      ),
      KanyuDatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $KanyuDatabaseManager {
  final _$KanyuDatabase _db;
  $KanyuDatabaseManager(this._db);
  $$KanyuRuleDocumentsTableTableManager get kanyuRuleDocuments =>
      $$KanyuRuleDocumentsTableTableManager(_db, _db.kanyuRuleDocuments);
  $$KanyuStaticDataDocumentsTableTableManager get kanyuStaticDataDocuments =>
      $$KanyuStaticDataDocumentsTableTableManager(
        _db,
        _db.kanyuStaticDataDocuments,
      );
  $$KanyuSchemaDocumentsTableTableManager get kanyuSchemaDocuments =>
      $$KanyuSchemaDocumentsTableTableManager(_db, _db.kanyuSchemaDocuments);
  $$KanyuDatasetGenerationsTableTableManager get kanyuDatasetGenerations =>
      $$KanyuDatasetGenerationsTableTableManager(
        _db,
        _db.kanyuDatasetGenerations,
      );
}
