import 'package:drift/drift.dart';

/// Drift table for cross-school decision chains.
/// See: docs/superpowers/specs/2026-05-27-xuan-common-storage-migration-design.md §7.2
@DataClassName('DecisionLinkRow')
class DecisionLinks extends Table {
  TextColumn get id => text()();
  TextColumn get sourceUuid => text().named('source_uuid')();
  TextColumn get targetUuid => text().named('target_uuid')();
  TextColumn get intent => text()();
  TextColumn get contextSnapshotJson => text().named('context_snapshot_json').nullable()();
  IntColumn get createdAtMs => integer().named('created_at_ms')();
  IntColumn get updatedAtMs => integer().named('updated_at_ms')();
  IntColumn get deletedAtMs => integer().named('deleted_at_ms').nullable()();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get unknownFields => text().named('unknown_fields').nullable()();

  // --- Fork/Link/Merge fields (added 2026-06-29) ---
  TextColumn get linkType => text().withDefault(const Constant('sequential')).named('link_type')();
  TextColumn get sessionId => text().named('session_id').nullable()();
  TextColumn get mergeTargetUuid => text().named('merge_target_uuid').nullable()();
  TextColumn get inferenceMetaJson => text().named('inference_meta_json').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 't_decision_links';
}
