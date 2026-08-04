import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

import 'package:enumeration/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:metaphysics_core/datamodel/divination_type_data_model.dart';
import 'package:metaphysics_core/datamodel/timing_divination_model.dart';
import 'package:metaphysics_core/datamodel/sub_divination_type_data_model.dart';
import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:persistence_drift/converters/divination_datetime_model_converter.dart';
import 'package:persistence_drift/converters/nullable_location_converter.dart';

import 'daos/seekers_dao.dart';
import 'daos/divinations_dao.dart';
import 'daos/seeker_divination_mappers_dao.dart';
import 'daos/combined_divinations_dao.dart';
import 'daos/decision_links_dao.dart';
import 'daos/divination_tags_dao.dart';
import 'daos/divination_types_dao.dart';
import 'daos/divination_sub_divination_type_mappers_dao.dart';
import 'tables/seekers_table.dart';
import 'tables/divinations_table.dart';
import 'tables/seeker_divination_mappers_table.dart';
import 'tables/combined_divinations_table.dart';
import 'tables/decision_links_table.dart';
import 'tables/divination_tags_table.dart';
import 'tables/divination_types_table.dart';
import 'tables/sub_divination_types_table.dart';
import 'tables/divination_sub_divination_type_mappers_table.dart';
import 'daos/da_yun_records_dao.dart';
import 'daos/tai_yuan_records_dao.dart';
import 'tables/tai_yuan_records_table.dart';
import 'tables/da_yun_records_table.dart';
import 'daos/timing_divinations_dao.dart';
import 'tables/divination_calendars_table.dart';
import 'tables/timing_divinations_table.dart';
export 'daos/divination_calendars_dao.dart';
export 'daos/timing_divinations_dao.dart';
export 'tables/divination_calendars_table.dart';
export 'tables/timing_divinations_table.dart';
import 'daos/panels_dao.dart';
import 'daos/divination_panel_mappers_dao.dart';
import 'daos/panel_skill_class_mappers_dao.dart';
import 'tables/panels_table.dart';
import 'tables/divination_panel_mappers_table.dart';
import 'tables/panel_skill_class_mappers_table.dart';
import 'tables/skills_table.dart';
import 'tables/skill_classes_table.dart';
import 'divination_case/divination_cases_table.dart';
import 'divination_case/divination_work_items_table.dart';
import 'divination_case/case_participants_table.dart';
import 'divination_case/panel_refs_table.dart';
import 'divination_case/work_item_panel_refs_table.dart';
import 'divination_case/creation_audit_logs_table.dart';
import 'divination_case/creation_audit_logs_dao.dart';
export 'daos/skills_dao.dart';
export 'daos/skill_classes_dao.dart';
export 'tables/skills_table.dart';
export 'tables/skill_classes_table.dart';
export 'daos/panels_dao.dart';
export 'daos/divination_panel_mappers_dao.dart';
export 'daos/panel_skill_class_mappers_dao.dart';
export 'tables/panels_table.dart';
export 'tables/divination_panel_mappers_table.dart';
export 'tables/panel_skill_class_mappers_table.dart';

export 'daos/seekers_dao.dart';
export 'daos/divinations_dao.dart';
export 'daos/seeker_divination_mappers_dao.dart';
export 'daos/combined_divinations_dao.dart';
export 'daos/decision_links_dao.dart';
export 'daos/divination_tags_dao.dart';
export 'daos/divination_types_dao.dart';
export 'daos/divination_sub_divination_type_mappers_dao.dart';
export 'tables/seekers_table.dart';
export 'tables/divinations_table.dart';
export 'tables/seeker_divination_mappers_table.dart';
export 'tables/combined_divinations_table.dart';
export 'tables/decision_links_table.dart';
export 'daos/da_yun_records_dao.dart';
export 'daos/tai_yuan_records_dao.dart';
export 'tables/da_yun_records_table.dart';
export 'tables/tai_yuan_records_table.dart';
export 'repositories/tai_yuan_record_repository.dart';
export 'repositories/da_yun_record_repository.dart';
export 'tables/divination_tags_table.dart';
export 'tables/divination_types_table.dart';
export 'tables/sub_divination_types_table.dart';
export 'tables/divination_sub_divination_type_mappers_table.dart';
export 'tables/auto_incrementing_primary_key.dart';
export 'tables/record_meta_table.dart';
export 'tables/record_search_index_table.dart';
export 'decision_links/inference_engine.dart';
export 'decision_links/fork_engine.dart';
export 'decision_links/merge_engine.dart';
export 'decision_links/decision_chain_traverser.dart';
export 'divination_case/drift_divination_case_repository.dart';
export 'divination_case/creation_audit_logs_table.dart';
export 'divination_case/creation_audit_logs_dao.dart';
export 'scope/scope_alias_entry.dart';
export 'scope/scope_bootstrap_store.dart';
export 'scope/scope_ledger.dart';
export 'scope/scope_resolver.dart';
export 'scope/drift_scope_ledger.dart';
export 'account/account_database.dart';
export 'account/drift_account_identity_link_repository.dart';
export 'record/record_cursor.dart';
export 'record/drift_record_data_source.dart';
export 'record/record_adapter_registry.dart';
export 'record/local_record_repository.dart';
export 'record/record_module_registry.dart';
export 'meihuayishu/meihua_database.dart';
export 'meihuayishu/meihua_gua_infos.dart';
export 'meihuayishu/meihua_divinations_dao.dart';
export 'meihuayishu/dictionary_database.dart';
export 'meihuayishu/dictionary_tables.dart';
export 'meihuayishu/drift_meihua_divination_record_repository.dart';
export 'meihuayishu/drift_meihua_dictionary_repository.dart';
export 'meihuayishu/meihua_record_codec.dart';
export 'meihuayishu/meihua_record_adapter.dart';
export 'meihuayishu/meihua_module_registry.dart';
export 'meihuayishu/meihua_record_migration.dart';
export 'meihuayishu/record_backed_meihua_repository.dart';
export 'four_zhu_card_templates/app_database.dart';
export 'four_zhu_card_templates/four_zhu_card_template_repository_adapter.dart';
export 'four_zhu_card_templates/four_zhu_card_template_installer_adapter.dart';
export 'four_zhu_card_templates/four_zhu_card_template_install_store_adapter.dart';
export 'four_zhu_card_templates/four_zhu_card_template_meta_store_adapter.dart';
export 'four_zhu_card_templates/four_zhu_card_template_setting_store_adapter.dart';
export 'four_zhu_card_templates/four_zhu_card_template_usage_recorder_adapter.dart';
export 'four_zhu_card_templates/four_zhu_editor_dependencies_factory.dart';
export 'four_zhu_card_templates/daos/card_template_meta_dao.dart';
export 'four_zhu_card_templates/daos/card_template_setting_dao.dart';
export 'four_zhu_card_templates/daos/card_template_skill_usage_dao.dart';
export 'four_zhu_card_templates/daos/market_template_installs_dao.dart';
export 'four_zhu_card_templates/layout_template_local_data_source.dart';
import 'tables/record_meta_table.dart';
import 'tables/record_search_index_table.dart';
import 'scope/drift_scope_alias_table.dart';
import 'blob/blob_tables.dart';
import 'blob/blob_datetime_converter.dart';

