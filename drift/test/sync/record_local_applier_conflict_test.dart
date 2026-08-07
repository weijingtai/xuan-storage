import 'dart:convert';

import 'package:crdt/crdt.dart' show Hlc;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/sync/record_local_applier.dart';
import 'package:persistence_drift/sync/record_outbox_mapper.dart';

RecordMeta _meta(String uuid, {String scope = 's1'}) => RecordMeta(
  uuid: uuid, scopeUid: scope, module: 'meihua', category: 'divination',
  divinationType: 'mei_hua', createdAt: DateTime.utc(2026),
);

RemoteChange _change(
  String opId,
  String entityId, {
  Map<String, dynamic>? payload,
  int? hlcPacked,
  String? deviceId,
  String opType = 'UPSERT',
}) {
  return RemoteChange(
    operationId: opId,
    entityType: RecordOutboxMapper.entityType,
    entityId: entityId,
    opType: opType,
    payloadJson: payload == null ? '{}' : jsonEncode(payload),
    cursor: TimestampCursor(
      serverUpdatedAtUtc: DateTime.utc(2026),
      tieBreaker: opId,
    ),
    serverTimeUtc: DateTime.utc(2026),
    hlcPacked: hlcPacked,
    deviceId: deviceId,
  );
}

Map<String, dynamic> _upsertPayload(RecordMeta meta) => {
  'meta': RecordOutboxMapper.metaToJson(meta),
  'searchTags': <Map<String, String>>[],
};

/// 恒返回 keepLocal 的 fake 仲裁器。
class _KeepLocalArbiter implements ConflictArbiter {
  const _KeepLocalArbiter();
  @override
  ArbitrationDecision arbitrate({
    required VersionStamp? remote,
    required VersionStamp? local,
  }) =>
      ArbitrationDecision.keepLocal;
}

/// 恒返回 takeRemote 的 fake 仲裁器。
class _TakeRemoteArbiter implements ConflictArbiter {
  const _TakeRemoteArbiter();
  @override
  ArbitrationDecision arbitrate({
    required VersionStamp? remote,
    required VersionStamp? local,
  }) =>
      ArbitrationDecision.takeRemote;
}

/// 计数式 fake 时钟：记录 observe 调用。
class _CountingClock implements HlcClock {
  int observeCount = 0;
  final List<String> observedNodes = [];
  final List<String> sequence = [];

  @override
  String get deviceId => 'device-test';

  @override
  Hlc get current => Hlc.now(deviceId);

  @override
  Future<Hlc> tick() async => Hlc.now(deviceId);

  @override
  Future<void> observe(Hlc remote) async {
    observeCount += 1;
    observedNodes.add(remote.nodeId);
    sequence.add('observe');
  }
}

