// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_database.dart';

// ignore_for_file: type=lint
class $AccountIdentityLinksTable extends AccountIdentityLinks
    with TableInfo<$AccountIdentityLinksTable, AccountIdentityLinkEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountIdentityLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _anonymousAppUserIdMeta =
      const VerificationMeta('anonymousAppUserId');
  @override
  late final GeneratedColumn<String> anonymousAppUserId =
      GeneratedColumn<String>('anonymous_app_user_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _registeredAppUserIdMeta =
      const VerificationMeta('registeredAppUserId');
  @override
  late final GeneratedColumn<String> registeredAppUserId =
      GeneratedColumn<String>('registered_app_user_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
      'provider_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _linkedAtMeta =
      const VerificationMeta('linkedAt');
  @override
  late final GeneratedColumn<DateTime> linkedAt = GeneratedColumn<DateTime>(
      'linked_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _mergeStatusMeta =
      const VerificationMeta('mergeStatus');
  @override
  late final GeneratedColumn<String> mergeStatus = GeneratedColumn<String>(
      'merge_status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 4, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('linked'));
  @override
  List<GeneratedColumn> get $columns => [
        anonymousAppUserId,
        registeredAppUserId,
        providerId,
        linkedAt,
        mergeStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_identity_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<AccountIdentityLinkEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('anonymous_app_user_id')) {
      context.handle(
          _anonymousAppUserIdMeta,
          anonymousAppUserId.isAcceptableOrUnknown(
              data['anonymous_app_user_id']!, _anonymousAppUserIdMeta));
    } else if (isInserting) {
      context.missing(_anonymousAppUserIdMeta);
    }
    if (data.containsKey('registered_app_user_id')) {
      context.handle(
          _registeredAppUserIdMeta,
          registeredAppUserId.isAcceptableOrUnknown(
              data['registered_app_user_id']!, _registeredAppUserIdMeta));
    } else if (isInserting) {
      context.missing(_registeredAppUserIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('linked_at')) {
      context.handle(_linkedAtMeta,
          linkedAt.isAcceptableOrUnknown(data['linked_at']!, _linkedAtMeta));
    } else if (isInserting) {
      context.missing(_linkedAtMeta);
    }
    if (data.containsKey('merge_status')) {
      context.handle(
          _mergeStatusMeta,
          mergeStatus.isAcceptableOrUnknown(
              data['merge_status']!, _mergeStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {anonymousAppUserId};
  @override
  AccountIdentityLinkEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountIdentityLinkEntry(
      anonymousAppUserId: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}anonymous_app_user_id'])!,
      registeredAppUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}registered_app_user_id'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_id'])!,
      linkedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}linked_at'])!,
      mergeStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merge_status'])!,
    );
  }

  @override
  $AccountIdentityLinksTable createAlias(String alias) {
    return $AccountIdentityLinksTable(attachedDatabase, alias);
  }
}

class AccountIdentityLinkEntry extends DataClass
    implements Insertable<AccountIdentityLinkEntry> {
  final String anonymousAppUserId;
  final String registeredAppUserId;
  final String providerId;
  final DateTime linkedAt;
  final String mergeStatus;
  const AccountIdentityLinkEntry(
      {required this.anonymousAppUserId,
      required this.registeredAppUserId,
      required this.providerId,
      required this.linkedAt,
      required this.mergeStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['anonymous_app_user_id'] = Variable<String>(anonymousAppUserId);
    map['registered_app_user_id'] = Variable<String>(registeredAppUserId);
    map['provider_id'] = Variable<String>(providerId);
    map['linked_at'] = Variable<DateTime>(linkedAt);
    map['merge_status'] = Variable<String>(mergeStatus);
    return map;
  }

  AccountIdentityLinksCompanion toCompanion(bool nullToAbsent) {
    return AccountIdentityLinksCompanion(
      anonymousAppUserId: Value(anonymousAppUserId),
      registeredAppUserId: Value(registeredAppUserId),
      providerId: Value(providerId),
      linkedAt: Value(linkedAt),
      mergeStatus: Value(mergeStatus),
    );
  }

  factory AccountIdentityLinkEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountIdentityLinkEntry(
      anonymousAppUserId:
          serializer.fromJson<String>(json['anonymousAppUserId']),
      registeredAppUserId:
          serializer.fromJson<String>(json['registeredAppUserId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      linkedAt: serializer.fromJson<DateTime>(json['linkedAt']),
      mergeStatus: serializer.fromJson<String>(json['mergeStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'anonymousAppUserId': serializer.toJson<String>(anonymousAppUserId),
      'registeredAppUserId': serializer.toJson<String>(registeredAppUserId),
      'providerId': serializer.toJson<String>(providerId),
      'linkedAt': serializer.toJson<DateTime>(linkedAt),
      'mergeStatus': serializer.toJson<String>(mergeStatus),
    };
  }

  AccountIdentityLinkEntry copyWith(
          {String? anonymousAppUserId,
          String? registeredAppUserId,
          String? providerId,
          DateTime? linkedAt,
          String? mergeStatus}) =>
      AccountIdentityLinkEntry(
        anonymousAppUserId: anonymousAppUserId ?? this.anonymousAppUserId,
        registeredAppUserId: registeredAppUserId ?? this.registeredAppUserId,
        providerId: providerId ?? this.providerId,
        linkedAt: linkedAt ?? this.linkedAt,
        mergeStatus: mergeStatus ?? this.mergeStatus,
      );
  AccountIdentityLinkEntry copyWithCompanion(
      AccountIdentityLinksCompanion data) {
    return AccountIdentityLinkEntry(
      anonymousAppUserId: data.anonymousAppUserId.present
          ? data.anonymousAppUserId.value
          : this.anonymousAppUserId,
      registeredAppUserId: data.registeredAppUserId.present
          ? data.registeredAppUserId.value
          : this.registeredAppUserId,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      linkedAt: data.linkedAt.present ? data.linkedAt.value : this.linkedAt,
      mergeStatus:
          data.mergeStatus.present ? data.mergeStatus.value : this.mergeStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountIdentityLinkEntry(')
          ..write('anonymousAppUserId: $anonymousAppUserId, ')
          ..write('registeredAppUserId: $registeredAppUserId, ')
          ..write('providerId: $providerId, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('mergeStatus: $mergeStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(anonymousAppUserId, registeredAppUserId,
      providerId, linkedAt, mergeStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountIdentityLinkEntry &&
          other.anonymousAppUserId == this.anonymousAppUserId &&
          other.registeredAppUserId == this.registeredAppUserId &&
          other.providerId == this.providerId &&
          other.linkedAt == this.linkedAt &&
          other.mergeStatus == this.mergeStatus);
}

class AccountIdentityLinksCompanion
    extends UpdateCompanion<AccountIdentityLinkEntry> {
  final Value<String> anonymousAppUserId;
  final Value<String> registeredAppUserId;
  final Value<String> providerId;
  final Value<DateTime> linkedAt;
  final Value<String> mergeStatus;
  final Value<int> rowid;
  const AccountIdentityLinksCompanion({
    this.anonymousAppUserId = const Value.absent(),
    this.registeredAppUserId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.linkedAt = const Value.absent(),
    this.mergeStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountIdentityLinksCompanion.insert({
    required String anonymousAppUserId,
    required String registeredAppUserId,
    required String providerId,
    required DateTime linkedAt,
    this.mergeStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : anonymousAppUserId = Value(anonymousAppUserId),
        registeredAppUserId = Value(registeredAppUserId),
        providerId = Value(providerId),
        linkedAt = Value(linkedAt);
  static Insertable<AccountIdentityLinkEntry> custom({
    Expression<String>? anonymousAppUserId,
    Expression<String>? registeredAppUserId,
    Expression<String>? providerId,
    Expression<DateTime>? linkedAt,
    Expression<String>? mergeStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (anonymousAppUserId != null)
        'anonymous_app_user_id': anonymousAppUserId,
      if (registeredAppUserId != null)
        'registered_app_user_id': registeredAppUserId,
      if (providerId != null) 'provider_id': providerId,
      if (linkedAt != null) 'linked_at': linkedAt,
      if (mergeStatus != null) 'merge_status': mergeStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountIdentityLinksCompanion copyWith(
      {Value<String>? anonymousAppUserId,
      Value<String>? registeredAppUserId,
      Value<String>? providerId,
      Value<DateTime>? linkedAt,
      Value<String>? mergeStatus,
      Value<int>? rowid}) {
    return AccountIdentityLinksCompanion(
      anonymousAppUserId: anonymousAppUserId ?? this.anonymousAppUserId,
      registeredAppUserId: registeredAppUserId ?? this.registeredAppUserId,
      providerId: providerId ?? this.providerId,
      linkedAt: linkedAt ?? this.linkedAt,
      mergeStatus: mergeStatus ?? this.mergeStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (anonymousAppUserId.present) {
      map['anonymous_app_user_id'] = Variable<String>(anonymousAppUserId.value);
    }
    if (registeredAppUserId.present) {
      map['registered_app_user_id'] =
          Variable<String>(registeredAppUserId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (linkedAt.present) {
      map['linked_at'] = Variable<DateTime>(linkedAt.value);
    }
    if (mergeStatus.present) {
      map['merge_status'] = Variable<String>(mergeStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountIdentityLinksCompanion(')
          ..write('anonymousAppUserId: $anonymousAppUserId, ')
          ..write('registeredAppUserId: $registeredAppUserId, ')
          ..write('providerId: $providerId, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('mergeStatus: $mergeStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AccountDatabase extends GeneratedDatabase {
  _$AccountDatabase(QueryExecutor e) : super(e);
  $AccountDatabaseManager get managers => $AccountDatabaseManager(this);
  late final $AccountIdentityLinksTable accountIdentityLinks =
      $AccountIdentityLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [accountIdentityLinks];
}

typedef $$AccountIdentityLinksTableCreateCompanionBuilder
    = AccountIdentityLinksCompanion Function({
  required String anonymousAppUserId,
  required String registeredAppUserId,
  required String providerId,
  required DateTime linkedAt,
  Value<String> mergeStatus,
  Value<int> rowid,
});
typedef $$AccountIdentityLinksTableUpdateCompanionBuilder
    = AccountIdentityLinksCompanion Function({
  Value<String> anonymousAppUserId,
  Value<String> registeredAppUserId,
  Value<String> providerId,
  Value<DateTime> linkedAt,
  Value<String> mergeStatus,
  Value<int> rowid,
});

class $$AccountIdentityLinksTableFilterComposer
    extends Composer<_$AccountDatabase, $AccountIdentityLinksTable> {
  $$AccountIdentityLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get anonymousAppUserId => $composableBuilder(
      column: $table.anonymousAppUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registeredAppUserId => $composableBuilder(
      column: $table.registeredAppUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get linkedAt => $composableBuilder(
      column: $table.linkedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mergeStatus => $composableBuilder(
      column: $table.mergeStatus, builder: (column) => ColumnFilters(column));
}

class $$AccountIdentityLinksTableOrderingComposer
    extends Composer<_$AccountDatabase, $AccountIdentityLinksTable> {
  $$AccountIdentityLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get anonymousAppUserId => $composableBuilder(
      column: $table.anonymousAppUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registeredAppUserId => $composableBuilder(
      column: $table.registeredAppUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get linkedAt => $composableBuilder(
      column: $table.linkedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mergeStatus => $composableBuilder(
      column: $table.mergeStatus, builder: (column) => ColumnOrderings(column));
}

class $$AccountIdentityLinksTableAnnotationComposer
    extends Composer<_$AccountDatabase, $AccountIdentityLinksTable> {
  $$AccountIdentityLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get anonymousAppUserId => $composableBuilder(
      column: $table.anonymousAppUserId, builder: (column) => column);

  GeneratedColumn<String> get registeredAppUserId => $composableBuilder(
      column: $table.registeredAppUserId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => column);

  GeneratedColumn<DateTime> get linkedAt =>
      $composableBuilder(column: $table.linkedAt, builder: (column) => column);

  GeneratedColumn<String> get mergeStatus => $composableBuilder(
      column: $table.mergeStatus, builder: (column) => column);
}

class $$AccountIdentityLinksTableTableManager extends RootTableManager<
    _$AccountDatabase,
    $AccountIdentityLinksTable,
    AccountIdentityLinkEntry,
    $$AccountIdentityLinksTableFilterComposer,
    $$AccountIdentityLinksTableOrderingComposer,
    $$AccountIdentityLinksTableAnnotationComposer,
    $$AccountIdentityLinksTableCreateCompanionBuilder,
    $$AccountIdentityLinksTableUpdateCompanionBuilder,
    (
      AccountIdentityLinkEntry,
      BaseReferences<_$AccountDatabase, $AccountIdentityLinksTable,
          AccountIdentityLinkEntry>
    ),
    AccountIdentityLinkEntry,
    PrefetchHooks Function()> {
  $$AccountIdentityLinksTableTableManager(
      _$AccountDatabase db, $AccountIdentityLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountIdentityLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountIdentityLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountIdentityLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> anonymousAppUserId = const Value.absent(),
            Value<String> registeredAppUserId = const Value.absent(),
            Value<String> providerId = const Value.absent(),
            Value<DateTime> linkedAt = const Value.absent(),
            Value<String> mergeStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountIdentityLinksCompanion(
            anonymousAppUserId: anonymousAppUserId,
            registeredAppUserId: registeredAppUserId,
            providerId: providerId,
            linkedAt: linkedAt,
            mergeStatus: mergeStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String anonymousAppUserId,
            required String registeredAppUserId,
            required String providerId,
            required DateTime linkedAt,
            Value<String> mergeStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountIdentityLinksCompanion.insert(
            anonymousAppUserId: anonymousAppUserId,
            registeredAppUserId: registeredAppUserId,
            providerId: providerId,
            linkedAt: linkedAt,
            mergeStatus: mergeStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountIdentityLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AccountDatabase,
        $AccountIdentityLinksTable,
        AccountIdentityLinkEntry,
        $$AccountIdentityLinksTableFilterComposer,
        $$AccountIdentityLinksTableOrderingComposer,
        $$AccountIdentityLinksTableAnnotationComposer,
        $$AccountIdentityLinksTableCreateCompanionBuilder,
        $$AccountIdentityLinksTableUpdateCompanionBuilder,
        (
          AccountIdentityLinkEntry,
          BaseReferences<_$AccountDatabase, $AccountIdentityLinksTable,
              AccountIdentityLinkEntry>
        ),
        AccountIdentityLinkEntry,
        PrefetchHooks Function()>;

class $AccountDatabaseManager {
  final _$AccountDatabase _db;
  $AccountDatabaseManager(this._db);
  $$AccountIdentityLinksTableTableManager get accountIdentityLinks =>
      $$AccountIdentityLinksTableTableManager(_db, _db.accountIdentityLinks);
}
