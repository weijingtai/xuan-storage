// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qizhengsiyu_database.dart';

// ignore_for_file: type=lint
class $StarPositionStatusesTable extends StarPositionStatuses
    with TableInfo<$StarPositionStatusesTable, StarPositionStatusEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StarPositionStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classNameMeta = const VerificationMeta(
    'className',
  );
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
    'class_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starMeta = const VerificationMeta('star');
  @override
  late final GeneratedColumn<String> star = GeneratedColumn<String>(
    'star',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionStatusTypeMeta =
      const VerificationMeta('positionStatusType');
  @override
  late final GeneratedColumn<String> positionStatusType =
      GeneratedColumn<String>(
        'position_status_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _positionListJsonMeta = const VerificationMeta(
    'positionListJson',
  );
  @override
  late final GeneratedColumn<String> positionListJson = GeneratedColumn<String>(
    'position_list_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    className,
    star,
    positionStatusType,
    positionListJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'star_position_status';
  @override
  VerificationContext validateIntegrity(
    Insertable<StarPositionStatusEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_name')) {
      context.handle(
        _classNameMeta,
        className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta),
      );
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('star')) {
      context.handle(
        _starMeta,
        star.isAcceptableOrUnknown(data['star']!, _starMeta),
      );
    } else if (isInserting) {
      context.missing(_starMeta);
    }
    if (data.containsKey('position_status_type')) {
      context.handle(
        _positionStatusTypeMeta,
        positionStatusType.isAcceptableOrUnknown(
          data['position_status_type']!,
          _positionStatusTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionStatusTypeMeta);
    }
    if (data.containsKey('position_list_json')) {
      context.handle(
        _positionListJsonMeta,
        positionListJson.isAcceptableOrUnknown(
          data['position_list_json']!,
          _positionListJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionListJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StarPositionStatusEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StarPositionStatusEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      className: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_name'],
      )!,
      star: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}star'],
      )!,
      positionStatusType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_status_type'],
      )!,
      positionListJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_list_json'],
      )!,
    );
  }

  @override
  $StarPositionStatusesTable createAlias(String alias) {
    return $StarPositionStatusesTable(attachedDatabase, alias);
  }
}