part 'persistence_drift.g.dart';

@DataClassName('OutboxRecordRow')
class OutboxRecords extends Table {
  @override
  String get tableName => 't_outbox';

  TextColumn get operationId => text().named('operation_id')();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get opType => text().named('op_type')();

  TextColumn get payloadJson => text().named('payload_json')();
  TextColumn get payloadSummary => text().nullable().named('payload_summary')();
  TextColumn get payloadHash => text().nullable().named('payload_hash')();

  DateTimeColumn get createdAtUtc => dateTime().named('created_at_utc')();
  IntColumn get attempt =>
      integer().withDefault(const Constant(0)).named('attempt')();
  TextColumn get status =>
      text().withDefault(const Constant('pending')).named('status')();

  TextColumn get lastErrorCode => text().nullable().named('last_error_code')();
  TextColumn get lastErrorMessage =>
      text().nullable().named('last_error_message')();
  DateTimeColumn get lastAttemptAtUtc =>
      dateTime().nullable().named('last_attempt_at_utc')();
  DateTimeColumn get succeededAtUtc =>
      dateTime().nullable().named('succeeded_at_utc')();

  @override
  Set<Column> get primaryKey => {operationId};

  List<Index> get indexes => [
        Index(
          'idx_outbox_scope_status_created',
          'CREATE INDEX idx_outbox_scope_status_created ON t_outbox (scope_uid, status, created_at_utc);',
        ),
        Index(
          'idx_outbox_scope_status',
          'CREATE INDEX idx_outbox_scope_status ON t_outbox (scope_uid, status);',
        ),
      ];
}

@DataClassName('OutboxPeerAckRow')
class OutboxPeerAcks extends Table {
  @override
  String get tableName => 't_outbox_peer_ack';

  /// per-peer ack 水位表（§5.2.2 第 1 条）。
  ///
  /// 一条 outbox 记录对 N 个对端各有一行 ack —— 记录本身只存一份，
  /// 「推没推成功」是 (operationId, peerId) 二元组的属性。
  ///
  /// 本表【同时】是 §5.3 oplog compaction 的水位表：
  /// 「所有已知 peer 均已 success 的 operationId 可被压缩」这一判定直接查本表。
  /// 因此 compaction 的数据模型不是待决项，它就是这张表。
  ///
  /// ⚠ 但本表提供的是压缩的【判据】，不是压缩的【许可】。
  /// compaction 的前置条件是「游标落在 oplog 保留窗口外 → 强制全量对齐」，
  /// 该能力归 S1c（见 specs/2026-08-03-s1c-full-reconciliation-design.md）。
  /// 缺了它而实现压缩，久未上线的设备会静默丢失被压缩区间的变更：
  /// 对端只能给出保留窗口内的增量，而该设备收下后照常把游标推进到"现在"
  /// ——【零报错、零测试变红】。
  /// 【S1b 内不得实现 compaction】。
  TextColumn get operationId => text().named('operation_id')();
  TextColumn get peerId => text().named('peer_id')();

  /// pending / success / failed / dead。与 t_outbox.status 同一套取值。
  TextColumn get status =>
      text().withDefault(const Constant('pending')).named('status')();

  /// 该对端的重试次数。per-peer —— 一个对端推成 dead 不影响其他对端。
  IntColumn get attempt =>
      integer().withDefault(const Constant(0)).named('attempt')();

  TextColumn get lastErrorCode => text().nullable().named('last_error_code')();
  TextColumn get lastErrorMessage =>
      text().nullable().named('last_error_message')();
  DateTimeColumn get ackedAtUtc => dateTime().nullable().named('acked_at_utc')();

  @override
  Set<Column> get primaryKey => {operationId, peerId};

  List<Index> get indexes => [
        Index(
          'idx_outbox_peer_ack_peer_status',
          'CREATE INDEX idx_outbox_peer_ack_peer_status '
          'ON t_outbox_peer_ack (peer_id, status);',
        ),
        Index(
          'idx_outbox_peer_ack_operation',
          'CREATE INDEX idx_outbox_peer_ack_operation '
          'ON t_outbox_peer_ack (operation_id);',
        ),
      ];
}

/// 每个实体当前版本的 HLC 戳（边表）。
///
/// 【为什么用边表而不是往 RecordMeta 加字段】：RecordMeta 在
/// repository-interface-record 仓库，改它要连带下游 12 个业务仓库。
/// 边表让 S1b 完全留在 xuan-storage 内，所有 Data class 零改动。
///
/// 代价：戳与记录不在同一行，【必须同事务写入】（A13 门禁守着）。
@DataClassName('EntityStampRow')
class EntityStamps extends Table {
  @override
  String get tableName => 't_entity_stamp';

  /// 所属账号作用域。
  ///
  /// ⚠ **主键里必须有它**（Codex R2）。本库里所有同步侧的表
  /// （t_outbox / t_sync_state）都以 scope_uid 分片；戳表少了这一维，
  /// 两个账号下 entityId 相同的实体会【共用同一行戳】——
  /// 切换账号后仲裁读到的是另一个账号的版本坐标，于是要么无脑覆盖、
  /// 要么无脑丢弃，而且不报错。
  TextColumn get scopeUid => text().named('scope_uid')();

  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();

  /// HLC 打包值 `(l << 16) | c`。有效范围与溢出行为见 ACT 08 的
  /// TASK_DETAIL.hlc_wire_format_spec ②（int64 位布局）。
  IntColumn get hlcPacked => integer().named('hlc_packed')();

  /// 写入该版本的设备。HLC 相等时的决胜位（= crdt Hlc 的 nodeId）。
  TextColumn get deviceId => text().named('device_id')();

  @override
  Set<Column> get primaryKey => {scopeUid, entityType, entityId};
}

/// 本设备 HLC 时钟的持久化状态（单行表）。
///
/// 【为什么是单行表而不是 key-value】：时钟是设备级的唯一状态，
/// 用固定主键的单行表，读写各一条语句，且不可能出现"存了两份钟"。
@DataClassName('HlcClockStateRow')
class HlcClockStates extends Table {
  @override
  String get tableName => 't_hlc_clock_state';

