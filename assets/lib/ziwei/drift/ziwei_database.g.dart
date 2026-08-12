// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ziwei_database.dart';

// ignore_for_file: type=lint
class $ZiweiStarCatalogDocumentsTable extends ZiweiStarCatalogDocuments
    with TableInfo<$ZiweiStarCatalogDocumentsTable, ZiweiStarCatalogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZiweiStarCatalogDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'star_catalog_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZiweiStarCatalogEntry> instance, {
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
  ZiweiStarCatalogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZiweiStarCatalogEntry(
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
  $ZiweiStarCatalogDocumentsTable createAlias(String alias) {
    return $ZiweiStarCatalogDocumentsTable(attachedDatabase, alias);
  }
}

class ZiweiStarCatalogEntry extends DataClass
    implements Insertable<ZiweiStarCatalogEntry> {
  final String fileName;
  final String payloadJson;
  const ZiweiStarCatalogEntry({
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

  ZiweiStarCatalogDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ZiweiStarCatalogDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory ZiweiStarCatalogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZiweiStarCatalogEntry(
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

  ZiweiStarCatalogEntry copyWith({String? fileName, String? payloadJson}) =>
      ZiweiStarCatalogEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  ZiweiStarCatalogEntry copyWithCompanion(
    ZiweiStarCatalogDocumentsCompanion data,
  ) {
    return ZiweiStarCatalogEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZiweiStarCatalogEntry(')
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
      (other is ZiweiStarCatalogEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class ZiweiStarCatalogDocumentsCompanion
    extends UpdateCompanion<ZiweiStarCatalogEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ZiweiStarCatalogDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZiweiStarCatalogDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<ZiweiStarCatalogEntry> custom({
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

  ZiweiStarCatalogDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return ZiweiStarCatalogDocumentsCompanion(
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
    return (StringBuffer('ZiweiStarCatalogDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZiweiStarMetadataDocumentsTable extends ZiweiStarMetadataDocuments
    with TableInfo<$ZiweiStarMetadataDocumentsTable, ZiweiStarMetadataEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZiweiStarMetadataDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'star_metadata_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZiweiStarMetadataEntry> instance, {
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
  ZiweiStarMetadataEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZiweiStarMetadataEntry(
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
  $ZiweiStarMetadataDocumentsTable createAlias(String alias) {
    return $ZiweiStarMetadataDocumentsTable(attachedDatabase, alias);
  }
}

class ZiweiStarMetadataEntry extends DataClass
    implements Insertable<ZiweiStarMetadataEntry> {
  final String fileName;
  final String payloadJson;
  const ZiweiStarMetadataEntry({
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

  ZiweiStarMetadataDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ZiweiStarMetadataDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory ZiweiStarMetadataEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZiweiStarMetadataEntry(
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

  ZiweiStarMetadataEntry copyWith({String? fileName, String? payloadJson}) =>
      ZiweiStarMetadataEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  ZiweiStarMetadataEntry copyWithCompanion(
    ZiweiStarMetadataDocumentsCompanion data,
  ) {
    return ZiweiStarMetadataEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZiweiStarMetadataEntry(')
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
      (other is ZiweiStarMetadataEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class ZiweiStarMetadataDocumentsCompanion
    extends UpdateCompanion<ZiweiStarMetadataEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ZiweiStarMetadataDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZiweiStarMetadataDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<ZiweiStarMetadataEntry> custom({
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

  ZiweiStarMetadataDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return ZiweiStarMetadataDocumentsCompanion(
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
    return (StringBuffer('ZiweiStarMetadataDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZiweiFourTransformationsDocumentsTable
    extends ZiweiFourTransformationsDocuments
    with
        TableInfo<
          $ZiweiFourTransformationsDocumentsTable,
          ZiweiFourTransformationsEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZiweiFourTransformationsDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'four_transformations_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZiweiFourTransformationsEntry> instance, {
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
  ZiweiFourTransformationsEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZiweiFourTransformationsEntry(
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
  $ZiweiFourTransformationsDocumentsTable createAlias(String alias) {
    return $ZiweiFourTransformationsDocumentsTable(attachedDatabase, alias);
  }
}

class ZiweiFourTransformationsEntry extends DataClass
    implements Insertable<ZiweiFourTransformationsEntry> {
  final String fileName;
  final String payloadJson;
  const ZiweiFourTransformationsEntry({
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

  ZiweiFourTransformationsDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ZiweiFourTransformationsDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory ZiweiFourTransformationsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZiweiFourTransformationsEntry(
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

  ZiweiFourTransformationsEntry copyWith({
    String? fileName,
    String? payloadJson,
  }) => ZiweiFourTransformationsEntry(
    fileName: fileName ?? this.fileName,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  ZiweiFourTransformationsEntry copyWithCompanion(
    ZiweiFourTransformationsDocumentsCompanion data,
  ) {
    return ZiweiFourTransformationsEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZiweiFourTransformationsEntry(')
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
      (other is ZiweiFourTransformationsEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class ZiweiFourTransformationsDocumentsCompanion
    extends UpdateCompanion<ZiweiFourTransformationsEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ZiweiFourTransformationsDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZiweiFourTransformationsDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<ZiweiFourTransformationsEntry> custom({
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

  ZiweiFourTransformationsDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return ZiweiFourTransformationsDocumentsCompanion(
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
    return (StringBuffer('ZiweiFourTransformationsDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZiweiDatasetGenerationsTable extends ZiweiDatasetGenerations
    with TableInfo<$ZiweiDatasetGenerationsTable, ZiweiDatasetGenerationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZiweiDatasetGenerationsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<ZiweiDatasetGenerationEntry> instance, {
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
  ZiweiDatasetGenerationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZiweiDatasetGenerationEntry(
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
  $ZiweiDatasetGenerationsTable createAlias(String alias) {
    return $ZiweiDatasetGenerationsTable(attachedDatabase, alias);
  }
}

class ZiweiDatasetGenerationEntry extends DataClass
    implements Insertable<ZiweiDatasetGenerationEntry> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const ZiweiDatasetGenerationEntry({
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

  ZiweiDatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return ZiweiDatasetGenerationsCompanion(
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

  factory ZiweiDatasetGenerationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZiweiDatasetGenerationEntry(
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

  ZiweiDatasetGenerationEntry copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => ZiweiDatasetGenerationEntry(
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
  ZiweiDatasetGenerationEntry copyWithCompanion(
    ZiweiDatasetGenerationsCompanion data,
  ) {
    return ZiweiDatasetGenerationEntry(
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
    return (StringBuffer('ZiweiDatasetGenerationEntry(')
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
      (other is ZiweiDatasetGenerationEntry &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class ZiweiDatasetGenerationsCompanion
    extends UpdateCompanion<ZiweiDatasetGenerationEntry> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const ZiweiDatasetGenerationsCompanion({
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
  ZiweiDatasetGenerationsCompanion.insert({
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
  static Insertable<ZiweiDatasetGenerationEntry> custom({
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

  ZiweiDatasetGenerationsCompanion copyWith({
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
    return ZiweiDatasetGenerationsCompanion(
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
    return (StringBuffer('ZiweiDatasetGenerationsCompanion(')
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

abstract class _$ZiweiDatabase extends GeneratedDatabase {
  _$ZiweiDatabase(QueryExecutor e) : super(e);
  $ZiweiDatabaseManager get managers => $ZiweiDatabaseManager(this);
  late final $ZiweiStarCatalogDocumentsTable ziweiStarCatalogDocuments =
      $ZiweiStarCatalogDocumentsTable(this);
  late final $ZiweiStarMetadataDocumentsTable ziweiStarMetadataDocuments =
      $ZiweiStarMetadataDocumentsTable(this);
  late final $ZiweiFourTransformationsDocumentsTable
  ziweiFourTransformationsDocuments = $ZiweiFourTransformationsDocumentsTable(
    this,
  );
  late final $ZiweiDatasetGenerationsTable ziweiDatasetGenerations =
      $ZiweiDatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ziweiStarCatalogDocuments,
    ziweiStarMetadataDocuments,
    ziweiFourTransformationsDocuments,
    ziweiDatasetGenerations,
  ];
}

typedef $$ZiweiStarCatalogDocumentsTableCreateCompanionBuilder =
    ZiweiStarCatalogDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$ZiweiStarCatalogDocumentsTableUpdateCompanionBuilder =
    ZiweiStarCatalogDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$ZiweiStarCatalogDocumentsTableFilterComposer
    extends Composer<_$ZiweiDatabase, $ZiweiStarCatalogDocumentsTable> {
  $$ZiweiStarCatalogDocumentsTableFilterComposer({
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

class $$ZiweiStarCatalogDocumentsTableOrderingComposer
    extends Composer<_$ZiweiDatabase, $ZiweiStarCatalogDocumentsTable> {
  $$ZiweiStarCatalogDocumentsTableOrderingComposer({
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

class $$ZiweiStarCatalogDocumentsTableAnnotationComposer
    extends Composer<_$ZiweiDatabase, $ZiweiStarCatalogDocumentsTable> {
  $$ZiweiStarCatalogDocumentsTableAnnotationComposer({
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

class $$ZiweiStarCatalogDocumentsTableTableManager
    extends
        RootTableManager<
          _$ZiweiDatabase,
          $ZiweiStarCatalogDocumentsTable,
          ZiweiStarCatalogEntry,
          $$ZiweiStarCatalogDocumentsTableFilterComposer,
          $$ZiweiStarCatalogDocumentsTableOrderingComposer,
          $$ZiweiStarCatalogDocumentsTableAnnotationComposer,
          $$ZiweiStarCatalogDocumentsTableCreateCompanionBuilder,
          $$ZiweiStarCatalogDocumentsTableUpdateCompanionBuilder,
          (
            ZiweiStarCatalogEntry,
            BaseReferences<
              _$ZiweiDatabase,
              $ZiweiStarCatalogDocumentsTable,
              ZiweiStarCatalogEntry
            >,
          ),
          ZiweiStarCatalogEntry,
          PrefetchHooks Function()
        > {
  $$ZiweiStarCatalogDocumentsTableTableManager(
    _$ZiweiDatabase db,
    $ZiweiStarCatalogDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZiweiStarCatalogDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ZiweiStarCatalogDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ZiweiStarCatalogDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZiweiStarCatalogDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => ZiweiStarCatalogDocumentsCompanion.insert(
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

typedef $$ZiweiStarCatalogDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ZiweiDatabase,
      $ZiweiStarCatalogDocumentsTable,
      ZiweiStarCatalogEntry,
      $$ZiweiStarCatalogDocumentsTableFilterComposer,
      $$ZiweiStarCatalogDocumentsTableOrderingComposer,
      $$ZiweiStarCatalogDocumentsTableAnnotationComposer,
      $$ZiweiStarCatalogDocumentsTableCreateCompanionBuilder,
      $$ZiweiStarCatalogDocumentsTableUpdateCompanionBuilder,
      (
        ZiweiStarCatalogEntry,
        BaseReferences<
          _$ZiweiDatabase,
          $ZiweiStarCatalogDocumentsTable,
          ZiweiStarCatalogEntry
        >,
      ),
      ZiweiStarCatalogEntry,
      PrefetchHooks Function()
    >;
typedef $$ZiweiStarMetadataDocumentsTableCreateCompanionBuilder =
    ZiweiStarMetadataDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$ZiweiStarMetadataDocumentsTableUpdateCompanionBuilder =
    ZiweiStarMetadataDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$ZiweiStarMetadataDocumentsTableFilterComposer
    extends Composer<_$ZiweiDatabase, $ZiweiStarMetadataDocumentsTable> {
  $$ZiweiStarMetadataDocumentsTableFilterComposer({
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

class $$ZiweiStarMetadataDocumentsTableOrderingComposer
    extends Composer<_$ZiweiDatabase, $ZiweiStarMetadataDocumentsTable> {
  $$ZiweiStarMetadataDocumentsTableOrderingComposer({
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

class $$ZiweiStarMetadataDocumentsTableAnnotationComposer
    extends Composer<_$ZiweiDatabase, $ZiweiStarMetadataDocumentsTable> {
  $$ZiweiStarMetadataDocumentsTableAnnotationComposer({
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

class $$ZiweiStarMetadataDocumentsTableTableManager
    extends
        RootTableManager<
          _$ZiweiDatabase,
          $ZiweiStarMetadataDocumentsTable,
          ZiweiStarMetadataEntry,
          $$ZiweiStarMetadataDocumentsTableFilterComposer,
          $$ZiweiStarMetadataDocumentsTableOrderingComposer,
          $$ZiweiStarMetadataDocumentsTableAnnotationComposer,
          $$ZiweiStarMetadataDocumentsTableCreateCompanionBuilder,
          $$ZiweiStarMetadataDocumentsTableUpdateCompanionBuilder,
          (
            ZiweiStarMetadataEntry,
            BaseReferences<
              _$ZiweiDatabase,
              $ZiweiStarMetadataDocumentsTable,
              ZiweiStarMetadataEntry
            >,
          ),
          ZiweiStarMetadataEntry,
          PrefetchHooks Function()
        > {
  $$ZiweiStarMetadataDocumentsTableTableManager(
    _$ZiweiDatabase db,
    $ZiweiStarMetadataDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZiweiStarMetadataDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ZiweiStarMetadataDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ZiweiStarMetadataDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZiweiStarMetadataDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => ZiweiStarMetadataDocumentsCompanion.insert(
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

typedef $$ZiweiStarMetadataDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ZiweiDatabase,
      $ZiweiStarMetadataDocumentsTable,
      ZiweiStarMetadataEntry,
      $$ZiweiStarMetadataDocumentsTableFilterComposer,
      $$ZiweiStarMetadataDocumentsTableOrderingComposer,
      $$ZiweiStarMetadataDocumentsTableAnnotationComposer,
      $$ZiweiStarMetadataDocumentsTableCreateCompanionBuilder,
      $$ZiweiStarMetadataDocumentsTableUpdateCompanionBuilder,
      (
        ZiweiStarMetadataEntry,
        BaseReferences<
          _$ZiweiDatabase,
          $ZiweiStarMetadataDocumentsTable,
          ZiweiStarMetadataEntry
        >,
      ),
      ZiweiStarMetadataEntry,
      PrefetchHooks Function()
    >;
typedef $$ZiweiFourTransformationsDocumentsTableCreateCompanionBuilder =
    ZiweiFourTransformationsDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$ZiweiFourTransformationsDocumentsTableUpdateCompanionBuilder =
    ZiweiFourTransformationsDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$ZiweiFourTransformationsDocumentsTableFilterComposer
    extends Composer<_$ZiweiDatabase, $ZiweiFourTransformationsDocumentsTable> {
  $$ZiweiFourTransformationsDocumentsTableFilterComposer({
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

class $$ZiweiFourTransformationsDocumentsTableOrderingComposer
    extends Composer<_$ZiweiDatabase, $ZiweiFourTransformationsDocumentsTable> {
  $$ZiweiFourTransformationsDocumentsTableOrderingComposer({
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

class $$ZiweiFourTransformationsDocumentsTableAnnotationComposer
    extends Composer<_$ZiweiDatabase, $ZiweiFourTransformationsDocumentsTable> {
  $$ZiweiFourTransformationsDocumentsTableAnnotationComposer({
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

class $$ZiweiFourTransformationsDocumentsTableTableManager
    extends
        RootTableManager<
          _$ZiweiDatabase,
          $ZiweiFourTransformationsDocumentsTable,
          ZiweiFourTransformationsEntry,
          $$ZiweiFourTransformationsDocumentsTableFilterComposer,
          $$ZiweiFourTransformationsDocumentsTableOrderingComposer,
          $$ZiweiFourTransformationsDocumentsTableAnnotationComposer,
          $$ZiweiFourTransformationsDocumentsTableCreateCompanionBuilder,
          $$ZiweiFourTransformationsDocumentsTableUpdateCompanionBuilder,
          (
            ZiweiFourTransformationsEntry,
            BaseReferences<
              _$ZiweiDatabase,
              $ZiweiFourTransformationsDocumentsTable,
              ZiweiFourTransformationsEntry
            >,
          ),
          ZiweiFourTransformationsEntry,
          PrefetchHooks Function()
        > {
  $$ZiweiFourTransformationsDocumentsTableTableManager(
    _$ZiweiDatabase db,
    $ZiweiFourTransformationsDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZiweiFourTransformationsDocumentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ZiweiFourTransformationsDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ZiweiFourTransformationsDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZiweiFourTransformationsDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => ZiweiFourTransformationsDocumentsCompanion.insert(
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

typedef $$ZiweiFourTransformationsDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ZiweiDatabase,
      $ZiweiFourTransformationsDocumentsTable,
      ZiweiFourTransformationsEntry,
      $$ZiweiFourTransformationsDocumentsTableFilterComposer,
      $$ZiweiFourTransformationsDocumentsTableOrderingComposer,
      $$ZiweiFourTransformationsDocumentsTableAnnotationComposer,
      $$ZiweiFourTransformationsDocumentsTableCreateCompanionBuilder,
      $$ZiweiFourTransformationsDocumentsTableUpdateCompanionBuilder,
      (
        ZiweiFourTransformationsEntry,
        BaseReferences<
          _$ZiweiDatabase,
          $ZiweiFourTransformationsDocumentsTable,
          ZiweiFourTransformationsEntry
        >,
      ),
      ZiweiFourTransformationsEntry,
      PrefetchHooks Function()
    >;
typedef $$ZiweiDatasetGenerationsTableCreateCompanionBuilder =
    ZiweiDatasetGenerationsCompanion Function({
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
typedef $$ZiweiDatasetGenerationsTableUpdateCompanionBuilder =
    ZiweiDatasetGenerationsCompanion Function({
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

class $$ZiweiDatasetGenerationsTableFilterComposer
    extends Composer<_$ZiweiDatabase, $ZiweiDatasetGenerationsTable> {
  $$ZiweiDatasetGenerationsTableFilterComposer({
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

class $$ZiweiDatasetGenerationsTableOrderingComposer
    extends Composer<_$ZiweiDatabase, $ZiweiDatasetGenerationsTable> {
  $$ZiweiDatasetGenerationsTableOrderingComposer({
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

class $$ZiweiDatasetGenerationsTableAnnotationComposer
    extends Composer<_$ZiweiDatabase, $ZiweiDatasetGenerationsTable> {
  $$ZiweiDatasetGenerationsTableAnnotationComposer({
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

class $$ZiweiDatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$ZiweiDatabase,
          $ZiweiDatasetGenerationsTable,
          ZiweiDatasetGenerationEntry,
          $$ZiweiDatasetGenerationsTableFilterComposer,
          $$ZiweiDatasetGenerationsTableOrderingComposer,
          $$ZiweiDatasetGenerationsTableAnnotationComposer,
          $$ZiweiDatasetGenerationsTableCreateCompanionBuilder,
          $$ZiweiDatasetGenerationsTableUpdateCompanionBuilder,
          (
            ZiweiDatasetGenerationEntry,
            BaseReferences<
              _$ZiweiDatabase,
              $ZiweiDatasetGenerationsTable,
              ZiweiDatasetGenerationEntry
            >,
          ),
          ZiweiDatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$ZiweiDatasetGenerationsTableTableManager(
    _$ZiweiDatabase db,
    $ZiweiDatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZiweiDatasetGenerationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ZiweiDatasetGenerationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ZiweiDatasetGenerationsTableAnnotationComposer(
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
              }) => ZiweiDatasetGenerationsCompanion(
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
              }) => ZiweiDatasetGenerationsCompanion.insert(
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

typedef $$ZiweiDatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ZiweiDatabase,
      $ZiweiDatasetGenerationsTable,
      ZiweiDatasetGenerationEntry,
      $$ZiweiDatasetGenerationsTableFilterComposer,
      $$ZiweiDatasetGenerationsTableOrderingComposer,
      $$ZiweiDatasetGenerationsTableAnnotationComposer,
      $$ZiweiDatasetGenerationsTableCreateCompanionBuilder,
      $$ZiweiDatasetGenerationsTableUpdateCompanionBuilder,
      (
        ZiweiDatasetGenerationEntry,
        BaseReferences<
          _$ZiweiDatabase,
          $ZiweiDatasetGenerationsTable,
          ZiweiDatasetGenerationEntry
        >,
      ),
      ZiweiDatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $ZiweiDatabaseManager {
  final _$ZiweiDatabase _db;
  $ZiweiDatabaseManager(this._db);
  $$ZiweiStarCatalogDocumentsTableTableManager get ziweiStarCatalogDocuments =>
      $$ZiweiStarCatalogDocumentsTableTableManager(
        _db,
        _db.ziweiStarCatalogDocuments,
      );
  $$ZiweiStarMetadataDocumentsTableTableManager
  get ziweiStarMetadataDocuments =>
      $$ZiweiStarMetadataDocumentsTableTableManager(
        _db,
        _db.ziweiStarMetadataDocuments,
      );
  $$ZiweiFourTransformationsDocumentsTableTableManager
  get ziweiFourTransformationsDocuments =>
      $$ZiweiFourTransformationsDocumentsTableTableManager(
        _db,
        _db.ziweiFourTransformationsDocuments,
      );
  $$ZiweiDatasetGenerationsTableTableManager get ziweiDatasetGenerations =>
      $$ZiweiDatasetGenerationsTableTableManager(
        _db,
        _db.ziweiDatasetGenerations,
      );
}
