// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_database.dart';

// ignore_for_file: type=lint
class $ThemeTokensTable extends ThemeTokens
    with TableInfo<$ThemeTokensTable, ThemeTokenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeTokensTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tokenKeyMeta = const VerificationMeta(
    'tokenKey',
  );
  @override
  late final GeneratedColumn<String> tokenKey = GeneratedColumn<String>(
    'token_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenValueMeta = const VerificationMeta(
    'tokenValue',
  );
  @override
  late final GeneratedColumn<String> tokenValue = GeneratedColumn<String>(
    'token_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    datasetId,
    generation,
    tokenKey,
    tokenValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_theme_token';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThemeTokenRow> instance, {
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
    if (data.containsKey('token_key')) {
      context.handle(
        _tokenKeyMeta,
        tokenKey.isAcceptableOrUnknown(data['token_key']!, _tokenKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenKeyMeta);
    }
    if (data.containsKey('token_value')) {
      context.handle(
        _tokenValueMeta,
        tokenValue.isAcceptableOrUnknown(data['token_value']!, _tokenValueMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {datasetId, generation, tokenKey};
  @override
  ThemeTokenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeTokenRow(
      datasetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dataset_id'],
      )!,
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      tokenKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_key'],
      )!,
      tokenValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_value'],
      )!,
    );
  }

  @override
  $ThemeTokensTable createAlias(String alias) {
    return $ThemeTokensTable(attachedDatabase, alias);
  }
}

class ThemeTokenRow extends DataClass implements Insertable<ThemeTokenRow> {
  /// 数据集 id（XRAP 主题数据集 = 'theme.package'）。
  final String datasetId;

  /// 世代号。generation 0 = bundled 内置世代（恒存在，XRAP 协议 P5）。
  final int generation;

  /// 扁平 token key（如 'light.four_zhu_card.background'）。
  final String tokenKey;