  /// 固定为 0。单行表的哨兵主键 —— 有 CHECK 约束保证只可能有一行。
  IntColumn get id =>
      integer().withDefault(const Constant(0)).named('id')();

  /// 上次退出/上次 tick 时的 HLC 打包值（int64，见 hlc_wire_format_spec ②）。
  IntColumn get hlcPacked => integer().named('hlc_packed')();

  /// 本设备标识。与 [DeviceIdentity.deviceId] 一致（= crdt Hlc 的 nodeId）。
  TextColumn get deviceId => text().named('device_id')();

  /// 最后一次落盘时间，仅供诊断，【不参与定序】。
  DateTimeColumn get savedAtUtc => dateTime().named('saved_at_utc')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => const ['CHECK (id = 0)'];
}

@DataClassName('SyncStateRow')
class SyncStates extends Table {
  @override
  String get tableName => 't_sync_state';
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get entityType => text().named('entity_type')();

  /// 该游标所属的对端。游标是 per-(scope, peer, entityType) 的 ——
  /// 云端游标推进到 T，不代表 LAN peer 也同步到了 T。
  /// 带默认值 'firestore'，使既有行升级后自动回填且既有 DAO 代码无需改动即可编译。
  TextColumn get peerId =>
      text().withDefault(const Constant('firestore')).named('peer_id')();

  TextColumn get cursorType => text().named('cursor_type')();
  IntColumn get revision => integer().nullable().named('revision')();
  DateTimeColumn get serverUpdatedAtUtc =>
      dateTime().nullable().named('server_updated_at_utc')();
  TextColumn get tieBreaker => text().nullable().named('tie_breaker')();

  DateTimeColumn get cursorUpdatedAtUtc =>
      dateTime().named('cursor_updated_at_utc')();
  DateTimeColumn get lastPulledAtUtc =>
      dateTime().nullable().named('last_pulled_at_utc')();
  DateTimeColumn get lastPushedAtUtc =>
      dateTime().nullable().named('last_pushed_at_utc')();

  @override
  Set<Column> get primaryKey => {scopeUid, peerId, entityType};

  List<Index> get indexes => [
        Index(
          'idx_sync_state_scope',
          'CREATE INDEX idx_sync_state_scope ON t_sync_state (scope_uid);',
        ),
      ];
}

@DriftAccessor(tables: [OutboxRecords])
class OutboxRecordsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$OutboxRecordsDaoMixin {
  OutboxRecordsDao(this.db) : super(db);

  final PersistenceDriftDatabase db;

  Future<void> enqueue(OutboxRecordsCompanion companion) async {
    await into(db.outboxRecords).insertOnConflictUpdate(companion);
  }

  /// 取该对端可推的一批记录。
  ///
  /// 语义（§5.2.1 阻断点 1/2）：可推 = 该 (operationId, peerId) 在
  /// t_outbox_peer_ack 中【不存在】（首次推送）或 status 为 pending/failed。
  /// 必须 LEFT JOIN —— 用 INNER JOIN 会漏掉所有从未推送过的记录，
  /// 线上表现是「新记录永远推不出去」，且只在新增对端时才暴露。
  ///
  /// ⚠ 过滤语义（§5.4 第一道锁）：策略在 Dart 的 StoragePolicyRegistry，
  /// 不在库里，SQL 无法过滤。做法：SQL 分页取候选（每页 page 条），
  /// 在 Dart 层用 [PeerEligibility.allows] 过滤，**先过滤再截断到 [limit]**。
  /// 先按 limit 截断再过滤会得到少于 limit 的结果，调用方看到"不足一批"
  /// 通常理解为"推完了"，于是 shared 记录多时后面的记录永远轮不上 —— 静默饥饿。
  Future<List<OutboxRecordRow>> peekBatch({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
    required int limit,
  }) async {
    const page = 50;
    var offset = 0;
    final out = <OutboxRecordRow>[];
    while (out.length < limit) {
      final o = db.outboxRecords;
      final a = db.outboxPeerAcks;
      final q = select(o).join([
        leftOuterJoin(
          a,
          o.operationId.equalsExp(a.operationId) &
              a.peerId.equals(peerId.value),
        ),
      ]);
      q.where(
        o.scopeUid.equals(scopeUid) &
            (a.status.isNull() |
                a.status.equals('pending') |
                a.status.equals('failed')),
      );
      q.orderBy([OrderingTerm.asc(o.createdAtUtc)]);
      q.limit(page, offset: offset);
      final rows = await q.map((row) => row.readTable(o)).get();
      if (rows.isEmpty) break;
      offset += page;
      for (final r in rows) {
        if (!PeerEligibility.allows(r.entityType, channel)) continue;
        out.add(r);
        if (out.length >= limit) break;
      }
    }
    return out;
  }

