// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'four_zhu_database.dart';

// ignore_for_file: type=lint
class $FourZhuDefaultTemplateDocumentsTable
    extends FourZhuDefaultTemplateDocuments
    with
        TableInfo<
          $FourZhuDefaultTemplateDocumentsTable,
          FourZhuDefaultTemplateDocumentEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FourZhuDefaultTemplateDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'default_template_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<FourZhuDefaultTemplateDocumentEntry> instance, {
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
  FourZhuDefaultTemplateDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FourZhuDefaultTemplateDocumentEntry(
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
  $FourZhuDefaultTemplateDocumentsTable createAlias(String alias) {
    return $FourZhuDefaultTemplateDocumentsTable(attachedDatabase, alias);
  }
}

class FourZhuDefaultTemplateDocumentEntry extends DataClass
    implements Insertable<FourZhuDefaultTemplateDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const FourZhuDefaultTemplateDocumentEntry({
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

  FourZhuDefaultTemplateDocumentsCompanion toCompanion(bool nullToAbsent) {
    return FourZhuDefaultTemplateDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory FourZhuDefaultTemplateDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FourZhuDefaultTemplateDocumentEntry(
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

  FourZhuDefaultTemplateDocumentEntry copyWith({
    String? fileName,
    String? payloadJson,
  }) => FourZhuDefaultTemplateDocumentEntry(
    fileName: fileName ?? this.fileName,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  FourZhuDefaultTemplateDocumentEntry copyWithCompanion(
    FourZhuDefaultTemplateDocumentsCompanion data,
  ) {
    return FourZhuDefaultTemplateDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FourZhuDefaultTemplateDocumentEntry(')
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
      (other is FourZhuDefaultTemplateDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class FourZhuDefaultTemplateDocumentsCompanion
    extends UpdateCompanion<FourZhuDefaultTemplateDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const FourZhuDefaultTemplateDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FourZhuDefaultTemplateDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<FourZhuDefaultTemplateDocumentEntry> custom({
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

  FourZhuDefaultTemplateDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return FourZhuDefaultTemplateDocumentsCompanion(
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
    return (StringBuffer('FourZhuDefaultTemplateDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FourZhuMarketTemplatesDocumentsTable
    extends FourZhuMarketTemplatesDocuments
    with
        TableInfo<
          $FourZhuMarketTemplatesDocumentsTable,
          FourZhuMarketTemplatesDocumentEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FourZhuMarketTemplatesDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'market_templates_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<FourZhuMarketTemplatesDocumentEntry> instance, {
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
  FourZhuMarketTemplatesDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FourZhuMarketTemplatesDocumentEntry(
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
  $FourZhuMarketTemplatesDocumentsTable createAlias(String alias) {
    return $FourZhuMarketTemplatesDocumentsTable(attachedDatabase, alias);
  }
}

class FourZhuMarketTemplatesDocumentEntry extends DataClass
    implements Insertable<FourZhuMarketTemplatesDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const FourZhuMarketTemplatesDocumentEntry({
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

  FourZhuMarketTemplatesDocumentsCompanion toCompanion(bool nullToAbsent) {
    return FourZhuMarketTemplatesDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory FourZhuMarketTemplatesDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FourZhuMarketTemplatesDocumentEntry(
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

  FourZhuMarketTemplatesDocumentEntry copyWith({
    String? fileName,
    String? payloadJson,
  }) => FourZhuMarketTemplatesDocumentEntry(
    fileName: fileName ?? this.fileName,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  FourZhuMarketTemplatesDocumentEntry copyWithCompanion(
    FourZhuMarketTemplatesDocumentsCompanion data,
  ) {
    return FourZhuMarketTemplatesDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FourZhuMarketTemplatesDocumentEntry(')
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
      (other is FourZhuMarketTemplatesDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class FourZhuMarketTemplatesDocumentsCompanion
    extends UpdateCompanion<FourZhuMarketTemplatesDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const FourZhuMarketTemplatesDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FourZhuMarketTemplatesDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<FourZhuMarketTemplatesDocumentEntry> custom({
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

  FourZhuMarketTemplatesDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return FourZhuMarketTemplatesDocumentsCompanion(
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
    return (StringBuffer('FourZhuMarketTemplatesDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FourZhuOutboxTemplatesDocumentsTable
    extends FourZhuOutboxTemplatesDocuments
    with
        TableInfo<
          $FourZhuOutboxTemplatesDocumentsTable,
          FourZhuOutboxTemplatesDocumentEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FourZhuOutboxTemplatesDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'outbox_templates_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<FourZhuOutboxTemplatesDocumentEntry> instance, {
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
  FourZhuOutboxTemplatesDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FourZhuOutboxTemplatesDocumentEntry(
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
  $FourZhuOutboxTemplatesDocumentsTable createAlias(String alias) {
    return $FourZhuOutboxTemplatesDocumentsTable(attachedDatabase, alias);
  }
}

class FourZhuOutboxTemplatesDocumentEntry extends DataClass
    implements Insertable<FourZhuOutboxTemplatesDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const FourZhuOutboxTemplatesDocumentEntry({
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

  FourZhuOutboxTemplatesDocumentsCompanion toCompanion(bool nullToAbsent) {
    return FourZhuOutboxTemplatesDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory FourZhuOutboxTemplatesDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FourZhuOutboxTemplatesDocumentEntry(
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

  FourZhuOutboxTemplatesDocumentEntry copyWith({
    String? fileName,
    String? payloadJson,
  }) => FourZhuOutboxTemplatesDocumentEntry(
    fileName: fileName ?? this.fileName,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  FourZhuOutboxTemplatesDocumentEntry copyWithCompanion(
    FourZhuOutboxTemplatesDocumentsCompanion data,
  ) {
    return FourZhuOutboxTemplatesDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FourZhuOutboxTemplatesDocumentEntry(')
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
      (other is FourZhuOutboxTemplatesDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class FourZhuOutboxTemplatesDocumentsCompanion
    extends UpdateCompanion<FourZhuOutboxTemplatesDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const FourZhuOutboxTemplatesDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FourZhuOutboxTemplatesDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<FourZhuOutboxTemplatesDocumentEntry> custom({
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

  FourZhuOutboxTemplatesDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return FourZhuOutboxTemplatesDocumentsCompanion(
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
    return (StringBuffer('FourZhuOutboxTemplatesDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FourZhuDatasetGenerationsTable extends FourZhuDatasetGenerations
    with
        TableInfo<
          $FourZhuDatasetGenerationsTable,
          FourZhuDatasetGenerationEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FourZhuDatasetGenerationsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<FourZhuDatasetGenerationEntry> instance, {
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
  FourZhuDatasetGenerationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FourZhuDatasetGenerationEntry(
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
  $FourZhuDatasetGenerationsTable createAlias(String alias) {
    return $FourZhuDatasetGenerationsTable(attachedDatabase, alias);
  }
}

class FourZhuDatasetGenerationEntry extends DataClass
    implements Insertable<FourZhuDatasetGenerationEntry> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const FourZhuDatasetGenerationEntry({
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

  FourZhuDatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return FourZhuDatasetGenerationsCompanion(
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

  factory FourZhuDatasetGenerationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FourZhuDatasetGenerationEntry(
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

  FourZhuDatasetGenerationEntry copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => FourZhuDatasetGenerationEntry(
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
  FourZhuDatasetGenerationEntry copyWithCompanion(
    FourZhuDatasetGenerationsCompanion data,
  ) {
    return FourZhuDatasetGenerationEntry(
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
    return (StringBuffer('FourZhuDatasetGenerationEntry(')
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
      (other is FourZhuDatasetGenerationEntry &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class FourZhuDatasetGenerationsCompanion
    extends UpdateCompanion<FourZhuDatasetGenerationEntry> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const FourZhuDatasetGenerationsCompanion({
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
  FourZhuDatasetGenerationsCompanion.insert({
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
  static Insertable<FourZhuDatasetGenerationEntry> custom({
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

  FourZhuDatasetGenerationsCompanion copyWith({
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
    return FourZhuDatasetGenerationsCompanion(
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
    return (StringBuffer('FourZhuDatasetGenerationsCompanion(')
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

abstract class _$FourZhuDatabase extends GeneratedDatabase {
  _$FourZhuDatabase(QueryExecutor e) : super(e);
  $FourZhuDatabaseManager get managers => $FourZhuDatabaseManager(this);
  late final $FourZhuDefaultTemplateDocumentsTable
  fourZhuDefaultTemplateDocuments = $FourZhuDefaultTemplateDocumentsTable(this);
  late final $FourZhuMarketTemplatesDocumentsTable
  fourZhuMarketTemplatesDocuments = $FourZhuMarketTemplatesDocumentsTable(this);
  late final $FourZhuOutboxTemplatesDocumentsTable
  fourZhuOutboxTemplatesDocuments = $FourZhuOutboxTemplatesDocumentsTable(this);
  late final $FourZhuDatasetGenerationsTable fourZhuDatasetGenerations =
      $FourZhuDatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    fourZhuDefaultTemplateDocuments,
    fourZhuMarketTemplatesDocuments,
    fourZhuOutboxTemplatesDocuments,
    fourZhuDatasetGenerations,
  ];
}

typedef $$FourZhuDefaultTemplateDocumentsTableCreateCompanionBuilder =
    FourZhuDefaultTemplateDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$FourZhuDefaultTemplateDocumentsTableUpdateCompanionBuilder =
    FourZhuDefaultTemplateDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$FourZhuDefaultTemplateDocumentsTableFilterComposer
    extends Composer<_$FourZhuDatabase, $FourZhuDefaultTemplateDocumentsTable> {
  $$FourZhuDefaultTemplateDocumentsTableFilterComposer({
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

class $$FourZhuDefaultTemplateDocumentsTableOrderingComposer
    extends Composer<_$FourZhuDatabase, $FourZhuDefaultTemplateDocumentsTable> {
  $$FourZhuDefaultTemplateDocumentsTableOrderingComposer({
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

class $$FourZhuDefaultTemplateDocumentsTableAnnotationComposer
    extends Composer<_$FourZhuDatabase, $FourZhuDefaultTemplateDocumentsTable> {
  $$FourZhuDefaultTemplateDocumentsTableAnnotationComposer({
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

class $$FourZhuDefaultTemplateDocumentsTableTableManager
    extends
        RootTableManager<
          _$FourZhuDatabase,
          $FourZhuDefaultTemplateDocumentsTable,
          FourZhuDefaultTemplateDocumentEntry,
          $$FourZhuDefaultTemplateDocumentsTableFilterComposer,
          $$FourZhuDefaultTemplateDocumentsTableOrderingComposer,
          $$FourZhuDefaultTemplateDocumentsTableAnnotationComposer,
          $$FourZhuDefaultTemplateDocumentsTableCreateCompanionBuilder,
          $$FourZhuDefaultTemplateDocumentsTableUpdateCompanionBuilder,
          (
            FourZhuDefaultTemplateDocumentEntry,
            BaseReferences<
              _$FourZhuDatabase,
              $FourZhuDefaultTemplateDocumentsTable,
              FourZhuDefaultTemplateDocumentEntry
            >,
          ),
          FourZhuDefaultTemplateDocumentEntry,
          PrefetchHooks Function()
        > {
  $$FourZhuDefaultTemplateDocumentsTableTableManager(
    _$FourZhuDatabase db,
    $FourZhuDefaultTemplateDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FourZhuDefaultTemplateDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FourZhuDefaultTemplateDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FourZhuDefaultTemplateDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FourZhuDefaultTemplateDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => FourZhuDefaultTemplateDocumentsCompanion.insert(
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

typedef $$FourZhuDefaultTemplateDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$FourZhuDatabase,
      $FourZhuDefaultTemplateDocumentsTable,
      FourZhuDefaultTemplateDocumentEntry,
      $$FourZhuDefaultTemplateDocumentsTableFilterComposer,
      $$FourZhuDefaultTemplateDocumentsTableOrderingComposer,
      $$FourZhuDefaultTemplateDocumentsTableAnnotationComposer,
      $$FourZhuDefaultTemplateDocumentsTableCreateCompanionBuilder,
      $$FourZhuDefaultTemplateDocumentsTableUpdateCompanionBuilder,
      (
        FourZhuDefaultTemplateDocumentEntry,
        BaseReferences<
          _$FourZhuDatabase,
          $FourZhuDefaultTemplateDocumentsTable,
          FourZhuDefaultTemplateDocumentEntry
        >,
      ),
      FourZhuDefaultTemplateDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$FourZhuMarketTemplatesDocumentsTableCreateCompanionBuilder =
    FourZhuMarketTemplatesDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$FourZhuMarketTemplatesDocumentsTableUpdateCompanionBuilder =
    FourZhuMarketTemplatesDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$FourZhuMarketTemplatesDocumentsTableFilterComposer
    extends Composer<_$FourZhuDatabase, $FourZhuMarketTemplatesDocumentsTable> {
  $$FourZhuMarketTemplatesDocumentsTableFilterComposer({
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

class $$FourZhuMarketTemplatesDocumentsTableOrderingComposer
    extends Composer<_$FourZhuDatabase, $FourZhuMarketTemplatesDocumentsTable> {
  $$FourZhuMarketTemplatesDocumentsTableOrderingComposer({
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

class $$FourZhuMarketTemplatesDocumentsTableAnnotationComposer
    extends Composer<_$FourZhuDatabase, $FourZhuMarketTemplatesDocumentsTable> {
  $$FourZhuMarketTemplatesDocumentsTableAnnotationComposer({
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

class $$FourZhuMarketTemplatesDocumentsTableTableManager
    extends
        RootTableManager<
          _$FourZhuDatabase,
          $FourZhuMarketTemplatesDocumentsTable,
          FourZhuMarketTemplatesDocumentEntry,
          $$FourZhuMarketTemplatesDocumentsTableFilterComposer,
          $$FourZhuMarketTemplatesDocumentsTableOrderingComposer,
          $$FourZhuMarketTemplatesDocumentsTableAnnotationComposer,
          $$FourZhuMarketTemplatesDocumentsTableCreateCompanionBuilder,
          $$FourZhuMarketTemplatesDocumentsTableUpdateCompanionBuilder,
          (
            FourZhuMarketTemplatesDocumentEntry,
            BaseReferences<
              _$FourZhuDatabase,
              $FourZhuMarketTemplatesDocumentsTable,
              FourZhuMarketTemplatesDocumentEntry
            >,
          ),
          FourZhuMarketTemplatesDocumentEntry,
          PrefetchHooks Function()
        > {
  $$FourZhuMarketTemplatesDocumentsTableTableManager(
    _$FourZhuDatabase db,
    $FourZhuMarketTemplatesDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FourZhuMarketTemplatesDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FourZhuMarketTemplatesDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FourZhuMarketTemplatesDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FourZhuMarketTemplatesDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => FourZhuMarketTemplatesDocumentsCompanion.insert(
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

typedef $$FourZhuMarketTemplatesDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$FourZhuDatabase,
      $FourZhuMarketTemplatesDocumentsTable,
      FourZhuMarketTemplatesDocumentEntry,
      $$FourZhuMarketTemplatesDocumentsTableFilterComposer,
      $$FourZhuMarketTemplatesDocumentsTableOrderingComposer,
      $$FourZhuMarketTemplatesDocumentsTableAnnotationComposer,
      $$FourZhuMarketTemplatesDocumentsTableCreateCompanionBuilder,
      $$FourZhuMarketTemplatesDocumentsTableUpdateCompanionBuilder,
      (
        FourZhuMarketTemplatesDocumentEntry,
        BaseReferences<
          _$FourZhuDatabase,
          $FourZhuMarketTemplatesDocumentsTable,
          FourZhuMarketTemplatesDocumentEntry
        >,
      ),
      FourZhuMarketTemplatesDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$FourZhuOutboxTemplatesDocumentsTableCreateCompanionBuilder =
    FourZhuOutboxTemplatesDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$FourZhuOutboxTemplatesDocumentsTableUpdateCompanionBuilder =
    FourZhuOutboxTemplatesDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$FourZhuOutboxTemplatesDocumentsTableFilterComposer
    extends Composer<_$FourZhuDatabase, $FourZhuOutboxTemplatesDocumentsTable> {
  $$FourZhuOutboxTemplatesDocumentsTableFilterComposer({
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

class $$FourZhuOutboxTemplatesDocumentsTableOrderingComposer
    extends Composer<_$FourZhuDatabase, $FourZhuOutboxTemplatesDocumentsTable> {
  $$FourZhuOutboxTemplatesDocumentsTableOrderingComposer({
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

class $$FourZhuOutboxTemplatesDocumentsTableAnnotationComposer
    extends Composer<_$FourZhuDatabase, $FourZhuOutboxTemplatesDocumentsTable> {
  $$FourZhuOutboxTemplatesDocumentsTableAnnotationComposer({
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

class $$FourZhuOutboxTemplatesDocumentsTableTableManager
    extends
        RootTableManager<
          _$FourZhuDatabase,
          $FourZhuOutboxTemplatesDocumentsTable,
          FourZhuOutboxTemplatesDocumentEntry,
          $$FourZhuOutboxTemplatesDocumentsTableFilterComposer,
          $$FourZhuOutboxTemplatesDocumentsTableOrderingComposer,
          $$FourZhuOutboxTemplatesDocumentsTableAnnotationComposer,
          $$FourZhuOutboxTemplatesDocumentsTableCreateCompanionBuilder,
          $$FourZhuOutboxTemplatesDocumentsTableUpdateCompanionBuilder,
          (
            FourZhuOutboxTemplatesDocumentEntry,
            BaseReferences<
              _$FourZhuDatabase,
              $FourZhuOutboxTemplatesDocumentsTable,
              FourZhuOutboxTemplatesDocumentEntry
            >,
          ),
          FourZhuOutboxTemplatesDocumentEntry,
          PrefetchHooks Function()
        > {
  $$FourZhuOutboxTemplatesDocumentsTableTableManager(
    _$FourZhuDatabase db,
    $FourZhuOutboxTemplatesDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FourZhuOutboxTemplatesDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FourZhuOutboxTemplatesDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FourZhuOutboxTemplatesDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FourZhuOutboxTemplatesDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => FourZhuOutboxTemplatesDocumentsCompanion.insert(
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

typedef $$FourZhuOutboxTemplatesDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$FourZhuDatabase,
      $FourZhuOutboxTemplatesDocumentsTable,
      FourZhuOutboxTemplatesDocumentEntry,
      $$FourZhuOutboxTemplatesDocumentsTableFilterComposer,
      $$FourZhuOutboxTemplatesDocumentsTableOrderingComposer,
      $$FourZhuOutboxTemplatesDocumentsTableAnnotationComposer,
      $$FourZhuOutboxTemplatesDocumentsTableCreateCompanionBuilder,
      $$FourZhuOutboxTemplatesDocumentsTableUpdateCompanionBuilder,
      (
        FourZhuOutboxTemplatesDocumentEntry,
        BaseReferences<
          _$FourZhuDatabase,
          $FourZhuOutboxTemplatesDocumentsTable,
          FourZhuOutboxTemplatesDocumentEntry
        >,
      ),
      FourZhuOutboxTemplatesDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$FourZhuDatasetGenerationsTableCreateCompanionBuilder =
    FourZhuDatasetGenerationsCompanion Function({
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
typedef $$FourZhuDatasetGenerationsTableUpdateCompanionBuilder =
    FourZhuDatasetGenerationsCompanion Function({
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

class $$FourZhuDatasetGenerationsTableFilterComposer
    extends Composer<_$FourZhuDatabase, $FourZhuDatasetGenerationsTable> {
  $$FourZhuDatasetGenerationsTableFilterComposer({
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

class $$FourZhuDatasetGenerationsTableOrderingComposer
    extends Composer<_$FourZhuDatabase, $FourZhuDatasetGenerationsTable> {
  $$FourZhuDatasetGenerationsTableOrderingComposer({
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

class $$FourZhuDatasetGenerationsTableAnnotationComposer
    extends Composer<_$FourZhuDatabase, $FourZhuDatasetGenerationsTable> {
  $$FourZhuDatasetGenerationsTableAnnotationComposer({
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

class $$FourZhuDatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$FourZhuDatabase,
          $FourZhuDatasetGenerationsTable,
          FourZhuDatasetGenerationEntry,
          $$FourZhuDatasetGenerationsTableFilterComposer,
          $$FourZhuDatasetGenerationsTableOrderingComposer,
          $$FourZhuDatasetGenerationsTableAnnotationComposer,
          $$FourZhuDatasetGenerationsTableCreateCompanionBuilder,
          $$FourZhuDatasetGenerationsTableUpdateCompanionBuilder,
          (
            FourZhuDatasetGenerationEntry,
            BaseReferences<
              _$FourZhuDatabase,
              $FourZhuDatasetGenerationsTable,
              FourZhuDatasetGenerationEntry
            >,
          ),
          FourZhuDatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$FourZhuDatasetGenerationsTableTableManager(
    _$FourZhuDatabase db,
    $FourZhuDatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FourZhuDatasetGenerationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FourZhuDatasetGenerationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FourZhuDatasetGenerationsTableAnnotationComposer(
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
              }) => FourZhuDatasetGenerationsCompanion(
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
              }) => FourZhuDatasetGenerationsCompanion.insert(
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

typedef $$FourZhuDatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$FourZhuDatabase,
      $FourZhuDatasetGenerationsTable,
      FourZhuDatasetGenerationEntry,
      $$FourZhuDatasetGenerationsTableFilterComposer,
      $$FourZhuDatasetGenerationsTableOrderingComposer,
      $$FourZhuDatasetGenerationsTableAnnotationComposer,
      $$FourZhuDatasetGenerationsTableCreateCompanionBuilder,
      $$FourZhuDatasetGenerationsTableUpdateCompanionBuilder,
      (
        FourZhuDatasetGenerationEntry,
        BaseReferences<
          _$FourZhuDatabase,
          $FourZhuDatasetGenerationsTable,
          FourZhuDatasetGenerationEntry
        >,
      ),
      FourZhuDatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $FourZhuDatabaseManager {
  final _$FourZhuDatabase _db;
  $FourZhuDatabaseManager(this._db);
  $$FourZhuDefaultTemplateDocumentsTableTableManager
  get fourZhuDefaultTemplateDocuments =>
      $$FourZhuDefaultTemplateDocumentsTableTableManager(
        _db,
        _db.fourZhuDefaultTemplateDocuments,
      );
  $$FourZhuMarketTemplatesDocumentsTableTableManager
  get fourZhuMarketTemplatesDocuments =>
      $$FourZhuMarketTemplatesDocumentsTableTableManager(
        _db,
        _db.fourZhuMarketTemplatesDocuments,
      );
  $$FourZhuOutboxTemplatesDocumentsTableTableManager
  get fourZhuOutboxTemplatesDocuments =>
      $$FourZhuOutboxTemplatesDocumentsTableTableManager(
        _db,
        _db.fourZhuOutboxTemplatesDocuments,
      );
  $$FourZhuDatasetGenerationsTableTableManager get fourZhuDatasetGenerations =>
      $$FourZhuDatasetGenerationsTableTableManager(
        _db,
        _db.fourZhuDatasetGenerations,
      );
}