void main() {
  late PersistenceDriftDatabase db;
  late DriftRecordDataSource ds;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    ds = DriftRecordDataSource(db, scopeUid: 's1');
  });

  tearDown(() async => await db.close());

  RecordLocalApplier applierHelper({
    ConflictArbiter arbiter = const HlcConflictArbiter(),
    Future<void> Function(RecordMeta, List<SearchTag>)? applyRecord,
    Future<bool> Function(String)? deleteRecord,
    Future<RecordMeta?> Function(String)? readLocalRecord,
    Future<EntityStampRow?> Function(String)? readLocalStamp,
    HlcClock? clock,
    String scope = 's1',
  }) {
    return RecordLocalApplier(
      scopeUid: scope,
      applyRecord: applyRecord ?? ds.applyRemoteRecord,
      deleteRecord: deleteRecord ?? ds.softDeleteRecord,
      readLocalRecord: readLocalRecord ?? (uuid) => ds.getRecord(uuid),
      readLocalStamp: readLocalStamp ??
          (entityId) => db.getEntityStamp(
            scopeUid: scope,
            entityType: RecordOutboxMapper.entityType,
            entityId: entityId,
          ),
      applyWithStamp: ({
        required entityType,
        required entityId,
        required hlcPacked,
        required deviceId,
        required write,
        bool isDeleted = false,
      }) =>
          db.applyWithStamp(
            scopeUid: scope,
            entityType: entityType,
            entityId: entityId,
            hlcPacked: hlcPacked,
            deviceId: deviceId,
            write: write,
              isDeleted: isDeleted,
          ),
      arbiter: arbiter,
      clock: clock,
    );
  }

  group('cursor 推进规则', () {
    test('failed_change_blocks_cursor_advance', () async {
      // 中间那条 applyRecord 抛异常
      final applyCalls = <String>[];
      final applier = applierHelper(
        applyRecord: (meta, tags) async {
          applyCalls.add(meta.uuid);
          if (meta.uuid == 'r2') {
            throw StateError('write failed for r2');
          }
        },
      );

      final changes = [
        _change('op-1', 'r1',
            payload: _upsertPayload(_meta('r1')),
            hlcPacked: 100, deviceId: 'device-a'),
        _change('op-2', 'r2',
            payload: _upsertPayload(_meta('r2')),
            hlcPacked: 200, deviceId: 'device-a'),
        _change('op-3', 'r3',
            payload: _upsertPayload(_meta('r3')),
            hlcPacked: 300, deviceId: 'device-a'),
      ];

      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: changes,
      );

      expect(result.canAdvanceCursor, isFalse,
          reason: '有任何 failed 就不得推进游标');
      expect(result.lastError, isNotNull);
      expect(result.lastError!.message, contains('op-2'),
          reason: 'lastError 必须带第一条失败 change 的 operationId');
      expect(result.appliedCount, 2,
          reason: '一条失败不该中断整批');
      expect(
        result.outcomes.where((o) => o.decision == ChangeApplyDecision.failed),
        hasLength(1),
      );
    });

    test('skipped_change_does_not_block_cursor_advance', () async {
      final applier = applierHelper(
        arbiter: const _KeepLocalArbiter(),
        readLocalStamp: (_) async => EntityStampRow(
          scopeUid: 's1',
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          hlcPacked: 500,
          deviceId: 'device-local',
          isDeleted: false,
        ),
      );
      await ds.applyRemoteRecord(_meta('r1'), const []);

      final changes = [
        _change('op-1', 'r1',
            payload: _upsertPayload(_meta('r1')),
            hlcPacked: 100, deviceId: 'device-remote'),
        _change('op-2', 'r2',
            payload: _upsertPayload(_meta('r2')),
            hlcPacked: 200, deviceId: 'device-remote'),
      ];

      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: changes,
      );

      expect(result.canAdvanceCursor, isTrue,
          reason: 'skipped（仲裁 keepLocal）不阻止游标推进');
    });

    test('all_success_still_advances_cursor', () async {
      final applier = applierHelper();
      final changes = [
        _change('op-1', 'r1',
            payload: _upsertPayload(_meta('r1')),
            hlcPacked: 100, deviceId: 'device-a'),
      ];
      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: changes,
      );
      expect(result.canAdvanceCursor, isTrue);
      expect(result.lastError, isNull);
    });

    test('entity_type_mismatch_still_blocks_advance', () async {
      final applier = applierHelper();
      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: 'wrong_type',
        changes: [_change('op-1', 'r1')],
      );
      expect(result.canAdvanceCursor, isFalse);
    });
  });

  group('scope 绑定', () {
    test('rejects_scope_mismatch', () async {
      // scope-A 的 applier + scope-A 的 ds
      final dsA = DriftRecordDataSource(db, scopeUid: 'scope-A');
      final applierA = RecordLocalApplier(
        scopeUid: 'scope-A',
        applyRecord: dsA.applyRemoteRecord,
        deleteRecord: dsA.softDeleteRecord,
        readLocalRecord: (uuid) => dsA.getRecord(uuid),
        readLocalStamp: (entityId) => db.getEntityStamp(
          scopeUid: 'scope-A',
          entityType: RecordOutboxMapper.entityType,
          entityId: entityId,
        ),
        applyWithStamp: ({
          required entityType,
          required entityId,
          required hlcPacked,
          required deviceId,
          required write,
          bool isDeleted = false,
        }) =>
            db.applyWithStamp(
              scopeUid: 'scope-A',
              entityType: entityType,
              entityId: entityId,
              hlcPacked: hlcPacked,
              deviceId: deviceId,
              write: write,
              isDeleted: isDeleted,
            ),
        arbiter: const HlcConflictArbiter(),
      );

      final result = await applierA.applyRemoteChanges(
        scopeUid: 'scope-B',
        entityType: RecordOutboxMapper.entityType,
        changes: [
          _change('op-1', 'shared-id',
              payload: _upsertPayload(_meta('shared-id', scope: 'scope-B')),
              hlcPacked: 100, deviceId: 'device-b'),
        ],
      );

      expect(result.canAdvanceCursor, isFalse,
          reason: '传错 scope 是调用方 bug，绝不能让游标推进');
      expect(result.appliedCount, 0);
      expect(result.outcomes, isEmpty, reason: '一条都不许应用');
      expect(result.lastError, isNotNull);
      expect(result.lastError!.message, contains('scope'));

      // scope-A 库里没有任何写入（防跨租户串写）
      expect(await dsA.getRecord('shared-id'), isNull,
          reason: 'scope-B 的 change 绝不能写进 scope-A 的库');
    });

    test('same_uuid_in_two_scopes_never_cross_reads', () async {
      // scope-A：'shared-id' 存在本地实体 + 边表有戳
      final dsA = DriftRecordDataSource(db, scopeUid: 'scope-A');
      await dsA.applyRemoteRecord(_meta('shared-id', scope: 'scope-A'), const []);
      await db.applyWithStamp(
        scopeUid: 'scope-A',
        entityType: RecordOutboxMapper.entityType,
        entityId: 'shared-id',
        hlcPacked: 900,
        deviceId: 'device-a',
        write: () async {},
      );

      // scope-B：'shared-id' 不存在
      final dsB = DriftRecordDataSource(db, scopeUid: 'scope-B');

      final applierA = RecordLocalApplier(
        scopeUid: 'scope-A',
        applyRecord: dsA.applyRemoteRecord,
        deleteRecord: dsA.softDeleteRecord,
        readLocalRecord: (uuid) => dsA.getRecord(uuid),
        readLocalStamp: (entityId) => db.getEntityStamp(
          scopeUid: 'scope-A',
          entityType: RecordOutboxMapper.entityType,
          entityId: entityId,
        ),
        applyWithStamp: ({
          required entityType,
          required entityId,
          required hlcPacked,
          required deviceId,
          required write,
          bool isDeleted = false,
        }) =>
            db.applyWithStamp(
              scopeUid: 'scope-A',
              entityType: entityType,
              entityId: entityId,
              hlcPacked: hlcPacked,
              deviceId: deviceId,
              write: write,
              isDeleted: isDeleted,
            ),
        arbiter: const HlcConflictArbiter(),
      );
      final applierB = RecordLocalApplier(
        scopeUid: 'scope-B',
        applyRecord: dsB.applyRemoteRecord,
        deleteRecord: dsB.softDeleteRecord,
        readLocalRecord: (uuid) => dsB.getRecord(uuid),
        readLocalStamp: (entityId) => db.getEntityStamp(
          scopeUid: 'scope-B',
          entityType: RecordOutboxMapper.entityType,
          entityId: entityId,
        ),
        applyWithStamp: ({
          required entityType,
          required entityId,
          required hlcPacked,
          required deviceId,
          required write,
          bool isDeleted = false,
        }) =>
            db.applyWithStamp(
              scopeUid: 'scope-B',
              entityType: entityType,
              entityId: entityId,
              hlcPacked: hlcPacked,
              deviceId: deviceId,
              write: write,
              isDeleted: isDeleted,
            ),
        arbiter: const HlcConflictArbiter(),
      );

      // 同一条远端 change（uuid shared-id，远端戳更旧 → scope-A 走仲裁 keepLocal）
      final change = _change('op-1', 'shared-id',
          payload: _upsertPayload(_meta('shared-id', scope: 'scope-B')),
          hlcPacked: 100, deviceId: 'device-remote');

      final rA = await applierA.applyRemoteChanges(
        scopeUid: 'scope-A',
        entityType: RecordOutboxMapper.entityType,
        changes: [change],
      );
      final rB = await applierB.applyRemoteChanges(
        scopeUid: 'scope-B',
        entityType: RecordOutboxMapper.entityType,
        changes: [change],
      );

      // scope-A：本地有实体 → 进入仲裁，远端败（keepLocal）→ 留档 discardedSide==local? 不对——
      // keepLocal 时丢弃的是远端，discardedSide==remote。这里验证 scope-A 走了仲裁分支。
      expect(rA.outcomes.single.decision, ChangeApplyDecision.skipped,
          reason: 'scope-A 有实体有戳，远端更旧 → keepLocal（skipped）');
      // scope-B：本地无实体 → 直接应用
      expect(rB.outcomes.single.decision, ChangeApplyDecision.applied,
          reason: 'scope-B 无实体 → 直接应用');
      expect(rB.outcomes.single.discardedSide, isNull,
          reason: '本地无实体时不得产生 discarded 留档');
    });
  });

  group('畸形 payload 与失败', () {
    test('malformed_payload_is_failed_and_blocks_cursor', () async {
      final changes = [
        // ① payloadJson 不是合法 JSON
        _change('op-bad-json', 'r1', payload: null),
        // ③ 写库回调抛异常
        _change('op-throw', 'r2',
            payload: _upsertPayload(_meta('r2')),
            hlcPacked: 200, deviceId: 'device-a'),
      ];
      // 用注入的抛异常 applyRecord 触发③
      final applierThrow = applierHelper(
        applyRecord: (_, _) async => throw StateError('write boom'),
      );
      final result = await applierThrow.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: changes,
      );
      expect(
        result.outcomes.every((o) => o.decision == ChangeApplyDecision.failed),
        isTrue,
        reason: '畸形 payload 与写库异常必须归 failed',
      );
      expect(result.canAdvanceCursor, isFalse);
      expect(result.lastError, isNotNull);
    });
  });

  group('仲裁留档', () {
    test('keep_local_archives_the_discarded_remote', () async {
      final applier = applierHelper(
        arbiter: const _KeepLocalArbiter(),
        readLocalStamp: (_) async => EntityStampRow(
          scopeUid: 's1',
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          hlcPacked: 500,
          deviceId: 'device-local',
          isDeleted: false,
        ),
      );
      await ds.applyRemoteRecord(_meta('r1'), const []);
      final remotePayload = _upsertPayload(_meta('r1'));

      final change = _change('op-1', 'r1',
          payload: remotePayload, hlcPacked: 100, deviceId: 'device-remote');
      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: [change],
      );

      final outcome = result.outcomes.single;
      expect(outcome.decision, ChangeApplyDecision.skipped);
      expect(result.canAdvanceCursor, isTrue,
          reason: 'skipped 不阻止游标推进');
      expect(outcome.discardedSide, ConflictSide.remote);
      expect(outcome.discardedPayloadJson, jsonEncode(remotePayload),
          reason: '被丢弃的远端 payload 必须留档');
      expect(outcome.discardedStamp, isNotNull);
    });

    test('arbiter_keep_local_records_skipped_not_applied', () async {
      var applyCount = 0;
      final applier = applierHelper(
        arbiter: const _KeepLocalArbiter(),
        applyRecord: (_, _) async => applyCount += 1,
        readLocalStamp: (_) async => EntityStampRow(
          scopeUid: 's1',
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          hlcPacked: 500,
          deviceId: 'device-local',
          isDeleted: false,
        ),
      );
      final change = _change('op-1', 'r1',
          payload: _upsertPayload(_meta('r1')),
          hlcPacked: 100, deviceId: 'device-remote');
      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: [change],
      );
      expect(applyCount, 0, reason: '仲裁挡在写库之前');
      expect(result.outcomes.single.decision, ChangeApplyDecision.skipped);
      expect(result.appliedCount, 0);
    });

    test('take_remote_archives_the_overwritten_local', () async {
      final applier = applierHelper(
        arbiter: const _TakeRemoteArbiter(),
        readLocalStamp: (_) async => EntityStampRow(
          scopeUid: 's1',
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          hlcPacked: 500,
          deviceId: 'device-local',
          isDeleted: false,
        ),
      );
      // 本地已有一个可辨识的旧 payload
      final oldMeta = _meta('r1').copyWith(question: 'old-question');
      await ds.applyRemoteRecord(oldMeta, const []);

      final remoteChange = _change('op-1', 'r1',
          payload: _upsertPayload(_meta('r1').copyWith(question: 'new-question')),
          hlcPacked: 900, deviceId: 'device-remote');

      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: [remoteChange],
      );

      final outcome = result.outcomes.single;
      expect(outcome.decision, ChangeApplyDecision.applied);
      expect(outcome.discardedSide, ConflictSide.local);
      expect(outcome.discardedPayloadJson, contains('old-question'),
          reason: '被覆盖的本地 payload 必须留档（不是新的）');
      expect(outcome.discardedStamp, isNotNull);
    });

    test('stampless_existing_local_is_archived_but_absent_local_is_not',
        () async {
      // 场景①：本地无实体 → 不留档
      final applierAbsent = applierHelper(arbiter: const _TakeRemoteArbiter());
      final rAbsent = await applierAbsent.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: [
          _change('op-1', 'r-absent',
              payload: _upsertPayload(_meta('r-absent')),
              hlcPacked: 900, deviceId: 'device-remote'),
        ],
      );
      expect(rAbsent.outcomes.single.discardedSide, isNull,
          reason: '本地无实体，无数据被覆盖，不留档');
      expect(rAbsent.outcomes.single.discardedPayloadJson, isNull);

      // 场景②：本地有实体（历史数据）但边表无戳 → 必须留档 local
      await ds.applyRemoteRecord(_meta('r-historic'), const []);
      final applierHistoric = applierHelper(arbiter: const _TakeRemoteArbiter());
      final rHistoric = await applierHistoric.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: [
          _change('op-2', 'r-historic',
              payload: _upsertPayload(_meta('r-historic')),
              hlcPacked: 900, deviceId: 'device-remote'),
        ],
      );
      expect(rHistoric.outcomes.single.discardedSide, ConflictSide.local,
          reason: '本地有实体无戳，被覆盖时必须留档');
      expect(rHistoric.outcomes.single.discardedStamp, isNull,
          reason: '本来就没戳，discardedStamp 为 null 合法');
    });
  });

  group('无戳远端与 observe', () {
    test('missing_hlc_on_remote_change_keeps_local', () async {
      var applyCount = 0;
      final applier = applierHelper(
        arbiter: const HlcConflictArbiter(),
        applyRecord: (_, _) async => applyCount += 1,
        readLocalStamp: (_) async => EntityStampRow(
          scopeUid: 's1',
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          hlcPacked: 500,
          deviceId: 'device-local',
          isDeleted: false,
        ),
      );
      await ds.applyRemoteRecord(_meta('r1'), const []);

      // 不带 hlcPacked（历史 oplog 条目）
      final change = _change('op-1', 'r1',
          payload: _upsertPayload(_meta('r1')));
      final result = await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: [change],
      );
      expect(result.outcomes.single.decision, ChangeApplyDecision.skipped,
          reason: 'remote 无戳 → keepLocal（fail-safe）');
      expect(result.outcomes.single.discardedSide, ConflictSide.remote);
      expect(applyCount, 0, reason: 'keepLocal 时不得应用');
    });

    test('observe_called_on_every_stamped_inbound_change', () async {
      final clock = _CountingClock();
      final applier = applierHelper(clock: clock);

      // 5 条带戳 + 2 条不带
      final changes = [
        for (var i = 0; i < 5; i += 1)
          _change('op-$i', 'r$i',
              payload: _upsertPayload(_meta('r$i')),
              hlcPacked: 100 + i, deviceId: 'device-$i'),
        _change('op-5', 'r5', payload: _upsertPayload(_meta('r5'))),
        _change('op-6', 'r6', payload: _upsertPayload(_meta('r6'))),
      ];

      await applier.applyRemoteChanges(
        scopeUid: 's1',
        entityType: RecordOutboxMapper.entityType,
        changes: changes,
      );

      expect(clock.observeCount, 5,
          reason: '恰好 5 条带戳，observe 必须被调用恰好 5 次');
    });
  });
}