  Future<List<OutboxRecordRow>> listRetryable({required String scopeUid}) {
    return (select(db.outboxRecords)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                (t.status.equals('pending') | t.status.equals('failed')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtUtc)]))
        .get();
  }

  Future<void> deleteByScope({required String scopeUid}) async {
    await (delete(db.outboxRecords)..where((t) => t.scopeUid.equals(scopeUid)))
        .go();
  }

  Future<void> enqueueMany(List<OutboxRecordsCompanion> companions) async {
    if (companions.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(db.outboxRecords, companions);
    });
  }

  /// 该对端的待推送积压数（含 ack 行不存在的记录）。
  ///
  /// ⚠ 与 peekBatch 用【同一套过滤】（§5.4 + ACT 05 转译推导）：
  /// 计数与 peekBatch 不同语义时，SyncRuntime 会看到"还有 N 条待推"但
  /// peekBatch 返回空 —— 无限空转唤醒。过滤同样在 Dart 层做。
  Future<int> backlogCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) async {
    final countExp = db.outboxRecords.operationId.count();
    final o = db.outboxRecords;
    final a = db.outboxPeerAcks;
    final rows = await (selectOnly(o)
          ..addColumns([o.scopeUid, o.entityType, countExp])
          ..join([
            leftOuterJoin(
              a,
              o.operationId.equalsExp(a.operationId) &
                  a.peerId.equals(peerId.value),
            ),
          ])
          ..where(
            o.scopeUid.equals(scopeUid) &
                (a.status.isNull() |
                    a.status.equals('pending') |
                    a.status.equals('failed')),
          )
          ..groupBy([o.entityType]))
        .get();
    var count = 0;
    for (final row in rows) {
      if (!PeerEligibility.allows(row.read(o.entityType)!, channel)) continue;
      count += row.read(countExp) ?? 0;
    }
    return count;
  }

  /// 订阅该对端的待推送积压数。
  ///
  /// 必须 JOIN t_outbox_peer_ack —— `.watchSingle()` 会自动跟踪被查询的表，
  /// 该对端的 ack 行变化（例如 markSuccess）时 stream 才重新发射；
  /// 若只查 t_outbox 再在 Dart 里过滤，云端推完后 LAN 的 backlog 数字不会更新。
  ///
  /// ⚠ 与 peekBatch 用【同一套过滤】：按 entityType 分组后，仅累加
  /// [PeerEligibility.allows] 通过的实体类型（ACT 05 推导，见 backlogCount）。
  Stream<int> watchBacklogCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) {
    final countExp = db.outboxRecords.operationId.count();
    final o = db.outboxRecords;
    final a = db.outboxPeerAcks;
    return (selectOnly(o)
          ..addColumns([o.entityType, countExp])
          ..join([
            leftOuterJoin(
              a,
              o.operationId.equalsExp(a.operationId) &
                  a.peerId.equals(peerId.value),
            ),
          ])
          ..where(
            o.scopeUid.equals(scopeUid) &
                (a.status.isNull() |
                    a.status.equals('pending') |
                    a.status.equals('failed')),
          )
          ..groupBy([o.entityType]))
        .watch()
        .map((rows) {
      var count = 0;
      for (final row in rows) {
        if (!PeerEligibility.allows(row.read(o.entityType)!, channel)) continue;
        count += row.read(countExp) ?? 0;
      }
      return count;
    });
  }

  /// 该对端的死信数（该对端 ack 行 status = 'dead' 的条数）。
  ///
  /// ⚠ 与 backlogCount 用【同一套 channel 过滤】：死信数用于观测/告警，
  /// 若不过滤会与 backlogCount 的语义错位（ACT 05 推导，见 backlogCount）。
  Future<int> deadCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) async {
    final countExp = db.outboxRecords.operationId.count();
    final o = db.outboxRecords;
    final a = db.outboxPeerAcks;
    final rows = await (selectOnly(o)
          ..addColumns([o.entityType, countExp])
          ..join([
            leftOuterJoin(
              a,
              o.operationId.equalsExp(a.operationId) &
                  a.peerId.equals(peerId.value),
            ),
          ])
          ..where(o.scopeUid.equals(scopeUid) & a.status.equals('dead'))
          ..groupBy([o.entityType]))
        .get();
    var count = 0;
    for (final row in rows) {
      if (!PeerEligibility.allows(row.read(o.entityType)!, channel)) continue;
      count += row.read(countExp) ?? 0;
    }
    return count;
  }

  /// 标记【某一条记录对某一个对端】推送成功。
  ///
  /// ack 行惰性创建（upsert）：入队时【不】预建 ack 行 —— 对端集合入队时
  /// 还不确定。success 是 (operationId, peerId) 二元组的属性，
  /// 【不得】删除 t_outbox 行（删除是 compaction 的事，§5.3）。
  Future<void> markSuccess({
    required String operationId,
    required PeerId peerId,
    required DateTime atUtc,
  }) async {
    await into(db.outboxPeerAcks).insertOnConflictUpdate(
      OutboxPeerAcksCompanion(
        operationId: Value(operationId),
        peerId: Value(peerId.value),
        status: const Value('success'),
        attempt: const Value(0),
        lastErrorCode: const Value(null),
        lastErrorMessage: const Value(null),
        ackedAtUtc: Value(atUtc),
      ),
    );
  }

  /// 标记【某一条记录对某一个对端】推送失败。
  ///
  /// attempt 与 isDead 归 ack 表管 —— 一个长期离线的 LAN peer 达到 dead
  /// 阈值【不得】影响该行对 cloud 的可推送性。
  Future<void> markFailed({
    required String operationId,
    required PeerId peerId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {
    await into(db.outboxPeerAcks).insertOnConflictUpdate(
      OutboxPeerAcksCompanion(
        operationId: Value(operationId),
        peerId: Value(peerId.value),
        status: Value(isDead ? 'dead' : 'failed'),
        attempt: Value(attempt),
        lastErrorCode: Value(errorCode),
        lastErrorMessage: Value(errorMessage),
        ackedAtUtc: Value(atUtc),
      ),
    );
  }

  /// 读取【某一条记录对某一个对端】的当前重试次数。
  ///
  /// ack 行不存在（从未推送过）时返回 0，不抛异常。
  Future<int> attemptFor({
    required String operationId,
    required PeerId peerId,
  }) async {
    final row = await (select(db.outboxPeerAcks)
          ..where(
            (t) =>
                t.operationId.equals(operationId) &
                t.peerId.equals(peerId.value),
          ))
        .getSingleOrNull();
    return row?.attempt ?? 0;
  }
}

@DriftAccessor(tables: [SyncStates])
class SyncStatesDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$SyncStatesDaoMixin {
  SyncStatesDao(this.db) : super(db);

  final PersistenceDriftDatabase db;

  int _compareTimestampCursor({
    required DateTime serverUpdatedAtUtcA,
    required String tieBreakerA,
    required DateTime serverUpdatedAtUtcB,
    required String tieBreakerB,
  }) {
    final tsCmp = serverUpdatedAtUtcA.compareTo(serverUpdatedAtUtcB);
    if (tsCmp != 0) return tsCmp;
    return tieBreakerA.compareTo(tieBreakerB);
  }

  /// 写入 (scopeUid, peerId, entityType) 的 timestamp 游标，仅当它更新时覆盖。
  ///
  /// 「不回退」判定只在那一行三元组内比较 —— 跨 peer 的游标不可比，
  /// 云端推进到 T 不代表 LAN peer 也同步到了 T（§5.2.2）。
  Future<void> setTimestampCursorIfNewer({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required DateTime serverUpdatedAtUtc,
    required String tieBreaker,
    required DateTime atUtc,
  }) async {
    await db.transaction(() async {
      final existing = await find(
        scopeUid: scopeUid,
        peerId: peerId,
        entityType: entityType,
      );
      if (existing != null &&
          existing.cursorType == 'timestamp' &&
          existing.serverUpdatedAtUtc != null &&
          existing.tieBreaker != null) {
        final cmp = _compareTimestampCursor(
          serverUpdatedAtUtcA: serverUpdatedAtUtc,
          tieBreakerA: tieBreaker,
          serverUpdatedAtUtcB: existing.serverUpdatedAtUtc!,
          tieBreakerB: existing.tieBreaker!,
        );
        if (cmp <= 0) return;
      }

      await upsert(
        SyncStatesCompanion.insert(
          scopeUid: scopeUid,
          peerId: Value(peerId.value),
          entityType: entityType,
          cursorType: 'timestamp',
          serverUpdatedAtUtc: Value(serverUpdatedAtUtc),
          tieBreaker: Value(tieBreaker),
          cursorUpdatedAtUtc: atUtc,
          revision: const Value(null),
          lastPulledAtUtc: const Value(null),
          lastPushedAtUtc: const Value(null),
        ),
      );
    });
  }

  Future<void> setRevisionCursorIfNewer({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required int revision,
    required DateTime atUtc,
  }) async {
    await db.transaction(() async {
      final existing = await find(
        scopeUid: scopeUid,
        peerId: peerId,
        entityType: entityType,
      );
      if (existing != null &&
          existing.cursorType == 'revision' &&
          existing.revision != null) {
        if (revision <= existing.revision!) return;
      }

      await upsert(
        SyncStatesCompanion.insert(
          scopeUid: scopeUid,
          peerId: Value(peerId.value),
          entityType: entityType,
          cursorType: 'revision',
          revision: Value(revision),
          serverUpdatedAtUtc: const Value(null),
          tieBreaker: const Value(null),
          cursorUpdatedAtUtc: atUtc,
          lastPulledAtUtc: const Value(null),
          lastPushedAtUtc: const Value(null),
        ),
      );
    });
  }

  Future<SyncStateRow?> find({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) {
    return (select(db.syncStates)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.peerId.equals(peerId.value) &
                t.entityType.equals(entityType),
          ))
        .getSingleOrNull();
  }

  Future<void> upsert(SyncStatesCompanion companion) async {
    await into(db.syncStates).insertOnConflictUpdate(companion);
  }

  Future<void> clear({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) async {
    await (delete(db.syncStates)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.peerId.equals(peerId.value) &
                t.entityType.equals(entityType),
          ))
        .go();
  }

  Future<void> markPulledAt({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required DateTime atUtc,
  }) async {
    await (update(db.syncStates)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.peerId.equals(peerId.value) &
                t.entityType.equals(entityType),
          ))
        .write(SyncStatesCompanion(lastPulledAtUtc: Value(atUtc)));
  }

  Future<void> markPushedAt({
    required String scopeUid,
    required PeerId peerId,
    required DateTime atUtc,
  }) async {
    await (update(db.syncStates)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.peerId.equals(peerId.value),
          ))
        .write(SyncStatesCompanion(lastPushedAtUtc: Value(atUtc)));
  }
}

