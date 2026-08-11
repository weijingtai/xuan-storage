// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_database.dart';

// ignore_for_file: type=lint
class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, DictionaryCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radicalMeta = const VerificationMeta(
    'radical',
  );
  @override
  late final GeneratedColumn<String> radical = GeneratedColumn<String>(
    'radical',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decompositionMeta = const VerificationMeta(
    'decomposition',
  );
  @override
  late final GeneratedColumn<String> decomposition = GeneratedColumn<String>(
    'decomposition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchesJsonMeta = const VerificationMeta(
    'matchesJson',
  );
  @override
  late final GeneratedColumn<String> matchesJson = GeneratedColumn<String>(
    'matches_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    character,
    definition,
    radical,
    decomposition,
    matchesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<DictionaryCharacter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('radical')) {
      context.handle(
        _radicalMeta,
        radical.isAcceptableOrUnknown(data['radical']!, _radicalMeta),
      );
    }
    if (data.containsKey('decomposition')) {
      context.handle(
        _decompositionMeta,
        decomposition.isAcceptableOrUnknown(
          data['decomposition']!,
          _decompositionMeta,
        ),
      );
    }
    if (data.containsKey('matches_json')) {
      context.handle(
        _matchesJsonMeta,
        matchesJson.isAcceptableOrUnknown(
          data['matches_json']!,
          _matchesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DictionaryCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryCharacter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      ),
      radical: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}radical'],
      ),
      decomposition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decomposition'],
      ),
      matchesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matches_json'],
      ),
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class DictionaryCharacter extends DataClass
    implements Insertable<DictionaryCharacter> {
  final int id;
  final String character;
  final String? definition;
  final String? radical;
  final String? decomposition;
  final String? matchesJson;
  const DictionaryCharacter({
    required this.id,
    required this.character,
    this.definition,
    this.radical,
    this.decomposition,
    this.matchesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character'] = Variable<String>(character);
    if (!nullToAbsent || definition != null) {
      map['definition'] = Variable<String>(definition);
    }
    if (!nullToAbsent || radical != null) {
      map['radical'] = Variable<String>(radical);
    }
    if (!nullToAbsent || decomposition != null) {
      map['decomposition'] = Variable<String>(decomposition);
    }
    if (!nullToAbsent || matchesJson != null) {
      map['matches_json'] = Variable<String>(matchesJson);
    }
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      character: Value(character),
      definition: definition == null && nullToAbsent
          ? const Value.absent()
          : Value(definition),
      radical: radical == null && nullToAbsent
          ? const Value.absent()
          : Value(radical),
      decomposition: decomposition == null && nullToAbsent
          ? const Value.absent()
          : Value(decomposition),
      matchesJson: matchesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(matchesJson),
    );
  }

  factory DictionaryCharacter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryCharacter(
      id: serializer.fromJson<int>(json['id']),
      character: serializer.fromJson<String>(json['character']),
      definition: serializer.fromJson<String?>(json['definition']),
      radical: serializer.fromJson<String?>(json['radical']),
      decomposition: serializer.fromJson<String?>(json['decomposition']),
      matchesJson: serializer.fromJson<String?>(json['matchesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'character': serializer.toJson<String>(character),
      'definition': serializer.toJson<String?>(definition),
      'radical': serializer.toJson<String?>(radical),
      'decomposition': serializer.toJson<String?>(decomposition),
      'matchesJson': serializer.toJson<String?>(matchesJson),
    };
  }

  DictionaryCharacter copyWith({
    int? id,
    String? character,
    Value<String?> definition = const Value.absent(),
    Value<String?> radical = const Value.absent(),
    Value<String?> decomposition = const Value.absent(),
    Value<String?> matchesJson = const Value.absent(),
  }) => DictionaryCharacter(
    id: id ?? this.id,
    character: character ?? this.character,
    definition: definition.present ? definition.value : this.definition,
    radical: radical.present ? radical.value : this.radical,
    decomposition: decomposition.present
        ? decomposition.value
        : this.decomposition,
    matchesJson: matchesJson.present ? matchesJson.value : this.matchesJson,
  );
  DictionaryCharacter copyWithCompanion(CharactersCompanion data) {
    return DictionaryCharacter(
      id: data.id.present ? data.id.value : this.id,
      character: data.character.present ? data.character.value : this.character,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      radical: data.radical.present ? data.radical.value : this.radical,
      decomposition: data.decomposition.present
          ? data.decomposition.value
          : this.decomposition,
      matchesJson: data.matchesJson.present
          ? data.matchesJson.value
          : this.matchesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryCharacter(')
          ..write('id: $id, ')
          ..write('character: $character, ')
          ..write('definition: $definition, ')
          ..write('radical: $radical, ')
          ..write('decomposition: $decomposition, ')
          ..write('matchesJson: $matchesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    character,
    definition,
    radical,
    decomposition,
    matchesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryCharacter &&
          other.id == this.id &&
          other.character == this.character &&
          other.definition == this.definition &&
          other.radical == this.radical &&
          other.decomposition == this.decomposition &&
          other.matchesJson == this.matchesJson);
}

class CharactersCompanion extends UpdateCompanion<DictionaryCharacter> {
  final Value<int> id;
  final Value<String> character;
  final Value<String?> definition;
  final Value<String?> radical;
  final Value<String?> decomposition;
  final Value<String?> matchesJson;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.character = const Value.absent(),
    this.definition = const Value.absent(),
    this.radical = const Value.absent(),
    this.decomposition = const Value.absent(),
    this.matchesJson = const Value.absent(),
  });
  CharactersCompanion.insert({
    this.id = const Value.absent(),
    required String character,
    this.definition = const Value.absent(),
    this.radical = const Value.absent(),
    this.decomposition = const Value.absent(),
    this.matchesJson = const Value.absent(),
  }) : character = Value(character);
  static Insertable<DictionaryCharacter> custom({
    Expression<int>? id,
    Expression<String>? character,
    Expression<String>? definition,
    Expression<String>? radical,
    Expression<String>? decomposition,
    Expression<String>? matchesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (character != null) 'character': character,
      if (definition != null) 'definition': definition,
      if (radical != null) 'radical': radical,
      if (decomposition != null) 'decomposition': decomposition,
      if (matchesJson != null) 'matches_json': matchesJson,
    });
  }

  CharactersCompanion copyWith({
    Value<int>? id,
    Value<String>? character,
    Value<String?>? definition,
    Value<String?>? radical,
    Value<String?>? decomposition,
    Value<String?>? matchesJson,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      character: character ?? this.character,
      definition: definition ?? this.definition,
      radical: radical ?? this.radical,
      decomposition: decomposition ?? this.decomposition,
      matchesJson: matchesJson ?? this.matchesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (radical.present) {
      map['radical'] = Variable<String>(radical.value);
    }
    if (decomposition.present) {
      map['decomposition'] = Variable<String>(decomposition.value);
    }
    if (matchesJson.present) {
      map['matches_json'] = Variable<String>(matchesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('character: $character, ')
          ..write('definition: $definition, ')
          ..write('radical: $radical, ')
          ..write('decomposition: $decomposition, ')
          ..write('matchesJson: $matchesJson')
          ..write(')'))
        .toString();
  }
}

class $PinyinsTable extends Pinyins
    with TableInfo<$PinyinsTable, DictionaryPinyin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinyinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinWithToneNumberMeta =
      const VerificationMeta('pinyinWithToneNumber');
  @override
  late final GeneratedColumn<String> pinyinWithToneNumber =
      GeneratedColumn<String>(
        'pinyin_with_tone_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    characterId,
    pinyin,
    pinyinWithToneNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinyin';
  @override
  VerificationContext validateIntegrity(
    Insertable<DictionaryPinyin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
    }
    if (data.containsKey('pinyin_with_tone_number')) {
      context.handle(
        _pinyinWithToneNumberMeta,
        pinyinWithToneNumber.isAcceptableOrUnknown(
          data['pinyin_with_tone_number']!,
          _pinyinWithToneNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DictionaryPinyin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryPinyin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      )!,
      pinyinWithToneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin_with_tone_number'],
      ),
    );
  }

  @override
  $PinyinsTable createAlias(String alias) {
    return $PinyinsTable(attachedDatabase, alias);
  }
}

class DictionaryPinyin extends DataClass
    implements Insertable<DictionaryPinyin> {
  final int id;
  final int characterId;
  final String pinyin;
  final String? pinyinWithToneNumber;
  const DictionaryPinyin({
    required this.id,
    required this.characterId,
    required this.pinyin,
    this.pinyinWithToneNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<int>(characterId);
    map['pinyin'] = Variable<String>(pinyin);
    if (!nullToAbsent || pinyinWithToneNumber != null) {
      map['pinyin_with_tone_number'] = Variable<String>(pinyinWithToneNumber);
    }
    return map;
  }

  PinyinsCompanion toCompanion(bool nullToAbsent) {
    return PinyinsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      pinyin: Value(pinyin),
      pinyinWithToneNumber: pinyinWithToneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pinyinWithToneNumber),
    );
  }

  factory DictionaryPinyin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryPinyin(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<int>(json['characterId']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
      pinyinWithToneNumber: serializer.fromJson<String?>(
        json['pinyinWithToneNumber'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<int>(characterId),
      'pinyin': serializer.toJson<String>(pinyin),
      'pinyinWithToneNumber': serializer.toJson<String?>(pinyinWithToneNumber),
    };
  }

  DictionaryPinyin copyWith({
    int? id,
    int? characterId,
    String? pinyin,
    Value<String?> pinyinWithToneNumber = const Value.absent(),
  }) => DictionaryPinyin(
    id: id ?? this.id,
    characterId: characterId ?? this.characterId,
    pinyin: pinyin ?? this.pinyin,
    pinyinWithToneNumber: pinyinWithToneNumber.present
        ? pinyinWithToneNumber.value
        : this.pinyinWithToneNumber,
  );
  DictionaryPinyin copyWithCompanion(PinyinsCompanion data) {
    return DictionaryPinyin(
      id: data.id.present ? data.id.value : this.id,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      pinyinWithToneNumber: data.pinyinWithToneNumber.present
          ? data.pinyinWithToneNumber.value
          : this.pinyinWithToneNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryPinyin(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('pinyin: $pinyin, ')
          ..write('pinyinWithToneNumber: $pinyinWithToneNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, characterId, pinyin, pinyinWithToneNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryPinyin &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.pinyin == this.pinyin &&
          other.pinyinWithToneNumber == this.pinyinWithToneNumber);
}

class PinyinsCompanion extends UpdateCompanion<DictionaryPinyin> {
  final Value<int> id;
  final Value<int> characterId;
  final Value<String> pinyin;
  final Value<String?> pinyinWithToneNumber;
  const PinyinsCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.pinyinWithToneNumber = const Value.absent(),
  });
  PinyinsCompanion.insert({
    this.id = const Value.absent(),
    required int characterId,
    required String pinyin,
    this.pinyinWithToneNumber = const Value.absent(),
  }) : characterId = Value(characterId),
       pinyin = Value(pinyin);
  static Insertable<DictionaryPinyin> custom({
    Expression<int>? id,
    Expression<int>? characterId,
    Expression<String>? pinyin,
    Expression<String>? pinyinWithToneNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (pinyin != null) 'pinyin': pinyin,
      if (pinyinWithToneNumber != null)
        'pinyin_with_tone_number': pinyinWithToneNumber,
    });
  }

  PinyinsCompanion copyWith({
    Value<int>? id,
    Value<int>? characterId,
    Value<String>? pinyin,
    Value<String?>? pinyinWithToneNumber,
  }) {
    return PinyinsCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      pinyin: pinyin ?? this.pinyin,
      pinyinWithToneNumber: pinyinWithToneNumber ?? this.pinyinWithToneNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (pinyinWithToneNumber.present) {
      map['pinyin_with_tone_number'] = Variable<String>(
        pinyinWithToneNumber.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinyinsCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('pinyin: $pinyin, ')
          ..write('pinyinWithToneNumber: $pinyinWithToneNumber')
          ..write(')'))
        .toString();
  }
}

class $EtymologiesTable extends Etymologies
    with TableInfo<$EtymologiesTable, DictionaryEtymology> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtymologiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
    'hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, characterId, type, hint];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etymology';
  @override
  VerificationContext validateIntegrity(
    Insertable<DictionaryEtymology> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('hint')) {
      context.handle(
        _hintMeta,
        hint.isAcceptableOrUnknown(data['hint']!, _hintMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DictionaryEtymology map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryEtymology(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      hint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hint'],
      ),
    );
  }

  @override
  $EtymologiesTable createAlias(String alias) {
    return $EtymologiesTable(attachedDatabase, alias);
  }
}

class DictionaryEtymology extends DataClass
    implements Insertable<DictionaryEtymology> {
  final int id;
  final int characterId;
  final String? type;
  final String? hint;
  const DictionaryEtymology({
    required this.id,
    required this.characterId,
    this.type,
    this.hint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<int>(characterId);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    return map;
  }

  EtymologiesCompanion toCompanion(bool nullToAbsent) {
    return EtymologiesCompanion(
      id: Value(id),
      characterId: Value(characterId),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
    );
  }

  factory DictionaryEtymology.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryEtymology(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<int>(json['characterId']),
      type: serializer.fromJson<String?>(json['type']),
      hint: serializer.fromJson<String?>(json['hint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<int>(characterId),
      'type': serializer.toJson<String?>(type),
      'hint': serializer.toJson<String?>(hint),
    };
  }

  DictionaryEtymology copyWith({
    int? id,
    int? characterId,
    Value<String?> type = const Value.absent(),
    Value<String?> hint = const Value.absent(),
  }) => DictionaryEtymology(
    id: id ?? this.id,
    characterId: characterId ?? this.characterId,
    type: type.present ? type.value : this.type,
    hint: hint.present ? hint.value : this.hint,
  );
  DictionaryEtymology copyWithCompanion(EtymologiesCompanion data) {
    return DictionaryEtymology(
      id: data.id.present ? data.id.value : this.id,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      type: data.type.present ? data.type.value : this.type,
      hint: data.hint.present ? data.hint.value : this.hint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEtymology(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('type: $type, ')
          ..write('hint: $hint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, type, hint);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryEtymology &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.type == this.type &&
          other.hint == this.hint);
}

class EtymologiesCompanion extends UpdateCompanion<DictionaryEtymology> {
  final Value<int> id;
  final Value<int> characterId;
  final Value<String?> type;
  final Value<String?> hint;
  const EtymologiesCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.type = const Value.absent(),
    this.hint = const Value.absent(),
  });
  EtymologiesCompanion.insert({
    this.id = const Value.absent(),
    required int characterId,
    this.type = const Value.absent(),
    this.hint = const Value.absent(),
  }) : characterId = Value(characterId);
  static Insertable<DictionaryEtymology> custom({
    Expression<int>? id,
    Expression<int>? characterId,
    Expression<String>? type,
    Expression<String>? hint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (type != null) 'type': type,
      if (hint != null) 'hint': hint,
    });
  }

  EtymologiesCompanion copyWith({
    Value<int>? id,
    Value<int>? characterId,
    Value<String?>? type,
    Value<String?>? hint,
  }) {
    return EtymologiesCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      type: type ?? this.type,
      hint: hint ?? this.hint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtymologiesCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('type: $type, ')
          ..write('hint: $hint')
          ..write(')'))
        .toString();
  }
}

class $MeihuaDatasetGenerationsTable extends MeihuaDatasetGenerations
    with
        TableInfo<
          $MeihuaDatasetGenerationsTable,
          MeihuaDatasetGenerationEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeihuaDatasetGenerationsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<MeihuaDatasetGenerationEntry> instance, {
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
  MeihuaDatasetGenerationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeihuaDatasetGenerationEntry(
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
  $MeihuaDatasetGenerationsTable createAlias(String alias) {
    return $MeihuaDatasetGenerationsTable(attachedDatabase, alias);
  }
}

class MeihuaDatasetGenerationEntry extends DataClass
    implements Insertable<MeihuaDatasetGenerationEntry> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const MeihuaDatasetGenerationEntry({
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

  MeihuaDatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return MeihuaDatasetGenerationsCompanion(
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

  factory MeihuaDatasetGenerationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeihuaDatasetGenerationEntry(
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

  MeihuaDatasetGenerationEntry copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => MeihuaDatasetGenerationEntry(
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
  MeihuaDatasetGenerationEntry copyWithCompanion(
    MeihuaDatasetGenerationsCompanion data,
  ) {
    return MeihuaDatasetGenerationEntry(
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
    return (StringBuffer('MeihuaDatasetGenerationEntry(')
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
      (other is MeihuaDatasetGenerationEntry &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class MeihuaDatasetGenerationsCompanion
    extends UpdateCompanion<MeihuaDatasetGenerationEntry> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const MeihuaDatasetGenerationsCompanion({
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
  MeihuaDatasetGenerationsCompanion.insert({
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
  static Insertable<MeihuaDatasetGenerationEntry> custom({
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

  MeihuaDatasetGenerationsCompanion copyWith({
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
    return MeihuaDatasetGenerationsCompanion(
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
    return (StringBuffer('MeihuaDatasetGenerationsCompanion(')
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

abstract class _$DictionaryDatabase extends GeneratedDatabase {
  _$DictionaryDatabase(QueryExecutor e) : super(e);
  $DictionaryDatabaseManager get managers => $DictionaryDatabaseManager(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $PinyinsTable pinyins = $PinyinsTable(this);
  late final $EtymologiesTable etymologies = $EtymologiesTable(this);
  late final $MeihuaDatasetGenerationsTable meihuaDatasetGenerations =
      $MeihuaDatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    characters,
    pinyins,
    etymologies,
    meihuaDatasetGenerations,
  ];
}

typedef $$CharactersTableCreateCompanionBuilder =
    CharactersCompanion Function({
      Value<int> id,
      required String character,
      Value<String?> definition,
      Value<String?> radical,
      Value<String?> decomposition,
      Value<String?> matchesJson,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<int> id,
      Value<String> character,
      Value<String?> definition,
      Value<String?> radical,
      Value<String?> decomposition,
      Value<String?> matchesJson,
    });

class $$CharactersTableFilterComposer
    extends Composer<_$DictionaryDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
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

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get radical => $composableBuilder(
    column: $table.radical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decomposition => $composableBuilder(
    column: $table.decomposition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchesJson => $composableBuilder(
    column: $table.matchesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharactersTableOrderingComposer
    extends Composer<_$DictionaryDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
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

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get radical => $composableBuilder(
    column: $table.radical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decomposition => $composableBuilder(
    column: $table.decomposition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchesJson => $composableBuilder(
    column: $table.matchesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$DictionaryDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get radical =>
      $composableBuilder(column: $table.radical, builder: (column) => column);

  GeneratedColumn<String> get decomposition => $composableBuilder(
    column: $table.decomposition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchesJson => $composableBuilder(
    column: $table.matchesJson,
    builder: (column) => column,
  );
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$DictionaryDatabase,
          $CharactersTable,
          DictionaryCharacter,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (
            DictionaryCharacter,
            BaseReferences<
              _$DictionaryDatabase,
              $CharactersTable,
              DictionaryCharacter
            >,
          ),
          DictionaryCharacter,
          PrefetchHooks Function()
        > {
  $$CharactersTableTableManager(_$DictionaryDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> radical = const Value.absent(),
                Value<String?> decomposition = const Value.absent(),
                Value<String?> matchesJson = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                character: character,
                definition: definition,
                radical: radical,
                decomposition: decomposition,
                matchesJson: matchesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String character,
                Value<String?> definition = const Value.absent(),
                Value<String?> radical = const Value.absent(),
                Value<String?> decomposition = const Value.absent(),
                Value<String?> matchesJson = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                character: character,
                definition: definition,
                radical: radical,
                decomposition: decomposition,
                matchesJson: matchesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$DictionaryDatabase,
      $CharactersTable,
      DictionaryCharacter,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (
        DictionaryCharacter,
        BaseReferences<
          _$DictionaryDatabase,
          $CharactersTable,
          DictionaryCharacter
        >,
      ),
      DictionaryCharacter,
      PrefetchHooks Function()
    >;
typedef $$PinyinsTableCreateCompanionBuilder =
    PinyinsCompanion Function({
      Value<int> id,
      required int characterId,
      required String pinyin,
      Value<String?> pinyinWithToneNumber,
    });
typedef $$PinyinsTableUpdateCompanionBuilder =
    PinyinsCompanion Function({
      Value<int> id,
      Value<int> characterId,
      Value<String> pinyin,
      Value<String?> pinyinWithToneNumber,
    });

class $$PinyinsTableFilterComposer
    extends Composer<_$DictionaryDatabase, $PinyinsTable> {
  $$PinyinsTableFilterComposer({
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

  ColumnFilters<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyinWithToneNumber => $composableBuilder(
    column: $table.pinyinWithToneNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PinyinsTableOrderingComposer
    extends Composer<_$DictionaryDatabase, $PinyinsTable> {
  $$PinyinsTableOrderingComposer({
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

  ColumnOrderings<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyinWithToneNumber => $composableBuilder(
    column: $table.pinyinWithToneNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PinyinsTableAnnotationComposer
    extends Composer<_$DictionaryDatabase, $PinyinsTable> {
  $$PinyinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get pinyinWithToneNumber => $composableBuilder(
    column: $table.pinyinWithToneNumber,
    builder: (column) => column,
  );
}

class $$PinyinsTableTableManager
    extends
        RootTableManager<
          _$DictionaryDatabase,
          $PinyinsTable,
          DictionaryPinyin,
          $$PinyinsTableFilterComposer,
          $$PinyinsTableOrderingComposer,
          $$PinyinsTableAnnotationComposer,
          $$PinyinsTableCreateCompanionBuilder,
          $$PinyinsTableUpdateCompanionBuilder,
          (
            DictionaryPinyin,
            BaseReferences<
              _$DictionaryDatabase,
              $PinyinsTable,
              DictionaryPinyin
            >,
          ),
          DictionaryPinyin,
          PrefetchHooks Function()
        > {
  $$PinyinsTableTableManager(_$DictionaryDatabase db, $PinyinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinyinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinyinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinyinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> characterId = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
                Value<String?> pinyinWithToneNumber = const Value.absent(),
              }) => PinyinsCompanion(
                id: id,
                characterId: characterId,
                pinyin: pinyin,
                pinyinWithToneNumber: pinyinWithToneNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int characterId,
                required String pinyin,
                Value<String?> pinyinWithToneNumber = const Value.absent(),
              }) => PinyinsCompanion.insert(
                id: id,
                characterId: characterId,
                pinyin: pinyin,
                pinyinWithToneNumber: pinyinWithToneNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PinyinsTableProcessedTableManager =
    ProcessedTableManager<
      _$DictionaryDatabase,
      $PinyinsTable,
      DictionaryPinyin,
      $$PinyinsTableFilterComposer,
      $$PinyinsTableOrderingComposer,
      $$PinyinsTableAnnotationComposer,
      $$PinyinsTableCreateCompanionBuilder,
      $$PinyinsTableUpdateCompanionBuilder,
      (
        DictionaryPinyin,
        BaseReferences<_$DictionaryDatabase, $PinyinsTable, DictionaryPinyin>,
      ),
      DictionaryPinyin,
      PrefetchHooks Function()
    >;
typedef $$EtymologiesTableCreateCompanionBuilder =
    EtymologiesCompanion Function({
      Value<int> id,
      required int characterId,
      Value<String?> type,
      Value<String?> hint,
    });
typedef $$EtymologiesTableUpdateCompanionBuilder =
    EtymologiesCompanion Function({
      Value<int> id,
      Value<int> characterId,
      Value<String?> type,
      Value<String?> hint,
    });

class $$EtymologiesTableFilterComposer
    extends Composer<_$DictionaryDatabase, $EtymologiesTable> {
  $$EtymologiesTableFilterComposer({
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

  ColumnFilters<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hint => $composableBuilder(
    column: $table.hint,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EtymologiesTableOrderingComposer
    extends Composer<_$DictionaryDatabase, $EtymologiesTable> {
  $$EtymologiesTableOrderingComposer({
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

  ColumnOrderings<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hint => $composableBuilder(
    column: $table.hint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EtymologiesTableAnnotationComposer
    extends Composer<_$DictionaryDatabase, $EtymologiesTable> {
  $$EtymologiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);
}

class $$EtymologiesTableTableManager
    extends
        RootTableManager<
          _$DictionaryDatabase,
          $EtymologiesTable,
          DictionaryEtymology,
          $$EtymologiesTableFilterComposer,
          $$EtymologiesTableOrderingComposer,
          $$EtymologiesTableAnnotationComposer,
          $$EtymologiesTableCreateCompanionBuilder,
          $$EtymologiesTableUpdateCompanionBuilder,
          (
            DictionaryEtymology,
            BaseReferences<
              _$DictionaryDatabase,
              $EtymologiesTable,
              DictionaryEtymology
            >,
          ),
          DictionaryEtymology,
          PrefetchHooks Function()
        > {
  $$EtymologiesTableTableManager(
    _$DictionaryDatabase db,
    $EtymologiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EtymologiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EtymologiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EtymologiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> characterId = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> hint = const Value.absent(),
              }) => EtymologiesCompanion(
                id: id,
                characterId: characterId,
                type: type,
                hint: hint,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int characterId,
                Value<String?> type = const Value.absent(),
                Value<String?> hint = const Value.absent(),
              }) => EtymologiesCompanion.insert(
                id: id,
                characterId: characterId,
                type: type,
                hint: hint,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EtymologiesTableProcessedTableManager =
    ProcessedTableManager<
      _$DictionaryDatabase,
      $EtymologiesTable,
      DictionaryEtymology,
      $$EtymologiesTableFilterComposer,
      $$EtymologiesTableOrderingComposer,
      $$EtymologiesTableAnnotationComposer,
      $$EtymologiesTableCreateCompanionBuilder,
      $$EtymologiesTableUpdateCompanionBuilder,
      (
        DictionaryEtymology,
        BaseReferences<
          _$DictionaryDatabase,
          $EtymologiesTable,
          DictionaryEtymology
        >,
      ),
      DictionaryEtymology,
      PrefetchHooks Function()
    >;
typedef $$MeihuaDatasetGenerationsTableCreateCompanionBuilder =
    MeihuaDatasetGenerationsCompanion Function({
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
typedef $$MeihuaDatasetGenerationsTableUpdateCompanionBuilder =
    MeihuaDatasetGenerationsCompanion Function({
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

class $$MeihuaDatasetGenerationsTableFilterComposer
    extends Composer<_$DictionaryDatabase, $MeihuaDatasetGenerationsTable> {
  $$MeihuaDatasetGenerationsTableFilterComposer({
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

class $$MeihuaDatasetGenerationsTableOrderingComposer
    extends Composer<_$DictionaryDatabase, $MeihuaDatasetGenerationsTable> {
  $$MeihuaDatasetGenerationsTableOrderingComposer({
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

class $$MeihuaDatasetGenerationsTableAnnotationComposer
    extends Composer<_$DictionaryDatabase, $MeihuaDatasetGenerationsTable> {
  $$MeihuaDatasetGenerationsTableAnnotationComposer({
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

class $$MeihuaDatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$DictionaryDatabase,
          $MeihuaDatasetGenerationsTable,
          MeihuaDatasetGenerationEntry,
          $$MeihuaDatasetGenerationsTableFilterComposer,
          $$MeihuaDatasetGenerationsTableOrderingComposer,
          $$MeihuaDatasetGenerationsTableAnnotationComposer,
          $$MeihuaDatasetGenerationsTableCreateCompanionBuilder,
          $$MeihuaDatasetGenerationsTableUpdateCompanionBuilder,
          (
            MeihuaDatasetGenerationEntry,
            BaseReferences<
              _$DictionaryDatabase,
              $MeihuaDatasetGenerationsTable,
              MeihuaDatasetGenerationEntry
            >,
          ),
          MeihuaDatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$MeihuaDatasetGenerationsTableTableManager(
    _$DictionaryDatabase db,
    $MeihuaDatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeihuaDatasetGenerationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MeihuaDatasetGenerationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MeihuaDatasetGenerationsTableAnnotationComposer(
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
              }) => MeihuaDatasetGenerationsCompanion(
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
              }) => MeihuaDatasetGenerationsCompanion.insert(
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

typedef $$MeihuaDatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$DictionaryDatabase,
      $MeihuaDatasetGenerationsTable,
      MeihuaDatasetGenerationEntry,
      $$MeihuaDatasetGenerationsTableFilterComposer,
      $$MeihuaDatasetGenerationsTableOrderingComposer,
      $$MeihuaDatasetGenerationsTableAnnotationComposer,
      $$MeihuaDatasetGenerationsTableCreateCompanionBuilder,
      $$MeihuaDatasetGenerationsTableUpdateCompanionBuilder,
      (
        MeihuaDatasetGenerationEntry,
        BaseReferences<
          _$DictionaryDatabase,
          $MeihuaDatasetGenerationsTable,
          MeihuaDatasetGenerationEntry
        >,
      ),
      MeihuaDatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $DictionaryDatabaseManager {
  final _$DictionaryDatabase _db;
  $DictionaryDatabaseManager(this._db);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$PinyinsTableTableManager get pinyins =>
      $$PinyinsTableTableManager(_db, _db.pinyins);
  $$EtymologiesTableTableManager get etymologies =>
      $$EtymologiesTableTableManager(_db, _db.etymologies);
  $$MeihuaDatasetGenerationsTableTableManager get meihuaDatasetGenerations =>
      $$MeihuaDatasetGenerationsTableTableManager(
        _db,
        _db.meihuaDatasetGenerations,
      );
}
