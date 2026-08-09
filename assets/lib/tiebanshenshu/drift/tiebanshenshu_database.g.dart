// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiebanshenshu_database.dart';

// ignore_for_file: type=lint
class $TiaoWenEntriesTable extends TiaoWenEntries
    with TableInfo<$TiaoWenEntriesTable, TiaoWenEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TiaoWenEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _content1Meta = const VerificationMeta(
    'content1',
  );
  @override
  late final GeneratedColumn<String> content1 = GeneratedColumn<String>(
    'content1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageSet1JsonMeta = const VerificationMeta(
    'ageSet1Json',
  );
  @override
  late final GeneratedColumn<String> ageSet1Json = GeneratedColumn<String>(
    'age_set1_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, setName, content1, ageSet1Json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tiao_wen';
  @override
  VerificationContext validateIntegrity(
    Insertable<TiaoWenEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    } else if (isInserting) {
      context.missing(_setNameMeta);
    }
    if (data.containsKey('content1')) {
      context.handle(
        _content1Meta,
        content1.isAcceptableOrUnknown(data['content1']!, _content1Meta),
      );
    } else if (isInserting) {
      context.missing(_content1Meta);
    }
    if (data.containsKey('age_set1_json')) {
      context.handle(
        _ageSet1JsonMeta,
        ageSet1Json.isAcceptableOrUnknown(
          data['age_set1_json']!,
          _ageSet1JsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TiaoWenEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TiaoWenEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      content1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content1'],
      )!,
      ageSet1Json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}age_set1_json'],
      ),
    );
  }

  @override
  $TiaoWenEntriesTable createAlias(String alias) {
    return $TiaoWenEntriesTable(attachedDatabase, alias);
  }
}