/// 实体 HLC 戳边表 + 本设备时钟单行表的管理（ACT 08）。
///
/// 【applyWithStamp 是本 ACT 的核心生产接口】：在【同一个 drift 事务】里
/// 写业务记录并更新它的 HLC 戳 —— 戳与记录一起落盘或一起回滚（A13）。
/// 调用方【不得】自己开事务再调本方法。
@DriftAccessor(tables: [EntityStamps, HlcClockStates])
class EntityStampDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$EntityStampDaoMixin {
  EntityStampDao(this.db) : super(db);

  final PersistenceDriftDatabase db;

  /// 在【同一个 drift 事务】里写业务记录并更新它的 HLC 戳。
  ///
  /// [write] 是业务写入回调，在事务内执行；它抛出时整个事务回滚，
  /// 戳与记录【一起】不落盘。调用方【不得】自己开事务再调本方法。
  ///
  /// ACT 10 的 applier 必须走这个方法，不许自己 `transaction(() { ... })`
  /// 里分别调两次 —— 那样写法上看着也在一个事务里，但戳的更新会散落在
  /// applier 的多个分支中，漏掉一个分支不报错。
  Future<void> applyWithStamp({
    required String scopeUid,
    required String entityType,
    required String entityId,
    required int hlcPacked,
    required String deviceId,
    required Future<void> Function() write,
  }) async {
    await db.transaction(() async {
      await write();
      await into(db.entityStamps).insertOnConflictUpdate(
        EntityStampsCompanion.insert(
          scopeUid: scopeUid,
          entityType: entityType,
          entityId: entityId,
          hlcPacked: hlcPacked,
          deviceId: deviceId,
        ),
      );
    });
  }

  /// 读取某个实体当前的 HLC 戳；边表里没有该行时返回 null。
  ///
  /// 【ACT 10 的 applier 靠它拿"本地版本"参与仲裁】。
  ///
  /// 返回 null 有【两种现实】且本方法【区分不了】：
  ///   ① 本地压根没有这个实体
  ///   ② 本地有实体，但边表还没有它的戳（v8 迁移前写入的历史数据）
  /// 这个区分【必须由调用方做】—— ACT 10 的 applier 结合
  /// 本地实体是否存在来判定。
  Future<EntityStampRow?> getEntityStamp({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) {
    return (select(db.entityStamps)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                t.entityType.equals(entityType) &
                t.entityId.equals(entityId),
          ))
        .getSingleOrNull();
  }

  /// 读回本设备上次退出时的时钟；从未存过返回 null。
  Future<HlcClockStateRow?> loadClock() {
    return (select(db.hlcClockStates)..where((t) => t.id.equals(0)))
        .getSingleOrNull();
  }

  /// 落盘本设备时钟（单行表，固定 id = 0）。
  Future<void> saveClock({
    required int hlcPacked,
    required String deviceId,
    required DateTime savedAtUtc,
  }) async {
    await into(db.hlcClockStates).insertOnConflictUpdate(
      HlcClockStatesCompanion.insert(
        id: const Value(0),
        hlcPacked: hlcPacked,
        deviceId: deviceId,
        savedAtUtc: savedAtUtc,
      ),
    );
  }
}