  /// token 值，JSON 文本编码。
  ///
  /// 存的是标量或 List 的 JSON 表示；Map 由构建期展平为多条 token，
  /// 落地期 v 为 Map 直接抛 StateError（照 InMemoryThemeMaterializer）。
  final String tokenValue;
  const ThemeTokenRow({
    required this.datasetId,
    required this.generation,
    required this.tokenKey,
    required this.tokenValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dataset_id'] = Variable<String>(datasetId);
    map['generation'] = Variable<int>(generation);
    map['token_key'] = Variable<String>(tokenKey);
    map['token_value'] = Variable<String>(tokenValue);
    return map;
  }

  ThemeTokensCompanion toCompanion(bool nullToAbsent) {
    return ThemeTokensCompanion(
      datasetId: Value(datasetId),
      generation: Value(generation),
      tokenKey: Value(tokenKey),
      tokenValue: Value(tokenValue),
    );
  }

  factory ThemeTokenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeTokenRow(
      datasetId: serializer.fromJson<String>(json['datasetId']),
      generation: serializer.fromJson<int>(json['generation']),
      tokenKey: serializer.fromJson<String>(json['tokenKey']),
      tokenValue: serializer.fromJson<String>(json['tokenValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'datasetId': serializer.toJson<String>(datasetId),
      'generation': serializer.toJson<int>(generation),
      'tokenKey': serializer.toJson<String>(tokenKey),
      'tokenValue': serializer.toJson<String>(tokenValue),
    };
  }

  ThemeTokenRow copyWith({
    String? datasetId,
    int? generation,
    String? tokenKey,
    String? tokenValue,
  }) => ThemeTokenRow(
    datasetId: datasetId ?? this.datasetId,
    generation: generation ?? this.generation,
    tokenKey: tokenKey ?? this.tokenKey,
    tokenValue: tokenValue ?? this.tokenValue,
  );
  ThemeTokenRow copyWithCompanion(ThemeTokensCompanion data) {
    return ThemeTokenRow(
      datasetId: data.datasetId.present ? data.datasetId.value : this.datasetId,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      tokenKey: data.tokenKey.present ? data.tokenKey.value : this.tokenKey,
      tokenValue: data.tokenValue.present
          ? data.tokenValue.value
          : this.tokenValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeTokenRow(')
          ..write('datasetId: $datasetId, ')
          ..write('generation: $generation, ')
          ..write('tokenKey: $tokenKey, ')
          ..write('tokenValue: $tokenValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(datasetId, generation, tokenKey, tokenValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeTokenRow &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.tokenKey == this.tokenKey &&
          other.tokenValue == this.tokenValue);
}

class ThemeTokensCompanion extends UpdateCompanion<ThemeTokenRow> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> tokenKey;
  final Value<String> tokenValue;
  final Value<int> rowid;
  const ThemeTokensCompanion({
    this.datasetId = const Value.absent(),
    this.generation = const Value.absent(),
    this.tokenKey = const Value.absent(),
    this.tokenValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThemeTokensCompanion.insert({
    required String datasetId,
    required int generation,
    required String tokenKey,
    required String tokenValue,
    this.rowid = const Value.absent(),
  }) : datasetId = Value(datasetId),
       generation = Value(generation),
       tokenKey = Value(tokenKey),
       tokenValue = Value(tokenValue);
  static Insertable<ThemeTokenRow> custom({
    Expression<String>? datasetId,
    Expression<int>? generation,
    Expression<String>? tokenKey,
    Expression<String>? tokenValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (datasetId != null) 'dataset_id': datasetId,
      if (generation != null) 'generation': generation,
      if (tokenKey != null) 'token_key': tokenKey,
      if (tokenValue != null) 'token_value': tokenValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThemeTokensCompanion copyWith({
    Value<String>? datasetId,
    Value<int>? generation,
    Value<String>? tokenKey,
    Value<String>? tokenValue,
    Value<int>? rowid,
  }) {
    return ThemeTokensCompanion(
      datasetId: datasetId ?? this.datasetId,
      generation: generation ?? this.generation,
      tokenKey: tokenKey ?? this.tokenKey,
      tokenValue: tokenValue ?? this.tokenValue,
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
    if (tokenKey.present) {
      map['token_key'] = Variable<String>(tokenKey.value);
    }
    if (tokenValue.present) {
      map['token_value'] = Variable<String>(tokenValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemeTokensCompanion(')
          ..write('datasetId: $datasetId, ')
          ..write('generation: $generation, ')
          ..write('tokenKey: $tokenKey, ')
          ..write('tokenValue: $tokenValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThemeOverridesTable extends ThemeOverrides
    with TableInfo<$ThemeOverridesTable, ThemeOverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeUidMeta = const VerificationMeta(
    'scopeUid',
  );
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
    'scope_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenKeyMeta = const VerificationMeta(
    'tokenKey',
  );
  @override
  late final GeneratedColumn<String> tokenKey = GeneratedColumn<String>(
    'token_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originKindMeta = const VerificationMeta(
    'originKind',
  );
  @override
  late final GeneratedColumn<String> originKind = GeneratedColumn<String>(
    'origin_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originThemeIdMeta = const VerificationMeta(
    'originThemeId',
  );
  @override
  late final GeneratedColumn<String> originThemeId = GeneratedColumn<String>(
    'origin_theme_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originThemeVersionMeta =
      const VerificationMeta('originThemeVersion');
  @override
  late final GeneratedColumn<String> originThemeVersion =
      GeneratedColumn<String>(
        'origin_theme_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    scopeUid,
    tokenKey,
    value,
    originKind,
    originThemeId,
    originThemeVersion,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_theme_override';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThemeOverrideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_uid')) {
      context.handle(
        _scopeUidMeta,
        scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('token_key')) {
      context.handle(
        _tokenKeyMeta,
        tokenKey.isAcceptableOrUnknown(data['token_key']!, _tokenKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('origin_kind')) {
      context.handle(
        _originKindMeta,
        originKind.isAcceptableOrUnknown(data['origin_kind']!, _originKindMeta),
      );
    } else if (isInserting) {
      context.missing(_originKindMeta);
    }
    if (data.containsKey('origin_theme_id')) {
      context.handle(
        _originThemeIdMeta,
        originThemeId.isAcceptableOrUnknown(
          data['origin_theme_id']!,
          _originThemeIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_theme_version')) {
      context.handle(
        _originThemeVersionMeta,
        originThemeVersion.isAcceptableOrUnknown(
          data['origin_theme_version']!,
          _originThemeVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeUid, tokenKey};
  @override
  ThemeOverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeOverrideRow(
      scopeUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_uid'],
      )!,
      tokenKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      originKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_kind'],
      )!,
      originThemeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_theme_id'],
      ),
      originThemeVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_theme_version'],
      ),
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ThemeOverridesTable createAlias(String alias) {
    return $ThemeOverridesTable(attachedDatabase, alias);
  }
}

class ThemeOverrideRow extends DataClass
    implements Insertable<ThemeOverrideRow> {
  /// 账号作用域。与内存版 scopeUid 对齐；多账号隔离。
  final String scopeUid;

  /// 扁平 token key。
  final String tokenKey;

  /// 覆盖值，JSON 文本编码（标量或 List，不得为 Map）。
  final String value;

  /// 覆盖来源类型：'manual' 或 'package'（照 OverrideOrigin.kind）。
  final String originKind;

  /// 取值来源主题包 id；manual 时为 null（照 OverrideOrigin.sourceThemeId）。
  final String? originThemeId;

  /// 取值时该主题包版本；manual 时为 null（照 OverrideOrigin.sourceThemeVersion）。
  final String? originThemeVersion;

  /// 写入时刻（UTC）。
  final DateTime updatedAtUtc;
  const ThemeOverrideRow({
    required this.scopeUid,
    required this.tokenKey,
    required this.value,
    required this.originKind,
    this.originThemeId,
    this.originThemeVersion,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_uid'] = Variable<String>(scopeUid);
    map['token_key'] = Variable<String>(tokenKey);
    map['value'] = Variable<String>(value);
    map['origin_kind'] = Variable<String>(originKind);
    if (!nullToAbsent || originThemeId != null) {
      map['origin_theme_id'] = Variable<String>(originThemeId);
    }
    if (!nullToAbsent || originThemeVersion != null) {
      map['origin_theme_version'] = Variable<String>(originThemeVersion);
    }
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  ThemeOverridesCompanion toCompanion(bool nullToAbsent) {
    return ThemeOverridesCompanion(
      scopeUid: Value(scopeUid),
      tokenKey: Value(tokenKey),
      value: Value(value),
      originKind: Value(originKind),
      originThemeId: originThemeId == null && nullToAbsent
          ? const Value.absent()
          : Value(originThemeId),
      originThemeVersion: originThemeVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(originThemeVersion),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ThemeOverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeOverrideRow(
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      tokenKey: serializer.fromJson<String>(json['tokenKey']),
      value: serializer.fromJson<String>(json['value']),
      originKind: serializer.fromJson<String>(json['originKind']),
      originThemeId: serializer.fromJson<String?>(json['originThemeId']),
      originThemeVersion: serializer.fromJson<String?>(
        json['originThemeVersion'],
      ),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeUid': serializer.toJson<String>(scopeUid),
      'tokenKey': serializer.toJson<String>(tokenKey),
      'value': serializer.toJson<String>(value),
      'originKind': serializer.toJson<String>(originKind),
      'originThemeId': serializer.toJson<String?>(originThemeId),
      'originThemeVersion': serializer.toJson<String?>(originThemeVersion),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  ThemeOverrideRow copyWith({
    String? scopeUid,
    String? tokenKey,
    String? value,
    String? originKind,
    Value<String?> originThemeId = const Value.absent(),
    Value<String?> originThemeVersion = const Value.absent(),
    DateTime? updatedAtUtc,
  }) => ThemeOverrideRow(
    scopeUid: scopeUid ?? this.scopeUid,
    tokenKey: tokenKey ?? this.tokenKey,
    value: value ?? this.value,
    originKind: originKind ?? this.originKind,
    originThemeId: originThemeId.present
        ? originThemeId.value
        : this.originThemeId,
    originThemeVersion: originThemeVersion.present
        ? originThemeVersion.value
        : this.originThemeVersion,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ThemeOverrideRow copyWithCompanion(ThemeOverridesCompanion data) {
    return ThemeOverrideRow(
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      tokenKey: data.tokenKey.present ? data.tokenKey.value : this.tokenKey,
      value: data.value.present ? data.value.value : this.value,
      originKind: data.originKind.present
          ? data.originKind.value
          : this.originKind,
      originThemeId: data.originThemeId.present
          ? data.originThemeId.value
          : this.originThemeId,
      originThemeVersion: data.originThemeVersion.present
          ? data.originThemeVersion.value
          : this.originThemeVersion,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeOverrideRow(')
          ..write('scopeUid: $scopeUid, ')
          ..write('tokenKey: $tokenKey, ')
          ..write('value: $value, ')
          ..write('originKind: $originKind, ')
          ..write('originThemeId: $originThemeId, ')
          ..write('originThemeVersion: $originThemeVersion, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    scopeUid,
    tokenKey,
    value,
    originKind,
    originThemeId,
    originThemeVersion,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeOverrideRow &&
          other.scopeUid == this.scopeUid &&
          other.tokenKey == this.tokenKey &&
          other.value == this.value &&
          other.originKind == this.originKind &&
          other.originThemeId == this.originThemeId &&
          other.originThemeVersion == this.originThemeVersion &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ThemeOverridesCompanion extends UpdateCompanion<ThemeOverrideRow> {
  final Value<String> scopeUid;
  final Value<String> tokenKey;
  final Value<String> value;
  final Value<String> originKind;
  final Value<String?> originThemeId;
  final Value<String?> originThemeVersion;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const ThemeOverridesCompanion({
    this.scopeUid = const Value.absent(),
    this.tokenKey = const Value.absent(),
    this.value = const Value.absent(),
    this.originKind = const Value.absent(),
    this.originThemeId = const Value.absent(),
    this.originThemeVersion = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThemeOverridesCompanion.insert({
    required String scopeUid,
    required String tokenKey,
    required String value,
    required String originKind,
    this.originThemeId = const Value.absent(),
    this.originThemeVersion = const Value.absent(),
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : scopeUid = Value(scopeUid),
       tokenKey = Value(tokenKey),
       value = Value(value),
       originKind = Value(originKind),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ThemeOverrideRow> custom({
    Expression<String>? scopeUid,
    Expression<String>? tokenKey,
    Expression<String>? value,
    Expression<String>? originKind,
    Expression<String>? originThemeId,
    Expression<String>? originThemeVersion,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (tokenKey != null) 'token_key': tokenKey,
      if (value != null) 'value': value,
      if (originKind != null) 'origin_kind': originKind,
      if (originThemeId != null) 'origin_theme_id': originThemeId,
      if (originThemeVersion != null)
        'origin_theme_version': originThemeVersion,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThemeOverridesCompanion copyWith({
    Value<String>? scopeUid,
    Value<String>? tokenKey,
    Value<String>? value,
    Value<String>? originKind,
    Value<String?>? originThemeId,
    Value<String?>? originThemeVersion,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return ThemeOverridesCompanion(
      scopeUid: scopeUid ?? this.scopeUid,
      tokenKey: tokenKey ?? this.tokenKey,
      value: value ?? this.value,
      originKind: originKind ?? this.originKind,
      originThemeId: originThemeId ?? this.originThemeId,
      originThemeVersion: originThemeVersion ?? this.originThemeVersion,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (tokenKey.present) {
      map['token_key'] = Variable<String>(tokenKey.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (originKind.present) {
      map['origin_kind'] = Variable<String>(originKind.value);
    }
    if (originThemeId.present) {
      map['origin_theme_id'] = Variable<String>(originThemeId.value);
    }
    if (originThemeVersion.present) {
      map['origin_theme_version'] = Variable<String>(originThemeVersion.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemeOverridesCompanion(')
          ..write('scopeUid: $scopeUid, ')
          ..write('tokenKey: $tokenKey, ')
          ..write('value: $value, ')
          ..write('originKind: $originKind, ')
          ..write('originThemeId: $originThemeId, ')
          ..write('originThemeVersion: $originThemeVersion, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThemeSelectionsTable extends ThemeSelections
    with TableInfo<$ThemeSelectionsTable, ThemeSelectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeSelectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeUidMeta = const VerificationMeta(
    'scopeUid',
  );
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
    'scope_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedThemeIdMeta = const VerificationMeta(
    'selectedThemeId',
  );
  @override
  late final GeneratedColumn<String> selectedThemeId = GeneratedColumn<String>(
    'selected_theme_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [scopeUid, selectedThemeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_theme_selection';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThemeSelectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_uid')) {
      context.handle(
        _scopeUidMeta,
        scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('selected_theme_id')) {
      context.handle(
        _selectedThemeIdMeta,
        selectedThemeId.isAcceptableOrUnknown(
          data['selected_theme_id']!,
          _selectedThemeIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeUid};
  @override
  ThemeSelectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeSelectionRow(
      scopeUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_uid'],
      )!,
      selectedThemeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_theme_id'],
      ),
    );
  }

  @override
  $ThemeSelectionsTable createAlias(String alias) {
    return $ThemeSelectionsTable(attachedDatabase, alias);
  }
}

class ThemeSelectionRow extends DataClass
    implements Insertable<ThemeSelectionRow> {
  /// 账号作用域。
  final String scopeUid;

  /// 用户显式选择的主题 id；null = 跟随官方默认。
  final String? selectedThemeId;
  const ThemeSelectionRow({required this.scopeUid, this.selectedThemeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_uid'] = Variable<String>(scopeUid);
    if (!nullToAbsent || selectedThemeId != null) {
      map['selected_theme_id'] = Variable<String>(selectedThemeId);
    }
    return map;
  }

  ThemeSelectionsCompanion toCompanion(bool nullToAbsent) {
    return ThemeSelectionsCompanion(
      scopeUid: Value(scopeUid),
      selectedThemeId: selectedThemeId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedThemeId),
    );
  }

  factory ThemeSelectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeSelectionRow(
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      selectedThemeId: serializer.fromJson<String?>(json['selectedThemeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeUid': serializer.toJson<String>(scopeUid),
      'selectedThemeId': serializer.toJson<String?>(selectedThemeId),
    };
  }

  ThemeSelectionRow copyWith({
    String? scopeUid,
    Value<String?> selectedThemeId = const Value.absent(),
  }) => ThemeSelectionRow(
    scopeUid: scopeUid ?? this.scopeUid,
    selectedThemeId: selectedThemeId.present
        ? selectedThemeId.value
        : this.selectedThemeId,
  );
  ThemeSelectionRow copyWithCompanion(ThemeSelectionsCompanion data) {
    return ThemeSelectionRow(
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      selectedThemeId: data.selectedThemeId.present
          ? data.selectedThemeId.value
          : this.selectedThemeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeSelectionRow(')
          ..write('scopeUid: $scopeUid, ')
          ..write('selectedThemeId: $selectedThemeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scopeUid, selectedThemeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeSelectionRow &&
          other.scopeUid == this.scopeUid &&
          other.selectedThemeId == this.selectedThemeId);
}

class ThemeSelectionsCompanion extends UpdateCompanion<ThemeSelectionRow> {
  final Value<String> scopeUid;
  final Value<String?> selectedThemeId;
  final Value<int> rowid;
  const ThemeSelectionsCompanion({
    this.scopeUid = const Value.absent(),
    this.selectedThemeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThemeSelectionsCompanion.insert({
    required String scopeUid,
    this.selectedThemeId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scopeUid = Value(scopeUid);
  static Insertable<ThemeSelectionRow> custom({
    Expression<String>? scopeUid,
    Expression<String>? selectedThemeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (selectedThemeId != null) 'selected_theme_id': selectedThemeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThemeSelectionsCompanion copyWith({
    Value<String>? scopeUid,
    Value<String?>? selectedThemeId,
    Value<int>? rowid,
  }) {
    return ThemeSelectionsCompanion(
      scopeUid: scopeUid ?? this.scopeUid,
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (selectedThemeId.present) {
      map['selected_theme_id'] = Variable<String>(selectedThemeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemeSelectionsCompanion(')
          ..write('scopeUid: $scopeUid, ')
          ..write('selectedThemeId: $selectedThemeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThemeDatasetGenerationsTable extends ThemeDatasetGenerations
    with TableInfo<$ThemeDatasetGenerationsTable, ThemeDatasetGenerationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeDatasetGenerationsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 't_theme_dataset_generation';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThemeDatasetGenerationRow> instance, {
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
  ThemeDatasetGenerationRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeDatasetGenerationRow(
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
  $ThemeDatasetGenerationsTable createAlias(String alias) {
    return $ThemeDatasetGenerationsTable(attachedDatabase, alias);
  }
}

class ThemeDatasetGenerationRow extends DataClass
    implements Insertable<ThemeDatasetGenerationRow> {
  final String datasetId;
  final int generation;
  final String payloadSha256;
  final int payloadBytes;
  final int? declaredRowCount;
  final String status;
  final String sourceId;
  final DateTime? installedAtUtc;
  const ThemeDatasetGenerationRow({
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

  ThemeDatasetGenerationsCompanion toCompanion(bool nullToAbsent) {
    return ThemeDatasetGenerationsCompanion(
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

  factory ThemeDatasetGenerationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeDatasetGenerationRow(
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

  ThemeDatasetGenerationRow copyWith({
    String? datasetId,
    int? generation,
    String? payloadSha256,
    int? payloadBytes,
    Value<int?> declaredRowCount = const Value.absent(),
    String? status,
    String? sourceId,
    Value<DateTime?> installedAtUtc = const Value.absent(),
  }) => ThemeDatasetGenerationRow(
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
  ThemeDatasetGenerationRow copyWithCompanion(
    ThemeDatasetGenerationsCompanion data,
  ) {
    return ThemeDatasetGenerationRow(
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
    return (StringBuffer('ThemeDatasetGenerationRow(')
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
      (other is ThemeDatasetGenerationRow &&
          other.datasetId == this.datasetId &&
          other.generation == this.generation &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadBytes == this.payloadBytes &&
          other.declaredRowCount == this.declaredRowCount &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.installedAtUtc == this.installedAtUtc);
}

class ThemeDatasetGenerationsCompanion
    extends UpdateCompanion<ThemeDatasetGenerationRow> {
  final Value<String> datasetId;
  final Value<int> generation;
  final Value<String> payloadSha256;
  final Value<int> payloadBytes;
  final Value<int?> declaredRowCount;
  final Value<String> status;
  final Value<String> sourceId;
  final Value<DateTime?> installedAtUtc;
  final Value<int> rowid;
  const ThemeDatasetGenerationsCompanion({
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
  ThemeDatasetGenerationsCompanion.insert({
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
  static Insertable<ThemeDatasetGenerationRow> custom({
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

  ThemeDatasetGenerationsCompanion copyWith({
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
    return ThemeDatasetGenerationsCompanion(
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
    return (StringBuffer('ThemeDatasetGenerationsCompanion(')
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

abstract class _$ThemeDatabase extends GeneratedDatabase {
  _$ThemeDatabase(QueryExecutor e) : super(e);
  $ThemeDatabaseManager get managers => $ThemeDatabaseManager(this);
  late final $ThemeTokensTable themeTokens = $ThemeTokensTable(this);
  late final $ThemeOverridesTable themeOverrides = $ThemeOverridesTable(this);
  late final $ThemeSelectionsTable themeSelections = $ThemeSelectionsTable(
    this,
  );
  late final $ThemeDatasetGenerationsTable themeDatasetGenerations =
      $ThemeDatasetGenerationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    themeTokens,
    themeOverrides,
    themeSelections,
    themeDatasetGenerations,
  ];
}

typedef $$ThemeTokensTableCreateCompanionBuilder =
    ThemeTokensCompanion Function({
      required String datasetId,
      required int generation,
      required String tokenKey,
      required String tokenValue,
      Value<int> rowid,
    });
typedef $$ThemeTokensTableUpdateCompanionBuilder =
    ThemeTokensCompanion Function({
      Value<String> datasetId,
      Value<int> generation,
      Value<String> tokenKey,
      Value<String> tokenValue,
      Value<int> rowid,
    });

class $$ThemeTokensTableFilterComposer
    extends Composer<_$ThemeDatabase, $ThemeTokensTable> {
  $$ThemeTokensTableFilterComposer({
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

  ColumnFilters<String> get tokenKey => $composableBuilder(
    column: $table.tokenKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenValue => $composableBuilder(
    column: $table.tokenValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThemeTokensTableOrderingComposer
    extends Composer<_$ThemeDatabase, $ThemeTokensTable> {
  $$ThemeTokensTableOrderingComposer({
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

  ColumnOrderings<String> get tokenKey => $composableBuilder(
    column: $table.tokenKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenValue => $composableBuilder(
    column: $table.tokenValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThemeTokensTableAnnotationComposer
    extends Composer<_$ThemeDatabase, $ThemeTokensTable> {
  $$ThemeTokensTableAnnotationComposer({
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

  GeneratedColumn<String> get tokenKey =>
      $composableBuilder(column: $table.tokenKey, builder: (column) => column);

  GeneratedColumn<String> get tokenValue => $composableBuilder(
    column: $table.tokenValue,
    builder: (column) => column,
  );
}

class $$ThemeTokensTableTableManager
    extends
        RootTableManager<
          _$ThemeDatabase,
          $ThemeTokensTable,
          ThemeTokenRow,
          $$ThemeTokensTableFilterComposer,
          $$ThemeTokensTableOrderingComposer,
          $$ThemeTokensTableAnnotationComposer,
          $$ThemeTokensTableCreateCompanionBuilder,
          $$ThemeTokensTableUpdateCompanionBuilder,
          (
            ThemeTokenRow,
            BaseReferences<_$ThemeDatabase, $ThemeTokensTable, ThemeTokenRow>,
          ),
          ThemeTokenRow,
          PrefetchHooks Function()
        > {
  $$ThemeTokensTableTableManager(_$ThemeDatabase db, $ThemeTokensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemeTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemeTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> datasetId = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<String> tokenKey = const Value.absent(),
                Value<String> tokenValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThemeTokensCompanion(
                datasetId: datasetId,
                generation: generation,
                tokenKey: tokenKey,
                tokenValue: tokenValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String datasetId,
                required int generation,
                required String tokenKey,
                required String tokenValue,
                Value<int> rowid = const Value.absent(),
              }) => ThemeTokensCompanion.insert(
                datasetId: datasetId,
                generation: generation,
                tokenKey: tokenKey,
                tokenValue: tokenValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThemeTokensTableProcessedTableManager =
    ProcessedTableManager<
      _$ThemeDatabase,
      $ThemeTokensTable,
      ThemeTokenRow,
      $$ThemeTokensTableFilterComposer,
      $$ThemeTokensTableOrderingComposer,
      $$ThemeTokensTableAnnotationComposer,
      $$ThemeTokensTableCreateCompanionBuilder,
      $$ThemeTokensTableUpdateCompanionBuilder,
      (
        ThemeTokenRow,
        BaseReferences<_$ThemeDatabase, $ThemeTokensTable, ThemeTokenRow>,
      ),
      ThemeTokenRow,
      PrefetchHooks Function()
    >;
typedef $$ThemeOverridesTableCreateCompanionBuilder =
    ThemeOverridesCompanion Function({
      required String scopeUid,
      required String tokenKey,
      required String value,
      required String originKind,
      Value<String?> originThemeId,
      Value<String?> originThemeVersion,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$ThemeOverridesTableUpdateCompanionBuilder =
    ThemeOverridesCompanion Function({
      Value<String> scopeUid,
      Value<String> tokenKey,
      Value<String> value,
      Value<String> originKind,
      Value<String?> originThemeId,
      Value<String?> originThemeVersion,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

class $$ThemeOverridesTableFilterComposer
    extends Composer<_$ThemeDatabase, $ThemeOverridesTable> {
  $$ThemeOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeUid => $composableBuilder(
    column: $table.scopeUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenKey => $composableBuilder(
    column: $table.tokenKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originKind => $composableBuilder(
    column: $table.originKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originThemeId => $composableBuilder(
    column: $table.originThemeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originThemeVersion => $composableBuilder(
    column: $table.originThemeVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThemeOverridesTableOrderingComposer
    extends Composer<_$ThemeDatabase, $ThemeOverridesTable> {
  $$ThemeOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeUid => $composableBuilder(
    column: $table.scopeUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenKey => $composableBuilder(
    column: $table.tokenKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originKind => $composableBuilder(
    column: $table.originKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originThemeId => $composableBuilder(
    column: $table.originThemeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originThemeVersion => $composableBuilder(
    column: $table.originThemeVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThemeOverridesTableAnnotationComposer
    extends Composer<_$ThemeDatabase, $ThemeOverridesTable> {
  $$ThemeOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<String> get tokenKey =>
      $composableBuilder(column: $table.tokenKey, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get originKind => $composableBuilder(
    column: $table.originKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originThemeId => $composableBuilder(
    column: $table.originThemeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originThemeVersion => $composableBuilder(
    column: $table.originThemeVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$ThemeOverridesTableTableManager
    extends
        RootTableManager<
          _$ThemeDatabase,
          $ThemeOverridesTable,
          ThemeOverrideRow,
          $$ThemeOverridesTableFilterComposer,
          $$ThemeOverridesTableOrderingComposer,
          $$ThemeOverridesTableAnnotationComposer,
          $$ThemeOverridesTableCreateCompanionBuilder,
          $$ThemeOverridesTableUpdateCompanionBuilder,
          (
            ThemeOverrideRow,
            BaseReferences<
              _$ThemeDatabase,
              $ThemeOverridesTable,
              ThemeOverrideRow
            >,
          ),
          ThemeOverrideRow,
          PrefetchHooks Function()
        > {
  $$ThemeOverridesTableTableManager(
    _$ThemeDatabase db,
    $ThemeOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemeOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemeOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scopeUid = const Value.absent(),
                Value<String> tokenKey = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> originKind = const Value.absent(),
                Value<String?> originThemeId = const Value.absent(),
                Value<String?> originThemeVersion = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThemeOverridesCompanion(
                scopeUid: scopeUid,
                tokenKey: tokenKey,
                value: value,
                originKind: originKind,
                originThemeId: originThemeId,
                originThemeVersion: originThemeVersion,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scopeUid,
                required String tokenKey,
                required String value,
                required String originKind,
                Value<String?> originThemeId = const Value.absent(),
                Value<String?> originThemeVersion = const Value.absent(),
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => ThemeOverridesCompanion.insert(
                scopeUid: scopeUid,
                tokenKey: tokenKey,
                value: value,
                originKind: originKind,
                originThemeId: originThemeId,
                originThemeVersion: originThemeVersion,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThemeOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$ThemeDatabase,
      $ThemeOverridesTable,
      ThemeOverrideRow,
      $$ThemeOverridesTableFilterComposer,
      $$ThemeOverridesTableOrderingComposer,
      $$ThemeOverridesTableAnnotationComposer,
      $$ThemeOverridesTableCreateCompanionBuilder,
      $$ThemeOverridesTableUpdateCompanionBuilder,
      (
        ThemeOverrideRow,
        BaseReferences<_$ThemeDatabase, $ThemeOverridesTable, ThemeOverrideRow>,
      ),
      ThemeOverrideRow,
      PrefetchHooks Function()
    >;
typedef $$ThemeSelectionsTableCreateCompanionBuilder =
    ThemeSelectionsCompanion Function({
      required String scopeUid,
      Value<String?> selectedThemeId,
      Value<int> rowid,
    });
typedef $$ThemeSelectionsTableUpdateCompanionBuilder =
    ThemeSelectionsCompanion Function({
      Value<String> scopeUid,
      Value<String?> selectedThemeId,
      Value<int> rowid,
    });

class $$ThemeSelectionsTableFilterComposer
    extends Composer<_$ThemeDatabase, $ThemeSelectionsTable> {
  $$ThemeSelectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeUid => $composableBuilder(
    column: $table.scopeUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedThemeId => $composableBuilder(
    column: $table.selectedThemeId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThemeSelectionsTableOrderingComposer
    extends Composer<_$ThemeDatabase, $ThemeSelectionsTable> {
  $$ThemeSelectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeUid => $composableBuilder(
    column: $table.scopeUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedThemeId => $composableBuilder(
    column: $table.selectedThemeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThemeSelectionsTableAnnotationComposer
    extends Composer<_$ThemeDatabase, $ThemeSelectionsTable> {
  $$ThemeSelectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<String> get selectedThemeId => $composableBuilder(
    column: $table.selectedThemeId,
    builder: (column) => column,
  );
}

class $$ThemeSelectionsTableTableManager
    extends
        RootTableManager<
          _$ThemeDatabase,
          $ThemeSelectionsTable,
          ThemeSelectionRow,
          $$ThemeSelectionsTableFilterComposer,
          $$ThemeSelectionsTableOrderingComposer,
          $$ThemeSelectionsTableAnnotationComposer,
          $$ThemeSelectionsTableCreateCompanionBuilder,
          $$ThemeSelectionsTableUpdateCompanionBuilder,
          (
            ThemeSelectionRow,
            BaseReferences<
              _$ThemeDatabase,
              $ThemeSelectionsTable,
              ThemeSelectionRow
            >,
          ),
          ThemeSelectionRow,
          PrefetchHooks Function()
        > {
  $$ThemeSelectionsTableTableManager(
    _$ThemeDatabase db,
    $ThemeSelectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeSelectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemeSelectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemeSelectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scopeUid = const Value.absent(),
                Value<String?> selectedThemeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThemeSelectionsCompanion(
                scopeUid: scopeUid,
                selectedThemeId: selectedThemeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scopeUid,
                Value<String?> selectedThemeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThemeSelectionsCompanion.insert(
                scopeUid: scopeUid,
                selectedThemeId: selectedThemeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThemeSelectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ThemeDatabase,
      $ThemeSelectionsTable,
      ThemeSelectionRow,
      $$ThemeSelectionsTableFilterComposer,
      $$ThemeSelectionsTableOrderingComposer,
      $$ThemeSelectionsTableAnnotationComposer,
      $$ThemeSelectionsTableCreateCompanionBuilder,
      $$ThemeSelectionsTableUpdateCompanionBuilder,
      (
        ThemeSelectionRow,
        BaseReferences<
          _$ThemeDatabase,
          $ThemeSelectionsTable,
          ThemeSelectionRow
        >,
      ),
      ThemeSelectionRow,
      PrefetchHooks Function()
    >;
typedef $$ThemeDatasetGenerationsTableCreateCompanionBuilder =
    ThemeDatasetGenerationsCompanion Function({
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
typedef $$ThemeDatasetGenerationsTableUpdateCompanionBuilder =
    ThemeDatasetGenerationsCompanion Function({
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

class $$ThemeDatasetGenerationsTableFilterComposer
    extends Composer<_$ThemeDatabase, $ThemeDatasetGenerationsTable> {
  $$ThemeDatasetGenerationsTableFilterComposer({
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

class $$ThemeDatasetGenerationsTableOrderingComposer
    extends Composer<_$ThemeDatabase, $ThemeDatasetGenerationsTable> {
  $$ThemeDatasetGenerationsTableOrderingComposer({
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

class $$ThemeDatasetGenerationsTableAnnotationComposer
    extends Composer<_$ThemeDatabase, $ThemeDatasetGenerationsTable> {
  $$ThemeDatasetGenerationsTableAnnotationComposer({
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

class $$ThemeDatasetGenerationsTableTableManager
    extends
        RootTableManager<
          _$ThemeDatabase,
          $ThemeDatasetGenerationsTable,
          ThemeDatasetGenerationRow,
          $$ThemeDatasetGenerationsTableFilterComposer,
          $$ThemeDatasetGenerationsTableOrderingComposer,
          $$ThemeDatasetGenerationsTableAnnotationComposer,
          $$ThemeDatasetGenerationsTableCreateCompanionBuilder,
          $$ThemeDatasetGenerationsTableUpdateCompanionBuilder,
          (
            ThemeDatasetGenerationRow,
            BaseReferences<
              _$ThemeDatabase,
              $ThemeDatasetGenerationsTable,
              ThemeDatasetGenerationRow
            >,
          ),
          ThemeDatasetGenerationRow,
          PrefetchHooks Function()
        > {
  $$ThemeDatasetGenerationsTableTableManager(
    _$ThemeDatabase db,
    $ThemeDatasetGenerationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeDatasetGenerationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ThemeDatasetGenerationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ThemeDatasetGenerationsTableAnnotationComposer(
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
              }) => ThemeDatasetGenerationsCompanion(
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
              }) => ThemeDatasetGenerationsCompanion.insert(
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

typedef $$ThemeDatasetGenerationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ThemeDatabase,
      $ThemeDatasetGenerationsTable,
      ThemeDatasetGenerationRow,
      $$ThemeDatasetGenerationsTableFilterComposer,
      $$ThemeDatasetGenerationsTableOrderingComposer,
      $$ThemeDatasetGenerationsTableAnnotationComposer,
      $$ThemeDatasetGenerationsTableCreateCompanionBuilder,
      $$ThemeDatasetGenerationsTableUpdateCompanionBuilder,
      (
        ThemeDatasetGenerationRow,
        BaseReferences<
          _$ThemeDatabase,
          $ThemeDatasetGenerationsTable,
          ThemeDatasetGenerationRow
        >,
      ),
      ThemeDatasetGenerationRow,
      PrefetchHooks Function()
    >;

class $ThemeDatabaseManager {
  final _$ThemeDatabase _db;
  $ThemeDatabaseManager(this._db);
  $$ThemeTokensTableTableManager get themeTokens =>
      $$ThemeTokensTableTableManager(_db, _db.themeTokens);
  $$ThemeOverridesTableTableManager get themeOverrides =>
      $$ThemeOverridesTableTableManager(_db, _db.themeOverrides);
  $$ThemeSelectionsTableTableManager get themeSelections =>
      $$ThemeSelectionsTableTableManager(_db, _db.themeSelections);
  $$ThemeDatasetGenerationsTableTableManager get themeDatasetGenerations =>
      $$ThemeDatasetGenerationsTableTableManager(
        _db,
        _db.themeDatasetGenerations,
      );
}