class TiaoWenEntry extends DataClass implements Insertable<TiaoWenEntry> {
  final int id;
  final String setName;
  final String content1;
  final String? ageSet1Json;
  const TiaoWenEntry({
    required this.id,
    required this.setName,
    required this.content1,
    this.ageSet1Json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['set_name'] = Variable<String>(setName);
    map['content1'] = Variable<String>(content1);
    if (!nullToAbsent || ageSet1Json != null) {
      map['age_set1_json'] = Variable<String>(ageSet1Json);
    }
    return map;
  }

  TiaoWenEntriesCompanion toCompanion(bool nullToAbsent) {
    return TiaoWenEntriesCompanion(
      id: Value(id),
      setName: Value(setName),
      content1: Value(content1),
      ageSet1Json: ageSet1Json == null && nullToAbsent
          ? const Value.absent()
          : Value(ageSet1Json),
    );
  }

  factory TiaoWenEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TiaoWenEntry(
      id: serializer.fromJson<int>(json['id']),
      setName: serializer.fromJson<String>(json['setName']),
      content1: serializer.fromJson<String>(json['content1']),
      ageSet1Json: serializer.fromJson<String?>(json['ageSet1Json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'setName': serializer.toJson<String>(setName),
      'content1': serializer.toJson<String>(content1),
      'ageSet1Json': serializer.toJson<String?>(ageSet1Json),
    };
  }

  TiaoWenEntry copyWith({
    int? id,
    String? setName,
    String? content1,
    Value<String?> ageSet1Json = const Value.absent(),
  }) => TiaoWenEntry(
    id: id ?? this.id,
    setName: setName ?? this.setName,
    content1: content1 ?? this.content1,
    ageSet1Json: ageSet1Json.present ? ageSet1Json.value : this.ageSet1Json,
  );
  TiaoWenEntry copyWithCompanion(TiaoWenEntriesCompanion data) {
    return TiaoWenEntry(
      id: data.id.present ? data.id.value : this.id,
      setName: data.setName.present ? data.setName.value : this.setName,
      content1: data.content1.present ? data.content1.value : this.content1,
      ageSet1Json: data.ageSet1Json.present
          ? data.ageSet1Json.value
          : this.ageSet1Json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TiaoWenEntry(')
          ..write('id: $id, ')
          ..write('setName: $setName, ')
          ..write('content1: $content1, ')
          ..write('ageSet1Json: $ageSet1Json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, setName, content1, ageSet1Json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TiaoWenEntry &&
          other.id == this.id &&
          other.setName == this.setName &&
          other.content1 == this.content1 &&
          other.ageSet1Json == this.ageSet1Json);
}

class TiaoWenEntriesCompanion extends UpdateCompanion<TiaoWenEntry> {
  final Value<int> id;
  final Value<String> setName;
  final Value<String> content1;
  final Value<String?> ageSet1Json;
  const TiaoWenEntriesCompanion({
    this.id = const Value.absent(),
    this.setName = const Value.absent(),
    this.content1 = const Value.absent(),
    this.ageSet1Json = const Value.absent(),
  });
  TiaoWenEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String setName,
    required String content1,
    this.ageSet1Json = const Value.absent(),
  }) : setName = Value(setName),
       content1 = Value(content1);
  static Insertable<TiaoWenEntry> custom({
    Expression<int>? id,
    Expression<String>? setName,
    Expression<String>? content1,
    Expression<String>? ageSet1Json,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setName != null) 'set_name': setName,
      if (content1 != null) 'content1': content1,
      if (ageSet1Json != null) 'age_set1_json': ageSet1Json,
    });
  }

  TiaoWenEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? setName,
    Value<String>? content1,
    Value<String?>? ageSet1Json,
  }) {
    return TiaoWenEntriesCompanion(
      id: id ?? this.id,
      setName: setName ?? this.setName,
      content1: content1 ?? this.content1,
      ageSet1Json: ageSet1Json ?? this.ageSet1Json,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (content1.present) {
      map['content1'] = Variable<String>(content1.value);
    }
    if (ageSet1Json.present) {
      map['age_set1_json'] = Variable<String>(ageSet1Json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TiaoWenEntriesCompanion(')
          ..write('id: $id, ')
          ..write('setName: $setName, ')
          ..write('content1: $content1, ')
          ..write('ageSet1Json: $ageSet1Json')
          ..write(')'))
        .toString();
  }
}

class $KaoKeDocumentsTable extends KaoKeDocuments
    with TableInfo<$KaoKeDocumentsTable, KaoKeDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KaoKeDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'kao_ke_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<KaoKeDocumentEntry> instance, {
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
  KaoKeDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KaoKeDocumentEntry(
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
  $KaoKeDocumentsTable createAlias(String alias) {
    return $KaoKeDocumentsTable(attachedDatabase, alias);
  }
}

class KaoKeDocumentEntry extends DataClass
    implements Insertable<KaoKeDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const KaoKeDocumentEntry({required this.fileName, required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_name'] = Variable<String>(fileName);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  KaoKeDocumentsCompanion toCompanion(bool nullToAbsent) {
    return KaoKeDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory KaoKeDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KaoKeDocumentEntry(
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

  KaoKeDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      KaoKeDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  KaoKeDocumentEntry copyWithCompanion(KaoKeDocumentsCompanion data) {
    return KaoKeDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KaoKeDocumentEntry(')
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
      (other is KaoKeDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class KaoKeDocumentsCompanion extends UpdateCompanion<KaoKeDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const KaoKeDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KaoKeDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<KaoKeDocumentEntry> custom({
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

  KaoKeDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return KaoKeDocumentsCompanion(
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
    return (StringBuffer('KaoKeDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShaoZiShuDocumentsTable extends ShaoZiShuDocuments
    with TableInfo<$ShaoZiShuDocumentsTable, ShaoZiShuDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShaoZiShuDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _payloadTextMeta = const VerificationMeta(
    'payloadText',
  );
  @override
  late final GeneratedColumn<String> payloadText = GeneratedColumn<String>(
    'payload_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [fileName, payloadText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shaozishu_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShaoZiShuDocumentEntry> instance, {
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
    if (data.containsKey('payload_text')) {
      context.handle(
        _payloadTextMeta,
        payloadText.isAcceptableOrUnknown(
          data['payload_text']!,
          _payloadTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileName};
  @override
  ShaoZiShuDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShaoZiShuDocumentEntry(
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      payloadText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_text'],
      )!,
    );
  }

  @override
  $ShaoZiShuDocumentsTable createAlias(String alias) {
    return $ShaoZiShuDocumentsTable(attachedDatabase, alias);
  }
}

class ShaoZiShuDocumentEntry extends DataClass
    implements Insertable<ShaoZiShuDocumentEntry> {
  final String fileName;
  final String payloadText;
  const ShaoZiShuDocumentEntry({
    required this.fileName,
    required this.payloadText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_name'] = Variable<String>(fileName);
    map['payload_text'] = Variable<String>(payloadText);
    return map;
  }

  ShaoZiShuDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ShaoZiShuDocumentsCompanion(
      fileName: Value(fileName),
      payloadText: Value(payloadText),
    );
  }

  factory ShaoZiShuDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShaoZiShuDocumentEntry(
      fileName: serializer.fromJson<String>(json['fileName']),
      payloadText: serializer.fromJson<String>(json['payloadText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileName': serializer.toJson<String>(fileName),
      'payloadText': serializer.toJson<String>(payloadText),
    };
  }

  ShaoZiShuDocumentEntry copyWith({String? fileName, String? payloadText}) =>
      ShaoZiShuDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadText: payloadText ?? this.payloadText,
      );
  ShaoZiShuDocumentEntry copyWithCompanion(ShaoZiShuDocumentsCompanion data) {
    return ShaoZiShuDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadText: data.payloadText.present
          ? data.payloadText.value
          : this.payloadText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShaoZiShuDocumentEntry(')
          ..write('fileName: $fileName, ')
          ..write('payloadText: $payloadText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileName, payloadText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShaoZiShuDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadText == this.payloadText);
}

class ShaoZiShuDocumentsCompanion
    extends UpdateCompanion<ShaoZiShuDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadText;
  final Value<int> rowid;
  const ShaoZiShuDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShaoZiShuDocumentsCompanion.insert({
    required String fileName,
    required String payloadText,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadText = Value(payloadText);
  static Insertable<ShaoZiShuDocumentEntry> custom({
    Expression<String>? fileName,
    Expression<String>? payloadText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileName != null) 'file_name': fileName,
      if (payloadText != null) 'payload_text': payloadText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShaoZiShuDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadText,
    Value<int>? rowid,
  }) {
    return ShaoZiShuDocumentsCompanion(
      fileName: fileName ?? this.fileName,
      payloadText: payloadText ?? this.payloadText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (payloadText.present) {
      map['payload_text'] = Variable<String>(payloadText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShaoZiShuDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadText: $payloadText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormulaDocumentsTable extends FormulaDocuments
    with TableInfo<$FormulaDocumentsTable, FormulaDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormulaDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'formulas_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormulaDocumentEntry> instance, {
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
  FormulaDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormulaDocumentEntry(
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
  $FormulaDocumentsTable createAlias(String alias) {
    return $FormulaDocumentsTable(attachedDatabase, alias);
  }
}

class FormulaDocumentEntry extends DataClass
    implements Insertable<FormulaDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const FormulaDocumentEntry({
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

  FormulaDocumentsCompanion toCompanion(bool nullToAbsent) {
    return FormulaDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory FormulaDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormulaDocumentEntry(
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

  FormulaDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      FormulaDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  FormulaDocumentEntry copyWithCompanion(FormulaDocumentsCompanion data) {
    return FormulaDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormulaDocumentEntry(')
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
      (other is FormulaDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class FormulaDocumentsCompanion extends UpdateCompanion<FormulaDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const FormulaDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormulaDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<FormulaDocumentEntry> custom({
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

  FormulaDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return FormulaDocumentsCompanion(
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
    return (StringBuffer('FormulaDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TiebanshenshuDatasetGenerationsTable
    extends TiebanshenshuDatasetGenerations
    with
        TableInfo<
          $TiebanshenshuDatasetGenerationsTable,
          TiebanshenshuDatasetGenerationEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TiebanshenshuDatasetGenerationsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<TiebanshenshuDatasetGenerationEntry> instance, {
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
  TiebanshenshuDatasetGenerationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TiebanshenshuDatasetGenerationEntry(
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
  $TiebanshenshuDatasetGenerationsTable createAlias(String alias) {
    return $TiebanshenshuDatasetGenerationsTable(attachedDatabase, alias);
  }
}

class TiebanshenshuDatasetGenerationEntry extends DataClass
    implements Insertable<TiebanshenshuDatasetGenerationEntry> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const TiebanshenshuDatasetGenerationEntry({
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

  TiebanshenshuDatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return TiebanshenshuDatasetGenerationsCompanion(
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

  factory TiebanshenshuDatasetGenerationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TiebanshenshuDatasetGenerationEntry(
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

  TiebanshenshuDatasetGenerationEntry copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => TiebanshenshuDatasetGenerationEntry(
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
  TiebanshenshuDatasetGenerationEntry copyWithCompanion(
    TiebanshenshuDatasetGenerationsCompanion data,
  ) {
    return TiebanshenshuDatasetGenerationEntry(
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
    return (StringBuffer('TiebanshenshuDatasetGenerationEntry(')
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
      (other is TiebanshenshuDatasetGenerationEntry &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class TiebanshenshuDatasetGenerationsCompanion
    extends UpdateCompanion<TiebanshenshuDatasetGenerationEntry> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const TiebanshenshuDatasetGenerationsCompanion({
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
  TiebanshenshuDatasetGenerationsCompanion.insert({
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
  static Insertable<TiebanshenshuDatasetGenerationEntry> custom({
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

  TiebanshenshuDatasetGenerationsCompanion copyWith({
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
    return TiebanshenshuDatasetGenerationsCompanion(
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
    return (StringBuffer('TiebanshenshuDatasetGenerationsCompanion(')
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

abstract class _$TiebanshenshuDatabase extends GeneratedDatabase {
  _$TiebanshenshuDatabase(QueryExecutor e) : super(e);
  $TiebanshenshuDatabaseManager get managers =>
      $TiebanshenshuDatabaseManager(this);
  late final $TiaoWenEntriesTable tiaoWenEntries = $TiaoWenEntriesTable(this);
  late final $KaoKeDocumentsTable kaoKeDocuments = $KaoKeDocumentsTable(this);
  late final $ShaoZiShuDocumentsTable shaoZiShuDocuments =
      $ShaoZiShuDocumentsTable(this);
  late final $FormulaDocumentsTable formulaDocuments = $FormulaDocumentsTable(
    this,
  );
  late final $TiebanshenshuDatasetGenerationsTable
  tiebanshenshuDatasetGenerations = $TiebanshenshuDatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tiaoWenEntries,
    kaoKeDocuments,
    shaoZiShuDocuments,
    formulaDocuments,
    tiebanshenshuDatasetGenerations,
  ];
}

typedef $$TiaoWenEntriesTableCreateCompanionBuilder =
    TiaoWenEntriesCompanion Function({
      Value<int> id,
      required String setName,
      required String content1,
      Value<String?> ageSet1Json,
    });
typedef $$TiaoWenEntriesTableUpdateCompanionBuilder =
    TiaoWenEntriesCompanion Function({
      Value<int> id,
      Value<String> setName,
      Value<String> content1,
      Value<String?> ageSet1Json,
    });

class $$TiaoWenEntriesTableFilterComposer
    extends Composer<_$TiebanshenshuDatabase, $TiaoWenEntriesTable> {
  $$TiaoWenEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content1 => $composableBuilder(
    column: $table.content1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ageSet1Json => $composableBuilder(
    column: $table.ageSet1Json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TiaoWenEntriesTableOrderingComposer
    extends Composer<_$TiebanshenshuDatabase, $TiaoWenEntriesTable> {
  $$TiaoWenEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content1 => $composableBuilder(
    column: $table.content1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ageSet1Json => $composableBuilder(
    column: $table.ageSet1Json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TiaoWenEntriesTableAnnotationComposer
    extends Composer<_$TiebanshenshuDatabase, $TiaoWenEntriesTable> {
  $$TiaoWenEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get content1 =>
      $composableBuilder(column: $table.content1, builder: (column) => column);

  GeneratedColumn<String> get ageSet1Json => $composableBuilder(
    column: $table.ageSet1Json,
    builder: (column) => column,
  );
}

class $$TiaoWenEntriesTableTableManager
    extends
        RootTableManager<
          _$TiebanshenshuDatabase,
          $TiaoWenEntriesTable,
          TiaoWenEntry,
          $$TiaoWenEntriesTableFilterComposer,
          $$TiaoWenEntriesTableOrderingComposer,
          $$TiaoWenEntriesTableAnnotationComposer,
          $$TiaoWenEntriesTableCreateCompanionBuilder,
          $$TiaoWenEntriesTableUpdateCompanionBuilder,
          (
            TiaoWenEntry,
            BaseReferences<
              _$TiebanshenshuDatabase,
              $TiaoWenEntriesTable,
              TiaoWenEntry
            >,
          ),
          TiaoWenEntry,
          PrefetchHooks Function()
        > {
  $$TiaoWenEntriesTableTableManager(
    _$TiebanshenshuDatabase db,
    $TiaoWenEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TiaoWenEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TiaoWenEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TiaoWenEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> content1 = const Value.absent(),
                Value<String?> ageSet1Json = const Value.absent(),
              }) => TiaoWenEntriesCompanion(
                id: id,
                setName: setName,
                content1: content1,
                ageSet1Json: ageSet1Json,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String setName,
                required String content1,
                Value<String?> ageSet1Json = const Value.absent(),
              }) => TiaoWenEntriesCompanion.insert(
                id: id,
                setName: setName,
                content1: content1,
                ageSet1Json: ageSet1Json,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TiaoWenEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$TiebanshenshuDatabase,
      $TiaoWenEntriesTable,
      TiaoWenEntry,
      $$TiaoWenEntriesTableFilterComposer,
      $$TiaoWenEntriesTableOrderingComposer,
      $$TiaoWenEntriesTableAnnotationComposer,
      $$TiaoWenEntriesTableCreateCompanionBuilder,
      $$TiaoWenEntriesTableUpdateCompanionBuilder,
      (
        TiaoWenEntry,
        BaseReferences<
          _$TiebanshenshuDatabase,
          $TiaoWenEntriesTable,
          TiaoWenEntry
        >,
      ),
      TiaoWenEntry,
      PrefetchHooks Function()
    >;
typedef $$KaoKeDocumentsTableCreateCompanionBuilder =
    KaoKeDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$KaoKeDocumentsTableUpdateCompanionBuilder =
    KaoKeDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$KaoKeDocumentsTableFilterComposer
    extends Composer<_$TiebanshenshuDatabase, $KaoKeDocumentsTable> {
  $$KaoKeDocumentsTableFilterComposer({
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

class $$KaoKeDocumentsTableOrderingComposer
    extends Composer<_$TiebanshenshuDatabase, $KaoKeDocumentsTable> {
  $$KaoKeDocumentsTableOrderingComposer({
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

class $$KaoKeDocumentsTableAnnotationComposer
    extends Composer<_$TiebanshenshuDatabase, $KaoKeDocumentsTable> {
  $$KaoKeDocumentsTableAnnotationComposer({
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

class $$KaoKeDocumentsTableTableManager
    extends
        RootTableManager<
          _$TiebanshenshuDatabase,
          $KaoKeDocumentsTable,
          KaoKeDocumentEntry,
          $$KaoKeDocumentsTableFilterComposer,
          $$KaoKeDocumentsTableOrderingComposer,
          $$KaoKeDocumentsTableAnnotationComposer,
          $$KaoKeDocumentsTableCreateCompanionBuilder,
          $$KaoKeDocumentsTableUpdateCompanionBuilder,
          (
            KaoKeDocumentEntry,
            BaseReferences<
              _$TiebanshenshuDatabase,
              $KaoKeDocumentsTable,
              KaoKeDocumentEntry
            >,
          ),
          KaoKeDocumentEntry,
          PrefetchHooks Function()
        > {
  $$KaoKeDocumentsTableTableManager(
    _$TiebanshenshuDatabase db,
    $KaoKeDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KaoKeDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KaoKeDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KaoKeDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KaoKeDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => KaoKeDocumentsCompanion.insert(
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

typedef $$KaoKeDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$TiebanshenshuDatabase,
      $KaoKeDocumentsTable,
      KaoKeDocumentEntry,
      $$KaoKeDocumentsTableFilterComposer,
      $$KaoKeDocumentsTableOrderingComposer,
      $$KaoKeDocumentsTableAnnotationComposer,
      $$KaoKeDocumentsTableCreateCompanionBuilder,
      $$KaoKeDocumentsTableUpdateCompanionBuilder,
      (
        KaoKeDocumentEntry,
        BaseReferences<
          _$TiebanshenshuDatabase,
          $KaoKeDocumentsTable,
          KaoKeDocumentEntry
        >,
      ),
      KaoKeDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$ShaoZiShuDocumentsTableCreateCompanionBuilder =
    ShaoZiShuDocumentsCompanion Function({
      required String fileName,
      required String payloadText,
      Value<int> rowid,
    });
typedef $$ShaoZiShuDocumentsTableUpdateCompanionBuilder =
    ShaoZiShuDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadText,
      Value<int> rowid,
    });

class $$ShaoZiShuDocumentsTableFilterComposer
    extends Composer<_$TiebanshenshuDatabase, $ShaoZiShuDocumentsTable> {
  $$ShaoZiShuDocumentsTableFilterComposer({
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

  ColumnFilters<String> get payloadText => $composableBuilder(
    column: $table.payloadText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShaoZiShuDocumentsTableOrderingComposer
    extends Composer<_$TiebanshenshuDatabase, $ShaoZiShuDocumentsTable> {
  $$ShaoZiShuDocumentsTableOrderingComposer({
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

  ColumnOrderings<String> get payloadText => $composableBuilder(
    column: $table.payloadText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShaoZiShuDocumentsTableAnnotationComposer
    extends Composer<_$TiebanshenshuDatabase, $ShaoZiShuDocumentsTable> {
  $$ShaoZiShuDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get payloadText => $composableBuilder(
    column: $table.payloadText,
    builder: (column) => column,
  );
}

class $$ShaoZiShuDocumentsTableTableManager
    extends
        RootTableManager<
          _$TiebanshenshuDatabase,
          $ShaoZiShuDocumentsTable,
          ShaoZiShuDocumentEntry,
          $$ShaoZiShuDocumentsTableFilterComposer,
          $$ShaoZiShuDocumentsTableOrderingComposer,
          $$ShaoZiShuDocumentsTableAnnotationComposer,
          $$ShaoZiShuDocumentsTableCreateCompanionBuilder,
          $$ShaoZiShuDocumentsTableUpdateCompanionBuilder,
          (
            ShaoZiShuDocumentEntry,
            BaseReferences<
              _$TiebanshenshuDatabase,
              $ShaoZiShuDocumentsTable,
              ShaoZiShuDocumentEntry
            >,
          ),
          ShaoZiShuDocumentEntry,
          PrefetchHooks Function()
        > {
  $$ShaoZiShuDocumentsTableTableManager(
    _$TiebanshenshuDatabase db,
    $ShaoZiShuDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShaoZiShuDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShaoZiShuDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShaoZiShuDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShaoZiShuDocumentsCompanion(
                fileName: fileName,
                payloadText: payloadText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadText,
                Value<int> rowid = const Value.absent(),
              }) => ShaoZiShuDocumentsCompanion.insert(
                fileName: fileName,
                payloadText: payloadText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShaoZiShuDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$TiebanshenshuDatabase,
      $ShaoZiShuDocumentsTable,
      ShaoZiShuDocumentEntry,
      $$ShaoZiShuDocumentsTableFilterComposer,
      $$ShaoZiShuDocumentsTableOrderingComposer,
      $$ShaoZiShuDocumentsTableAnnotationComposer,
      $$ShaoZiShuDocumentsTableCreateCompanionBuilder,
      $$ShaoZiShuDocumentsTableUpdateCompanionBuilder,
      (
        ShaoZiShuDocumentEntry,
        BaseReferences<
          _$TiebanshenshuDatabase,
          $ShaoZiShuDocumentsTable,
          ShaoZiShuDocumentEntry
        >,
      ),
      ShaoZiShuDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$FormulaDocumentsTableCreateCompanionBuilder =
    FormulaDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$FormulaDocumentsTableUpdateCompanionBuilder =
    FormulaDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$FormulaDocumentsTableFilterComposer
    extends Composer<_$TiebanshenshuDatabase, $FormulaDocumentsTable> {
  $$FormulaDocumentsTableFilterComposer({
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

class $$FormulaDocumentsTableOrderingComposer
    extends Composer<_$TiebanshenshuDatabase, $FormulaDocumentsTable> {
  $$FormulaDocumentsTableOrderingComposer({
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

class $$FormulaDocumentsTableAnnotationComposer
    extends Composer<_$TiebanshenshuDatabase, $FormulaDocumentsTable> {
  $$FormulaDocumentsTableAnnotationComposer({
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

class $$FormulaDocumentsTableTableManager
    extends
        RootTableManager<
          _$TiebanshenshuDatabase,
          $FormulaDocumentsTable,
          FormulaDocumentEntry,
          $$FormulaDocumentsTableFilterComposer,
          $$FormulaDocumentsTableOrderingComposer,
          $$FormulaDocumentsTableAnnotationComposer,
          $$FormulaDocumentsTableCreateCompanionBuilder,
          $$FormulaDocumentsTableUpdateCompanionBuilder,
          (
            FormulaDocumentEntry,
            BaseReferences<
              _$TiebanshenshuDatabase,
              $FormulaDocumentsTable,
              FormulaDocumentEntry
            >,
          ),
          FormulaDocumentEntry,
          PrefetchHooks Function()
        > {
  $$FormulaDocumentsTableTableManager(
    _$TiebanshenshuDatabase db,
    $FormulaDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormulaDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormulaDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormulaDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormulaDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => FormulaDocumentsCompanion.insert(
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

typedef $$FormulaDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$TiebanshenshuDatabase,
      $FormulaDocumentsTable,
      FormulaDocumentEntry,
      $$FormulaDocumentsTableFilterComposer,
      $$FormulaDocumentsTableOrderingComposer,
      $$FormulaDocumentsTableAnnotationComposer,
      $$FormulaDocumentsTableCreateCompanionBuilder,
      $$FormulaDocumentsTableUpdateCompanionBuilder,
      (
        FormulaDocumentEntry,
        BaseReferences<
          _$TiebanshenshuDatabase,
          $FormulaDocumentsTable,
          FormulaDocumentEntry
        >,
      ),
      FormulaDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$TiebanshenshuDatasetGenerationsTableCreateCompanionBuilder =
    TiebanshenshuDatasetGenerationsCompanion Function({
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
typedef $$TiebanshenshuDatasetGenerationsTableUpdateCompanionBuilder =
    TiebanshenshuDatasetGenerationsCompanion Function({
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

class $$TiebanshenshuDatasetGenerationsTableFilterComposer
    extends
        Composer<
          _$TiebanshenshuDatabase,
          $TiebanshenshuDatasetGenerationsTable
        > {
  $$TiebanshenshuDatasetGenerationsTableFilterComposer({
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

class $$TiebanshenshuDatasetGenerationsTableOrderingComposer
    extends
        Composer<
          _$TiebanshenshuDatabase,
          $TiebanshenshuDatasetGenerationsTable
        > {
  $$TiebanshenshuDatasetGenerationsTableOrderingComposer({
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

class $$TiebanshenshuDatasetGenerationsTableAnnotationComposer
    extends
        Composer<
          _$TiebanshenshuDatabase,
          $TiebanshenshuDatasetGenerationsTable
        > {
  $$TiebanshenshuDatasetGenerationsTableAnnotationComposer({
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

class $$TiebanshenshuDatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$TiebanshenshuDatabase,
          $TiebanshenshuDatasetGenerationsTable,
          TiebanshenshuDatasetGenerationEntry,
          $$TiebanshenshuDatasetGenerationsTableFilterComposer,
          $$TiebanshenshuDatasetGenerationsTableOrderingComposer,
          $$TiebanshenshuDatasetGenerationsTableAnnotationComposer,
          $$TiebanshenshuDatasetGenerationsTableCreateCompanionBuilder,
          $$TiebanshenshuDatasetGenerationsTableUpdateCompanionBuilder,
          (
            TiebanshenshuDatasetGenerationEntry,
            BaseReferences<
              _$TiebanshenshuDatabase,
              $TiebanshenshuDatasetGenerationsTable,
              TiebanshenshuDatasetGenerationEntry
            >,
          ),
          TiebanshenshuDatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$TiebanshenshuDatasetGenerationsTableTableManager(
    _$TiebanshenshuDatabase db,
    $TiebanshenshuDatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TiebanshenshuDatasetGenerationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TiebanshenshuDatasetGenerationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TiebanshenshuDatasetGenerationsTableAnnotationComposer(
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
              }) => TiebanshenshuDatasetGenerationsCompanion(
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
              }) => TiebanshenshuDatasetGenerationsCompanion.insert(
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

typedef $$TiebanshenshuDatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$TiebanshenshuDatabase,
      $TiebanshenshuDatasetGenerationsTable,
      TiebanshenshuDatasetGenerationEntry,
      $$TiebanshenshuDatasetGenerationsTableFilterComposer,
      $$TiebanshenshuDatasetGenerationsTableOrderingComposer,
      $$TiebanshenshuDatasetGenerationsTableAnnotationComposer,
      $$TiebanshenshuDatasetGenerationsTableCreateCompanionBuilder,
      $$TiebanshenshuDatasetGenerationsTableUpdateCompanionBuilder,
      (
        TiebanshenshuDatasetGenerationEntry,
        BaseReferences<
          _$TiebanshenshuDatabase,
          $TiebanshenshuDatasetGenerationsTable,
          TiebanshenshuDatasetGenerationEntry
        >,
      ),
      TiebanshenshuDatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $TiebanshenshuDatabaseManager {
  final _$TiebanshenshuDatabase _db;
  $TiebanshenshuDatabaseManager(this._db);
  $$TiaoWenEntriesTableTableManager get tiaoWenEntries =>
      $$TiaoWenEntriesTableTableManager(_db, _db.tiaoWenEntries);
  $$KaoKeDocumentsTableTableManager get kaoKeDocuments =>
      $$KaoKeDocumentsTableTableManager(_db, _db.kaoKeDocuments);
  $$ShaoZiShuDocumentsTableTableManager get shaoZiShuDocuments =>
      $$ShaoZiShuDocumentsTableTableManager(_db, _db.shaoZiShuDocuments);
  $$FormulaDocumentsTableTableManager get formulaDocuments =>
      $$FormulaDocumentsTableTableManager(_db, _db.formulaDocuments);
  $$TiebanshenshuDatasetGenerationsTableTableManager
  get tiebanshenshuDatasetGenerations =>
      $$TiebanshenshuDatasetGenerationsTableTableManager(
        _db,
        _db.tiebanshenshuDatasetGenerations,
      );
}