@DriftDatabase(
  tables: [
    OutboxRecords,
    SyncStates,
    Seekers,
    Divinations,
    SeekerDivinationMappers,
    CombinedDivinations,
    DecisionLinks,
    DivinationTags,
    DivinationTypes,
    SubDivinationTypes,
    DivinationSubDivinationTypeMappers,
    DivinationCalendars,
    TimingDivinations,
    Panels,
    DivinationPanelMappers,
    PanelSkillClassMappers,
    Skills,
    SkillClasses,
    DaYunRecords,
    TaiYuanRecords,
    DivinationCases,
    DivinationWorkItems,
    CaseParticipants,
    PanelRefs,
    WorkItemPanelRefs,
    CreationAuditLogs,
    OutboxPeerAcks,
    EntityStamps,
    HlcClockStates,
    TRecordMeta,
    TRecordSearchIndex,
    TScopeAlias,
    BlobMetas,
    BlobChunks,
    BlobRefs,
  ],
  daos: [
    OutboxRecordsDao,
    SyncStatesDao,
    SeekersDao,
    DivinationsDao,
    SeekerDivinationMappersDao,
    CombinedDivinationsDao,
    DecisionLinksDao,
    DivinationTagsDao,
    DivinationTypesDao,
    DivinationSubDivinationTypeMappersDao,
    TimingDivinationsDao,
    PanelsDao,
    DivinationPanelMappersDao,
    PanelSkillClassMappersDao,
    DaYunRecordsDao,
    TaiYuanRecordsDao,
    CreationAuditLogsDao,
    EntityStampDao,
  ],
)
class PersistenceDriftDatabase extends _$PersistenceDriftDatabase {
  PersistenceDriftDatabase(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createRecordIndices();
      await _createAuditLogIndices();
      await _createOutboxPeerAckIndices();
      await _createBlobIndices();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(tRecordMeta);
        await m.createTable(tRecordSearchIndex);
        await m.createTable(tScopeAlias);
        await _createRecordIndices();
      }
      if (from < 3) {
        await m.addColumn(decisionLinks, decisionLinks.linkType);
        await m.addColumn(decisionLinks, decisionLinks.sessionId);
        await m.addColumn(decisionLinks, decisionLinks.mergeTargetUuid);
        await m.addColumn(decisionLinks, decisionLinks.inferenceMetaJson);
      }
      if (from < 4) {
        // ignore: experimental_member_use
        await m.alterTable(TableMigration(tRecordMeta));
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_record_meta_occurred '
          'ON t_record_meta(scope_uid, occurred_at_utc DESC)');
      }
      if (from < 5) {
        // schema v5：案例表增 extras_json 列（T1 裁定扩展位）
        await m.addColumn(divinationCases, divinationCases.extrasJson);
      }
      if (from < 6) {
        // schema v6：创建流审计日志表
        await m.createTable(creationAuditLogs);
        await _createAuditLogIndices();
      }
      if (from < 7) {
        // schema v7：per-peer ack 水位表 + t_sync_state 加 peer_id 列（默认 'firestore'）
        // + 主键切到 {scopeUid, peerId, entityType}。
        // 顺序不能换：先加列再切主键 —— TableMigration 建新表时 peer_id 必须已有值。
        await m.createTable(outboxPeerAcks);
        final hasSyncState = (await customSelect(
          "SELECT 1 AS x FROM sqlite_master "
          "WHERE type = 'table' AND name = 't_sync_state'",
        ).get()).isNotEmpty;
        if (hasSyncState) {
          await m.addColumn(syncStates, syncStates.peerId);
          // ignore: experimental_member_use
          await m.alterTable(TableMigration(syncStates));
        } else {
          // 兜底：极早期库（或历史迁移测试手搓的最小旧库）没有 t_sync_state，
          // 直接按 v7 全量定义建表，避免 addColumn 因缺表而抛异常。
          await m.createTable(syncStates);
        }
        await _createOutboxPeerAckIndices();
      }
      if (from < 8) {
        // schema v8：HLC 戳边表 + 时钟单行表（ACT 08）。
        // t_entity_stamp 存每个实体当前版本的 HLC 戳；
        // t_hlc_clock_state 存本设备时钟（单行表，CHECK (id = 0)）。
        await m.createTable(entityStamps);
        await m.createTable(hlcClockStates);
      }
      if (from < 9) {
        // schema v9：blob 元数据、分块持有集合与记录引用表。
        await m.createTable(blobMetas);
        await m.createTable(blobChunks);
        await m.createTable(blobRefs);
        await _createBlobIndices();
      }
    },
  );

  /// 便捷转发：读取某个实体当前的 HLC 戳（边表无行返回 null）。
  /// 见 [EntityStampDao.getEntityStamp]。
  Future<EntityStampRow?> getEntityStamp({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) {
    return entityStampDao.getEntityStamp(
      scopeUid: scopeUid,
      entityType: entityType,
      entityId: entityId,
    );
  }

  /// 便捷转发：在【同一个事务】里写业务记录并更新它的 HLC 戳。
  /// 见 [EntityStampDao.applyWithStamp]（A13 的生产落地点）。
  Future<void> applyWithStamp({
    required String scopeUid,
    required String entityType,
    required String entityId,
    required int hlcPacked,
    required String deviceId,
    required Future<void> Function() write,
  }) {
    return entityStampDao.applyWithStamp(
      scopeUid: scopeUid,
      entityType: entityType,
      entityId: entityId,
      hlcPacked: hlcPacked,
      deviceId: deviceId,
      write: write,
    );
  }

  Future<void> _createRecordIndices() async {
    await customStatement(
      'CREATE INDEX idx_record_meta_scope_created '
      'ON t_record_meta(scope_uid, deleted_at, created_at DESC)');
    await customStatement(
      'CREATE INDEX idx_record_meta_scope_cat_mod '
      'ON t_record_meta(scope_uid, category, module)');
    await customStatement(
      'CREATE INDEX idx_record_meta_scope_type '
      'ON t_record_meta(scope_uid, divination_type)');
    await customStatement(
      'CREATE INDEX idx_record_search '
      'ON t_record_search_index(scope_uid, module, index_key, index_value)');
    await customStatement(
      'CREATE INDEX idx_record_search_by_record '
      'ON t_record_search_index(record_uuid)');
  }

  Future<void> _createAuditLogIndices() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_audit_case_uuid '
      'ON t_creation_audit_logs(case_uuid)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_audit_audited_at '
      'ON t_creation_audit_logs(audited_at DESC)');
  }

  Future<void> _createOutboxPeerAckIndices() async {
    // 升级路径专用：m.createTable 不会创建表声明里的索引（createAll 才会），
    // 因此 from<7 分支必须手动建这两条索引；fresh 库由 indexes getter 经 createAll 建。
    await customStatement(
      'CREATE INDEX idx_outbox_peer_ack_peer_status '
      'ON t_outbox_peer_ack (peer_id, status)');
    await customStatement(
      'CREATE INDEX idx_outbox_peer_ack_operation '
      'ON t_outbox_peer_ack (operation_id)');
  }

  Future<void> _createBlobIndices() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_blob_scope_tier_access '
      'ON t_blob_meta(scope_uid, tier, last_access_at_utc DESC)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_blob_plaintext_sha '
      'ON t_blob_meta(plaintext_sha256)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_blob_status_staged '
      'ON t_blob_meta(status, staged_at_utc)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_blob_external_id '
      'ON t_blob_meta(external_id)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_blob_ref_manifest '
      'ON t_blob_ref(cipher_manifest_id)');
  }
}

