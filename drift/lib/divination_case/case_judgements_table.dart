import 'package:drift/drift.dart';

class CaseJudgements extends Table {
  @override
  String get tableName => 't_case_judgements';

  TextColumn get uuid => text().named('uuid')();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get caseUuid => text().named('case_uuid')();
  TextColumn get workItemUuid => text().named('work_item_uuid').nullable()();
  TextColumn get techniqueId => text().named('technique_id').nullable()();
  TextColumn get module => text().named('module').nullable()();
  TextColumn get judgementText => text().named('text')();
  TextColumn get detailText => text().named('detail_text').nullable()();
  TextColumn get indicatorLabel => text().named('indicator_label').nullable()();
  TextColumn get patternLabel => text().named('pattern_label').nullable()();
  TextColumn get status => text().named('status')();
  TextColumn get keyBasis => text().named('key_basis').nullable()();
  TextColumn get attachedToKind => text().named('attached_to_kind').nullable()();
  IntColumn get orderIndex => integer().named('order_index')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {uuid};

  @override
  List<Index> get indexes => [
    Index(
      'idx_case_judgements_scope_case',
      'CREATE INDEX idx_case_judgements_scope_case ON t_case_judgements(scope_uid, case_uuid);',
    ),
    Index(
      'idx_case_judgements_work_item',
      'CREATE INDEX idx_case_judgements_work_item ON t_case_judgements(work_item_uuid);',
    ),
  ];
}
