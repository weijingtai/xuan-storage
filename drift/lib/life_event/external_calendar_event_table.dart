// ACT-15：ExternalCalendarEvent Drift 表定义。
//
// 两张表（Design §15）：
//   1. t_le_external_events: 外部事件主表（保存多 revision 历史）
//   2. t_le_external_event_subjects: 外部事件关联主体子表（position 定序）
//
// 铁律：
// - 不得对 t_life_event_* / t_le_user_* / t_le_reminder_* 任何表建外键或触发器；
// - schemaVersion 保持 1，不写 onUpgrade；
// - 不推断 usedProfileRefs。
library;

import 'package:drift/drift.dart';

/// 外部日历事件主表（Design §15）。
@DataClassName('LifeEventExternalEventRow')
class LifeEventExternalEvents extends Table {
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get externalEventId => text().named('external_event_id')();
  TextColumn get revision => text().named('revision')();
  TextColumn get originType => text().named('origin_type')();
  TextColumn get originId => text().named('origin_id')();
  TextColumn get divinationTypeKey => text().named('divination_type_key')();
  TextColumn get subDivinationTypeKey =>
      text().named('sub_divination_type_key').nullable()();
  TextColumn get eventTimeKind => text().named('event_time_kind')();
  IntColumn get eventStartMs => integer().named('event_start_ms')();
  IntColumn get eventEndMs => integer().named('event_end_ms').nullable()();
  IntColumn get eventPrecision => integer().named('event_precision').nullable()();
  TextColumn get factSummary => text().named('fact_summary')();
  TextColumn get evidenceRef => text().named('evidence_ref').nullable()();
  TextColumn get lifecycleStatus => text().named('lifecycle_status')();
  TextColumn get usedProfileRefsJson => text().named('used_profile_refs_json')();
  IntColumn get savedAtMs => integer().named('saved_at_ms')();
  BoolColumn get isLatest => boolean().named('is_latest')();

  @override
  Set<Column> get primaryKey => {ownerScopeId, externalEventId, revision};

  @override
  String? get tableName => 't_le_external_events';
}

/// 外部日历事件关联主体子表（relatedSubjectIds，position 保证顺序稳定）。
@DataClassName('LifeEventExternalEventSubjectRow')
class LifeEventExternalEventSubjects extends Table {
  TextColumn get ownerScopeId => text().named('owner_scope_id')();
  TextColumn get externalEventId => text().named('external_event_id')();
  TextColumn get revision => text().named('revision')();
  TextColumn get subjectId => text().named('subject_id')();
  IntColumn get position => integer().named('position')();

  @override
  Set<Column> get primaryKey => {
        ownerScopeId,
        externalEventId,
        revision,
        subjectId,
        position,
      };

  @override
  String? get tableName => 't_le_external_event_subjects';
}