/// Drift/SQLite implementation of [OutboxStore].
///
/// 功能说明：
/// - 负责 outbox 入队、批量读取、状态流转（success/failed/dead）与计数查询。
/// - 通过 [SyncLogger] 输出结构化埋点，便于定位 outbox 积压、失败率与耗时。
class DriftOutboxStore implements OutboxStore {
  /// Creates a Drift-backed [OutboxStore].
  ///
  /// 功能说明：
  /// - 为同步引擎提供 Outbox 的 Drift/SQLite 实现。
  /// - 通过可注入的 [SyncLogger] 输出结构化埋点，便于开发调试与生产观测。
  ///
  /// 参数说明：
  /// - [dao]：OutboxRecords 的 DAO。
  /// - [logger]：可选日志器；未传入则为 no-op（生产可按需注入 sink）。
  DriftOutboxStore({required OutboxRecordsDao dao, SyncLogger? logger})
      : _dao = dao,
        _logger = logger ?? SyncLogger.noop();

  final OutboxRecordsDao _dao;
  final SyncLogger _logger;

  /// Redacts potentially sensitive identifiers for production logs.
  ///
  /// 功能说明：
  /// - 用于减少在生产环境中暴露 scopeUid/entityId 等信息的风险。
  ///
  /// 参数说明：
  /// - [value]：原始标识。
  ///
  /// 返回值：
  /// - 脱敏后的字符串。
  String _redactId(String value) {
    if (value.isEmpty) return '***';
    if (value.length <= 6) return '***';
    return '${value.substring(0, 3)}…${value.substring(value.length - 3)}';
  }

  /// Returns a safe-to-log error summary.
  ///
  /// 功能说明：
  /// - 避免将异常对象原样写入日志，降低在生产环境中泄露敏感信息的风险。
  ///
  /// 参数说明：
  /// - [error]：捕获到的异常。
  ///
  /// 返回值：
  /// - 可用于日志采集的精简信息。
  Object _errorSummary(Object error) {
    return <String, Object?>{
      'type': error.runtimeType.toString(),
    };
  }

  OutboxRecord _mapRow(OutboxRecordRow row) {
    return OutboxRecord(
      operationId: row.operationId,
      scopeUid: row.scopeUid,
      entityType: row.entityType,
      entityId: row.entityId,
      opType: row.opType,
      payloadJson: row.payloadJson,
      createdAtUtc: row.createdAtUtc.toUtc(),
      attempt: row.attempt,
    );
  }

  /// Enqueues one outbox record.
  ///
  /// 功能说明：
  /// - 将业务写入转换为 outbox 记录（pending），供后续 push 消费。
  ///
  /// 参数说明：
  /// - [record]：待入队的 outbox 记录。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> enqueue(OutboxRecord record) async {
    final sw = Stopwatch()..start();
    _logger.debug(
      'drift_outbox_enqueue_start',
      data: <String, Object?>{
        'operationId': record.operationId,
        'scopeUid': _redactId(record.scopeUid),
        'entityType': record.entityType,
        'entityId': _redactId(record.entityId),
        'opType': record.opType,
        'attempt': record.attempt,
      },
    );

