// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_database.dart';

// ignore_for_file: type=lint
class $AdminDivisionsTable extends AdminDivisions
    with TableInfo<$AdminDivisionsTable, AdminDivisionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdminDivisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentCodeMeta = const VerificationMeta(
    'parentCode',
  );
  @override
  late final GeneratedColumn<String> parentCode = GeneratedColumn<String>(
    'parent_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    parentCode,
    level,
    name,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admin_division';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdminDivisionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('parent_code')) {
      context.handle(
        _parentCodeMeta,
        parentCode.isAcceptableOrUnknown(data['parent_code']!, _parentCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_parentCodeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  AdminDivisionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminDivisionEntry(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      parentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_code'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
    );
  }

  @override
  $AdminDivisionsTable createAlias(String alias) {
    return $AdminDivisionsTable(attachedDatabase, alias);
  }
}

class AdminDivisionEntry extends DataClass
    implements Insertable<AdminDivisionEntry> {
  final String code;
  final String parentCode;
  final int level;
  final String name;
  final double? latitude;
  final double? longitude;
  const AdminDivisionEntry({
    required this.code,
    required this.parentCode,
    required this.level,
    required this.name,
    this.latitude,
    this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['parent_code'] = Variable<String>(parentCode);
    map['level'] = Variable<int>(level);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  AdminDivisionsCompanion toCompanion(bool nullToAbsent) {
    return AdminDivisionsCompanion(
      code: Value(code),
      parentCode: Value(parentCode),
      level: Value(level),
      name: Value(name),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory AdminDivisionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminDivisionEntry(
      code: serializer.fromJson<String>(json['code']),
      parentCode: serializer.fromJson<String>(json['parentCode']),
      level: serializer.fromJson<int>(json['level']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'parentCode': serializer.toJson<String>(parentCode),
      'level': serializer.toJson<int>(level),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  AdminDivisionEntry copyWith({
    String? code,
    String? parentCode,
    int? level,
    String? name,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
  }) => AdminDivisionEntry(
    code: code ?? this.code,
    parentCode: parentCode ?? this.parentCode,
    level: level ?? this.level,
    name: name ?? this.name,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
  );
  AdminDivisionEntry copyWithCompanion(AdminDivisionsCompanion data) {
    return AdminDivisionEntry(
      code: data.code.present ? data.code.value : this.code,
      parentCode: data.parentCode.present
          ? data.parentCode.value
          : this.parentCode,
      level: data.level.present ? data.level.value : this.level,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminDivisionEntry(')
          ..write('code: $code, ')
          ..write('parentCode: $parentCode, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, parentCode, level, name, latitude, longitude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminDivisionEntry &&
          other.code == this.code &&
          other.parentCode == this.parentCode &&
          other.level == this.level &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class AdminDivisionsCompanion extends UpdateCompanion<AdminDivisionEntry> {
  final Value<String> code;
  final Value<String> parentCode;
  final Value<int> level;
  final Value<String> name;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const AdminDivisionsCompanion({
    this.code = const Value.absent(),
    this.parentCode = const Value.absent(),
    this.level = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdminDivisionsCompanion.insert({
    required String code,
    required String parentCode,
    required int level,
    required String name,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       parentCode = Value(parentCode),
       level = Value(level),
       name = Value(name);
  static Insertable<AdminDivisionEntry> custom({
    Expression<String>? code,
    Expression<String>? parentCode,
    Expression<int>? level,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (parentCode != null) 'parent_code': parentCode,
      if (level != null) 'level': level,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdminDivisionsCompanion copyWith({
    Value<String>? code,
    Value<String>? parentCode,
    Value<int>? level,
    Value<String>? name,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? rowid,
  }) {
    return AdminDivisionsCompanion(
      code: code ?? this.code,
      parentCode: parentCode ?? this.parentCode,
      level: level ?? this.level,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (parentCode.present) {
      map['parent_code'] = Variable<String>(parentCode.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminDivisionsCompanion(')
          ..write('code: $code, ')
          ..write('parentCode: $parentCode, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegionsTable extends Regions with TableInfo<$RegionsTable, RegionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _translationsJsonMeta = const VerificationMeta(
    'translationsJson',
  );
  @override
  late final GeneratedColumn<String> translationsJson = GeneratedColumn<String>(
    'translations_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wikiDataIdMeta = const VerificationMeta(
    'wikiDataId',
  );
  @override
  late final GeneratedColumn<String> wikiDataId = GeneratedColumn<String>(
    'wiki_data_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    translationsJson,
    wikiDataId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'region';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('translations_json')) {
      context.handle(
        _translationsJsonMeta,
        translationsJson.isAcceptableOrUnknown(
          data['translations_json']!,
          _translationsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationsJsonMeta);
    }
    if (data.containsKey('wiki_data_id')) {
      context.handle(
        _wikiDataIdMeta,
        wikiDataId.isAcceptableOrUnknown(
          data['wiki_data_id']!,
          _wikiDataIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      translationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translations_json'],
      )!,
      wikiDataId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wiki_data_id'],
      ),
    );
  }

  @override
  $RegionsTable createAlias(String alias) {
    return $RegionsTable(attachedDatabase, alias);
  }
}

class RegionEntry extends DataClass implements Insertable<RegionEntry> {
  final int id;
  final String name;
  final String translationsJson;
  final String? wikiDataId;
  const RegionEntry({
    required this.id,
    required this.name,
    required this.translationsJson,
    this.wikiDataId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['translations_json'] = Variable<String>(translationsJson);
    if (!nullToAbsent || wikiDataId != null) {
      map['wiki_data_id'] = Variable<String>(wikiDataId);
    }
    return map;
  }

  RegionsCompanion toCompanion(bool nullToAbsent) {
    return RegionsCompanion(
      id: Value(id),
      name: Value(name),
      translationsJson: Value(translationsJson),
      wikiDataId: wikiDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(wikiDataId),
    );
  }

  factory RegionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegionEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      translationsJson: serializer.fromJson<String>(json['translationsJson']),
      wikiDataId: serializer.fromJson<String?>(json['wikiDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'translationsJson': serializer.toJson<String>(translationsJson),
      'wikiDataId': serializer.toJson<String?>(wikiDataId),
    };
  }

  RegionEntry copyWith({
    int? id,
    String? name,
    String? translationsJson,
    Value<String?> wikiDataId = const Value.absent(),
  }) => RegionEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    translationsJson: translationsJson ?? this.translationsJson,
    wikiDataId: wikiDataId.present ? wikiDataId.value : this.wikiDataId,
  );
  RegionEntry copyWithCompanion(RegionsCompanion data) {
    return RegionEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      translationsJson: data.translationsJson.present
          ? data.translationsJson.value
          : this.translationsJson,
      wikiDataId: data.wikiDataId.present
          ? data.wikiDataId.value
          : this.wikiDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegionEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('translationsJson: $translationsJson, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, translationsJson, wikiDataId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegionEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.translationsJson == this.translationsJson &&
          other.wikiDataId == this.wikiDataId);
}

class RegionsCompanion extends UpdateCompanion<RegionEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> translationsJson;
  final Value<String?> wikiDataId;
  const RegionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.translationsJson = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  });
  RegionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String translationsJson,
    this.wikiDataId = const Value.absent(),
  }) : name = Value(name),
       translationsJson = Value(translationsJson);
  static Insertable<RegionEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? translationsJson,
    Expression<String>? wikiDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (translationsJson != null) 'translations_json': translationsJson,
      if (wikiDataId != null) 'wiki_data_id': wikiDataId,
    });
  }

  RegionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? translationsJson,
    Value<String?>? wikiDataId,
  }) {
    return RegionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      translationsJson: translationsJson ?? this.translationsJson,
      wikiDataId: wikiDataId ?? this.wikiDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (translationsJson.present) {
      map['translations_json'] = Variable<String>(translationsJson.value);
    }
    if (wikiDataId.present) {
      map['wiki_data_id'] = Variable<String>(wikiDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('translationsJson: $translationsJson, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }
}

class $CitiesTable extends Cities with TableInfo<$CitiesTable, CityEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _provinceCodeMeta = const VerificationMeta(
    'provinceCode',
  );
  @override
  late final GeneratedColumn<String> provinceCode = GeneratedColumn<String>(
    'province_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearCodeMeta = const VerificationMeta(
    'yearCode',
  );
  @override
  late final GeneratedColumn<String> yearCode = GeneratedColumn<String>(
    'year_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, name, provinceCode, yearCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'city';
  @override
  VerificationContext validateIntegrity(
    Insertable<CityEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('province_code')) {
      context.handle(
        _provinceCodeMeta,
        provinceCode.isAcceptableOrUnknown(
          data['province_code']!,
          _provinceCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_provinceCodeMeta);
    }
    if (data.containsKey('year_code')) {
      context.handle(
        _yearCodeMeta,
        yearCode.isAcceptableOrUnknown(data['year_code']!, _yearCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_yearCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  CityEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CityEntry(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      provinceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province_code'],
      )!,
      yearCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_code'],
      )!,
    );
  }

  @override
  $CitiesTable createAlias(String alias) {
    return $CitiesTable(attachedDatabase, alias);
  }
}

class CityEntry extends DataClass implements Insertable<CityEntry> {
  final String code;
  final String name;
  final String provinceCode;
  final String yearCode;
  const CityEntry({
    required this.code,
    required this.name,
    required this.provinceCode,
    required this.yearCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['province_code'] = Variable<String>(provinceCode);
    map['year_code'] = Variable<String>(yearCode);
    return map;
  }

  CitiesCompanion toCompanion(bool nullToAbsent) {
    return CitiesCompanion(
      code: Value(code),
      name: Value(name),
      provinceCode: Value(provinceCode),
      yearCode: Value(yearCode),
    );
  }

  factory CityEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CityEntry(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      provinceCode: serializer.fromJson<String>(json['provinceCode']),
      yearCode: serializer.fromJson<String>(json['yearCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'provinceCode': serializer.toJson<String>(provinceCode),
      'yearCode': serializer.toJson<String>(yearCode),
    };
  }

  CityEntry copyWith({
    String? code,
    String? name,
    String? provinceCode,
    String? yearCode,
  }) => CityEntry(
    code: code ?? this.code,
    name: name ?? this.name,
    provinceCode: provinceCode ?? this.provinceCode,
    yearCode: yearCode ?? this.yearCode,
  );
  CityEntry copyWithCompanion(CitiesCompanion data) {
    return CityEntry(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      provinceCode: data.provinceCode.present
          ? data.provinceCode.value
          : this.provinceCode,
      yearCode: data.yearCode.present ? data.yearCode.value : this.yearCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CityEntry(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('provinceCode: $provinceCode, ')
          ..write('yearCode: $yearCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, provinceCode, yearCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CityEntry &&
          other.code == this.code &&
          other.name == this.name &&
          other.provinceCode == this.provinceCode &&
          other.yearCode == this.yearCode);
}

class CitiesCompanion extends UpdateCompanion<CityEntry> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> provinceCode;
  final Value<String> yearCode;
  final Value<int> rowid;
  const CitiesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.provinceCode = const Value.absent(),
    this.yearCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CitiesCompanion.insert({
    required String code,
    required String name,
    required String provinceCode,
    required String yearCode,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       provinceCode = Value(provinceCode),
       yearCode = Value(yearCode);
  static Insertable<CityEntry> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? provinceCode,
    Expression<String>? yearCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (provinceCode != null) 'province_code': provinceCode,
      if (yearCode != null) 'year_code': yearCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CitiesCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? provinceCode,
    Value<String>? yearCode,
    Value<int>? rowid,
  }) {
    return CitiesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      provinceCode: provinceCode ?? this.provinceCode,
      yearCode: yearCode ?? this.yearCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (provinceCode.present) {
      map['province_code'] = Variable<String>(provinceCode.value);
    }
    if (yearCode.present) {
      map['year_code'] = Variable<String>(yearCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CitiesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('provinceCode: $provinceCode, ')
          ..write('yearCode: $yearCode, ')
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

abstract class _$GeoDatabase extends GeneratedDatabase {
  _$GeoDatabase(QueryExecutor e) : super(e);
  $GeoDatabaseManager get managers => $GeoDatabaseManager(this);
  late final $AdminDivisionsTable adminDivisions = $AdminDivisionsTable(this);
  late final $RegionsTable regions = $RegionsTable(this);
  late final $CitiesTable cities = $CitiesTable(this);
  late final $DatasetGenerationsTable datasetGenerations =
      $DatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    adminDivisions,
    regions,
    cities,
    datasetGenerations,
  ];
}

typedef $$AdminDivisionsTableCreateCompanionBuilder =
    AdminDivisionsCompanion Function({
      required String code,
      required String parentCode,
      required int level,
      required String name,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });
typedef $$AdminDivisionsTableUpdateCompanionBuilder =
    AdminDivisionsCompanion Function({
      Value<String> code,
      Value<String> parentCode,
      Value<int> level,
      Value<String> name,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> rowid,
    });

class $$AdminDivisionsTableFilterComposer
    extends Composer<_$GeoDatabase, $AdminDivisionsTable> {
  $$AdminDivisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentCode => $composableBuilder(
    column: $table.parentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdminDivisionsTableOrderingComposer
    extends Composer<_$GeoDatabase, $AdminDivisionsTable> {
  $$AdminDivisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentCode => $composableBuilder(
    column: $table.parentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdminDivisionsTableAnnotationComposer
    extends Composer<_$GeoDatabase, $AdminDivisionsTable> {
  $$AdminDivisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get parentCode => $composableBuilder(
    column: $table.parentCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$AdminDivisionsTableTableManager
    extends
        RootTableManager<
          _$GeoDatabase,
          $AdminDivisionsTable,
          AdminDivisionEntry,
          $$AdminDivisionsTableFilterComposer,
          $$AdminDivisionsTableOrderingComposer,
          $$AdminDivisionsTableAnnotationComposer,
          $$AdminDivisionsTableCreateCompanionBuilder,
          $$AdminDivisionsTableUpdateCompanionBuilder,
          (
            AdminDivisionEntry,
            BaseReferences<
              _$GeoDatabase,
              $AdminDivisionsTable,
              AdminDivisionEntry
            >,
          ),
          AdminDivisionEntry,
          PrefetchHooks Function()
        > {
  $$AdminDivisionsTableTableManager(
    _$GeoDatabase db,
    $AdminDivisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdminDivisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdminDivisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdminDivisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> parentCode = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdminDivisionsCompanion(
                code: code,
                parentCode: parentCode,
                level: level,
                name: name,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String parentCode,
                required int level,
                required String name,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdminDivisionsCompanion.insert(
                code: code,
                parentCode: parentCode,
                level: level,
                name: name,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdminDivisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$GeoDatabase,
      $AdminDivisionsTable,
      AdminDivisionEntry,
      $$AdminDivisionsTableFilterComposer,
      $$AdminDivisionsTableOrderingComposer,
      $$AdminDivisionsTableAnnotationComposer,
      $$AdminDivisionsTableCreateCompanionBuilder,
      $$AdminDivisionsTableUpdateCompanionBuilder,
      (
        AdminDivisionEntry,
        BaseReferences<_$GeoDatabase, $AdminDivisionsTable, AdminDivisionEntry>,
      ),
      AdminDivisionEntry,
      PrefetchHooks Function()
    >;
typedef $$RegionsTableCreateCompanionBuilder =
    RegionsCompanion Function({
      Value<int> id,
      required String name,
      required String translationsJson,
      Value<String?> wikiDataId,
    });
typedef $$RegionsTableUpdateCompanionBuilder =
    RegionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> translationsJson,
      Value<String?> wikiDataId,
    });

class $$RegionsTableFilterComposer
    extends Composer<_$GeoDatabase, $RegionsTable> {
  $$RegionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationsJson => $composableBuilder(
    column: $table.translationsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wikiDataId => $composableBuilder(
    column: $table.wikiDataId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RegionsTableOrderingComposer
    extends Composer<_$GeoDatabase, $RegionsTable> {
  $$RegionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationsJson => $composableBuilder(
    column: $table.translationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wikiDataId => $composableBuilder(
    column: $table.wikiDataId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RegionsTableAnnotationComposer
    extends Composer<_$GeoDatabase, $RegionsTable> {
  $$RegionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get translationsJson => $composableBuilder(
    column: $table.translationsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wikiDataId => $composableBuilder(
    column: $table.wikiDataId,
    builder: (column) => column,
  );
}

class $$RegionsTableTableManager
    extends
        RootTableManager<
          _$GeoDatabase,
          $RegionsTable,
          RegionEntry,
          $$RegionsTableFilterComposer,
          $$RegionsTableOrderingComposer,
          $$RegionsTableAnnotationComposer,
          $$RegionsTableCreateCompanionBuilder,
          $$RegionsTableUpdateCompanionBuilder,
          (
            RegionEntry,
            BaseReferences<_$GeoDatabase, $RegionsTable, RegionEntry>,
          ),
          RegionEntry,
          PrefetchHooks Function()
        > {
  $$RegionsTableTableManager(_$GeoDatabase db, $RegionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> translationsJson = const Value.absent(),
                Value<String?> wikiDataId = const Value.absent(),
              }) => RegionsCompanion(
                id: id,
                name: name,
                translationsJson: translationsJson,
                wikiDataId: wikiDataId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String translationsJson,
                Value<String?> wikiDataId = const Value.absent(),
              }) => RegionsCompanion.insert(
                id: id,
                name: name,
                translationsJson: translationsJson,
                wikiDataId: wikiDataId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RegionsTableProcessedTableManager =
    ProcessedTableManager<
      _$GeoDatabase,
      $RegionsTable,
      RegionEntry,
      $$RegionsTableFilterComposer,
      $$RegionsTableOrderingComposer,
      $$RegionsTableAnnotationComposer,
      $$RegionsTableCreateCompanionBuilder,
      $$RegionsTableUpdateCompanionBuilder,
      (RegionEntry, BaseReferences<_$GeoDatabase, $RegionsTable, RegionEntry>),
      RegionEntry,
      PrefetchHooks Function()
    >;
typedef $$CitiesTableCreateCompanionBuilder =
    CitiesCompanion Function({
      required String code,
      required String name,
      required String provinceCode,
      required String yearCode,
      Value<int> rowid,
    });
typedef $$CitiesTableUpdateCompanionBuilder =
    CitiesCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> provinceCode,
      Value<String> yearCode,
      Value<int> rowid,
    });

class $$CitiesTableFilterComposer
    extends Composer<_$GeoDatabase, $CitiesTable> {
  $$CitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provinceCode => $composableBuilder(
    column: $table.provinceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yearCode => $composableBuilder(
    column: $table.yearCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CitiesTableOrderingComposer
    extends Composer<_$GeoDatabase, $CitiesTable> {
  $$CitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provinceCode => $composableBuilder(
    column: $table.provinceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yearCode => $composableBuilder(
    column: $table.yearCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CitiesTableAnnotationComposer
    extends Composer<_$GeoDatabase, $CitiesTable> {
  $$CitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get provinceCode => $composableBuilder(
    column: $table.provinceCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get yearCode =>
      $composableBuilder(column: $table.yearCode, builder: (column) => column);
}

class $$CitiesTableTableManager
    extends
        RootTableManager<
          _$GeoDatabase,
          $CitiesTable,
          CityEntry,
          $$CitiesTableFilterComposer,
          $$CitiesTableOrderingComposer,
          $$CitiesTableAnnotationComposer,
          $$CitiesTableCreateCompanionBuilder,
          $$CitiesTableUpdateCompanionBuilder,
          (CityEntry, BaseReferences<_$GeoDatabase, $CitiesTable, CityEntry>),
          CityEntry,
          PrefetchHooks Function()
        > {
  $$CitiesTableTableManager(_$GeoDatabase db, $CitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> provinceCode = const Value.absent(),
                Value<String> yearCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CitiesCompanion(
                code: code,
                name: name,
                provinceCode: provinceCode,
                yearCode: yearCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String provinceCode,
                required String yearCode,
                Value<int> rowid = const Value.absent(),
              }) => CitiesCompanion.insert(
                code: code,
                name: name,
                provinceCode: provinceCode,
                yearCode: yearCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$GeoDatabase,
      $CitiesTable,
      CityEntry,
      $$CitiesTableFilterComposer,
      $$CitiesTableOrderingComposer,
      $$CitiesTableAnnotationComposer,
      $$CitiesTableCreateCompanionBuilder,
      $$CitiesTableUpdateCompanionBuilder,
      (CityEntry, BaseReferences<_$GeoDatabase, $CitiesTable, CityEntry>),
      CityEntry,
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
    extends Composer<_$GeoDatabase, $DatasetGenerationsTable> {
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
    extends Composer<_$GeoDatabase, $DatasetGenerationsTable> {
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
    extends Composer<_$GeoDatabase, $DatasetGenerationsTable> {
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
          _$GeoDatabase,
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
              _$GeoDatabase,
              $DatasetGenerationsTable,
              DatasetGenerationEntry
            >,
          ),
          DatasetGenerationEntry,
          PrefetchHooks Function()
        > {
  $$DatasetGenerationsTableTableManager(
    _$GeoDatabase db,
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
      _$GeoDatabase,
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
          _$GeoDatabase,
          $DatasetGenerationsTable,
          DatasetGenerationEntry
        >,
      ),
      DatasetGenerationEntry,
      PrefetchHooks Function()
    >;

class $GeoDatabaseManager {
  final _$GeoDatabase _db;
  $GeoDatabaseManager(this._db);
  $$AdminDivisionsTableTableManager get adminDivisions =>
      $$AdminDivisionsTableTableManager(_db, _db.adminDivisions);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db, _db.regions);
  $$CitiesTableTableManager get cities =>
      $$CitiesTableTableManager(_db, _db.cities);
  $$DatasetGenerationsTableTableManager get datasetGenerations =>
      $$DatasetGenerationsTableTableManager(_db, _db.datasetGenerations);
}
