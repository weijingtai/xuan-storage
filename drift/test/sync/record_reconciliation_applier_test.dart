import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/sync/record_local_applier.dart';
import 'package:persistence_drift/sync/record_outbox_mapper.dart';
import 'package:persistence_drift/sync/record_reconciliation_applier.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// S1c ACT-D 集成测试：RecordReconciliationApplier（全量对齐落库）。
///
/// 覆盖：
/// 1. 活终态落地（写 record + 戳）。
/// 2. 墓碑终态落地（is_deleted=true，记录删除）。
/// 3. 冲突留档计数（takeRemote 覆盖 / keepLocal 丢远端 都算）。
/// 4. 墓碑复活（对端活终态戳更大 → 本地墓碑复活为活记录）。
void main() {
  const scope = 'recon-scope';

  test('alive_terminal_writes_record_and_stamp', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: scope);
    final applier = _buildApplier(db, ds, scope);

    final terminal = EntityTerminal(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
      isDeleted: false,
      hlcPacked: 2000 << 16,
      deviceId: 'dev-a',
      payloadJson: '{"meta":${jsonMeta(scope, 'r1')},"searchTags":[]}',
    );

    final result = await applier.applyTerminals(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      terminals: [terminal],
    );

    expect(result.recordsReconciled, 1);
    expect(result.conflictsLogged, 0);
    expect(result.blobsPending, 0);

    final localMeta = await ds.getRecord('r1');
    expect(localMeta, isNotNull, reason: '活终态必须写入本地 record');
    final stamp = await db.getEntityStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
    );
    expect(stamp, isNotNull);
    expect(stamp!.hlcPacked, 2000 << 16);
    expect(stamp.deviceId, 'dev-a');
    expect(stamp.isDeleted, isFalse);
  });

  test('tombstone_terminal_writes_tombstone_marker', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: scope);
    final applier = _buildApplier(db, ds, scope);

    final terminal = EntityTerminal(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
      isDeleted: true,
      hlcPacked: 3000 << 16,
      deviceId: 'dev-b',
    );

    final result = await applier.applyTerminals(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      terminals: [terminal],
    );

    expect(result.recordsReconciled, 1);
    final stamp = await db.getEntityStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
    );
    expect(stamp, isNotNull);
    expect(stamp!.isDeleted, isTrue, reason: '墓碑终态必须置 is_deleted=true');
    expect(stamp.hlcPacked, 3000 << 16);
  });

  test('take_remote_overwrite_logs_conflict', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: scope);
    final applier = _buildApplier(db, ds, scope);

    // 先写入本地较旧版本（hlc = 1000）
    await ds.applyRemoteRecord(_recordMeta(scope, 'r1'), const []);
    await db.applyWithStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
      hlcPacked: 1000 << 16,
      deviceId: 'dev-local',
      write: () async {},
    );

    // 对端终态戳更大（hlc = 5000）→ takeRemote 覆盖本地 → 留档 1
    final result = await applier.applyTerminals(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      terminals: [
        EntityTerminal(
          scopeUid: scope,
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          isDeleted: false,
          hlcPacked: 5000 << 16,
          deviceId: 'dev-remote',
          payloadJson: '{"meta":${jsonMeta(scope, 'r1')},"searchTags":[]}',
        ),
      ],
    );

    expect(result.conflictsLogged, 1, reason: '覆盖本地必须计入冲突留档');
    final stamp = await db.getEntityStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
    );
    expect(stamp!.hlcPacked, 5000 << 16);
  });

  test('keep_local_discards_remote_logs_conflict', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: scope);
    final applier = _buildApplier(db, ds, scope);

    // 本地较新（hlc = 8000）
    await ds.applyRemoteRecord(_recordMeta(scope, 'r1'), const []);
    await db.applyWithStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
      hlcPacked: 8000 << 16,
      deviceId: 'dev-local',
      write: () async {},
    );

    // 对端终态戳更小（hlc = 3000）→ keepLocal 丢远端 → 留档 1
    final result = await applier.applyTerminals(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      terminals: [
        EntityTerminal(
          scopeUid: scope,
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          isDeleted: false,
          hlcPacked: 3000 << 16,
          deviceId: 'dev-remote',
          payloadJson: '{"meta":${jsonMeta(scope, 'r1')},"searchTags":[]}',
        ),
      ],
    );

    expect(result.conflictsLogged, 1, reason: '丢弃远端必须计入冲突留档');
    final stamp = await db.getEntityStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
    );
    expect(stamp!.hlcPacked, 8000 << 16, reason: '本地版本必须保留');
  });

  test('tombstone_revives_when_remote_alive_and_newer', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: scope);
    final applier = _buildApplier(db, ds, scope);

    // 本地墓碑（hlc = 1000, is_deleted=true）
    await db.applyWithStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
      hlcPacked: 1000 << 16,
      deviceId: 'dev-local',
      write: () async {},
      isDeleted: true,
    );

    // 对端活终态戳更大（hlc = 6000）→ takeRemote + isDeleted=false → 复活
    final result = await applier.applyTerminals(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      terminals: [
        EntityTerminal(
          scopeUid: scope,
          entityType: RecordOutboxMapper.entityType,
          entityId: 'r1',
          isDeleted: false,
          hlcPacked: 6000 << 16,
          deviceId: 'dev-remote',
          payloadJson: '{"meta":${jsonMeta(scope, 'r1')},"searchTags":[]}',
        ),
      ],
    );

    expect(result.recordsReconciled, 1);
    final stamp = await db.getEntityStamp(
      scopeUid: scope,
      entityType: RecordOutboxMapper.entityType,
      entityId: 'r1',
    );
    expect(stamp!.isDeleted, isFalse, reason: '活终态戳更大 → 本地墓碑复活');
    expect(stamp.hlcPacked, 6000 << 16);
  });
}

RecordReconciliationApplier _buildApplier(
  PersistenceDriftDatabase db,
  DriftRecordDataSource ds,
  String scope,
) {
  final delegate = RecordLocalApplier(
    scopeUid: scope,
    applyRecord: ds.applyRemoteRecord,
    deleteRecord: ds.softDeleteRecord,
    readLocalRecord: (uuid) => ds.getRecord(uuid),
    readLocalStamp: (entityId) => db.getEntityStamp(
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
    arbiter: const HlcConflictArbiter(),
  );
  return RecordReconciliationApplier(
    delegate: delegate,
    nowUtc: () => DateTime.fromMillisecondsSinceEpoch(1700000000000),
  );
}

/// 生成 record payload 的 meta 段（RecordOutboxMapper 的线上格式）。
String jsonMeta(String scope, String uuid) =>
    '{"uuid":"$uuid","scopeUid":"$scope","module":"meihua",'
    '"category":"divination","divinationType":"mei_hua","createdAt":"2026-01-01T00:00:00.000Z"}';

/// 构造一个 record 实体（供 applyRemoteRecord 直接写入）。
RecordMeta _recordMeta(String scope, String uuid) => RecordMeta(
      uuid: uuid,
      scopeUid: scope,
      module: 'meihua',
      category: 'divination',
      divinationType: 'mei_hua',
      createdAt: DateTime.utc(2026, 1, 1),
    );