class StarPositionStatusEntry extends DataClass
    implements Insertable<StarPositionStatusEntry> {
  final int id;
  final String className;
  final String star;
  final String positionStatusType;
  final String positionListJson;
  const StarPositionStatusEntry({
    required this.id,
    required this.className,
    required this.star,
    required this.positionStatusType,
    required this.positionListJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_name'] = Variable<String>(className);
    map['star'] = Variable<String>(star);
    map['position_status_type'] = Variable<String>(positionStatusType);
    map['position_list_json'] = Variable<String>(positionListJson);
    return map;
  }

  StarPositionStatusesCompanion toCompanion(bool nullToAbsent) {
    return StarPositionStatusesCompanion(
      id: Value(id),
      className: Value(className),
      star: Value(star),
      positionStatusType: Value(positionStatusType),
      positionListJson: Value(positionListJson),
    );
  }

  factory StarPositionStatusEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StarPositionStatusEntry(
      id: serializer.fromJson<int>(json['id']),
      className: serializer.fromJson<String>(json['className']),
      star: serializer.fromJson<String>(json['star']),
      positionStatusType: serializer.fromJson<String>(
        json['positionStatusType'],
      ),
      positionListJson: serializer.fromJson<String>(json['positionListJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'className': serializer.toJson<String>(className),
      'star': serializer.toJson<String>(star),
      'positionStatusType': serializer.toJson<String>(positionStatusType),
      'positionListJson': serializer.toJson<String>(positionListJson),
    };
  }

  StarPositionStatusEntry copyWith({
    int? id,
    String? className,
    String? star,
    String? positionStatusType,
    String? positionListJson,
  }) => StarPositionStatusEntry(
    id: id ?? this.id,
    className: className ?? this.className,
    star: star ?? this.star,
    positionStatusType: positionStatusType ?? this.positionStatusType,
    positionListJson: positionListJson ?? this.positionListJson,
  );
  StarPositionStatusEntry copyWithCompanion(
    StarPositionStatusesCompanion data,
  ) {
    return StarPositionStatusEntry(
      id: data.id.present ? data.id.value : this.id,
      className: data.className.present ? data.className.value : this.className,
      star: data.star.present ? data.star.value : this.star,
      positionStatusType: data.positionStatusType.present
          ? data.positionStatusType.value
          : this.positionStatusType,
      positionListJson: data.positionListJson.present
          ? data.positionListJson.value
          : this.positionListJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StarPositionStatusEntry(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('star: $star, ')
          ..write('positionStatusType: $positionStatusType, ')
          ..write('positionListJson: $positionListJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, className, star, positionStatusType, positionListJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StarPositionStatusEntry &&
          other.id == this.id &&
          other.className == this.className &&
          other.star == this.star &&
          other.positionStatusType == this.positionStatusType &&
          other.positionListJson == this.positionListJson);
}

class StarPositionStatusesCompanion
    extends UpdateCompanion<StarPositionStatusEntry> {
  final Value<int> id;
  final Value<String> className;
  final Value<String> star;
  final Value<String> positionStatusType;
  final Value<String> positionListJson;
  const StarPositionStatusesCompanion({
    this.id = const Value.absent(),
    this.className = const Value.absent(),
    this.star = const Value.absent(),
    this.positionStatusType = const Value.absent(),
    this.positionListJson = const Value.absent(),
  });
  StarPositionStatusesCompanion.insert({
    this.id = const Value.absent(),
    required String className,
    required String star,
    required String positionStatusType,
    required String positionListJson,
  }) : className = Value(className),
       star = Value(star),
       positionStatusType = Value(positionStatusType),
       positionListJson = Value(positionListJson);
  static Insertable<StarPositionStatusEntry> custom({
    Expression<int>? id,
    Expression<String>? className,
    Expression<String>? star,
    Expression<String>? positionStatusType,
    Expression<String>? positionListJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (className != null) 'class_name': className,
      if (star != null) 'star': star,
      if (positionStatusType != null)
        'position_status_type': positionStatusType,
      if (positionListJson != null) 'position_list_json': positionListJson,
    });
  }

  StarPositionStatusesCompanion copyWith({
    Value<int>? id,
    Value<String>? className,
    Value<String>? star,
    Value<String>? positionStatusType,
    Value<String>? positionListJson,
  }) {
    return StarPositionStatusesCompanion(
      id: id ?? this.id,
      className: className ?? this.className,
      star: star ?? this.star,
      positionStatusType: positionStatusType ?? this.positionStatusType,
      positionListJson: positionListJson ?? this.positionListJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (star.present) {
      map['star'] = Variable<String>(star.value);
    }
    if (positionStatusType.present) {
      map['position_status_type'] = Variable<String>(positionStatusType.value);
    }
    if (positionListJson.present) {
      map['position_list_json'] = Variable<String>(positionListJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StarPositionStatusesCompanion(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('star: $star, ')
          ..write('positionStatusType: $positionStatusType, ')
          ..write('positionListJson: $positionListJson')
          ..write(')'))
        .toString();
  }
}

class $GeJuPatternsTable extends GeJuPatterns
    with TableInfo<$GeJuPatternsTable, GeJuPatternEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuPatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasesMeta = const VerificationMeta(
    'aliases',
  );
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
    'aliases',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originNotesMeta = const VerificationMeta(
    'originNotes',
  );
  @override
  late final GeneratedColumn<String> originNotes = GeneratedColumn<String>(
    'origin_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceCountMeta = const VerificationMeta(
    'referenceCount',
  );
  @override
  late final GeneratedColumn<int> referenceCount = GeneratedColumn<int>(
    'reference_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleCountMeta = const VerificationMeta(
    'ruleCount',
  );
  @override
  late final GeneratedColumn<int> ruleCount = GeneratedColumn<int>(
    'rule_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    englishName,
    pinyin,
    aliases,
    categoryId,
    keywords,
    tags,
    description,
    originNotes,
    referenceCount,
    ruleCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_patterns';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeJuPatternEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    }
    if (data.containsKey('aliases')) {
      context.handle(
        _aliasesMeta,
        aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('origin_notes')) {
      context.handle(
        _originNotesMeta,
        originNotes.isAcceptableOrUnknown(
          data['origin_notes']!,
          _originNotesMeta,
        ),
      );
    }
    if (data.containsKey('reference_count')) {
      context.handle(
        _referenceCountMeta,
        referenceCount.isAcceptableOrUnknown(
          data['reference_count']!,
          _referenceCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceCountMeta);
    }
    if (data.containsKey('rule_count')) {
      context.handle(
        _ruleCountMeta,
        ruleCount.isAcceptableOrUnknown(data['rule_count']!, _ruleCountMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuPatternEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuPatternEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      ),
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      ),
      aliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      originNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_notes'],
      ),
      referenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_count'],
      )!,
      ruleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GeJuPatternsTable createAlias(String alias) {
    return $GeJuPatternsTable(attachedDatabase, alias);
  }
}

class GeJuPatternEntry extends DataClass
    implements Insertable<GeJuPatternEntry> {
  final String id;
  final String name;
  final String? englishName;
  final String? pinyin;
  final String? aliases;
  final String categoryId;
  final String? keywords;
  final String? tags;
  final String? description;
  final String? originNotes;
  final int referenceCount;
  final int ruleCount;
  final int createdAt;
  const GeJuPatternEntry({
    required this.id,
    required this.name,
    this.englishName,
    this.pinyin,
    this.aliases,
    required this.categoryId,
    this.keywords,
    this.tags,
    this.description,
    this.originNotes,
    required this.referenceCount,
    required this.ruleCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || englishName != null) {
      map['english_name'] = Variable<String>(englishName);
    }
    if (!nullToAbsent || pinyin != null) {
      map['pinyin'] = Variable<String>(pinyin);
    }
    if (!nullToAbsent || aliases != null) {
      map['aliases'] = Variable<String>(aliases);
    }
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || keywords != null) {
      map['keywords'] = Variable<String>(keywords);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || originNotes != null) {
      map['origin_notes'] = Variable<String>(originNotes);
    }
    map['reference_count'] = Variable<int>(referenceCount);
    map['rule_count'] = Variable<int>(ruleCount);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  GeJuPatternsCompanion toCompanion(bool nullToAbsent) {
    return GeJuPatternsCompanion(
      id: Value(id),
      name: Value(name),
      englishName: englishName == null && nullToAbsent
          ? const Value.absent()
          : Value(englishName),
      pinyin: pinyin == null && nullToAbsent
          ? const Value.absent()
          : Value(pinyin),
      aliases: aliases == null && nullToAbsent
          ? const Value.absent()
          : Value(aliases),
      categoryId: Value(categoryId),
      keywords: keywords == null && nullToAbsent
          ? const Value.absent()
          : Value(keywords),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      originNotes: originNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(originNotes),
      referenceCount: Value(referenceCount),
      ruleCount: Value(ruleCount),
      createdAt: Value(createdAt),
    );
  }

  factory GeJuPatternEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuPatternEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      englishName: serializer.fromJson<String?>(json['englishName']),
      pinyin: serializer.fromJson<String?>(json['pinyin']),
      aliases: serializer.fromJson<String?>(json['aliases']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      keywords: serializer.fromJson<String?>(json['keywords']),
      tags: serializer.fromJson<String?>(json['tags']),
      description: serializer.fromJson<String?>(json['description']),
      originNotes: serializer.fromJson<String?>(json['originNotes']),
      referenceCount: serializer.fromJson<int>(json['referenceCount']),
      ruleCount: serializer.fromJson<int>(json['ruleCount']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'englishName': serializer.toJson<String?>(englishName),
      'pinyin': serializer.toJson<String?>(pinyin),
      'aliases': serializer.toJson<String?>(aliases),
      'categoryId': serializer.toJson<String>(categoryId),
      'keywords': serializer.toJson<String?>(keywords),
      'tags': serializer.toJson<String?>(tags),
      'description': serializer.toJson<String?>(description),
      'originNotes': serializer.toJson<String?>(originNotes),
      'referenceCount': serializer.toJson<int>(referenceCount),
      'ruleCount': serializer.toJson<int>(ruleCount),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  GeJuPatternEntry copyWith({
    String? id,
    String? name,
    Value<String?> englishName = const Value.absent(),
    Value<String?> pinyin = const Value.absent(),
    Value<String?> aliases = const Value.absent(),
    String? categoryId,
    Value<String?> keywords = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> originNotes = const Value.absent(),
    int? referenceCount,
    int? ruleCount,
    int? createdAt,
  }) => GeJuPatternEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    englishName: englishName.present ? englishName.value : this.englishName,
    pinyin: pinyin.present ? pinyin.value : this.pinyin,
    aliases: aliases.present ? aliases.value : this.aliases,
    categoryId: categoryId ?? this.categoryId,
    keywords: keywords.present ? keywords.value : this.keywords,
    tags: tags.present ? tags.value : this.tags,
    description: description.present ? description.value : this.description,
    originNotes: originNotes.present ? originNotes.value : this.originNotes,
    referenceCount: referenceCount ?? this.referenceCount,
    ruleCount: ruleCount ?? this.ruleCount,
    createdAt: createdAt ?? this.createdAt,
  );
  GeJuPatternEntry copyWithCompanion(GeJuPatternsCompanion data) {
    return GeJuPatternEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      tags: data.tags.present ? data.tags.value : this.tags,
      description: data.description.present
          ? data.description.value
          : this.description,
      originNotes: data.originNotes.present
          ? data.originNotes.value
          : this.originNotes,
      referenceCount: data.referenceCount.present
          ? data.referenceCount.value
          : this.referenceCount,
      ruleCount: data.ruleCount.present ? data.ruleCount.value : this.ruleCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuPatternEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('pinyin: $pinyin, ')
          ..write('aliases: $aliases, ')
          ..write('categoryId: $categoryId, ')
          ..write('keywords: $keywords, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('originNotes: $originNotes, ')
          ..write('referenceCount: $referenceCount, ')
          ..write('ruleCount: $ruleCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    englishName,
    pinyin,
    aliases,
    categoryId,
    keywords,
    tags,
    description,
    originNotes,
    referenceCount,
    ruleCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuPatternEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.englishName == this.englishName &&
          other.pinyin == this.pinyin &&
          other.aliases == this.aliases &&
          other.categoryId == this.categoryId &&
          other.keywords == this.keywords &&
          other.tags == this.tags &&
          other.description == this.description &&
          other.originNotes == this.originNotes &&
          other.referenceCount == this.referenceCount &&
          other.ruleCount == this.ruleCount &&
          other.createdAt == this.createdAt);
}

class GeJuPatternsCompanion extends UpdateCompanion<GeJuPatternEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> englishName;
  final Value<String?> pinyin;
  final Value<String?> aliases;
  final Value<String> categoryId;
  final Value<String?> keywords;
  final Value<String?> tags;
  final Value<String?> description;
  final Value<String?> originNotes;
  final Value<int> referenceCount;
  final Value<int> ruleCount;
  final Value<int> createdAt;
  final Value<int> rowid;
  const GeJuPatternsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.englishName = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.aliases = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.keywords = const Value.absent(),
    this.tags = const Value.absent(),
    this.description = const Value.absent(),
    this.originNotes = const Value.absent(),
    this.referenceCount = const Value.absent(),
    this.ruleCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuPatternsCompanion.insert({
    required String id,
    required String name,
    this.englishName = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.aliases = const Value.absent(),
    required String categoryId,
    this.keywords = const Value.absent(),
    this.tags = const Value.absent(),
    this.description = const Value.absent(),
    this.originNotes = const Value.absent(),
    required int referenceCount,
    required int ruleCount,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       categoryId = Value(categoryId),
       referenceCount = Value(referenceCount),
       ruleCount = Value(ruleCount),
       createdAt = Value(createdAt);
  static Insertable<GeJuPatternEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? englishName,
    Expression<String>? pinyin,
    Expression<String>? aliases,
    Expression<String>? categoryId,
    Expression<String>? keywords,
    Expression<String>? tags,
    Expression<String>? description,
    Expression<String>? originNotes,
    Expression<int>? referenceCount,
    Expression<int>? ruleCount,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (englishName != null) 'english_name': englishName,
      if (pinyin != null) 'pinyin': pinyin,
      if (aliases != null) 'aliases': aliases,
      if (categoryId != null) 'category_id': categoryId,
      if (keywords != null) 'keywords': keywords,
      if (tags != null) 'tags': tags,
      if (description != null) 'description': description,
      if (originNotes != null) 'origin_notes': originNotes,
      if (referenceCount != null) 'reference_count': referenceCount,
      if (ruleCount != null) 'rule_count': ruleCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuPatternsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? englishName,
    Value<String?>? pinyin,
    Value<String?>? aliases,
    Value<String>? categoryId,
    Value<String?>? keywords,
    Value<String?>? tags,
    Value<String?>? description,
    Value<String?>? originNotes,
    Value<int>? referenceCount,
    Value<int>? ruleCount,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return GeJuPatternsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      pinyin: pinyin ?? this.pinyin,
      aliases: aliases ?? this.aliases,
      categoryId: categoryId ?? this.categoryId,
      keywords: keywords ?? this.keywords,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      originNotes: originNotes ?? this.originNotes,
      referenceCount: referenceCount ?? this.referenceCount,
      ruleCount: ruleCount ?? this.ruleCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (originNotes.present) {
      map['origin_notes'] = Variable<String>(originNotes.value);
    }
    if (referenceCount.present) {
      map['reference_count'] = Variable<int>(referenceCount.value);
    }
    if (ruleCount.present) {
      map['rule_count'] = Variable<int>(ruleCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuPatternsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('pinyin: $pinyin, ')
          ..write('aliases: $aliases, ')
          ..write('categoryId: $categoryId, ')
          ..write('keywords: $keywords, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('originNotes: $originNotes, ')
          ..write('referenceCount: $referenceCount, ')
          ..write('ruleCount: $ruleCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuSchoolsTable extends GeJuSchools
    with TableInfo<$GeJuSchoolsTable, GeJuSchoolEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuSchoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eraMeta = const VerificationMeta('era');
  @override
  late final GeneratedColumn<String> era = GeneratedColumn<String>(
    'era',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _founderMeta = const VerificationMeta(
    'founder',
  );
  @override
  late final GeneratedColumn<String> founder = GeneratedColumn<String>(
    'founder',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleCountMeta = const VerificationMeta(
    'ruleCount',
  );
  @override
  late final GeneratedColumn<int> ruleCount = GeneratedColumn<int>(
    'rule_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    era,
    founder,
    description,
    isActive,
    ruleCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_schools';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeJuSchoolEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('era')) {
      context.handle(
        _eraMeta,
        era.isAcceptableOrUnknown(data['era']!, _eraMeta),
      );
    }
    if (data.containsKey('founder')) {
      context.handle(
        _founderMeta,
        founder.isAcceptableOrUnknown(data['founder']!, _founderMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('rule_count')) {
      context.handle(
        _ruleCountMeta,
        ruleCount.isAcceptableOrUnknown(data['rule_count']!, _ruleCountMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuSchoolEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuSchoolEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      era: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}era'],
      ),
      founder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}founder'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      ruleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GeJuSchoolsTable createAlias(String alias) {
    return $GeJuSchoolsTable(attachedDatabase, alias);
  }
}

class GeJuSchoolEntry extends DataClass implements Insertable<GeJuSchoolEntry> {
  final String id;
  final String name;
  final String type;
  final String? era;
  final String? founder;
  final String? description;
  final int isActive;
  final int ruleCount;
  final int createdAt;
  const GeJuSchoolEntry({
    required this.id,
    required this.name,
    required this.type,
    this.era,
    this.founder,
    this.description,
    required this.isActive,
    required this.ruleCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || era != null) {
      map['era'] = Variable<String>(era);
    }
    if (!nullToAbsent || founder != null) {
      map['founder'] = Variable<String>(founder);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<int>(isActive);
    map['rule_count'] = Variable<int>(ruleCount);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  GeJuSchoolsCompanion toCompanion(bool nullToAbsent) {
    return GeJuSchoolsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      era: era == null && nullToAbsent ? const Value.absent() : Value(era),
      founder: founder == null && nullToAbsent
          ? const Value.absent()
          : Value(founder),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      ruleCount: Value(ruleCount),
      createdAt: Value(createdAt),
    );
  }

  factory GeJuSchoolEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuSchoolEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      era: serializer.fromJson<String?>(json['era']),
      founder: serializer.fromJson<String?>(json['founder']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<int>(json['isActive']),
      ruleCount: serializer.fromJson<int>(json['ruleCount']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'era': serializer.toJson<String?>(era),
      'founder': serializer.toJson<String?>(founder),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<int>(isActive),
      'ruleCount': serializer.toJson<int>(ruleCount),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  GeJuSchoolEntry copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> era = const Value.absent(),
    Value<String?> founder = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? isActive,
    int? ruleCount,
    int? createdAt,
  }) => GeJuSchoolEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    era: era.present ? era.value : this.era,
    founder: founder.present ? founder.value : this.founder,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    ruleCount: ruleCount ?? this.ruleCount,
    createdAt: createdAt ?? this.createdAt,
  );
  GeJuSchoolEntry copyWithCompanion(GeJuSchoolsCompanion data) {
    return GeJuSchoolEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      era: data.era.present ? data.era.value : this.era,
      founder: data.founder.present ? data.founder.value : this.founder,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      ruleCount: data.ruleCount.present ? data.ruleCount.value : this.ruleCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuSchoolEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('era: $era, ')
          ..write('founder: $founder, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('ruleCount: $ruleCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    era,
    founder,
    description,
    isActive,
    ruleCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuSchoolEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.era == this.era &&
          other.founder == this.founder &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.ruleCount == this.ruleCount &&
          other.createdAt == this.createdAt);
}

class GeJuSchoolsCompanion extends UpdateCompanion<GeJuSchoolEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> era;
  final Value<String?> founder;
  final Value<String?> description;
  final Value<int> isActive;
  final Value<int> ruleCount;
  final Value<int> createdAt;
  final Value<int> rowid;
  const GeJuSchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.era = const Value.absent(),
    this.founder = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.ruleCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuSchoolsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.era = const Value.absent(),
    this.founder = const Value.absent(),
    this.description = const Value.absent(),
    required int isActive,
    required int ruleCount,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       isActive = Value(isActive),
       ruleCount = Value(ruleCount),
       createdAt = Value(createdAt);
  static Insertable<GeJuSchoolEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? era,
    Expression<String>? founder,
    Expression<String>? description,
    Expression<int>? isActive,
    Expression<int>? ruleCount,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (era != null) 'era': era,
      if (founder != null) 'founder': founder,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (ruleCount != null) 'rule_count': ruleCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuSchoolsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? era,
    Value<String?>? founder,
    Value<String?>? description,
    Value<int>? isActive,
    Value<int>? ruleCount,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return GeJuSchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      era: era ?? this.era,
      founder: founder ?? this.founder,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      ruleCount: ruleCount ?? this.ruleCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (era.present) {
      map['era'] = Variable<String>(era.value);
    }
    if (founder.present) {
      map['founder'] = Variable<String>(founder.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (ruleCount.present) {
      map['rule_count'] = Variable<int>(ruleCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuSchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('era: $era, ')
          ..write('founder: $founder, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('ruleCount: $ruleCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuCategoriesTable extends GeJuCategories
    with TableInfo<$GeJuCategoriesTable, GeJuCategoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternCountMeta = const VerificationMeta(
    'patternCount',
  );
  @override
  late final GeneratedColumn<int> patternCount = GeneratedColumn<int>(
    'pattern_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    order,
    parentId,
    isActive,
    patternCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeJuCategoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('pattern_count')) {
      context.handle(
        _patternCountMeta,
        patternCount.isAcceptableOrUnknown(
          data['pattern_count']!,
          _patternCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuCategoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuCategoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      patternCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pattern_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GeJuCategoriesTable createAlias(String alias) {
    return $GeJuCategoriesTable(attachedDatabase, alias);
  }
}

class GeJuCategoryEntry extends DataClass
    implements Insertable<GeJuCategoryEntry> {
  final String id;
  final String name;
  final int order;
  final String? parentId;
  final int isActive;
  final int patternCount;
  final int createdAt;
  const GeJuCategoryEntry({
    required this.id,
    required this.name,
    required this.order,
    this.parentId,
    required this.isActive,
    required this.patternCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['is_active'] = Variable<int>(isActive);
    map['pattern_count'] = Variable<int>(patternCount);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  GeJuCategoriesCompanion toCompanion(bool nullToAbsent) {
    return GeJuCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      order: Value(order),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isActive: Value(isActive),
      patternCount: Value(patternCount),
      createdAt: Value(createdAt),
    );
  }

  factory GeJuCategoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuCategoryEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      order: serializer.fromJson<int>(json['order']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      isActive: serializer.fromJson<int>(json['isActive']),
      patternCount: serializer.fromJson<int>(json['patternCount']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'order': serializer.toJson<int>(order),
      'parentId': serializer.toJson<String?>(parentId),
      'isActive': serializer.toJson<int>(isActive),
      'patternCount': serializer.toJson<int>(patternCount),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  GeJuCategoryEntry copyWith({
    String? id,
    String? name,
    int? order,
    Value<String?> parentId = const Value.absent(),
    int? isActive,
    int? patternCount,
    int? createdAt,
  }) => GeJuCategoryEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    order: order ?? this.order,
    parentId: parentId.present ? parentId.value : this.parentId,
    isActive: isActive ?? this.isActive,
    patternCount: patternCount ?? this.patternCount,
    createdAt: createdAt ?? this.createdAt,
  );
  GeJuCategoryEntry copyWithCompanion(GeJuCategoriesCompanion data) {
    return GeJuCategoryEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      order: data.order.present ? data.order.value : this.order,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      patternCount: data.patternCount.present
          ? data.patternCount.value
          : this.patternCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuCategoryEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('parentId: $parentId, ')
          ..write('isActive: $isActive, ')
          ..write('patternCount: $patternCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, order, parentId, isActive, patternCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuCategoryEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.order == this.order &&
          other.parentId == this.parentId &&
          other.isActive == this.isActive &&
          other.patternCount == this.patternCount &&
          other.createdAt == this.createdAt);
}

class GeJuCategoriesCompanion extends UpdateCompanion<GeJuCategoryEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> order;
  final Value<String?> parentId;
  final Value<int> isActive;
  final Value<int> patternCount;
  final Value<int> createdAt;
  final Value<int> rowid;
  const GeJuCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.order = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.patternCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuCategoriesCompanion.insert({
    required String id,
    required String name,
    required int order,
    this.parentId = const Value.absent(),
    required int isActive,
    required int patternCount,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       order = Value(order),
       isActive = Value(isActive),
       patternCount = Value(patternCount),
       createdAt = Value(createdAt);
  static Insertable<GeJuCategoryEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? order,
    Expression<String>? parentId,
    Expression<int>? isActive,
    Expression<int>? patternCount,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (order != null) 'order': order,
      if (parentId != null) 'parent_id': parentId,
      if (isActive != null) 'is_active': isActive,
      if (patternCount != null) 'pattern_count': patternCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? order,
    Value<String?>? parentId,
    Value<int>? isActive,
    Value<int>? patternCount,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return GeJuCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
      patternCount: patternCount ?? this.patternCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (patternCount.present) {
      map['pattern_count'] = Variable<int>(patternCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('parentId: $parentId, ')
          ..write('isActive: $isActive, ')
          ..write('patternCount: $patternCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuRulesTable extends GeJuRules
    with TableInfo<$GeJuRulesTable, GeJuRuleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _patternIdMeta = const VerificationMeta(
    'patternId',
  );
  @override
  late final GeneratedColumn<String> patternId = GeneratedColumn<String>(
    'pattern_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jixiongMeta = const VerificationMeta(
    'jixiong',
  );
  @override
  late final GeneratedColumn<String> jixiong = GeneratedColumn<String>(
    'jixiong',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _geJuTypeMeta = const VerificationMeta(
    'geJuType',
  );
  @override
  late final GeneratedColumn<String> geJuType = GeneratedColumn<String>(
    'ge_ju_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coordinateSystemMeta = const VerificationMeta(
    'coordinateSystem',
  );
  @override
  late final GeneratedColumn<String> coordinateSystem = GeneratedColumn<String>(
    'coordinate_system',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionsMeta = const VerificationMeta(
    'conditions',
  );
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
    'conditions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assertionMeta = const VerificationMeta(
    'assertion',
  );
  @override
  late final GeneratedColumn<String> assertion = GeneratedColumn<String>(
    'assertion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _briefMeta = const VerificationMeta('brief');
  @override
  late final GeneratedColumn<String> brief = GeneratedColumn<String>(
    'brief',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<String> chapter = GeneratedColumn<String>(
    'chapter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalTextMeta = const VerificationMeta(
    'originalText',
  );
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
    'original_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionRemarkMeta = const VerificationMeta(
    'versionRemark',
  );
  @override
  late final GeneratedColumn<String> versionRemark = GeneratedColumn<String>(
    'version_remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<int> isVerified = GeneratedColumn<int>(
    'is_verified',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewCountMeta = const VerificationMeta(
    'viewCount',
  );
  @override
  late final GeneratedColumn<int> viewCount = GeneratedColumn<int>(
    'view_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patternId,
    schoolId,
    jixiong,
    geJuType,
    scope,
    coordinateSystem,
    conditions,
    assertion,
    brief,
    chapter,
    originalText,
    explanation,
    notes,
    version,
    versionRemark,
    isActive,
    isVerified,
    priority,
    viewCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeJuRuleEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pattern_id')) {
      context.handle(
        _patternIdMeta,
        patternId.isAcceptableOrUnknown(data['pattern_id']!, _patternIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patternIdMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('jixiong')) {
      context.handle(
        _jixiongMeta,
        jixiong.isAcceptableOrUnknown(data['jixiong']!, _jixiongMeta),
      );
    } else if (isInserting) {
      context.missing(_jixiongMeta);
    }
    if (data.containsKey('ge_ju_type')) {
      context.handle(
        _geJuTypeMeta,
        geJuType.isAcceptableOrUnknown(data['ge_ju_type']!, _geJuTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_geJuTypeMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('coordinate_system')) {
      context.handle(
        _coordinateSystemMeta,
        coordinateSystem.isAcceptableOrUnknown(
          data['coordinate_system']!,
          _coordinateSystemMeta,
        ),
      );
    }
    if (data.containsKey('conditions')) {
      context.handle(
        _conditionsMeta,
        conditions.isAcceptableOrUnknown(data['conditions']!, _conditionsMeta),
      );
    }
    if (data.containsKey('assertion')) {
      context.handle(
        _assertionMeta,
        assertion.isAcceptableOrUnknown(data['assertion']!, _assertionMeta),
      );
    }
    if (data.containsKey('brief')) {
      context.handle(
        _briefMeta,
        brief.isAcceptableOrUnknown(data['brief']!, _briefMeta),
      );
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    }
    if (data.containsKey('original_text')) {
      context.handle(
        _originalTextMeta,
        originalText.isAcceptableOrUnknown(
          data['original_text']!,
          _originalTextMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('version_remark')) {
      context.handle(
        _versionRemarkMeta,
        versionRemark.isAcceptableOrUnknown(
          data['version_remark']!,
          _versionRemarkMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_isVerifiedMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('view_count')) {
      context.handle(
        _viewCountMeta,
        viewCount.isAcceptableOrUnknown(data['view_count']!, _viewCountMeta),
      );
    } else if (isInserting) {
      context.missing(_viewCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuRuleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuRuleEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patternId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      jixiong: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jixiong'],
      )!,
      geJuType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ge_ju_type'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      coordinateSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coordinate_system'],
      ),
      conditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conditions'],
      ),
      assertion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assertion'],
      ),
      brief: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brief'],
      ),
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter'],
      ),
      originalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_text'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      versionRemark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_remark'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_verified'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      viewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}view_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GeJuRulesTable createAlias(String alias) {
    return $GeJuRulesTable(attachedDatabase, alias);
  }
}

class GeJuRuleEntry extends DataClass implements Insertable<GeJuRuleEntry> {
  final int id;
  final String patternId;
  final String schoolId;
  final String jixiong;
  final String geJuType;
  final String scope;
  final String? coordinateSystem;
  final String? conditions;
  final String? assertion;
  final String? brief;
  final String? chapter;
  final String? originalText;
  final String? explanation;
  final String? notes;
  final String version;
  final String? versionRemark;
  final int isActive;
  final int isVerified;
  final int priority;
  final int viewCount;
  final int createdAt;
  final int updatedAt;
  const GeJuRuleEntry({
    required this.id,
    required this.patternId,
    required this.schoolId,
    required this.jixiong,
    required this.geJuType,
    required this.scope,
    this.coordinateSystem,
    this.conditions,
    this.assertion,
    this.brief,
    this.chapter,
    this.originalText,
    this.explanation,
    this.notes,
    required this.version,
    this.versionRemark,
    required this.isActive,
    required this.isVerified,
    required this.priority,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pattern_id'] = Variable<String>(patternId);
    map['school_id'] = Variable<String>(schoolId);
    map['jixiong'] = Variable<String>(jixiong);
    map['ge_ju_type'] = Variable<String>(geJuType);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || coordinateSystem != null) {
      map['coordinate_system'] = Variable<String>(coordinateSystem);
    }
    if (!nullToAbsent || conditions != null) {
      map['conditions'] = Variable<String>(conditions);
    }
    if (!nullToAbsent || assertion != null) {
      map['assertion'] = Variable<String>(assertion);
    }
    if (!nullToAbsent || brief != null) {
      map['brief'] = Variable<String>(brief);
    }
    if (!nullToAbsent || chapter != null) {
      map['chapter'] = Variable<String>(chapter);
    }
    if (!nullToAbsent || originalText != null) {
      map['original_text'] = Variable<String>(originalText);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || versionRemark != null) {
      map['version_remark'] = Variable<String>(versionRemark);
    }
    map['is_active'] = Variable<int>(isActive);
    map['is_verified'] = Variable<int>(isVerified);
    map['priority'] = Variable<int>(priority);
    map['view_count'] = Variable<int>(viewCount);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  GeJuRulesCompanion toCompanion(bool nullToAbsent) {
    return GeJuRulesCompanion(
      id: Value(id),
      patternId: Value(patternId),
      schoolId: Value(schoolId),
      jixiong: Value(jixiong),
      geJuType: Value(geJuType),
      scope: Value(scope),
      coordinateSystem: coordinateSystem == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinateSystem),
      conditions: conditions == null && nullToAbsent
          ? const Value.absent()
          : Value(conditions),
      assertion: assertion == null && nullToAbsent
          ? const Value.absent()
          : Value(assertion),
      brief: brief == null && nullToAbsent
          ? const Value.absent()
          : Value(brief),
      chapter: chapter == null && nullToAbsent
          ? const Value.absent()
          : Value(chapter),
      originalText: originalText == null && nullToAbsent
          ? const Value.absent()
          : Value(originalText),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      version: Value(version),
      versionRemark: versionRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(versionRemark),
      isActive: Value(isActive),
      isVerified: Value(isVerified),
      priority: Value(priority),
      viewCount: Value(viewCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GeJuRuleEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuRuleEntry(
      id: serializer.fromJson<int>(json['id']),
      patternId: serializer.fromJson<String>(json['patternId']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      jixiong: serializer.fromJson<String>(json['jixiong']),
      geJuType: serializer.fromJson<String>(json['geJuType']),
      scope: serializer.fromJson<String>(json['scope']),
      coordinateSystem: serializer.fromJson<String?>(json['coordinateSystem']),
      conditions: serializer.fromJson<String?>(json['conditions']),
      assertion: serializer.fromJson<String?>(json['assertion']),
      brief: serializer.fromJson<String?>(json['brief']),
      chapter: serializer.fromJson<String?>(json['chapter']),
      originalText: serializer.fromJson<String?>(json['originalText']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      notes: serializer.fromJson<String?>(json['notes']),
      version: serializer.fromJson<String>(json['version']),
      versionRemark: serializer.fromJson<String?>(json['versionRemark']),
      isActive: serializer.fromJson<int>(json['isActive']),
      isVerified: serializer.fromJson<int>(json['isVerified']),
      priority: serializer.fromJson<int>(json['priority']),
      viewCount: serializer.fromJson<int>(json['viewCount']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patternId': serializer.toJson<String>(patternId),
      'schoolId': serializer.toJson<String>(schoolId),
      'jixiong': serializer.toJson<String>(jixiong),
      'geJuType': serializer.toJson<String>(geJuType),
      'scope': serializer.toJson<String>(scope),
      'coordinateSystem': serializer.toJson<String?>(coordinateSystem),
      'conditions': serializer.toJson<String?>(conditions),
      'assertion': serializer.toJson<String?>(assertion),
      'brief': serializer.toJson<String?>(brief),
      'chapter': serializer.toJson<String?>(chapter),
      'originalText': serializer.toJson<String?>(originalText),
      'explanation': serializer.toJson<String?>(explanation),
      'notes': serializer.toJson<String?>(notes),
      'version': serializer.toJson<String>(version),
      'versionRemark': serializer.toJson<String?>(versionRemark),
      'isActive': serializer.toJson<int>(isActive),
      'isVerified': serializer.toJson<int>(isVerified),
      'priority': serializer.toJson<int>(priority),
      'viewCount': serializer.toJson<int>(viewCount),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  GeJuRuleEntry copyWith({
    int? id,
    String? patternId,
    String? schoolId,
    String? jixiong,
    String? geJuType,
    String? scope,
    Value<String?> coordinateSystem = const Value.absent(),
    Value<String?> conditions = const Value.absent(),
    Value<String?> assertion = const Value.absent(),
    Value<String?> brief = const Value.absent(),
    Value<String?> chapter = const Value.absent(),
    Value<String?> originalText = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? version,
    Value<String?> versionRemark = const Value.absent(),
    int? isActive,
    int? isVerified,
    int? priority,
    int? viewCount,
    int? createdAt,
    int? updatedAt,
  }) => GeJuRuleEntry(
    id: id ?? this.id,
    patternId: patternId ?? this.patternId,
    schoolId: schoolId ?? this.schoolId,
    jixiong: jixiong ?? this.jixiong,
    geJuType: geJuType ?? this.geJuType,
    scope: scope ?? this.scope,
    coordinateSystem: coordinateSystem.present
        ? coordinateSystem.value
        : this.coordinateSystem,
    conditions: conditions.present ? conditions.value : this.conditions,
    assertion: assertion.present ? assertion.value : this.assertion,
    brief: brief.present ? brief.value : this.brief,
    chapter: chapter.present ? chapter.value : this.chapter,
    originalText: originalText.present ? originalText.value : this.originalText,
    explanation: explanation.present ? explanation.value : this.explanation,
    notes: notes.present ? notes.value : this.notes,
    version: version ?? this.version,
    versionRemark: versionRemark.present
        ? versionRemark.value
        : this.versionRemark,
    isActive: isActive ?? this.isActive,
    isVerified: isVerified ?? this.isVerified,
    priority: priority ?? this.priority,
    viewCount: viewCount ?? this.viewCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GeJuRuleEntry copyWithCompanion(GeJuRulesCompanion data) {
    return GeJuRuleEntry(
      id: data.id.present ? data.id.value : this.id,
      patternId: data.patternId.present ? data.patternId.value : this.patternId,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      jixiong: data.jixiong.present ? data.jixiong.value : this.jixiong,
      geJuType: data.geJuType.present ? data.geJuType.value : this.geJuType,
      scope: data.scope.present ? data.scope.value : this.scope,
      coordinateSystem: data.coordinateSystem.present
          ? data.coordinateSystem.value
          : this.coordinateSystem,
      conditions: data.conditions.present
          ? data.conditions.value
          : this.conditions,
      assertion: data.assertion.present ? data.assertion.value : this.assertion,
      brief: data.brief.present ? data.brief.value : this.brief,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      notes: data.notes.present ? data.notes.value : this.notes,
      version: data.version.present ? data.version.value : this.version,
      versionRemark: data.versionRemark.present
          ? data.versionRemark.value
          : this.versionRemark,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
      priority: data.priority.present ? data.priority.value : this.priority,
      viewCount: data.viewCount.present ? data.viewCount.value : this.viewCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuRuleEntry(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('schoolId: $schoolId, ')
          ..write('jixiong: $jixiong, ')
          ..write('geJuType: $geJuType, ')
          ..write('scope: $scope, ')
          ..write('coordinateSystem: $coordinateSystem, ')
          ..write('conditions: $conditions, ')
          ..write('assertion: $assertion, ')
          ..write('brief: $brief, ')
          ..write('chapter: $chapter, ')
          ..write('originalText: $originalText, ')
          ..write('explanation: $explanation, ')
          ..write('notes: $notes, ')
          ..write('version: $version, ')
          ..write('versionRemark: $versionRemark, ')
          ..write('isActive: $isActive, ')
          ..write('isVerified: $isVerified, ')
          ..write('priority: $priority, ')
          ..write('viewCount: $viewCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    patternId,
    schoolId,
    jixiong,
    geJuType,
    scope,
    coordinateSystem,
    conditions,
    assertion,
    brief,
    chapter,
    originalText,
    explanation,
    notes,
    version,
    versionRemark,
    isActive,
    isVerified,
    priority,
    viewCount,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuRuleEntry &&
          other.id == this.id &&
          other.patternId == this.patternId &&
          other.schoolId == this.schoolId &&
          other.jixiong == this.jixiong &&
          other.geJuType == this.geJuType &&
          other.scope == this.scope &&
          other.coordinateSystem == this.coordinateSystem &&
          other.conditions == this.conditions &&
          other.assertion == this.assertion &&
          other.brief == this.brief &&
          other.chapter == this.chapter &&
          other.originalText == this.originalText &&
          other.explanation == this.explanation &&
          other.notes == this.notes &&
          other.version == this.version &&
          other.versionRemark == this.versionRemark &&
          other.isActive == this.isActive &&
          other.isVerified == this.isVerified &&
          other.priority == this.priority &&
          other.viewCount == this.viewCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GeJuRulesCompanion extends UpdateCompanion<GeJuRuleEntry> {
  final Value<int> id;
  final Value<String> patternId;
  final Value<String> schoolId;
  final Value<String> jixiong;
  final Value<String> geJuType;
  final Value<String> scope;
  final Value<String?> coordinateSystem;
  final Value<String?> conditions;
  final Value<String?> assertion;
  final Value<String?> brief;
  final Value<String?> chapter;
  final Value<String?> originalText;
  final Value<String?> explanation;
  final Value<String?> notes;
  final Value<String> version;
  final Value<String?> versionRemark;
  final Value<int> isActive;
  final Value<int> isVerified;
  final Value<int> priority;
  final Value<int> viewCount;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const GeJuRulesCompanion({
    this.id = const Value.absent(),
    this.patternId = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.jixiong = const Value.absent(),
    this.geJuType = const Value.absent(),
    this.scope = const Value.absent(),
    this.coordinateSystem = const Value.absent(),
    this.conditions = const Value.absent(),
    this.assertion = const Value.absent(),
    this.brief = const Value.absent(),
    this.chapter = const Value.absent(),
    this.originalText = const Value.absent(),
    this.explanation = const Value.absent(),
    this.notes = const Value.absent(),
    this.version = const Value.absent(),
    this.versionRemark = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.priority = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GeJuRulesCompanion.insert({
    this.id = const Value.absent(),
    required String patternId,
    required String schoolId,
    required String jixiong,
    required String geJuType,
    required String scope,
    this.coordinateSystem = const Value.absent(),
    this.conditions = const Value.absent(),
    this.assertion = const Value.absent(),
    this.brief = const Value.absent(),
    this.chapter = const Value.absent(),
    this.originalText = const Value.absent(),
    this.explanation = const Value.absent(),
    this.notes = const Value.absent(),
    required String version,
    this.versionRemark = const Value.absent(),
    required int isActive,
    required int isVerified,
    required int priority,
    required int viewCount,
    required int createdAt,
    required int updatedAt,
  }) : patternId = Value(patternId),
       schoolId = Value(schoolId),
       jixiong = Value(jixiong),
       geJuType = Value(geJuType),
       scope = Value(scope),
       version = Value(version),
       isActive = Value(isActive),
       isVerified = Value(isVerified),
       priority = Value(priority),
       viewCount = Value(viewCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GeJuRuleEntry> custom({
    Expression<int>? id,
    Expression<String>? patternId,
    Expression<String>? schoolId,
    Expression<String>? jixiong,
    Expression<String>? geJuType,
    Expression<String>? scope,
    Expression<String>? coordinateSystem,
    Expression<String>? conditions,
    Expression<String>? assertion,
    Expression<String>? brief,
    Expression<String>? chapter,
    Expression<String>? originalText,
    Expression<String>? explanation,
    Expression<String>? notes,
    Expression<String>? version,
    Expression<String>? versionRemark,
    Expression<int>? isActive,
    Expression<int>? isVerified,
    Expression<int>? priority,
    Expression<int>? viewCount,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patternId != null) 'pattern_id': patternId,
      if (schoolId != null) 'school_id': schoolId,
      if (jixiong != null) 'jixiong': jixiong,
      if (geJuType != null) 'ge_ju_type': geJuType,
      if (scope != null) 'scope': scope,
      if (coordinateSystem != null) 'coordinate_system': coordinateSystem,
      if (conditions != null) 'conditions': conditions,
      if (assertion != null) 'assertion': assertion,
      if (brief != null) 'brief': brief,
      if (chapter != null) 'chapter': chapter,
      if (originalText != null) 'original_text': originalText,
      if (explanation != null) 'explanation': explanation,
      if (notes != null) 'notes': notes,
      if (version != null) 'version': version,
      if (versionRemark != null) 'version_remark': versionRemark,
      if (isActive != null) 'is_active': isActive,
      if (isVerified != null) 'is_verified': isVerified,
      if (priority != null) 'priority': priority,
      if (viewCount != null) 'view_count': viewCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GeJuRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? patternId,
    Value<String>? schoolId,
    Value<String>? jixiong,
    Value<String>? geJuType,
    Value<String>? scope,
    Value<String?>? coordinateSystem,
    Value<String?>? conditions,
    Value<String?>? assertion,
    Value<String?>? brief,
    Value<String?>? chapter,
    Value<String?>? originalText,
    Value<String?>? explanation,
    Value<String?>? notes,
    Value<String>? version,
    Value<String?>? versionRemark,
    Value<int>? isActive,
    Value<int>? isVerified,
    Value<int>? priority,
    Value<int>? viewCount,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return GeJuRulesCompanion(
      id: id ?? this.id,
      patternId: patternId ?? this.patternId,
      schoolId: schoolId ?? this.schoolId,
      jixiong: jixiong ?? this.jixiong,
      geJuType: geJuType ?? this.geJuType,
      scope: scope ?? this.scope,
      coordinateSystem: coordinateSystem ?? this.coordinateSystem,
      conditions: conditions ?? this.conditions,
      assertion: assertion ?? this.assertion,
      brief: brief ?? this.brief,
      chapter: chapter ?? this.chapter,
      originalText: originalText ?? this.originalText,
      explanation: explanation ?? this.explanation,
      notes: notes ?? this.notes,
      version: version ?? this.version,
      versionRemark: versionRemark ?? this.versionRemark,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      priority: priority ?? this.priority,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patternId.present) {
      map['pattern_id'] = Variable<String>(patternId.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (jixiong.present) {
      map['jixiong'] = Variable<String>(jixiong.value);
    }
    if (geJuType.present) {
      map['ge_ju_type'] = Variable<String>(geJuType.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (coordinateSystem.present) {
      map['coordinate_system'] = Variable<String>(coordinateSystem.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (assertion.present) {
      map['assertion'] = Variable<String>(assertion.value);
    }
    if (brief.present) {
      map['brief'] = Variable<String>(brief.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<String>(chapter.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (versionRemark.present) {
      map['version_remark'] = Variable<String>(versionRemark.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<int>(isVerified.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (viewCount.present) {
      map['view_count'] = Variable<int>(viewCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuRulesCompanion(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('schoolId: $schoolId, ')
          ..write('jixiong: $jixiong, ')
          ..write('geJuType: $geJuType, ')
          ..write('scope: $scope, ')
          ..write('coordinateSystem: $coordinateSystem, ')
          ..write('conditions: $conditions, ')
          ..write('assertion: $assertion, ')
          ..write('brief: $brief, ')
          ..write('chapter: $chapter, ')
          ..write('originalText: $originalText, ')
          ..write('explanation: $explanation, ')
          ..write('notes: $notes, ')
          ..write('version: $version, ')
          ..write('versionRemark: $versionRemark, ')
          ..write('isActive: $isActive, ')
          ..write('isVerified: $isVerified, ')
          ..write('priority: $priority, ')
          ..write('viewCount: $viewCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GeJuVersionsTable extends GeJuVersions
    with TableInfo<$GeJuVersionsTable, GeJuVersionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionRemarkMeta = const VerificationMeta(
    'versionRemark',
  );
  @override
  late final GeneratedColumn<String> versionRemark = GeneratedColumn<String>(
    'version_remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedFieldsMeta = const VerificationMeta(
    'changedFields',
  );
  @override
  late final GeneratedColumn<String> changedFields = GeneratedColumn<String>(
    'changed_fields',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapshotMeta = const VerificationMeta(
    'snapshot',
  );
  @override
  late final GeneratedColumn<String> snapshot = GeneratedColumn<String>(
    'snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diffFromPreviousMeta = const VerificationMeta(
    'diffFromPrevious',
  );
  @override
  late final GeneratedColumn<String> diffFromPrevious = GeneratedColumn<String>(
    'diff_from_previous',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleId,
    version,
    versionRemark,
    operationType,
    changedFields,
    snapshot,
    diffFromPrevious,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeJuVersionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('version_remark')) {
      context.handle(
        _versionRemarkMeta,
        versionRemark.isAcceptableOrUnknown(
          data['version_remark']!,
          _versionRemarkMeta,
        ),
      );
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('changed_fields')) {
      context.handle(
        _changedFieldsMeta,
        changedFields.isAcceptableOrUnknown(
          data['changed_fields']!,
          _changedFieldsMeta,
        ),
      );
    }
    if (data.containsKey('snapshot')) {
      context.handle(
        _snapshotMeta,
        snapshot.isAcceptableOrUnknown(data['snapshot']!, _snapshotMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotMeta);
    }
    if (data.containsKey('diff_from_previous')) {
      context.handle(
        _diffFromPreviousMeta,
        diffFromPrevious.isAcceptableOrUnknown(
          data['diff_from_previous']!,
          _diffFromPreviousMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuVersionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuVersionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      versionRemark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_remark'],
      ),
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      changedFields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changed_fields'],
      ),
      snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot'],
      )!,
      diffFromPrevious: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diff_from_previous'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GeJuVersionsTable createAlias(String alias) {
    return $GeJuVersionsTable(attachedDatabase, alias);
  }
}

class GeJuVersionEntry extends DataClass
    implements Insertable<GeJuVersionEntry> {
  final int id;
  final int ruleId;
  final String version;
  final String? versionRemark;
  final String operationType;
  final String? changedFields;
  final String snapshot;
  final String? diffFromPrevious;
  final String createdBy;
  final int createdAt;
  const GeJuVersionEntry({
    required this.id,
    required this.ruleId,
    required this.version,
    this.versionRemark,
    required this.operationType,
    this.changedFields,
    required this.snapshot,
    this.diffFromPrevious,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rule_id'] = Variable<int>(ruleId);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || versionRemark != null) {
      map['version_remark'] = Variable<String>(versionRemark);
    }
    map['operation_type'] = Variable<String>(operationType);
    if (!nullToAbsent || changedFields != null) {
      map['changed_fields'] = Variable<String>(changedFields);
    }
    map['snapshot'] = Variable<String>(snapshot);
    if (!nullToAbsent || diffFromPrevious != null) {
      map['diff_from_previous'] = Variable<String>(diffFromPrevious);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  GeJuVersionsCompanion toCompanion(bool nullToAbsent) {
    return GeJuVersionsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      version: Value(version),
      versionRemark: versionRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(versionRemark),
      operationType: Value(operationType),
      changedFields: changedFields == null && nullToAbsent
          ? const Value.absent()
          : Value(changedFields),
      snapshot: Value(snapshot),
      diffFromPrevious: diffFromPrevious == null && nullToAbsent
          ? const Value.absent()
          : Value(diffFromPrevious),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory GeJuVersionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuVersionEntry(
      id: serializer.fromJson<int>(json['id']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      version: serializer.fromJson<String>(json['version']),
      versionRemark: serializer.fromJson<String?>(json['versionRemark']),
      operationType: serializer.fromJson<String>(json['operationType']),
      changedFields: serializer.fromJson<String?>(json['changedFields']),
      snapshot: serializer.fromJson<String>(json['snapshot']),
      diffFromPrevious: serializer.fromJson<String?>(json['diffFromPrevious']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ruleId': serializer.toJson<int>(ruleId),
      'version': serializer.toJson<String>(version),
      'versionRemark': serializer.toJson<String?>(versionRemark),
      'operationType': serializer.toJson<String>(operationType),
      'changedFields': serializer.toJson<String?>(changedFields),
      'snapshot': serializer.toJson<String>(snapshot),
      'diffFromPrevious': serializer.toJson<String?>(diffFromPrevious),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  GeJuVersionEntry copyWith({
    int? id,
    int? ruleId,
    String? version,
    Value<String?> versionRemark = const Value.absent(),
    String? operationType,
    Value<String?> changedFields = const Value.absent(),
    String? snapshot,
    Value<String?> diffFromPrevious = const Value.absent(),
    String? createdBy,
    int? createdAt,
  }) => GeJuVersionEntry(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    version: version ?? this.version,
    versionRemark: versionRemark.present
        ? versionRemark.value
        : this.versionRemark,
    operationType: operationType ?? this.operationType,
    changedFields: changedFields.present
        ? changedFields.value
        : this.changedFields,
    snapshot: snapshot ?? this.snapshot,
    diffFromPrevious: diffFromPrevious.present
        ? diffFromPrevious.value
        : this.diffFromPrevious,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  GeJuVersionEntry copyWithCompanion(GeJuVersionsCompanion data) {
    return GeJuVersionEntry(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      version: data.version.present ? data.version.value : this.version,
      versionRemark: data.versionRemark.present
          ? data.versionRemark.value
          : this.versionRemark,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      changedFields: data.changedFields.present
          ? data.changedFields.value
          : this.changedFields,
      snapshot: data.snapshot.present ? data.snapshot.value : this.snapshot,
      diffFromPrevious: data.diffFromPrevious.present
          ? data.diffFromPrevious.value
          : this.diffFromPrevious,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuVersionEntry(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('version: $version, ')
          ..write('versionRemark: $versionRemark, ')
          ..write('operationType: $operationType, ')
          ..write('changedFields: $changedFields, ')
          ..write('snapshot: $snapshot, ')
          ..write('diffFromPrevious: $diffFromPrevious, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleId,
    version,
    versionRemark,
    operationType,
    changedFields,
    snapshot,
    diffFromPrevious,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuVersionEntry &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.version == this.version &&
          other.versionRemark == this.versionRemark &&
          other.operationType == this.operationType &&
          other.changedFields == this.changedFields &&
          other.snapshot == this.snapshot &&
          other.diffFromPrevious == this.diffFromPrevious &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class GeJuVersionsCompanion extends UpdateCompanion<GeJuVersionEntry> {
  final Value<int> id;
  final Value<int> ruleId;
  final Value<String> version;
  final Value<String?> versionRemark;
  final Value<String> operationType;
  final Value<String?> changedFields;
  final Value<String> snapshot;
  final Value<String?> diffFromPrevious;
  final Value<String> createdBy;
  final Value<int> createdAt;
  const GeJuVersionsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.version = const Value.absent(),
    this.versionRemark = const Value.absent(),
    this.operationType = const Value.absent(),
    this.changedFields = const Value.absent(),
    this.snapshot = const Value.absent(),
    this.diffFromPrevious = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GeJuVersionsCompanion.insert({
    this.id = const Value.absent(),
    required int ruleId,
    required String version,
    this.versionRemark = const Value.absent(),
    required String operationType,
    this.changedFields = const Value.absent(),
    required String snapshot,
    this.diffFromPrevious = const Value.absent(),
    required String createdBy,
    required int createdAt,
  }) : ruleId = Value(ruleId),
       version = Value(version),
       operationType = Value(operationType),
       snapshot = Value(snapshot),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<GeJuVersionEntry> custom({
    Expression<int>? id,
    Expression<int>? ruleId,
    Expression<String>? version,
    Expression<String>? versionRemark,
    Expression<String>? operationType,
    Expression<String>? changedFields,
    Expression<String>? snapshot,
    Expression<String>? diffFromPrevious,
    Expression<String>? createdBy,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (version != null) 'version': version,
      if (versionRemark != null) 'version_remark': versionRemark,
      if (operationType != null) 'operation_type': operationType,
      if (changedFields != null) 'changed_fields': changedFields,
      if (snapshot != null) 'snapshot': snapshot,
      if (diffFromPrevious != null) 'diff_from_previous': diffFromPrevious,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GeJuVersionsCompanion copyWith({
    Value<int>? id,
    Value<int>? ruleId,
    Value<String>? version,
    Value<String?>? versionRemark,
    Value<String>? operationType,
    Value<String?>? changedFields,
    Value<String>? snapshot,
    Value<String?>? diffFromPrevious,
    Value<String>? createdBy,
    Value<int>? createdAt,
  }) {
    return GeJuVersionsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      version: version ?? this.version,
      versionRemark: versionRemark ?? this.versionRemark,
      operationType: operationType ?? this.operationType,
      changedFields: changedFields ?? this.changedFields,
      snapshot: snapshot ?? this.snapshot,
      diffFromPrevious: diffFromPrevious ?? this.diffFromPrevious,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (versionRemark.present) {
      map['version_remark'] = Variable<String>(versionRemark.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (changedFields.present) {
      map['changed_fields'] = Variable<String>(changedFields.value);
    }
    if (snapshot.present) {
      map['snapshot'] = Variable<String>(snapshot.value);
    }
    if (diffFromPrevious.present) {
      map['diff_from_previous'] = Variable<String>(diffFromPrevious.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuVersionsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('version: $version, ')
          ..write('versionRemark: $versionRemark, ')
          ..write('operationType: $operationType, ')
          ..write('changedFields: $changedFields, ')
          ..write('snapshot: $snapshot, ')
          ..write('diffFromPrevious: $diffFromPrevious, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ZhouTianDocumentsTable extends ZhouTianDocuments
    with TableInfo<$ZhouTianDocumentsTable, ZhouTianDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZhouTianDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'zhou_tian_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZhouTianDocumentEntry> instance, {
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
  ZhouTianDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZhouTianDocumentEntry(
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
  $ZhouTianDocumentsTable createAlias(String alias) {
    return $ZhouTianDocumentsTable(attachedDatabase, alias);
  }
}

class ZhouTianDocumentEntry extends DataClass
    implements Insertable<ZhouTianDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const ZhouTianDocumentEntry({
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

  ZhouTianDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ZhouTianDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory ZhouTianDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZhouTianDocumentEntry(
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

  ZhouTianDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      ZhouTianDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  ZhouTianDocumentEntry copyWithCompanion(ZhouTianDocumentsCompanion data) {
    return ZhouTianDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZhouTianDocumentEntry(')
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
      (other is ZhouTianDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class ZhouTianDocumentsCompanion
    extends UpdateCompanion<ZhouTianDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ZhouTianDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZhouTianDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<ZhouTianDocumentEntry> custom({
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

  ZhouTianDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return ZhouTianDocumentsCompanion(
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
    return (StringBuffer('ZhouTianDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EphemerisDocumentsTable extends EphemerisDocuments
    with TableInfo<$EphemerisDocumentsTable, EphemerisDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EphemerisDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'ephemeris_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<EphemerisDocumentEntry> instance, {
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
  EphemerisDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EphemerisDocumentEntry(
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
  $EphemerisDocumentsTable createAlias(String alias) {
    return $EphemerisDocumentsTable(attachedDatabase, alias);
  }
}

class EphemerisDocumentEntry extends DataClass
    implements Insertable<EphemerisDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const EphemerisDocumentEntry({
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

  EphemerisDocumentsCompanion toCompanion(bool nullToAbsent) {
    return EphemerisDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory EphemerisDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EphemerisDocumentEntry(
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

  EphemerisDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      EphemerisDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  EphemerisDocumentEntry copyWithCompanion(EphemerisDocumentsCompanion data) {
    return EphemerisDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EphemerisDocumentEntry(')
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
      (other is EphemerisDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class EphemerisDocumentsCompanion
    extends UpdateCompanion<EphemerisDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const EphemerisDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EphemerisDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<EphemerisDocumentEntry> custom({
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

  EphemerisDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return EphemerisDocumentsCompanion(
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
    return (StringBuffer('EphemerisDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShenShaDocumentsTable extends ShenShaDocuments
    with TableInfo<$ShenShaDocumentsTable, ShenShaDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShenShaDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'shen_sha_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShenShaDocumentEntry> instance, {
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
  ShenShaDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShenShaDocumentEntry(
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
  $ShenShaDocumentsTable createAlias(String alias) {
    return $ShenShaDocumentsTable(attachedDatabase, alias);
  }
}

class ShenShaDocumentEntry extends DataClass
    implements Insertable<ShenShaDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const ShenShaDocumentEntry({
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

  ShenShaDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ShenShaDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory ShenShaDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShenShaDocumentEntry(
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

  ShenShaDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      ShenShaDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  ShenShaDocumentEntry copyWithCompanion(ShenShaDocumentsCompanion data) {
    return ShenShaDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShenShaDocumentEntry(')
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
      (other is ShenShaDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class ShenShaDocumentsCompanion extends UpdateCompanion<ShenShaDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ShenShaDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShenShaDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<ShenShaDocumentEntry> custom({
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

  ShenShaDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return ShenShaDocumentsCompanion(
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
    return (StringBuffer('ShenShaDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HuaYaoDocumentsTable extends HuaYaoDocuments
    with TableInfo<$HuaYaoDocumentsTable, HuaYaoDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HuaYaoDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'hua_yao_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<HuaYaoDocumentEntry> instance, {
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
  HuaYaoDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HuaYaoDocumentEntry(
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
  $HuaYaoDocumentsTable createAlias(String alias) {
    return $HuaYaoDocumentsTable(attachedDatabase, alias);
  }
}

class HuaYaoDocumentEntry extends DataClass
    implements Insertable<HuaYaoDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const HuaYaoDocumentEntry({
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

  HuaYaoDocumentsCompanion toCompanion(bool nullToAbsent) {
    return HuaYaoDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory HuaYaoDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HuaYaoDocumentEntry(
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

  HuaYaoDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      HuaYaoDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  HuaYaoDocumentEntry copyWithCompanion(HuaYaoDocumentsCompanion data) {
    return HuaYaoDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HuaYaoDocumentEntry(')
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
      (other is HuaYaoDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class HuaYaoDocumentsCompanion extends UpdateCompanion<HuaYaoDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const HuaYaoDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HuaYaoDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<HuaYaoDocumentEntry> custom({
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

  HuaYaoDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return HuaYaoDocumentsCompanion(
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
    return (StringBuffer('HuaYaoDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuRulesDocumentsTable extends GeJuRulesDocuments
    with TableInfo<$GeJuRulesDocumentsTable, GeJuRulesDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuRulesDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'ge_ju_rules_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeJuRulesDocumentEntry> instance, {
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
  GeJuRulesDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuRulesDocumentEntry(
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
  $GeJuRulesDocumentsTable createAlias(String alias) {
    return $GeJuRulesDocumentsTable(attachedDatabase, alias);
  }
}

class GeJuRulesDocumentEntry extends DataClass
    implements Insertable<GeJuRulesDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const GeJuRulesDocumentEntry({
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

  GeJuRulesDocumentsCompanion toCompanion(bool nullToAbsent) {
    return GeJuRulesDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory GeJuRulesDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuRulesDocumentEntry(
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

  GeJuRulesDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      GeJuRulesDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  GeJuRulesDocumentEntry copyWithCompanion(GeJuRulesDocumentsCompanion data) {
    return GeJuRulesDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuRulesDocumentEntry(')
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
      (other is GeJuRulesDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class GeJuRulesDocumentsCompanion
    extends UpdateCompanion<GeJuRulesDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const GeJuRulesDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuRulesDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<GeJuRulesDocumentEntry> custom({
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

  GeJuRulesDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return GeJuRulesDocumentsCompanion(
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
    return (StringBuffer('GeJuRulesDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuContentDocumentsTable extends GeJuContentDocuments
    with TableInfo<$GeJuContentDocumentsTable, GeJuContentDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuContentDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'ge_ju_content_document';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeJuContentDocumentEntry> instance, {
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
  GeJuContentDocumentEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuContentDocumentEntry(
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
  $GeJuContentDocumentsTable createAlias(String alias) {
    return $GeJuContentDocumentsTable(attachedDatabase, alias);
  }
}

class GeJuContentDocumentEntry extends DataClass
    implements Insertable<GeJuContentDocumentEntry> {
  final String fileName;
  final String payloadJson;
  const GeJuContentDocumentEntry({
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

  GeJuContentDocumentsCompanion toCompanion(bool nullToAbsent) {
    return GeJuContentDocumentsCompanion(
      fileName: Value(fileName),
      payloadJson: Value(payloadJson),
    );
  }

  factory GeJuContentDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuContentDocumentEntry(
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

  GeJuContentDocumentEntry copyWith({String? fileName, String? payloadJson}) =>
      GeJuContentDocumentEntry(
        fileName: fileName ?? this.fileName,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  GeJuContentDocumentEntry copyWithCompanion(
    GeJuContentDocumentsCompanion data,
  ) {
    return GeJuContentDocumentEntry(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuContentDocumentEntry(')
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
      (other is GeJuContentDocumentEntry &&
          other.fileName == this.fileName &&
          other.payloadJson == this.payloadJson);
}

class GeJuContentDocumentsCompanion
    extends UpdateCompanion<GeJuContentDocumentEntry> {
  final Value<String> fileName;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const GeJuContentDocumentsCompanion({
    this.fileName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuContentDocumentsCompanion.insert({
    required String fileName,
    required String payloadJson,
    this.rowid = const Value.absent(),
  }) : fileName = Value(fileName),
       payloadJson = Value(payloadJson);
  static Insertable<GeJuContentDocumentEntry> custom({
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

  GeJuContentDocumentsCompanion copyWith({
    Value<String>? fileName,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return GeJuContentDocumentsCompanion(
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
    return (StringBuffer('GeJuContentDocumentsCompanion(')
          ..write('fileName: $fileName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatasetGenerationsTable extends DatasetGenerations
    with TableInfo<$DatasetGenerationsTable, DatasetGenerationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatasetGenerationsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<DatasetGenerationEntry> instance, {
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
  DatasetGenerationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatasetGenerationEntry(
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
  $DatasetGenerationsTable createAlias(String alias) {
    return $DatasetGenerationsTable(attachedDatabase, alias);
  }
}

class DatasetGenerationEntry extends DataClass
    implements Insertable<DatasetGenerationEntry> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const DatasetGenerationEntry({
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

  DatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return DatasetGenerationsCompanion(
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

  factory DatasetGenerationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatasetGenerationEntry(
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

  DatasetGenerationEntry copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => DatasetGenerationEntry(
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
  DatasetGenerationEntry copyWithCompanion(DatasetGenerationsCompanion data) {
    return DatasetGenerationEntry(
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
    return (StringBuffer('DatasetGenerationEntry(')
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
      (other is DatasetGenerationEntry &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class DatasetGenerationsCompanion
    extends UpdateCompanion<DatasetGenerationEntry> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const DatasetGenerationsCompanion({
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
  DatasetGenerationsCompanion.insert({
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
  static Insertable<DatasetGenerationEntry> custom({
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

  DatasetGenerationsCompanion copyWith({
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
    return DatasetGenerationsCompanion(
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
    return (StringBuffer('DatasetGenerationsCompanion(')
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

abstract class _$QizhengsiyuDatabase extends GeneratedDatabase {
  _$QizhengsiyuDatabase(QueryExecutor e) : super(e);
  $QizhengsiyuDatabaseManager get managers => $QizhengsiyuDatabaseManager(this);
  late final $StarPositionStatusesTable starPositionStatuses =
      $StarPositionStatusesTable(this);
  late final $GeJuPatternsTable geJuPatterns = $GeJuPatternsTable(this);
  late final $GeJuSchoolsTable geJuSchools = $GeJuSchoolsTable(this);
  late final $GeJuCategoriesTable geJuCategories = $GeJuCategoriesTable(this);
  late final $GeJuRulesTable geJuRules = $GeJuRulesTable(this);
  late final $GeJuVersionsTable geJuVersions = $GeJuVersionsTable(this);
  late final $ZhouTianDocumentsTable zhouTianDocuments =
      $ZhouTianDocumentsTable(this);
  late final $EphemerisDocumentsTable ephemerisDocuments =
      $EphemerisDocumentsTable(this);
  late final $ShenShaDocumentsTable shenShaDocuments = $ShenShaDocumentsTable(
    this,
  );
  late final $HuaYaoDocumentsTable huaYaoDocuments = $HuaYaoDocumentsTable(
    this,
  );
  late final $GeJuRulesDocumentsTable geJuRulesDocuments =
      $GeJuRulesDocumentsTable(this);
  late final $GeJuContentDocumentsTable geJuContentDocuments =
      $GeJuContentDocumentsTable(this);
  late final $DatasetGenerationsTable datasetGenerations =
      $DatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    starPositionStatuses,
    geJuPatterns,
    geJuSchools,
    geJuCategories,
    geJuRules,
    geJuVersions,
    zhouTianDocuments,
    ephemerisDocuments,
    shenShaDocuments,
    huaYaoDocuments,
    geJuRulesDocuments,
    geJuContentDocuments,
    datasetGenerations,
  ];
}

typedef $$StarPositionStatusesTableCreateCompanionBuilder =
    StarPositionStatusesCompanion Function({
      Value<int> id,
      required String className,
      required String star,
      required String positionStatusType,
      required String positionListJson,
    });
typedef $$StarPositionStatusesTableUpdateCompanionBuilder =
    StarPositionStatusesCompanion Function({
      Value<int> id,
      Value<String> className,
      Value<String> star,
      Value<String> positionStatusType,
      Value<String> positionListJson,
    });

class $$StarPositionStatusesTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $StarPositionStatusesTable> {
  $$StarPositionStatusesTableFilterComposer({
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

  ColumnFilters<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get star => $composableBuilder(
    column: $table.star,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionStatusType => $composableBuilder(
    column: $table.positionStatusType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionListJson => $composableBuilder(
    column: $table.positionListJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StarPositionStatusesTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $StarPositionStatusesTable> {
  $$StarPositionStatusesTableOrderingComposer({
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

  ColumnOrderings<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get star => $composableBuilder(
    column: $table.star,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionStatusType => $composableBuilder(
    column: $table.positionStatusType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionListJson => $composableBuilder(
    column: $table.positionListJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StarPositionStatusesTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $StarPositionStatusesTable> {
  $$StarPositionStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get star =>
      $composableBuilder(column: $table.star, builder: (column) => column);

  GeneratedColumn<String> get positionStatusType => $composableBuilder(
    column: $table.positionStatusType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get positionListJson => $composableBuilder(
    column: $table.positionListJson,
    builder: (column) => column,
  );
}

class $$StarPositionStatusesTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $StarPositionStatusesTable,
          StarPositionStatusEntry,
          $$StarPositionStatusesTableFilterComposer,
          $$StarPositionStatusesTableOrderingComposer,
          $$StarPositionStatusesTableAnnotationComposer,
          $$StarPositionStatusesTableCreateCompanionBuilder,
          $$StarPositionStatusesTableUpdateCompanionBuilder,
          (
            StarPositionStatusEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $StarPositionStatusesTable,
              StarPositionStatusEntry
            >,
          ),
          StarPositionStatusEntry,
          PrefetchHooks Function()
        > {
  $$StarPositionStatusesTableTableManager(
    _$QizhengsiyuDatabase db,
    $StarPositionStatusesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StarPositionStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StarPositionStatusesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StarPositionStatusesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> className = const Value.absent(),
                Value<String> star = const Value.absent(),
                Value<String> positionStatusType = const Value.absent(),
                Value<String> positionListJson = const Value.absent(),
              }) => StarPositionStatusesCompanion(
                id: id,
                className: className,
                star: star,
                positionStatusType: positionStatusType,
                positionListJson: positionListJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String className,
                required String star,
                required String positionStatusType,
                required String positionListJson,
              }) => StarPositionStatusesCompanion.insert(
                id: id,
                className: className,
                star: star,
                positionStatusType: positionStatusType,
                positionListJson: positionListJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StarPositionStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $StarPositionStatusesTable,
      StarPositionStatusEntry,
      $$StarPositionStatusesTableFilterComposer,
      $$StarPositionStatusesTableOrderingComposer,
      $$StarPositionStatusesTableAnnotationComposer,
      $$StarPositionStatusesTableCreateCompanionBuilder,
      $$StarPositionStatusesTableUpdateCompanionBuilder,
      (
        StarPositionStatusEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $StarPositionStatusesTable,
          StarPositionStatusEntry
        >,
      ),
      StarPositionStatusEntry,
      PrefetchHooks Function()
    >;
typedef $$GeJuPatternsTableCreateCompanionBuilder =
    GeJuPatternsCompanion Function({
      required String id,
      required String name,
      Value<String?> englishName,
      Value<String?> pinyin,
      Value<String?> aliases,
      required String categoryId,
      Value<String?> keywords,
      Value<String?> tags,
      Value<String?> description,
      Value<String?> originNotes,
      required int referenceCount,
      required int ruleCount,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$GeJuPatternsTableUpdateCompanionBuilder =
    GeJuPatternsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> englishName,
      Value<String?> pinyin,
      Value<String?> aliases,
      Value<String> categoryId,
      Value<String?> keywords,
      Value<String?> tags,
      Value<String?> description,
      Value<String?> originNotes,
      Value<int> referenceCount,
      Value<int> ruleCount,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$GeJuPatternsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuPatternsTable> {
  $$GeJuPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originNotes => $composableBuilder(
    column: $table.originNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get referenceCount => $composableBuilder(
    column: $table.referenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruleCount => $composableBuilder(
    column: $table.ruleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeJuPatternsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuPatternsTable> {
  $$GeJuPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originNotes => $composableBuilder(
    column: $table.originNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get referenceCount => $composableBuilder(
    column: $table.referenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleCount => $composableBuilder(
    column: $table.ruleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeJuPatternsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuPatternsTable> {
  $$GeJuPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originNotes => $composableBuilder(
    column: $table.originNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get referenceCount => $composableBuilder(
    column: $table.referenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ruleCount =>
      $composableBuilder(column: $table.ruleCount, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GeJuPatternsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $GeJuPatternsTable,
          GeJuPatternEntry,
          $$GeJuPatternsTableFilterComposer,
          $$GeJuPatternsTableOrderingComposer,
          $$GeJuPatternsTableAnnotationComposer,
          $$GeJuPatternsTableCreateCompanionBuilder,
          $$GeJuPatternsTableUpdateCompanionBuilder,
          (
            GeJuPatternEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $GeJuPatternsTable,
              GeJuPatternEntry
            >,
          ),
          GeJuPatternEntry,
          PrefetchHooks Function()
        > {
  $$GeJuPatternsTableTableManager(
    _$QizhengsiyuDatabase db,
    $GeJuPatternsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuPatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuPatternsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> englishName = const Value.absent(),
                Value<String?> pinyin = const Value.absent(),
                Value<String?> aliases = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> originNotes = const Value.absent(),
                Value<int> referenceCount = const Value.absent(),
                Value<int> ruleCount = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeJuPatternsCompanion(
                id: id,
                name: name,
                englishName: englishName,
                pinyin: pinyin,
                aliases: aliases,
                categoryId: categoryId,
                keywords: keywords,
                tags: tags,
                description: description,
                originNotes: originNotes,
                referenceCount: referenceCount,
                ruleCount: ruleCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> englishName = const Value.absent(),
                Value<String?> pinyin = const Value.absent(),
                Value<String?> aliases = const Value.absent(),
                required String categoryId,
                Value<String?> keywords = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> originNotes = const Value.absent(),
                required int referenceCount,
                required int ruleCount,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GeJuPatternsCompanion.insert(
                id: id,
                name: name,
                englishName: englishName,
                pinyin: pinyin,
                aliases: aliases,
                categoryId: categoryId,
                keywords: keywords,
                tags: tags,
                description: description,
                originNotes: originNotes,
                referenceCount: referenceCount,
                ruleCount: ruleCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeJuPatternsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $GeJuPatternsTable,
      GeJuPatternEntry,
      $$GeJuPatternsTableFilterComposer,
      $$GeJuPatternsTableOrderingComposer,
      $$GeJuPatternsTableAnnotationComposer,
      $$GeJuPatternsTableCreateCompanionBuilder,
      $$GeJuPatternsTableUpdateCompanionBuilder,
      (
        GeJuPatternEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $GeJuPatternsTable,
          GeJuPatternEntry
        >,
      ),
      GeJuPatternEntry,
      PrefetchHooks Function()
    >;
typedef $$GeJuSchoolsTableCreateCompanionBuilder =
    GeJuSchoolsCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<String?> era,
      Value<String?> founder,
      Value<String?> description,
      required int isActive,
      required int ruleCount,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$GeJuSchoolsTableUpdateCompanionBuilder =
    GeJuSchoolsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> era,
      Value<String?> founder,
      Value<String?> description,
      Value<int> isActive,
      Value<int> ruleCount,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$GeJuSchoolsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuSchoolsTable> {
  $$GeJuSchoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get era => $composableBuilder(
    column: $table.era,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get founder => $composableBuilder(
    column: $table.founder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruleCount => $composableBuilder(
    column: $table.ruleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeJuSchoolsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuSchoolsTable> {
  $$GeJuSchoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get era => $composableBuilder(
    column: $table.era,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get founder => $composableBuilder(
    column: $table.founder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleCount => $composableBuilder(
    column: $table.ruleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeJuSchoolsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuSchoolsTable> {
  $$GeJuSchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get era =>
      $composableBuilder(column: $table.era, builder: (column) => column);

  GeneratedColumn<String> get founder =>
      $composableBuilder(column: $table.founder, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get ruleCount =>
      $composableBuilder(column: $table.ruleCount, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GeJuSchoolsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $GeJuSchoolsTable,
          GeJuSchoolEntry,
          $$GeJuSchoolsTableFilterComposer,
          $$GeJuSchoolsTableOrderingComposer,
          $$GeJuSchoolsTableAnnotationComposer,
          $$GeJuSchoolsTableCreateCompanionBuilder,
          $$GeJuSchoolsTableUpdateCompanionBuilder,
          (
            GeJuSchoolEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $GeJuSchoolsTable,
              GeJuSchoolEntry
            >,
          ),
          GeJuSchoolEntry,
          PrefetchHooks Function()
        > {
  $$GeJuSchoolsTableTableManager(
    _$QizhengsiyuDatabase db,
    $GeJuSchoolsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuSchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuSchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuSchoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> era = const Value.absent(),
                Value<String?> founder = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int> ruleCount = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeJuSchoolsCompanion(
                id: id,
                name: name,
                type: type,
                era: era,
                founder: founder,
                description: description,
                isActive: isActive,
                ruleCount: ruleCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<String?> era = const Value.absent(),
                Value<String?> founder = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int isActive,
                required int ruleCount,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GeJuSchoolsCompanion.insert(
                id: id,
                name: name,
                type: type,
                era: era,
                founder: founder,
                description: description,
                isActive: isActive,
                ruleCount: ruleCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeJuSchoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $GeJuSchoolsTable,
      GeJuSchoolEntry,
      $$GeJuSchoolsTableFilterComposer,
      $$GeJuSchoolsTableOrderingComposer,
      $$GeJuSchoolsTableAnnotationComposer,
      $$GeJuSchoolsTableCreateCompanionBuilder,
      $$GeJuSchoolsTableUpdateCompanionBuilder,
      (
        GeJuSchoolEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $GeJuSchoolsTable,
          GeJuSchoolEntry
        >,
      ),
      GeJuSchoolEntry,
      PrefetchHooks Function()
    >;
typedef $$GeJuCategoriesTableCreateCompanionBuilder =
    GeJuCategoriesCompanion Function({
      required String id,
      required String name,
      required int order,
      Value<String?> parentId,
      required int isActive,
      required int patternCount,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$GeJuCategoriesTableUpdateCompanionBuilder =
    GeJuCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> order,
      Value<String?> parentId,
      Value<int> isActive,
      Value<int> patternCount,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$GeJuCategoriesTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuCategoriesTable> {
  $$GeJuCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get patternCount => $composableBuilder(
    column: $table.patternCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeJuCategoriesTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuCategoriesTable> {
  $$GeJuCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get patternCount => $composableBuilder(
    column: $table.patternCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeJuCategoriesTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuCategoriesTable> {
  $$GeJuCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get patternCount => $composableBuilder(
    column: $table.patternCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GeJuCategoriesTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $GeJuCategoriesTable,
          GeJuCategoryEntry,
          $$GeJuCategoriesTableFilterComposer,
          $$GeJuCategoriesTableOrderingComposer,
          $$GeJuCategoriesTableAnnotationComposer,
          $$GeJuCategoriesTableCreateCompanionBuilder,
          $$GeJuCategoriesTableUpdateCompanionBuilder,
          (
            GeJuCategoryEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $GeJuCategoriesTable,
              GeJuCategoryEntry
            >,
          ),
          GeJuCategoryEntry,
          PrefetchHooks Function()
        > {
  $$GeJuCategoriesTableTableManager(
    _$QizhengsiyuDatabase db,
    $GeJuCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int> patternCount = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeJuCategoriesCompanion(
                id: id,
                name: name,
                order: order,
                parentId: parentId,
                isActive: isActive,
                patternCount: patternCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int order,
                Value<String?> parentId = const Value.absent(),
                required int isActive,
                required int patternCount,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GeJuCategoriesCompanion.insert(
                id: id,
                name: name,
                order: order,
                parentId: parentId,
                isActive: isActive,
                patternCount: patternCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeJuCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $GeJuCategoriesTable,
      GeJuCategoryEntry,
      $$GeJuCategoriesTableFilterComposer,
      $$GeJuCategoriesTableOrderingComposer,
      $$GeJuCategoriesTableAnnotationComposer,
      $$GeJuCategoriesTableCreateCompanionBuilder,
      $$GeJuCategoriesTableUpdateCompanionBuilder,
      (
        GeJuCategoryEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $GeJuCategoriesTable,
          GeJuCategoryEntry
        >,
      ),
      GeJuCategoryEntry,
      PrefetchHooks Function()
    >;
typedef $$GeJuRulesTableCreateCompanionBuilder =
    GeJuRulesCompanion Function({
      Value<int> id,
      required String patternId,
      required String schoolId,
      required String jixiong,
      required String geJuType,
      required String scope,
      Value<String?> coordinateSystem,
      Value<String?> conditions,
      Value<String?> assertion,
      Value<String?> brief,
      Value<String?> chapter,
      Value<String?> originalText,
      Value<String?> explanation,
      Value<String?> notes,
      required String version,
      Value<String?> versionRemark,
      required int isActive,
      required int isVerified,
      required int priority,
      required int viewCount,
      required int createdAt,
      required int updatedAt,
    });
typedef $$GeJuRulesTableUpdateCompanionBuilder =
    GeJuRulesCompanion Function({
      Value<int> id,
      Value<String> patternId,
      Value<String> schoolId,
      Value<String> jixiong,
      Value<String> geJuType,
      Value<String> scope,
      Value<String?> coordinateSystem,
      Value<String?> conditions,
      Value<String?> assertion,
      Value<String?> brief,
      Value<String?> chapter,
      Value<String?> originalText,
      Value<String?> explanation,
      Value<String?> notes,
      Value<String> version,
      Value<String?> versionRemark,
      Value<int> isActive,
      Value<int> isVerified,
      Value<int> priority,
      Value<int> viewCount,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

class $$GeJuRulesTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuRulesTable> {
  $$GeJuRulesTableFilterComposer({
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

  ColumnFilters<String> get patternId => $composableBuilder(
    column: $table.patternId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jixiong => $composableBuilder(
    column: $table.jixiong,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geJuType => $composableBuilder(
    column: $table.geJuType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coordinateSystem => $composableBuilder(
    column: $table.coordinateSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assertion => $composableBuilder(
    column: $table.assertion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brief => $composableBuilder(
    column: $table.brief,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionRemark => $composableBuilder(
    column: $table.versionRemark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeJuRulesTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuRulesTable> {
  $$GeJuRulesTableOrderingComposer({
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

  ColumnOrderings<String> get patternId => $composableBuilder(
    column: $table.patternId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jixiong => $composableBuilder(
    column: $table.jixiong,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geJuType => $composableBuilder(
    column: $table.geJuType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coordinateSystem => $composableBuilder(
    column: $table.coordinateSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assertion => $composableBuilder(
    column: $table.assertion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brief => $composableBuilder(
    column: $table.brief,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionRemark => $composableBuilder(
    column: $table.versionRemark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeJuRulesTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuRulesTable> {
  $$GeJuRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patternId =>
      $composableBuilder(column: $table.patternId, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get jixiong =>
      $composableBuilder(column: $table.jixiong, builder: (column) => column);

  GeneratedColumn<String> get geJuType =>
      $composableBuilder(column: $table.geJuType, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get coordinateSystem => $composableBuilder(
    column: $table.coordinateSystem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assertion =>
      $composableBuilder(column: $table.assertion, builder: (column) => column);

  GeneratedColumn<String> get brief =>
      $composableBuilder(column: $table.brief, builder: (column) => column);

  GeneratedColumn<String> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get versionRemark => $composableBuilder(
    column: $table.versionRemark,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get viewCount =>
      $composableBuilder(column: $table.viewCount, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GeJuRulesTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $GeJuRulesTable,
          GeJuRuleEntry,
          $$GeJuRulesTableFilterComposer,
          $$GeJuRulesTableOrderingComposer,
          $$GeJuRulesTableAnnotationComposer,
          $$GeJuRulesTableCreateCompanionBuilder,
          $$GeJuRulesTableUpdateCompanionBuilder,
          (
            GeJuRuleEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $GeJuRulesTable,
              GeJuRuleEntry
            >,
          ),
          GeJuRuleEntry,
          PrefetchHooks Function()
        > {
  $$GeJuRulesTableTableManager(_$QizhengsiyuDatabase db, $GeJuRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> patternId = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> jixiong = const Value.absent(),
                Value<String> geJuType = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> coordinateSystem = const Value.absent(),
                Value<String?> conditions = const Value.absent(),
                Value<String?> assertion = const Value.absent(),
                Value<String?> brief = const Value.absent(),
                Value<String?> chapter = const Value.absent(),
                Value<String?> originalText = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String?> versionRemark = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int> isVerified = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> viewCount = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => GeJuRulesCompanion(
                id: id,
                patternId: patternId,
                schoolId: schoolId,
                jixiong: jixiong,
                geJuType: geJuType,
                scope: scope,
                coordinateSystem: coordinateSystem,
                conditions: conditions,
                assertion: assertion,
                brief: brief,
                chapter: chapter,
                originalText: originalText,
                explanation: explanation,
                notes: notes,
                version: version,
                versionRemark: versionRemark,
                isActive: isActive,
                isVerified: isVerified,
                priority: priority,
                viewCount: viewCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String patternId,
                required String schoolId,
                required String jixiong,
                required String geJuType,
                required String scope,
                Value<String?> coordinateSystem = const Value.absent(),
                Value<String?> conditions = const Value.absent(),
                Value<String?> assertion = const Value.absent(),
                Value<String?> brief = const Value.absent(),
                Value<String?> chapter = const Value.absent(),
                Value<String?> originalText = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String version,
                Value<String?> versionRemark = const Value.absent(),
                required int isActive,
                required int isVerified,
                required int priority,
                required int viewCount,
                required int createdAt,
                required int updatedAt,
              }) => GeJuRulesCompanion.insert(
                id: id,
                patternId: patternId,
                schoolId: schoolId,
                jixiong: jixiong,
                geJuType: geJuType,
                scope: scope,
                coordinateSystem: coordinateSystem,
                conditions: conditions,
                assertion: assertion,
                brief: brief,
                chapter: chapter,
                originalText: originalText,
                explanation: explanation,
                notes: notes,
                version: version,
                versionRemark: versionRemark,
                isActive: isActive,
                isVerified: isVerified,
                priority: priority,
                viewCount: viewCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeJuRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $GeJuRulesTable,
      GeJuRuleEntry,
      $$GeJuRulesTableFilterComposer,
      $$GeJuRulesTableOrderingComposer,
      $$GeJuRulesTableAnnotationComposer,
      $$GeJuRulesTableCreateCompanionBuilder,
      $$GeJuRulesTableUpdateCompanionBuilder,
      (
        GeJuRuleEntry,
        BaseReferences<_$QizhengsiyuDatabase, $GeJuRulesTable, GeJuRuleEntry>,
      ),
      GeJuRuleEntry,
      PrefetchHooks Function()
    >;
typedef $$GeJuVersionsTableCreateCompanionBuilder =
    GeJuVersionsCompanion Function({
      Value<int> id,
      required int ruleId,
      required String version,
      Value<String?> versionRemark,
      required String operationType,
      Value<String?> changedFields,
      required String snapshot,
      Value<String?> diffFromPrevious,
      required String createdBy,
      required int createdAt,
    });
typedef $$GeJuVersionsTableUpdateCompanionBuilder =
    GeJuVersionsCompanion Function({
      Value<int> id,
      Value<int> ruleId,
      Value<String> version,
      Value<String?> versionRemark,
      Value<String> operationType,
      Value<String?> changedFields,
      Value<String> snapshot,
      Value<String?> diffFromPrevious,
      Value<String> createdBy,
      Value<int> createdAt,
    });

class $$GeJuVersionsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuVersionsTable> {
  $$GeJuVersionsTableFilterComposer({
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

  ColumnFilters<int> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionRemark => $composableBuilder(
    column: $table.versionRemark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changedFields => $composableBuilder(
    column: $table.changedFields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diffFromPrevious => $composableBuilder(
    column: $table.diffFromPrevious,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeJuVersionsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuVersionsTable> {
  $$GeJuVersionsTableOrderingComposer({
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

  ColumnOrderings<int> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionRemark => $composableBuilder(
    column: $table.versionRemark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedFields => $composableBuilder(
    column: $table.changedFields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diffFromPrevious => $composableBuilder(
    column: $table.diffFromPrevious,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeJuVersionsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuVersionsTable> {
  $$GeJuVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get versionRemark => $composableBuilder(
    column: $table.versionRemark,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changedFields => $composableBuilder(
    column: $table.changedFields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshot =>
      $composableBuilder(column: $table.snapshot, builder: (column) => column);

  GeneratedColumn<String> get diffFromPrevious => $composableBuilder(
    column: $table.diffFromPrevious,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GeJuVersionsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $GeJuVersionsTable,
          GeJuVersionEntry,
          $$GeJuVersionsTableFilterComposer,
          $$GeJuVersionsTableOrderingComposer,
          $$GeJuVersionsTableAnnotationComposer,
          $$GeJuVersionsTableCreateCompanionBuilder,
          $$GeJuVersionsTableUpdateCompanionBuilder,
          (
            GeJuVersionEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $GeJuVersionsTable,
              GeJuVersionEntry
            >,
          ),
          GeJuVersionEntry,
          PrefetchHooks Function()
        > {
  $$GeJuVersionsTableTableManager(
    _$QizhengsiyuDatabase db,
    $GeJuVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String?> versionRemark = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String?> changedFields = const Value.absent(),
                Value<String> snapshot = const Value.absent(),
                Value<String?> diffFromPrevious = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => GeJuVersionsCompanion(
                id: id,
                ruleId: ruleId,
                version: version,
                versionRemark: versionRemark,
                operationType: operationType,
                changedFields: changedFields,
                snapshot: snapshot,
                diffFromPrevious: diffFromPrevious,
                createdBy: createdBy,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ruleId,
                required String version,
                Value<String?> versionRemark = const Value.absent(),
                required String operationType,
                Value<String?> changedFields = const Value.absent(),
                required String snapshot,
                Value<String?> diffFromPrevious = const Value.absent(),
                required String createdBy,
                required int createdAt,
              }) => GeJuVersionsCompanion.insert(
                id: id,
                ruleId: ruleId,
                version: version,
                versionRemark: versionRemark,
                operationType: operationType,
                changedFields: changedFields,
                snapshot: snapshot,
                diffFromPrevious: diffFromPrevious,
                createdBy: createdBy,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeJuVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $GeJuVersionsTable,
      GeJuVersionEntry,
      $$GeJuVersionsTableFilterComposer,
      $$GeJuVersionsTableOrderingComposer,
      $$GeJuVersionsTableAnnotationComposer,
      $$GeJuVersionsTableCreateCompanionBuilder,
      $$GeJuVersionsTableUpdateCompanionBuilder,
      (
        GeJuVersionEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $GeJuVersionsTable,
          GeJuVersionEntry
        >,
      ),
      GeJuVersionEntry,
      PrefetchHooks Function()
    >;
typedef $$ZhouTianDocumentsTableCreateCompanionBuilder =
    ZhouTianDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$ZhouTianDocumentsTableUpdateCompanionBuilder =
    ZhouTianDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$ZhouTianDocumentsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $ZhouTianDocumentsTable> {
  $$ZhouTianDocumentsTableFilterComposer({
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

class $$ZhouTianDocumentsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $ZhouTianDocumentsTable> {
  $$ZhouTianDocumentsTableOrderingComposer({
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

class $$ZhouTianDocumentsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $ZhouTianDocumentsTable> {
  $$ZhouTianDocumentsTableAnnotationComposer({
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

class $$ZhouTianDocumentsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $ZhouTianDocumentsTable,
          ZhouTianDocumentEntry,
          $$ZhouTianDocumentsTableFilterComposer,
          $$ZhouTianDocumentsTableOrderingComposer,
          $$ZhouTianDocumentsTableAnnotationComposer,
          $$ZhouTianDocumentsTableCreateCompanionBuilder,
          $$ZhouTianDocumentsTableUpdateCompanionBuilder,
          (
            ZhouTianDocumentEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $ZhouTianDocumentsTable,
              ZhouTianDocumentEntry
            >,
          ),
          ZhouTianDocumentEntry,
          PrefetchHooks Function()
        > {
  $$ZhouTianDocumentsTableTableManager(
    _$QizhengsiyuDatabase db,
    $ZhouTianDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZhouTianDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZhouTianDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZhouTianDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZhouTianDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => ZhouTianDocumentsCompanion.insert(
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

typedef $$ZhouTianDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $ZhouTianDocumentsTable,
      ZhouTianDocumentEntry,
      $$ZhouTianDocumentsTableFilterComposer,
      $$ZhouTianDocumentsTableOrderingComposer,
      $$ZhouTianDocumentsTableAnnotationComposer,
      $$ZhouTianDocumentsTableCreateCompanionBuilder,
      $$ZhouTianDocumentsTableUpdateCompanionBuilder,
      (
        ZhouTianDocumentEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $ZhouTianDocumentsTable,
          ZhouTianDocumentEntry
        >,
      ),
      ZhouTianDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$EphemerisDocumentsTableCreateCompanionBuilder =
    EphemerisDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$EphemerisDocumentsTableUpdateCompanionBuilder =
    EphemerisDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$EphemerisDocumentsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $EphemerisDocumentsTable> {
  $$EphemerisDocumentsTableFilterComposer({
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

class $$EphemerisDocumentsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $EphemerisDocumentsTable> {
  $$EphemerisDocumentsTableOrderingComposer({
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

class $$EphemerisDocumentsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $EphemerisDocumentsTable> {
  $$EphemerisDocumentsTableAnnotationComposer({
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

class $$EphemerisDocumentsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $EphemerisDocumentsTable,
          EphemerisDocumentEntry,
          $$EphemerisDocumentsTableFilterComposer,
          $$EphemerisDocumentsTableOrderingComposer,
          $$EphemerisDocumentsTableAnnotationComposer,
          $$EphemerisDocumentsTableCreateCompanionBuilder,
          $$EphemerisDocumentsTableUpdateCompanionBuilder,
          (
            EphemerisDocumentEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $EphemerisDocumentsTable,
              EphemerisDocumentEntry
            >,
          ),
          EphemerisDocumentEntry,
          PrefetchHooks Function()
        > {
  $$EphemerisDocumentsTableTableManager(
    _$QizhengsiyuDatabase db,
    $EphemerisDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EphemerisDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EphemerisDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EphemerisDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EphemerisDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => EphemerisDocumentsCompanion.insert(
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

typedef $$EphemerisDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $EphemerisDocumentsTable,
      EphemerisDocumentEntry,
      $$EphemerisDocumentsTableFilterComposer,
      $$EphemerisDocumentsTableOrderingComposer,
      $$EphemerisDocumentsTableAnnotationComposer,
      $$EphemerisDocumentsTableCreateCompanionBuilder,
      $$EphemerisDocumentsTableUpdateCompanionBuilder,
      (
        EphemerisDocumentEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $EphemerisDocumentsTable,
          EphemerisDocumentEntry
        >,
      ),
      EphemerisDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$ShenShaDocumentsTableCreateCompanionBuilder =
    ShenShaDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$ShenShaDocumentsTableUpdateCompanionBuilder =
    ShenShaDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$ShenShaDocumentsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $ShenShaDocumentsTable> {
  $$ShenShaDocumentsTableFilterComposer({
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

class $$ShenShaDocumentsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $ShenShaDocumentsTable> {
  $$ShenShaDocumentsTableOrderingComposer({
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

class $$ShenShaDocumentsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $ShenShaDocumentsTable> {
  $$ShenShaDocumentsTableAnnotationComposer({
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

class $$ShenShaDocumentsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $ShenShaDocumentsTable,
          ShenShaDocumentEntry,
          $$ShenShaDocumentsTableFilterComposer,
          $$ShenShaDocumentsTableOrderingComposer,
          $$ShenShaDocumentsTableAnnotationComposer,
          $$ShenShaDocumentsTableCreateCompanionBuilder,
          $$ShenShaDocumentsTableUpdateCompanionBuilder,
          (
            ShenShaDocumentEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $ShenShaDocumentsTable,
              ShenShaDocumentEntry
            >,
          ),
          ShenShaDocumentEntry,
          PrefetchHooks Function()
        > {
  $$ShenShaDocumentsTableTableManager(
    _$QizhengsiyuDatabase db,
    $ShenShaDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShenShaDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShenShaDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShenShaDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShenShaDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => ShenShaDocumentsCompanion.insert(
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

typedef $$ShenShaDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $ShenShaDocumentsTable,
      ShenShaDocumentEntry,
      $$ShenShaDocumentsTableFilterComposer,
      $$ShenShaDocumentsTableOrderingComposer,
      $$ShenShaDocumentsTableAnnotationComposer,
      $$ShenShaDocumentsTableCreateCompanionBuilder,
      $$ShenShaDocumentsTableUpdateCompanionBuilder,
      (
        ShenShaDocumentEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $ShenShaDocumentsTable,
          ShenShaDocumentEntry
        >,
      ),
      ShenShaDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$HuaYaoDocumentsTableCreateCompanionBuilder =
    HuaYaoDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$HuaYaoDocumentsTableUpdateCompanionBuilder =
    HuaYaoDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$HuaYaoDocumentsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $HuaYaoDocumentsTable> {
  $$HuaYaoDocumentsTableFilterComposer({
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

class $$HuaYaoDocumentsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $HuaYaoDocumentsTable> {
  $$HuaYaoDocumentsTableOrderingComposer({
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

class $$HuaYaoDocumentsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $HuaYaoDocumentsTable> {
  $$HuaYaoDocumentsTableAnnotationComposer({
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

class $$HuaYaoDocumentsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $HuaYaoDocumentsTable,
          HuaYaoDocumentEntry,
          $$HuaYaoDocumentsTableFilterComposer,
          $$HuaYaoDocumentsTableOrderingComposer,
          $$HuaYaoDocumentsTableAnnotationComposer,
          $$HuaYaoDocumentsTableCreateCompanionBuilder,
          $$HuaYaoDocumentsTableUpdateCompanionBuilder,
          (
            HuaYaoDocumentEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $HuaYaoDocumentsTable,
              HuaYaoDocumentEntry
            >,
          ),
          HuaYaoDocumentEntry,
          PrefetchHooks Function()
        > {
  $$HuaYaoDocumentsTableTableManager(
    _$QizhengsiyuDatabase db,
    $HuaYaoDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HuaYaoDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HuaYaoDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HuaYaoDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HuaYaoDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => HuaYaoDocumentsCompanion.insert(
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

typedef $$HuaYaoDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $HuaYaoDocumentsTable,
      HuaYaoDocumentEntry,
      $$HuaYaoDocumentsTableFilterComposer,
      $$HuaYaoDocumentsTableOrderingComposer,
      $$HuaYaoDocumentsTableAnnotationComposer,
      $$HuaYaoDocumentsTableCreateCompanionBuilder,
      $$HuaYaoDocumentsTableUpdateCompanionBuilder,
      (
        HuaYaoDocumentEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $HuaYaoDocumentsTable,
          HuaYaoDocumentEntry
        >,
      ),
      HuaYaoDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$GeJuRulesDocumentsTableCreateCompanionBuilder =
    GeJuRulesDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$GeJuRulesDocumentsTableUpdateCompanionBuilder =
    GeJuRulesDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$GeJuRulesDocumentsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuRulesDocumentsTable> {
  $$GeJuRulesDocumentsTableFilterComposer({
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

class $$GeJuRulesDocumentsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuRulesDocumentsTable> {
  $$GeJuRulesDocumentsTableOrderingComposer({
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

class $$GeJuRulesDocumentsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuRulesDocumentsTable> {
  $$GeJuRulesDocumentsTableAnnotationComposer({
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

class $$GeJuRulesDocumentsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $GeJuRulesDocumentsTable,
          GeJuRulesDocumentEntry,
          $$GeJuRulesDocumentsTableFilterComposer,
          $$GeJuRulesDocumentsTableOrderingComposer,
          $$GeJuRulesDocumentsTableAnnotationComposer,
          $$GeJuRulesDocumentsTableCreateCompanionBuilder,
          $$GeJuRulesDocumentsTableUpdateCompanionBuilder,
          (
            GeJuRulesDocumentEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $GeJuRulesDocumentsTable,
              GeJuRulesDocumentEntry
            >,
          ),
          GeJuRulesDocumentEntry,
          PrefetchHooks Function()
        > {
  $$GeJuRulesDocumentsTableTableManager(
    _$QizhengsiyuDatabase db,
    $GeJuRulesDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuRulesDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuRulesDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuRulesDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeJuRulesDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => GeJuRulesDocumentsCompanion.insert(
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

typedef $$GeJuRulesDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $GeJuRulesDocumentsTable,
      GeJuRulesDocumentEntry,
      $$GeJuRulesDocumentsTableFilterComposer,
      $$GeJuRulesDocumentsTableOrderingComposer,
      $$GeJuRulesDocumentsTableAnnotationComposer,
      $$GeJuRulesDocumentsTableCreateCompanionBuilder,
      $$GeJuRulesDocumentsTableUpdateCompanionBuilder,
      (
        GeJuRulesDocumentEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $GeJuRulesDocumentsTable,
          GeJuRulesDocumentEntry
        >,
      ),
      GeJuRulesDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$GeJuContentDocumentsTableCreateCompanionBuilder =
    GeJuContentDocumentsCompanion Function({
      required String fileName,
      required String payloadJson,
      Value<int> rowid,
    });
typedef $$GeJuContentDocumentsTableUpdateCompanionBuilder =
    GeJuContentDocumentsCompanion Function({
      Value<String> fileName,
      Value<String> payloadJson,
      Value<int> rowid,
    });

class $$GeJuContentDocumentsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuContentDocumentsTable> {
  $$GeJuContentDocumentsTableFilterComposer({
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

class $$GeJuContentDocumentsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuContentDocumentsTable> {
  $$GeJuContentDocumentsTableOrderingComposer({
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

class $$GeJuContentDocumentsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $GeJuContentDocumentsTable> {
  $$GeJuContentDocumentsTableAnnotationComposer({
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

class $$GeJuContentDocumentsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $GeJuContentDocumentsTable,
          GeJuContentDocumentEntry,
          $$GeJuContentDocumentsTableFilterComposer,
          $$GeJuContentDocumentsTableOrderingComposer,
          $$GeJuContentDocumentsTableAnnotationComposer,
          $$GeJuContentDocumentsTableCreateCompanionBuilder,
          $$GeJuContentDocumentsTableUpdateCompanionBuilder,
          (
            GeJuContentDocumentEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $GeJuContentDocumentsTable,
              GeJuContentDocumentEntry
            >,
          ),
          GeJuContentDocumentEntry,
          PrefetchHooks Function()
        > {
  $$GeJuContentDocumentsTableTableManager(
    _$QizhengsiyuDatabase db,
    $GeJuContentDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuContentDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuContentDocumentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GeJuContentDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fileName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeJuContentDocumentsCompanion(
                fileName: fileName,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileName,
                required String payloadJson,
                Value<int> rowid = const Value.absent(),
              }) => GeJuContentDocumentsCompanion.insert(
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

typedef $$GeJuContentDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $GeJuContentDocumentsTable,
      GeJuContentDocumentEntry,
      $$GeJuContentDocumentsTableFilterComposer,
      $$GeJuContentDocumentsTableOrderingComposer,
      $$GeJuContentDocumentsTableAnnotationComposer,
      $$GeJuContentDocumentsTableCreateCompanionBuilder,
      $$GeJuContentDocumentsTableUpdateCompanionBuilder,
      (
        GeJuContentDocumentEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $GeJuContentDocumentsTable,
          GeJuContentDocumentEntry
        >,
      ),
      GeJuContentDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$DatasetGenerationsTableCreateCompanionBuilder =
    DatasetGenerationsCompanion Function({
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
typedef $$DatasetGenerationsTableUpdateCompanionBuilder =
    DatasetGenerationsCompanion Function({
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

class $$DatasetGenerationsTableFilterComposer
    extends Composer<_$QizhengsiyuDatabase, $DatasetGenerationsTable> {
  $$DatasetGenerationsTableFilterComposer({
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

class $$DatasetGenerationsTableOrderingComposer
    extends Composer<_$QizhengsiyuDatabase, $DatasetGenerationsTable> {
  $$DatasetGenerationsTableOrderingComposer({
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

class $$DatasetGenerationsTableAnnotationComposer
    extends Composer<_$QizhengsiyuDatabase, $DatasetGenerationsTable> {
  $$DatasetGenerationsTableAnnotationComposer({
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

class $$DatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$QizhengsiyuDatabase,
          $DatasetGenerationsTable,
          DatasetGenerationEntry,
          $$DatasetGenerationsTableFilterComposer,
          $$DatasetGenerationsTableOrderingComposer,
          $$DatasetGenerationsTableAnnotationComposer,
          $$DatasetGenerationsTableCreateCompanionBuilder,
          $$DatasetGenerationsTableUpdateCompanionBuilder,
          (
            DatasetGenerationEntry,
            BaseReferences<
              _$QizhengsiyuDatabase,
              $DatasetGenerationsTable,
              DatasetGenerationEntry
            >,
          ),
          DatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$DatasetGenerationsTableTableManager(
    _$QizhengsiyuDatabase db,
    $DatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatasetGenerationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DatasetGenerationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DatasetGenerationsTableAnnotationComposer(
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
              }) => DatasetGenerationsCompanion(
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
              }) => DatasetGenerationsCompanion.insert(
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

typedef $$DatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$QizhengsiyuDatabase,
      $DatasetGenerationsTable,
      DatasetGenerationEntry,
      $$DatasetGenerationsTableFilterComposer,
      $$DatasetGenerationsTableOrderingComposer,
      $$DatasetGenerationsTableAnnotationComposer,
      $$DatasetGenerationsTableCreateCompanionBuilder,
      $$DatasetGenerationsTableUpdateCompanionBuilder,
      (
        DatasetGenerationEntry,
        BaseReferences<
          _$QizhengsiyuDatabase,
          $DatasetGenerationsTable,
          DatasetGenerationEntry
        >,
      ),
      DatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $QizhengsiyuDatabaseManager {
  final _$QizhengsiyuDatabase _db;
  $QizhengsiyuDatabaseManager(this._db);
  $$StarPositionStatusesTableTableManager get starPositionStatuses =>
      $$StarPositionStatusesTableTableManager(_db, _db.starPositionStatuses);
  $$GeJuPatternsTableTableManager get geJuPatterns =>
      $$GeJuPatternsTableTableManager(_db, _db.geJuPatterns);
  $$GeJuSchoolsTableTableManager get geJuSchools =>
      $$GeJuSchoolsTableTableManager(_db, _db.geJuSchools);
  $$GeJuCategoriesTableTableManager get geJuCategories =>
      $$GeJuCategoriesTableTableManager(_db, _db.geJuCategories);
  $$GeJuRulesTableTableManager get geJuRules =>
      $$GeJuRulesTableTableManager(_db, _db.geJuRules);
  $$GeJuVersionsTableTableManager get geJuVersions =>
      $$GeJuVersionsTableTableManager(_db, _db.geJuVersions);
  $$ZhouTianDocumentsTableTableManager get zhouTianDocuments =>
      $$ZhouTianDocumentsTableTableManager(_db, _db.zhouTianDocuments);
  $$EphemerisDocumentsTableTableManager get ephemerisDocuments =>
      $$EphemerisDocumentsTableTableManager(_db, _db.ephemerisDocuments);
  $$ShenShaDocumentsTableTableManager get shenShaDocuments =>
      $$ShenShaDocumentsTableTableManager(_db, _db.shenShaDocuments);
  $$HuaYaoDocumentsTableTableManager get huaYaoDocuments =>
      $$HuaYaoDocumentsTableTableManager(_db, _db.huaYaoDocuments);
  $$GeJuRulesDocumentsTableTableManager get geJuRulesDocuments =>
      $$GeJuRulesDocumentsTableTableManager(_db, _db.geJuRulesDocuments);
  $$GeJuContentDocumentsTableTableManager get geJuContentDocuments =>
      $$GeJuContentDocumentsTableTableManager(_db, _db.geJuContentDocuments);
  $$DatasetGenerationsTableTableManager get datasetGenerations =>
      $$DatasetGenerationsTableTableManager(_db, _db.datasetGenerations);
}
