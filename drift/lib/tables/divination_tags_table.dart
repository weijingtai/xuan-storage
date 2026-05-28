import 'package:drift/drift.dart';

/// EAV index table for divination feature tags.
/// Composite index (domain, tag_key, tag_value) enables fast cross-divination queries.
/// See: docs/superpowers/specs/2026-05-26-foundation-storage-v2-design.md §2.2
@DataClassName('DivinationTagRow')
class DivinationTags extends Table {
  TextColumn get divinationUuid => text().named('divination_uuid')();
  TextColumn get domain => text()();
  TextColumn get tagKey => text().named('tag_key')();
  TextColumn get tagValue => text().named('tag_value')();
  TextColumn get scopeUid => text().named('scope_uid')();
  IntColumn get createdAtMs => integer().named('created_at_ms')();

  @override
  Set<Column> get primaryKey => {divinationUuid, domain, tagKey, tagValue};

  @override
  String? get tableName => 't_divination_tags';

  @override
  List<String> get customConstraints => [
        'INDEX idx_tags_lookup (domain, tag_key, tag_value)',
      ];
}