    try {
      await _dao.enqueue(
        OutboxRecordsCompanion.insert(
          operationId: record.operationId,
          scopeUid: record.scopeUid,
          entityType: record.entityType,
          entityId: record.entityId,
          opType: record.opType,
          payloadJson: record.payloadJson,
          createdAtUtc: record.createdAtUtc,
          attempt: Value(record.attempt),
          payloadSummary: const Value(null),
          payloadHash: const Value(null),
        ),
      );

      _logger.debug(
        'drift_outbox_enqueue_success',
        data: <String, Object?>{
          'operationId': record.operationId,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
    } catch (e, st) {
      _logger.error(
        'drift_outbox_enqueue_error',
        data: <String, Object?>{
          'operationId': record.operationId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Peeks a batch of pending outbox records.
  ///
  /// 功能说明：
  /// - 读取待 push 的记录（通常按 createdAt 排序）。
  /// - 只读取，不更新状态。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [limit]：最大返回数量。
  ///
  /// 返回值：
  /// - outbox 记录列表。
  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
    required int limit,
  }) async {
    final sw = Stopwatch()..start();
    _logger.trace(
      'drift_outbox_peek_batch_start',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'channel': channel.name,
        'limit': limit,
      },
    );

    try {
      final rows = await _dao.peekBatch(
        scopeUid: scopeUid,
        peerId: peerId,
        channel: channel,
        limit: limit,
      );
      final out = rows.map(_mapRow).toList(growable: false);
      _logger.trace(
        'drift_outbox_peek_batch_success',
        data: <String, Object?>{
          'scopeUid': _redactId(scopeUid),
          'peerId': peerId.value,
          'channel': channel.name,
          'requested': limit,
          'returned': out.length,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
      return out;
    } catch (e, st) {
      _logger.error(
        'drift_outbox_peek_batch_error',
        data: <String, Object?>{
          'scopeUid': _redactId(scopeUid),
          'peerId': peerId.value,
          'channel': channel.name,
          'limit': limit,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Marks one outbox record as succeeded.
  ///
  /// 功能说明：
  /// - push 成功后将记录置为 success 并写入成功时间。
  ///
  /// 参数说明：
  /// - [operationId]：操作 id。
  /// - [atUtc]：成功时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markSuccess({
    required String operationId,
    required PeerId peerId,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_outbox_mark_success',
      data: <String, Object?>{
        'operationId': operationId,
        'peerId': peerId.value,
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markSuccess(operationId: operationId, peerId: peerId, atUtc: atUtc);
  }

  /// Marks one outbox record as failed (or dead).
  ///
  /// 功能说明：
  /// - push 失败时记录错误信息与重试次数；达到阈值时标记为 dead。
  ///
  /// 参数说明：
  /// - [operationId]：操作 id。
  /// - [attempt]：本次失败后 attempt 值。
  /// - [errorCode]：错误码（可用于聚合统计）。
  /// - [errorMessage]：错误信息（注意：该值会写入本地 DB）。
  /// - [atUtc]：失败时间（UTC）。
  /// - [isDead]：是否进入死信。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markFailed({
    required String operationId,
    required PeerId peerId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) {
    _logger.debug(
      'drift_outbox_mark_failed',
      data: <String, Object?>{
        'operationId': operationId,
        'peerId': peerId.value,
        'attempt': attempt,
        'errorCode': errorCode,
        'isDead': isDead,
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markFailed(
      operationId: operationId,
      peerId: peerId,
      attempt: attempt,
      errorCode: errorCode,
      errorMessage: errorMessage,
      atUtc: atUtc,
      isDead: isDead,
    );
  }

  /// 读取【某一条记录对某一个对端】的当前重试次数。
  ///
  /// ack 行不存在（从未推送过）时返回 0，不抛异常。
  @override
  Future<int> attemptFor({
    required String operationId,
    required PeerId peerId,
  }) {
    _logger.trace(
      'drift_outbox_attempt_for',
      data: <String, Object?>{
        'operationId': operationId,
        'peerId': peerId.value,
      },
    );
    return _dao.attemptFor(operationId: operationId, peerId: peerId);
  }

  /// Returns count of pending/failed (non-dead) records for a scope.
  ///
  /// 功能说明：
  /// - 用于观测 backlog 规模与同步压力。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [peerId]：对端。
  /// - [channel]：对端所在通道（与 peekBatch 同套过滤）。
  ///
  /// 返回值：
  /// - backlog 数量。
  @override
  Future<int> backlogCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) {
    _logger.trace(
      'drift_outbox_backlog_count',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'channel': channel.name,
      },
    );
    return _dao.backlogCount(
      scopeUid: scopeUid,
      peerId: peerId,
      channel: channel,
    );
  }

  @override
  Stream<int> watchBacklogCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) {
    _logger.trace(
      'drift_outbox_watch_backlog_count',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'channel': channel.name,
      },
    );
    return _dao
        .watchBacklogCount(
          scopeUid: scopeUid,
          peerId: peerId,
          channel: channel,
        )
        .distinct();
  }

  /// Returns count of dead-letter records for a scope.
  ///
  /// 功能说明：
  /// - 用于观测不可恢复失败的积压。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [peerId]：对端。
  /// - [channel]：对端所在通道（与 backlogCount 同套过滤）。
  ///
  /// 返回值：
  /// - dead 数量。
  @override
  Future<int> deadCount({
    required String scopeUid,
    required PeerId peerId,
    required Channel channel,
  }) {
    _logger.trace(
      'drift_outbox_dead_count',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'channel': channel.name,
      },
    );
    return _dao.deadCount(
      scopeUid: scopeUid,
      peerId: peerId,
      channel: channel,
    );
  }
}

/// Drift/SQLite implementation of [SyncStateStore].
///
/// 功能说明：
/// - 负责保存与推进 pull cursor（timestamp/revision）。
/// - 记录最近 pulledAt/pushedAt 时间，用于观测与诊断。
/// - 通过 [SyncLogger] 输出结构化埋点。
class DriftSyncStateStore implements SyncStateStore {
  /// Creates a Drift-backed [SyncStateStore].
  ///
  /// 功能说明：
  /// - 保存并推进 pull cursor、记录最近 pull/push 时间。
  /// - 通过可注入的 [SyncLogger] 输出结构化埋点。
  ///
  /// 参数说明：
  /// - [dao]：SyncStates 的 DAO。
  /// - [logger]：可选日志器；未传入则为 no-op。
  DriftSyncStateStore({required SyncStatesDao dao, SyncLogger? logger})
      : _dao = dao,
        _logger = logger ?? SyncLogger.noop();

  final SyncStatesDao _dao;
  final SyncLogger _logger;

  /// Redacts potentially sensitive identifiers for production logs.
  ///
  /// 功能说明：
  /// - 用于减少在生产环境中暴露 scopeUid/entityType 的风险。
  ///
  /// 参数说明：
  /// - [value]：原始标识。
  ///
  /// 返回值：
  /// - 脱敏后的字符串。
  String _redactId(String value) {
    if (value.isEmpty) return '***';
    if (value.length <= 6) return '***';
    return '${value.substring(0, 3)}…${value.substring(value.length - 3)}';
  }

  /// Returns current pull cursor for one entity type.
  ///
  /// 功能说明：
  /// - 读取上次 pull 的游标；用于从远端增量拉取。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - 游标（可能为 null）。
  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) async {
    final sw = Stopwatch()..start();
    final row =
        await _dao.find(scopeUid: scopeUid, peerId: peerId, entityType: entityType);
    PullCursor? out;
    String cursorType = 'none';

    if (row != null) {
      cursorType = row.cursorType;

      if (row.cursorType == 'timestamp' &&
          row.serverUpdatedAtUtc != null &&
          row.tieBreaker != null) {
        out = TimestampCursor(
          serverUpdatedAtUtc: row.serverUpdatedAtUtc!.toUtc(),
          tieBreaker: row.tieBreaker!,
        );
      } else if (row.cursorType == 'revision' && row.revision != null) {
        out = RevisionCursor(revision: row.revision!);
      } else {
        out = null;
      }
    }

    _logger.trace(
      'drift_sync_state_get_cursor',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'entityType': entityType,
        'cursorType': cursorType,
        'returned': out?.runtimeType.toString(),
        'durationMs': sw.elapsedMilliseconds,
      },
    );

    return out;
  }

  /// Advances cursor if newer.
  ///
  /// 功能说明：
  /// - 只允许 cursor 单调递增，避免回退导致重复拉取。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [cursor]：候选新游标。
  /// - [atUtc]：更新时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_sync_state_set_cursor_if_newer',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'entityType': entityType,
        'cursorType': cursor.runtimeType.toString(),
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    if (cursor is TimestampCursor) {
      return _dao.setTimestampCursorIfNewer(
        scopeUid: scopeUid,
        peerId: peerId,
        entityType: entityType,
        serverUpdatedAtUtc: cursor.serverUpdatedAtUtc,
        tieBreaker: cursor.tieBreaker,
        atUtc: atUtc,
      );
    }

    if (cursor is RevisionCursor) {
      return _dao.setRevisionCursorIfNewer(
        scopeUid: scopeUid,
        peerId: peerId,
        entityType: entityType,
        revision: cursor.revision,
        atUtc: atUtc,
      );
    }

    throw UnsupportedError('Unsupported cursor type: ${cursor.runtimeType}');
  }

  /// Clears sync state for one entity type.
  ///
  /// 功能说明：
  /// - 用于重置 cursor（例如需要全量重拉）。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> clear({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
  }) {
    _logger.warn(
      'drift_sync_state_clear',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'entityType': entityType,
      },
    );
    return _dao.clear(scopeUid: scopeUid, peerId: peerId, entityType: entityType);
  }

  /// Marks last pulled timestamp for a scope + entity type.
  ///
  /// 功能说明：
  /// - 仅用于观测与诊断，不影响 cursor。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [atUtc]：拉取完成时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required PeerId peerId,
    required String entityType,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_sync_state_mark_pulled_at',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'entityType': entityType,
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markPulledAt(
        scopeUid: scopeUid, peerId: peerId, entityType: entityType, atUtc: atUtc);
  }

  /// Marks last pushed timestamp for a scope.
  ///
  /// 功能说明：
  /// - 仅用于观测与诊断，不影响 outbox 逻辑。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [atUtc]：push 完成时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required PeerId peerId,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_sync_state_mark_pushed_at',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'peerId': peerId.value,
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markPushedAt(scopeUid: scopeUid, peerId: peerId, atUtc: atUtc);
  }
}
