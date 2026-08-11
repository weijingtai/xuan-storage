// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taiyishenshu_database.dart';

// ignore_for_file: type=lint
class $TaiyiSchoolDocumentsTable extends TaiyiSchoolDocuments
    with TableInfo<$TaiyiSchoolDocumentsTable, TaiyiSchoolDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaiyiSchoolDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'schools_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaiyiSchoolDocumentEntry> instance, {
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
  TaiyiSchoolDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaiyiSchoolDocumentEntry(
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
  $TaiyiSchoolDocumentsTable createAlias(String alias) {
    return $TaiyiSchoolDocumentsTable(attachedDatabase, alias);
  }
}

class TaiyiSchoolDocumentEntry extends DataClass
    implements Insertable<TaiyiSchoolDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const TaiyiSchoolDocumentEntry({
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

  TaiyiSchoolDocumentsCompanion toCompanion(bool nullToAbsent) {
    return TaiyiSchoolDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory TaiyiSchoolDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaiyiSchoolDocumentEntry(
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

  TaiyiSchoolDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      TaiyiSchoolDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  TaiyiSchoolDocumentEntry copyWithCompanion(
    TaiyiSchoolDocumentsCompanion data,
  ) {
    return TaiyiSchoolDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaiyiSchoolDocumentEntry(')
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
      (other is TaiyiSchoolDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class TaiyiSchoolDocumentsCompanion
    extends UpdateCompanion<TaiyiSchoolDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const TaiyiSchoolDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaiyiSchoolDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<TaiyiSchoolDocumentEntry> custom({
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

  TaiyiSchoolDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return TaiyiSchoolDocumentsCompanion(
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
    return (StringBuffer('TaiyiSchoolDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaiyiDeityDocumentsTable extends TaiyiDeityDocuments
    with TableInfo<$TaiyiDeityDocumentsTable, TaiyiDeityDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaiyiDeityDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'deities_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaiyiDeityDocumentEntry> instance, {
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
  TaiyiDeityDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaiyiDeityDocumentEntry(
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
  $TaiyiDeityDocumentsTable createAlias(String alias) {
    return $TaiyiDeityDocumentsTable(attachedDatabase, alias);
  }
}

class TaiyiDeityDocumentEntry extends DataClass
    implements Insertable<TaiyiDeityDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const TaiyiDeityDocumentEntry({
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

  TaiyiDeityDocumentsCompanion toCompanion(bool nullToAbsent) {
    return TaiyiDeityDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory TaiyiDeityDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaiyiDeityDocumentEntry(
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

  TaiyiDeityDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      TaiyiDeityDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  TaiyiDeityDocumentEntry copyWithCompanion(TaiyiDeityDocumentsCompanion data) {
    return TaiyiDeityDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaiyiDeityDocumentEntry(')
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
      (other is TaiyiDeityDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class TaiyiDeityDocumentsCompanion
    extends UpdateCompanion<TaiyiDeityDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const TaiyiDeityDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaiyiDeityDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<TaiyiDeityDocumentEntry> custom({
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

  TaiyiDeityDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return TaiyiDeityDocumentsCompanion(
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
    return (StringBuffer('TaiyiDeityDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaiyiMingGuaDocumentsTable extends TaiyiMingGuaDocuments
    with TableInfo<$TaiyiMingGuaDocumentsTable, TaiyiMingGuaDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaiyiMingGuaDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'minggua_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaiyiMingGuaDocumentEntry> instance, {
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
  TaiyiMingGuaDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaiyiMingGuaDocumentEntry(
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
  $TaiyiMingGuaDocumentsTable createAlias(String alias) {
    return $TaiyiMingGuaDocumentsTable(attachedDatabase, alias);
  }
}

class TaiyiMingGuaDocumentEntry extends DataClass
    implements Insertable<TaiyiMingGuaDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const TaiyiMingGuaDocumentEntry({
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

  TaiyiMingGuaDocumentsCompanion toCompanion(bool nullToAbsent) {
    return TaiyiMingGuaDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory TaiyiMingGuaDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaiyiMingGuaDocumentEntry(
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

  TaiyiMingGuaDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      TaiyiMingGuaDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  TaiyiMingGuaDocumentEntry copyWithCompanion(
    TaiyiMingGuaDocumentsCompanion data,
  ) {
    return TaiyiMingGuaDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaiyiMingGuaDocumentEntry(')
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
      (other is TaiyiMingGuaDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class TaiyiMingGuaDocumentsCompanion
    extends UpdateCompanion<TaiyiMingGuaDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const TaiyiMingGuaDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaiyiMingGuaDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<TaiyiMingGuaDocumentEntry> custom({
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

  TaiyiMingGuaDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return TaiyiMingGuaDocumentsCompanion(
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
    return (StringBuffer('TaiyiMingGuaDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaiyiDatasetGenerationsTable extends TaiyiDatasetGenerations
    with TableInfo<$TaiyiDatasetGenerationsTable, TaiyiDatasetGenerationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaiyiDatasetGenerationsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<TaiyiDatasetGenerationEntry> instance, {
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
  TaiyiDatasetGenerationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaiyiDatasetGenerationEntry(
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
  $TaiyiDatasetGenerationsTable createAlias(String alias) {
    return $TaiyiDatasetGenerationsTable(attachedDatabase, alias);
  }
}

class TaiyiDatasetGenerationEntry extends DataClass
    implements Insertable<TaiyiDatasetGenerationEntry> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const TaiyiDatasetGenerationEntry({
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

  TaiyiDatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return TaiyiDatasetGenerationsCompanion(
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

  factory TaiyiDatasetGenerationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaiyiDatasetGenerationEntry(
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

  TaiyiDatasetGenerationEntry copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => TaiyiDatasetGenerationEntry(
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
  TaiyiDatasetGenerationEntry copyWithCompanion(
    TaiyiDatasetGenerationsCompanion data,
  ) {
    return TaiyiDatasetGenerationEntry(
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
    return (StringBuffer('TaiyiDatasetGenerationEntry(')
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
      (other is TaiyiDatasetGenerationEntry &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class TaiyiDatasetGenerationsCompanion
    extends UpdateCompanion<TaiyiDatasetGenerationEntry> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const TaiyiDatasetGenerationsCompanion({
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
  TaiyiDatasetGenerationsCompanion.insert({
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
  static Insertable<TaiyiDatasetGenerationEntry> custom({
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

  TaiyiDatasetGenerationsCompanion copyWith({
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
    return TaiyiDatasetGenerationsCompanion(
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
    return (StringBuffer('TaiyiDatasetGenerationsCompanion(')
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

abstract class _$TaiyishenshuDatabase extends GeneratedDatabase {
  _$TaiyishenshuDatabase(QueryExecutor e) : super(e);
  $TaiyishenshuDatabaseManager get managers =>
      $TaiyishenshuDatabaseManager(this);
  late final $TaiyiSchoolDocumentsTable taiyiSchoolDocuments =
      $TaiyiSchoolDocumentsTable(this);
  late final $TaiyiDeityDocumentsTable taiyiDeityDocuments =
      $TaiyiDeityDocumentsTable(this);
  late final $TaiyiMingGuaDocumentsTable taiyiMingGuaDocuments =
      $TaiyiMingGuaDocumentsTable(this);
  late final $TaiyiDatasetGenerationsTable taiyiDatasetGenerations =
      $TaiyiDatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taiyiSchoolDocuments,
    taiyiDeityDocuments,
    taiyiMingGuaDocuments,
    taiyiDatasetGenerations,
  ];
}

typedef $$TaiyiSchoolDocumentsTableCreateCompanionBuilder =
    TaiyiSchoolDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$TaiyiSchoolDocumentsTableUpdateCompanionBuilder =
    TaiyiSchoolDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$TaiyiSchoolDocumentsTableFilterComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiSchoolDocumentsTable> {
  $$TaiyiSchoolDocumentsTableFilterComposer({
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

class $$TaiyiSchoolDocumentsTableOrderingComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiSchoolDocumentsTable> {
  $$TaiyiSchoolDocumentsTableOrderingComposer({
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

class $$TaiyiSchoolDocumentsTableAnnotationComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiSchoolDocumentsTable> {
  $$TaiyiSchoolDocumentsTableAnnotationComposer({
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

class $$TaiyiSchoolDocumentsTableTableManager
    extends
        RootTableManager<
          _$TaiyishenshuDatabase,
          $TaiyiSchoolDocumentsTable,
          TaiyiSchoolDocumentEntry,
          $$TaiyiSchoolDocumentsTableFilterComposer,
          $$TaiyiSchoolDocumentsTableOrderingComposer,
          $$TaiyiSchoolDocumentsTableAnnotationComposer,
          $$TaiyiSchoolDocumentsTableCreateCompanionBuilder,
          $$TaiyiSchoolDocumentsTableUpdateCompanionBuilder,
          (
            TaiyiSchoolDocumentEntry,
            BaseReferences<
              _$TaiyishenshuDatabase,
              $TaiyiSchoolDocumentsTable,
              TaiyiSchoolDocumentEntry
            >,
          ),
          TaiyiSchoolDocumentEntry,
          PrefetchHooks Function()
        > {
  $$TaiyiSchoolDocumentsTableTableManager(
    _$TaiyishenshuDatabase db,
    $TaiyiSchoolDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaiyiSchoolDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaiyiSchoolDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaiyiSchoolDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaiyiSchoolDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => TaiyiSchoolDocumentsCompanion.insert(
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

typedef $$TaiyiSchoolDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$TaiyishenshuDatabase,
      $TaiyiSchoolDocumentsTable,
      TaiyiSchoolDocumentEntry,
      $$TaiyiSchoolDocumentsTableFilterComposer,
      $$TaiyiSchoolDocumentsTableOrderingComposer,
      $$TaiyiSchoolDocumentsTableAnnotationComposer,
      $$TaiyiSchoolDocumentsTableCreateCompanionBuilder,
      $$TaiyiSchoolDocumentsTableUpdateCompanionBuilder,
      (
        TaiyiSchoolDocumentEntry,
        BaseReferences<
          _$TaiyishenshuDatabase,
          $TaiyiSchoolDocumentsTable,
          TaiyiSchoolDocumentEntry
        >,
      ),
      TaiyiSchoolDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$TaiyiDeityDocumentsTableCreateCompanionBuilder =
    TaiyiDeityDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$TaiyiDeityDocumentsTableUpdateCompanionBuilder =
    TaiyiDeityDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$TaiyiDeityDocumentsTableFilterComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiDeityDocumentsTable> {
  $$TaiyiDeityDocumentsTableFilterComposer({
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

class $$TaiyiDeityDocumentsTableOrderingComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiDeityDocumentsTable> {
  $$TaiyiDeityDocumentsTableOrderingComposer({
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

class $$TaiyiDeityDocumentsTableAnnotationComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiDeityDocumentsTable> {
  $$TaiyiDeityDocumentsTableAnnotationComposer({
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

class $$TaiyiDeityDocumentsTableTableManager
    extends
        RootTableManager<
          _$TaiyishenshuDatabase,
          $TaiyiDeityDocumentsTable,
          TaiyiDeityDocumentEntry,
          $$TaiyiDeityDocumentsTableFilterComposer,
          $$TaiyiDeityDocumentsTableOrderingComposer,
          $$TaiyiDeityDocumentsTableAnnotationComposer,
          $$TaiyiDeityDocumentsTableCreateCompanionBuilder,
          $$TaiyiDeityDocumentsTableUpdateCompanionBuilder,
          (
            TaiyiDeityDocumentEntry,
            BaseReferences<
              _$TaiyishenshuDatabase,
              $TaiyiDeityDocumentsTable,
              TaiyiDeityDocumentEntry
            >,
          ),
          TaiyiDeityDocumentEntry,
          PrefetchHooks Function()
        > {
  $$TaiyiDeityDocumentsTableTableManager(
    _$TaiyishenshuDatabase db,
    $TaiyiDeityDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaiyiDeityDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaiyiDeityDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaiyiDeityDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaiyiDeityDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => TaiyiDeityDocumentsCompanion.insert(
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

typedef $$TaiyiDeityDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$TaiyishenshuDatabase,
      $TaiyiDeityDocumentsTable,
      TaiyiDeityDocumentEntry,
      $$TaiyiDeityDocumentsTableFilterComposer,
      $$TaiyiDeityDocumentsTableOrderingComposer,
      $$TaiyiDeityDocumentsTableAnnotationComposer,
      $$TaiyiDeityDocumentsTableCreateCompanionBuilder,
      $$TaiyiDeityDocumentsTableUpdateCompanionBuilder,
      (
        TaiyiDeityDocumentEntry,
        BaseReferences<
          _$TaiyishenshuDatabase,
          $TaiyiDeityDocumentsTable,
          TaiyiDeityDocumentEntry
        >,
      ),
      TaiyiDeityDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$TaiyiMingGuaDocumentsTableCreateCompanionBuilder =
    TaiyiMingGuaDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$TaiyiMingGuaDocumentsTableUpdateCompanionBuilder =
    TaiyiMingGuaDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$TaiyiMingGuaDocumentsTableFilterComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiMingGuaDocumentsTable> {
  $$TaiyiMingGuaDocumentsTableFilterComposer({
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

class $$TaiyiMingGuaDocumentsTableOrderingComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiMingGuaDocumentsTable> {
  $$TaiyiMingGuaDocumentsTableOrderingComposer({
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

class $$TaiyiMingGuaDocumentsTableAnnotationComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiMingGuaDocumentsTable> {
  $$TaiyiMingGuaDocumentsTableAnnotationComposer({
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

class $$TaiyiMingGuaDocumentsTableTableManager
    extends
        RootTableManager<
          _$TaiyishenshuDatabase,
          $TaiyiMingGuaDocumentsTable,
          TaiyiMingGuaDocumentEntry,
          $$TaiyiMingGuaDocumentsTableFilterComposer,
          $$TaiyiMingGuaDocumentsTableOrderingComposer,
          $$TaiyiMingGuaDocumentsTableAnnotationComposer,
          $$TaiyiMingGuaDocumentsTableCreateCompanionBuilder,
          $$TaiyiMingGuaDocumentsTableUpdateCompanionBuilder,
          (
            TaiyiMingGuaDocumentEntry,
            BaseReferences<
              _$TaiyishenshuDatabase,
              $TaiyiMingGuaDocumentsTable,
              TaiyiMingGuaDocumentEntry
            >,
          ),
          TaiyiMingGuaDocumentEntry,
          PrefetchHooks Function()
        > {
  $$TaiyiMingGuaDocumentsTableTableManager(
    _$TaiyishenshuDatabase db,
    $TaiyiMingGuaDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaiyiMingGuaDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TaiyiMingGuaDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaiyiMingGuaDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaiyiMingGuaDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => TaiyiMingGuaDocumentsCompanion.insert(
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

typedef $$TaiyiMingGuaDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$TaiyishenshuDatabase,
      $TaiyiMingGuaDocumentsTable,
      TaiyiMingGuaDocumentEntry,
      $$TaiyiMingGuaDocumentsTableFilterComposer,
      $$TaiyiMingGuaDocumentsTableOrderingComposer,
      $$TaiyiMingGuaDocumentsTableAnnotationComposer,
      $$TaiyiMingGuaDocumentsTableCreateCompanionBuilder,
      $$TaiyiMingGuaDocumentsTableUpdateCompanionBuilder,
      (
        TaiyiMingGuaDocumentEntry,
        BaseReferences<
          _$TaiyishenshuDatabase,
          $TaiyiMingGuaDocumentsTable,
          TaiyiMingGuaDocumentEntry
        >,
      ),
      TaiyiMingGuaDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$TaiyiDatasetGenerationsTableCreateCompanionBuilder =
    TaiyiDatasetGenerationsCompanion Function({
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
typedef $$TaiyiDatasetGenerationsTableUpdateCompanionBuilder =
    TaiyiDatasetGenerationsCompanion Function({
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

class $$TaiyiDatasetGenerationsTableFilterComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiDatasetGenerationsTable> {
  $$TaiyiDatasetGenerationsTableFilterComposer({
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

class $$TaiyiDatasetGenerationsTableOrderingComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiDatasetGenerationsTable> {
  $$TaiyiDatasetGenerationsTableOrderingComposer({
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

class $$TaiyiDatasetGenerationsTableAnnotationComposer
    extends Composer<_$TaiyishenshuDatabase, $TaiyiDatasetGenerationsTable> {
  $$TaiyiDatasetGenerationsTableAnnotationComposer({
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

class $$TaiyiDatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$TaiyishenshuDatabase,
          $TaiyiDatasetGenerationsTable,
          TaiyiDatasetGenerationEntry,
          $$TaiyiDatasetGenerationsTableFilterComposer,
          $$TaiyiDatasetGenerationsTableOrderingComposer,
          $$TaiyiDatasetGenerationsTableAnnotationComposer,
          $$TaiyiDatasetGenerationsTableCreateCompanionBuilder,
          $$TaiyiDatasetGenerationsTableUpdateCompanionBuilder,
          (
            TaiyiDatasetGenerationEntry,
            BaseReferences<
              _$TaiyishenshuDatabase,
              $TaiyiDatasetGenerationsTable,
              TaiyiDatasetGenerationEntry
            >,
          ),
          TaiyiDatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$TaiyiDatasetGenerationsTableTableManager(
    _$TaiyishenshuDatabase db,
    $TaiyiDatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaiyiDatasetGenerationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TaiyiDatasetGenerationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaiyiDatasetGenerationsTableAnnotationComposer(
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
              }) => TaiyiDatasetGenerationsCompanion(
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
              }) => TaiyiDatasetGenerationsCompanion.insert(
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

typedef $$TaiyiDatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$TaiyishenshuDatabase,
      $TaiyiDatasetGenerationsTable,
      TaiyiDatasetGenerationEntry,
      $$TaiyiDatasetGenerationsTableFilterComposer,
      $$TaiyiDatasetGenerationsTableOrderingComposer,
      $$TaiyiDatasetGenerationsTableAnnotationComposer,
      $$TaiyiDatasetGenerationsTableCreateCompanionBuilder,
      $$TaiyiDatasetGenerationsTableUpdateCompanionBuilder,
      (
        TaiyiDatasetGenerationEntry,
        BaseReferences<
          _$TaiyishenshuDatabase,
          $TaiyiDatasetGenerationsTable,
          TaiyiDatasetGenerationEntry
        >,
      ),
      TaiyiDatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $TaiyishenshuDatabaseManager {
  final _$TaiyishenshuDatabase _db;
  $TaiyishenshuDatabaseManager(this._db);
  $$TaiyiSchoolDocumentsTableTableManager get taiyiSchoolDocuments =>
      $$TaiyiSchoolDocumentsTableTableManager(_db, _db.taiyiSchoolDocuments);
  $$TaiyiDeityDocumentsTableTableManager get taiyiDeityDocuments =>
      $$TaiyiDeityDocumentsTableTableManager(_db, _db.taiyiDeityDocuments);
  $$TaiyiMingGuaDocumentsTableTableManager get taiyiMingGuaDocuments =>
      $$TaiyiMingGuaDocumentsTableTableManager(_db, _db.taiyiMingGuaDocuments);
  $$TaiyiDatasetGenerationsTableTableManager get taiyiDatasetGenerations =>
      $$TaiyiDatasetGenerationsTableTableManager(
        _db,
        _db.taiyiDatasetGenerations,
      );
}
