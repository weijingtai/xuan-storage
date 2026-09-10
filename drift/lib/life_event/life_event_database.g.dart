// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_event_database.dart';

// ignore_for_file: type=lint
class $LifeEventSubjectsTable extends LifeEventSubjects
    with TableInfo<$LifeEventSubjectsTable, LifeEventSubjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayLabelMeta = const VerificationMeta(
    'displayLabel',
  );
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
    'display_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [subjectId, ownerScopeId, displayLabel];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventSubjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('display_label')) {
      context.handle(
        _displayLabelMeta,
        displayLabel.isAcceptableOrUnknown(
          data['display_label']!,
          _displayLabelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {subjectId};
  @override
  LifeEventSubjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventSubjectRow(
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      displayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_label'],
      ),
    );
  }

  @override
  $LifeEventSubjectsTable createAlias(String alias) {
    return $LifeEventSubjectsTable(attachedDatabase, alias);
  }
}

class LifeEventSubjectRow extends DataClass
    implements Insertable<LifeEventSubjectRow> {
  final String subjectId;
  final String ownerScopeId;
  final String? displayLabel;
  const LifeEventSubjectRow({
    required this.subjectId,
    required this.ownerScopeId,
    this.displayLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['subject_id'] = Variable<String>(subjectId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    if (!nullToAbsent || displayLabel != null) {
      map['display_label'] = Variable<String>(displayLabel);
    }
    return map;
  }

  LifeEventSubjectsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventSubjectsCompanion(
      subjectId: Value(subjectId),
      ownerScopeId: Value(ownerScopeId),
      displayLabel: displayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(displayLabel),
    );
  }

  factory LifeEventSubjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventSubjectRow(
      subjectId: serializer.fromJson<String>(json['subjectId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      displayLabel: serializer.fromJson<String?>(json['displayLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'subjectId': serializer.toJson<String>(subjectId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'displayLabel': serializer.toJson<String?>(displayLabel),
    };
  }

  LifeEventSubjectRow copyWith({
    String? subjectId,
    String? ownerScopeId,
    Value<String?> displayLabel = const Value.absent(),
  }) => LifeEventSubjectRow(
    subjectId: subjectId ?? this.subjectId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    displayLabel: displayLabel.present ? displayLabel.value : this.displayLabel,
  );
  LifeEventSubjectRow copyWithCompanion(LifeEventSubjectsCompanion data) {
    return LifeEventSubjectRow(
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventSubjectRow(')
          ..write('subjectId: $subjectId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('displayLabel: $displayLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(subjectId, ownerScopeId, displayLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventSubjectRow &&
          other.subjectId == this.subjectId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.displayLabel == this.displayLabel);
}

class LifeEventSubjectsCompanion extends UpdateCompanion<LifeEventSubjectRow> {
  final Value<String> subjectId;
  final Value<String> ownerScopeId;
  final Value<String?> displayLabel;
  final Value<int> rowid;
  const LifeEventSubjectsCompanion({
    this.subjectId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventSubjectsCompanion.insert({
    required String subjectId,
    required String ownerScopeId,
    this.displayLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : subjectId = Value(subjectId),
       ownerScopeId = Value(ownerScopeId);
  static Insertable<LifeEventSubjectRow> custom({
    Expression<String>? subjectId,
    Expression<String>? ownerScopeId,
    Expression<String>? displayLabel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (subjectId != null) 'subject_id': subjectId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (displayLabel != null) 'display_label': displayLabel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventSubjectsCompanion copyWith({
    Value<String>? subjectId,
    Value<String>? ownerScopeId,
    Value<String?>? displayLabel,
    Value<int>? rowid,
  }) {
    return LifeEventSubjectsCompanion(
      subjectId: subjectId ?? this.subjectId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      displayLabel: displayLabel ?? this.displayLabel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventSubjectsCompanion(')
          ..write('subjectId: $subjectId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventLifeProfilesTable extends LifeEventLifeProfiles
    with TableInfo<$LifeEventLifeProfilesTable, LifeEventLifeProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventLifeProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayLabelMeta = const VerificationMeta(
    'displayLabel',
  );
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
    'display_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    ownerScopeId,
    subjectId,
    displayLabel,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_life_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventLifeProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('display_label')) {
      context.handle(
        _displayLabelMeta,
        displayLabel.isAcceptableOrUnknown(
          data['display_label']!,
          _displayLabelMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  LifeEventLifeProfileRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventLifeProfileRow(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      displayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_label'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $LifeEventLifeProfilesTable createAlias(String alias) {
    return $LifeEventLifeProfilesTable(attachedDatabase, alias);
  }
}

class LifeEventLifeProfileRow extends DataClass
    implements Insertable<LifeEventLifeProfileRow> {
  final String profileId;
  final String ownerScopeId;
  final String subjectId;
  final String? displayLabel;
  final int revision;
  const LifeEventLifeProfileRow({
    required this.profileId,
    required this.ownerScopeId,
    required this.subjectId,
    this.displayLabel,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    map['subject_id'] = Variable<String>(subjectId);
    if (!nullToAbsent || displayLabel != null) {
      map['display_label'] = Variable<String>(displayLabel);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  LifeEventLifeProfilesCompanion toCompanion(bool nullToAbsent) {
    return LifeEventLifeProfilesCompanion(
      profileId: Value(profileId),
      ownerScopeId: Value(ownerScopeId),
      subjectId: Value(subjectId),
      displayLabel: displayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(displayLabel),
      revision: Value(revision),
    );
  }

  factory LifeEventLifeProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventLifeProfileRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      displayLabel: serializer.fromJson<String?>(json['displayLabel']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'subjectId': serializer.toJson<String>(subjectId),
      'displayLabel': serializer.toJson<String?>(displayLabel),
      'revision': serializer.toJson<int>(revision),
    };
  }

  LifeEventLifeProfileRow copyWith({
    String? profileId,
    String? ownerScopeId,
    String? subjectId,
    Value<String?> displayLabel = const Value.absent(),
    int? revision,
  }) => LifeEventLifeProfileRow(
    profileId: profileId ?? this.profileId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    subjectId: subjectId ?? this.subjectId,
    displayLabel: displayLabel.present ? displayLabel.value : this.displayLabel,
    revision: revision ?? this.revision,
  );
  LifeEventLifeProfileRow copyWithCompanion(
    LifeEventLifeProfilesCompanion data,
  ) {
    return LifeEventLifeProfileRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventLifeProfileRow(')
          ..write('profileId: $profileId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('subjectId: $subjectId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileId, ownerScopeId, subjectId, displayLabel, revision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventLifeProfileRow &&
          other.profileId == this.profileId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.subjectId == this.subjectId &&
          other.displayLabel == this.displayLabel &&
          other.revision == this.revision);
}

class LifeEventLifeProfilesCompanion
    extends UpdateCompanion<LifeEventLifeProfileRow> {
  final Value<String> profileId;
  final Value<String> ownerScopeId;
  final Value<String> subjectId;
  final Value<String?> displayLabel;
  final Value<int> revision;
  final Value<int> rowid;
  const LifeEventLifeProfilesCompanion({
    this.profileId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventLifeProfilesCompanion.insert({
    required String profileId,
    required String ownerScopeId,
    required String subjectId,
    this.displayLabel = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       ownerScopeId = Value(ownerScopeId),
       subjectId = Value(subjectId),
       revision = Value(revision);
  static Insertable<LifeEventLifeProfileRow> custom({
    Expression<String>? profileId,
    Expression<String>? ownerScopeId,
    Expression<String>? subjectId,
    Expression<String>? displayLabel,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (subjectId != null) 'subject_id': subjectId,
      if (displayLabel != null) 'display_label': displayLabel,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventLifeProfilesCompanion copyWith({
    Value<String>? profileId,
    Value<String>? ownerScopeId,
    Value<String>? subjectId,
    Value<String?>? displayLabel,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return LifeEventLifeProfilesCompanion(
      profileId: profileId ?? this.profileId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      subjectId: subjectId ?? this.subjectId,
      displayLabel: displayLabel ?? this.displayLabel,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventLifeProfilesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('subjectId: $subjectId, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventChartSnapshotRefsTable extends LifeEventChartSnapshotRefs
    with
        TableInfo<$LifeEventChartSnapshotRefsTable, LifeEventChartSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventChartSnapshotRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chartSnapshotIdMeta = const VerificationMeta(
    'chartSnapshotId',
  );
  @override
  late final GeneratedColumn<String> chartSnapshotId = GeneratedColumn<String>(
    'chart_snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _divinationTypeKeyMeta = const VerificationMeta(
    'divinationTypeKey',
  );
  @override
  late final GeneratedColumn<String> divinationTypeKey =
      GeneratedColumn<String>(
        'divination_type_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _subDivinationTypeKeyMeta =
      const VerificationMeta('subDivinationTypeKey');
  @override
  late final GeneratedColumn<String> subDivinationTypeKey =
      GeneratedColumn<String>(
        'sub_divination_type_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _snapshotRevisionMeta = const VerificationMeta(
    'snapshotRevision',
  );
  @override
  late final GeneratedColumn<String> snapshotRevision = GeneratedColumn<String>(
    'snapshot_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<String> algorithmVersion = GeneratedColumn<String>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputFingerprintMeta = const VerificationMeta(
    'inputFingerprint',
  );
  @override
  late final GeneratedColumn<String> inputFingerprint = GeneratedColumn<String>(
    'input_fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chartSnapshotId,
    profileId,
    providerId,
    divinationTypeKey,
    subDivinationTypeKey,
    snapshotRevision,
    algorithmVersion,
    inputFingerprint,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_chart_snapshot_refs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventChartSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chart_snapshot_id')) {
      context.handle(
        _chartSnapshotIdMeta,
        chartSnapshotId.isAcceptableOrUnknown(
          data['chart_snapshot_id']!,
          _chartSnapshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chartSnapshotIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('divination_type_key')) {
      context.handle(
        _divinationTypeKeyMeta,
        divinationTypeKey.isAcceptableOrUnknown(
          data['divination_type_key']!,
          _divinationTypeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_divinationTypeKeyMeta);
    }
    if (data.containsKey('sub_divination_type_key')) {
      context.handle(
        _subDivinationTypeKeyMeta,
        subDivinationTypeKey.isAcceptableOrUnknown(
          data['sub_divination_type_key']!,
          _subDivinationTypeKeyMeta,
        ),
      );
    }
    if (data.containsKey('snapshot_revision')) {
      context.handle(
        _snapshotRevisionMeta,
        snapshotRevision.isAcceptableOrUnknown(
          data['snapshot_revision']!,
          _snapshotRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotRevisionMeta);
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algorithmVersionMeta);
    }
    if (data.containsKey('input_fingerprint')) {
      context.handle(
        _inputFingerprintMeta,
        inputFingerprint.isAcceptableOrUnknown(
          data['input_fingerprint']!,
          _inputFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputFingerprintMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chartSnapshotId};
  @override
  LifeEventChartSnapshotRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventChartSnapshotRow(
      chartSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chart_snapshot_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      divinationTypeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}divination_type_key'],
      )!,
      subDivinationTypeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_divination_type_key'],
      ),
      snapshotRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_revision'],
      )!,
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm_version'],
      )!,
      inputFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_fingerprint'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $LifeEventChartSnapshotRefsTable createAlias(String alias) {
    return $LifeEventChartSnapshotRefsTable(attachedDatabase, alias);
  }
}

class LifeEventChartSnapshotRow extends DataClass
    implements Insertable<LifeEventChartSnapshotRow> {
  final String chartSnapshotId;
  final String profileId;
  final String providerId;
  final String divinationTypeKey;
  final String? subDivinationTypeKey;
  final String snapshotRevision;
  final String algorithmVersion;
  final String inputFingerprint;
  final int createdAtMs;
  const LifeEventChartSnapshotRow({
    required this.chartSnapshotId,
    required this.profileId,
    required this.providerId,
    required this.divinationTypeKey,
    this.subDivinationTypeKey,
    required this.snapshotRevision,
    required this.algorithmVersion,
    required this.inputFingerprint,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chart_snapshot_id'] = Variable<String>(chartSnapshotId);
    map['profile_id'] = Variable<String>(profileId);
    map['provider_id'] = Variable<String>(providerId);
    map['divination_type_key'] = Variable<String>(divinationTypeKey);
    if (!nullToAbsent || subDivinationTypeKey != null) {
      map['sub_divination_type_key'] = Variable<String>(subDivinationTypeKey);
    }
    map['snapshot_revision'] = Variable<String>(snapshotRevision);
    map['algorithm_version'] = Variable<String>(algorithmVersion);
    map['input_fingerprint'] = Variable<String>(inputFingerprint);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  LifeEventChartSnapshotRefsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventChartSnapshotRefsCompanion(
      chartSnapshotId: Value(chartSnapshotId),
      profileId: Value(profileId),
      providerId: Value(providerId),
      divinationTypeKey: Value(divinationTypeKey),
      subDivinationTypeKey: subDivinationTypeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(subDivinationTypeKey),
      snapshotRevision: Value(snapshotRevision),
      algorithmVersion: Value(algorithmVersion),
      inputFingerprint: Value(inputFingerprint),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory LifeEventChartSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventChartSnapshotRow(
      chartSnapshotId: serializer.fromJson<String>(json['chartSnapshotId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      divinationTypeKey: serializer.fromJson<String>(json['divinationTypeKey']),
      subDivinationTypeKey: serializer.fromJson<String?>(
        json['subDivinationTypeKey'],
      ),
      snapshotRevision: serializer.fromJson<String>(json['snapshotRevision']),
      algorithmVersion: serializer.fromJson<String>(json['algorithmVersion']),
      inputFingerprint: serializer.fromJson<String>(json['inputFingerprint']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chartSnapshotId': serializer.toJson<String>(chartSnapshotId),
      'profileId': serializer.toJson<String>(profileId),
      'providerId': serializer.toJson<String>(providerId),
      'divinationTypeKey': serializer.toJson<String>(divinationTypeKey),
      'subDivinationTypeKey': serializer.toJson<String?>(subDivinationTypeKey),
      'snapshotRevision': serializer.toJson<String>(snapshotRevision),
      'algorithmVersion': serializer.toJson<String>(algorithmVersion),
      'inputFingerprint': serializer.toJson<String>(inputFingerprint),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  LifeEventChartSnapshotRow copyWith({
    String? chartSnapshotId,
    String? profileId,
    String? providerId,
    String? divinationTypeKey,
    Value<String?> subDivinationTypeKey = const Value.absent(),
    String? snapshotRevision,
    String? algorithmVersion,
    String? inputFingerprint,
    int? createdAtMs,
  }) => LifeEventChartSnapshotRow(
    chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
    profileId: profileId ?? this.profileId,
    providerId: providerId ?? this.providerId,
    divinationTypeKey: divinationTypeKey ?? this.divinationTypeKey,
    subDivinationTypeKey: subDivinationTypeKey.present
        ? subDivinationTypeKey.value
        : this.subDivinationTypeKey,
    snapshotRevision: snapshotRevision ?? this.snapshotRevision,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    inputFingerprint: inputFingerprint ?? this.inputFingerprint,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  LifeEventChartSnapshotRow copyWithCompanion(
    LifeEventChartSnapshotRefsCompanion data,
  ) {
    return LifeEventChartSnapshotRow(
      chartSnapshotId: data.chartSnapshotId.present
          ? data.chartSnapshotId.value
          : this.chartSnapshotId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      divinationTypeKey: data.divinationTypeKey.present
          ? data.divinationTypeKey.value
          : this.divinationTypeKey,
      subDivinationTypeKey: data.subDivinationTypeKey.present
          ? data.subDivinationTypeKey.value
          : this.subDivinationTypeKey,
      snapshotRevision: data.snapshotRevision.present
          ? data.snapshotRevision.value
          : this.snapshotRevision,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      inputFingerprint: data.inputFingerprint.present
          ? data.inputFingerprint.value
          : this.inputFingerprint,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventChartSnapshotRow(')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('profileId: $profileId, ')
          ..write('providerId: $providerId, ')
          ..write('divinationTypeKey: $divinationTypeKey, ')
          ..write('subDivinationTypeKey: $subDivinationTypeKey, ')
          ..write('snapshotRevision: $snapshotRevision, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('inputFingerprint: $inputFingerprint, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chartSnapshotId,
    profileId,
    providerId,
    divinationTypeKey,
    subDivinationTypeKey,
    snapshotRevision,
    algorithmVersion,
    inputFingerprint,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventChartSnapshotRow &&
          other.chartSnapshotId == this.chartSnapshotId &&
          other.profileId == this.profileId &&
          other.providerId == this.providerId &&
          other.divinationTypeKey == this.divinationTypeKey &&
          other.subDivinationTypeKey == this.subDivinationTypeKey &&
          other.snapshotRevision == this.snapshotRevision &&
          other.algorithmVersion == this.algorithmVersion &&
          other.inputFingerprint == this.inputFingerprint &&
          other.createdAtMs == this.createdAtMs);
}

class LifeEventChartSnapshotRefsCompanion
    extends UpdateCompanion<LifeEventChartSnapshotRow> {
  final Value<String> chartSnapshotId;
  final Value<String> profileId;
  final Value<String> providerId;
  final Value<String> divinationTypeKey;
  final Value<String?> subDivinationTypeKey;
  final Value<String> snapshotRevision;
  final Value<String> algorithmVersion;
  final Value<String> inputFingerprint;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const LifeEventChartSnapshotRefsCompanion({
    this.chartSnapshotId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.divinationTypeKey = const Value.absent(),
    this.subDivinationTypeKey = const Value.absent(),
    this.snapshotRevision = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.inputFingerprint = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventChartSnapshotRefsCompanion.insert({
    required String chartSnapshotId,
    required String profileId,
    required String providerId,
    required String divinationTypeKey,
    this.subDivinationTypeKey = const Value.absent(),
    required String snapshotRevision,
    required String algorithmVersion,
    required String inputFingerprint,
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : chartSnapshotId = Value(chartSnapshotId),
       profileId = Value(profileId),
       providerId = Value(providerId),
       divinationTypeKey = Value(divinationTypeKey),
       snapshotRevision = Value(snapshotRevision),
       algorithmVersion = Value(algorithmVersion),
       inputFingerprint = Value(inputFingerprint),
       createdAtMs = Value(createdAtMs);
  static Insertable<LifeEventChartSnapshotRow> custom({
    Expression<String>? chartSnapshotId,
    Expression<String>? profileId,
    Expression<String>? providerId,
    Expression<String>? divinationTypeKey,
    Expression<String>? subDivinationTypeKey,
    Expression<String>? snapshotRevision,
    Expression<String>? algorithmVersion,
    Expression<String>? inputFingerprint,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chartSnapshotId != null) 'chart_snapshot_id': chartSnapshotId,
      if (profileId != null) 'profile_id': profileId,
      if (providerId != null) 'provider_id': providerId,
      if (divinationTypeKey != null) 'divination_type_key': divinationTypeKey,
      if (subDivinationTypeKey != null)
        'sub_divination_type_key': subDivinationTypeKey,
      if (snapshotRevision != null) 'snapshot_revision': snapshotRevision,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (inputFingerprint != null) 'input_fingerprint': inputFingerprint,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventChartSnapshotRefsCompanion copyWith({
    Value<String>? chartSnapshotId,
    Value<String>? profileId,
    Value<String>? providerId,
    Value<String>? divinationTypeKey,
    Value<String?>? subDivinationTypeKey,
    Value<String>? snapshotRevision,
    Value<String>? algorithmVersion,
    Value<String>? inputFingerprint,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return LifeEventChartSnapshotRefsCompanion(
      chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
      profileId: profileId ?? this.profileId,
      providerId: providerId ?? this.providerId,
      divinationTypeKey: divinationTypeKey ?? this.divinationTypeKey,
      subDivinationTypeKey: subDivinationTypeKey ?? this.subDivinationTypeKey,
      snapshotRevision: snapshotRevision ?? this.snapshotRevision,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      inputFingerprint: inputFingerprint ?? this.inputFingerprint,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chartSnapshotId.present) {
      map['chart_snapshot_id'] = Variable<String>(chartSnapshotId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (divinationTypeKey.present) {
      map['divination_type_key'] = Variable<String>(divinationTypeKey.value);
    }
    if (subDivinationTypeKey.present) {
      map['sub_divination_type_key'] = Variable<String>(
        subDivinationTypeKey.value,
      );
    }
    if (snapshotRevision.present) {
      map['snapshot_revision'] = Variable<String>(snapshotRevision.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<String>(algorithmVersion.value);
    }
    if (inputFingerprint.present) {
      map['input_fingerprint'] = Variable<String>(inputFingerprint.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventChartSnapshotRefsCompanion(')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('profileId: $profileId, ')
          ..write('providerId: $providerId, ')
          ..write('divinationTypeKey: $divinationTypeKey, ')
          ..write('subDivinationTypeKey: $subDivinationTypeKey, ')
          ..write('snapshotRevision: $snapshotRevision, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('inputFingerprint: $inputFingerprint, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventProviderDescriptorsTable extends LifeEventProviderDescriptors
    with
        TableInfo<
          $LifeEventProviderDescriptorsTable,
          LifeEventProviderDescriptorRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventProviderDescriptorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerVersionMeta = const VerificationMeta(
    'providerVersion',
  );
  @override
  late final GeneratedColumn<String> providerVersion = GeneratedColumn<String>(
    'provider_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<String> algorithmVersion = GeneratedColumn<String>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataVersionMeta = const VerificationMeta(
    'dataVersion',
  );
  @override
  late final GeneratedColumn<String> dataVersion = GeneratedColumn<String>(
    'data_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<String> schemaVersion = GeneratedColumn<String>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptorJsonMeta = const VerificationMeta(
    'descriptorJson',
  );
  @override
  late final GeneratedColumn<String> descriptorJson = GeneratedColumn<String>(
    'descriptor_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    providerId,
    providerVersion,
    algorithmVersion,
    dataVersion,
    schemaVersion,
    descriptorJson,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_provider_descriptors';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventProviderDescriptorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('provider_version')) {
      context.handle(
        _providerVersionMeta,
        providerVersion.isAcceptableOrUnknown(
          data['provider_version']!,
          _providerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerVersionMeta);
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algorithmVersionMeta);
    }
    if (data.containsKey('data_version')) {
      context.handle(
        _dataVersionMeta,
        dataVersion.isAcceptableOrUnknown(
          data['data_version']!,
          _dataVersionMeta,
        ),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('descriptor_json')) {
      context.handle(
        _descriptorJsonMeta,
        descriptorJson.isAcceptableOrUnknown(
          data['descriptor_json']!,
          _descriptorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptorJsonMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId};
  @override
  LifeEventProviderDescriptorRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventProviderDescriptorRow(
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      providerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_version'],
      )!,
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm_version'],
      )!,
      dataVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_version'],
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema_version'],
      )!,
      descriptorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descriptor_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $LifeEventProviderDescriptorsTable createAlias(String alias) {
    return $LifeEventProviderDescriptorsTable(attachedDatabase, alias);
  }
}

class LifeEventProviderDescriptorRow extends DataClass
    implements Insertable<LifeEventProviderDescriptorRow> {
  final String providerId;
  final String providerVersion;
  final String algorithmVersion;
  final String? dataVersion;
  final String schemaVersion;
  final String descriptorJson;
  final int createdAtMs;
  const LifeEventProviderDescriptorRow({
    required this.providerId,
    required this.providerVersion,
    required this.algorithmVersion,
    this.dataVersion,
    required this.schemaVersion,
    required this.descriptorJson,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider_id'] = Variable<String>(providerId);
    map['provider_version'] = Variable<String>(providerVersion);
    map['algorithm_version'] = Variable<String>(algorithmVersion);
    if (!nullToAbsent || dataVersion != null) {
      map['data_version'] = Variable<String>(dataVersion);
    }
    map['schema_version'] = Variable<String>(schemaVersion);
    map['descriptor_json'] = Variable<String>(descriptorJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  LifeEventProviderDescriptorsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventProviderDescriptorsCompanion(
      providerId: Value(providerId),
      providerVersion: Value(providerVersion),
      algorithmVersion: Value(algorithmVersion),
      dataVersion: dataVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(dataVersion),
      schemaVersion: Value(schemaVersion),
      descriptorJson: Value(descriptorJson),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory LifeEventProviderDescriptorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventProviderDescriptorRow(
      providerId: serializer.fromJson<String>(json['providerId']),
      providerVersion: serializer.fromJson<String>(json['providerVersion']),
      algorithmVersion: serializer.fromJson<String>(json['algorithmVersion']),
      dataVersion: serializer.fromJson<String?>(json['dataVersion']),
      schemaVersion: serializer.fromJson<String>(json['schemaVersion']),
      descriptorJson: serializer.fromJson<String>(json['descriptorJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'providerId': serializer.toJson<String>(providerId),
      'providerVersion': serializer.toJson<String>(providerVersion),
      'algorithmVersion': serializer.toJson<String>(algorithmVersion),
      'dataVersion': serializer.toJson<String?>(dataVersion),
      'schemaVersion': serializer.toJson<String>(schemaVersion),
      'descriptorJson': serializer.toJson<String>(descriptorJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  LifeEventProviderDescriptorRow copyWith({
    String? providerId,
    String? providerVersion,
    String? algorithmVersion,
    Value<String?> dataVersion = const Value.absent(),
    String? schemaVersion,
    String? descriptorJson,
    int? createdAtMs,
  }) => LifeEventProviderDescriptorRow(
    providerId: providerId ?? this.providerId,
    providerVersion: providerVersion ?? this.providerVersion,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    dataVersion: dataVersion.present ? dataVersion.value : this.dataVersion,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    descriptorJson: descriptorJson ?? this.descriptorJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  LifeEventProviderDescriptorRow copyWithCompanion(
    LifeEventProviderDescriptorsCompanion data,
  ) {
    return LifeEventProviderDescriptorRow(
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      providerVersion: data.providerVersion.present
          ? data.providerVersion.value
          : this.providerVersion,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      dataVersion: data.dataVersion.present
          ? data.dataVersion.value
          : this.dataVersion,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      descriptorJson: data.descriptorJson.present
          ? data.descriptorJson.value
          : this.descriptorJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventProviderDescriptorRow(')
          ..write('providerId: $providerId, ')
          ..write('providerVersion: $providerVersion, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('descriptorJson: $descriptorJson, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    providerId,
    providerVersion,
    algorithmVersion,
    dataVersion,
    schemaVersion,
    descriptorJson,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventProviderDescriptorRow &&
          other.providerId == this.providerId &&
          other.providerVersion == this.providerVersion &&
          other.algorithmVersion == this.algorithmVersion &&
          other.dataVersion == this.dataVersion &&
          other.schemaVersion == this.schemaVersion &&
          other.descriptorJson == this.descriptorJson &&
          other.createdAtMs == this.createdAtMs);
}

class LifeEventProviderDescriptorsCompanion
    extends UpdateCompanion<LifeEventProviderDescriptorRow> {
  final Value<String> providerId;
  final Value<String> providerVersion;
  final Value<String> algorithmVersion;
  final Value<String?> dataVersion;
  final Value<String> schemaVersion;
  final Value<String> descriptorJson;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const LifeEventProviderDescriptorsCompanion({
    this.providerId = const Value.absent(),
    this.providerVersion = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.dataVersion = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.descriptorJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventProviderDescriptorsCompanion.insert({
    required String providerId,
    required String providerVersion,
    required String algorithmVersion,
    this.dataVersion = const Value.absent(),
    required String schemaVersion,
    required String descriptorJson,
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : providerId = Value(providerId),
       providerVersion = Value(providerVersion),
       algorithmVersion = Value(algorithmVersion),
       schemaVersion = Value(schemaVersion),
       descriptorJson = Value(descriptorJson),
       createdAtMs = Value(createdAtMs);
  static Insertable<LifeEventProviderDescriptorRow> custom({
    Expression<String>? providerId,
    Expression<String>? providerVersion,
    Expression<String>? algorithmVersion,
    Expression<String>? dataVersion,
    Expression<String>? schemaVersion,
    Expression<String>? descriptorJson,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (providerId != null) 'provider_id': providerId,
      if (providerVersion != null) 'provider_version': providerVersion,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (dataVersion != null) 'data_version': dataVersion,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (descriptorJson != null) 'descriptor_json': descriptorJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventProviderDescriptorsCompanion copyWith({
    Value<String>? providerId,
    Value<String>? providerVersion,
    Value<String>? algorithmVersion,
    Value<String?>? dataVersion,
    Value<String>? schemaVersion,
    Value<String>? descriptorJson,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return LifeEventProviderDescriptorsCompanion(
      providerId: providerId ?? this.providerId,
      providerVersion: providerVersion ?? this.providerVersion,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      dataVersion: dataVersion ?? this.dataVersion,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      descriptorJson: descriptorJson ?? this.descriptorJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (providerVersion.present) {
      map['provider_version'] = Variable<String>(providerVersion.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<String>(algorithmVersion.value);
    }
    if (dataVersion.present) {
      map['data_version'] = Variable<String>(dataVersion.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<String>(schemaVersion.value);
    }
    if (descriptorJson.present) {
      map['descriptor_json'] = Variable<String>(descriptorJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventProviderDescriptorsCompanion(')
          ..write('providerId: $providerId, ')
          ..write('providerVersion: $providerVersion, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('descriptorJson: $descriptorJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventEventTypeDescriptorsTable extends LifeEventEventTypeDescriptors
    with
        TableInfo<
          $LifeEventEventTypeDescriptorsTable,
          LifeEventEventTypeDescriptorRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventEventTypeDescriptorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeIdMeta = const VerificationMeta(
    'eventTypeId',
  );
  @override
  late final GeneratedColumn<String> eventTypeId = GeneratedColumn<String>(
    'event_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<String> schemaVersion = GeneratedColumn<String>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptorJsonMeta = const VerificationMeta(
    'descriptorJson',
  );
  @override
  late final GeneratedColumn<String> descriptorJson = GeneratedColumn<String>(
    'descriptor_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    providerId,
    eventTypeId,
    schemaVersion,
    descriptorJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_event_type_descriptors';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventEventTypeDescriptorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('event_type_id')) {
      context.handle(
        _eventTypeIdMeta,
        eventTypeId.isAcceptableOrUnknown(
          data['event_type_id']!,
          _eventTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTypeIdMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('descriptor_json')) {
      context.handle(
        _descriptorJsonMeta,
        descriptorJson.isAcceptableOrUnknown(
          data['descriptor_json']!,
          _descriptorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptorJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId, eventTypeId};
  @override
  LifeEventEventTypeDescriptorRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventEventTypeDescriptorRow(
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      eventTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type_id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema_version'],
      )!,
      descriptorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descriptor_json'],
      )!,
    );
  }

  @override
  $LifeEventEventTypeDescriptorsTable createAlias(String alias) {
    return $LifeEventEventTypeDescriptorsTable(attachedDatabase, alias);
  }
}

class LifeEventEventTypeDescriptorRow extends DataClass
    implements Insertable<LifeEventEventTypeDescriptorRow> {
  final String providerId;
  final String eventTypeId;
  final String schemaVersion;
  final String descriptorJson;
  const LifeEventEventTypeDescriptorRow({
    required this.providerId,
    required this.eventTypeId,
    required this.schemaVersion,
    required this.descriptorJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider_id'] = Variable<String>(providerId);
    map['event_type_id'] = Variable<String>(eventTypeId);
    map['schema_version'] = Variable<String>(schemaVersion);
    map['descriptor_json'] = Variable<String>(descriptorJson);
    return map;
  }

  LifeEventEventTypeDescriptorsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventEventTypeDescriptorsCompanion(
      providerId: Value(providerId),
      eventTypeId: Value(eventTypeId),
      schemaVersion: Value(schemaVersion),
      descriptorJson: Value(descriptorJson),
    );
  }

  factory LifeEventEventTypeDescriptorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventEventTypeDescriptorRow(
      providerId: serializer.fromJson<String>(json['providerId']),
      eventTypeId: serializer.fromJson<String>(json['eventTypeId']),
      schemaVersion: serializer.fromJson<String>(json['schemaVersion']),
      descriptorJson: serializer.fromJson<String>(json['descriptorJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'providerId': serializer.toJson<String>(providerId),
      'eventTypeId': serializer.toJson<String>(eventTypeId),
      'schemaVersion': serializer.toJson<String>(schemaVersion),
      'descriptorJson': serializer.toJson<String>(descriptorJson),
    };
  }

  LifeEventEventTypeDescriptorRow copyWith({
    String? providerId,
    String? eventTypeId,
    String? schemaVersion,
    String? descriptorJson,
  }) => LifeEventEventTypeDescriptorRow(
    providerId: providerId ?? this.providerId,
    eventTypeId: eventTypeId ?? this.eventTypeId,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    descriptorJson: descriptorJson ?? this.descriptorJson,
  );
  LifeEventEventTypeDescriptorRow copyWithCompanion(
    LifeEventEventTypeDescriptorsCompanion data,
  ) {
    return LifeEventEventTypeDescriptorRow(
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      eventTypeId: data.eventTypeId.present
          ? data.eventTypeId.value
          : this.eventTypeId,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      descriptorJson: data.descriptorJson.present
          ? data.descriptorJson.value
          : this.descriptorJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventEventTypeDescriptorRow(')
          ..write('providerId: $providerId, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('descriptorJson: $descriptorJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(providerId, eventTypeId, schemaVersion, descriptorJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventEventTypeDescriptorRow &&
          other.providerId == this.providerId &&
          other.eventTypeId == this.eventTypeId &&
          other.schemaVersion == this.schemaVersion &&
          other.descriptorJson == this.descriptorJson);
}

class LifeEventEventTypeDescriptorsCompanion
    extends UpdateCompanion<LifeEventEventTypeDescriptorRow> {
  final Value<String> providerId;
  final Value<String> eventTypeId;
  final Value<String> schemaVersion;
  final Value<String> descriptorJson;
  final Value<int> rowid;
  const LifeEventEventTypeDescriptorsCompanion({
    this.providerId = const Value.absent(),
    this.eventTypeId = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.descriptorJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventEventTypeDescriptorsCompanion.insert({
    required String providerId,
    required String eventTypeId,
    required String schemaVersion,
    required String descriptorJson,
    this.rowid = const Value.absent(),
  }) : providerId = Value(providerId),
       eventTypeId = Value(eventTypeId),
       schemaVersion = Value(schemaVersion),
       descriptorJson = Value(descriptorJson);
  static Insertable<LifeEventEventTypeDescriptorRow> custom({
    Expression<String>? providerId,
    Expression<String>? eventTypeId,
    Expression<String>? schemaVersion,
    Expression<String>? descriptorJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (providerId != null) 'provider_id': providerId,
      if (eventTypeId != null) 'event_type_id': eventTypeId,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (descriptorJson != null) 'descriptor_json': descriptorJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventEventTypeDescriptorsCompanion copyWith({
    Value<String>? providerId,
    Value<String>? eventTypeId,
    Value<String>? schemaVersion,
    Value<String>? descriptorJson,
    Value<int>? rowid,
  }) {
    return LifeEventEventTypeDescriptorsCompanion(
      providerId: providerId ?? this.providerId,
      eventTypeId: eventTypeId ?? this.eventTypeId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      descriptorJson: descriptorJson ?? this.descriptorJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (eventTypeId.present) {
      map['event_type_id'] = Variable<String>(eventTypeId.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<String>(schemaVersion.value);
    }
    if (descriptorJson.present) {
      map['descriptor_json'] = Variable<String>(descriptorJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventEventTypeDescriptorsCompanion(')
          ..write('providerId: $providerId, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('descriptorJson: $descriptorJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventProjectionsTable extends LifeEventProjections
    with TableInfo<$LifeEventProjectionsTable, LifeEventProjectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventProjectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectionIdMeta = const VerificationMeta(
    'projectionId',
  );
  @override
  late final GeneratedColumn<String> projectionId = GeneratedColumn<String>(
    'projection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverageIdMeta = const VerificationMeta(
    'coverageId',
  );
  @override
  late final GeneratedColumn<String> coverageId = GeneratedColumn<String>(
    'coverage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverageGenerationMeta =
      const VerificationMeta('coverageGeneration');
  @override
  late final GeneratedColumn<int> coverageGeneration = GeneratedColumn<int>(
    'coverage_generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceProviderIdMeta = const VerificationMeta(
    'sourceProviderId',
  );
  @override
  late final GeneratedColumn<String> sourceProviderId = GeneratedColumn<String>(
    'source_provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceEventIdMeta = const VerificationMeta(
    'sourceEventId',
  );
  @override
  late final GeneratedColumn<String> sourceEventId = GeneratedColumn<String>(
    'source_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventRevisionMeta = const VerificationMeta(
    'eventRevision',
  );
  @override
  late final GeneratedColumn<String> eventRevision = GeneratedColumn<String>(
    'event_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chartSnapshotIdMeta = const VerificationMeta(
    'chartSnapshotId',
  );
  @override
  late final GeneratedColumn<String> chartSnapshotId = GeneratedColumn<String>(
    'chart_snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _divinationTypeKeyMeta = const VerificationMeta(
    'divinationTypeKey',
  );
  @override
  late final GeneratedColumn<String> divinationTypeKey =
      GeneratedColumn<String>(
        'divination_type_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _subDivinationTypeKeyMeta =
      const VerificationMeta('subDivinationTypeKey');
  @override
  late final GeneratedColumn<String> subDivinationTypeKey =
      GeneratedColumn<String>(
        'sub_divination_type_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _eventTypeIdMeta = const VerificationMeta(
    'eventTypeId',
  );
  @override
  late final GeneratedColumn<String> eventTypeId = GeneratedColumn<String>(
    'event_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveStartMsMeta = const VerificationMeta(
    'effectiveStartMs',
  );
  @override
  late final GeneratedColumn<int> effectiveStartMs = GeneratedColumn<int>(
    'effective_start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precisionRankMeta = const VerificationMeta(
    'precisionRank',
  );
  @override
  late final GeneratedColumn<int> precisionRank = GeneratedColumn<int>(
    'precision_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectionJsonMeta = const VerificationMeta(
    'projectionJson',
  );
  @override
  late final GeneratedColumn<String> projectionJson = GeneratedColumn<String>(
    'projection_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifecycleStatusMeta = const VerificationMeta(
    'lifecycleStatus',
  );
  @override
  late final GeneratedColumn<int> lifecycleStatus = GeneratedColumn<int>(
    'lifecycle_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    projectionId,
    coverageId,
    coverageGeneration,
    sourceProviderId,
    sourceEventId,
    eventRevision,
    ownerScopeId,
    subjectId,
    profileId,
    chartSnapshotId,
    divinationTypeKey,
    subDivinationTypeKey,
    eventTypeId,
    effectiveStartMs,
    precisionRank,
    projectionJson,
    lifecycleStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_projections';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventProjectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('projection_id')) {
      context.handle(
        _projectionIdMeta,
        projectionId.isAcceptableOrUnknown(
          data['projection_id']!,
          _projectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectionIdMeta);
    }
    if (data.containsKey('coverage_id')) {
      context.handle(
        _coverageIdMeta,
        coverageId.isAcceptableOrUnknown(data['coverage_id']!, _coverageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_coverageIdMeta);
    }
    if (data.containsKey('coverage_generation')) {
      context.handle(
        _coverageGenerationMeta,
        coverageGeneration.isAcceptableOrUnknown(
          data['coverage_generation']!,
          _coverageGenerationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coverageGenerationMeta);
    }
    if (data.containsKey('source_provider_id')) {
      context.handle(
        _sourceProviderIdMeta,
        sourceProviderId.isAcceptableOrUnknown(
          data['source_provider_id']!,
          _sourceProviderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceProviderIdMeta);
    }
    if (data.containsKey('source_event_id')) {
      context.handle(
        _sourceEventIdMeta,
        sourceEventId.isAcceptableOrUnknown(
          data['source_event_id']!,
          _sourceEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEventIdMeta);
    }
    if (data.containsKey('event_revision')) {
      context.handle(
        _eventRevisionMeta,
        eventRevision.isAcceptableOrUnknown(
          data['event_revision']!,
          _eventRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventRevisionMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('chart_snapshot_id')) {
      context.handle(
        _chartSnapshotIdMeta,
        chartSnapshotId.isAcceptableOrUnknown(
          data['chart_snapshot_id']!,
          _chartSnapshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chartSnapshotIdMeta);
    }
    if (data.containsKey('divination_type_key')) {
      context.handle(
        _divinationTypeKeyMeta,
        divinationTypeKey.isAcceptableOrUnknown(
          data['divination_type_key']!,
          _divinationTypeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_divinationTypeKeyMeta);
    }
    if (data.containsKey('sub_divination_type_key')) {
      context.handle(
        _subDivinationTypeKeyMeta,
        subDivinationTypeKey.isAcceptableOrUnknown(
          data['sub_divination_type_key']!,
          _subDivinationTypeKeyMeta,
        ),
      );
    }
    if (data.containsKey('event_type_id')) {
      context.handle(
        _eventTypeIdMeta,
        eventTypeId.isAcceptableOrUnknown(
          data['event_type_id']!,
          _eventTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTypeIdMeta);
    }
    if (data.containsKey('effective_start_ms')) {
      context.handle(
        _effectiveStartMsMeta,
        effectiveStartMs.isAcceptableOrUnknown(
          data['effective_start_ms']!,
          _effectiveStartMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveStartMsMeta);
    }
    if (data.containsKey('precision_rank')) {
      context.handle(
        _precisionRankMeta,
        precisionRank.isAcceptableOrUnknown(
          data['precision_rank']!,
          _precisionRankMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precisionRankMeta);
    }
    if (data.containsKey('projection_json')) {
      context.handle(
        _projectionJsonMeta,
        projectionJson.isAcceptableOrUnknown(
          data['projection_json']!,
          _projectionJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectionJsonMeta);
    }
    if (data.containsKey('lifecycle_status')) {
      context.handle(
        _lifecycleStatusMeta,
        lifecycleStatus.isAcceptableOrUnknown(
          data['lifecycle_status']!,
          _lifecycleStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lifecycleStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectionId};
  @override
  LifeEventProjectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventProjectionRow(
      projectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}projection_id'],
      )!,
      coverageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverage_id'],
      )!,
      coverageGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coverage_generation'],
      )!,
      sourceProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_provider_id'],
      )!,
      sourceEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_event_id'],
      )!,
      eventRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_revision'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      chartSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chart_snapshot_id'],
      )!,
      divinationTypeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}divination_type_key'],
      )!,
      subDivinationTypeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_divination_type_key'],
      ),
      eventTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type_id'],
      )!,
      effectiveStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_start_ms'],
      )!,
      precisionRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precision_rank'],
      )!,
      projectionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}projection_json'],
      )!,
      lifecycleStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifecycle_status'],
      )!,
    );
  }

  @override
  $LifeEventProjectionsTable createAlias(String alias) {
    return $LifeEventProjectionsTable(attachedDatabase, alias);
  }
}

class LifeEventProjectionRow extends DataClass
    implements Insertable<LifeEventProjectionRow> {
  final String projectionId;
  final String coverageId;
  final int coverageGeneration;
  final String sourceProviderId;
  final String sourceEventId;
  final String eventRevision;
  final String ownerScopeId;
  final String subjectId;
  final String profileId;
  final String chartSnapshotId;
  final String divinationTypeKey;
  final String? subDivinationTypeKey;
  final String eventTypeId;
  final int effectiveStartMs;
  final int precisionRank;
  final String projectionJson;
  final int lifecycleStatus;
  const LifeEventProjectionRow({
    required this.projectionId,
    required this.coverageId,
    required this.coverageGeneration,
    required this.sourceProviderId,
    required this.sourceEventId,
    required this.eventRevision,
    required this.ownerScopeId,
    required this.subjectId,
    required this.profileId,
    required this.chartSnapshotId,
    required this.divinationTypeKey,
    this.subDivinationTypeKey,
    required this.eventTypeId,
    required this.effectiveStartMs,
    required this.precisionRank,
    required this.projectionJson,
    required this.lifecycleStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['projection_id'] = Variable<String>(projectionId);
    map['coverage_id'] = Variable<String>(coverageId);
    map['coverage_generation'] = Variable<int>(coverageGeneration);
    map['source_provider_id'] = Variable<String>(sourceProviderId);
    map['source_event_id'] = Variable<String>(sourceEventId);
    map['event_revision'] = Variable<String>(eventRevision);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    map['subject_id'] = Variable<String>(subjectId);
    map['profile_id'] = Variable<String>(profileId);
    map['chart_snapshot_id'] = Variable<String>(chartSnapshotId);
    map['divination_type_key'] = Variable<String>(divinationTypeKey);
    if (!nullToAbsent || subDivinationTypeKey != null) {
      map['sub_divination_type_key'] = Variable<String>(subDivinationTypeKey);
    }
    map['event_type_id'] = Variable<String>(eventTypeId);
    map['effective_start_ms'] = Variable<int>(effectiveStartMs);
    map['precision_rank'] = Variable<int>(precisionRank);
    map['projection_json'] = Variable<String>(projectionJson);
    map['lifecycle_status'] = Variable<int>(lifecycleStatus);
    return map;
  }

  LifeEventProjectionsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventProjectionsCompanion(
      projectionId: Value(projectionId),
      coverageId: Value(coverageId),
      coverageGeneration: Value(coverageGeneration),
      sourceProviderId: Value(sourceProviderId),
      sourceEventId: Value(sourceEventId),
      eventRevision: Value(eventRevision),
      ownerScopeId: Value(ownerScopeId),
      subjectId: Value(subjectId),
      profileId: Value(profileId),
      chartSnapshotId: Value(chartSnapshotId),
      divinationTypeKey: Value(divinationTypeKey),
      subDivinationTypeKey: subDivinationTypeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(subDivinationTypeKey),
      eventTypeId: Value(eventTypeId),
      effectiveStartMs: Value(effectiveStartMs),
      precisionRank: Value(precisionRank),
      projectionJson: Value(projectionJson),
      lifecycleStatus: Value(lifecycleStatus),
    );
  }

  factory LifeEventProjectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventProjectionRow(
      projectionId: serializer.fromJson<String>(json['projectionId']),
      coverageId: serializer.fromJson<String>(json['coverageId']),
      coverageGeneration: serializer.fromJson<int>(json['coverageGeneration']),
      sourceProviderId: serializer.fromJson<String>(json['sourceProviderId']),
      sourceEventId: serializer.fromJson<String>(json['sourceEventId']),
      eventRevision: serializer.fromJson<String>(json['eventRevision']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      chartSnapshotId: serializer.fromJson<String>(json['chartSnapshotId']),
      divinationTypeKey: serializer.fromJson<String>(json['divinationTypeKey']),
      subDivinationTypeKey: serializer.fromJson<String?>(
        json['subDivinationTypeKey'],
      ),
      eventTypeId: serializer.fromJson<String>(json['eventTypeId']),
      effectiveStartMs: serializer.fromJson<int>(json['effectiveStartMs']),
      precisionRank: serializer.fromJson<int>(json['precisionRank']),
      projectionJson: serializer.fromJson<String>(json['projectionJson']),
      lifecycleStatus: serializer.fromJson<int>(json['lifecycleStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectionId': serializer.toJson<String>(projectionId),
      'coverageId': serializer.toJson<String>(coverageId),
      'coverageGeneration': serializer.toJson<int>(coverageGeneration),
      'sourceProviderId': serializer.toJson<String>(sourceProviderId),
      'sourceEventId': serializer.toJson<String>(sourceEventId),
      'eventRevision': serializer.toJson<String>(eventRevision),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'subjectId': serializer.toJson<String>(subjectId),
      'profileId': serializer.toJson<String>(profileId),
      'chartSnapshotId': serializer.toJson<String>(chartSnapshotId),
      'divinationTypeKey': serializer.toJson<String>(divinationTypeKey),
      'subDivinationTypeKey': serializer.toJson<String?>(subDivinationTypeKey),
      'eventTypeId': serializer.toJson<String>(eventTypeId),
      'effectiveStartMs': serializer.toJson<int>(effectiveStartMs),
      'precisionRank': serializer.toJson<int>(precisionRank),
      'projectionJson': serializer.toJson<String>(projectionJson),
      'lifecycleStatus': serializer.toJson<int>(lifecycleStatus),
    };
  }

  LifeEventProjectionRow copyWith({
    String? projectionId,
    String? coverageId,
    int? coverageGeneration,
    String? sourceProviderId,
    String? sourceEventId,
    String? eventRevision,
    String? ownerScopeId,
    String? subjectId,
    String? profileId,
    String? chartSnapshotId,
    String? divinationTypeKey,
    Value<String?> subDivinationTypeKey = const Value.absent(),
    String? eventTypeId,
    int? effectiveStartMs,
    int? precisionRank,
    String? projectionJson,
    int? lifecycleStatus,
  }) => LifeEventProjectionRow(
    projectionId: projectionId ?? this.projectionId,
    coverageId: coverageId ?? this.coverageId,
    coverageGeneration: coverageGeneration ?? this.coverageGeneration,
    sourceProviderId: sourceProviderId ?? this.sourceProviderId,
    sourceEventId: sourceEventId ?? this.sourceEventId,
    eventRevision: eventRevision ?? this.eventRevision,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    subjectId: subjectId ?? this.subjectId,
    profileId: profileId ?? this.profileId,
    chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
    divinationTypeKey: divinationTypeKey ?? this.divinationTypeKey,
    subDivinationTypeKey: subDivinationTypeKey.present
        ? subDivinationTypeKey.value
        : this.subDivinationTypeKey,
    eventTypeId: eventTypeId ?? this.eventTypeId,
    effectiveStartMs: effectiveStartMs ?? this.effectiveStartMs,
    precisionRank: precisionRank ?? this.precisionRank,
    projectionJson: projectionJson ?? this.projectionJson,
    lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
  );
  LifeEventProjectionRow copyWithCompanion(LifeEventProjectionsCompanion data) {
    return LifeEventProjectionRow(
      projectionId: data.projectionId.present
          ? data.projectionId.value
          : this.projectionId,
      coverageId: data.coverageId.present
          ? data.coverageId.value
          : this.coverageId,
      coverageGeneration: data.coverageGeneration.present
          ? data.coverageGeneration.value
          : this.coverageGeneration,
      sourceProviderId: data.sourceProviderId.present
          ? data.sourceProviderId.value
          : this.sourceProviderId,
      sourceEventId: data.sourceEventId.present
          ? data.sourceEventId.value
          : this.sourceEventId,
      eventRevision: data.eventRevision.present
          ? data.eventRevision.value
          : this.eventRevision,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      chartSnapshotId: data.chartSnapshotId.present
          ? data.chartSnapshotId.value
          : this.chartSnapshotId,
      divinationTypeKey: data.divinationTypeKey.present
          ? data.divinationTypeKey.value
          : this.divinationTypeKey,
      subDivinationTypeKey: data.subDivinationTypeKey.present
          ? data.subDivinationTypeKey.value
          : this.subDivinationTypeKey,
      eventTypeId: data.eventTypeId.present
          ? data.eventTypeId.value
          : this.eventTypeId,
      effectiveStartMs: data.effectiveStartMs.present
          ? data.effectiveStartMs.value
          : this.effectiveStartMs,
      precisionRank: data.precisionRank.present
          ? data.precisionRank.value
          : this.precisionRank,
      projectionJson: data.projectionJson.present
          ? data.projectionJson.value
          : this.projectionJson,
      lifecycleStatus: data.lifecycleStatus.present
          ? data.lifecycleStatus.value
          : this.lifecycleStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventProjectionRow(')
          ..write('projectionId: $projectionId, ')
          ..write('coverageId: $coverageId, ')
          ..write('coverageGeneration: $coverageGeneration, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('eventRevision: $eventRevision, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('subjectId: $subjectId, ')
          ..write('profileId: $profileId, ')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('divinationTypeKey: $divinationTypeKey, ')
          ..write('subDivinationTypeKey: $subDivinationTypeKey, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('effectiveStartMs: $effectiveStartMs, ')
          ..write('precisionRank: $precisionRank, ')
          ..write('projectionJson: $projectionJson, ')
          ..write('lifecycleStatus: $lifecycleStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    projectionId,
    coverageId,
    coverageGeneration,
    sourceProviderId,
    sourceEventId,
    eventRevision,
    ownerScopeId,
    subjectId,
    profileId,
    chartSnapshotId,
    divinationTypeKey,
    subDivinationTypeKey,
    eventTypeId,
    effectiveStartMs,
    precisionRank,
    projectionJson,
    lifecycleStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventProjectionRow &&
          other.projectionId == this.projectionId &&
          other.coverageId == this.coverageId &&
          other.coverageGeneration == this.coverageGeneration &&
          other.sourceProviderId == this.sourceProviderId &&
          other.sourceEventId == this.sourceEventId &&
          other.eventRevision == this.eventRevision &&
          other.ownerScopeId == this.ownerScopeId &&
          other.subjectId == this.subjectId &&
          other.profileId == this.profileId &&
          other.chartSnapshotId == this.chartSnapshotId &&
          other.divinationTypeKey == this.divinationTypeKey &&
          other.subDivinationTypeKey == this.subDivinationTypeKey &&
          other.eventTypeId == this.eventTypeId &&
          other.effectiveStartMs == this.effectiveStartMs &&
          other.precisionRank == this.precisionRank &&
          other.projectionJson == this.projectionJson &&
          other.lifecycleStatus == this.lifecycleStatus);
}

class LifeEventProjectionsCompanion
    extends UpdateCompanion<LifeEventProjectionRow> {
  final Value<String> projectionId;
  final Value<String> coverageId;
  final Value<int> coverageGeneration;
  final Value<String> sourceProviderId;
  final Value<String> sourceEventId;
  final Value<String> eventRevision;
  final Value<String> ownerScopeId;
  final Value<String> subjectId;
  final Value<String> profileId;
  final Value<String> chartSnapshotId;
  final Value<String> divinationTypeKey;
  final Value<String?> subDivinationTypeKey;
  final Value<String> eventTypeId;
  final Value<int> effectiveStartMs;
  final Value<int> precisionRank;
  final Value<String> projectionJson;
  final Value<int> lifecycleStatus;
  final Value<int> rowid;
  const LifeEventProjectionsCompanion({
    this.projectionId = const Value.absent(),
    this.coverageId = const Value.absent(),
    this.coverageGeneration = const Value.absent(),
    this.sourceProviderId = const Value.absent(),
    this.sourceEventId = const Value.absent(),
    this.eventRevision = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.chartSnapshotId = const Value.absent(),
    this.divinationTypeKey = const Value.absent(),
    this.subDivinationTypeKey = const Value.absent(),
    this.eventTypeId = const Value.absent(),
    this.effectiveStartMs = const Value.absent(),
    this.precisionRank = const Value.absent(),
    this.projectionJson = const Value.absent(),
    this.lifecycleStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventProjectionsCompanion.insert({
    required String projectionId,
    required String coverageId,
    required int coverageGeneration,
    required String sourceProviderId,
    required String sourceEventId,
    required String eventRevision,
    required String ownerScopeId,
    required String subjectId,
    required String profileId,
    required String chartSnapshotId,
    required String divinationTypeKey,
    this.subDivinationTypeKey = const Value.absent(),
    required String eventTypeId,
    required int effectiveStartMs,
    required int precisionRank,
    required String projectionJson,
    required int lifecycleStatus,
    this.rowid = const Value.absent(),
  }) : projectionId = Value(projectionId),
       coverageId = Value(coverageId),
       coverageGeneration = Value(coverageGeneration),
       sourceProviderId = Value(sourceProviderId),
       sourceEventId = Value(sourceEventId),
       eventRevision = Value(eventRevision),
       ownerScopeId = Value(ownerScopeId),
       subjectId = Value(subjectId),
       profileId = Value(profileId),
       chartSnapshotId = Value(chartSnapshotId),
       divinationTypeKey = Value(divinationTypeKey),
       eventTypeId = Value(eventTypeId),
       effectiveStartMs = Value(effectiveStartMs),
       precisionRank = Value(precisionRank),
       projectionJson = Value(projectionJson),
       lifecycleStatus = Value(lifecycleStatus);
  static Insertable<LifeEventProjectionRow> custom({
    Expression<String>? projectionId,
    Expression<String>? coverageId,
    Expression<int>? coverageGeneration,
    Expression<String>? sourceProviderId,
    Expression<String>? sourceEventId,
    Expression<String>? eventRevision,
    Expression<String>? ownerScopeId,
    Expression<String>? subjectId,
    Expression<String>? profileId,
    Expression<String>? chartSnapshotId,
    Expression<String>? divinationTypeKey,
    Expression<String>? subDivinationTypeKey,
    Expression<String>? eventTypeId,
    Expression<int>? effectiveStartMs,
    Expression<int>? precisionRank,
    Expression<String>? projectionJson,
    Expression<int>? lifecycleStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectionId != null) 'projection_id': projectionId,
      if (coverageId != null) 'coverage_id': coverageId,
      if (coverageGeneration != null) 'coverage_generation': coverageGeneration,
      if (sourceProviderId != null) 'source_provider_id': sourceProviderId,
      if (sourceEventId != null) 'source_event_id': sourceEventId,
      if (eventRevision != null) 'event_revision': eventRevision,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (subjectId != null) 'subject_id': subjectId,
      if (profileId != null) 'profile_id': profileId,
      if (chartSnapshotId != null) 'chart_snapshot_id': chartSnapshotId,
      if (divinationTypeKey != null) 'divination_type_key': divinationTypeKey,
      if (subDivinationTypeKey != null)
        'sub_divination_type_key': subDivinationTypeKey,
      if (eventTypeId != null) 'event_type_id': eventTypeId,
      if (effectiveStartMs != null) 'effective_start_ms': effectiveStartMs,
      if (precisionRank != null) 'precision_rank': precisionRank,
      if (projectionJson != null) 'projection_json': projectionJson,
      if (lifecycleStatus != null) 'lifecycle_status': lifecycleStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventProjectionsCompanion copyWith({
    Value<String>? projectionId,
    Value<String>? coverageId,
    Value<int>? coverageGeneration,
    Value<String>? sourceProviderId,
    Value<String>? sourceEventId,
    Value<String>? eventRevision,
    Value<String>? ownerScopeId,
    Value<String>? subjectId,
    Value<String>? profileId,
    Value<String>? chartSnapshotId,
    Value<String>? divinationTypeKey,
    Value<String?>? subDivinationTypeKey,
    Value<String>? eventTypeId,
    Value<int>? effectiveStartMs,
    Value<int>? precisionRank,
    Value<String>? projectionJson,
    Value<int>? lifecycleStatus,
    Value<int>? rowid,
  }) {
    return LifeEventProjectionsCompanion(
      projectionId: projectionId ?? this.projectionId,
      coverageId: coverageId ?? this.coverageId,
      coverageGeneration: coverageGeneration ?? this.coverageGeneration,
      sourceProviderId: sourceProviderId ?? this.sourceProviderId,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      eventRevision: eventRevision ?? this.eventRevision,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      subjectId: subjectId ?? this.subjectId,
      profileId: profileId ?? this.profileId,
      chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
      divinationTypeKey: divinationTypeKey ?? this.divinationTypeKey,
      subDivinationTypeKey: subDivinationTypeKey ?? this.subDivinationTypeKey,
      eventTypeId: eventTypeId ?? this.eventTypeId,
      effectiveStartMs: effectiveStartMs ?? this.effectiveStartMs,
      precisionRank: precisionRank ?? this.precisionRank,
      projectionJson: projectionJson ?? this.projectionJson,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectionId.present) {
      map['projection_id'] = Variable<String>(projectionId.value);
    }
    if (coverageId.present) {
      map['coverage_id'] = Variable<String>(coverageId.value);
    }
    if (coverageGeneration.present) {
      map['coverage_generation'] = Variable<int>(coverageGeneration.value);
    }
    if (sourceProviderId.present) {
      map['source_provider_id'] = Variable<String>(sourceProviderId.value);
    }
    if (sourceEventId.present) {
      map['source_event_id'] = Variable<String>(sourceEventId.value);
    }
    if (eventRevision.present) {
      map['event_revision'] = Variable<String>(eventRevision.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (chartSnapshotId.present) {
      map['chart_snapshot_id'] = Variable<String>(chartSnapshotId.value);
    }
    if (divinationTypeKey.present) {
      map['divination_type_key'] = Variable<String>(divinationTypeKey.value);
    }
    if (subDivinationTypeKey.present) {
      map['sub_divination_type_key'] = Variable<String>(
        subDivinationTypeKey.value,
      );
    }
    if (eventTypeId.present) {
      map['event_type_id'] = Variable<String>(eventTypeId.value);
    }
    if (effectiveStartMs.present) {
      map['effective_start_ms'] = Variable<int>(effectiveStartMs.value);
    }
    if (precisionRank.present) {
      map['precision_rank'] = Variable<int>(precisionRank.value);
    }
    if (projectionJson.present) {
      map['projection_json'] = Variable<String>(projectionJson.value);
    }
    if (lifecycleStatus.present) {
      map['lifecycle_status'] = Variable<int>(lifecycleStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventProjectionsCompanion(')
          ..write('projectionId: $projectionId, ')
          ..write('coverageId: $coverageId, ')
          ..write('coverageGeneration: $coverageGeneration, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('eventRevision: $eventRevision, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('subjectId: $subjectId, ')
          ..write('profileId: $profileId, ')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('divinationTypeKey: $divinationTypeKey, ')
          ..write('subDivinationTypeKey: $subDivinationTypeKey, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('effectiveStartMs: $effectiveStartMs, ')
          ..write('precisionRank: $precisionRank, ')
          ..write('projectionJson: $projectionJson, ')
          ..write('lifecycleStatus: $lifecycleStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventCoverageSeriesHeadsTable extends LifeEventCoverageSeriesHeads
    with
        TableInfo<
          $LifeEventCoverageSeriesHeadsTable,
          LifeEventCoverageSeriesHeadRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventCoverageSeriesHeadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _coverageSeriesIdMeta = const VerificationMeta(
    'coverageSeriesId',
  );
  @override
  late final GeneratedColumn<String> coverageSeriesId = GeneratedColumn<String>(
    'coverage_series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chartSnapshotIdMeta = const VerificationMeta(
    'chartSnapshotId',
  );
  @override
  late final GeneratedColumn<String> chartSnapshotId = GeneratedColumn<String>(
    'chart_snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeIdMeta = const VerificationMeta(
    'eventTypeId',
  );
  @override
  late final GeneratedColumn<String> eventTypeId = GeneratedColumn<String>(
    'event_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesRevisionMeta = const VerificationMeta(
    'seriesRevision',
  );
  @override
  late final GeneratedColumn<int> seriesRevision = GeneratedColumn<int>(
    'series_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeCoverageIdMeta = const VerificationMeta(
    'activeCoverageId',
  );
  @override
  late final GeneratedColumn<String> activeCoverageId = GeneratedColumn<String>(
    'active_coverage_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _candidateCoverageIdMeta =
      const VerificationMeta('candidateCoverageId');
  @override
  late final GeneratedColumn<String> candidateCoverageId =
      GeneratedColumn<String>(
        'candidate_coverage_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _desiredRangeStartMsMeta =
      const VerificationMeta('desiredRangeStartMs');
  @override
  late final GeneratedColumn<int> desiredRangeStartMs = GeneratedColumn<int>(
    'desired_range_start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _desiredRangeEndMsMeta = const VerificationMeta(
    'desiredRangeEndMs',
  );
  @override
  late final GeneratedColumn<int> desiredRangeEndMs = GeneratedColumn<int>(
    'desired_range_end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    coverageSeriesId,
    ownerScopeId,
    profileId,
    chartSnapshotId,
    providerId,
    eventTypeId,
    seriesRevision,
    activeCoverageId,
    candidateCoverageId,
    desiredRangeStartMs,
    desiredRangeEndMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_coverage_series_heads';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventCoverageSeriesHeadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('coverage_series_id')) {
      context.handle(
        _coverageSeriesIdMeta,
        coverageSeriesId.isAcceptableOrUnknown(
          data['coverage_series_id']!,
          _coverageSeriesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coverageSeriesIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('chart_snapshot_id')) {
      context.handle(
        _chartSnapshotIdMeta,
        chartSnapshotId.isAcceptableOrUnknown(
          data['chart_snapshot_id']!,
          _chartSnapshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chartSnapshotIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('event_type_id')) {
      context.handle(
        _eventTypeIdMeta,
        eventTypeId.isAcceptableOrUnknown(
          data['event_type_id']!,
          _eventTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTypeIdMeta);
    }
    if (data.containsKey('series_revision')) {
      context.handle(
        _seriesRevisionMeta,
        seriesRevision.isAcceptableOrUnknown(
          data['series_revision']!,
          _seriesRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seriesRevisionMeta);
    }
    if (data.containsKey('active_coverage_id')) {
      context.handle(
        _activeCoverageIdMeta,
        activeCoverageId.isAcceptableOrUnknown(
          data['active_coverage_id']!,
          _activeCoverageIdMeta,
        ),
      );
    }
    if (data.containsKey('candidate_coverage_id')) {
      context.handle(
        _candidateCoverageIdMeta,
        candidateCoverageId.isAcceptableOrUnknown(
          data['candidate_coverage_id']!,
          _candidateCoverageIdMeta,
        ),
      );
    }
    if (data.containsKey('desired_range_start_ms')) {
      context.handle(
        _desiredRangeStartMsMeta,
        desiredRangeStartMs.isAcceptableOrUnknown(
          data['desired_range_start_ms']!,
          _desiredRangeStartMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_desiredRangeStartMsMeta);
    }
    if (data.containsKey('desired_range_end_ms')) {
      context.handle(
        _desiredRangeEndMsMeta,
        desiredRangeEndMs.isAcceptableOrUnknown(
          data['desired_range_end_ms']!,
          _desiredRangeEndMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_desiredRangeEndMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {coverageSeriesId};
  @override
  LifeEventCoverageSeriesHeadRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventCoverageSeriesHeadRow(
      coverageSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverage_series_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      chartSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chart_snapshot_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      eventTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type_id'],
      )!,
      seriesRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_revision'],
      )!,
      activeCoverageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_coverage_id'],
      ),
      candidateCoverageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_coverage_id'],
      ),
      desiredRangeStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}desired_range_start_ms'],
      )!,
      desiredRangeEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}desired_range_end_ms'],
      )!,
    );
  }

  @override
  $LifeEventCoverageSeriesHeadsTable createAlias(String alias) {
    return $LifeEventCoverageSeriesHeadsTable(attachedDatabase, alias);
  }
}

class LifeEventCoverageSeriesHeadRow extends DataClass
    implements Insertable<LifeEventCoverageSeriesHeadRow> {
  final String coverageSeriesId;
  final String ownerScopeId;
  final String profileId;
  final String chartSnapshotId;
  final String providerId;
  final String eventTypeId;
  final int seriesRevision;
  final String? activeCoverageId;
  final String? candidateCoverageId;
  final int desiredRangeStartMs;
  final int desiredRangeEndMs;
  const LifeEventCoverageSeriesHeadRow({
    required this.coverageSeriesId,
    required this.ownerScopeId,
    required this.profileId,
    required this.chartSnapshotId,
    required this.providerId,
    required this.eventTypeId,
    required this.seriesRevision,
    this.activeCoverageId,
    this.candidateCoverageId,
    required this.desiredRangeStartMs,
    required this.desiredRangeEndMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['coverage_series_id'] = Variable<String>(coverageSeriesId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    map['profile_id'] = Variable<String>(profileId);
    map['chart_snapshot_id'] = Variable<String>(chartSnapshotId);
    map['provider_id'] = Variable<String>(providerId);
    map['event_type_id'] = Variable<String>(eventTypeId);
    map['series_revision'] = Variable<int>(seriesRevision);
    if (!nullToAbsent || activeCoverageId != null) {
      map['active_coverage_id'] = Variable<String>(activeCoverageId);
    }
    if (!nullToAbsent || candidateCoverageId != null) {
      map['candidate_coverage_id'] = Variable<String>(candidateCoverageId);
    }
    map['desired_range_start_ms'] = Variable<int>(desiredRangeStartMs);
    map['desired_range_end_ms'] = Variable<int>(desiredRangeEndMs);
    return map;
  }

  LifeEventCoverageSeriesHeadsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventCoverageSeriesHeadsCompanion(
      coverageSeriesId: Value(coverageSeriesId),
      ownerScopeId: Value(ownerScopeId),
      profileId: Value(profileId),
      chartSnapshotId: Value(chartSnapshotId),
      providerId: Value(providerId),
      eventTypeId: Value(eventTypeId),
      seriesRevision: Value(seriesRevision),
      activeCoverageId: activeCoverageId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeCoverageId),
      candidateCoverageId: candidateCoverageId == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateCoverageId),
      desiredRangeStartMs: Value(desiredRangeStartMs),
      desiredRangeEndMs: Value(desiredRangeEndMs),
    );
  }

  factory LifeEventCoverageSeriesHeadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventCoverageSeriesHeadRow(
      coverageSeriesId: serializer.fromJson<String>(json['coverageSeriesId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      chartSnapshotId: serializer.fromJson<String>(json['chartSnapshotId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      eventTypeId: serializer.fromJson<String>(json['eventTypeId']),
      seriesRevision: serializer.fromJson<int>(json['seriesRevision']),
      activeCoverageId: serializer.fromJson<String?>(json['activeCoverageId']),
      candidateCoverageId: serializer.fromJson<String?>(
        json['candidateCoverageId'],
      ),
      desiredRangeStartMs: serializer.fromJson<int>(
        json['desiredRangeStartMs'],
      ),
      desiredRangeEndMs: serializer.fromJson<int>(json['desiredRangeEndMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'coverageSeriesId': serializer.toJson<String>(coverageSeriesId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'profileId': serializer.toJson<String>(profileId),
      'chartSnapshotId': serializer.toJson<String>(chartSnapshotId),
      'providerId': serializer.toJson<String>(providerId),
      'eventTypeId': serializer.toJson<String>(eventTypeId),
      'seriesRevision': serializer.toJson<int>(seriesRevision),
      'activeCoverageId': serializer.toJson<String?>(activeCoverageId),
      'candidateCoverageId': serializer.toJson<String?>(candidateCoverageId),
      'desiredRangeStartMs': serializer.toJson<int>(desiredRangeStartMs),
      'desiredRangeEndMs': serializer.toJson<int>(desiredRangeEndMs),
    };
  }

  LifeEventCoverageSeriesHeadRow copyWith({
    String? coverageSeriesId,
    String? ownerScopeId,
    String? profileId,
    String? chartSnapshotId,
    String? providerId,
    String? eventTypeId,
    int? seriesRevision,
    Value<String?> activeCoverageId = const Value.absent(),
    Value<String?> candidateCoverageId = const Value.absent(),
    int? desiredRangeStartMs,
    int? desiredRangeEndMs,
  }) => LifeEventCoverageSeriesHeadRow(
    coverageSeriesId: coverageSeriesId ?? this.coverageSeriesId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    profileId: profileId ?? this.profileId,
    chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
    providerId: providerId ?? this.providerId,
    eventTypeId: eventTypeId ?? this.eventTypeId,
    seriesRevision: seriesRevision ?? this.seriesRevision,
    activeCoverageId: activeCoverageId.present
        ? activeCoverageId.value
        : this.activeCoverageId,
    candidateCoverageId: candidateCoverageId.present
        ? candidateCoverageId.value
        : this.candidateCoverageId,
    desiredRangeStartMs: desiredRangeStartMs ?? this.desiredRangeStartMs,
    desiredRangeEndMs: desiredRangeEndMs ?? this.desiredRangeEndMs,
  );
  LifeEventCoverageSeriesHeadRow copyWithCompanion(
    LifeEventCoverageSeriesHeadsCompanion data,
  ) {
    return LifeEventCoverageSeriesHeadRow(
      coverageSeriesId: data.coverageSeriesId.present
          ? data.coverageSeriesId.value
          : this.coverageSeriesId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      chartSnapshotId: data.chartSnapshotId.present
          ? data.chartSnapshotId.value
          : this.chartSnapshotId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      eventTypeId: data.eventTypeId.present
          ? data.eventTypeId.value
          : this.eventTypeId,
      seriesRevision: data.seriesRevision.present
          ? data.seriesRevision.value
          : this.seriesRevision,
      activeCoverageId: data.activeCoverageId.present
          ? data.activeCoverageId.value
          : this.activeCoverageId,
      candidateCoverageId: data.candidateCoverageId.present
          ? data.candidateCoverageId.value
          : this.candidateCoverageId,
      desiredRangeStartMs: data.desiredRangeStartMs.present
          ? data.desiredRangeStartMs.value
          : this.desiredRangeStartMs,
      desiredRangeEndMs: data.desiredRangeEndMs.present
          ? data.desiredRangeEndMs.value
          : this.desiredRangeEndMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventCoverageSeriesHeadRow(')
          ..write('coverageSeriesId: $coverageSeriesId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('profileId: $profileId, ')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('providerId: $providerId, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('seriesRevision: $seriesRevision, ')
          ..write('activeCoverageId: $activeCoverageId, ')
          ..write('candidateCoverageId: $candidateCoverageId, ')
          ..write('desiredRangeStartMs: $desiredRangeStartMs, ')
          ..write('desiredRangeEndMs: $desiredRangeEndMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    coverageSeriesId,
    ownerScopeId,
    profileId,
    chartSnapshotId,
    providerId,
    eventTypeId,
    seriesRevision,
    activeCoverageId,
    candidateCoverageId,
    desiredRangeStartMs,
    desiredRangeEndMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventCoverageSeriesHeadRow &&
          other.coverageSeriesId == this.coverageSeriesId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.profileId == this.profileId &&
          other.chartSnapshotId == this.chartSnapshotId &&
          other.providerId == this.providerId &&
          other.eventTypeId == this.eventTypeId &&
          other.seriesRevision == this.seriesRevision &&
          other.activeCoverageId == this.activeCoverageId &&
          other.candidateCoverageId == this.candidateCoverageId &&
          other.desiredRangeStartMs == this.desiredRangeStartMs &&
          other.desiredRangeEndMs == this.desiredRangeEndMs);
}

class LifeEventCoverageSeriesHeadsCompanion
    extends UpdateCompanion<LifeEventCoverageSeriesHeadRow> {
  final Value<String> coverageSeriesId;
  final Value<String> ownerScopeId;
  final Value<String> profileId;
  final Value<String> chartSnapshotId;
  final Value<String> providerId;
  final Value<String> eventTypeId;
  final Value<int> seriesRevision;
  final Value<String?> activeCoverageId;
  final Value<String?> candidateCoverageId;
  final Value<int> desiredRangeStartMs;
  final Value<int> desiredRangeEndMs;
  final Value<int> rowid;
  const LifeEventCoverageSeriesHeadsCompanion({
    this.coverageSeriesId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.chartSnapshotId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.eventTypeId = const Value.absent(),
    this.seriesRevision = const Value.absent(),
    this.activeCoverageId = const Value.absent(),
    this.candidateCoverageId = const Value.absent(),
    this.desiredRangeStartMs = const Value.absent(),
    this.desiredRangeEndMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventCoverageSeriesHeadsCompanion.insert({
    required String coverageSeriesId,
    required String ownerScopeId,
    required String profileId,
    required String chartSnapshotId,
    required String providerId,
    required String eventTypeId,
    required int seriesRevision,
    this.activeCoverageId = const Value.absent(),
    this.candidateCoverageId = const Value.absent(),
    required int desiredRangeStartMs,
    required int desiredRangeEndMs,
    this.rowid = const Value.absent(),
  }) : coverageSeriesId = Value(coverageSeriesId),
       ownerScopeId = Value(ownerScopeId),
       profileId = Value(profileId),
       chartSnapshotId = Value(chartSnapshotId),
       providerId = Value(providerId),
       eventTypeId = Value(eventTypeId),
       seriesRevision = Value(seriesRevision),
       desiredRangeStartMs = Value(desiredRangeStartMs),
       desiredRangeEndMs = Value(desiredRangeEndMs);
  static Insertable<LifeEventCoverageSeriesHeadRow> custom({
    Expression<String>? coverageSeriesId,
    Expression<String>? ownerScopeId,
    Expression<String>? profileId,
    Expression<String>? chartSnapshotId,
    Expression<String>? providerId,
    Expression<String>? eventTypeId,
    Expression<int>? seriesRevision,
    Expression<String>? activeCoverageId,
    Expression<String>? candidateCoverageId,
    Expression<int>? desiredRangeStartMs,
    Expression<int>? desiredRangeEndMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (coverageSeriesId != null) 'coverage_series_id': coverageSeriesId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (profileId != null) 'profile_id': profileId,
      if (chartSnapshotId != null) 'chart_snapshot_id': chartSnapshotId,
      if (providerId != null) 'provider_id': providerId,
      if (eventTypeId != null) 'event_type_id': eventTypeId,
      if (seriesRevision != null) 'series_revision': seriesRevision,
      if (activeCoverageId != null) 'active_coverage_id': activeCoverageId,
      if (candidateCoverageId != null)
        'candidate_coverage_id': candidateCoverageId,
      if (desiredRangeStartMs != null)
        'desired_range_start_ms': desiredRangeStartMs,
      if (desiredRangeEndMs != null) 'desired_range_end_ms': desiredRangeEndMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventCoverageSeriesHeadsCompanion copyWith({
    Value<String>? coverageSeriesId,
    Value<String>? ownerScopeId,
    Value<String>? profileId,
    Value<String>? chartSnapshotId,
    Value<String>? providerId,
    Value<String>? eventTypeId,
    Value<int>? seriesRevision,
    Value<String?>? activeCoverageId,
    Value<String?>? candidateCoverageId,
    Value<int>? desiredRangeStartMs,
    Value<int>? desiredRangeEndMs,
    Value<int>? rowid,
  }) {
    return LifeEventCoverageSeriesHeadsCompanion(
      coverageSeriesId: coverageSeriesId ?? this.coverageSeriesId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      profileId: profileId ?? this.profileId,
      chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
      providerId: providerId ?? this.providerId,
      eventTypeId: eventTypeId ?? this.eventTypeId,
      seriesRevision: seriesRevision ?? this.seriesRevision,
      activeCoverageId: activeCoverageId ?? this.activeCoverageId,
      candidateCoverageId: candidateCoverageId ?? this.candidateCoverageId,
      desiredRangeStartMs: desiredRangeStartMs ?? this.desiredRangeStartMs,
      desiredRangeEndMs: desiredRangeEndMs ?? this.desiredRangeEndMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coverageSeriesId.present) {
      map['coverage_series_id'] = Variable<String>(coverageSeriesId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (chartSnapshotId.present) {
      map['chart_snapshot_id'] = Variable<String>(chartSnapshotId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (eventTypeId.present) {
      map['event_type_id'] = Variable<String>(eventTypeId.value);
    }
    if (seriesRevision.present) {
      map['series_revision'] = Variable<int>(seriesRevision.value);
    }
    if (activeCoverageId.present) {
      map['active_coverage_id'] = Variable<String>(activeCoverageId.value);
    }
    if (candidateCoverageId.present) {
      map['candidate_coverage_id'] = Variable<String>(
        candidateCoverageId.value,
      );
    }
    if (desiredRangeStartMs.present) {
      map['desired_range_start_ms'] = Variable<int>(desiredRangeStartMs.value);
    }
    if (desiredRangeEndMs.present) {
      map['desired_range_end_ms'] = Variable<int>(desiredRangeEndMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventCoverageSeriesHeadsCompanion(')
          ..write('coverageSeriesId: $coverageSeriesId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('profileId: $profileId, ')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('providerId: $providerId, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('seriesRevision: $seriesRevision, ')
          ..write('activeCoverageId: $activeCoverageId, ')
          ..write('candidateCoverageId: $candidateCoverageId, ')
          ..write('desiredRangeStartMs: $desiredRangeStartMs, ')
          ..write('desiredRangeEndMs: $desiredRangeEndMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventCoverageManifestsTable extends LifeEventCoverageManifests
    with
        TableInfo<
          $LifeEventCoverageManifestsTable,
          LifeEventCoverageManifestRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventCoverageManifestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _coverageIdMeta = const VerificationMeta(
    'coverageId',
  );
  @override
  late final GeneratedColumn<String> coverageId = GeneratedColumn<String>(
    'coverage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverageSeriesIdMeta = const VerificationMeta(
    'coverageSeriesId',
  );
  @override
  late final GeneratedColumn<String> coverageSeriesId = GeneratedColumn<String>(
    'coverage_series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverageGenerationMeta =
      const VerificationMeta('coverageGeneration');
  @override
  late final GeneratedColumn<int> coverageGeneration = GeneratedColumn<int>(
    'coverage_generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manifestRevisionMeta = const VerificationMeta(
    'manifestRevision',
  );
  @override
  late final GeneratedColumn<int> manifestRevision = GeneratedColumn<int>(
    'manifest_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingStateMeta = const VerificationMeta(
    'servingState',
  );
  @override
  late final GeneratedColumn<int> servingState = GeneratedColumn<int>(
    'serving_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chartSnapshotIdMeta = const VerificationMeta(
    'chartSnapshotId',
  );
  @override
  late final GeneratedColumn<String> chartSnapshotId = GeneratedColumn<String>(
    'chart_snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chartSnapshotRevisionMeta =
      const VerificationMeta('chartSnapshotRevision');
  @override
  late final GeneratedColumn<String> chartSnapshotRevision =
      GeneratedColumn<String>(
        'chart_snapshot_revision',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerVersionMeta = const VerificationMeta(
    'providerVersion',
  );
  @override
  late final GeneratedColumn<String> providerVersion = GeneratedColumn<String>(
    'provider_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<String> algorithmVersion = GeneratedColumn<String>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataVersionMeta = const VerificationMeta(
    'dataVersion',
  );
  @override
  late final GeneratedColumn<String> dataVersion = GeneratedColumn<String>(
    'data_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeIdMeta = const VerificationMeta(
    'eventTypeId',
  );
  @override
  late final GeneratedColumn<String> eventTypeId = GeneratedColumn<String>(
    'event_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeSchemaVersionMeta =
      const VerificationMeta('eventTypeSchemaVersion');
  @override
  late final GeneratedColumn<String> eventTypeSchemaVersion =
      GeneratedColumn<String>(
        'event_type_schema_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _requestedRangeStartMsMeta =
      const VerificationMeta('requestedRangeStartMs');
  @override
  late final GeneratedColumn<int> requestedRangeStartMs = GeneratedColumn<int>(
    'requested_range_start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedRangeEndMsMeta =
      const VerificationMeta('requestedRangeEndMs');
  @override
  late final GeneratedColumn<int> requestedRangeEndMs = GeneratedColumn<int>(
    'requested_range_end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coveredRangesJsonMeta = const VerificationMeta(
    'coveredRangesJson',
  );
  @override
  late final GeneratedColumn<String> coveredRangesJson =
      GeneratedColumn<String>(
        'covered_ranges_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputFingerprintMeta = const VerificationMeta(
    'inputFingerprint',
  );
  @override
  late final GeneratedColumn<String> inputFingerprint = GeneratedColumn<String>(
    'input_fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedShardCountMeta =
      const VerificationMeta('expectedShardCount');
  @override
  late final GeneratedColumn<int> expectedShardCount = GeneratedColumn<int>(
    'expected_shard_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedShardCountMeta =
      const VerificationMeta('completedShardCount');
  @override
  late final GeneratedColumn<int> completedShardCount = GeneratedColumn<int>(
    'completed_shard_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceEventCountMeta = const VerificationMeta(
    'sourceEventCount',
  );
  @override
  late final GeneratedColumn<int> sourceEventCount = GeneratedColumn<int>(
    'source_event_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outputDigestMeta = const VerificationMeta(
    'outputDigest',
  );
  @override
  late final GeneratedColumn<String> outputDigest = GeneratedColumn<String>(
    'output_digest',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMsMeta = const VerificationMeta(
    'completedAtMs',
  );
  @override
  late final GeneratedColumn<int> completedAtMs = GeneratedColumn<int>(
    'completed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    coverageId,
    coverageSeriesId,
    coverageGeneration,
    manifestRevision,
    servingState,
    profileId,
    chartSnapshotId,
    chartSnapshotRevision,
    providerId,
    providerVersion,
    algorithmVersion,
    dataVersion,
    eventTypeId,
    eventTypeSchemaVersion,
    requestedRangeStartMs,
    requestedRangeEndMs,
    coveredRangesJson,
    status,
    inputFingerprint,
    expectedShardCount,
    completedShardCount,
    sourceEventCount,
    outputDigest,
    startedAtMs,
    completedAtMs,
    lastErrorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_coverage_manifests';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventCoverageManifestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('coverage_id')) {
      context.handle(
        _coverageIdMeta,
        coverageId.isAcceptableOrUnknown(data['coverage_id']!, _coverageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_coverageIdMeta);
    }
    if (data.containsKey('coverage_series_id')) {
      context.handle(
        _coverageSeriesIdMeta,
        coverageSeriesId.isAcceptableOrUnknown(
          data['coverage_series_id']!,
          _coverageSeriesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coverageSeriesIdMeta);
    }
    if (data.containsKey('coverage_generation')) {
      context.handle(
        _coverageGenerationMeta,
        coverageGeneration.isAcceptableOrUnknown(
          data['coverage_generation']!,
          _coverageGenerationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coverageGenerationMeta);
    }
    if (data.containsKey('manifest_revision')) {
      context.handle(
        _manifestRevisionMeta,
        manifestRevision.isAcceptableOrUnknown(
          data['manifest_revision']!,
          _manifestRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manifestRevisionMeta);
    }
    if (data.containsKey('serving_state')) {
      context.handle(
        _servingStateMeta,
        servingState.isAcceptableOrUnknown(
          data['serving_state']!,
          _servingStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingStateMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('chart_snapshot_id')) {
      context.handle(
        _chartSnapshotIdMeta,
        chartSnapshotId.isAcceptableOrUnknown(
          data['chart_snapshot_id']!,
          _chartSnapshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chartSnapshotIdMeta);
    }
    if (data.containsKey('chart_snapshot_revision')) {
      context.handle(
        _chartSnapshotRevisionMeta,
        chartSnapshotRevision.isAcceptableOrUnknown(
          data['chart_snapshot_revision']!,
          _chartSnapshotRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chartSnapshotRevisionMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('provider_version')) {
      context.handle(
        _providerVersionMeta,
        providerVersion.isAcceptableOrUnknown(
          data['provider_version']!,
          _providerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerVersionMeta);
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algorithmVersionMeta);
    }
    if (data.containsKey('data_version')) {
      context.handle(
        _dataVersionMeta,
        dataVersion.isAcceptableOrUnknown(
          data['data_version']!,
          _dataVersionMeta,
        ),
      );
    }
    if (data.containsKey('event_type_id')) {
      context.handle(
        _eventTypeIdMeta,
        eventTypeId.isAcceptableOrUnknown(
          data['event_type_id']!,
          _eventTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTypeIdMeta);
    }
    if (data.containsKey('event_type_schema_version')) {
      context.handle(
        _eventTypeSchemaVersionMeta,
        eventTypeSchemaVersion.isAcceptableOrUnknown(
          data['event_type_schema_version']!,
          _eventTypeSchemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTypeSchemaVersionMeta);
    }
    if (data.containsKey('requested_range_start_ms')) {
      context.handle(
        _requestedRangeStartMsMeta,
        requestedRangeStartMs.isAcceptableOrUnknown(
          data['requested_range_start_ms']!,
          _requestedRangeStartMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedRangeStartMsMeta);
    }
    if (data.containsKey('requested_range_end_ms')) {
      context.handle(
        _requestedRangeEndMsMeta,
        requestedRangeEndMs.isAcceptableOrUnknown(
          data['requested_range_end_ms']!,
          _requestedRangeEndMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedRangeEndMsMeta);
    }
    if (data.containsKey('covered_ranges_json')) {
      context.handle(
        _coveredRangesJsonMeta,
        coveredRangesJson.isAcceptableOrUnknown(
          data['covered_ranges_json']!,
          _coveredRangesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coveredRangesJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('input_fingerprint')) {
      context.handle(
        _inputFingerprintMeta,
        inputFingerprint.isAcceptableOrUnknown(
          data['input_fingerprint']!,
          _inputFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputFingerprintMeta);
    }
    if (data.containsKey('expected_shard_count')) {
      context.handle(
        _expectedShardCountMeta,
        expectedShardCount.isAcceptableOrUnknown(
          data['expected_shard_count']!,
          _expectedShardCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedShardCountMeta);
    }
    if (data.containsKey('completed_shard_count')) {
      context.handle(
        _completedShardCountMeta,
        completedShardCount.isAcceptableOrUnknown(
          data['completed_shard_count']!,
          _completedShardCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedShardCountMeta);
    }
    if (data.containsKey('source_event_count')) {
      context.handle(
        _sourceEventCountMeta,
        sourceEventCount.isAcceptableOrUnknown(
          data['source_event_count']!,
          _sourceEventCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEventCountMeta);
    }
    if (data.containsKey('output_digest')) {
      context.handle(
        _outputDigestMeta,
        outputDigest.isAcceptableOrUnknown(
          data['output_digest']!,
          _outputDigestMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outputDigestMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('completed_at_ms')) {
      context.handle(
        _completedAtMsMeta,
        completedAtMs.isAcceptableOrUnknown(
          data['completed_at_ms']!,
          _completedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {coverageId};
  @override
  LifeEventCoverageManifestRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventCoverageManifestRow(
      coverageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverage_id'],
      )!,
      coverageSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverage_series_id'],
      )!,
      coverageGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coverage_generation'],
      )!,
      manifestRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manifest_revision'],
      )!,
      servingState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serving_state'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      chartSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chart_snapshot_id'],
      )!,
      chartSnapshotRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chart_snapshot_revision'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      providerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_version'],
      )!,
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm_version'],
      )!,
      dataVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_version'],
      ),
      eventTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type_id'],
      )!,
      eventTypeSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type_schema_version'],
      )!,
      requestedRangeStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_range_start_ms'],
      )!,
      requestedRangeEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_range_end_ms'],
      )!,
      coveredRangesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}covered_ranges_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      inputFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_fingerprint'],
      )!,
      expectedShardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_shard_count'],
      )!,
      completedShardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_shard_count'],
      )!,
      sourceEventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_event_count'],
      )!,
      outputDigest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_digest'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      completedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_ms'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
    );
  }

  @override
  $LifeEventCoverageManifestsTable createAlias(String alias) {
    return $LifeEventCoverageManifestsTable(attachedDatabase, alias);
  }
}

class LifeEventCoverageManifestRow extends DataClass
    implements Insertable<LifeEventCoverageManifestRow> {
  final String coverageId;
  final String coverageSeriesId;
  final int coverageGeneration;
  final int manifestRevision;
  final int servingState;
  final String profileId;
  final String chartSnapshotId;
  final String chartSnapshotRevision;
  final String providerId;
  final String providerVersion;
  final String algorithmVersion;
  final String? dataVersion;
  final String eventTypeId;
  final String eventTypeSchemaVersion;
  final int requestedRangeStartMs;
  final int requestedRangeEndMs;
  final String coveredRangesJson;
  final int status;
  final String inputFingerprint;
  final int expectedShardCount;
  final int completedShardCount;
  final int sourceEventCount;
  final String outputDigest;
  final int startedAtMs;
  final int? completedAtMs;
  final String? lastErrorCode;
  const LifeEventCoverageManifestRow({
    required this.coverageId,
    required this.coverageSeriesId,
    required this.coverageGeneration,
    required this.manifestRevision,
    required this.servingState,
    required this.profileId,
    required this.chartSnapshotId,
    required this.chartSnapshotRevision,
    required this.providerId,
    required this.providerVersion,
    required this.algorithmVersion,
    this.dataVersion,
    required this.eventTypeId,
    required this.eventTypeSchemaVersion,
    required this.requestedRangeStartMs,
    required this.requestedRangeEndMs,
    required this.coveredRangesJson,
    required this.status,
    required this.inputFingerprint,
    required this.expectedShardCount,
    required this.completedShardCount,
    required this.sourceEventCount,
    required this.outputDigest,
    required this.startedAtMs,
    this.completedAtMs,
    this.lastErrorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['coverage_id'] = Variable<String>(coverageId);
    map['coverage_series_id'] = Variable<String>(coverageSeriesId);
    map['coverage_generation'] = Variable<int>(coverageGeneration);
    map['manifest_revision'] = Variable<int>(manifestRevision);
    map['serving_state'] = Variable<int>(servingState);
    map['profile_id'] = Variable<String>(profileId);
    map['chart_snapshot_id'] = Variable<String>(chartSnapshotId);
    map['chart_snapshot_revision'] = Variable<String>(chartSnapshotRevision);
    map['provider_id'] = Variable<String>(providerId);
    map['provider_version'] = Variable<String>(providerVersion);
    map['algorithm_version'] = Variable<String>(algorithmVersion);
    if (!nullToAbsent || dataVersion != null) {
      map['data_version'] = Variable<String>(dataVersion);
    }
    map['event_type_id'] = Variable<String>(eventTypeId);
    map['event_type_schema_version'] = Variable<String>(eventTypeSchemaVersion);
    map['requested_range_start_ms'] = Variable<int>(requestedRangeStartMs);
    map['requested_range_end_ms'] = Variable<int>(requestedRangeEndMs);
    map['covered_ranges_json'] = Variable<String>(coveredRangesJson);
    map['status'] = Variable<int>(status);
    map['input_fingerprint'] = Variable<String>(inputFingerprint);
    map['expected_shard_count'] = Variable<int>(expectedShardCount);
    map['completed_shard_count'] = Variable<int>(completedShardCount);
    map['source_event_count'] = Variable<int>(sourceEventCount);
    map['output_digest'] = Variable<String>(outputDigest);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    if (!nullToAbsent || completedAtMs != null) {
      map['completed_at_ms'] = Variable<int>(completedAtMs);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    return map;
  }

  LifeEventCoverageManifestsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventCoverageManifestsCompanion(
      coverageId: Value(coverageId),
      coverageSeriesId: Value(coverageSeriesId),
      coverageGeneration: Value(coverageGeneration),
      manifestRevision: Value(manifestRevision),
      servingState: Value(servingState),
      profileId: Value(profileId),
      chartSnapshotId: Value(chartSnapshotId),
      chartSnapshotRevision: Value(chartSnapshotRevision),
      providerId: Value(providerId),
      providerVersion: Value(providerVersion),
      algorithmVersion: Value(algorithmVersion),
      dataVersion: dataVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(dataVersion),
      eventTypeId: Value(eventTypeId),
      eventTypeSchemaVersion: Value(eventTypeSchemaVersion),
      requestedRangeStartMs: Value(requestedRangeStartMs),
      requestedRangeEndMs: Value(requestedRangeEndMs),
      coveredRangesJson: Value(coveredRangesJson),
      status: Value(status),
      inputFingerprint: Value(inputFingerprint),
      expectedShardCount: Value(expectedShardCount),
      completedShardCount: Value(completedShardCount),
      sourceEventCount: Value(sourceEventCount),
      outputDigest: Value(outputDigest),
      startedAtMs: Value(startedAtMs),
      completedAtMs: completedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtMs),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
    );
  }

  factory LifeEventCoverageManifestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventCoverageManifestRow(
      coverageId: serializer.fromJson<String>(json['coverageId']),
      coverageSeriesId: serializer.fromJson<String>(json['coverageSeriesId']),
      coverageGeneration: serializer.fromJson<int>(json['coverageGeneration']),
      manifestRevision: serializer.fromJson<int>(json['manifestRevision']),
      servingState: serializer.fromJson<int>(json['servingState']),
      profileId: serializer.fromJson<String>(json['profileId']),
      chartSnapshotId: serializer.fromJson<String>(json['chartSnapshotId']),
      chartSnapshotRevision: serializer.fromJson<String>(
        json['chartSnapshotRevision'],
      ),
      providerId: serializer.fromJson<String>(json['providerId']),
      providerVersion: serializer.fromJson<String>(json['providerVersion']),
      algorithmVersion: serializer.fromJson<String>(json['algorithmVersion']),
      dataVersion: serializer.fromJson<String?>(json['dataVersion']),
      eventTypeId: serializer.fromJson<String>(json['eventTypeId']),
      eventTypeSchemaVersion: serializer.fromJson<String>(
        json['eventTypeSchemaVersion'],
      ),
      requestedRangeStartMs: serializer.fromJson<int>(
        json['requestedRangeStartMs'],
      ),
      requestedRangeEndMs: serializer.fromJson<int>(
        json['requestedRangeEndMs'],
      ),
      coveredRangesJson: serializer.fromJson<String>(json['coveredRangesJson']),
      status: serializer.fromJson<int>(json['status']),
      inputFingerprint: serializer.fromJson<String>(json['inputFingerprint']),
      expectedShardCount: serializer.fromJson<int>(json['expectedShardCount']),
      completedShardCount: serializer.fromJson<int>(
        json['completedShardCount'],
      ),
      sourceEventCount: serializer.fromJson<int>(json['sourceEventCount']),
      outputDigest: serializer.fromJson<String>(json['outputDigest']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      completedAtMs: serializer.fromJson<int?>(json['completedAtMs']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'coverageId': serializer.toJson<String>(coverageId),
      'coverageSeriesId': serializer.toJson<String>(coverageSeriesId),
      'coverageGeneration': serializer.toJson<int>(coverageGeneration),
      'manifestRevision': serializer.toJson<int>(manifestRevision),
      'servingState': serializer.toJson<int>(servingState),
      'profileId': serializer.toJson<String>(profileId),
      'chartSnapshotId': serializer.toJson<String>(chartSnapshotId),
      'chartSnapshotRevision': serializer.toJson<String>(chartSnapshotRevision),
      'providerId': serializer.toJson<String>(providerId),
      'providerVersion': serializer.toJson<String>(providerVersion),
      'algorithmVersion': serializer.toJson<String>(algorithmVersion),
      'dataVersion': serializer.toJson<String?>(dataVersion),
      'eventTypeId': serializer.toJson<String>(eventTypeId),
      'eventTypeSchemaVersion': serializer.toJson<String>(
        eventTypeSchemaVersion,
      ),
      'requestedRangeStartMs': serializer.toJson<int>(requestedRangeStartMs),
      'requestedRangeEndMs': serializer.toJson<int>(requestedRangeEndMs),
      'coveredRangesJson': serializer.toJson<String>(coveredRangesJson),
      'status': serializer.toJson<int>(status),
      'inputFingerprint': serializer.toJson<String>(inputFingerprint),
      'expectedShardCount': serializer.toJson<int>(expectedShardCount),
      'completedShardCount': serializer.toJson<int>(completedShardCount),
      'sourceEventCount': serializer.toJson<int>(sourceEventCount),
      'outputDigest': serializer.toJson<String>(outputDigest),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'completedAtMs': serializer.toJson<int?>(completedAtMs),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
    };
  }

  LifeEventCoverageManifestRow copyWith({
    String? coverageId,
    String? coverageSeriesId,
    int? coverageGeneration,
    int? manifestRevision,
    int? servingState,
    String? profileId,
    String? chartSnapshotId,
    String? chartSnapshotRevision,
    String? providerId,
    String? providerVersion,
    String? algorithmVersion,
    Value<String?> dataVersion = const Value.absent(),
    String? eventTypeId,
    String? eventTypeSchemaVersion,
    int? requestedRangeStartMs,
    int? requestedRangeEndMs,
    String? coveredRangesJson,
    int? status,
    String? inputFingerprint,
    int? expectedShardCount,
    int? completedShardCount,
    int? sourceEventCount,
    String? outputDigest,
    int? startedAtMs,
    Value<int?> completedAtMs = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
  }) => LifeEventCoverageManifestRow(
    coverageId: coverageId ?? this.coverageId,
    coverageSeriesId: coverageSeriesId ?? this.coverageSeriesId,
    coverageGeneration: coverageGeneration ?? this.coverageGeneration,
    manifestRevision: manifestRevision ?? this.manifestRevision,
    servingState: servingState ?? this.servingState,
    profileId: profileId ?? this.profileId,
    chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
    chartSnapshotRevision: chartSnapshotRevision ?? this.chartSnapshotRevision,
    providerId: providerId ?? this.providerId,
    providerVersion: providerVersion ?? this.providerVersion,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    dataVersion: dataVersion.present ? dataVersion.value : this.dataVersion,
    eventTypeId: eventTypeId ?? this.eventTypeId,
    eventTypeSchemaVersion:
        eventTypeSchemaVersion ?? this.eventTypeSchemaVersion,
    requestedRangeStartMs: requestedRangeStartMs ?? this.requestedRangeStartMs,
    requestedRangeEndMs: requestedRangeEndMs ?? this.requestedRangeEndMs,
    coveredRangesJson: coveredRangesJson ?? this.coveredRangesJson,
    status: status ?? this.status,
    inputFingerprint: inputFingerprint ?? this.inputFingerprint,
    expectedShardCount: expectedShardCount ?? this.expectedShardCount,
    completedShardCount: completedShardCount ?? this.completedShardCount,
    sourceEventCount: sourceEventCount ?? this.sourceEventCount,
    outputDigest: outputDigest ?? this.outputDigest,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    completedAtMs: completedAtMs.present
        ? completedAtMs.value
        : this.completedAtMs,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
  );
  LifeEventCoverageManifestRow copyWithCompanion(
    LifeEventCoverageManifestsCompanion data,
  ) {
    return LifeEventCoverageManifestRow(
      coverageId: data.coverageId.present
          ? data.coverageId.value
          : this.coverageId,
      coverageSeriesId: data.coverageSeriesId.present
          ? data.coverageSeriesId.value
          : this.coverageSeriesId,
      coverageGeneration: data.coverageGeneration.present
          ? data.coverageGeneration.value
          : this.coverageGeneration,
      manifestRevision: data.manifestRevision.present
          ? data.manifestRevision.value
          : this.manifestRevision,
      servingState: data.servingState.present
          ? data.servingState.value
          : this.servingState,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      chartSnapshotId: data.chartSnapshotId.present
          ? data.chartSnapshotId.value
          : this.chartSnapshotId,
      chartSnapshotRevision: data.chartSnapshotRevision.present
          ? data.chartSnapshotRevision.value
          : this.chartSnapshotRevision,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      providerVersion: data.providerVersion.present
          ? data.providerVersion.value
          : this.providerVersion,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      dataVersion: data.dataVersion.present
          ? data.dataVersion.value
          : this.dataVersion,
      eventTypeId: data.eventTypeId.present
          ? data.eventTypeId.value
          : this.eventTypeId,
      eventTypeSchemaVersion: data.eventTypeSchemaVersion.present
          ? data.eventTypeSchemaVersion.value
          : this.eventTypeSchemaVersion,
      requestedRangeStartMs: data.requestedRangeStartMs.present
          ? data.requestedRangeStartMs.value
          : this.requestedRangeStartMs,
      requestedRangeEndMs: data.requestedRangeEndMs.present
          ? data.requestedRangeEndMs.value
          : this.requestedRangeEndMs,
      coveredRangesJson: data.coveredRangesJson.present
          ? data.coveredRangesJson.value
          : this.coveredRangesJson,
      status: data.status.present ? data.status.value : this.status,
      inputFingerprint: data.inputFingerprint.present
          ? data.inputFingerprint.value
          : this.inputFingerprint,
      expectedShardCount: data.expectedShardCount.present
          ? data.expectedShardCount.value
          : this.expectedShardCount,
      completedShardCount: data.completedShardCount.present
          ? data.completedShardCount.value
          : this.completedShardCount,
      sourceEventCount: data.sourceEventCount.present
          ? data.sourceEventCount.value
          : this.sourceEventCount,
      outputDigest: data.outputDigest.present
          ? data.outputDigest.value
          : this.outputDigest,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      completedAtMs: data.completedAtMs.present
          ? data.completedAtMs.value
          : this.completedAtMs,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventCoverageManifestRow(')
          ..write('coverageId: $coverageId, ')
          ..write('coverageSeriesId: $coverageSeriesId, ')
          ..write('coverageGeneration: $coverageGeneration, ')
          ..write('manifestRevision: $manifestRevision, ')
          ..write('servingState: $servingState, ')
          ..write('profileId: $profileId, ')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('chartSnapshotRevision: $chartSnapshotRevision, ')
          ..write('providerId: $providerId, ')
          ..write('providerVersion: $providerVersion, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('eventTypeSchemaVersion: $eventTypeSchemaVersion, ')
          ..write('requestedRangeStartMs: $requestedRangeStartMs, ')
          ..write('requestedRangeEndMs: $requestedRangeEndMs, ')
          ..write('coveredRangesJson: $coveredRangesJson, ')
          ..write('status: $status, ')
          ..write('inputFingerprint: $inputFingerprint, ')
          ..write('expectedShardCount: $expectedShardCount, ')
          ..write('completedShardCount: $completedShardCount, ')
          ..write('sourceEventCount: $sourceEventCount, ')
          ..write('outputDigest: $outputDigest, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('lastErrorCode: $lastErrorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    coverageId,
    coverageSeriesId,
    coverageGeneration,
    manifestRevision,
    servingState,
    profileId,
    chartSnapshotId,
    chartSnapshotRevision,
    providerId,
    providerVersion,
    algorithmVersion,
    dataVersion,
    eventTypeId,
    eventTypeSchemaVersion,
    requestedRangeStartMs,
    requestedRangeEndMs,
    coveredRangesJson,
    status,
    inputFingerprint,
    expectedShardCount,
    completedShardCount,
    sourceEventCount,
    outputDigest,
    startedAtMs,
    completedAtMs,
    lastErrorCode,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventCoverageManifestRow &&
          other.coverageId == this.coverageId &&
          other.coverageSeriesId == this.coverageSeriesId &&
          other.coverageGeneration == this.coverageGeneration &&
          other.manifestRevision == this.manifestRevision &&
          other.servingState == this.servingState &&
          other.profileId == this.profileId &&
          other.chartSnapshotId == this.chartSnapshotId &&
          other.chartSnapshotRevision == this.chartSnapshotRevision &&
          other.providerId == this.providerId &&
          other.providerVersion == this.providerVersion &&
          other.algorithmVersion == this.algorithmVersion &&
          other.dataVersion == this.dataVersion &&
          other.eventTypeId == this.eventTypeId &&
          other.eventTypeSchemaVersion == this.eventTypeSchemaVersion &&
          other.requestedRangeStartMs == this.requestedRangeStartMs &&
          other.requestedRangeEndMs == this.requestedRangeEndMs &&
          other.coveredRangesJson == this.coveredRangesJson &&
          other.status == this.status &&
          other.inputFingerprint == this.inputFingerprint &&
          other.expectedShardCount == this.expectedShardCount &&
          other.completedShardCount == this.completedShardCount &&
          other.sourceEventCount == this.sourceEventCount &&
          other.outputDigest == this.outputDigest &&
          other.startedAtMs == this.startedAtMs &&
          other.completedAtMs == this.completedAtMs &&
          other.lastErrorCode == this.lastErrorCode);
}

class LifeEventCoverageManifestsCompanion
    extends UpdateCompanion<LifeEventCoverageManifestRow> {
  final Value<String> coverageId;
  final Value<String> coverageSeriesId;
  final Value<int> coverageGeneration;
  final Value<int> manifestRevision;
  final Value<int> servingState;
  final Value<String> profileId;
  final Value<String> chartSnapshotId;
  final Value<String> chartSnapshotRevision;
  final Value<String> providerId;
  final Value<String> providerVersion;
  final Value<String> algorithmVersion;
  final Value<String?> dataVersion;
  final Value<String> eventTypeId;
  final Value<String> eventTypeSchemaVersion;
  final Value<int> requestedRangeStartMs;
  final Value<int> requestedRangeEndMs;
  final Value<String> coveredRangesJson;
  final Value<int> status;
  final Value<String> inputFingerprint;
  final Value<int> expectedShardCount;
  final Value<int> completedShardCount;
  final Value<int> sourceEventCount;
  final Value<String> outputDigest;
  final Value<int> startedAtMs;
  final Value<int?> completedAtMs;
  final Value<String?> lastErrorCode;
  final Value<int> rowid;
  const LifeEventCoverageManifestsCompanion({
    this.coverageId = const Value.absent(),
    this.coverageSeriesId = const Value.absent(),
    this.coverageGeneration = const Value.absent(),
    this.manifestRevision = const Value.absent(),
    this.servingState = const Value.absent(),
    this.profileId = const Value.absent(),
    this.chartSnapshotId = const Value.absent(),
    this.chartSnapshotRevision = const Value.absent(),
    this.providerId = const Value.absent(),
    this.providerVersion = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.dataVersion = const Value.absent(),
    this.eventTypeId = const Value.absent(),
    this.eventTypeSchemaVersion = const Value.absent(),
    this.requestedRangeStartMs = const Value.absent(),
    this.requestedRangeEndMs = const Value.absent(),
    this.coveredRangesJson = const Value.absent(),
    this.status = const Value.absent(),
    this.inputFingerprint = const Value.absent(),
    this.expectedShardCount = const Value.absent(),
    this.completedShardCount = const Value.absent(),
    this.sourceEventCount = const Value.absent(),
    this.outputDigest = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventCoverageManifestsCompanion.insert({
    required String coverageId,
    required String coverageSeriesId,
    required int coverageGeneration,
    required int manifestRevision,
    required int servingState,
    required String profileId,
    required String chartSnapshotId,
    required String chartSnapshotRevision,
    required String providerId,
    required String providerVersion,
    required String algorithmVersion,
    this.dataVersion = const Value.absent(),
    required String eventTypeId,
    required String eventTypeSchemaVersion,
    required int requestedRangeStartMs,
    required int requestedRangeEndMs,
    required String coveredRangesJson,
    required int status,
    required String inputFingerprint,
    required int expectedShardCount,
    required int completedShardCount,
    required int sourceEventCount,
    required String outputDigest,
    required int startedAtMs,
    this.completedAtMs = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : coverageId = Value(coverageId),
       coverageSeriesId = Value(coverageSeriesId),
       coverageGeneration = Value(coverageGeneration),
       manifestRevision = Value(manifestRevision),
       servingState = Value(servingState),
       profileId = Value(profileId),
       chartSnapshotId = Value(chartSnapshotId),
       chartSnapshotRevision = Value(chartSnapshotRevision),
       providerId = Value(providerId),
       providerVersion = Value(providerVersion),
       algorithmVersion = Value(algorithmVersion),
       eventTypeId = Value(eventTypeId),
       eventTypeSchemaVersion = Value(eventTypeSchemaVersion),
       requestedRangeStartMs = Value(requestedRangeStartMs),
       requestedRangeEndMs = Value(requestedRangeEndMs),
       coveredRangesJson = Value(coveredRangesJson),
       status = Value(status),
       inputFingerprint = Value(inputFingerprint),
       expectedShardCount = Value(expectedShardCount),
       completedShardCount = Value(completedShardCount),
       sourceEventCount = Value(sourceEventCount),
       outputDigest = Value(outputDigest),
       startedAtMs = Value(startedAtMs);
  static Insertable<LifeEventCoverageManifestRow> custom({
    Expression<String>? coverageId,
    Expression<String>? coverageSeriesId,
    Expression<int>? coverageGeneration,
    Expression<int>? manifestRevision,
    Expression<int>? servingState,
    Expression<String>? profileId,
    Expression<String>? chartSnapshotId,
    Expression<String>? chartSnapshotRevision,
    Expression<String>? providerId,
    Expression<String>? providerVersion,
    Expression<String>? algorithmVersion,
    Expression<String>? dataVersion,
    Expression<String>? eventTypeId,
    Expression<String>? eventTypeSchemaVersion,
    Expression<int>? requestedRangeStartMs,
    Expression<int>? requestedRangeEndMs,
    Expression<String>? coveredRangesJson,
    Expression<int>? status,
    Expression<String>? inputFingerprint,
    Expression<int>? expectedShardCount,
    Expression<int>? completedShardCount,
    Expression<int>? sourceEventCount,
    Expression<String>? outputDigest,
    Expression<int>? startedAtMs,
    Expression<int>? completedAtMs,
    Expression<String>? lastErrorCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (coverageId != null) 'coverage_id': coverageId,
      if (coverageSeriesId != null) 'coverage_series_id': coverageSeriesId,
      if (coverageGeneration != null) 'coverage_generation': coverageGeneration,
      if (manifestRevision != null) 'manifest_revision': manifestRevision,
      if (servingState != null) 'serving_state': servingState,
      if (profileId != null) 'profile_id': profileId,
      if (chartSnapshotId != null) 'chart_snapshot_id': chartSnapshotId,
      if (chartSnapshotRevision != null)
        'chart_snapshot_revision': chartSnapshotRevision,
      if (providerId != null) 'provider_id': providerId,
      if (providerVersion != null) 'provider_version': providerVersion,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (dataVersion != null) 'data_version': dataVersion,
      if (eventTypeId != null) 'event_type_id': eventTypeId,
      if (eventTypeSchemaVersion != null)
        'event_type_schema_version': eventTypeSchemaVersion,
      if (requestedRangeStartMs != null)
        'requested_range_start_ms': requestedRangeStartMs,
      if (requestedRangeEndMs != null)
        'requested_range_end_ms': requestedRangeEndMs,
      if (coveredRangesJson != null) 'covered_ranges_json': coveredRangesJson,
      if (status != null) 'status': status,
      if (inputFingerprint != null) 'input_fingerprint': inputFingerprint,
      if (expectedShardCount != null)
        'expected_shard_count': expectedShardCount,
      if (completedShardCount != null)
        'completed_shard_count': completedShardCount,
      if (sourceEventCount != null) 'source_event_count': sourceEventCount,
      if (outputDigest != null) 'output_digest': outputDigest,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (completedAtMs != null) 'completed_at_ms': completedAtMs,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventCoverageManifestsCompanion copyWith({
    Value<String>? coverageId,
    Value<String>? coverageSeriesId,
    Value<int>? coverageGeneration,
    Value<int>? manifestRevision,
    Value<int>? servingState,
    Value<String>? profileId,
    Value<String>? chartSnapshotId,
    Value<String>? chartSnapshotRevision,
    Value<String>? providerId,
    Value<String>? providerVersion,
    Value<String>? algorithmVersion,
    Value<String?>? dataVersion,
    Value<String>? eventTypeId,
    Value<String>? eventTypeSchemaVersion,
    Value<int>? requestedRangeStartMs,
    Value<int>? requestedRangeEndMs,
    Value<String>? coveredRangesJson,
    Value<int>? status,
    Value<String>? inputFingerprint,
    Value<int>? expectedShardCount,
    Value<int>? completedShardCount,
    Value<int>? sourceEventCount,
    Value<String>? outputDigest,
    Value<int>? startedAtMs,
    Value<int?>? completedAtMs,
    Value<String?>? lastErrorCode,
    Value<int>? rowid,
  }) {
    return LifeEventCoverageManifestsCompanion(
      coverageId: coverageId ?? this.coverageId,
      coverageSeriesId: coverageSeriesId ?? this.coverageSeriesId,
      coverageGeneration: coverageGeneration ?? this.coverageGeneration,
      manifestRevision: manifestRevision ?? this.manifestRevision,
      servingState: servingState ?? this.servingState,
      profileId: profileId ?? this.profileId,
      chartSnapshotId: chartSnapshotId ?? this.chartSnapshotId,
      chartSnapshotRevision:
          chartSnapshotRevision ?? this.chartSnapshotRevision,
      providerId: providerId ?? this.providerId,
      providerVersion: providerVersion ?? this.providerVersion,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      dataVersion: dataVersion ?? this.dataVersion,
      eventTypeId: eventTypeId ?? this.eventTypeId,
      eventTypeSchemaVersion:
          eventTypeSchemaVersion ?? this.eventTypeSchemaVersion,
      requestedRangeStartMs:
          requestedRangeStartMs ?? this.requestedRangeStartMs,
      requestedRangeEndMs: requestedRangeEndMs ?? this.requestedRangeEndMs,
      coveredRangesJson: coveredRangesJson ?? this.coveredRangesJson,
      status: status ?? this.status,
      inputFingerprint: inputFingerprint ?? this.inputFingerprint,
      expectedShardCount: expectedShardCount ?? this.expectedShardCount,
      completedShardCount: completedShardCount ?? this.completedShardCount,
      sourceEventCount: sourceEventCount ?? this.sourceEventCount,
      outputDigest: outputDigest ?? this.outputDigest,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coverageId.present) {
      map['coverage_id'] = Variable<String>(coverageId.value);
    }
    if (coverageSeriesId.present) {
      map['coverage_series_id'] = Variable<String>(coverageSeriesId.value);
    }
    if (coverageGeneration.present) {
      map['coverage_generation'] = Variable<int>(coverageGeneration.value);
    }
    if (manifestRevision.present) {
      map['manifest_revision'] = Variable<int>(manifestRevision.value);
    }
    if (servingState.present) {
      map['serving_state'] = Variable<int>(servingState.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (chartSnapshotId.present) {
      map['chart_snapshot_id'] = Variable<String>(chartSnapshotId.value);
    }
    if (chartSnapshotRevision.present) {
      map['chart_snapshot_revision'] = Variable<String>(
        chartSnapshotRevision.value,
      );
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (providerVersion.present) {
      map['provider_version'] = Variable<String>(providerVersion.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<String>(algorithmVersion.value);
    }
    if (dataVersion.present) {
      map['data_version'] = Variable<String>(dataVersion.value);
    }
    if (eventTypeId.present) {
      map['event_type_id'] = Variable<String>(eventTypeId.value);
    }
    if (eventTypeSchemaVersion.present) {
      map['event_type_schema_version'] = Variable<String>(
        eventTypeSchemaVersion.value,
      );
    }
    if (requestedRangeStartMs.present) {
      map['requested_range_start_ms'] = Variable<int>(
        requestedRangeStartMs.value,
      );
    }
    if (requestedRangeEndMs.present) {
      map['requested_range_end_ms'] = Variable<int>(requestedRangeEndMs.value);
    }
    if (coveredRangesJson.present) {
      map['covered_ranges_json'] = Variable<String>(coveredRangesJson.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (inputFingerprint.present) {
      map['input_fingerprint'] = Variable<String>(inputFingerprint.value);
    }
    if (expectedShardCount.present) {
      map['expected_shard_count'] = Variable<int>(expectedShardCount.value);
    }
    if (completedShardCount.present) {
      map['completed_shard_count'] = Variable<int>(completedShardCount.value);
    }
    if (sourceEventCount.present) {
      map['source_event_count'] = Variable<int>(sourceEventCount.value);
    }
    if (outputDigest.present) {
      map['output_digest'] = Variable<String>(outputDigest.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (completedAtMs.present) {
      map['completed_at_ms'] = Variable<int>(completedAtMs.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventCoverageManifestsCompanion(')
          ..write('coverageId: $coverageId, ')
          ..write('coverageSeriesId: $coverageSeriesId, ')
          ..write('coverageGeneration: $coverageGeneration, ')
          ..write('manifestRevision: $manifestRevision, ')
          ..write('servingState: $servingState, ')
          ..write('profileId: $profileId, ')
          ..write('chartSnapshotId: $chartSnapshotId, ')
          ..write('chartSnapshotRevision: $chartSnapshotRevision, ')
          ..write('providerId: $providerId, ')
          ..write('providerVersion: $providerVersion, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('eventTypeSchemaVersion: $eventTypeSchemaVersion, ')
          ..write('requestedRangeStartMs: $requestedRangeStartMs, ')
          ..write('requestedRangeEndMs: $requestedRangeEndMs, ')
          ..write('coveredRangesJson: $coveredRangesJson, ')
          ..write('status: $status, ')
          ..write('inputFingerprint: $inputFingerprint, ')
          ..write('expectedShardCount: $expectedShardCount, ')
          ..write('completedShardCount: $completedShardCount, ')
          ..write('sourceEventCount: $sourceEventCount, ')
          ..write('outputDigest: $outputDigest, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventShardReceiptsTable extends LifeEventShardReceipts
    with TableInfo<$LifeEventShardReceiptsTable, LifeEventShardReceiptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventShardReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _coverageIdMeta = const VerificationMeta(
    'coverageId',
  );
  @override
  late final GeneratedColumn<String> coverageId = GeneratedColumn<String>(
    'coverage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shardIdMeta = const VerificationMeta(
    'shardId',
  );
  @override
  late final GeneratedColumn<String> shardId = GeneratedColumn<String>(
    'shard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverageGenerationMeta =
      const VerificationMeta('coverageGeneration');
  @override
  late final GeneratedColumn<int> coverageGeneration = GeneratedColumn<int>(
    'coverage_generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedRangeStartMsMeta =
      const VerificationMeta('requestedRangeStartMs');
  @override
  late final GeneratedColumn<int> requestedRangeStartMs = GeneratedColumn<int>(
    'requested_range_start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedRangeEndMsMeta =
      const VerificationMeta('requestedRangeEndMs');
  @override
  late final GeneratedColumn<int> requestedRangeEndMs = GeneratedColumn<int>(
    'requested_range_end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coveredRangeStartMsMeta =
      const VerificationMeta('coveredRangeStartMs');
  @override
  late final GeneratedColumn<int> coveredRangeStartMs = GeneratedColumn<int>(
    'covered_range_start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coveredRangeEndMsMeta = const VerificationMeta(
    'coveredRangeEndMs',
  );
  @override
  late final GeneratedColumn<int> coveredRangeEndMs = GeneratedColumn<int>(
    'covered_range_end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventCountMeta = const VerificationMeta(
    'eventCount',
  );
  @override
  late final GeneratedColumn<int> eventCount = GeneratedColumn<int>(
    'event_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentDigestMeta = const VerificationMeta(
    'contentDigest',
  );
  @override
  late final GeneratedColumn<String> contentDigest = GeneratedColumn<String>(
    'content_digest',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _persistedCountMeta = const VerificationMeta(
    'persistedCount',
  );
  @override
  late final GeneratedColumn<int> persistedCount = GeneratedColumn<int>(
    'persisted_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _persistedDigestMeta = const VerificationMeta(
    'persistedDigest',
  );
  @override
  late final GeneratedColumn<String> persistedDigest = GeneratedColumn<String>(
    'persisted_digest',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompleteForCoveredRangeMeta =
      const VerificationMeta('isCompleteForCoveredRange');
  @override
  late final GeneratedColumn<bool> isCompleteForCoveredRange =
      GeneratedColumn<bool>(
        'is_complete_for_covered_range',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_complete_for_covered_range" IN (0, 1))',
        ),
      );
  static const VerificationMeta _inputFingerprintMeta = const VerificationMeta(
    'inputFingerprint',
  );
  @override
  late final GeneratedColumn<String> inputFingerprint = GeneratedColumn<String>(
    'input_fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _committedAtMsMeta = const VerificationMeta(
    'committedAtMs',
  );
  @override
  late final GeneratedColumn<int> committedAtMs = GeneratedColumn<int>(
    'committed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    coverageId,
    shardId,
    coverageGeneration,
    requestedRangeStartMs,
    requestedRangeEndMs,
    coveredRangeStartMs,
    coveredRangeEndMs,
    eventCount,
    contentDigest,
    persistedCount,
    persistedDigest,
    isCompleteForCoveredRange,
    inputFingerprint,
    committedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_life_event_shard_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventShardReceiptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('coverage_id')) {
      context.handle(
        _coverageIdMeta,
        coverageId.isAcceptableOrUnknown(data['coverage_id']!, _coverageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_coverageIdMeta);
    }
    if (data.containsKey('shard_id')) {
      context.handle(
        _shardIdMeta,
        shardId.isAcceptableOrUnknown(data['shard_id']!, _shardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shardIdMeta);
    }
    if (data.containsKey('coverage_generation')) {
      context.handle(
        _coverageGenerationMeta,
        coverageGeneration.isAcceptableOrUnknown(
          data['coverage_generation']!,
          _coverageGenerationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coverageGenerationMeta);
    }
    if (data.containsKey('requested_range_start_ms')) {
      context.handle(
        _requestedRangeStartMsMeta,
        requestedRangeStartMs.isAcceptableOrUnknown(
          data['requested_range_start_ms']!,
          _requestedRangeStartMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedRangeStartMsMeta);
    }
    if (data.containsKey('requested_range_end_ms')) {
      context.handle(
        _requestedRangeEndMsMeta,
        requestedRangeEndMs.isAcceptableOrUnknown(
          data['requested_range_end_ms']!,
          _requestedRangeEndMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedRangeEndMsMeta);
    }
    if (data.containsKey('covered_range_start_ms')) {
      context.handle(
        _coveredRangeStartMsMeta,
        coveredRangeStartMs.isAcceptableOrUnknown(
          data['covered_range_start_ms']!,
          _coveredRangeStartMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coveredRangeStartMsMeta);
    }
    if (data.containsKey('covered_range_end_ms')) {
      context.handle(
        _coveredRangeEndMsMeta,
        coveredRangeEndMs.isAcceptableOrUnknown(
          data['covered_range_end_ms']!,
          _coveredRangeEndMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coveredRangeEndMsMeta);
    }
    if (data.containsKey('event_count')) {
      context.handle(
        _eventCountMeta,
        eventCount.isAcceptableOrUnknown(data['event_count']!, _eventCountMeta),
      );
    } else if (isInserting) {
      context.missing(_eventCountMeta);
    }
    if (data.containsKey('content_digest')) {
      context.handle(
        _contentDigestMeta,
        contentDigest.isAcceptableOrUnknown(
          data['content_digest']!,
          _contentDigestMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentDigestMeta);
    }
    if (data.containsKey('persisted_count')) {
      context.handle(
        _persistedCountMeta,
        persistedCount.isAcceptableOrUnknown(
          data['persisted_count']!,
          _persistedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_persistedCountMeta);
    }
    if (data.containsKey('persisted_digest')) {
      context.handle(
        _persistedDigestMeta,
        persistedDigest.isAcceptableOrUnknown(
          data['persisted_digest']!,
          _persistedDigestMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_persistedDigestMeta);
    }
    if (data.containsKey('is_complete_for_covered_range')) {
      context.handle(
        _isCompleteForCoveredRangeMeta,
        isCompleteForCoveredRange.isAcceptableOrUnknown(
          data['is_complete_for_covered_range']!,
          _isCompleteForCoveredRangeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isCompleteForCoveredRangeMeta);
    }
    if (data.containsKey('input_fingerprint')) {
      context.handle(
        _inputFingerprintMeta,
        inputFingerprint.isAcceptableOrUnknown(
          data['input_fingerprint']!,
          _inputFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputFingerprintMeta);
    }
    if (data.containsKey('committed_at_ms')) {
      context.handle(
        _committedAtMsMeta,
        committedAtMs.isAcceptableOrUnknown(
          data['committed_at_ms']!,
          _committedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_committedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {coverageId, shardId};
  @override
  LifeEventShardReceiptRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventShardReceiptRow(
      coverageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverage_id'],
      )!,
      shardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shard_id'],
      )!,
      coverageGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coverage_generation'],
      )!,
      requestedRangeStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_range_start_ms'],
      )!,
      requestedRangeEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_range_end_ms'],
      )!,
      coveredRangeStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}covered_range_start_ms'],
      )!,
      coveredRangeEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}covered_range_end_ms'],
      )!,
      eventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_count'],
      )!,
      contentDigest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_digest'],
      )!,
      persistedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}persisted_count'],
      )!,
      persistedDigest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persisted_digest'],
      )!,
      isCompleteForCoveredRange: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete_for_covered_range'],
      )!,
      inputFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_fingerprint'],
      )!,
      committedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}committed_at_ms'],
      )!,
    );
  }

  @override
  $LifeEventShardReceiptsTable createAlias(String alias) {
    return $LifeEventShardReceiptsTable(attachedDatabase, alias);
  }
}

class LifeEventShardReceiptRow extends DataClass
    implements Insertable<LifeEventShardReceiptRow> {
  final String coverageId;
  final String shardId;
  final int coverageGeneration;
  final int requestedRangeStartMs;
  final int requestedRangeEndMs;
  final int coveredRangeStartMs;
  final int coveredRangeEndMs;
  final int eventCount;
  final String contentDigest;
  final int persistedCount;
  final String persistedDigest;
  final bool isCompleteForCoveredRange;
  final String inputFingerprint;
  final int committedAtMs;
  const LifeEventShardReceiptRow({
    required this.coverageId,
    required this.shardId,
    required this.coverageGeneration,
    required this.requestedRangeStartMs,
    required this.requestedRangeEndMs,
    required this.coveredRangeStartMs,
    required this.coveredRangeEndMs,
    required this.eventCount,
    required this.contentDigest,
    required this.persistedCount,
    required this.persistedDigest,
    required this.isCompleteForCoveredRange,
    required this.inputFingerprint,
    required this.committedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['coverage_id'] = Variable<String>(coverageId);
    map['shard_id'] = Variable<String>(shardId);
    map['coverage_generation'] = Variable<int>(coverageGeneration);
    map['requested_range_start_ms'] = Variable<int>(requestedRangeStartMs);
    map['requested_range_end_ms'] = Variable<int>(requestedRangeEndMs);
    map['covered_range_start_ms'] = Variable<int>(coveredRangeStartMs);
    map['covered_range_end_ms'] = Variable<int>(coveredRangeEndMs);
    map['event_count'] = Variable<int>(eventCount);
    map['content_digest'] = Variable<String>(contentDigest);
    map['persisted_count'] = Variable<int>(persistedCount);
    map['persisted_digest'] = Variable<String>(persistedDigest);
    map['is_complete_for_covered_range'] = Variable<bool>(
      isCompleteForCoveredRange,
    );
    map['input_fingerprint'] = Variable<String>(inputFingerprint);
    map['committed_at_ms'] = Variable<int>(committedAtMs);
    return map;
  }

  LifeEventShardReceiptsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventShardReceiptsCompanion(
      coverageId: Value(coverageId),
      shardId: Value(shardId),
      coverageGeneration: Value(coverageGeneration),
      requestedRangeStartMs: Value(requestedRangeStartMs),
      requestedRangeEndMs: Value(requestedRangeEndMs),
      coveredRangeStartMs: Value(coveredRangeStartMs),
      coveredRangeEndMs: Value(coveredRangeEndMs),
      eventCount: Value(eventCount),
      contentDigest: Value(contentDigest),
      persistedCount: Value(persistedCount),
      persistedDigest: Value(persistedDigest),
      isCompleteForCoveredRange: Value(isCompleteForCoveredRange),
      inputFingerprint: Value(inputFingerprint),
      committedAtMs: Value(committedAtMs),
    );
  }

  factory LifeEventShardReceiptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventShardReceiptRow(
      coverageId: serializer.fromJson<String>(json['coverageId']),
      shardId: serializer.fromJson<String>(json['shardId']),
      coverageGeneration: serializer.fromJson<int>(json['coverageGeneration']),
      requestedRangeStartMs: serializer.fromJson<int>(
        json['requestedRangeStartMs'],
      ),
      requestedRangeEndMs: serializer.fromJson<int>(
        json['requestedRangeEndMs'],
      ),
      coveredRangeStartMs: serializer.fromJson<int>(
        json['coveredRangeStartMs'],
      ),
      coveredRangeEndMs: serializer.fromJson<int>(json['coveredRangeEndMs']),
      eventCount: serializer.fromJson<int>(json['eventCount']),
      contentDigest: serializer.fromJson<String>(json['contentDigest']),
      persistedCount: serializer.fromJson<int>(json['persistedCount']),
      persistedDigest: serializer.fromJson<String>(json['persistedDigest']),
      isCompleteForCoveredRange: serializer.fromJson<bool>(
        json['isCompleteForCoveredRange'],
      ),
      inputFingerprint: serializer.fromJson<String>(json['inputFingerprint']),
      committedAtMs: serializer.fromJson<int>(json['committedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'coverageId': serializer.toJson<String>(coverageId),
      'shardId': serializer.toJson<String>(shardId),
      'coverageGeneration': serializer.toJson<int>(coverageGeneration),
      'requestedRangeStartMs': serializer.toJson<int>(requestedRangeStartMs),
      'requestedRangeEndMs': serializer.toJson<int>(requestedRangeEndMs),
      'coveredRangeStartMs': serializer.toJson<int>(coveredRangeStartMs),
      'coveredRangeEndMs': serializer.toJson<int>(coveredRangeEndMs),
      'eventCount': serializer.toJson<int>(eventCount),
      'contentDigest': serializer.toJson<String>(contentDigest),
      'persistedCount': serializer.toJson<int>(persistedCount),
      'persistedDigest': serializer.toJson<String>(persistedDigest),
      'isCompleteForCoveredRange': serializer.toJson<bool>(
        isCompleteForCoveredRange,
      ),
      'inputFingerprint': serializer.toJson<String>(inputFingerprint),
      'committedAtMs': serializer.toJson<int>(committedAtMs),
    };
  }

  LifeEventShardReceiptRow copyWith({
    String? coverageId,
    String? shardId,
    int? coverageGeneration,
    int? requestedRangeStartMs,
    int? requestedRangeEndMs,
    int? coveredRangeStartMs,
    int? coveredRangeEndMs,
    int? eventCount,
    String? contentDigest,
    int? persistedCount,
    String? persistedDigest,
    bool? isCompleteForCoveredRange,
    String? inputFingerprint,
    int? committedAtMs,
  }) => LifeEventShardReceiptRow(
    coverageId: coverageId ?? this.coverageId,
    shardId: shardId ?? this.shardId,
    coverageGeneration: coverageGeneration ?? this.coverageGeneration,
    requestedRangeStartMs: requestedRangeStartMs ?? this.requestedRangeStartMs,
    requestedRangeEndMs: requestedRangeEndMs ?? this.requestedRangeEndMs,
    coveredRangeStartMs: coveredRangeStartMs ?? this.coveredRangeStartMs,
    coveredRangeEndMs: coveredRangeEndMs ?? this.coveredRangeEndMs,
    eventCount: eventCount ?? this.eventCount,
    contentDigest: contentDigest ?? this.contentDigest,
    persistedCount: persistedCount ?? this.persistedCount,
    persistedDigest: persistedDigest ?? this.persistedDigest,
    isCompleteForCoveredRange:
        isCompleteForCoveredRange ?? this.isCompleteForCoveredRange,
    inputFingerprint: inputFingerprint ?? this.inputFingerprint,
    committedAtMs: committedAtMs ?? this.committedAtMs,
  );
  LifeEventShardReceiptRow copyWithCompanion(
    LifeEventShardReceiptsCompanion data,
  ) {
    return LifeEventShardReceiptRow(
      coverageId: data.coverageId.present
          ? data.coverageId.value
          : this.coverageId,
      shardId: data.shardId.present ? data.shardId.value : this.shardId,
      coverageGeneration: data.coverageGeneration.present
          ? data.coverageGeneration.value
          : this.coverageGeneration,
      requestedRangeStartMs: data.requestedRangeStartMs.present
          ? data.requestedRangeStartMs.value
          : this.requestedRangeStartMs,
      requestedRangeEndMs: data.requestedRangeEndMs.present
          ? data.requestedRangeEndMs.value
          : this.requestedRangeEndMs,
      coveredRangeStartMs: data.coveredRangeStartMs.present
          ? data.coveredRangeStartMs.value
          : this.coveredRangeStartMs,
      coveredRangeEndMs: data.coveredRangeEndMs.present
          ? data.coveredRangeEndMs.value
          : this.coveredRangeEndMs,
      eventCount: data.eventCount.present
          ? data.eventCount.value
          : this.eventCount,
      contentDigest: data.contentDigest.present
          ? data.contentDigest.value
          : this.contentDigest,
      persistedCount: data.persistedCount.present
          ? data.persistedCount.value
          : this.persistedCount,
      persistedDigest: data.persistedDigest.present
          ? data.persistedDigest.value
          : this.persistedDigest,
      isCompleteForCoveredRange: data.isCompleteForCoveredRange.present
          ? data.isCompleteForCoveredRange.value
          : this.isCompleteForCoveredRange,
      inputFingerprint: data.inputFingerprint.present
          ? data.inputFingerprint.value
          : this.inputFingerprint,
      committedAtMs: data.committedAtMs.present
          ? data.committedAtMs.value
          : this.committedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventShardReceiptRow(')
          ..write('coverageId: $coverageId, ')
          ..write('shardId: $shardId, ')
          ..write('coverageGeneration: $coverageGeneration, ')
          ..write('requestedRangeStartMs: $requestedRangeStartMs, ')
          ..write('requestedRangeEndMs: $requestedRangeEndMs, ')
          ..write('coveredRangeStartMs: $coveredRangeStartMs, ')
          ..write('coveredRangeEndMs: $coveredRangeEndMs, ')
          ..write('eventCount: $eventCount, ')
          ..write('contentDigest: $contentDigest, ')
          ..write('persistedCount: $persistedCount, ')
          ..write('persistedDigest: $persistedDigest, ')
          ..write('isCompleteForCoveredRange: $isCompleteForCoveredRange, ')
          ..write('inputFingerprint: $inputFingerprint, ')
          ..write('committedAtMs: $committedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    coverageId,
    shardId,
    coverageGeneration,
    requestedRangeStartMs,
    requestedRangeEndMs,
    coveredRangeStartMs,
    coveredRangeEndMs,
    eventCount,
    contentDigest,
    persistedCount,
    persistedDigest,
    isCompleteForCoveredRange,
    inputFingerprint,
    committedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventShardReceiptRow &&
          other.coverageId == this.coverageId &&
          other.shardId == this.shardId &&
          other.coverageGeneration == this.coverageGeneration &&
          other.requestedRangeStartMs == this.requestedRangeStartMs &&
          other.requestedRangeEndMs == this.requestedRangeEndMs &&
          other.coveredRangeStartMs == this.coveredRangeStartMs &&
          other.coveredRangeEndMs == this.coveredRangeEndMs &&
          other.eventCount == this.eventCount &&
          other.contentDigest == this.contentDigest &&
          other.persistedCount == this.persistedCount &&
          other.persistedDigest == this.persistedDigest &&
          other.isCompleteForCoveredRange == this.isCompleteForCoveredRange &&
          other.inputFingerprint == this.inputFingerprint &&
          other.committedAtMs == this.committedAtMs);
}

class LifeEventShardReceiptsCompanion
    extends UpdateCompanion<LifeEventShardReceiptRow> {
  final Value<String> coverageId;
  final Value<String> shardId;
  final Value<int> coverageGeneration;
  final Value<int> requestedRangeStartMs;
  final Value<int> requestedRangeEndMs;
  final Value<int> coveredRangeStartMs;
  final Value<int> coveredRangeEndMs;
  final Value<int> eventCount;
  final Value<String> contentDigest;
  final Value<int> persistedCount;
  final Value<String> persistedDigest;
  final Value<bool> isCompleteForCoveredRange;
  final Value<String> inputFingerprint;
  final Value<int> committedAtMs;
  final Value<int> rowid;
  const LifeEventShardReceiptsCompanion({
    this.coverageId = const Value.absent(),
    this.shardId = const Value.absent(),
    this.coverageGeneration = const Value.absent(),
    this.requestedRangeStartMs = const Value.absent(),
    this.requestedRangeEndMs = const Value.absent(),
    this.coveredRangeStartMs = const Value.absent(),
    this.coveredRangeEndMs = const Value.absent(),
    this.eventCount = const Value.absent(),
    this.contentDigest = const Value.absent(),
    this.persistedCount = const Value.absent(),
    this.persistedDigest = const Value.absent(),
    this.isCompleteForCoveredRange = const Value.absent(),
    this.inputFingerprint = const Value.absent(),
    this.committedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventShardReceiptsCompanion.insert({
    required String coverageId,
    required String shardId,
    required int coverageGeneration,
    required int requestedRangeStartMs,
    required int requestedRangeEndMs,
    required int coveredRangeStartMs,
    required int coveredRangeEndMs,
    required int eventCount,
    required String contentDigest,
    required int persistedCount,
    required String persistedDigest,
    required bool isCompleteForCoveredRange,
    required String inputFingerprint,
    required int committedAtMs,
    this.rowid = const Value.absent(),
  }) : coverageId = Value(coverageId),
       shardId = Value(shardId),
       coverageGeneration = Value(coverageGeneration),
       requestedRangeStartMs = Value(requestedRangeStartMs),
       requestedRangeEndMs = Value(requestedRangeEndMs),
       coveredRangeStartMs = Value(coveredRangeStartMs),
       coveredRangeEndMs = Value(coveredRangeEndMs),
       eventCount = Value(eventCount),
       contentDigest = Value(contentDigest),
       persistedCount = Value(persistedCount),
       persistedDigest = Value(persistedDigest),
       isCompleteForCoveredRange = Value(isCompleteForCoveredRange),
       inputFingerprint = Value(inputFingerprint),
       committedAtMs = Value(committedAtMs);
  static Insertable<LifeEventShardReceiptRow> custom({
    Expression<String>? coverageId,
    Expression<String>? shardId,
    Expression<int>? coverageGeneration,
    Expression<int>? requestedRangeStartMs,
    Expression<int>? requestedRangeEndMs,
    Expression<int>? coveredRangeStartMs,
    Expression<int>? coveredRangeEndMs,
    Expression<int>? eventCount,
    Expression<String>? contentDigest,
    Expression<int>? persistedCount,
    Expression<String>? persistedDigest,
    Expression<bool>? isCompleteForCoveredRange,
    Expression<String>? inputFingerprint,
    Expression<int>? committedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (coverageId != null) 'coverage_id': coverageId,
      if (shardId != null) 'shard_id': shardId,
      if (coverageGeneration != null) 'coverage_generation': coverageGeneration,
      if (requestedRangeStartMs != null)
        'requested_range_start_ms': requestedRangeStartMs,
      if (requestedRangeEndMs != null)
        'requested_range_end_ms': requestedRangeEndMs,
      if (coveredRangeStartMs != null)
        'covered_range_start_ms': coveredRangeStartMs,
      if (coveredRangeEndMs != null) 'covered_range_end_ms': coveredRangeEndMs,
      if (eventCount != null) 'event_count': eventCount,
      if (contentDigest != null) 'content_digest': contentDigest,
      if (persistedCount != null) 'persisted_count': persistedCount,
      if (persistedDigest != null) 'persisted_digest': persistedDigest,
      if (isCompleteForCoveredRange != null)
        'is_complete_for_covered_range': isCompleteForCoveredRange,
      if (inputFingerprint != null) 'input_fingerprint': inputFingerprint,
      if (committedAtMs != null) 'committed_at_ms': committedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventShardReceiptsCompanion copyWith({
    Value<String>? coverageId,
    Value<String>? shardId,
    Value<int>? coverageGeneration,
    Value<int>? requestedRangeStartMs,
    Value<int>? requestedRangeEndMs,
    Value<int>? coveredRangeStartMs,
    Value<int>? coveredRangeEndMs,
    Value<int>? eventCount,
    Value<String>? contentDigest,
    Value<int>? persistedCount,
    Value<String>? persistedDigest,
    Value<bool>? isCompleteForCoveredRange,
    Value<String>? inputFingerprint,
    Value<int>? committedAtMs,
    Value<int>? rowid,
  }) {
    return LifeEventShardReceiptsCompanion(
      coverageId: coverageId ?? this.coverageId,
      shardId: shardId ?? this.shardId,
      coverageGeneration: coverageGeneration ?? this.coverageGeneration,
      requestedRangeStartMs:
          requestedRangeStartMs ?? this.requestedRangeStartMs,
      requestedRangeEndMs: requestedRangeEndMs ?? this.requestedRangeEndMs,
      coveredRangeStartMs: coveredRangeStartMs ?? this.coveredRangeStartMs,
      coveredRangeEndMs: coveredRangeEndMs ?? this.coveredRangeEndMs,
      eventCount: eventCount ?? this.eventCount,
      contentDigest: contentDigest ?? this.contentDigest,
      persistedCount: persistedCount ?? this.persistedCount,
      persistedDigest: persistedDigest ?? this.persistedDigest,
      isCompleteForCoveredRange:
          isCompleteForCoveredRange ?? this.isCompleteForCoveredRange,
      inputFingerprint: inputFingerprint ?? this.inputFingerprint,
      committedAtMs: committedAtMs ?? this.committedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coverageId.present) {
      map['coverage_id'] = Variable<String>(coverageId.value);
    }
    if (shardId.present) {
      map['shard_id'] = Variable<String>(shardId.value);
    }
    if (coverageGeneration.present) {
      map['coverage_generation'] = Variable<int>(coverageGeneration.value);
    }
    if (requestedRangeStartMs.present) {
      map['requested_range_start_ms'] = Variable<int>(
        requestedRangeStartMs.value,
      );
    }
    if (requestedRangeEndMs.present) {
      map['requested_range_end_ms'] = Variable<int>(requestedRangeEndMs.value);
    }
    if (coveredRangeStartMs.present) {
      map['covered_range_start_ms'] = Variable<int>(coveredRangeStartMs.value);
    }
    if (coveredRangeEndMs.present) {
      map['covered_range_end_ms'] = Variable<int>(coveredRangeEndMs.value);
    }
    if (eventCount.present) {
      map['event_count'] = Variable<int>(eventCount.value);
    }
    if (contentDigest.present) {
      map['content_digest'] = Variable<String>(contentDigest.value);
    }
    if (persistedCount.present) {
      map['persisted_count'] = Variable<int>(persistedCount.value);
    }
    if (persistedDigest.present) {
      map['persisted_digest'] = Variable<String>(persistedDigest.value);
    }
    if (isCompleteForCoveredRange.present) {
      map['is_complete_for_covered_range'] = Variable<bool>(
        isCompleteForCoveredRange.value,
      );
    }
    if (inputFingerprint.present) {
      map['input_fingerprint'] = Variable<String>(inputFingerprint.value);
    }
    if (committedAtMs.present) {
      map['committed_at_ms'] = Variable<int>(committedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventShardReceiptsCompanion(')
          ..write('coverageId: $coverageId, ')
          ..write('shardId: $shardId, ')
          ..write('coverageGeneration: $coverageGeneration, ')
          ..write('requestedRangeStartMs: $requestedRangeStartMs, ')
          ..write('requestedRangeEndMs: $requestedRangeEndMs, ')
          ..write('coveredRangeStartMs: $coveredRangeStartMs, ')
          ..write('coveredRangeEndMs: $coveredRangeEndMs, ')
          ..write('eventCount: $eventCount, ')
          ..write('contentDigest: $contentDigest, ')
          ..write('persistedCount: $persistedCount, ')
          ..write('persistedDigest: $persistedDigest, ')
          ..write('isCompleteForCoveredRange: $isCompleteForCoveredRange, ')
          ..write('inputFingerprint: $inputFingerprint, ')
          ..write('committedAtMs: $committedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventUserDirectionsTable extends LifeEventUserDirections
    with TableInfo<$LifeEventUserDirectionsTable, LifeEventUserDirectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventUserDirectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _directionIdMeta = const VerificationMeta(
    'directionId',
  );
  @override
  late final GeneratedColumn<String> directionId = GeneratedColumn<String>(
    'direction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMsMeta = const VerificationMeta(
    'archivedAtMs',
  );
  @override
  late final GeneratedColumn<int> archivedAtMs = GeneratedColumn<int>(
    'archived_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    directionId,
    ownerScopeId,
    label,
    color,
    sortOrder,
    archivedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_user_directions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventUserDirectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('direction_id')) {
      context.handle(
        _directionIdMeta,
        directionId.isAcceptableOrUnknown(
          data['direction_id']!,
          _directionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directionIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('archived_at_ms')) {
      context.handle(
        _archivedAtMsMeta,
        archivedAtMs.isAcceptableOrUnknown(
          data['archived_at_ms']!,
          _archivedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {directionId};
  @override
  LifeEventUserDirectionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventUserDirectionRow(
      directionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      archivedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at_ms'],
      ),
    );
  }

  @override
  $LifeEventUserDirectionsTable createAlias(String alias) {
    return $LifeEventUserDirectionsTable(attachedDatabase, alias);
  }
}

class LifeEventUserDirectionRow extends DataClass
    implements Insertable<LifeEventUserDirectionRow> {
  final String directionId;
  final String ownerScopeId;
  final String label;
  final String? color;
  final int sortOrder;
  final int? archivedAtMs;
  const LifeEventUserDirectionRow({
    required this.directionId,
    required this.ownerScopeId,
    required this.label,
    this.color,
    required this.sortOrder,
    this.archivedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['direction_id'] = Variable<String>(directionId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || archivedAtMs != null) {
      map['archived_at_ms'] = Variable<int>(archivedAtMs);
    }
    return map;
  }

  LifeEventUserDirectionsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventUserDirectionsCompanion(
      directionId: Value(directionId),
      ownerScopeId: Value(ownerScopeId),
      label: Value(label),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      sortOrder: Value(sortOrder),
      archivedAtMs: archivedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtMs),
    );
  }

  factory LifeEventUserDirectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventUserDirectionRow(
      directionId: serializer.fromJson<String>(json['directionId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      label: serializer.fromJson<String>(json['label']),
      color: serializer.fromJson<String?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archivedAtMs: serializer.fromJson<int?>(json['archivedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'directionId': serializer.toJson<String>(directionId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'label': serializer.toJson<String>(label),
      'color': serializer.toJson<String?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archivedAtMs': serializer.toJson<int?>(archivedAtMs),
    };
  }

  LifeEventUserDirectionRow copyWith({
    String? directionId,
    String? ownerScopeId,
    String? label,
    Value<String?> color = const Value.absent(),
    int? sortOrder,
    Value<int?> archivedAtMs = const Value.absent(),
  }) => LifeEventUserDirectionRow(
    directionId: directionId ?? this.directionId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    label: label ?? this.label,
    color: color.present ? color.value : this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    archivedAtMs: archivedAtMs.present ? archivedAtMs.value : this.archivedAtMs,
  );
  LifeEventUserDirectionRow copyWithCompanion(
    LifeEventUserDirectionsCompanion data,
  ) {
    return LifeEventUserDirectionRow(
      directionId: data.directionId.present
          ? data.directionId.value
          : this.directionId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      label: data.label.present ? data.label.value : this.label,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archivedAtMs: data.archivedAtMs.present
          ? data.archivedAtMs.value
          : this.archivedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventUserDirectionRow(')
          ..write('directionId: $directionId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archivedAtMs: $archivedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    directionId,
    ownerScopeId,
    label,
    color,
    sortOrder,
    archivedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventUserDirectionRow &&
          other.directionId == this.directionId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.label == this.label &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.archivedAtMs == this.archivedAtMs);
}

class LifeEventUserDirectionsCompanion
    extends UpdateCompanion<LifeEventUserDirectionRow> {
  final Value<String> directionId;
  final Value<String> ownerScopeId;
  final Value<String> label;
  final Value<String?> color;
  final Value<int> sortOrder;
  final Value<int?> archivedAtMs;
  final Value<int> rowid;
  const LifeEventUserDirectionsCompanion({
    this.directionId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.label = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archivedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventUserDirectionsCompanion.insert({
    required String directionId,
    required String ownerScopeId,
    required String label,
    this.color = const Value.absent(),
    required int sortOrder,
    this.archivedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : directionId = Value(directionId),
       ownerScopeId = Value(ownerScopeId),
       label = Value(label),
       sortOrder = Value(sortOrder);
  static Insertable<LifeEventUserDirectionRow> custom({
    Expression<String>? directionId,
    Expression<String>? ownerScopeId,
    Expression<String>? label,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<int>? archivedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (directionId != null) 'direction_id': directionId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (label != null) 'label': label,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archivedAtMs != null) 'archived_at_ms': archivedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventUserDirectionsCompanion copyWith({
    Value<String>? directionId,
    Value<String>? ownerScopeId,
    Value<String>? label,
    Value<String?>? color,
    Value<int>? sortOrder,
    Value<int?>? archivedAtMs,
    Value<int>? rowid,
  }) {
    return LifeEventUserDirectionsCompanion(
      directionId: directionId ?? this.directionId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      label: label ?? this.label,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      archivedAtMs: archivedAtMs ?? this.archivedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (directionId.present) {
      map['direction_id'] = Variable<String>(directionId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (archivedAtMs.present) {
      map['archived_at_ms'] = Variable<int>(archivedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventUserDirectionsCompanion(')
          ..write('directionId: $directionId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archivedAtMs: $archivedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventUserAnnotationsTable extends LifeEventUserAnnotations
    with TableInfo<$LifeEventUserAnnotationsTable, LifeEventUserAnnotationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventUserAnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _annotationIdMeta = const VerificationMeta(
    'annotationId',
  );
  @override
  late final GeneratedColumn<String> annotationId = GeneratedColumn<String>(
    'annotation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interpretationMeta = const VerificationMeta(
    'interpretation',
  );
  @override
  late final GeneratedColumn<String> interpretation = GeneratedColumn<String>(
    'interpretation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importanceOwnerScopeIdMeta =
      const VerificationMeta('importanceOwnerScopeId');
  @override
  late final GeneratedColumn<String> importanceOwnerScopeId =
      GeneratedColumn<String>(
        'importance_owner_scope_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importanceCatalogIdMeta =
      const VerificationMeta('importanceCatalogId');
  @override
  late final GeneratedColumn<String> importanceCatalogId =
      GeneratedColumn<String>(
        'importance_catalog_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importanceCatalogRevisionMeta =
      const VerificationMeta('importanceCatalogRevision');
  @override
  late final GeneratedColumn<int> importanceCatalogRevision =
      GeneratedColumn<int>(
        'importance_catalog_revision',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importanceLevelIdMeta = const VerificationMeta(
    'importanceLevelId',
  );
  @override
  late final GeneratedColumn<String> importanceLevelId =
      GeneratedColumn<String>(
        'importance_level_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    annotationId,
    ownerScopeId,
    title,
    interpretation,
    importanceOwnerScopeId,
    importanceCatalogId,
    importanceCatalogRevision,
    importanceLevelId,
    tagsJson,
    revision,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_user_annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventUserAnnotationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('annotation_id')) {
      context.handle(
        _annotationIdMeta,
        annotationId.isAcceptableOrUnknown(
          data['annotation_id']!,
          _annotationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annotationIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('interpretation')) {
      context.handle(
        _interpretationMeta,
        interpretation.isAcceptableOrUnknown(
          data['interpretation']!,
          _interpretationMeta,
        ),
      );
    }
    if (data.containsKey('importance_owner_scope_id')) {
      context.handle(
        _importanceOwnerScopeIdMeta,
        importanceOwnerScopeId.isAcceptableOrUnknown(
          data['importance_owner_scope_id']!,
          _importanceOwnerScopeIdMeta,
        ),
      );
    }
    if (data.containsKey('importance_catalog_id')) {
      context.handle(
        _importanceCatalogIdMeta,
        importanceCatalogId.isAcceptableOrUnknown(
          data['importance_catalog_id']!,
          _importanceCatalogIdMeta,
        ),
      );
    }
    if (data.containsKey('importance_catalog_revision')) {
      context.handle(
        _importanceCatalogRevisionMeta,
        importanceCatalogRevision.isAcceptableOrUnknown(
          data['importance_catalog_revision']!,
          _importanceCatalogRevisionMeta,
        ),
      );
    }
    if (data.containsKey('importance_level_id')) {
      context.handle(
        _importanceLevelIdMeta,
        importanceLevelId.isAcceptableOrUnknown(
          data['importance_level_id']!,
          _importanceLevelIdMeta,
        ),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {annotationId};
  @override
  LifeEventUserAnnotationRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventUserAnnotationRow(
      annotationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}annotation_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      interpretation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interpretation'],
      ),
      importanceOwnerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance_owner_scope_id'],
      ),
      importanceCatalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance_catalog_id'],
      ),
      importanceCatalogRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}importance_catalog_revision'],
      ),
      importanceLevelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance_level_id'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $LifeEventUserAnnotationsTable createAlias(String alias) {
    return $LifeEventUserAnnotationsTable(attachedDatabase, alias);
  }
}

class LifeEventUserAnnotationRow extends DataClass
    implements Insertable<LifeEventUserAnnotationRow> {
  final String annotationId;
  final String ownerScopeId;
  final String? title;
  final String? interpretation;
  final String? importanceOwnerScopeId;
  final String? importanceCatalogId;
  final int? importanceCatalogRevision;
  final String? importanceLevelId;
  final String tagsJson;
  final int revision;
  final int createdAtMs;
  final int updatedAtMs;
  const LifeEventUserAnnotationRow({
    required this.annotationId,
    required this.ownerScopeId,
    this.title,
    this.interpretation,
    this.importanceOwnerScopeId,
    this.importanceCatalogId,
    this.importanceCatalogRevision,
    this.importanceLevelId,
    required this.tagsJson,
    required this.revision,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['annotation_id'] = Variable<String>(annotationId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || interpretation != null) {
      map['interpretation'] = Variable<String>(interpretation);
    }
    if (!nullToAbsent || importanceOwnerScopeId != null) {
      map['importance_owner_scope_id'] = Variable<String>(
        importanceOwnerScopeId,
      );
    }
    if (!nullToAbsent || importanceCatalogId != null) {
      map['importance_catalog_id'] = Variable<String>(importanceCatalogId);
    }
    if (!nullToAbsent || importanceCatalogRevision != null) {
      map['importance_catalog_revision'] = Variable<int>(
        importanceCatalogRevision,
      );
    }
    if (!nullToAbsent || importanceLevelId != null) {
      map['importance_level_id'] = Variable<String>(importanceLevelId);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    map['revision'] = Variable<int>(revision);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  LifeEventUserAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventUserAnnotationsCompanion(
      annotationId: Value(annotationId),
      ownerScopeId: Value(ownerScopeId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      interpretation: interpretation == null && nullToAbsent
          ? const Value.absent()
          : Value(interpretation),
      importanceOwnerScopeId: importanceOwnerScopeId == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceOwnerScopeId),
      importanceCatalogId: importanceCatalogId == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceCatalogId),
      importanceCatalogRevision:
          importanceCatalogRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceCatalogRevision),
      importanceLevelId: importanceLevelId == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceLevelId),
      tagsJson: Value(tagsJson),
      revision: Value(revision),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory LifeEventUserAnnotationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventUserAnnotationRow(
      annotationId: serializer.fromJson<String>(json['annotationId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      title: serializer.fromJson<String?>(json['title']),
      interpretation: serializer.fromJson<String?>(json['interpretation']),
      importanceOwnerScopeId: serializer.fromJson<String?>(
        json['importanceOwnerScopeId'],
      ),
      importanceCatalogId: serializer.fromJson<String?>(
        json['importanceCatalogId'],
      ),
      importanceCatalogRevision: serializer.fromJson<int?>(
        json['importanceCatalogRevision'],
      ),
      importanceLevelId: serializer.fromJson<String?>(
        json['importanceLevelId'],
      ),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'annotationId': serializer.toJson<String>(annotationId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'title': serializer.toJson<String?>(title),
      'interpretation': serializer.toJson<String?>(interpretation),
      'importanceOwnerScopeId': serializer.toJson<String?>(
        importanceOwnerScopeId,
      ),
      'importanceCatalogId': serializer.toJson<String?>(importanceCatalogId),
      'importanceCatalogRevision': serializer.toJson<int?>(
        importanceCatalogRevision,
      ),
      'importanceLevelId': serializer.toJson<String?>(importanceLevelId),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'revision': serializer.toJson<int>(revision),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  LifeEventUserAnnotationRow copyWith({
    String? annotationId,
    String? ownerScopeId,
    Value<String?> title = const Value.absent(),
    Value<String?> interpretation = const Value.absent(),
    Value<String?> importanceOwnerScopeId = const Value.absent(),
    Value<String?> importanceCatalogId = const Value.absent(),
    Value<int?> importanceCatalogRevision = const Value.absent(),
    Value<String?> importanceLevelId = const Value.absent(),
    String? tagsJson,
    int? revision,
    int? createdAtMs,
    int? updatedAtMs,
  }) => LifeEventUserAnnotationRow(
    annotationId: annotationId ?? this.annotationId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    title: title.present ? title.value : this.title,
    interpretation: interpretation.present
        ? interpretation.value
        : this.interpretation,
    importanceOwnerScopeId: importanceOwnerScopeId.present
        ? importanceOwnerScopeId.value
        : this.importanceOwnerScopeId,
    importanceCatalogId: importanceCatalogId.present
        ? importanceCatalogId.value
        : this.importanceCatalogId,
    importanceCatalogRevision: importanceCatalogRevision.present
        ? importanceCatalogRevision.value
        : this.importanceCatalogRevision,
    importanceLevelId: importanceLevelId.present
        ? importanceLevelId.value
        : this.importanceLevelId,
    tagsJson: tagsJson ?? this.tagsJson,
    revision: revision ?? this.revision,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  LifeEventUserAnnotationRow copyWithCompanion(
    LifeEventUserAnnotationsCompanion data,
  ) {
    return LifeEventUserAnnotationRow(
      annotationId: data.annotationId.present
          ? data.annotationId.value
          : this.annotationId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      title: data.title.present ? data.title.value : this.title,
      interpretation: data.interpretation.present
          ? data.interpretation.value
          : this.interpretation,
      importanceOwnerScopeId: data.importanceOwnerScopeId.present
          ? data.importanceOwnerScopeId.value
          : this.importanceOwnerScopeId,
      importanceCatalogId: data.importanceCatalogId.present
          ? data.importanceCatalogId.value
          : this.importanceCatalogId,
      importanceCatalogRevision: data.importanceCatalogRevision.present
          ? data.importanceCatalogRevision.value
          : this.importanceCatalogRevision,
      importanceLevelId: data.importanceLevelId.present
          ? data.importanceLevelId.value
          : this.importanceLevelId,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventUserAnnotationRow(')
          ..write('annotationId: $annotationId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('title: $title, ')
          ..write('interpretation: $interpretation, ')
          ..write('importanceOwnerScopeId: $importanceOwnerScopeId, ')
          ..write('importanceCatalogId: $importanceCatalogId, ')
          ..write('importanceCatalogRevision: $importanceCatalogRevision, ')
          ..write('importanceLevelId: $importanceLevelId, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('revision: $revision, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    annotationId,
    ownerScopeId,
    title,
    interpretation,
    importanceOwnerScopeId,
    importanceCatalogId,
    importanceCatalogRevision,
    importanceLevelId,
    tagsJson,
    revision,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventUserAnnotationRow &&
          other.annotationId == this.annotationId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.title == this.title &&
          other.interpretation == this.interpretation &&
          other.importanceOwnerScopeId == this.importanceOwnerScopeId &&
          other.importanceCatalogId == this.importanceCatalogId &&
          other.importanceCatalogRevision == this.importanceCatalogRevision &&
          other.importanceLevelId == this.importanceLevelId &&
          other.tagsJson == this.tagsJson &&
          other.revision == this.revision &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class LifeEventUserAnnotationsCompanion
    extends UpdateCompanion<LifeEventUserAnnotationRow> {
  final Value<String> annotationId;
  final Value<String> ownerScopeId;
  final Value<String?> title;
  final Value<String?> interpretation;
  final Value<String?> importanceOwnerScopeId;
  final Value<String?> importanceCatalogId;
  final Value<int?> importanceCatalogRevision;
  final Value<String?> importanceLevelId;
  final Value<String> tagsJson;
  final Value<int> revision;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const LifeEventUserAnnotationsCompanion({
    this.annotationId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.title = const Value.absent(),
    this.interpretation = const Value.absent(),
    this.importanceOwnerScopeId = const Value.absent(),
    this.importanceCatalogId = const Value.absent(),
    this.importanceCatalogRevision = const Value.absent(),
    this.importanceLevelId = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventUserAnnotationsCompanion.insert({
    required String annotationId,
    required String ownerScopeId,
    this.title = const Value.absent(),
    this.interpretation = const Value.absent(),
    this.importanceOwnerScopeId = const Value.absent(),
    this.importanceCatalogId = const Value.absent(),
    this.importanceCatalogRevision = const Value.absent(),
    this.importanceLevelId = const Value.absent(),
    this.tagsJson = const Value.absent(),
    required int revision,
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : annotationId = Value(annotationId),
       ownerScopeId = Value(ownerScopeId),
       revision = Value(revision),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LifeEventUserAnnotationRow> custom({
    Expression<String>? annotationId,
    Expression<String>? ownerScopeId,
    Expression<String>? title,
    Expression<String>? interpretation,
    Expression<String>? importanceOwnerScopeId,
    Expression<String>? importanceCatalogId,
    Expression<int>? importanceCatalogRevision,
    Expression<String>? importanceLevelId,
    Expression<String>? tagsJson,
    Expression<int>? revision,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (annotationId != null) 'annotation_id': annotationId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (title != null) 'title': title,
      if (interpretation != null) 'interpretation': interpretation,
      if (importanceOwnerScopeId != null)
        'importance_owner_scope_id': importanceOwnerScopeId,
      if (importanceCatalogId != null)
        'importance_catalog_id': importanceCatalogId,
      if (importanceCatalogRevision != null)
        'importance_catalog_revision': importanceCatalogRevision,
      if (importanceLevelId != null) 'importance_level_id': importanceLevelId,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (revision != null) 'revision': revision,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventUserAnnotationsCompanion copyWith({
    Value<String>? annotationId,
    Value<String>? ownerScopeId,
    Value<String?>? title,
    Value<String?>? interpretation,
    Value<String?>? importanceOwnerScopeId,
    Value<String?>? importanceCatalogId,
    Value<int?>? importanceCatalogRevision,
    Value<String?>? importanceLevelId,
    Value<String>? tagsJson,
    Value<int>? revision,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return LifeEventUserAnnotationsCompanion(
      annotationId: annotationId ?? this.annotationId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      title: title ?? this.title,
      interpretation: interpretation ?? this.interpretation,
      importanceOwnerScopeId:
          importanceOwnerScopeId ?? this.importanceOwnerScopeId,
      importanceCatalogId: importanceCatalogId ?? this.importanceCatalogId,
      importanceCatalogRevision:
          importanceCatalogRevision ?? this.importanceCatalogRevision,
      importanceLevelId: importanceLevelId ?? this.importanceLevelId,
      tagsJson: tagsJson ?? this.tagsJson,
      revision: revision ?? this.revision,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (annotationId.present) {
      map['annotation_id'] = Variable<String>(annotationId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (interpretation.present) {
      map['interpretation'] = Variable<String>(interpretation.value);
    }
    if (importanceOwnerScopeId.present) {
      map['importance_owner_scope_id'] = Variable<String>(
        importanceOwnerScopeId.value,
      );
    }
    if (importanceCatalogId.present) {
      map['importance_catalog_id'] = Variable<String>(
        importanceCatalogId.value,
      );
    }
    if (importanceCatalogRevision.present) {
      map['importance_catalog_revision'] = Variable<int>(
        importanceCatalogRevision.value,
      );
    }
    if (importanceLevelId.present) {
      map['importance_level_id'] = Variable<String>(importanceLevelId.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventUserAnnotationsCompanion(')
          ..write('annotationId: $annotationId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('title: $title, ')
          ..write('interpretation: $interpretation, ')
          ..write('importanceOwnerScopeId: $importanceOwnerScopeId, ')
          ..write('importanceCatalogId: $importanceCatalogId, ')
          ..write('importanceCatalogRevision: $importanceCatalogRevision, ')
          ..write('importanceLevelId: $importanceLevelId, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('revision: $revision, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventAnnotationTargetRefsTable extends LifeEventAnnotationTargetRefs
    with
        TableInfo<
          $LifeEventAnnotationTargetRefsTable,
          LifeEventAnnotationTargetRefRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventAnnotationTargetRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _annotationIdMeta = const VerificationMeta(
    'annotationId',
  );
  @override
  late final GeneratedColumn<String> annotationId = GeneratedColumn<String>(
    'annotation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceEventIdMeta = const VerificationMeta(
    'sourceEventId',
  );
  @override
  late final GeneratedColumn<String> sourceEventId = GeneratedColumn<String>(
    'source_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventRevisionMeta = const VerificationMeta(
    'eventRevision',
  );
  @override
  late final GeneratedColumn<String> eventRevision = GeneratedColumn<String>(
    'event_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    annotationId,
    providerId,
    sourceEventId,
    eventRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_annotation_target_refs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventAnnotationTargetRefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('annotation_id')) {
      context.handle(
        _annotationIdMeta,
        annotationId.isAcceptableOrUnknown(
          data['annotation_id']!,
          _annotationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annotationIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('source_event_id')) {
      context.handle(
        _sourceEventIdMeta,
        sourceEventId.isAcceptableOrUnknown(
          data['source_event_id']!,
          _sourceEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEventIdMeta);
    }
    if (data.containsKey('event_revision')) {
      context.handle(
        _eventRevisionMeta,
        eventRevision.isAcceptableOrUnknown(
          data['event_revision']!,
          _eventRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventRevisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    annotationId,
    providerId,
    sourceEventId,
  };
  @override
  LifeEventAnnotationTargetRefRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventAnnotationTargetRefRow(
      annotationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}annotation_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      sourceEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_event_id'],
      )!,
      eventRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_revision'],
      )!,
    );
  }

  @override
  $LifeEventAnnotationTargetRefsTable createAlias(String alias) {
    return $LifeEventAnnotationTargetRefsTable(attachedDatabase, alias);
  }
}

class LifeEventAnnotationTargetRefRow extends DataClass
    implements Insertable<LifeEventAnnotationTargetRefRow> {
  final String annotationId;
  final String providerId;
  final String sourceEventId;
  final String eventRevision;
  const LifeEventAnnotationTargetRefRow({
    required this.annotationId,
    required this.providerId,
    required this.sourceEventId,
    required this.eventRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['annotation_id'] = Variable<String>(annotationId);
    map['provider_id'] = Variable<String>(providerId);
    map['source_event_id'] = Variable<String>(sourceEventId);
    map['event_revision'] = Variable<String>(eventRevision);
    return map;
  }

  LifeEventAnnotationTargetRefsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventAnnotationTargetRefsCompanion(
      annotationId: Value(annotationId),
      providerId: Value(providerId),
      sourceEventId: Value(sourceEventId),
      eventRevision: Value(eventRevision),
    );
  }

  factory LifeEventAnnotationTargetRefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventAnnotationTargetRefRow(
      annotationId: serializer.fromJson<String>(json['annotationId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      sourceEventId: serializer.fromJson<String>(json['sourceEventId']),
      eventRevision: serializer.fromJson<String>(json['eventRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'annotationId': serializer.toJson<String>(annotationId),
      'providerId': serializer.toJson<String>(providerId),
      'sourceEventId': serializer.toJson<String>(sourceEventId),
      'eventRevision': serializer.toJson<String>(eventRevision),
    };
  }

  LifeEventAnnotationTargetRefRow copyWith({
    String? annotationId,
    String? providerId,
    String? sourceEventId,
    String? eventRevision,
  }) => LifeEventAnnotationTargetRefRow(
    annotationId: annotationId ?? this.annotationId,
    providerId: providerId ?? this.providerId,
    sourceEventId: sourceEventId ?? this.sourceEventId,
    eventRevision: eventRevision ?? this.eventRevision,
  );
  LifeEventAnnotationTargetRefRow copyWithCompanion(
    LifeEventAnnotationTargetRefsCompanion data,
  ) {
    return LifeEventAnnotationTargetRefRow(
      annotationId: data.annotationId.present
          ? data.annotationId.value
          : this.annotationId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      sourceEventId: data.sourceEventId.present
          ? data.sourceEventId.value
          : this.sourceEventId,
      eventRevision: data.eventRevision.present
          ? data.eventRevision.value
          : this.eventRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventAnnotationTargetRefRow(')
          ..write('annotationId: $annotationId, ')
          ..write('providerId: $providerId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('eventRevision: $eventRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(annotationId, providerId, sourceEventId, eventRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventAnnotationTargetRefRow &&
          other.annotationId == this.annotationId &&
          other.providerId == this.providerId &&
          other.sourceEventId == this.sourceEventId &&
          other.eventRevision == this.eventRevision);
}

class LifeEventAnnotationTargetRefsCompanion
    extends UpdateCompanion<LifeEventAnnotationTargetRefRow> {
  final Value<String> annotationId;
  final Value<String> providerId;
  final Value<String> sourceEventId;
  final Value<String> eventRevision;
  final Value<int> rowid;
  const LifeEventAnnotationTargetRefsCompanion({
    this.annotationId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.sourceEventId = const Value.absent(),
    this.eventRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventAnnotationTargetRefsCompanion.insert({
    required String annotationId,
    required String providerId,
    required String sourceEventId,
    required String eventRevision,
    this.rowid = const Value.absent(),
  }) : annotationId = Value(annotationId),
       providerId = Value(providerId),
       sourceEventId = Value(sourceEventId),
       eventRevision = Value(eventRevision);
  static Insertable<LifeEventAnnotationTargetRefRow> custom({
    Expression<String>? annotationId,
    Expression<String>? providerId,
    Expression<String>? sourceEventId,
    Expression<String>? eventRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (annotationId != null) 'annotation_id': annotationId,
      if (providerId != null) 'provider_id': providerId,
      if (sourceEventId != null) 'source_event_id': sourceEventId,
      if (eventRevision != null) 'event_revision': eventRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventAnnotationTargetRefsCompanion copyWith({
    Value<String>? annotationId,
    Value<String>? providerId,
    Value<String>? sourceEventId,
    Value<String>? eventRevision,
    Value<int>? rowid,
  }) {
    return LifeEventAnnotationTargetRefsCompanion(
      annotationId: annotationId ?? this.annotationId,
      providerId: providerId ?? this.providerId,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      eventRevision: eventRevision ?? this.eventRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (annotationId.present) {
      map['annotation_id'] = Variable<String>(annotationId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (sourceEventId.present) {
      map['source_event_id'] = Variable<String>(sourceEventId.value);
    }
    if (eventRevision.present) {
      map['event_revision'] = Variable<String>(eventRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventAnnotationTargetRefsCompanion(')
          ..write('annotationId: $annotationId, ')
          ..write('providerId: $providerId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('eventRevision: $eventRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventAnnotationDirectionRefsTable
    extends LifeEventAnnotationDirectionRefs
    with
        TableInfo<
          $LifeEventAnnotationDirectionRefsTable,
          LifeEventAnnotationDirectionRefRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventAnnotationDirectionRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _annotationIdMeta = const VerificationMeta(
    'annotationId',
  );
  @override
  late final GeneratedColumn<String> annotationId = GeneratedColumn<String>(
    'annotation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionIdMeta = const VerificationMeta(
    'directionId',
  );
  @override
  late final GeneratedColumn<String> directionId = GeneratedColumn<String>(
    'direction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [annotationId, directionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_annotation_direction_refs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventAnnotationDirectionRefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('annotation_id')) {
      context.handle(
        _annotationIdMeta,
        annotationId.isAcceptableOrUnknown(
          data['annotation_id']!,
          _annotationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annotationIdMeta);
    }
    if (data.containsKey('direction_id')) {
      context.handle(
        _directionIdMeta,
        directionId.isAcceptableOrUnknown(
          data['direction_id']!,
          _directionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {annotationId, directionId};
  @override
  LifeEventAnnotationDirectionRefRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventAnnotationDirectionRefRow(
      annotationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}annotation_id'],
      )!,
      directionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction_id'],
      )!,
    );
  }

  @override
  $LifeEventAnnotationDirectionRefsTable createAlias(String alias) {
    return $LifeEventAnnotationDirectionRefsTable(attachedDatabase, alias);
  }
}

class LifeEventAnnotationDirectionRefRow extends DataClass
    implements Insertable<LifeEventAnnotationDirectionRefRow> {
  final String annotationId;
  final String directionId;
  const LifeEventAnnotationDirectionRefRow({
    required this.annotationId,
    required this.directionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['annotation_id'] = Variable<String>(annotationId);
    map['direction_id'] = Variable<String>(directionId);
    return map;
  }

  LifeEventAnnotationDirectionRefsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventAnnotationDirectionRefsCompanion(
      annotationId: Value(annotationId),
      directionId: Value(directionId),
    );
  }

  factory LifeEventAnnotationDirectionRefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventAnnotationDirectionRefRow(
      annotationId: serializer.fromJson<String>(json['annotationId']),
      directionId: serializer.fromJson<String>(json['directionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'annotationId': serializer.toJson<String>(annotationId),
      'directionId': serializer.toJson<String>(directionId),
    };
  }

  LifeEventAnnotationDirectionRefRow copyWith({
    String? annotationId,
    String? directionId,
  }) => LifeEventAnnotationDirectionRefRow(
    annotationId: annotationId ?? this.annotationId,
    directionId: directionId ?? this.directionId,
  );
  LifeEventAnnotationDirectionRefRow copyWithCompanion(
    LifeEventAnnotationDirectionRefsCompanion data,
  ) {
    return LifeEventAnnotationDirectionRefRow(
      annotationId: data.annotationId.present
          ? data.annotationId.value
          : this.annotationId,
      directionId: data.directionId.present
          ? data.directionId.value
          : this.directionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventAnnotationDirectionRefRow(')
          ..write('annotationId: $annotationId, ')
          ..write('directionId: $directionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(annotationId, directionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventAnnotationDirectionRefRow &&
          other.annotationId == this.annotationId &&
          other.directionId == this.directionId);
}

class LifeEventAnnotationDirectionRefsCompanion
    extends UpdateCompanion<LifeEventAnnotationDirectionRefRow> {
  final Value<String> annotationId;
  final Value<String> directionId;
  final Value<int> rowid;
  const LifeEventAnnotationDirectionRefsCompanion({
    this.annotationId = const Value.absent(),
    this.directionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventAnnotationDirectionRefsCompanion.insert({
    required String annotationId,
    required String directionId,
    this.rowid = const Value.absent(),
  }) : annotationId = Value(annotationId),
       directionId = Value(directionId);
  static Insertable<LifeEventAnnotationDirectionRefRow> custom({
    Expression<String>? annotationId,
    Expression<String>? directionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (annotationId != null) 'annotation_id': annotationId,
      if (directionId != null) 'direction_id': directionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventAnnotationDirectionRefsCompanion copyWith({
    Value<String>? annotationId,
    Value<String>? directionId,
    Value<int>? rowid,
  }) {
    return LifeEventAnnotationDirectionRefsCompanion(
      annotationId: annotationId ?? this.annotationId,
      directionId: directionId ?? this.directionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (annotationId.present) {
      map['annotation_id'] = Variable<String>(annotationId.value);
    }
    if (directionId.present) {
      map['direction_id'] = Variable<String>(directionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventAnnotationDirectionRefsCompanion(')
          ..write('annotationId: $annotationId, ')
          ..write('directionId: $directionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventOccurrenceSelectionsTable extends LifeEventOccurrenceSelections
    with
        TableInfo<
          $LifeEventOccurrenceSelectionsTable,
          LifeEventOccurrenceSelectionRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventOccurrenceSelectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _selectionIdMeta = const VerificationMeta(
    'selectionId',
  );
  @override
  late final GeneratedColumn<String> selectionId = GeneratedColumn<String>(
    'selection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceProviderIdMeta = const VerificationMeta(
    'sourceProviderId',
  );
  @override
  late final GeneratedColumn<String> sourceProviderId = GeneratedColumn<String>(
    'source_provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceEventIdMeta = const VerificationMeta(
    'sourceEventId',
  );
  @override
  late final GeneratedColumn<String> sourceEventId = GeneratedColumn<String>(
    'source_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceEventRevisionMeta =
      const VerificationMeta('sourceEventRevision');
  @override
  late final GeneratedColumn<String> sourceEventRevision =
      GeneratedColumn<String>(
        'source_event_revision',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eventRevisionMeta = const VerificationMeta(
    'eventRevision',
  );
  @override
  late final GeneratedColumn<String> eventRevision = GeneratedColumn<String>(
    'event_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annotationRefMeta = const VerificationMeta(
    'annotationRef',
  );
  @override
  late final GeneratedColumn<String> annotationRef = GeneratedColumn<String>(
    'annotation_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    selectionId,
    ownerScopeId,
    revision,
    sourceProviderId,
    sourceEventId,
    sourceEventRevision,
    eventRevision,
    annotationRef,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_occurrence_selections';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventOccurrenceSelectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('selection_id')) {
      context.handle(
        _selectionIdMeta,
        selectionId.isAcceptableOrUnknown(
          data['selection_id']!,
          _selectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectionIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('source_provider_id')) {
      context.handle(
        _sourceProviderIdMeta,
        sourceProviderId.isAcceptableOrUnknown(
          data['source_provider_id']!,
          _sourceProviderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceProviderIdMeta);
    }
    if (data.containsKey('source_event_id')) {
      context.handle(
        _sourceEventIdMeta,
        sourceEventId.isAcceptableOrUnknown(
          data['source_event_id']!,
          _sourceEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEventIdMeta);
    }
    if (data.containsKey('source_event_revision')) {
      context.handle(
        _sourceEventRevisionMeta,
        sourceEventRevision.isAcceptableOrUnknown(
          data['source_event_revision']!,
          _sourceEventRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEventRevisionMeta);
    }
    if (data.containsKey('event_revision')) {
      context.handle(
        _eventRevisionMeta,
        eventRevision.isAcceptableOrUnknown(
          data['event_revision']!,
          _eventRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventRevisionMeta);
    }
    if (data.containsKey('annotation_ref')) {
      context.handle(
        _annotationRefMeta,
        annotationRef.isAcceptableOrUnknown(
          data['annotation_ref']!,
          _annotationRefMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {selectionId};
  @override
  LifeEventOccurrenceSelectionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventOccurrenceSelectionRow(
      selectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selection_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      sourceProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_provider_id'],
      )!,
      sourceEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_event_id'],
      )!,
      sourceEventRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_event_revision'],
      )!,
      eventRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_revision'],
      )!,
      annotationRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}annotation_ref'],
      ),
    );
  }

  @override
  $LifeEventOccurrenceSelectionsTable createAlias(String alias) {
    return $LifeEventOccurrenceSelectionsTable(attachedDatabase, alias);
  }
}

class LifeEventOccurrenceSelectionRow extends DataClass
    implements Insertable<LifeEventOccurrenceSelectionRow> {
  final String selectionId;
  final String ownerScopeId;
  final int revision;
  final String sourceProviderId;
  final String sourceEventId;
  final String sourceEventRevision;
  final String eventRevision;
  final String? annotationRef;
  const LifeEventOccurrenceSelectionRow({
    required this.selectionId,
    required this.ownerScopeId,
    required this.revision,
    required this.sourceProviderId,
    required this.sourceEventId,
    required this.sourceEventRevision,
    required this.eventRevision,
    this.annotationRef,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['selection_id'] = Variable<String>(selectionId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    map['revision'] = Variable<int>(revision);
    map['source_provider_id'] = Variable<String>(sourceProviderId);
    map['source_event_id'] = Variable<String>(sourceEventId);
    map['source_event_revision'] = Variable<String>(sourceEventRevision);
    map['event_revision'] = Variable<String>(eventRevision);
    if (!nullToAbsent || annotationRef != null) {
      map['annotation_ref'] = Variable<String>(annotationRef);
    }
    return map;
  }

  LifeEventOccurrenceSelectionsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventOccurrenceSelectionsCompanion(
      selectionId: Value(selectionId),
      ownerScopeId: Value(ownerScopeId),
      revision: Value(revision),
      sourceProviderId: Value(sourceProviderId),
      sourceEventId: Value(sourceEventId),
      sourceEventRevision: Value(sourceEventRevision),
      eventRevision: Value(eventRevision),
      annotationRef: annotationRef == null && nullToAbsent
          ? const Value.absent()
          : Value(annotationRef),
    );
  }

  factory LifeEventOccurrenceSelectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventOccurrenceSelectionRow(
      selectionId: serializer.fromJson<String>(json['selectionId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      revision: serializer.fromJson<int>(json['revision']),
      sourceProviderId: serializer.fromJson<String>(json['sourceProviderId']),
      sourceEventId: serializer.fromJson<String>(json['sourceEventId']),
      sourceEventRevision: serializer.fromJson<String>(
        json['sourceEventRevision'],
      ),
      eventRevision: serializer.fromJson<String>(json['eventRevision']),
      annotationRef: serializer.fromJson<String?>(json['annotationRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'selectionId': serializer.toJson<String>(selectionId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'revision': serializer.toJson<int>(revision),
      'sourceProviderId': serializer.toJson<String>(sourceProviderId),
      'sourceEventId': serializer.toJson<String>(sourceEventId),
      'sourceEventRevision': serializer.toJson<String>(sourceEventRevision),
      'eventRevision': serializer.toJson<String>(eventRevision),
      'annotationRef': serializer.toJson<String?>(annotationRef),
    };
  }

  LifeEventOccurrenceSelectionRow copyWith({
    String? selectionId,
    String? ownerScopeId,
    int? revision,
    String? sourceProviderId,
    String? sourceEventId,
    String? sourceEventRevision,
    String? eventRevision,
    Value<String?> annotationRef = const Value.absent(),
  }) => LifeEventOccurrenceSelectionRow(
    selectionId: selectionId ?? this.selectionId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    revision: revision ?? this.revision,
    sourceProviderId: sourceProviderId ?? this.sourceProviderId,
    sourceEventId: sourceEventId ?? this.sourceEventId,
    sourceEventRevision: sourceEventRevision ?? this.sourceEventRevision,
    eventRevision: eventRevision ?? this.eventRevision,
    annotationRef: annotationRef.present
        ? annotationRef.value
        : this.annotationRef,
  );
  LifeEventOccurrenceSelectionRow copyWithCompanion(
    LifeEventOccurrenceSelectionsCompanion data,
  ) {
    return LifeEventOccurrenceSelectionRow(
      selectionId: data.selectionId.present
          ? data.selectionId.value
          : this.selectionId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      revision: data.revision.present ? data.revision.value : this.revision,
      sourceProviderId: data.sourceProviderId.present
          ? data.sourceProviderId.value
          : this.sourceProviderId,
      sourceEventId: data.sourceEventId.present
          ? data.sourceEventId.value
          : this.sourceEventId,
      sourceEventRevision: data.sourceEventRevision.present
          ? data.sourceEventRevision.value
          : this.sourceEventRevision,
      eventRevision: data.eventRevision.present
          ? data.eventRevision.value
          : this.eventRevision,
      annotationRef: data.annotationRef.present
          ? data.annotationRef.value
          : this.annotationRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventOccurrenceSelectionRow(')
          ..write('selectionId: $selectionId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('revision: $revision, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('sourceEventRevision: $sourceEventRevision, ')
          ..write('eventRevision: $eventRevision, ')
          ..write('annotationRef: $annotationRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    selectionId,
    ownerScopeId,
    revision,
    sourceProviderId,
    sourceEventId,
    sourceEventRevision,
    eventRevision,
    annotationRef,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventOccurrenceSelectionRow &&
          other.selectionId == this.selectionId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.revision == this.revision &&
          other.sourceProviderId == this.sourceProviderId &&
          other.sourceEventId == this.sourceEventId &&
          other.sourceEventRevision == this.sourceEventRevision &&
          other.eventRevision == this.eventRevision &&
          other.annotationRef == this.annotationRef);
}

class LifeEventOccurrenceSelectionsCompanion
    extends UpdateCompanion<LifeEventOccurrenceSelectionRow> {
  final Value<String> selectionId;
  final Value<String> ownerScopeId;
  final Value<int> revision;
  final Value<String> sourceProviderId;
  final Value<String> sourceEventId;
  final Value<String> sourceEventRevision;
  final Value<String> eventRevision;
  final Value<String?> annotationRef;
  final Value<int> rowid;
  const LifeEventOccurrenceSelectionsCompanion({
    this.selectionId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.revision = const Value.absent(),
    this.sourceProviderId = const Value.absent(),
    this.sourceEventId = const Value.absent(),
    this.sourceEventRevision = const Value.absent(),
    this.eventRevision = const Value.absent(),
    this.annotationRef = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventOccurrenceSelectionsCompanion.insert({
    required String selectionId,
    required String ownerScopeId,
    required int revision,
    required String sourceProviderId,
    required String sourceEventId,
    required String sourceEventRevision,
    required String eventRevision,
    this.annotationRef = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : selectionId = Value(selectionId),
       ownerScopeId = Value(ownerScopeId),
       revision = Value(revision),
       sourceProviderId = Value(sourceProviderId),
       sourceEventId = Value(sourceEventId),
       sourceEventRevision = Value(sourceEventRevision),
       eventRevision = Value(eventRevision);
  static Insertable<LifeEventOccurrenceSelectionRow> custom({
    Expression<String>? selectionId,
    Expression<String>? ownerScopeId,
    Expression<int>? revision,
    Expression<String>? sourceProviderId,
    Expression<String>? sourceEventId,
    Expression<String>? sourceEventRevision,
    Expression<String>? eventRevision,
    Expression<String>? annotationRef,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (selectionId != null) 'selection_id': selectionId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (revision != null) 'revision': revision,
      if (sourceProviderId != null) 'source_provider_id': sourceProviderId,
      if (sourceEventId != null) 'source_event_id': sourceEventId,
      if (sourceEventRevision != null)
        'source_event_revision': sourceEventRevision,
      if (eventRevision != null) 'event_revision': eventRevision,
      if (annotationRef != null) 'annotation_ref': annotationRef,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventOccurrenceSelectionsCompanion copyWith({
    Value<String>? selectionId,
    Value<String>? ownerScopeId,
    Value<int>? revision,
    Value<String>? sourceProviderId,
    Value<String>? sourceEventId,
    Value<String>? sourceEventRevision,
    Value<String>? eventRevision,
    Value<String?>? annotationRef,
    Value<int>? rowid,
  }) {
    return LifeEventOccurrenceSelectionsCompanion(
      selectionId: selectionId ?? this.selectionId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      revision: revision ?? this.revision,
      sourceProviderId: sourceProviderId ?? this.sourceProviderId,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      sourceEventRevision: sourceEventRevision ?? this.sourceEventRevision,
      eventRevision: eventRevision ?? this.eventRevision,
      annotationRef: annotationRef ?? this.annotationRef,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (selectionId.present) {
      map['selection_id'] = Variable<String>(selectionId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (sourceProviderId.present) {
      map['source_provider_id'] = Variable<String>(sourceProviderId.value);
    }
    if (sourceEventId.present) {
      map['source_event_id'] = Variable<String>(sourceEventId.value);
    }
    if (sourceEventRevision.present) {
      map['source_event_revision'] = Variable<String>(
        sourceEventRevision.value,
      );
    }
    if (eventRevision.present) {
      map['event_revision'] = Variable<String>(eventRevision.value);
    }
    if (annotationRef.present) {
      map['annotation_ref'] = Variable<String>(annotationRef.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventOccurrenceSelectionsCompanion(')
          ..write('selectionId: $selectionId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('revision: $revision, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('sourceEventRevision: $sourceEventRevision, ')
          ..write('eventRevision: $eventRevision, ')
          ..write('annotationRef: $annotationRef, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventPatternRulesTable extends LifeEventPatternRules
    with TableInfo<$LifeEventPatternRulesTable, LifeEventPatternRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventPatternRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _savedPatternIdMeta = const VerificationMeta(
    'savedPatternId',
  );
  @override
  late final GeneratedColumn<String> savedPatternId = GeneratedColumn<String>(
    'saved_pattern_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeIdMeta = const VerificationMeta(
    'eventTypeId',
  );
  @override
  late final GeneratedColumn<String> eventTypeId = GeneratedColumn<String>(
    'event_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternSchemaVersionMeta =
      const VerificationMeta('patternSchemaVersion');
  @override
  late final GeneratedColumn<String> patternSchemaVersion =
      GeneratedColumn<String>(
        'pattern_schema_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _providerDescriptorVersionMeta =
      const VerificationMeta('providerDescriptorVersion');
  @override
  late final GeneratedColumn<String> providerDescriptorVersion =
      GeneratedColumn<String>(
        'provider_descriptor_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _matcherSemanticVersionMeta =
      const VerificationMeta('matcherSemanticVersion');
  @override
  late final GeneratedColumn<String> matcherSemanticVersion =
      GeneratedColumn<String>(
        'matcher_semantic_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _normalizedPatternJsonMeta =
      const VerificationMeta('normalizedPatternJson');
  @override
  late final GeneratedColumn<String> normalizedPatternJson =
      GeneratedColumn<String>(
        'normalized_pattern_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _patternFingerprintMeta =
      const VerificationMeta('patternFingerprint');
  @override
  late final GeneratedColumn<String> patternFingerprint =
      GeneratedColumn<String>(
        'pattern_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _annotationRefMeta = const VerificationMeta(
    'annotationRef',
  );
  @override
  late final GeneratedColumn<String> annotationRef = GeneratedColumn<String>(
    'annotation_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledForMatchingMeta =
      const VerificationMeta('enabledForMatching');
  @override
  late final GeneratedColumn<bool> enabledForMatching = GeneratedColumn<bool>(
    'enabled_for_matching',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled_for_matching" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    savedPatternId,
    ownerScopeId,
    revision,
    providerId,
    eventTypeId,
    patternSchemaVersion,
    providerDescriptorVersion,
    matcherSemanticVersion,
    normalizedPatternJson,
    patternFingerprint,
    annotationRef,
    enabledForMatching,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_pattern_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventPatternRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('saved_pattern_id')) {
      context.handle(
        _savedPatternIdMeta,
        savedPatternId.isAcceptableOrUnknown(
          data['saved_pattern_id']!,
          _savedPatternIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedPatternIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('event_type_id')) {
      context.handle(
        _eventTypeIdMeta,
        eventTypeId.isAcceptableOrUnknown(
          data['event_type_id']!,
          _eventTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTypeIdMeta);
    }
    if (data.containsKey('pattern_schema_version')) {
      context.handle(
        _patternSchemaVersionMeta,
        patternSchemaVersion.isAcceptableOrUnknown(
          data['pattern_schema_version']!,
          _patternSchemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternSchemaVersionMeta);
    }
    if (data.containsKey('provider_descriptor_version')) {
      context.handle(
        _providerDescriptorVersionMeta,
        providerDescriptorVersion.isAcceptableOrUnknown(
          data['provider_descriptor_version']!,
          _providerDescriptorVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerDescriptorVersionMeta);
    }
    if (data.containsKey('matcher_semantic_version')) {
      context.handle(
        _matcherSemanticVersionMeta,
        matcherSemanticVersion.isAcceptableOrUnknown(
          data['matcher_semantic_version']!,
          _matcherSemanticVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_matcherSemanticVersionMeta);
    }
    if (data.containsKey('normalized_pattern_json')) {
      context.handle(
        _normalizedPatternJsonMeta,
        normalizedPatternJson.isAcceptableOrUnknown(
          data['normalized_pattern_json']!,
          _normalizedPatternJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedPatternJsonMeta);
    }
    if (data.containsKey('pattern_fingerprint')) {
      context.handle(
        _patternFingerprintMeta,
        patternFingerprint.isAcceptableOrUnknown(
          data['pattern_fingerprint']!,
          _patternFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternFingerprintMeta);
    }
    if (data.containsKey('annotation_ref')) {
      context.handle(
        _annotationRefMeta,
        annotationRef.isAcceptableOrUnknown(
          data['annotation_ref']!,
          _annotationRefMeta,
        ),
      );
    }
    if (data.containsKey('enabled_for_matching')) {
      context.handle(
        _enabledForMatchingMeta,
        enabledForMatching.isAcceptableOrUnknown(
          data['enabled_for_matching']!,
          _enabledForMatchingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enabledForMatchingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {savedPatternId};
  @override
  LifeEventPatternRuleRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventPatternRuleRow(
      savedPatternId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_pattern_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      eventTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type_id'],
      )!,
      patternSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_schema_version'],
      )!,
      providerDescriptorVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_descriptor_version'],
      )!,
      matcherSemanticVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matcher_semantic_version'],
      )!,
      normalizedPatternJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_pattern_json'],
      )!,
      patternFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_fingerprint'],
      )!,
      annotationRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}annotation_ref'],
      ),
      enabledForMatching: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled_for_matching'],
      )!,
    );
  }

  @override
  $LifeEventPatternRulesTable createAlias(String alias) {
    return $LifeEventPatternRulesTable(attachedDatabase, alias);
  }
}

class LifeEventPatternRuleRow extends DataClass
    implements Insertable<LifeEventPatternRuleRow> {
  final String savedPatternId;
  final String ownerScopeId;
  final int revision;
  final String providerId;
  final String eventTypeId;
  final String patternSchemaVersion;
  final String providerDescriptorVersion;
  final String matcherSemanticVersion;
  final String normalizedPatternJson;
  final String patternFingerprint;
  final String? annotationRef;
  final bool enabledForMatching;
  const LifeEventPatternRuleRow({
    required this.savedPatternId,
    required this.ownerScopeId,
    required this.revision,
    required this.providerId,
    required this.eventTypeId,
    required this.patternSchemaVersion,
    required this.providerDescriptorVersion,
    required this.matcherSemanticVersion,
    required this.normalizedPatternJson,
    required this.patternFingerprint,
    this.annotationRef,
    required this.enabledForMatching,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['saved_pattern_id'] = Variable<String>(savedPatternId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    map['revision'] = Variable<int>(revision);
    map['provider_id'] = Variable<String>(providerId);
    map['event_type_id'] = Variable<String>(eventTypeId);
    map['pattern_schema_version'] = Variable<String>(patternSchemaVersion);
    map['provider_descriptor_version'] = Variable<String>(
      providerDescriptorVersion,
    );
    map['matcher_semantic_version'] = Variable<String>(matcherSemanticVersion);
    map['normalized_pattern_json'] = Variable<String>(normalizedPatternJson);
    map['pattern_fingerprint'] = Variable<String>(patternFingerprint);
    if (!nullToAbsent || annotationRef != null) {
      map['annotation_ref'] = Variable<String>(annotationRef);
    }
    map['enabled_for_matching'] = Variable<bool>(enabledForMatching);
    return map;
  }

  LifeEventPatternRulesCompanion toCompanion(bool nullToAbsent) {
    return LifeEventPatternRulesCompanion(
      savedPatternId: Value(savedPatternId),
      ownerScopeId: Value(ownerScopeId),
      revision: Value(revision),
      providerId: Value(providerId),
      eventTypeId: Value(eventTypeId),
      patternSchemaVersion: Value(patternSchemaVersion),
      providerDescriptorVersion: Value(providerDescriptorVersion),
      matcherSemanticVersion: Value(matcherSemanticVersion),
      normalizedPatternJson: Value(normalizedPatternJson),
      patternFingerprint: Value(patternFingerprint),
      annotationRef: annotationRef == null && nullToAbsent
          ? const Value.absent()
          : Value(annotationRef),
      enabledForMatching: Value(enabledForMatching),
    );
  }

  factory LifeEventPatternRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventPatternRuleRow(
      savedPatternId: serializer.fromJson<String>(json['savedPatternId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      revision: serializer.fromJson<int>(json['revision']),
      providerId: serializer.fromJson<String>(json['providerId']),
      eventTypeId: serializer.fromJson<String>(json['eventTypeId']),
      patternSchemaVersion: serializer.fromJson<String>(
        json['patternSchemaVersion'],
      ),
      providerDescriptorVersion: serializer.fromJson<String>(
        json['providerDescriptorVersion'],
      ),
      matcherSemanticVersion: serializer.fromJson<String>(
        json['matcherSemanticVersion'],
      ),
      normalizedPatternJson: serializer.fromJson<String>(
        json['normalizedPatternJson'],
      ),
      patternFingerprint: serializer.fromJson<String>(
        json['patternFingerprint'],
      ),
      annotationRef: serializer.fromJson<String?>(json['annotationRef']),
      enabledForMatching: serializer.fromJson<bool>(json['enabledForMatching']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'savedPatternId': serializer.toJson<String>(savedPatternId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'revision': serializer.toJson<int>(revision),
      'providerId': serializer.toJson<String>(providerId),
      'eventTypeId': serializer.toJson<String>(eventTypeId),
      'patternSchemaVersion': serializer.toJson<String>(patternSchemaVersion),
      'providerDescriptorVersion': serializer.toJson<String>(
        providerDescriptorVersion,
      ),
      'matcherSemanticVersion': serializer.toJson<String>(
        matcherSemanticVersion,
      ),
      'normalizedPatternJson': serializer.toJson<String>(normalizedPatternJson),
      'patternFingerprint': serializer.toJson<String>(patternFingerprint),
      'annotationRef': serializer.toJson<String?>(annotationRef),
      'enabledForMatching': serializer.toJson<bool>(enabledForMatching),
    };
  }

  LifeEventPatternRuleRow copyWith({
    String? savedPatternId,
    String? ownerScopeId,
    int? revision,
    String? providerId,
    String? eventTypeId,
    String? patternSchemaVersion,
    String? providerDescriptorVersion,
    String? matcherSemanticVersion,
    String? normalizedPatternJson,
    String? patternFingerprint,
    Value<String?> annotationRef = const Value.absent(),
    bool? enabledForMatching,
  }) => LifeEventPatternRuleRow(
    savedPatternId: savedPatternId ?? this.savedPatternId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    revision: revision ?? this.revision,
    providerId: providerId ?? this.providerId,
    eventTypeId: eventTypeId ?? this.eventTypeId,
    patternSchemaVersion: patternSchemaVersion ?? this.patternSchemaVersion,
    providerDescriptorVersion:
        providerDescriptorVersion ?? this.providerDescriptorVersion,
    matcherSemanticVersion:
        matcherSemanticVersion ?? this.matcherSemanticVersion,
    normalizedPatternJson: normalizedPatternJson ?? this.normalizedPatternJson,
    patternFingerprint: patternFingerprint ?? this.patternFingerprint,
    annotationRef: annotationRef.present
        ? annotationRef.value
        : this.annotationRef,
    enabledForMatching: enabledForMatching ?? this.enabledForMatching,
  );
  LifeEventPatternRuleRow copyWithCompanion(
    LifeEventPatternRulesCompanion data,
  ) {
    return LifeEventPatternRuleRow(
      savedPatternId: data.savedPatternId.present
          ? data.savedPatternId.value
          : this.savedPatternId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      revision: data.revision.present ? data.revision.value : this.revision,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      eventTypeId: data.eventTypeId.present
          ? data.eventTypeId.value
          : this.eventTypeId,
      patternSchemaVersion: data.patternSchemaVersion.present
          ? data.patternSchemaVersion.value
          : this.patternSchemaVersion,
      providerDescriptorVersion: data.providerDescriptorVersion.present
          ? data.providerDescriptorVersion.value
          : this.providerDescriptorVersion,
      matcherSemanticVersion: data.matcherSemanticVersion.present
          ? data.matcherSemanticVersion.value
          : this.matcherSemanticVersion,
      normalizedPatternJson: data.normalizedPatternJson.present
          ? data.normalizedPatternJson.value
          : this.normalizedPatternJson,
      patternFingerprint: data.patternFingerprint.present
          ? data.patternFingerprint.value
          : this.patternFingerprint,
      annotationRef: data.annotationRef.present
          ? data.annotationRef.value
          : this.annotationRef,
      enabledForMatching: data.enabledForMatching.present
          ? data.enabledForMatching.value
          : this.enabledForMatching,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventPatternRuleRow(')
          ..write('savedPatternId: $savedPatternId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('revision: $revision, ')
          ..write('providerId: $providerId, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('patternSchemaVersion: $patternSchemaVersion, ')
          ..write('providerDescriptorVersion: $providerDescriptorVersion, ')
          ..write('matcherSemanticVersion: $matcherSemanticVersion, ')
          ..write('normalizedPatternJson: $normalizedPatternJson, ')
          ..write('patternFingerprint: $patternFingerprint, ')
          ..write('annotationRef: $annotationRef, ')
          ..write('enabledForMatching: $enabledForMatching')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    savedPatternId,
    ownerScopeId,
    revision,
    providerId,
    eventTypeId,
    patternSchemaVersion,
    providerDescriptorVersion,
    matcherSemanticVersion,
    normalizedPatternJson,
    patternFingerprint,
    annotationRef,
    enabledForMatching,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventPatternRuleRow &&
          other.savedPatternId == this.savedPatternId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.revision == this.revision &&
          other.providerId == this.providerId &&
          other.eventTypeId == this.eventTypeId &&
          other.patternSchemaVersion == this.patternSchemaVersion &&
          other.providerDescriptorVersion == this.providerDescriptorVersion &&
          other.matcherSemanticVersion == this.matcherSemanticVersion &&
          other.normalizedPatternJson == this.normalizedPatternJson &&
          other.patternFingerprint == this.patternFingerprint &&
          other.annotationRef == this.annotationRef &&
          other.enabledForMatching == this.enabledForMatching);
}

class LifeEventPatternRulesCompanion
    extends UpdateCompanion<LifeEventPatternRuleRow> {
  final Value<String> savedPatternId;
  final Value<String> ownerScopeId;
  final Value<int> revision;
  final Value<String> providerId;
  final Value<String> eventTypeId;
  final Value<String> patternSchemaVersion;
  final Value<String> providerDescriptorVersion;
  final Value<String> matcherSemanticVersion;
  final Value<String> normalizedPatternJson;
  final Value<String> patternFingerprint;
  final Value<String?> annotationRef;
  final Value<bool> enabledForMatching;
  final Value<int> rowid;
  const LifeEventPatternRulesCompanion({
    this.savedPatternId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.revision = const Value.absent(),
    this.providerId = const Value.absent(),
    this.eventTypeId = const Value.absent(),
    this.patternSchemaVersion = const Value.absent(),
    this.providerDescriptorVersion = const Value.absent(),
    this.matcherSemanticVersion = const Value.absent(),
    this.normalizedPatternJson = const Value.absent(),
    this.patternFingerprint = const Value.absent(),
    this.annotationRef = const Value.absent(),
    this.enabledForMatching = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventPatternRulesCompanion.insert({
    required String savedPatternId,
    required String ownerScopeId,
    required int revision,
    required String providerId,
    required String eventTypeId,
    required String patternSchemaVersion,
    required String providerDescriptorVersion,
    required String matcherSemanticVersion,
    required String normalizedPatternJson,
    required String patternFingerprint,
    this.annotationRef = const Value.absent(),
    required bool enabledForMatching,
    this.rowid = const Value.absent(),
  }) : savedPatternId = Value(savedPatternId),
       ownerScopeId = Value(ownerScopeId),
       revision = Value(revision),
       providerId = Value(providerId),
       eventTypeId = Value(eventTypeId),
       patternSchemaVersion = Value(patternSchemaVersion),
       providerDescriptorVersion = Value(providerDescriptorVersion),
       matcherSemanticVersion = Value(matcherSemanticVersion),
       normalizedPatternJson = Value(normalizedPatternJson),
       patternFingerprint = Value(patternFingerprint),
       enabledForMatching = Value(enabledForMatching);
  static Insertable<LifeEventPatternRuleRow> custom({
    Expression<String>? savedPatternId,
    Expression<String>? ownerScopeId,
    Expression<int>? revision,
    Expression<String>? providerId,
    Expression<String>? eventTypeId,
    Expression<String>? patternSchemaVersion,
    Expression<String>? providerDescriptorVersion,
    Expression<String>? matcherSemanticVersion,
    Expression<String>? normalizedPatternJson,
    Expression<String>? patternFingerprint,
    Expression<String>? annotationRef,
    Expression<bool>? enabledForMatching,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (savedPatternId != null) 'saved_pattern_id': savedPatternId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (revision != null) 'revision': revision,
      if (providerId != null) 'provider_id': providerId,
      if (eventTypeId != null) 'event_type_id': eventTypeId,
      if (patternSchemaVersion != null)
        'pattern_schema_version': patternSchemaVersion,
      if (providerDescriptorVersion != null)
        'provider_descriptor_version': providerDescriptorVersion,
      if (matcherSemanticVersion != null)
        'matcher_semantic_version': matcherSemanticVersion,
      if (normalizedPatternJson != null)
        'normalized_pattern_json': normalizedPatternJson,
      if (patternFingerprint != null) 'pattern_fingerprint': patternFingerprint,
      if (annotationRef != null) 'annotation_ref': annotationRef,
      if (enabledForMatching != null)
        'enabled_for_matching': enabledForMatching,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventPatternRulesCompanion copyWith({
    Value<String>? savedPatternId,
    Value<String>? ownerScopeId,
    Value<int>? revision,
    Value<String>? providerId,
    Value<String>? eventTypeId,
    Value<String>? patternSchemaVersion,
    Value<String>? providerDescriptorVersion,
    Value<String>? matcherSemanticVersion,
    Value<String>? normalizedPatternJson,
    Value<String>? patternFingerprint,
    Value<String?>? annotationRef,
    Value<bool>? enabledForMatching,
    Value<int>? rowid,
  }) {
    return LifeEventPatternRulesCompanion(
      savedPatternId: savedPatternId ?? this.savedPatternId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      revision: revision ?? this.revision,
      providerId: providerId ?? this.providerId,
      eventTypeId: eventTypeId ?? this.eventTypeId,
      patternSchemaVersion: patternSchemaVersion ?? this.patternSchemaVersion,
      providerDescriptorVersion:
          providerDescriptorVersion ?? this.providerDescriptorVersion,
      matcherSemanticVersion:
          matcherSemanticVersion ?? this.matcherSemanticVersion,
      normalizedPatternJson:
          normalizedPatternJson ?? this.normalizedPatternJson,
      patternFingerprint: patternFingerprint ?? this.patternFingerprint,
      annotationRef: annotationRef ?? this.annotationRef,
      enabledForMatching: enabledForMatching ?? this.enabledForMatching,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (savedPatternId.present) {
      map['saved_pattern_id'] = Variable<String>(savedPatternId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (eventTypeId.present) {
      map['event_type_id'] = Variable<String>(eventTypeId.value);
    }
    if (patternSchemaVersion.present) {
      map['pattern_schema_version'] = Variable<String>(
        patternSchemaVersion.value,
      );
    }
    if (providerDescriptorVersion.present) {
      map['provider_descriptor_version'] = Variable<String>(
        providerDescriptorVersion.value,
      );
    }
    if (matcherSemanticVersion.present) {
      map['matcher_semantic_version'] = Variable<String>(
        matcherSemanticVersion.value,
      );
    }
    if (normalizedPatternJson.present) {
      map['normalized_pattern_json'] = Variable<String>(
        normalizedPatternJson.value,
      );
    }
    if (patternFingerprint.present) {
      map['pattern_fingerprint'] = Variable<String>(patternFingerprint.value);
    }
    if (annotationRef.present) {
      map['annotation_ref'] = Variable<String>(annotationRef.value);
    }
    if (enabledForMatching.present) {
      map['enabled_for_matching'] = Variable<bool>(enabledForMatching.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventPatternRulesCompanion(')
          ..write('savedPatternId: $savedPatternId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('revision: $revision, ')
          ..write('providerId: $providerId, ')
          ..write('eventTypeId: $eventTypeId, ')
          ..write('patternSchemaVersion: $patternSchemaVersion, ')
          ..write('providerDescriptorVersion: $providerDescriptorVersion, ')
          ..write('matcherSemanticVersion: $matcherSemanticVersion, ')
          ..write('normalizedPatternJson: $normalizedPatternJson, ')
          ..write('patternFingerprint: $patternFingerprint, ')
          ..write('annotationRef: $annotationRef, ')
          ..write('enabledForMatching: $enabledForMatching, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventPatternTargetRefsTable extends LifeEventPatternTargetRefs
    with
        TableInfo<
          $LifeEventPatternTargetRefsTable,
          LifeEventPatternTargetRefRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventPatternTargetRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _savedPatternIdMeta = const VerificationMeta(
    'savedPatternId',
  );
  @override
  late final GeneratedColumn<String> savedPatternId = GeneratedColumn<String>(
    'saved_pattern_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [savedPatternId, targetType, targetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_pattern_target_refs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventPatternTargetRefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('saved_pattern_id')) {
      context.handle(
        _savedPatternIdMeta,
        savedPatternId.isAcceptableOrUnknown(
          data['saved_pattern_id']!,
          _savedPatternIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedPatternIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    savedPatternId,
    targetType,
    targetId,
  };
  @override
  LifeEventPatternTargetRefRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventPatternTargetRefRow(
      savedPatternId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_pattern_id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
    );
  }

  @override
  $LifeEventPatternTargetRefsTable createAlias(String alias) {
    return $LifeEventPatternTargetRefsTable(attachedDatabase, alias);
  }
}

class LifeEventPatternTargetRefRow extends DataClass
    implements Insertable<LifeEventPatternTargetRefRow> {
  final String savedPatternId;
  final String targetType;
  final String targetId;
  const LifeEventPatternTargetRefRow({
    required this.savedPatternId,
    required this.targetType,
    required this.targetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['saved_pattern_id'] = Variable<String>(savedPatternId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    return map;
  }

  LifeEventPatternTargetRefsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventPatternTargetRefsCompanion(
      savedPatternId: Value(savedPatternId),
      targetType: Value(targetType),
      targetId: Value(targetId),
    );
  }

  factory LifeEventPatternTargetRefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventPatternTargetRefRow(
      savedPatternId: serializer.fromJson<String>(json['savedPatternId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'savedPatternId': serializer.toJson<String>(savedPatternId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
    };
  }

  LifeEventPatternTargetRefRow copyWith({
    String? savedPatternId,
    String? targetType,
    String? targetId,
  }) => LifeEventPatternTargetRefRow(
    savedPatternId: savedPatternId ?? this.savedPatternId,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
  );
  LifeEventPatternTargetRefRow copyWithCompanion(
    LifeEventPatternTargetRefsCompanion data,
  ) {
    return LifeEventPatternTargetRefRow(
      savedPatternId: data.savedPatternId.present
          ? data.savedPatternId.value
          : this.savedPatternId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventPatternTargetRefRow(')
          ..write('savedPatternId: $savedPatternId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(savedPatternId, targetType, targetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventPatternTargetRefRow &&
          other.savedPatternId == this.savedPatternId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId);
}

class LifeEventPatternTargetRefsCompanion
    extends UpdateCompanion<LifeEventPatternTargetRefRow> {
  final Value<String> savedPatternId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<int> rowid;
  const LifeEventPatternTargetRefsCompanion({
    this.savedPatternId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventPatternTargetRefsCompanion.insert({
    required String savedPatternId,
    required String targetType,
    required String targetId,
    this.rowid = const Value.absent(),
  }) : savedPatternId = Value(savedPatternId),
       targetType = Value(targetType),
       targetId = Value(targetId);
  static Insertable<LifeEventPatternTargetRefRow> custom({
    Expression<String>? savedPatternId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (savedPatternId != null) 'saved_pattern_id': savedPatternId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventPatternTargetRefsCompanion copyWith({
    Value<String>? savedPatternId,
    Value<String>? targetType,
    Value<String>? targetId,
    Value<int>? rowid,
  }) {
    return LifeEventPatternTargetRefsCompanion(
      savedPatternId: savedPatternId ?? this.savedPatternId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (savedPatternId.present) {
      map['saved_pattern_id'] = Variable<String>(savedPatternId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventPatternTargetRefsCompanion(')
          ..write('savedPatternId: $savedPatternId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventRuleTemplatesTable extends LifeEventRuleTemplates
    with TableInfo<$LifeEventRuleTemplatesTable, LifeEventRuleTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventRuleTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeIdMeta = const VerificationMeta(
    'ownerScopeId',
  );
  @override
  late final GeneratedColumn<String> ownerScopeId = GeneratedColumn<String>(
    'owner_scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerPatternJsonMeta =
      const VerificationMeta('providerPatternJson');
  @override
  late final GeneratedColumn<String> providerPatternJson =
      GeneratedColumn<String>(
        'provider_pattern_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _defaultDirectionIdsJsonMeta =
      const VerificationMeta('defaultDirectionIdsJson');
  @override
  late final GeneratedColumn<String> defaultDirectionIdsJson =
      GeneratedColumn<String>(
        'default_direction_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _importanceOwnerScopeIdMeta =
      const VerificationMeta('importanceOwnerScopeId');
  @override
  late final GeneratedColumn<String> importanceOwnerScopeId =
      GeneratedColumn<String>(
        'importance_owner_scope_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importanceCatalogIdMeta =
      const VerificationMeta('importanceCatalogId');
  @override
  late final GeneratedColumn<String> importanceCatalogId =
      GeneratedColumn<String>(
        'importance_catalog_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importanceCatalogRevisionMeta =
      const VerificationMeta('importanceCatalogRevision');
  @override
  late final GeneratedColumn<int> importanceCatalogRevision =
      GeneratedColumn<int>(
        'importance_catalog_revision',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importanceLevelIdMeta = const VerificationMeta(
    'importanceLevelId',
  );
  @override
  late final GeneratedColumn<String> importanceLevelId =
      GeneratedColumn<String>(
        'importance_level_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _priorityOwnerScopeIdMeta =
      const VerificationMeta('priorityOwnerScopeId');
  @override
  late final GeneratedColumn<String> priorityOwnerScopeId =
      GeneratedColumn<String>(
        'priority_owner_scope_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _priorityCatalogIdMeta = const VerificationMeta(
    'priorityCatalogId',
  );
  @override
  late final GeneratedColumn<String> priorityCatalogId =
      GeneratedColumn<String>(
        'priority_catalog_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _priorityCatalogRevisionMeta =
      const VerificationMeta('priorityCatalogRevision');
  @override
  late final GeneratedColumn<int> priorityCatalogRevision =
      GeneratedColumn<int>(
        'priority_catalog_revision',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _priorityIdMeta = const VerificationMeta(
    'priorityId',
  );
  @override
  late final GeneratedColumn<String> priorityId = GeneratedColumn<String>(
    'priority_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultChannelIdsJsonMeta =
      const VerificationMeta('defaultChannelIdsJson');
  @override
  late final GeneratedColumn<String> defaultChannelIdsJson =
      GeneratedColumn<String>(
        'default_channel_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _defaultLeadTimesMsJsonMeta =
      const VerificationMeta('defaultLeadTimesMsJson');
  @override
  late final GeneratedColumn<String> defaultLeadTimesMsJson =
      GeneratedColumn<String>(
        'default_lead_times_ms_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    templateId,
    ownerScopeId,
    revision,
    providerPatternJson,
    defaultDirectionIdsJson,
    importanceOwnerScopeId,
    importanceCatalogId,
    importanceCatalogRevision,
    importanceLevelId,
    priorityOwnerScopeId,
    priorityCatalogId,
    priorityCatalogRevision,
    priorityId,
    defaultChannelIdsJson,
    defaultLeadTimesMsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_le_rule_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeEventRuleTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('owner_scope_id')) {
      context.handle(
        _ownerScopeIdMeta,
        ownerScopeId.isAcceptableOrUnknown(
          data['owner_scope_id']!,
          _ownerScopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('provider_pattern_json')) {
      context.handle(
        _providerPatternJsonMeta,
        providerPatternJson.isAcceptableOrUnknown(
          data['provider_pattern_json']!,
          _providerPatternJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerPatternJsonMeta);
    }
    if (data.containsKey('default_direction_ids_json')) {
      context.handle(
        _defaultDirectionIdsJsonMeta,
        defaultDirectionIdsJson.isAcceptableOrUnknown(
          data['default_direction_ids_json']!,
          _defaultDirectionIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultDirectionIdsJsonMeta);
    }
    if (data.containsKey('importance_owner_scope_id')) {
      context.handle(
        _importanceOwnerScopeIdMeta,
        importanceOwnerScopeId.isAcceptableOrUnknown(
          data['importance_owner_scope_id']!,
          _importanceOwnerScopeIdMeta,
        ),
      );
    }
    if (data.containsKey('importance_catalog_id')) {
      context.handle(
        _importanceCatalogIdMeta,
        importanceCatalogId.isAcceptableOrUnknown(
          data['importance_catalog_id']!,
          _importanceCatalogIdMeta,
        ),
      );
    }
    if (data.containsKey('importance_catalog_revision')) {
      context.handle(
        _importanceCatalogRevisionMeta,
        importanceCatalogRevision.isAcceptableOrUnknown(
          data['importance_catalog_revision']!,
          _importanceCatalogRevisionMeta,
        ),
      );
    }
    if (data.containsKey('importance_level_id')) {
      context.handle(
        _importanceLevelIdMeta,
        importanceLevelId.isAcceptableOrUnknown(
          data['importance_level_id']!,
          _importanceLevelIdMeta,
        ),
      );
    }
    if (data.containsKey('priority_owner_scope_id')) {
      context.handle(
        _priorityOwnerScopeIdMeta,
        priorityOwnerScopeId.isAcceptableOrUnknown(
          data['priority_owner_scope_id']!,
          _priorityOwnerScopeIdMeta,
        ),
      );
    }
    if (data.containsKey('priority_catalog_id')) {
      context.handle(
        _priorityCatalogIdMeta,
        priorityCatalogId.isAcceptableOrUnknown(
          data['priority_catalog_id']!,
          _priorityCatalogIdMeta,
        ),
      );
    }
    if (data.containsKey('priority_catalog_revision')) {
      context.handle(
        _priorityCatalogRevisionMeta,
        priorityCatalogRevision.isAcceptableOrUnknown(
          data['priority_catalog_revision']!,
          _priorityCatalogRevisionMeta,
        ),
      );
    }
    if (data.containsKey('priority_id')) {
      context.handle(
        _priorityIdMeta,
        priorityId.isAcceptableOrUnknown(data['priority_id']!, _priorityIdMeta),
      );
    }
    if (data.containsKey('default_channel_ids_json')) {
      context.handle(
        _defaultChannelIdsJsonMeta,
        defaultChannelIdsJson.isAcceptableOrUnknown(
          data['default_channel_ids_json']!,
          _defaultChannelIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultChannelIdsJsonMeta);
    }
    if (data.containsKey('default_lead_times_ms_json')) {
      context.handle(
        _defaultLeadTimesMsJsonMeta,
        defaultLeadTimesMsJson.isAcceptableOrUnknown(
          data['default_lead_times_ms_json']!,
          _defaultLeadTimesMsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultLeadTimesMsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {templateId};
  @override
  LifeEventRuleTemplateRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventRuleTemplateRow(
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      ownerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      providerPatternJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_pattern_json'],
      )!,
      defaultDirectionIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_direction_ids_json'],
      )!,
      importanceOwnerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance_owner_scope_id'],
      ),
      importanceCatalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance_catalog_id'],
      ),
      importanceCatalogRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}importance_catalog_revision'],
      ),
      importanceLevelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance_level_id'],
      ),
      priorityOwnerScopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority_owner_scope_id'],
      ),
      priorityCatalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority_catalog_id'],
      ),
      priorityCatalogRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority_catalog_revision'],
      ),
      priorityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority_id'],
      ),
      defaultChannelIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_channel_ids_json'],
      )!,
      defaultLeadTimesMsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_lead_times_ms_json'],
      )!,
    );
  }

  @override
  $LifeEventRuleTemplatesTable createAlias(String alias) {
    return $LifeEventRuleTemplatesTable(attachedDatabase, alias);
  }
}

class LifeEventRuleTemplateRow extends DataClass
    implements Insertable<LifeEventRuleTemplateRow> {
  final String templateId;
  final String ownerScopeId;
  final int revision;
  final String providerPatternJson;
  final String defaultDirectionIdsJson;
  final String? importanceOwnerScopeId;
  final String? importanceCatalogId;
  final int? importanceCatalogRevision;
  final String? importanceLevelId;
  final String? priorityOwnerScopeId;
  final String? priorityCatalogId;
  final int? priorityCatalogRevision;
  final String? priorityId;
  final String defaultChannelIdsJson;
  final String defaultLeadTimesMsJson;
  const LifeEventRuleTemplateRow({
    required this.templateId,
    required this.ownerScopeId,
    required this.revision,
    required this.providerPatternJson,
    required this.defaultDirectionIdsJson,
    this.importanceOwnerScopeId,
    this.importanceCatalogId,
    this.importanceCatalogRevision,
    this.importanceLevelId,
    this.priorityOwnerScopeId,
    this.priorityCatalogId,
    this.priorityCatalogRevision,
    this.priorityId,
    required this.defaultChannelIdsJson,
    required this.defaultLeadTimesMsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['template_id'] = Variable<String>(templateId);
    map['owner_scope_id'] = Variable<String>(ownerScopeId);
    map['revision'] = Variable<int>(revision);
    map['provider_pattern_json'] = Variable<String>(providerPatternJson);
    map['default_direction_ids_json'] = Variable<String>(
      defaultDirectionIdsJson,
    );
    if (!nullToAbsent || importanceOwnerScopeId != null) {
      map['importance_owner_scope_id'] = Variable<String>(
        importanceOwnerScopeId,
      );
    }
    if (!nullToAbsent || importanceCatalogId != null) {
      map['importance_catalog_id'] = Variable<String>(importanceCatalogId);
    }
    if (!nullToAbsent || importanceCatalogRevision != null) {
      map['importance_catalog_revision'] = Variable<int>(
        importanceCatalogRevision,
      );
    }
    if (!nullToAbsent || importanceLevelId != null) {
      map['importance_level_id'] = Variable<String>(importanceLevelId);
    }
    if (!nullToAbsent || priorityOwnerScopeId != null) {
      map['priority_owner_scope_id'] = Variable<String>(priorityOwnerScopeId);
    }
    if (!nullToAbsent || priorityCatalogId != null) {
      map['priority_catalog_id'] = Variable<String>(priorityCatalogId);
    }
    if (!nullToAbsent || priorityCatalogRevision != null) {
      map['priority_catalog_revision'] = Variable<int>(priorityCatalogRevision);
    }
    if (!nullToAbsent || priorityId != null) {
      map['priority_id'] = Variable<String>(priorityId);
    }
    map['default_channel_ids_json'] = Variable<String>(defaultChannelIdsJson);
    map['default_lead_times_ms_json'] = Variable<String>(
      defaultLeadTimesMsJson,
    );
    return map;
  }

  LifeEventRuleTemplatesCompanion toCompanion(bool nullToAbsent) {
    return LifeEventRuleTemplatesCompanion(
      templateId: Value(templateId),
      ownerScopeId: Value(ownerScopeId),
      revision: Value(revision),
      providerPatternJson: Value(providerPatternJson),
      defaultDirectionIdsJson: Value(defaultDirectionIdsJson),
      importanceOwnerScopeId: importanceOwnerScopeId == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceOwnerScopeId),
      importanceCatalogId: importanceCatalogId == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceCatalogId),
      importanceCatalogRevision:
          importanceCatalogRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceCatalogRevision),
      importanceLevelId: importanceLevelId == null && nullToAbsent
          ? const Value.absent()
          : Value(importanceLevelId),
      priorityOwnerScopeId: priorityOwnerScopeId == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityOwnerScopeId),
      priorityCatalogId: priorityCatalogId == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityCatalogId),
      priorityCatalogRevision: priorityCatalogRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityCatalogRevision),
      priorityId: priorityId == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityId),
      defaultChannelIdsJson: Value(defaultChannelIdsJson),
      defaultLeadTimesMsJson: Value(defaultLeadTimesMsJson),
    );
  }

  factory LifeEventRuleTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventRuleTemplateRow(
      templateId: serializer.fromJson<String>(json['templateId']),
      ownerScopeId: serializer.fromJson<String>(json['ownerScopeId']),
      revision: serializer.fromJson<int>(json['revision']),
      providerPatternJson: serializer.fromJson<String>(
        json['providerPatternJson'],
      ),
      defaultDirectionIdsJson: serializer.fromJson<String>(
        json['defaultDirectionIdsJson'],
      ),
      importanceOwnerScopeId: serializer.fromJson<String?>(
        json['importanceOwnerScopeId'],
      ),
      importanceCatalogId: serializer.fromJson<String?>(
        json['importanceCatalogId'],
      ),
      importanceCatalogRevision: serializer.fromJson<int?>(
        json['importanceCatalogRevision'],
      ),
      importanceLevelId: serializer.fromJson<String?>(
        json['importanceLevelId'],
      ),
      priorityOwnerScopeId: serializer.fromJson<String?>(
        json['priorityOwnerScopeId'],
      ),
      priorityCatalogId: serializer.fromJson<String?>(
        json['priorityCatalogId'],
      ),
      priorityCatalogRevision: serializer.fromJson<int?>(
        json['priorityCatalogRevision'],
      ),
      priorityId: serializer.fromJson<String?>(json['priorityId']),
      defaultChannelIdsJson: serializer.fromJson<String>(
        json['defaultChannelIdsJson'],
      ),
      defaultLeadTimesMsJson: serializer.fromJson<String>(
        json['defaultLeadTimesMsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateId': serializer.toJson<String>(templateId),
      'ownerScopeId': serializer.toJson<String>(ownerScopeId),
      'revision': serializer.toJson<int>(revision),
      'providerPatternJson': serializer.toJson<String>(providerPatternJson),
      'defaultDirectionIdsJson': serializer.toJson<String>(
        defaultDirectionIdsJson,
      ),
      'importanceOwnerScopeId': serializer.toJson<String?>(
        importanceOwnerScopeId,
      ),
      'importanceCatalogId': serializer.toJson<String?>(importanceCatalogId),
      'importanceCatalogRevision': serializer.toJson<int?>(
        importanceCatalogRevision,
      ),
      'importanceLevelId': serializer.toJson<String?>(importanceLevelId),
      'priorityOwnerScopeId': serializer.toJson<String?>(priorityOwnerScopeId),
      'priorityCatalogId': serializer.toJson<String?>(priorityCatalogId),
      'priorityCatalogRevision': serializer.toJson<int?>(
        priorityCatalogRevision,
      ),
      'priorityId': serializer.toJson<String?>(priorityId),
      'defaultChannelIdsJson': serializer.toJson<String>(defaultChannelIdsJson),
      'defaultLeadTimesMsJson': serializer.toJson<String>(
        defaultLeadTimesMsJson,
      ),
    };
  }

  LifeEventRuleTemplateRow copyWith({
    String? templateId,
    String? ownerScopeId,
    int? revision,
    String? providerPatternJson,
    String? defaultDirectionIdsJson,
    Value<String?> importanceOwnerScopeId = const Value.absent(),
    Value<String?> importanceCatalogId = const Value.absent(),
    Value<int?> importanceCatalogRevision = const Value.absent(),
    Value<String?> importanceLevelId = const Value.absent(),
    Value<String?> priorityOwnerScopeId = const Value.absent(),
    Value<String?> priorityCatalogId = const Value.absent(),
    Value<int?> priorityCatalogRevision = const Value.absent(),
    Value<String?> priorityId = const Value.absent(),
    String? defaultChannelIdsJson,
    String? defaultLeadTimesMsJson,
  }) => LifeEventRuleTemplateRow(
    templateId: templateId ?? this.templateId,
    ownerScopeId: ownerScopeId ?? this.ownerScopeId,
    revision: revision ?? this.revision,
    providerPatternJson: providerPatternJson ?? this.providerPatternJson,
    defaultDirectionIdsJson:
        defaultDirectionIdsJson ?? this.defaultDirectionIdsJson,
    importanceOwnerScopeId: importanceOwnerScopeId.present
        ? importanceOwnerScopeId.value
        : this.importanceOwnerScopeId,
    importanceCatalogId: importanceCatalogId.present
        ? importanceCatalogId.value
        : this.importanceCatalogId,
    importanceCatalogRevision: importanceCatalogRevision.present
        ? importanceCatalogRevision.value
        : this.importanceCatalogRevision,
    importanceLevelId: importanceLevelId.present
        ? importanceLevelId.value
        : this.importanceLevelId,
    priorityOwnerScopeId: priorityOwnerScopeId.present
        ? priorityOwnerScopeId.value
        : this.priorityOwnerScopeId,
    priorityCatalogId: priorityCatalogId.present
        ? priorityCatalogId.value
        : this.priorityCatalogId,
    priorityCatalogRevision: priorityCatalogRevision.present
        ? priorityCatalogRevision.value
        : this.priorityCatalogRevision,
    priorityId: priorityId.present ? priorityId.value : this.priorityId,
    defaultChannelIdsJson: defaultChannelIdsJson ?? this.defaultChannelIdsJson,
    defaultLeadTimesMsJson:
        defaultLeadTimesMsJson ?? this.defaultLeadTimesMsJson,
  );
  LifeEventRuleTemplateRow copyWithCompanion(
    LifeEventRuleTemplatesCompanion data,
  ) {
    return LifeEventRuleTemplateRow(
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      ownerScopeId: data.ownerScopeId.present
          ? data.ownerScopeId.value
          : this.ownerScopeId,
      revision: data.revision.present ? data.revision.value : this.revision,
      providerPatternJson: data.providerPatternJson.present
          ? data.providerPatternJson.value
          : this.providerPatternJson,
      defaultDirectionIdsJson: data.defaultDirectionIdsJson.present
          ? data.defaultDirectionIdsJson.value
          : this.defaultDirectionIdsJson,
      importanceOwnerScopeId: data.importanceOwnerScopeId.present
          ? data.importanceOwnerScopeId.value
          : this.importanceOwnerScopeId,
      importanceCatalogId: data.importanceCatalogId.present
          ? data.importanceCatalogId.value
          : this.importanceCatalogId,
      importanceCatalogRevision: data.importanceCatalogRevision.present
          ? data.importanceCatalogRevision.value
          : this.importanceCatalogRevision,
      importanceLevelId: data.importanceLevelId.present
          ? data.importanceLevelId.value
          : this.importanceLevelId,
      priorityOwnerScopeId: data.priorityOwnerScopeId.present
          ? data.priorityOwnerScopeId.value
          : this.priorityOwnerScopeId,
      priorityCatalogId: data.priorityCatalogId.present
          ? data.priorityCatalogId.value
          : this.priorityCatalogId,
      priorityCatalogRevision: data.priorityCatalogRevision.present
          ? data.priorityCatalogRevision.value
          : this.priorityCatalogRevision,
      priorityId: data.priorityId.present
          ? data.priorityId.value
          : this.priorityId,
      defaultChannelIdsJson: data.defaultChannelIdsJson.present
          ? data.defaultChannelIdsJson.value
          : this.defaultChannelIdsJson,
      defaultLeadTimesMsJson: data.defaultLeadTimesMsJson.present
          ? data.defaultLeadTimesMsJson.value
          : this.defaultLeadTimesMsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventRuleTemplateRow(')
          ..write('templateId: $templateId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('revision: $revision, ')
          ..write('providerPatternJson: $providerPatternJson, ')
          ..write('defaultDirectionIdsJson: $defaultDirectionIdsJson, ')
          ..write('importanceOwnerScopeId: $importanceOwnerScopeId, ')
          ..write('importanceCatalogId: $importanceCatalogId, ')
          ..write('importanceCatalogRevision: $importanceCatalogRevision, ')
          ..write('importanceLevelId: $importanceLevelId, ')
          ..write('priorityOwnerScopeId: $priorityOwnerScopeId, ')
          ..write('priorityCatalogId: $priorityCatalogId, ')
          ..write('priorityCatalogRevision: $priorityCatalogRevision, ')
          ..write('priorityId: $priorityId, ')
          ..write('defaultChannelIdsJson: $defaultChannelIdsJson, ')
          ..write('defaultLeadTimesMsJson: $defaultLeadTimesMsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    templateId,
    ownerScopeId,
    revision,
    providerPatternJson,
    defaultDirectionIdsJson,
    importanceOwnerScopeId,
    importanceCatalogId,
    importanceCatalogRevision,
    importanceLevelId,
    priorityOwnerScopeId,
    priorityCatalogId,
    priorityCatalogRevision,
    priorityId,
    defaultChannelIdsJson,
    defaultLeadTimesMsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventRuleTemplateRow &&
          other.templateId == this.templateId &&
          other.ownerScopeId == this.ownerScopeId &&
          other.revision == this.revision &&
          other.providerPatternJson == this.providerPatternJson &&
          other.defaultDirectionIdsJson == this.defaultDirectionIdsJson &&
          other.importanceOwnerScopeId == this.importanceOwnerScopeId &&
          other.importanceCatalogId == this.importanceCatalogId &&
          other.importanceCatalogRevision == this.importanceCatalogRevision &&
          other.importanceLevelId == this.importanceLevelId &&
          other.priorityOwnerScopeId == this.priorityOwnerScopeId &&
          other.priorityCatalogId == this.priorityCatalogId &&
          other.priorityCatalogRevision == this.priorityCatalogRevision &&
          other.priorityId == this.priorityId &&
          other.defaultChannelIdsJson == this.defaultChannelIdsJson &&
          other.defaultLeadTimesMsJson == this.defaultLeadTimesMsJson);
}

class LifeEventRuleTemplatesCompanion
    extends UpdateCompanion<LifeEventRuleTemplateRow> {
  final Value<String> templateId;
  final Value<String> ownerScopeId;
  final Value<int> revision;
  final Value<String> providerPatternJson;
  final Value<String> defaultDirectionIdsJson;
  final Value<String?> importanceOwnerScopeId;
  final Value<String?> importanceCatalogId;
  final Value<int?> importanceCatalogRevision;
  final Value<String?> importanceLevelId;
  final Value<String?> priorityOwnerScopeId;
  final Value<String?> priorityCatalogId;
  final Value<int?> priorityCatalogRevision;
  final Value<String?> priorityId;
  final Value<String> defaultChannelIdsJson;
  final Value<String> defaultLeadTimesMsJson;
  final Value<int> rowid;
  const LifeEventRuleTemplatesCompanion({
    this.templateId = const Value.absent(),
    this.ownerScopeId = const Value.absent(),
    this.revision = const Value.absent(),
    this.providerPatternJson = const Value.absent(),
    this.defaultDirectionIdsJson = const Value.absent(),
    this.importanceOwnerScopeId = const Value.absent(),
    this.importanceCatalogId = const Value.absent(),
    this.importanceCatalogRevision = const Value.absent(),
    this.importanceLevelId = const Value.absent(),
    this.priorityOwnerScopeId = const Value.absent(),
    this.priorityCatalogId = const Value.absent(),
    this.priorityCatalogRevision = const Value.absent(),
    this.priorityId = const Value.absent(),
    this.defaultChannelIdsJson = const Value.absent(),
    this.defaultLeadTimesMsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventRuleTemplatesCompanion.insert({
    required String templateId,
    required String ownerScopeId,
    required int revision,
    required String providerPatternJson,
    required String defaultDirectionIdsJson,
    this.importanceOwnerScopeId = const Value.absent(),
    this.importanceCatalogId = const Value.absent(),
    this.importanceCatalogRevision = const Value.absent(),
    this.importanceLevelId = const Value.absent(),
    this.priorityOwnerScopeId = const Value.absent(),
    this.priorityCatalogId = const Value.absent(),
    this.priorityCatalogRevision = const Value.absent(),
    this.priorityId = const Value.absent(),
    required String defaultChannelIdsJson,
    required String defaultLeadTimesMsJson,
    this.rowid = const Value.absent(),
  }) : templateId = Value(templateId),
       ownerScopeId = Value(ownerScopeId),
       revision = Value(revision),
       providerPatternJson = Value(providerPatternJson),
       defaultDirectionIdsJson = Value(defaultDirectionIdsJson),
       defaultChannelIdsJson = Value(defaultChannelIdsJson),
       defaultLeadTimesMsJson = Value(defaultLeadTimesMsJson);
  static Insertable<LifeEventRuleTemplateRow> custom({
    Expression<String>? templateId,
    Expression<String>? ownerScopeId,
    Expression<int>? revision,
    Expression<String>? providerPatternJson,
    Expression<String>? defaultDirectionIdsJson,
    Expression<String>? importanceOwnerScopeId,
    Expression<String>? importanceCatalogId,
    Expression<int>? importanceCatalogRevision,
    Expression<String>? importanceLevelId,
    Expression<String>? priorityOwnerScopeId,
    Expression<String>? priorityCatalogId,
    Expression<int>? priorityCatalogRevision,
    Expression<String>? priorityId,
    Expression<String>? defaultChannelIdsJson,
    Expression<String>? defaultLeadTimesMsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (templateId != null) 'template_id': templateId,
      if (ownerScopeId != null) 'owner_scope_id': ownerScopeId,
      if (revision != null) 'revision': revision,
      if (providerPatternJson != null)
        'provider_pattern_json': providerPatternJson,
      if (defaultDirectionIdsJson != null)
        'default_direction_ids_json': defaultDirectionIdsJson,
      if (importanceOwnerScopeId != null)
        'importance_owner_scope_id': importanceOwnerScopeId,
      if (importanceCatalogId != null)
        'importance_catalog_id': importanceCatalogId,
      if (importanceCatalogRevision != null)
        'importance_catalog_revision': importanceCatalogRevision,
      if (importanceLevelId != null) 'importance_level_id': importanceLevelId,
      if (priorityOwnerScopeId != null)
        'priority_owner_scope_id': priorityOwnerScopeId,
      if (priorityCatalogId != null) 'priority_catalog_id': priorityCatalogId,
      if (priorityCatalogRevision != null)
        'priority_catalog_revision': priorityCatalogRevision,
      if (priorityId != null) 'priority_id': priorityId,
      if (defaultChannelIdsJson != null)
        'default_channel_ids_json': defaultChannelIdsJson,
      if (defaultLeadTimesMsJson != null)
        'default_lead_times_ms_json': defaultLeadTimesMsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventRuleTemplatesCompanion copyWith({
    Value<String>? templateId,
    Value<String>? ownerScopeId,
    Value<int>? revision,
    Value<String>? providerPatternJson,
    Value<String>? defaultDirectionIdsJson,
    Value<String?>? importanceOwnerScopeId,
    Value<String?>? importanceCatalogId,
    Value<int?>? importanceCatalogRevision,
    Value<String?>? importanceLevelId,
    Value<String?>? priorityOwnerScopeId,
    Value<String?>? priorityCatalogId,
    Value<int?>? priorityCatalogRevision,
    Value<String?>? priorityId,
    Value<String>? defaultChannelIdsJson,
    Value<String>? defaultLeadTimesMsJson,
    Value<int>? rowid,
  }) {
    return LifeEventRuleTemplatesCompanion(
      templateId: templateId ?? this.templateId,
      ownerScopeId: ownerScopeId ?? this.ownerScopeId,
      revision: revision ?? this.revision,
      providerPatternJson: providerPatternJson ?? this.providerPatternJson,
      defaultDirectionIdsJson:
          defaultDirectionIdsJson ?? this.defaultDirectionIdsJson,
      importanceOwnerScopeId:
          importanceOwnerScopeId ?? this.importanceOwnerScopeId,
      importanceCatalogId: importanceCatalogId ?? this.importanceCatalogId,
      importanceCatalogRevision:
          importanceCatalogRevision ?? this.importanceCatalogRevision,
      importanceLevelId: importanceLevelId ?? this.importanceLevelId,
      priorityOwnerScopeId: priorityOwnerScopeId ?? this.priorityOwnerScopeId,
      priorityCatalogId: priorityCatalogId ?? this.priorityCatalogId,
      priorityCatalogRevision:
          priorityCatalogRevision ?? this.priorityCatalogRevision,
      priorityId: priorityId ?? this.priorityId,
      defaultChannelIdsJson:
          defaultChannelIdsJson ?? this.defaultChannelIdsJson,
      defaultLeadTimesMsJson:
          defaultLeadTimesMsJson ?? this.defaultLeadTimesMsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (ownerScopeId.present) {
      map['owner_scope_id'] = Variable<String>(ownerScopeId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (providerPatternJson.present) {
      map['provider_pattern_json'] = Variable<String>(
        providerPatternJson.value,
      );
    }
    if (defaultDirectionIdsJson.present) {
      map['default_direction_ids_json'] = Variable<String>(
        defaultDirectionIdsJson.value,
      );
    }
    if (importanceOwnerScopeId.present) {
      map['importance_owner_scope_id'] = Variable<String>(
        importanceOwnerScopeId.value,
      );
    }
    if (importanceCatalogId.present) {
      map['importance_catalog_id'] = Variable<String>(
        importanceCatalogId.value,
      );
    }
    if (importanceCatalogRevision.present) {
      map['importance_catalog_revision'] = Variable<int>(
        importanceCatalogRevision.value,
      );
    }
    if (importanceLevelId.present) {
      map['importance_level_id'] = Variable<String>(importanceLevelId.value);
    }
    if (priorityOwnerScopeId.present) {
      map['priority_owner_scope_id'] = Variable<String>(
        priorityOwnerScopeId.value,
      );
    }
    if (priorityCatalogId.present) {
      map['priority_catalog_id'] = Variable<String>(priorityCatalogId.value);
    }
    if (priorityCatalogRevision.present) {
      map['priority_catalog_revision'] = Variable<int>(
        priorityCatalogRevision.value,
      );
    }
    if (priorityId.present) {
      map['priority_id'] = Variable<String>(priorityId.value);
    }
    if (defaultChannelIdsJson.present) {
      map['default_channel_ids_json'] = Variable<String>(
        defaultChannelIdsJson.value,
      );
    }
    if (defaultLeadTimesMsJson.present) {
      map['default_lead_times_ms_json'] = Variable<String>(
        defaultLeadTimesMsJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventRuleTemplatesCompanion(')
          ..write('templateId: $templateId, ')
          ..write('ownerScopeId: $ownerScopeId, ')
          ..write('revision: $revision, ')
          ..write('providerPatternJson: $providerPatternJson, ')
          ..write('defaultDirectionIdsJson: $defaultDirectionIdsJson, ')
          ..write('importanceOwnerScopeId: $importanceOwnerScopeId, ')
          ..write('importanceCatalogId: $importanceCatalogId, ')
          ..write('importanceCatalogRevision: $importanceCatalogRevision, ')
          ..write('importanceLevelId: $importanceLevelId, ')
          ..write('priorityOwnerScopeId: $priorityOwnerScopeId, ')
          ..write('priorityCatalogId: $priorityCatalogId, ')
          ..write('priorityCatalogRevision: $priorityCatalogRevision, ')
          ..write('priorityId: $priorityId, ')
          ..write('defaultChannelIdsJson: $defaultChannelIdsJson, ')
          ..write('defaultLeadTimesMsJson: $defaultLeadTimesMsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LifeEventDatabase extends GeneratedDatabase {
  _$LifeEventDatabase(QueryExecutor e) : super(e);
  $LifeEventDatabaseManager get managers => $LifeEventDatabaseManager(this);
  late final $LifeEventSubjectsTable lifeEventSubjects =
      $LifeEventSubjectsTable(this);
  late final $LifeEventLifeProfilesTable lifeEventLifeProfiles =
      $LifeEventLifeProfilesTable(this);
  late final $LifeEventChartSnapshotRefsTable lifeEventChartSnapshotRefs =
      $LifeEventChartSnapshotRefsTable(this);
  late final $LifeEventProviderDescriptorsTable lifeEventProviderDescriptors =
      $LifeEventProviderDescriptorsTable(this);
  late final $LifeEventEventTypeDescriptorsTable lifeEventEventTypeDescriptors =
      $LifeEventEventTypeDescriptorsTable(this);
  late final $LifeEventProjectionsTable lifeEventProjections =
      $LifeEventProjectionsTable(this);
  late final $LifeEventCoverageSeriesHeadsTable lifeEventCoverageSeriesHeads =
      $LifeEventCoverageSeriesHeadsTable(this);
  late final $LifeEventCoverageManifestsTable lifeEventCoverageManifests =
      $LifeEventCoverageManifestsTable(this);
  late final $LifeEventShardReceiptsTable lifeEventShardReceipts =
      $LifeEventShardReceiptsTable(this);
  late final $LifeEventUserDirectionsTable lifeEventUserDirections =
      $LifeEventUserDirectionsTable(this);
  late final $LifeEventUserAnnotationsTable lifeEventUserAnnotations =
      $LifeEventUserAnnotationsTable(this);
  late final $LifeEventAnnotationTargetRefsTable lifeEventAnnotationTargetRefs =
      $LifeEventAnnotationTargetRefsTable(this);
  late final $LifeEventAnnotationDirectionRefsTable
  lifeEventAnnotationDirectionRefs = $LifeEventAnnotationDirectionRefsTable(
    this,
  );
  late final $LifeEventOccurrenceSelectionsTable lifeEventOccurrenceSelections =
      $LifeEventOccurrenceSelectionsTable(this);
  late final $LifeEventPatternRulesTable lifeEventPatternRules =
      $LifeEventPatternRulesTable(this);
  late final $LifeEventPatternTargetRefsTable lifeEventPatternTargetRefs =
      $LifeEventPatternTargetRefsTable(this);
  late final $LifeEventRuleTemplatesTable lifeEventRuleTemplates =
      $LifeEventRuleTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lifeEventSubjects,
    lifeEventLifeProfiles,
    lifeEventChartSnapshotRefs,
    lifeEventProviderDescriptors,
    lifeEventEventTypeDescriptors,
    lifeEventProjections,
    lifeEventCoverageSeriesHeads,
    lifeEventCoverageManifests,
    lifeEventShardReceipts,
    lifeEventUserDirections,
    lifeEventUserAnnotations,
    lifeEventAnnotationTargetRefs,
    lifeEventAnnotationDirectionRefs,
    lifeEventOccurrenceSelections,
    lifeEventPatternRules,
    lifeEventPatternTargetRefs,
    lifeEventRuleTemplates,
  ];
}

typedef $$LifeEventSubjectsTableCreateCompanionBuilder =
    LifeEventSubjectsCompanion Function({
      required String subjectId,
      required String ownerScopeId,
      Value<String?> displayLabel,
      Value<int> rowid,
    });
typedef $$LifeEventSubjectsTableUpdateCompanionBuilder =
    LifeEventSubjectsCompanion Function({
      Value<String> subjectId,
      Value<String> ownerScopeId,
      Value<String?> displayLabel,
      Value<int> rowid,
    });

class $$LifeEventSubjectsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventSubjectsTable> {
  $$LifeEventSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventSubjectsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventSubjectsTable> {
  $$LifeEventSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventSubjectsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventSubjectsTable> {
  $$LifeEventSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => column,
  );
}

class $$LifeEventSubjectsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventSubjectsTable,
          LifeEventSubjectRow,
          $$LifeEventSubjectsTableFilterComposer,
          $$LifeEventSubjectsTableOrderingComposer,
          $$LifeEventSubjectsTableAnnotationComposer,
          $$LifeEventSubjectsTableCreateCompanionBuilder,
          $$LifeEventSubjectsTableUpdateCompanionBuilder,
          (
            LifeEventSubjectRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventSubjectsTable,
              LifeEventSubjectRow
            >,
          ),
          LifeEventSubjectRow,
          PrefetchHooks Function()
        > {
  $$LifeEventSubjectsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventSubjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LifeEventSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LifeEventSubjectsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> subjectId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<String?> displayLabel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventSubjectsCompanion(
                subjectId: subjectId,
                ownerScopeId: ownerScopeId,
                displayLabel: displayLabel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String subjectId,
                required String ownerScopeId,
                Value<String?> displayLabel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventSubjectsCompanion.insert(
                subjectId: subjectId,
                ownerScopeId: ownerScopeId,
                displayLabel: displayLabel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventSubjectsTable,
      LifeEventSubjectRow,
      $$LifeEventSubjectsTableFilterComposer,
      $$LifeEventSubjectsTableOrderingComposer,
      $$LifeEventSubjectsTableAnnotationComposer,
      $$LifeEventSubjectsTableCreateCompanionBuilder,
      $$LifeEventSubjectsTableUpdateCompanionBuilder,
      (
        LifeEventSubjectRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventSubjectsTable,
          LifeEventSubjectRow
        >,
      ),
      LifeEventSubjectRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventLifeProfilesTableCreateCompanionBuilder =
    LifeEventLifeProfilesCompanion Function({
      required String profileId,
      required String ownerScopeId,
      required String subjectId,
      Value<String?> displayLabel,
      required int revision,
      Value<int> rowid,
    });
typedef $$LifeEventLifeProfilesTableUpdateCompanionBuilder =
    LifeEventLifeProfilesCompanion Function({
      Value<String> profileId,
      Value<String> ownerScopeId,
      Value<String> subjectId,
      Value<String?> displayLabel,
      Value<int> revision,
      Value<int> rowid,
    });

class $$LifeEventLifeProfilesTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventLifeProfilesTable> {
  $$LifeEventLifeProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventLifeProfilesTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventLifeProfilesTable> {
  $$LifeEventLifeProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventLifeProfilesTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventLifeProfilesTable> {
  $$LifeEventLifeProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$LifeEventLifeProfilesTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventLifeProfilesTable,
          LifeEventLifeProfileRow,
          $$LifeEventLifeProfilesTableFilterComposer,
          $$LifeEventLifeProfilesTableOrderingComposer,
          $$LifeEventLifeProfilesTableAnnotationComposer,
          $$LifeEventLifeProfilesTableCreateCompanionBuilder,
          $$LifeEventLifeProfilesTableUpdateCompanionBuilder,
          (
            LifeEventLifeProfileRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventLifeProfilesTable,
              LifeEventLifeProfileRow
            >,
          ),
          LifeEventLifeProfileRow,
          PrefetchHooks Function()
        > {
  $$LifeEventLifeProfilesTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventLifeProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventLifeProfilesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventLifeProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventLifeProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String?> displayLabel = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventLifeProfilesCompanion(
                profileId: profileId,
                ownerScopeId: ownerScopeId,
                subjectId: subjectId,
                displayLabel: displayLabel,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String ownerScopeId,
                required String subjectId,
                Value<String?> displayLabel = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventLifeProfilesCompanion.insert(
                profileId: profileId,
                ownerScopeId: ownerScopeId,
                subjectId: subjectId,
                displayLabel: displayLabel,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventLifeProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventLifeProfilesTable,
      LifeEventLifeProfileRow,
      $$LifeEventLifeProfilesTableFilterComposer,
      $$LifeEventLifeProfilesTableOrderingComposer,
      $$LifeEventLifeProfilesTableAnnotationComposer,
      $$LifeEventLifeProfilesTableCreateCompanionBuilder,
      $$LifeEventLifeProfilesTableUpdateCompanionBuilder,
      (
        LifeEventLifeProfileRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventLifeProfilesTable,
          LifeEventLifeProfileRow
        >,
      ),
      LifeEventLifeProfileRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventChartSnapshotRefsTableCreateCompanionBuilder =
    LifeEventChartSnapshotRefsCompanion Function({
      required String chartSnapshotId,
      required String profileId,
      required String providerId,
      required String divinationTypeKey,
      Value<String?> subDivinationTypeKey,
      required String snapshotRevision,
      required String algorithmVersion,
      required String inputFingerprint,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$LifeEventChartSnapshotRefsTableUpdateCompanionBuilder =
    LifeEventChartSnapshotRefsCompanion Function({
      Value<String> chartSnapshotId,
      Value<String> profileId,
      Value<String> providerId,
      Value<String> divinationTypeKey,
      Value<String?> subDivinationTypeKey,
      Value<String> snapshotRevision,
      Value<String> algorithmVersion,
      Value<String> inputFingerprint,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$LifeEventChartSnapshotRefsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventChartSnapshotRefsTable> {
  $$LifeEventChartSnapshotRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get divinationTypeKey => $composableBuilder(
    column: $table.divinationTypeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subDivinationTypeKey => $composableBuilder(
    column: $table.subDivinationTypeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotRevision => $composableBuilder(
    column: $table.snapshotRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventChartSnapshotRefsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventChartSnapshotRefsTable> {
  $$LifeEventChartSnapshotRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get divinationTypeKey => $composableBuilder(
    column: $table.divinationTypeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subDivinationTypeKey => $composableBuilder(
    column: $table.subDivinationTypeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotRevision => $composableBuilder(
    column: $table.snapshotRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventChartSnapshotRefsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventChartSnapshotRefsTable> {
  $$LifeEventChartSnapshotRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get divinationTypeKey => $composableBuilder(
    column: $table.divinationTypeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subDivinationTypeKey => $composableBuilder(
    column: $table.subDivinationTypeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotRevision => $composableBuilder(
    column: $table.snapshotRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$LifeEventChartSnapshotRefsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventChartSnapshotRefsTable,
          LifeEventChartSnapshotRow,
          $$LifeEventChartSnapshotRefsTableFilterComposer,
          $$LifeEventChartSnapshotRefsTableOrderingComposer,
          $$LifeEventChartSnapshotRefsTableAnnotationComposer,
          $$LifeEventChartSnapshotRefsTableCreateCompanionBuilder,
          $$LifeEventChartSnapshotRefsTableUpdateCompanionBuilder,
          (
            LifeEventChartSnapshotRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventChartSnapshotRefsTable,
              LifeEventChartSnapshotRow
            >,
          ),
          LifeEventChartSnapshotRow,
          PrefetchHooks Function()
        > {
  $$LifeEventChartSnapshotRefsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventChartSnapshotRefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventChartSnapshotRefsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventChartSnapshotRefsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventChartSnapshotRefsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> chartSnapshotId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> divinationTypeKey = const Value.absent(),
                Value<String?> subDivinationTypeKey = const Value.absent(),
                Value<String> snapshotRevision = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<String> inputFingerprint = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventChartSnapshotRefsCompanion(
                chartSnapshotId: chartSnapshotId,
                profileId: profileId,
                providerId: providerId,
                divinationTypeKey: divinationTypeKey,
                subDivinationTypeKey: subDivinationTypeKey,
                snapshotRevision: snapshotRevision,
                algorithmVersion: algorithmVersion,
                inputFingerprint: inputFingerprint,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chartSnapshotId,
                required String profileId,
                required String providerId,
                required String divinationTypeKey,
                Value<String?> subDivinationTypeKey = const Value.absent(),
                required String snapshotRevision,
                required String algorithmVersion,
                required String inputFingerprint,
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventChartSnapshotRefsCompanion.insert(
                chartSnapshotId: chartSnapshotId,
                profileId: profileId,
                providerId: providerId,
                divinationTypeKey: divinationTypeKey,
                subDivinationTypeKey: subDivinationTypeKey,
                snapshotRevision: snapshotRevision,
                algorithmVersion: algorithmVersion,
                inputFingerprint: inputFingerprint,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventChartSnapshotRefsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventChartSnapshotRefsTable,
      LifeEventChartSnapshotRow,
      $$LifeEventChartSnapshotRefsTableFilterComposer,
      $$LifeEventChartSnapshotRefsTableOrderingComposer,
      $$LifeEventChartSnapshotRefsTableAnnotationComposer,
      $$LifeEventChartSnapshotRefsTableCreateCompanionBuilder,
      $$LifeEventChartSnapshotRefsTableUpdateCompanionBuilder,
      (
        LifeEventChartSnapshotRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventChartSnapshotRefsTable,
          LifeEventChartSnapshotRow
        >,
      ),
      LifeEventChartSnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventProviderDescriptorsTableCreateCompanionBuilder =
    LifeEventProviderDescriptorsCompanion Function({
      required String providerId,
      required String providerVersion,
      required String algorithmVersion,
      Value<String?> dataVersion,
      required String schemaVersion,
      required String descriptorJson,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$LifeEventProviderDescriptorsTableUpdateCompanionBuilder =
    LifeEventProviderDescriptorsCompanion Function({
      Value<String> providerId,
      Value<String> providerVersion,
      Value<String> algorithmVersion,
      Value<String?> dataVersion,
      Value<String> schemaVersion,
      Value<String> descriptorJson,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$LifeEventProviderDescriptorsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventProviderDescriptorsTable> {
  $$LifeEventProviderDescriptorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptorJson => $composableBuilder(
    column: $table.descriptorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventProviderDescriptorsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventProviderDescriptorsTable> {
  $$LifeEventProviderDescriptorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptorJson => $composableBuilder(
    column: $table.descriptorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventProviderDescriptorsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventProviderDescriptorsTable> {
  $$LifeEventProviderDescriptorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptorJson => $composableBuilder(
    column: $table.descriptorJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$LifeEventProviderDescriptorsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventProviderDescriptorsTable,
          LifeEventProviderDescriptorRow,
          $$LifeEventProviderDescriptorsTableFilterComposer,
          $$LifeEventProviderDescriptorsTableOrderingComposer,
          $$LifeEventProviderDescriptorsTableAnnotationComposer,
          $$LifeEventProviderDescriptorsTableCreateCompanionBuilder,
          $$LifeEventProviderDescriptorsTableUpdateCompanionBuilder,
          (
            LifeEventProviderDescriptorRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventProviderDescriptorsTable,
              LifeEventProviderDescriptorRow
            >,
          ),
          LifeEventProviderDescriptorRow,
          PrefetchHooks Function()
        > {
  $$LifeEventProviderDescriptorsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventProviderDescriptorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventProviderDescriptorsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventProviderDescriptorsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventProviderDescriptorsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> providerId = const Value.absent(),
                Value<String> providerVersion = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<String?> dataVersion = const Value.absent(),
                Value<String> schemaVersion = const Value.absent(),
                Value<String> descriptorJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventProviderDescriptorsCompanion(
                providerId: providerId,
                providerVersion: providerVersion,
                algorithmVersion: algorithmVersion,
                dataVersion: dataVersion,
                schemaVersion: schemaVersion,
                descriptorJson: descriptorJson,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String providerId,
                required String providerVersion,
                required String algorithmVersion,
                Value<String?> dataVersion = const Value.absent(),
                required String schemaVersion,
                required String descriptorJson,
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventProviderDescriptorsCompanion.insert(
                providerId: providerId,
                providerVersion: providerVersion,
                algorithmVersion: algorithmVersion,
                dataVersion: dataVersion,
                schemaVersion: schemaVersion,
                descriptorJson: descriptorJson,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventProviderDescriptorsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventProviderDescriptorsTable,
      LifeEventProviderDescriptorRow,
      $$LifeEventProviderDescriptorsTableFilterComposer,
      $$LifeEventProviderDescriptorsTableOrderingComposer,
      $$LifeEventProviderDescriptorsTableAnnotationComposer,
      $$LifeEventProviderDescriptorsTableCreateCompanionBuilder,
      $$LifeEventProviderDescriptorsTableUpdateCompanionBuilder,
      (
        LifeEventProviderDescriptorRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventProviderDescriptorsTable,
          LifeEventProviderDescriptorRow
        >,
      ),
      LifeEventProviderDescriptorRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventEventTypeDescriptorsTableCreateCompanionBuilder =
    LifeEventEventTypeDescriptorsCompanion Function({
      required String providerId,
      required String eventTypeId,
      required String schemaVersion,
      required String descriptorJson,
      Value<int> rowid,
    });
typedef $$LifeEventEventTypeDescriptorsTableUpdateCompanionBuilder =
    LifeEventEventTypeDescriptorsCompanion Function({
      Value<String> providerId,
      Value<String> eventTypeId,
      Value<String> schemaVersion,
      Value<String> descriptorJson,
      Value<int> rowid,
    });

class $$LifeEventEventTypeDescriptorsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventEventTypeDescriptorsTable> {
  $$LifeEventEventTypeDescriptorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptorJson => $composableBuilder(
    column: $table.descriptorJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventEventTypeDescriptorsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventEventTypeDescriptorsTable> {
  $$LifeEventEventTypeDescriptorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptorJson => $composableBuilder(
    column: $table.descriptorJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventEventTypeDescriptorsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventEventTypeDescriptorsTable> {
  $$LifeEventEventTypeDescriptorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptorJson => $composableBuilder(
    column: $table.descriptorJson,
    builder: (column) => column,
  );
}

class $$LifeEventEventTypeDescriptorsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventEventTypeDescriptorsTable,
          LifeEventEventTypeDescriptorRow,
          $$LifeEventEventTypeDescriptorsTableFilterComposer,
          $$LifeEventEventTypeDescriptorsTableOrderingComposer,
          $$LifeEventEventTypeDescriptorsTableAnnotationComposer,
          $$LifeEventEventTypeDescriptorsTableCreateCompanionBuilder,
          $$LifeEventEventTypeDescriptorsTableUpdateCompanionBuilder,
          (
            LifeEventEventTypeDescriptorRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventEventTypeDescriptorsTable,
              LifeEventEventTypeDescriptorRow
            >,
          ),
          LifeEventEventTypeDescriptorRow,
          PrefetchHooks Function()
        > {
  $$LifeEventEventTypeDescriptorsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventEventTypeDescriptorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventEventTypeDescriptorsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventEventTypeDescriptorsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventEventTypeDescriptorsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> providerId = const Value.absent(),
                Value<String> eventTypeId = const Value.absent(),
                Value<String> schemaVersion = const Value.absent(),
                Value<String> descriptorJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventEventTypeDescriptorsCompanion(
                providerId: providerId,
                eventTypeId: eventTypeId,
                schemaVersion: schemaVersion,
                descriptorJson: descriptorJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String providerId,
                required String eventTypeId,
                required String schemaVersion,
                required String descriptorJson,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventEventTypeDescriptorsCompanion.insert(
                providerId: providerId,
                eventTypeId: eventTypeId,
                schemaVersion: schemaVersion,
                descriptorJson: descriptorJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventEventTypeDescriptorsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventEventTypeDescriptorsTable,
      LifeEventEventTypeDescriptorRow,
      $$LifeEventEventTypeDescriptorsTableFilterComposer,
      $$LifeEventEventTypeDescriptorsTableOrderingComposer,
      $$LifeEventEventTypeDescriptorsTableAnnotationComposer,
      $$LifeEventEventTypeDescriptorsTableCreateCompanionBuilder,
      $$LifeEventEventTypeDescriptorsTableUpdateCompanionBuilder,
      (
        LifeEventEventTypeDescriptorRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventEventTypeDescriptorsTable,
          LifeEventEventTypeDescriptorRow
        >,
      ),
      LifeEventEventTypeDescriptorRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventProjectionsTableCreateCompanionBuilder =
    LifeEventProjectionsCompanion Function({
      required String projectionId,
      required String coverageId,
      required int coverageGeneration,
      required String sourceProviderId,
      required String sourceEventId,
      required String eventRevision,
      required String ownerScopeId,
      required String subjectId,
      required String profileId,
      required String chartSnapshotId,
      required String divinationTypeKey,
      Value<String?> subDivinationTypeKey,
      required String eventTypeId,
      required int effectiveStartMs,
      required int precisionRank,
      required String projectionJson,
      required int lifecycleStatus,
      Value<int> rowid,
    });
typedef $$LifeEventProjectionsTableUpdateCompanionBuilder =
    LifeEventProjectionsCompanion Function({
      Value<String> projectionId,
      Value<String> coverageId,
      Value<int> coverageGeneration,
      Value<String> sourceProviderId,
      Value<String> sourceEventId,
      Value<String> eventRevision,
      Value<String> ownerScopeId,
      Value<String> subjectId,
      Value<String> profileId,
      Value<String> chartSnapshotId,
      Value<String> divinationTypeKey,
      Value<String?> subDivinationTypeKey,
      Value<String> eventTypeId,
      Value<int> effectiveStartMs,
      Value<int> precisionRank,
      Value<String> projectionJson,
      Value<int> lifecycleStatus,
      Value<int> rowid,
    });

class $$LifeEventProjectionsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventProjectionsTable> {
  $$LifeEventProjectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectionId => $composableBuilder(
    column: $table.projectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get divinationTypeKey => $composableBuilder(
    column: $table.divinationTypeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subDivinationTypeKey => $composableBuilder(
    column: $table.subDivinationTypeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveStartMs => $composableBuilder(
    column: $table.effectiveStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precisionRank => $composableBuilder(
    column: $table.precisionRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectionJson => $composableBuilder(
    column: $table.projectionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventProjectionsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventProjectionsTable> {
  $$LifeEventProjectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectionId => $composableBuilder(
    column: $table.projectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get divinationTypeKey => $composableBuilder(
    column: $table.divinationTypeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subDivinationTypeKey => $composableBuilder(
    column: $table.subDivinationTypeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveStartMs => $composableBuilder(
    column: $table.effectiveStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precisionRank => $composableBuilder(
    column: $table.precisionRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectionJson => $composableBuilder(
    column: $table.projectionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventProjectionsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventProjectionsTable> {
  $$LifeEventProjectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectionId => $composableBuilder(
    column: $table.projectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get divinationTypeKey => $composableBuilder(
    column: $table.divinationTypeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subDivinationTypeKey => $composableBuilder(
    column: $table.subDivinationTypeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveStartMs => $composableBuilder(
    column: $table.effectiveStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precisionRank => $composableBuilder(
    column: $table.precisionRank,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectionJson => $composableBuilder(
    column: $table.projectionJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => column,
  );
}

class $$LifeEventProjectionsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventProjectionsTable,
          LifeEventProjectionRow,
          $$LifeEventProjectionsTableFilterComposer,
          $$LifeEventProjectionsTableOrderingComposer,
          $$LifeEventProjectionsTableAnnotationComposer,
          $$LifeEventProjectionsTableCreateCompanionBuilder,
          $$LifeEventProjectionsTableUpdateCompanionBuilder,
          (
            LifeEventProjectionRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventProjectionsTable,
              LifeEventProjectionRow
            >,
          ),
          LifeEventProjectionRow,
          PrefetchHooks Function()
        > {
  $$LifeEventProjectionsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventProjectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventProjectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LifeEventProjectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventProjectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> projectionId = const Value.absent(),
                Value<String> coverageId = const Value.absent(),
                Value<int> coverageGeneration = const Value.absent(),
                Value<String> sourceProviderId = const Value.absent(),
                Value<String> sourceEventId = const Value.absent(),
                Value<String> eventRevision = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> chartSnapshotId = const Value.absent(),
                Value<String> divinationTypeKey = const Value.absent(),
                Value<String?> subDivinationTypeKey = const Value.absent(),
                Value<String> eventTypeId = const Value.absent(),
                Value<int> effectiveStartMs = const Value.absent(),
                Value<int> precisionRank = const Value.absent(),
                Value<String> projectionJson = const Value.absent(),
                Value<int> lifecycleStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventProjectionsCompanion(
                projectionId: projectionId,
                coverageId: coverageId,
                coverageGeneration: coverageGeneration,
                sourceProviderId: sourceProviderId,
                sourceEventId: sourceEventId,
                eventRevision: eventRevision,
                ownerScopeId: ownerScopeId,
                subjectId: subjectId,
                profileId: profileId,
                chartSnapshotId: chartSnapshotId,
                divinationTypeKey: divinationTypeKey,
                subDivinationTypeKey: subDivinationTypeKey,
                eventTypeId: eventTypeId,
                effectiveStartMs: effectiveStartMs,
                precisionRank: precisionRank,
                projectionJson: projectionJson,
                lifecycleStatus: lifecycleStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String projectionId,
                required String coverageId,
                required int coverageGeneration,
                required String sourceProviderId,
                required String sourceEventId,
                required String eventRevision,
                required String ownerScopeId,
                required String subjectId,
                required String profileId,
                required String chartSnapshotId,
                required String divinationTypeKey,
                Value<String?> subDivinationTypeKey = const Value.absent(),
                required String eventTypeId,
                required int effectiveStartMs,
                required int precisionRank,
                required String projectionJson,
                required int lifecycleStatus,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventProjectionsCompanion.insert(
                projectionId: projectionId,
                coverageId: coverageId,
                coverageGeneration: coverageGeneration,
                sourceProviderId: sourceProviderId,
                sourceEventId: sourceEventId,
                eventRevision: eventRevision,
                ownerScopeId: ownerScopeId,
                subjectId: subjectId,
                profileId: profileId,
                chartSnapshotId: chartSnapshotId,
                divinationTypeKey: divinationTypeKey,
                subDivinationTypeKey: subDivinationTypeKey,
                eventTypeId: eventTypeId,
                effectiveStartMs: effectiveStartMs,
                precisionRank: precisionRank,
                projectionJson: projectionJson,
                lifecycleStatus: lifecycleStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventProjectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventProjectionsTable,
      LifeEventProjectionRow,
      $$LifeEventProjectionsTableFilterComposer,
      $$LifeEventProjectionsTableOrderingComposer,
      $$LifeEventProjectionsTableAnnotationComposer,
      $$LifeEventProjectionsTableCreateCompanionBuilder,
      $$LifeEventProjectionsTableUpdateCompanionBuilder,
      (
        LifeEventProjectionRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventProjectionsTable,
          LifeEventProjectionRow
        >,
      ),
      LifeEventProjectionRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventCoverageSeriesHeadsTableCreateCompanionBuilder =
    LifeEventCoverageSeriesHeadsCompanion Function({
      required String coverageSeriesId,
      required String ownerScopeId,
      required String profileId,
      required String chartSnapshotId,
      required String providerId,
      required String eventTypeId,
      required int seriesRevision,
      Value<String?> activeCoverageId,
      Value<String?> candidateCoverageId,
      required int desiredRangeStartMs,
      required int desiredRangeEndMs,
      Value<int> rowid,
    });
typedef $$LifeEventCoverageSeriesHeadsTableUpdateCompanionBuilder =
    LifeEventCoverageSeriesHeadsCompanion Function({
      Value<String> coverageSeriesId,
      Value<String> ownerScopeId,
      Value<String> profileId,
      Value<String> chartSnapshotId,
      Value<String> providerId,
      Value<String> eventTypeId,
      Value<int> seriesRevision,
      Value<String?> activeCoverageId,
      Value<String?> candidateCoverageId,
      Value<int> desiredRangeStartMs,
      Value<int> desiredRangeEndMs,
      Value<int> rowid,
    });

class $$LifeEventCoverageSeriesHeadsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventCoverageSeriesHeadsTable> {
  $$LifeEventCoverageSeriesHeadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get coverageSeriesId => $composableBuilder(
    column: $table.coverageSeriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesRevision => $composableBuilder(
    column: $table.seriesRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeCoverageId => $composableBuilder(
    column: $table.activeCoverageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get candidateCoverageId => $composableBuilder(
    column: $table.candidateCoverageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get desiredRangeStartMs => $composableBuilder(
    column: $table.desiredRangeStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get desiredRangeEndMs => $composableBuilder(
    column: $table.desiredRangeEndMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventCoverageSeriesHeadsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventCoverageSeriesHeadsTable> {
  $$LifeEventCoverageSeriesHeadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get coverageSeriesId => $composableBuilder(
    column: $table.coverageSeriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesRevision => $composableBuilder(
    column: $table.seriesRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeCoverageId => $composableBuilder(
    column: $table.activeCoverageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get candidateCoverageId => $composableBuilder(
    column: $table.candidateCoverageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get desiredRangeStartMs => $composableBuilder(
    column: $table.desiredRangeStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get desiredRangeEndMs => $composableBuilder(
    column: $table.desiredRangeEndMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventCoverageSeriesHeadsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventCoverageSeriesHeadsTable> {
  $$LifeEventCoverageSeriesHeadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get coverageSeriesId => $composableBuilder(
    column: $table.coverageSeriesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriesRevision => $composableBuilder(
    column: $table.seriesRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeCoverageId => $composableBuilder(
    column: $table.activeCoverageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get candidateCoverageId => $composableBuilder(
    column: $table.candidateCoverageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get desiredRangeStartMs => $composableBuilder(
    column: $table.desiredRangeStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get desiredRangeEndMs => $composableBuilder(
    column: $table.desiredRangeEndMs,
    builder: (column) => column,
  );
}

class $$LifeEventCoverageSeriesHeadsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventCoverageSeriesHeadsTable,
          LifeEventCoverageSeriesHeadRow,
          $$LifeEventCoverageSeriesHeadsTableFilterComposer,
          $$LifeEventCoverageSeriesHeadsTableOrderingComposer,
          $$LifeEventCoverageSeriesHeadsTableAnnotationComposer,
          $$LifeEventCoverageSeriesHeadsTableCreateCompanionBuilder,
          $$LifeEventCoverageSeriesHeadsTableUpdateCompanionBuilder,
          (
            LifeEventCoverageSeriesHeadRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventCoverageSeriesHeadsTable,
              LifeEventCoverageSeriesHeadRow
            >,
          ),
          LifeEventCoverageSeriesHeadRow,
          PrefetchHooks Function()
        > {
  $$LifeEventCoverageSeriesHeadsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventCoverageSeriesHeadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventCoverageSeriesHeadsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventCoverageSeriesHeadsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventCoverageSeriesHeadsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> coverageSeriesId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> chartSnapshotId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> eventTypeId = const Value.absent(),
                Value<int> seriesRevision = const Value.absent(),
                Value<String?> activeCoverageId = const Value.absent(),
                Value<String?> candidateCoverageId = const Value.absent(),
                Value<int> desiredRangeStartMs = const Value.absent(),
                Value<int> desiredRangeEndMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventCoverageSeriesHeadsCompanion(
                coverageSeriesId: coverageSeriesId,
                ownerScopeId: ownerScopeId,
                profileId: profileId,
                chartSnapshotId: chartSnapshotId,
                providerId: providerId,
                eventTypeId: eventTypeId,
                seriesRevision: seriesRevision,
                activeCoverageId: activeCoverageId,
                candidateCoverageId: candidateCoverageId,
                desiredRangeStartMs: desiredRangeStartMs,
                desiredRangeEndMs: desiredRangeEndMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String coverageSeriesId,
                required String ownerScopeId,
                required String profileId,
                required String chartSnapshotId,
                required String providerId,
                required String eventTypeId,
                required int seriesRevision,
                Value<String?> activeCoverageId = const Value.absent(),
                Value<String?> candidateCoverageId = const Value.absent(),
                required int desiredRangeStartMs,
                required int desiredRangeEndMs,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventCoverageSeriesHeadsCompanion.insert(
                coverageSeriesId: coverageSeriesId,
                ownerScopeId: ownerScopeId,
                profileId: profileId,
                chartSnapshotId: chartSnapshotId,
                providerId: providerId,
                eventTypeId: eventTypeId,
                seriesRevision: seriesRevision,
                activeCoverageId: activeCoverageId,
                candidateCoverageId: candidateCoverageId,
                desiredRangeStartMs: desiredRangeStartMs,
                desiredRangeEndMs: desiredRangeEndMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventCoverageSeriesHeadsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventCoverageSeriesHeadsTable,
      LifeEventCoverageSeriesHeadRow,
      $$LifeEventCoverageSeriesHeadsTableFilterComposer,
      $$LifeEventCoverageSeriesHeadsTableOrderingComposer,
      $$LifeEventCoverageSeriesHeadsTableAnnotationComposer,
      $$LifeEventCoverageSeriesHeadsTableCreateCompanionBuilder,
      $$LifeEventCoverageSeriesHeadsTableUpdateCompanionBuilder,
      (
        LifeEventCoverageSeriesHeadRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventCoverageSeriesHeadsTable,
          LifeEventCoverageSeriesHeadRow
        >,
      ),
      LifeEventCoverageSeriesHeadRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventCoverageManifestsTableCreateCompanionBuilder =
    LifeEventCoverageManifestsCompanion Function({
      required String coverageId,
      required String coverageSeriesId,
      required int coverageGeneration,
      required int manifestRevision,
      required int servingState,
      required String profileId,
      required String chartSnapshotId,
      required String chartSnapshotRevision,
      required String providerId,
      required String providerVersion,
      required String algorithmVersion,
      Value<String?> dataVersion,
      required String eventTypeId,
      required String eventTypeSchemaVersion,
      required int requestedRangeStartMs,
      required int requestedRangeEndMs,
      required String coveredRangesJson,
      required int status,
      required String inputFingerprint,
      required int expectedShardCount,
      required int completedShardCount,
      required int sourceEventCount,
      required String outputDigest,
      required int startedAtMs,
      Value<int?> completedAtMs,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });
typedef $$LifeEventCoverageManifestsTableUpdateCompanionBuilder =
    LifeEventCoverageManifestsCompanion Function({
      Value<String> coverageId,
      Value<String> coverageSeriesId,
      Value<int> coverageGeneration,
      Value<int> manifestRevision,
      Value<int> servingState,
      Value<String> profileId,
      Value<String> chartSnapshotId,
      Value<String> chartSnapshotRevision,
      Value<String> providerId,
      Value<String> providerVersion,
      Value<String> algorithmVersion,
      Value<String?> dataVersion,
      Value<String> eventTypeId,
      Value<String> eventTypeSchemaVersion,
      Value<int> requestedRangeStartMs,
      Value<int> requestedRangeEndMs,
      Value<String> coveredRangesJson,
      Value<int> status,
      Value<String> inputFingerprint,
      Value<int> expectedShardCount,
      Value<int> completedShardCount,
      Value<int> sourceEventCount,
      Value<String> outputDigest,
      Value<int> startedAtMs,
      Value<int?> completedAtMs,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });

class $$LifeEventCoverageManifestsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventCoverageManifestsTable> {
  $$LifeEventCoverageManifestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverageSeriesId => $composableBuilder(
    column: $table.coverageSeriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manifestRevision => $composableBuilder(
    column: $table.manifestRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servingState => $composableBuilder(
    column: $table.servingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chartSnapshotRevision => $composableBuilder(
    column: $table.chartSnapshotRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTypeSchemaVersion => $composableBuilder(
    column: $table.eventTypeSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedRangeStartMs => $composableBuilder(
    column: $table.requestedRangeStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedRangeEndMs => $composableBuilder(
    column: $table.requestedRangeEndMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coveredRangesJson => $composableBuilder(
    column: $table.coveredRangesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedShardCount => $composableBuilder(
    column: $table.expectedShardCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedShardCount => $composableBuilder(
    column: $table.completedShardCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceEventCount => $composableBuilder(
    column: $table.sourceEventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputDigest => $composableBuilder(
    column: $table.outputDigest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventCoverageManifestsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventCoverageManifestsTable> {
  $$LifeEventCoverageManifestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverageSeriesId => $composableBuilder(
    column: $table.coverageSeriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manifestRevision => $composableBuilder(
    column: $table.manifestRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servingState => $composableBuilder(
    column: $table.servingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chartSnapshotRevision => $composableBuilder(
    column: $table.chartSnapshotRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTypeSchemaVersion => $composableBuilder(
    column: $table.eventTypeSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedRangeStartMs => $composableBuilder(
    column: $table.requestedRangeStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedRangeEndMs => $composableBuilder(
    column: $table.requestedRangeEndMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coveredRangesJson => $composableBuilder(
    column: $table.coveredRangesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedShardCount => $composableBuilder(
    column: $table.expectedShardCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedShardCount => $composableBuilder(
    column: $table.completedShardCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceEventCount => $composableBuilder(
    column: $table.sourceEventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputDigest => $composableBuilder(
    column: $table.outputDigest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventCoverageManifestsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventCoverageManifestsTable> {
  $$LifeEventCoverageManifestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverageSeriesId => $composableBuilder(
    column: $table.coverageSeriesId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get manifestRevision => $composableBuilder(
    column: $table.manifestRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get servingState => $composableBuilder(
    column: $table.servingState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get chartSnapshotId => $composableBuilder(
    column: $table.chartSnapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chartSnapshotRevision => $composableBuilder(
    column: $table.chartSnapshotRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerVersion => $composableBuilder(
    column: $table.providerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventTypeSchemaVersion => $composableBuilder(
    column: $table.eventTypeSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedRangeStartMs => $composableBuilder(
    column: $table.requestedRangeStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedRangeEndMs => $composableBuilder(
    column: $table.requestedRangeEndMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coveredRangesJson => $composableBuilder(
    column: $table.coveredRangesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedShardCount => $composableBuilder(
    column: $table.expectedShardCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedShardCount => $composableBuilder(
    column: $table.completedShardCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceEventCount => $composableBuilder(
    column: $table.sourceEventCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outputDigest => $composableBuilder(
    column: $table.outputDigest,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );
}

class $$LifeEventCoverageManifestsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventCoverageManifestsTable,
          LifeEventCoverageManifestRow,
          $$LifeEventCoverageManifestsTableFilterComposer,
          $$LifeEventCoverageManifestsTableOrderingComposer,
          $$LifeEventCoverageManifestsTableAnnotationComposer,
          $$LifeEventCoverageManifestsTableCreateCompanionBuilder,
          $$LifeEventCoverageManifestsTableUpdateCompanionBuilder,
          (
            LifeEventCoverageManifestRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventCoverageManifestsTable,
              LifeEventCoverageManifestRow
            >,
          ),
          LifeEventCoverageManifestRow,
          PrefetchHooks Function()
        > {
  $$LifeEventCoverageManifestsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventCoverageManifestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventCoverageManifestsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventCoverageManifestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventCoverageManifestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> coverageId = const Value.absent(),
                Value<String> coverageSeriesId = const Value.absent(),
                Value<int> coverageGeneration = const Value.absent(),
                Value<int> manifestRevision = const Value.absent(),
                Value<int> servingState = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> chartSnapshotId = const Value.absent(),
                Value<String> chartSnapshotRevision = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> providerVersion = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<String?> dataVersion = const Value.absent(),
                Value<String> eventTypeId = const Value.absent(),
                Value<String> eventTypeSchemaVersion = const Value.absent(),
                Value<int> requestedRangeStartMs = const Value.absent(),
                Value<int> requestedRangeEndMs = const Value.absent(),
                Value<String> coveredRangesJson = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String> inputFingerprint = const Value.absent(),
                Value<int> expectedShardCount = const Value.absent(),
                Value<int> completedShardCount = const Value.absent(),
                Value<int> sourceEventCount = const Value.absent(),
                Value<String> outputDigest = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int?> completedAtMs = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventCoverageManifestsCompanion(
                coverageId: coverageId,
                coverageSeriesId: coverageSeriesId,
                coverageGeneration: coverageGeneration,
                manifestRevision: manifestRevision,
                servingState: servingState,
                profileId: profileId,
                chartSnapshotId: chartSnapshotId,
                chartSnapshotRevision: chartSnapshotRevision,
                providerId: providerId,
                providerVersion: providerVersion,
                algorithmVersion: algorithmVersion,
                dataVersion: dataVersion,
                eventTypeId: eventTypeId,
                eventTypeSchemaVersion: eventTypeSchemaVersion,
                requestedRangeStartMs: requestedRangeStartMs,
                requestedRangeEndMs: requestedRangeEndMs,
                coveredRangesJson: coveredRangesJson,
                status: status,
                inputFingerprint: inputFingerprint,
                expectedShardCount: expectedShardCount,
                completedShardCount: completedShardCount,
                sourceEventCount: sourceEventCount,
                outputDigest: outputDigest,
                startedAtMs: startedAtMs,
                completedAtMs: completedAtMs,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String coverageId,
                required String coverageSeriesId,
                required int coverageGeneration,
                required int manifestRevision,
                required int servingState,
                required String profileId,
                required String chartSnapshotId,
                required String chartSnapshotRevision,
                required String providerId,
                required String providerVersion,
                required String algorithmVersion,
                Value<String?> dataVersion = const Value.absent(),
                required String eventTypeId,
                required String eventTypeSchemaVersion,
                required int requestedRangeStartMs,
                required int requestedRangeEndMs,
                required String coveredRangesJson,
                required int status,
                required String inputFingerprint,
                required int expectedShardCount,
                required int completedShardCount,
                required int sourceEventCount,
                required String outputDigest,
                required int startedAtMs,
                Value<int?> completedAtMs = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventCoverageManifestsCompanion.insert(
                coverageId: coverageId,
                coverageSeriesId: coverageSeriesId,
                coverageGeneration: coverageGeneration,
                manifestRevision: manifestRevision,
                servingState: servingState,
                profileId: profileId,
                chartSnapshotId: chartSnapshotId,
                chartSnapshotRevision: chartSnapshotRevision,
                providerId: providerId,
                providerVersion: providerVersion,
                algorithmVersion: algorithmVersion,
                dataVersion: dataVersion,
                eventTypeId: eventTypeId,
                eventTypeSchemaVersion: eventTypeSchemaVersion,
                requestedRangeStartMs: requestedRangeStartMs,
                requestedRangeEndMs: requestedRangeEndMs,
                coveredRangesJson: coveredRangesJson,
                status: status,
                inputFingerprint: inputFingerprint,
                expectedShardCount: expectedShardCount,
                completedShardCount: completedShardCount,
                sourceEventCount: sourceEventCount,
                outputDigest: outputDigest,
                startedAtMs: startedAtMs,
                completedAtMs: completedAtMs,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventCoverageManifestsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventCoverageManifestsTable,
      LifeEventCoverageManifestRow,
      $$LifeEventCoverageManifestsTableFilterComposer,
      $$LifeEventCoverageManifestsTableOrderingComposer,
      $$LifeEventCoverageManifestsTableAnnotationComposer,
      $$LifeEventCoverageManifestsTableCreateCompanionBuilder,
      $$LifeEventCoverageManifestsTableUpdateCompanionBuilder,
      (
        LifeEventCoverageManifestRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventCoverageManifestsTable,
          LifeEventCoverageManifestRow
        >,
      ),
      LifeEventCoverageManifestRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventShardReceiptsTableCreateCompanionBuilder =
    LifeEventShardReceiptsCompanion Function({
      required String coverageId,
      required String shardId,
      required int coverageGeneration,
      required int requestedRangeStartMs,
      required int requestedRangeEndMs,
      required int coveredRangeStartMs,
      required int coveredRangeEndMs,
      required int eventCount,
      required String contentDigest,
      required int persistedCount,
      required String persistedDigest,
      required bool isCompleteForCoveredRange,
      required String inputFingerprint,
      required int committedAtMs,
      Value<int> rowid,
    });
typedef $$LifeEventShardReceiptsTableUpdateCompanionBuilder =
    LifeEventShardReceiptsCompanion Function({
      Value<String> coverageId,
      Value<String> shardId,
      Value<int> coverageGeneration,
      Value<int> requestedRangeStartMs,
      Value<int> requestedRangeEndMs,
      Value<int> coveredRangeStartMs,
      Value<int> coveredRangeEndMs,
      Value<int> eventCount,
      Value<String> contentDigest,
      Value<int> persistedCount,
      Value<String> persistedDigest,
      Value<bool> isCompleteForCoveredRange,
      Value<String> inputFingerprint,
      Value<int> committedAtMs,
      Value<int> rowid,
    });

class $$LifeEventShardReceiptsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventShardReceiptsTable> {
  $$LifeEventShardReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shardId => $composableBuilder(
    column: $table.shardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedRangeStartMs => $composableBuilder(
    column: $table.requestedRangeStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedRangeEndMs => $composableBuilder(
    column: $table.requestedRangeEndMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coveredRangeStartMs => $composableBuilder(
    column: $table.coveredRangeStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coveredRangeEndMs => $composableBuilder(
    column: $table.coveredRangeEndMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentDigest => $composableBuilder(
    column: $table.contentDigest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get persistedCount => $composableBuilder(
    column: $table.persistedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get persistedDigest => $composableBuilder(
    column: $table.persistedDigest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleteForCoveredRange => $composableBuilder(
    column: $table.isCompleteForCoveredRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get committedAtMs => $composableBuilder(
    column: $table.committedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventShardReceiptsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventShardReceiptsTable> {
  $$LifeEventShardReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shardId => $composableBuilder(
    column: $table.shardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedRangeStartMs => $composableBuilder(
    column: $table.requestedRangeStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedRangeEndMs => $composableBuilder(
    column: $table.requestedRangeEndMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coveredRangeStartMs => $composableBuilder(
    column: $table.coveredRangeStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coveredRangeEndMs => $composableBuilder(
    column: $table.coveredRangeEndMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentDigest => $composableBuilder(
    column: $table.contentDigest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get persistedCount => $composableBuilder(
    column: $table.persistedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get persistedDigest => $composableBuilder(
    column: $table.persistedDigest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleteForCoveredRange => $composableBuilder(
    column: $table.isCompleteForCoveredRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get committedAtMs => $composableBuilder(
    column: $table.committedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventShardReceiptsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventShardReceiptsTable> {
  $$LifeEventShardReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get coverageId => $composableBuilder(
    column: $table.coverageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shardId =>
      $composableBuilder(column: $table.shardId, builder: (column) => column);

  GeneratedColumn<int> get coverageGeneration => $composableBuilder(
    column: $table.coverageGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedRangeStartMs => $composableBuilder(
    column: $table.requestedRangeStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedRangeEndMs => $composableBuilder(
    column: $table.requestedRangeEndMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coveredRangeStartMs => $composableBuilder(
    column: $table.coveredRangeStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coveredRangeEndMs => $composableBuilder(
    column: $table.coveredRangeEndMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentDigest => $composableBuilder(
    column: $table.contentDigest,
    builder: (column) => column,
  );

  GeneratedColumn<int> get persistedCount => $composableBuilder(
    column: $table.persistedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get persistedDigest => $composableBuilder(
    column: $table.persistedDigest,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleteForCoveredRange => $composableBuilder(
    column: $table.isCompleteForCoveredRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputFingerprint => $composableBuilder(
    column: $table.inputFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get committedAtMs => $composableBuilder(
    column: $table.committedAtMs,
    builder: (column) => column,
  );
}

class $$LifeEventShardReceiptsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventShardReceiptsTable,
          LifeEventShardReceiptRow,
          $$LifeEventShardReceiptsTableFilterComposer,
          $$LifeEventShardReceiptsTableOrderingComposer,
          $$LifeEventShardReceiptsTableAnnotationComposer,
          $$LifeEventShardReceiptsTableCreateCompanionBuilder,
          $$LifeEventShardReceiptsTableUpdateCompanionBuilder,
          (
            LifeEventShardReceiptRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventShardReceiptsTable,
              LifeEventShardReceiptRow
            >,
          ),
          LifeEventShardReceiptRow,
          PrefetchHooks Function()
        > {
  $$LifeEventShardReceiptsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventShardReceiptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventShardReceiptsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventShardReceiptsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventShardReceiptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> coverageId = const Value.absent(),
                Value<String> shardId = const Value.absent(),
                Value<int> coverageGeneration = const Value.absent(),
                Value<int> requestedRangeStartMs = const Value.absent(),
                Value<int> requestedRangeEndMs = const Value.absent(),
                Value<int> coveredRangeStartMs = const Value.absent(),
                Value<int> coveredRangeEndMs = const Value.absent(),
                Value<int> eventCount = const Value.absent(),
                Value<String> contentDigest = const Value.absent(),
                Value<int> persistedCount = const Value.absent(),
                Value<String> persistedDigest = const Value.absent(),
                Value<bool> isCompleteForCoveredRange = const Value.absent(),
                Value<String> inputFingerprint = const Value.absent(),
                Value<int> committedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventShardReceiptsCompanion(
                coverageId: coverageId,
                shardId: shardId,
                coverageGeneration: coverageGeneration,
                requestedRangeStartMs: requestedRangeStartMs,
                requestedRangeEndMs: requestedRangeEndMs,
                coveredRangeStartMs: coveredRangeStartMs,
                coveredRangeEndMs: coveredRangeEndMs,
                eventCount: eventCount,
                contentDigest: contentDigest,
                persistedCount: persistedCount,
                persistedDigest: persistedDigest,
                isCompleteForCoveredRange: isCompleteForCoveredRange,
                inputFingerprint: inputFingerprint,
                committedAtMs: committedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String coverageId,
                required String shardId,
                required int coverageGeneration,
                required int requestedRangeStartMs,
                required int requestedRangeEndMs,
                required int coveredRangeStartMs,
                required int coveredRangeEndMs,
                required int eventCount,
                required String contentDigest,
                required int persistedCount,
                required String persistedDigest,
                required bool isCompleteForCoveredRange,
                required String inputFingerprint,
                required int committedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventShardReceiptsCompanion.insert(
                coverageId: coverageId,
                shardId: shardId,
                coverageGeneration: coverageGeneration,
                requestedRangeStartMs: requestedRangeStartMs,
                requestedRangeEndMs: requestedRangeEndMs,
                coveredRangeStartMs: coveredRangeStartMs,
                coveredRangeEndMs: coveredRangeEndMs,
                eventCount: eventCount,
                contentDigest: contentDigest,
                persistedCount: persistedCount,
                persistedDigest: persistedDigest,
                isCompleteForCoveredRange: isCompleteForCoveredRange,
                inputFingerprint: inputFingerprint,
                committedAtMs: committedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventShardReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventShardReceiptsTable,
      LifeEventShardReceiptRow,
      $$LifeEventShardReceiptsTableFilterComposer,
      $$LifeEventShardReceiptsTableOrderingComposer,
      $$LifeEventShardReceiptsTableAnnotationComposer,
      $$LifeEventShardReceiptsTableCreateCompanionBuilder,
      $$LifeEventShardReceiptsTableUpdateCompanionBuilder,
      (
        LifeEventShardReceiptRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventShardReceiptsTable,
          LifeEventShardReceiptRow
        >,
      ),
      LifeEventShardReceiptRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventUserDirectionsTableCreateCompanionBuilder =
    LifeEventUserDirectionsCompanion Function({
      required String directionId,
      required String ownerScopeId,
      required String label,
      Value<String?> color,
      required int sortOrder,
      Value<int?> archivedAtMs,
      Value<int> rowid,
    });
typedef $$LifeEventUserDirectionsTableUpdateCompanionBuilder =
    LifeEventUserDirectionsCompanion Function({
      Value<String> directionId,
      Value<String> ownerScopeId,
      Value<String> label,
      Value<String?> color,
      Value<int> sortOrder,
      Value<int?> archivedAtMs,
      Value<int> rowid,
    });

class $$LifeEventUserDirectionsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventUserDirectionsTable> {
  $$LifeEventUserDirectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get directionId => $composableBuilder(
    column: $table.directionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAtMs => $composableBuilder(
    column: $table.archivedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventUserDirectionsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventUserDirectionsTable> {
  $$LifeEventUserDirectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get directionId => $composableBuilder(
    column: $table.directionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAtMs => $composableBuilder(
    column: $table.archivedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventUserDirectionsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventUserDirectionsTable> {
  $$LifeEventUserDirectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get directionId => $composableBuilder(
    column: $table.directionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get archivedAtMs => $composableBuilder(
    column: $table.archivedAtMs,
    builder: (column) => column,
  );
}

class $$LifeEventUserDirectionsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventUserDirectionsTable,
          LifeEventUserDirectionRow,
          $$LifeEventUserDirectionsTableFilterComposer,
          $$LifeEventUserDirectionsTableOrderingComposer,
          $$LifeEventUserDirectionsTableAnnotationComposer,
          $$LifeEventUserDirectionsTableCreateCompanionBuilder,
          $$LifeEventUserDirectionsTableUpdateCompanionBuilder,
          (
            LifeEventUserDirectionRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventUserDirectionsTable,
              LifeEventUserDirectionRow
            >,
          ),
          LifeEventUserDirectionRow,
          PrefetchHooks Function()
        > {
  $$LifeEventUserDirectionsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventUserDirectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventUserDirectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventUserDirectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventUserDirectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> directionId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> archivedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventUserDirectionsCompanion(
                directionId: directionId,
                ownerScopeId: ownerScopeId,
                label: label,
                color: color,
                sortOrder: sortOrder,
                archivedAtMs: archivedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String directionId,
                required String ownerScopeId,
                required String label,
                Value<String?> color = const Value.absent(),
                required int sortOrder,
                Value<int?> archivedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventUserDirectionsCompanion.insert(
                directionId: directionId,
                ownerScopeId: ownerScopeId,
                label: label,
                color: color,
                sortOrder: sortOrder,
                archivedAtMs: archivedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventUserDirectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventUserDirectionsTable,
      LifeEventUserDirectionRow,
      $$LifeEventUserDirectionsTableFilterComposer,
      $$LifeEventUserDirectionsTableOrderingComposer,
      $$LifeEventUserDirectionsTableAnnotationComposer,
      $$LifeEventUserDirectionsTableCreateCompanionBuilder,
      $$LifeEventUserDirectionsTableUpdateCompanionBuilder,
      (
        LifeEventUserDirectionRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventUserDirectionsTable,
          LifeEventUserDirectionRow
        >,
      ),
      LifeEventUserDirectionRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventUserAnnotationsTableCreateCompanionBuilder =
    LifeEventUserAnnotationsCompanion Function({
      required String annotationId,
      required String ownerScopeId,
      Value<String?> title,
      Value<String?> interpretation,
      Value<String?> importanceOwnerScopeId,
      Value<String?> importanceCatalogId,
      Value<int?> importanceCatalogRevision,
      Value<String?> importanceLevelId,
      Value<String> tagsJson,
      required int revision,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$LifeEventUserAnnotationsTableUpdateCompanionBuilder =
    LifeEventUserAnnotationsCompanion Function({
      Value<String> annotationId,
      Value<String> ownerScopeId,
      Value<String?> title,
      Value<String?> interpretation,
      Value<String?> importanceOwnerScopeId,
      Value<String?> importanceCatalogId,
      Value<int?> importanceCatalogRevision,
      Value<String?> importanceLevelId,
      Value<String> tagsJson,
      Value<int> revision,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$LifeEventUserAnnotationsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventUserAnnotationsTable> {
  $$LifeEventUserAnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interpretation => $composableBuilder(
    column: $table.interpretation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importanceOwnerScopeId => $composableBuilder(
    column: $table.importanceOwnerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importanceCatalogId => $composableBuilder(
    column: $table.importanceCatalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importanceCatalogRevision => $composableBuilder(
    column: $table.importanceCatalogRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importanceLevelId => $composableBuilder(
    column: $table.importanceLevelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventUserAnnotationsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventUserAnnotationsTable> {
  $$LifeEventUserAnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interpretation => $composableBuilder(
    column: $table.interpretation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importanceOwnerScopeId => $composableBuilder(
    column: $table.importanceOwnerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importanceCatalogId => $composableBuilder(
    column: $table.importanceCatalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importanceCatalogRevision => $composableBuilder(
    column: $table.importanceCatalogRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importanceLevelId => $composableBuilder(
    column: $table.importanceLevelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventUserAnnotationsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventUserAnnotationsTable> {
  $$LifeEventUserAnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get interpretation => $composableBuilder(
    column: $table.interpretation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importanceOwnerScopeId => $composableBuilder(
    column: $table.importanceOwnerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importanceCatalogId => $composableBuilder(
    column: $table.importanceCatalogId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importanceCatalogRevision => $composableBuilder(
    column: $table.importanceCatalogRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importanceLevelId => $composableBuilder(
    column: $table.importanceLevelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$LifeEventUserAnnotationsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventUserAnnotationsTable,
          LifeEventUserAnnotationRow,
          $$LifeEventUserAnnotationsTableFilterComposer,
          $$LifeEventUserAnnotationsTableOrderingComposer,
          $$LifeEventUserAnnotationsTableAnnotationComposer,
          $$LifeEventUserAnnotationsTableCreateCompanionBuilder,
          $$LifeEventUserAnnotationsTableUpdateCompanionBuilder,
          (
            LifeEventUserAnnotationRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventUserAnnotationsTable,
              LifeEventUserAnnotationRow
            >,
          ),
          LifeEventUserAnnotationRow,
          PrefetchHooks Function()
        > {
  $$LifeEventUserAnnotationsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventUserAnnotationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventUserAnnotationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventUserAnnotationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventUserAnnotationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> annotationId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> interpretation = const Value.absent(),
                Value<String?> importanceOwnerScopeId = const Value.absent(),
                Value<String?> importanceCatalogId = const Value.absent(),
                Value<int?> importanceCatalogRevision = const Value.absent(),
                Value<String?> importanceLevelId = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventUserAnnotationsCompanion(
                annotationId: annotationId,
                ownerScopeId: ownerScopeId,
                title: title,
                interpretation: interpretation,
                importanceOwnerScopeId: importanceOwnerScopeId,
                importanceCatalogId: importanceCatalogId,
                importanceCatalogRevision: importanceCatalogRevision,
                importanceLevelId: importanceLevelId,
                tagsJson: tagsJson,
                revision: revision,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String annotationId,
                required String ownerScopeId,
                Value<String?> title = const Value.absent(),
                Value<String?> interpretation = const Value.absent(),
                Value<String?> importanceOwnerScopeId = const Value.absent(),
                Value<String?> importanceCatalogId = const Value.absent(),
                Value<int?> importanceCatalogRevision = const Value.absent(),
                Value<String?> importanceLevelId = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                required int revision,
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventUserAnnotationsCompanion.insert(
                annotationId: annotationId,
                ownerScopeId: ownerScopeId,
                title: title,
                interpretation: interpretation,
                importanceOwnerScopeId: importanceOwnerScopeId,
                importanceCatalogId: importanceCatalogId,
                importanceCatalogRevision: importanceCatalogRevision,
                importanceLevelId: importanceLevelId,
                tagsJson: tagsJson,
                revision: revision,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventUserAnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventUserAnnotationsTable,
      LifeEventUserAnnotationRow,
      $$LifeEventUserAnnotationsTableFilterComposer,
      $$LifeEventUserAnnotationsTableOrderingComposer,
      $$LifeEventUserAnnotationsTableAnnotationComposer,
      $$LifeEventUserAnnotationsTableCreateCompanionBuilder,
      $$LifeEventUserAnnotationsTableUpdateCompanionBuilder,
      (
        LifeEventUserAnnotationRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventUserAnnotationsTable,
          LifeEventUserAnnotationRow
        >,
      ),
      LifeEventUserAnnotationRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventAnnotationTargetRefsTableCreateCompanionBuilder =
    LifeEventAnnotationTargetRefsCompanion Function({
      required String annotationId,
      required String providerId,
      required String sourceEventId,
      required String eventRevision,
      Value<int> rowid,
    });
typedef $$LifeEventAnnotationTargetRefsTableUpdateCompanionBuilder =
    LifeEventAnnotationTargetRefsCompanion Function({
      Value<String> annotationId,
      Value<String> providerId,
      Value<String> sourceEventId,
      Value<String> eventRevision,
      Value<int> rowid,
    });

class $$LifeEventAnnotationTargetRefsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventAnnotationTargetRefsTable> {
  $$LifeEventAnnotationTargetRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventAnnotationTargetRefsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventAnnotationTargetRefsTable> {
  $$LifeEventAnnotationTargetRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventAnnotationTargetRefsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventAnnotationTargetRefsTable> {
  $$LifeEventAnnotationTargetRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => column,
  );
}

class $$LifeEventAnnotationTargetRefsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventAnnotationTargetRefsTable,
          LifeEventAnnotationTargetRefRow,
          $$LifeEventAnnotationTargetRefsTableFilterComposer,
          $$LifeEventAnnotationTargetRefsTableOrderingComposer,
          $$LifeEventAnnotationTargetRefsTableAnnotationComposer,
          $$LifeEventAnnotationTargetRefsTableCreateCompanionBuilder,
          $$LifeEventAnnotationTargetRefsTableUpdateCompanionBuilder,
          (
            LifeEventAnnotationTargetRefRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventAnnotationTargetRefsTable,
              LifeEventAnnotationTargetRefRow
            >,
          ),
          LifeEventAnnotationTargetRefRow,
          PrefetchHooks Function()
        > {
  $$LifeEventAnnotationTargetRefsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventAnnotationTargetRefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventAnnotationTargetRefsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventAnnotationTargetRefsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventAnnotationTargetRefsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> annotationId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> sourceEventId = const Value.absent(),
                Value<String> eventRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventAnnotationTargetRefsCompanion(
                annotationId: annotationId,
                providerId: providerId,
                sourceEventId: sourceEventId,
                eventRevision: eventRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String annotationId,
                required String providerId,
                required String sourceEventId,
                required String eventRevision,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventAnnotationTargetRefsCompanion.insert(
                annotationId: annotationId,
                providerId: providerId,
                sourceEventId: sourceEventId,
                eventRevision: eventRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventAnnotationTargetRefsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventAnnotationTargetRefsTable,
      LifeEventAnnotationTargetRefRow,
      $$LifeEventAnnotationTargetRefsTableFilterComposer,
      $$LifeEventAnnotationTargetRefsTableOrderingComposer,
      $$LifeEventAnnotationTargetRefsTableAnnotationComposer,
      $$LifeEventAnnotationTargetRefsTableCreateCompanionBuilder,
      $$LifeEventAnnotationTargetRefsTableUpdateCompanionBuilder,
      (
        LifeEventAnnotationTargetRefRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventAnnotationTargetRefsTable,
          LifeEventAnnotationTargetRefRow
        >,
      ),
      LifeEventAnnotationTargetRefRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventAnnotationDirectionRefsTableCreateCompanionBuilder =
    LifeEventAnnotationDirectionRefsCompanion Function({
      required String annotationId,
      required String directionId,
      Value<int> rowid,
    });
typedef $$LifeEventAnnotationDirectionRefsTableUpdateCompanionBuilder =
    LifeEventAnnotationDirectionRefsCompanion Function({
      Value<String> annotationId,
      Value<String> directionId,
      Value<int> rowid,
    });

class $$LifeEventAnnotationDirectionRefsTableFilterComposer
    extends
        Composer<_$LifeEventDatabase, $LifeEventAnnotationDirectionRefsTable> {
  $$LifeEventAnnotationDirectionRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directionId => $composableBuilder(
    column: $table.directionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventAnnotationDirectionRefsTableOrderingComposer
    extends
        Composer<_$LifeEventDatabase, $LifeEventAnnotationDirectionRefsTable> {
  $$LifeEventAnnotationDirectionRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directionId => $composableBuilder(
    column: $table.directionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventAnnotationDirectionRefsTableAnnotationComposer
    extends
        Composer<_$LifeEventDatabase, $LifeEventAnnotationDirectionRefsTable> {
  $$LifeEventAnnotationDirectionRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get annotationId => $composableBuilder(
    column: $table.annotationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directionId => $composableBuilder(
    column: $table.directionId,
    builder: (column) => column,
  );
}

class $$LifeEventAnnotationDirectionRefsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventAnnotationDirectionRefsTable,
          LifeEventAnnotationDirectionRefRow,
          $$LifeEventAnnotationDirectionRefsTableFilterComposer,
          $$LifeEventAnnotationDirectionRefsTableOrderingComposer,
          $$LifeEventAnnotationDirectionRefsTableAnnotationComposer,
          $$LifeEventAnnotationDirectionRefsTableCreateCompanionBuilder,
          $$LifeEventAnnotationDirectionRefsTableUpdateCompanionBuilder,
          (
            LifeEventAnnotationDirectionRefRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventAnnotationDirectionRefsTable,
              LifeEventAnnotationDirectionRefRow
            >,
          ),
          LifeEventAnnotationDirectionRefRow,
          PrefetchHooks Function()
        > {
  $$LifeEventAnnotationDirectionRefsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventAnnotationDirectionRefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventAnnotationDirectionRefsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventAnnotationDirectionRefsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventAnnotationDirectionRefsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> annotationId = const Value.absent(),
                Value<String> directionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventAnnotationDirectionRefsCompanion(
                annotationId: annotationId,
                directionId: directionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String annotationId,
                required String directionId,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventAnnotationDirectionRefsCompanion.insert(
                annotationId: annotationId,
                directionId: directionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventAnnotationDirectionRefsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventAnnotationDirectionRefsTable,
      LifeEventAnnotationDirectionRefRow,
      $$LifeEventAnnotationDirectionRefsTableFilterComposer,
      $$LifeEventAnnotationDirectionRefsTableOrderingComposer,
      $$LifeEventAnnotationDirectionRefsTableAnnotationComposer,
      $$LifeEventAnnotationDirectionRefsTableCreateCompanionBuilder,
      $$LifeEventAnnotationDirectionRefsTableUpdateCompanionBuilder,
      (
        LifeEventAnnotationDirectionRefRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventAnnotationDirectionRefsTable,
          LifeEventAnnotationDirectionRefRow
        >,
      ),
      LifeEventAnnotationDirectionRefRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventOccurrenceSelectionsTableCreateCompanionBuilder =
    LifeEventOccurrenceSelectionsCompanion Function({
      required String selectionId,
      required String ownerScopeId,
      required int revision,
      required String sourceProviderId,
      required String sourceEventId,
      required String sourceEventRevision,
      required String eventRevision,
      Value<String?> annotationRef,
      Value<int> rowid,
    });
typedef $$LifeEventOccurrenceSelectionsTableUpdateCompanionBuilder =
    LifeEventOccurrenceSelectionsCompanion Function({
      Value<String> selectionId,
      Value<String> ownerScopeId,
      Value<int> revision,
      Value<String> sourceProviderId,
      Value<String> sourceEventId,
      Value<String> sourceEventRevision,
      Value<String> eventRevision,
      Value<String?> annotationRef,
      Value<int> rowid,
    });

class $$LifeEventOccurrenceSelectionsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventOccurrenceSelectionsTable> {
  $$LifeEventOccurrenceSelectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get selectionId => $composableBuilder(
    column: $table.selectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEventRevision => $composableBuilder(
    column: $table.sourceEventRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get annotationRef => $composableBuilder(
    column: $table.annotationRef,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventOccurrenceSelectionsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventOccurrenceSelectionsTable> {
  $$LifeEventOccurrenceSelectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get selectionId => $composableBuilder(
    column: $table.selectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEventRevision => $composableBuilder(
    column: $table.sourceEventRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get annotationRef => $composableBuilder(
    column: $table.annotationRef,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventOccurrenceSelectionsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventOccurrenceSelectionsTable> {
  $$LifeEventOccurrenceSelectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get selectionId => $composableBuilder(
    column: $table.selectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceEventRevision => $composableBuilder(
    column: $table.sourceEventRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventRevision => $composableBuilder(
    column: $table.eventRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get annotationRef => $composableBuilder(
    column: $table.annotationRef,
    builder: (column) => column,
  );
}

class $$LifeEventOccurrenceSelectionsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventOccurrenceSelectionsTable,
          LifeEventOccurrenceSelectionRow,
          $$LifeEventOccurrenceSelectionsTableFilterComposer,
          $$LifeEventOccurrenceSelectionsTableOrderingComposer,
          $$LifeEventOccurrenceSelectionsTableAnnotationComposer,
          $$LifeEventOccurrenceSelectionsTableCreateCompanionBuilder,
          $$LifeEventOccurrenceSelectionsTableUpdateCompanionBuilder,
          (
            LifeEventOccurrenceSelectionRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventOccurrenceSelectionsTable,
              LifeEventOccurrenceSelectionRow
            >,
          ),
          LifeEventOccurrenceSelectionRow,
          PrefetchHooks Function()
        > {
  $$LifeEventOccurrenceSelectionsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventOccurrenceSelectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventOccurrenceSelectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventOccurrenceSelectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventOccurrenceSelectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> selectionId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> sourceProviderId = const Value.absent(),
                Value<String> sourceEventId = const Value.absent(),
                Value<String> sourceEventRevision = const Value.absent(),
                Value<String> eventRevision = const Value.absent(),
                Value<String?> annotationRef = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventOccurrenceSelectionsCompanion(
                selectionId: selectionId,
                ownerScopeId: ownerScopeId,
                revision: revision,
                sourceProviderId: sourceProviderId,
                sourceEventId: sourceEventId,
                sourceEventRevision: sourceEventRevision,
                eventRevision: eventRevision,
                annotationRef: annotationRef,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String selectionId,
                required String ownerScopeId,
                required int revision,
                required String sourceProviderId,
                required String sourceEventId,
                required String sourceEventRevision,
                required String eventRevision,
                Value<String?> annotationRef = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventOccurrenceSelectionsCompanion.insert(
                selectionId: selectionId,
                ownerScopeId: ownerScopeId,
                revision: revision,
                sourceProviderId: sourceProviderId,
                sourceEventId: sourceEventId,
                sourceEventRevision: sourceEventRevision,
                eventRevision: eventRevision,
                annotationRef: annotationRef,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventOccurrenceSelectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventOccurrenceSelectionsTable,
      LifeEventOccurrenceSelectionRow,
      $$LifeEventOccurrenceSelectionsTableFilterComposer,
      $$LifeEventOccurrenceSelectionsTableOrderingComposer,
      $$LifeEventOccurrenceSelectionsTableAnnotationComposer,
      $$LifeEventOccurrenceSelectionsTableCreateCompanionBuilder,
      $$LifeEventOccurrenceSelectionsTableUpdateCompanionBuilder,
      (
        LifeEventOccurrenceSelectionRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventOccurrenceSelectionsTable,
          LifeEventOccurrenceSelectionRow
        >,
      ),
      LifeEventOccurrenceSelectionRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventPatternRulesTableCreateCompanionBuilder =
    LifeEventPatternRulesCompanion Function({
      required String savedPatternId,
      required String ownerScopeId,
      required int revision,
      required String providerId,
      required String eventTypeId,
      required String patternSchemaVersion,
      required String providerDescriptorVersion,
      required String matcherSemanticVersion,
      required String normalizedPatternJson,
      required String patternFingerprint,
      Value<String?> annotationRef,
      required bool enabledForMatching,
      Value<int> rowid,
    });
typedef $$LifeEventPatternRulesTableUpdateCompanionBuilder =
    LifeEventPatternRulesCompanion Function({
      Value<String> savedPatternId,
      Value<String> ownerScopeId,
      Value<int> revision,
      Value<String> providerId,
      Value<String> eventTypeId,
      Value<String> patternSchemaVersion,
      Value<String> providerDescriptorVersion,
      Value<String> matcherSemanticVersion,
      Value<String> normalizedPatternJson,
      Value<String> patternFingerprint,
      Value<String?> annotationRef,
      Value<bool> enabledForMatching,
      Value<int> rowid,
    });

class $$LifeEventPatternRulesTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventPatternRulesTable> {
  $$LifeEventPatternRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get savedPatternId => $composableBuilder(
    column: $table.savedPatternId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternSchemaVersion => $composableBuilder(
    column: $table.patternSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerDescriptorVersion => $composableBuilder(
    column: $table.providerDescriptorVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matcherSemanticVersion => $composableBuilder(
    column: $table.matcherSemanticVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedPatternJson => $composableBuilder(
    column: $table.normalizedPatternJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternFingerprint => $composableBuilder(
    column: $table.patternFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get annotationRef => $composableBuilder(
    column: $table.annotationRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabledForMatching => $composableBuilder(
    column: $table.enabledForMatching,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventPatternRulesTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventPatternRulesTable> {
  $$LifeEventPatternRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get savedPatternId => $composableBuilder(
    column: $table.savedPatternId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternSchemaVersion => $composableBuilder(
    column: $table.patternSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerDescriptorVersion => $composableBuilder(
    column: $table.providerDescriptorVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matcherSemanticVersion => $composableBuilder(
    column: $table.matcherSemanticVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedPatternJson => $composableBuilder(
    column: $table.normalizedPatternJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternFingerprint => $composableBuilder(
    column: $table.patternFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get annotationRef => $composableBuilder(
    column: $table.annotationRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabledForMatching => $composableBuilder(
    column: $table.enabledForMatching,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventPatternRulesTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventPatternRulesTable> {
  $$LifeEventPatternRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get savedPatternId => $composableBuilder(
    column: $table.savedPatternId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventTypeId => $composableBuilder(
    column: $table.eventTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patternSchemaVersion => $composableBuilder(
    column: $table.patternSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerDescriptorVersion => $composableBuilder(
    column: $table.providerDescriptorVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matcherSemanticVersion => $composableBuilder(
    column: $table.matcherSemanticVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedPatternJson => $composableBuilder(
    column: $table.normalizedPatternJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patternFingerprint => $composableBuilder(
    column: $table.patternFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get annotationRef => $composableBuilder(
    column: $table.annotationRef,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabledForMatching => $composableBuilder(
    column: $table.enabledForMatching,
    builder: (column) => column,
  );
}

class $$LifeEventPatternRulesTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventPatternRulesTable,
          LifeEventPatternRuleRow,
          $$LifeEventPatternRulesTableFilterComposer,
          $$LifeEventPatternRulesTableOrderingComposer,
          $$LifeEventPatternRulesTableAnnotationComposer,
          $$LifeEventPatternRulesTableCreateCompanionBuilder,
          $$LifeEventPatternRulesTableUpdateCompanionBuilder,
          (
            LifeEventPatternRuleRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventPatternRulesTable,
              LifeEventPatternRuleRow
            >,
          ),
          LifeEventPatternRuleRow,
          PrefetchHooks Function()
        > {
  $$LifeEventPatternRulesTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventPatternRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventPatternRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventPatternRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventPatternRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> savedPatternId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> eventTypeId = const Value.absent(),
                Value<String> patternSchemaVersion = const Value.absent(),
                Value<String> providerDescriptorVersion = const Value.absent(),
                Value<String> matcherSemanticVersion = const Value.absent(),
                Value<String> normalizedPatternJson = const Value.absent(),
                Value<String> patternFingerprint = const Value.absent(),
                Value<String?> annotationRef = const Value.absent(),
                Value<bool> enabledForMatching = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventPatternRulesCompanion(
                savedPatternId: savedPatternId,
                ownerScopeId: ownerScopeId,
                revision: revision,
                providerId: providerId,
                eventTypeId: eventTypeId,
                patternSchemaVersion: patternSchemaVersion,
                providerDescriptorVersion: providerDescriptorVersion,
                matcherSemanticVersion: matcherSemanticVersion,
                normalizedPatternJson: normalizedPatternJson,
                patternFingerprint: patternFingerprint,
                annotationRef: annotationRef,
                enabledForMatching: enabledForMatching,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String savedPatternId,
                required String ownerScopeId,
                required int revision,
                required String providerId,
                required String eventTypeId,
                required String patternSchemaVersion,
                required String providerDescriptorVersion,
                required String matcherSemanticVersion,
                required String normalizedPatternJson,
                required String patternFingerprint,
                Value<String?> annotationRef = const Value.absent(),
                required bool enabledForMatching,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventPatternRulesCompanion.insert(
                savedPatternId: savedPatternId,
                ownerScopeId: ownerScopeId,
                revision: revision,
                providerId: providerId,
                eventTypeId: eventTypeId,
                patternSchemaVersion: patternSchemaVersion,
                providerDescriptorVersion: providerDescriptorVersion,
                matcherSemanticVersion: matcherSemanticVersion,
                normalizedPatternJson: normalizedPatternJson,
                patternFingerprint: patternFingerprint,
                annotationRef: annotationRef,
                enabledForMatching: enabledForMatching,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventPatternRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventPatternRulesTable,
      LifeEventPatternRuleRow,
      $$LifeEventPatternRulesTableFilterComposer,
      $$LifeEventPatternRulesTableOrderingComposer,
      $$LifeEventPatternRulesTableAnnotationComposer,
      $$LifeEventPatternRulesTableCreateCompanionBuilder,
      $$LifeEventPatternRulesTableUpdateCompanionBuilder,
      (
        LifeEventPatternRuleRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventPatternRulesTable,
          LifeEventPatternRuleRow
        >,
      ),
      LifeEventPatternRuleRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventPatternTargetRefsTableCreateCompanionBuilder =
    LifeEventPatternTargetRefsCompanion Function({
      required String savedPatternId,
      required String targetType,
      required String targetId,
      Value<int> rowid,
    });
typedef $$LifeEventPatternTargetRefsTableUpdateCompanionBuilder =
    LifeEventPatternTargetRefsCompanion Function({
      Value<String> savedPatternId,
      Value<String> targetType,
      Value<String> targetId,
      Value<int> rowid,
    });

class $$LifeEventPatternTargetRefsTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventPatternTargetRefsTable> {
  $$LifeEventPatternTargetRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get savedPatternId => $composableBuilder(
    column: $table.savedPatternId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventPatternTargetRefsTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventPatternTargetRefsTable> {
  $$LifeEventPatternTargetRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get savedPatternId => $composableBuilder(
    column: $table.savedPatternId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventPatternTargetRefsTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventPatternTargetRefsTable> {
  $$LifeEventPatternTargetRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get savedPatternId => $composableBuilder(
    column: $table.savedPatternId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);
}

class $$LifeEventPatternTargetRefsTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventPatternTargetRefsTable,
          LifeEventPatternTargetRefRow,
          $$LifeEventPatternTargetRefsTableFilterComposer,
          $$LifeEventPatternTargetRefsTableOrderingComposer,
          $$LifeEventPatternTargetRefsTableAnnotationComposer,
          $$LifeEventPatternTargetRefsTableCreateCompanionBuilder,
          $$LifeEventPatternTargetRefsTableUpdateCompanionBuilder,
          (
            LifeEventPatternTargetRefRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventPatternTargetRefsTable,
              LifeEventPatternTargetRefRow
            >,
          ),
          LifeEventPatternTargetRefRow,
          PrefetchHooks Function()
        > {
  $$LifeEventPatternTargetRefsTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventPatternTargetRefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventPatternTargetRefsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventPatternTargetRefsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventPatternTargetRefsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> savedPatternId = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventPatternTargetRefsCompanion(
                savedPatternId: savedPatternId,
                targetType: targetType,
                targetId: targetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String savedPatternId,
                required String targetType,
                required String targetId,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventPatternTargetRefsCompanion.insert(
                savedPatternId: savedPatternId,
                targetType: targetType,
                targetId: targetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventPatternTargetRefsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventPatternTargetRefsTable,
      LifeEventPatternTargetRefRow,
      $$LifeEventPatternTargetRefsTableFilterComposer,
      $$LifeEventPatternTargetRefsTableOrderingComposer,
      $$LifeEventPatternTargetRefsTableAnnotationComposer,
      $$LifeEventPatternTargetRefsTableCreateCompanionBuilder,
      $$LifeEventPatternTargetRefsTableUpdateCompanionBuilder,
      (
        LifeEventPatternTargetRefRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventPatternTargetRefsTable,
          LifeEventPatternTargetRefRow
        >,
      ),
      LifeEventPatternTargetRefRow,
      PrefetchHooks Function()
    >;
typedef $$LifeEventRuleTemplatesTableCreateCompanionBuilder =
    LifeEventRuleTemplatesCompanion Function({
      required String templateId,
      required String ownerScopeId,
      required int revision,
      required String providerPatternJson,
      required String defaultDirectionIdsJson,
      Value<String?> importanceOwnerScopeId,
      Value<String?> importanceCatalogId,
      Value<int?> importanceCatalogRevision,
      Value<String?> importanceLevelId,
      Value<String?> priorityOwnerScopeId,
      Value<String?> priorityCatalogId,
      Value<int?> priorityCatalogRevision,
      Value<String?> priorityId,
      required String defaultChannelIdsJson,
      required String defaultLeadTimesMsJson,
      Value<int> rowid,
    });
typedef $$LifeEventRuleTemplatesTableUpdateCompanionBuilder =
    LifeEventRuleTemplatesCompanion Function({
      Value<String> templateId,
      Value<String> ownerScopeId,
      Value<int> revision,
      Value<String> providerPatternJson,
      Value<String> defaultDirectionIdsJson,
      Value<String?> importanceOwnerScopeId,
      Value<String?> importanceCatalogId,
      Value<int?> importanceCatalogRevision,
      Value<String?> importanceLevelId,
      Value<String?> priorityOwnerScopeId,
      Value<String?> priorityCatalogId,
      Value<int?> priorityCatalogRevision,
      Value<String?> priorityId,
      Value<String> defaultChannelIdsJson,
      Value<String> defaultLeadTimesMsJson,
      Value<int> rowid,
    });

class $$LifeEventRuleTemplatesTableFilterComposer
    extends Composer<_$LifeEventDatabase, $LifeEventRuleTemplatesTable> {
  $$LifeEventRuleTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerPatternJson => $composableBuilder(
    column: $table.providerPatternJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultDirectionIdsJson => $composableBuilder(
    column: $table.defaultDirectionIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importanceOwnerScopeId => $composableBuilder(
    column: $table.importanceOwnerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importanceCatalogId => $composableBuilder(
    column: $table.importanceCatalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importanceCatalogRevision => $composableBuilder(
    column: $table.importanceCatalogRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importanceLevelId => $composableBuilder(
    column: $table.importanceLevelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priorityOwnerScopeId => $composableBuilder(
    column: $table.priorityOwnerScopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priorityCatalogId => $composableBuilder(
    column: $table.priorityCatalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorityCatalogRevision => $composableBuilder(
    column: $table.priorityCatalogRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priorityId => $composableBuilder(
    column: $table.priorityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultChannelIdsJson => $composableBuilder(
    column: $table.defaultChannelIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultLeadTimesMsJson => $composableBuilder(
    column: $table.defaultLeadTimesMsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeEventRuleTemplatesTableOrderingComposer
    extends Composer<_$LifeEventDatabase, $LifeEventRuleTemplatesTable> {
  $$LifeEventRuleTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerPatternJson => $composableBuilder(
    column: $table.providerPatternJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultDirectionIdsJson => $composableBuilder(
    column: $table.defaultDirectionIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importanceOwnerScopeId => $composableBuilder(
    column: $table.importanceOwnerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importanceCatalogId => $composableBuilder(
    column: $table.importanceCatalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importanceCatalogRevision => $composableBuilder(
    column: $table.importanceCatalogRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importanceLevelId => $composableBuilder(
    column: $table.importanceLevelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priorityOwnerScopeId => $composableBuilder(
    column: $table.priorityOwnerScopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priorityCatalogId => $composableBuilder(
    column: $table.priorityCatalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorityCatalogRevision => $composableBuilder(
    column: $table.priorityCatalogRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priorityId => $composableBuilder(
    column: $table.priorityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultChannelIdsJson => $composableBuilder(
    column: $table.defaultChannelIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultLeadTimesMsJson => $composableBuilder(
    column: $table.defaultLeadTimesMsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeEventRuleTemplatesTableAnnotationComposer
    extends Composer<_$LifeEventDatabase, $LifeEventRuleTemplatesTable> {
  $$LifeEventRuleTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScopeId => $composableBuilder(
    column: $table.ownerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get providerPatternJson => $composableBuilder(
    column: $table.providerPatternJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultDirectionIdsJson => $composableBuilder(
    column: $table.defaultDirectionIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importanceOwnerScopeId => $composableBuilder(
    column: $table.importanceOwnerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importanceCatalogId => $composableBuilder(
    column: $table.importanceCatalogId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importanceCatalogRevision => $composableBuilder(
    column: $table.importanceCatalogRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importanceLevelId => $composableBuilder(
    column: $table.importanceLevelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priorityOwnerScopeId => $composableBuilder(
    column: $table.priorityOwnerScopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priorityCatalogId => $composableBuilder(
    column: $table.priorityCatalogId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priorityCatalogRevision => $composableBuilder(
    column: $table.priorityCatalogRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priorityId => $composableBuilder(
    column: $table.priorityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultChannelIdsJson => $composableBuilder(
    column: $table.defaultChannelIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultLeadTimesMsJson => $composableBuilder(
    column: $table.defaultLeadTimesMsJson,
    builder: (column) => column,
  );
}

class $$LifeEventRuleTemplatesTableTableManager
    extends
        RootTableManager<
          _$LifeEventDatabase,
          $LifeEventRuleTemplatesTable,
          LifeEventRuleTemplateRow,
          $$LifeEventRuleTemplatesTableFilterComposer,
          $$LifeEventRuleTemplatesTableOrderingComposer,
          $$LifeEventRuleTemplatesTableAnnotationComposer,
          $$LifeEventRuleTemplatesTableCreateCompanionBuilder,
          $$LifeEventRuleTemplatesTableUpdateCompanionBuilder,
          (
            LifeEventRuleTemplateRow,
            BaseReferences<
              _$LifeEventDatabase,
              $LifeEventRuleTemplatesTable,
              LifeEventRuleTemplateRow
            >,
          ),
          LifeEventRuleTemplateRow,
          PrefetchHooks Function()
        > {
  $$LifeEventRuleTemplatesTableTableManager(
    _$LifeEventDatabase db,
    $LifeEventRuleTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventRuleTemplatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LifeEventRuleTemplatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LifeEventRuleTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> templateId = const Value.absent(),
                Value<String> ownerScopeId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> providerPatternJson = const Value.absent(),
                Value<String> defaultDirectionIdsJson = const Value.absent(),
                Value<String?> importanceOwnerScopeId = const Value.absent(),
                Value<String?> importanceCatalogId = const Value.absent(),
                Value<int?> importanceCatalogRevision = const Value.absent(),
                Value<String?> importanceLevelId = const Value.absent(),
                Value<String?> priorityOwnerScopeId = const Value.absent(),
                Value<String?> priorityCatalogId = const Value.absent(),
                Value<int?> priorityCatalogRevision = const Value.absent(),
                Value<String?> priorityId = const Value.absent(),
                Value<String> defaultChannelIdsJson = const Value.absent(),
                Value<String> defaultLeadTimesMsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeEventRuleTemplatesCompanion(
                templateId: templateId,
                ownerScopeId: ownerScopeId,
                revision: revision,
                providerPatternJson: providerPatternJson,
                defaultDirectionIdsJson: defaultDirectionIdsJson,
                importanceOwnerScopeId: importanceOwnerScopeId,
                importanceCatalogId: importanceCatalogId,
                importanceCatalogRevision: importanceCatalogRevision,
                importanceLevelId: importanceLevelId,
                priorityOwnerScopeId: priorityOwnerScopeId,
                priorityCatalogId: priorityCatalogId,
                priorityCatalogRevision: priorityCatalogRevision,
                priorityId: priorityId,
                defaultChannelIdsJson: defaultChannelIdsJson,
                defaultLeadTimesMsJson: defaultLeadTimesMsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String templateId,
                required String ownerScopeId,
                required int revision,
                required String providerPatternJson,
                required String defaultDirectionIdsJson,
                Value<String?> importanceOwnerScopeId = const Value.absent(),
                Value<String?> importanceCatalogId = const Value.absent(),
                Value<int?> importanceCatalogRevision = const Value.absent(),
                Value<String?> importanceLevelId = const Value.absent(),
                Value<String?> priorityOwnerScopeId = const Value.absent(),
                Value<String?> priorityCatalogId = const Value.absent(),
                Value<int?> priorityCatalogRevision = const Value.absent(),
                Value<String?> priorityId = const Value.absent(),
                required String defaultChannelIdsJson,
                required String defaultLeadTimesMsJson,
                Value<int> rowid = const Value.absent(),
              }) => LifeEventRuleTemplatesCompanion.insert(
                templateId: templateId,
                ownerScopeId: ownerScopeId,
                revision: revision,
                providerPatternJson: providerPatternJson,
                defaultDirectionIdsJson: defaultDirectionIdsJson,
                importanceOwnerScopeId: importanceOwnerScopeId,
                importanceCatalogId: importanceCatalogId,
                importanceCatalogRevision: importanceCatalogRevision,
                importanceLevelId: importanceLevelId,
                priorityOwnerScopeId: priorityOwnerScopeId,
                priorityCatalogId: priorityCatalogId,
                priorityCatalogRevision: priorityCatalogRevision,
                priorityId: priorityId,
                defaultChannelIdsJson: defaultChannelIdsJson,
                defaultLeadTimesMsJson: defaultLeadTimesMsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeEventRuleTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeEventDatabase,
      $LifeEventRuleTemplatesTable,
      LifeEventRuleTemplateRow,
      $$LifeEventRuleTemplatesTableFilterComposer,
      $$LifeEventRuleTemplatesTableOrderingComposer,
      $$LifeEventRuleTemplatesTableAnnotationComposer,
      $$LifeEventRuleTemplatesTableCreateCompanionBuilder,
      $$LifeEventRuleTemplatesTableUpdateCompanionBuilder,
      (
        LifeEventRuleTemplateRow,
        BaseReferences<
          _$LifeEventDatabase,
          $LifeEventRuleTemplatesTable,
          LifeEventRuleTemplateRow
        >,
      ),
      LifeEventRuleTemplateRow,
      PrefetchHooks Function()
    >;

class $LifeEventDatabaseManager {
  final _$LifeEventDatabase _db;
  $LifeEventDatabaseManager(this._db);
  $$LifeEventSubjectsTableTableManager get lifeEventSubjects =>
      $$LifeEventSubjectsTableTableManager(_db, _db.lifeEventSubjects);
  $$LifeEventLifeProfilesTableTableManager get lifeEventLifeProfiles =>
      $$LifeEventLifeProfilesTableTableManager(_db, _db.lifeEventLifeProfiles);
  $$LifeEventChartSnapshotRefsTableTableManager
  get lifeEventChartSnapshotRefs =>
      $$LifeEventChartSnapshotRefsTableTableManager(
        _db,
        _db.lifeEventChartSnapshotRefs,
      );
  $$LifeEventProviderDescriptorsTableTableManager
  get lifeEventProviderDescriptors =>
      $$LifeEventProviderDescriptorsTableTableManager(
        _db,
        _db.lifeEventProviderDescriptors,
      );
  $$LifeEventEventTypeDescriptorsTableTableManager
  get lifeEventEventTypeDescriptors =>
      $$LifeEventEventTypeDescriptorsTableTableManager(
        _db,
        _db.lifeEventEventTypeDescriptors,
      );
  $$LifeEventProjectionsTableTableManager get lifeEventProjections =>
      $$LifeEventProjectionsTableTableManager(_db, _db.lifeEventProjections);
  $$LifeEventCoverageSeriesHeadsTableTableManager
  get lifeEventCoverageSeriesHeads =>
      $$LifeEventCoverageSeriesHeadsTableTableManager(
        _db,
        _db.lifeEventCoverageSeriesHeads,
      );
  $$LifeEventCoverageManifestsTableTableManager
  get lifeEventCoverageManifests =>
      $$LifeEventCoverageManifestsTableTableManager(
        _db,
        _db.lifeEventCoverageManifests,
      );
  $$LifeEventShardReceiptsTableTableManager get lifeEventShardReceipts =>
      $$LifeEventShardReceiptsTableTableManager(
        _db,
        _db.lifeEventShardReceipts,
      );
  $$LifeEventUserDirectionsTableTableManager get lifeEventUserDirections =>
      $$LifeEventUserDirectionsTableTableManager(
        _db,
        _db.lifeEventUserDirections,
      );
  $$LifeEventUserAnnotationsTableTableManager get lifeEventUserAnnotations =>
      $$LifeEventUserAnnotationsTableTableManager(
        _db,
        _db.lifeEventUserAnnotations,
      );
  $$LifeEventAnnotationTargetRefsTableTableManager
  get lifeEventAnnotationTargetRefs =>
      $$LifeEventAnnotationTargetRefsTableTableManager(
        _db,
        _db.lifeEventAnnotationTargetRefs,
      );
  $$LifeEventAnnotationDirectionRefsTableTableManager
  get lifeEventAnnotationDirectionRefs =>
      $$LifeEventAnnotationDirectionRefsTableTableManager(
        _db,
        _db.lifeEventAnnotationDirectionRefs,
      );
  $$LifeEventOccurrenceSelectionsTableTableManager
  get lifeEventOccurrenceSelections =>
      $$LifeEventOccurrenceSelectionsTableTableManager(
        _db,
        _db.lifeEventOccurrenceSelections,
      );
  $$LifeEventPatternRulesTableTableManager get lifeEventPatternRules =>
      $$LifeEventPatternRulesTableTableManager(_db, _db.lifeEventPatternRules);
  $$LifeEventPatternTargetRefsTableTableManager
  get lifeEventPatternTargetRefs =>
      $$LifeEventPatternTargetRefsTableTableManager(
        _db,
        _db.lifeEventPatternTargetRefs,
      );
  $$LifeEventRuleTemplatesTableTableManager get lifeEventRuleTemplates =>
      $$LifeEventRuleTemplatesTableTableManager(
        _db,
        _db.lifeEventRuleTemplates,
      );
}
