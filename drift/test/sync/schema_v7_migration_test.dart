import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

/// ACT 03 迁移测试：v6 → v7（t_outbox_peer_ack 新表 + t_sync_state 加 peer_id 列
/// + 主键切三元组）。
///
/// 骨架照抄 creation_audit_logs_schema_v6_migration_test.dart 与
/// record_meta_schema_v4_migration_test.dart：手工建旧库 → 触发升级 → 逐字段比对。
void main() {
  test('v6_upgrade_preserves_every_cursor_field', () async {
    // 1. 造一个 v6 形态的 t_sync_state（主键 {scope_uid, entity_type}），插 3 行
    //    可辨识数据（每个字段都填互不相同的值，null 比对不出搬运错误）。
    final sqliteDb = sqlite3.openInMemory();
    sqliteDb.execute('''
      CREATE TABLE t_sync_state (
        scope_uid TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        cursor_type TEXT NOT NULL,
        revision INTEGER,
        server_updated_at_utc INTEGER,
        tie_breaker TEXT,
        cursor_updated_at_utc INTEGER NOT NULL,
        last_pulled_at_utc INTEGER,
        last_pushed_at_utc INTEGER,
        PRIMARY KEY (scope_uid, entity_type)
      );
      PRAGMA user_version = 6;
    ''');
    sqliteDb.execute('''
      INSERT INTO t_sync_state VALUES
      ('scope-a', 'record', 'TimestampCursor', 1, 1001, 'tb-a', 2001, 3001, 4001),
      ('scope-a', 'divination_case', 'RevisionCursor', 2, 1002, 'tb-b', 2002, 3002, 4002),
      ('scope-b', 'record', 'TimestampCursor', 3, 1003, 'tb-c', 2003, 3003, 4003);
    ''');

    // 2. 打开 PersistenceDriftDatabase 触发升级
    final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
    addTearDown(db.close);

    // 2.1 执行一次 drift 查询触发惰性迁移（drift 不会在构造时升级 schema）
    await db.select(db.syncStates).get();

    // 3. 断言升级后行数与字段逐字未丢
    final rows = sqliteDb.select('SELECT * FROM t_sync_state ORDER BY rowid').toList();
    expect(rows.length, 3, reason: '行数不再是 3 —— 漏搬数据');

    // 列序 = v7 表定义序（TableMigration 按 Dart 表定义重建）：peer_id 在第 3 列。
    final expected = [
      ['scope-a', 'record', 'firestore', 'TimestampCursor', 1, 1001, 'tb-a', 2001, 3001, 4001],
      ['scope-a', 'divination_case', 'firestore', 'RevisionCursor', 2, 1002, 'tb-b', 2002, 3002, 4002],
      ['scope-b', 'record', 'firestore', 'TimestampCursor', 3, 1003, 'tb-c', 2003, 3003, 4003],
    ];
    for (var i = 0; i < rows.length; i++) {
      final actual = rows[i];
      for (var c = 0; c < expected[i].length; c++) {
        expect(actual[c], expected[i][c],
            reason: '第 $i 行第 $c 列搬运错误: ${actual[c]} != ${expected[i][c]}');
      }
    }

    // 4. 主键必须是 (scope_uid, peer_id, entity_type) 三列
    final pk = _primaryKeyColumns(sqliteDb, 't_sync_state');
    expect(pk, ['scope_uid', 'peer_id', 'entity_type'],
        reason: '主键未切到三元组，实际为 $pk');

    // 5. user_version 为 8（v7 之上又经 ACT 08 升到 v8）
    expect(sqliteDb.userVersion, 8);

    // 6. v8 的两张新表存在（t_entity_stamp + t_hlc_clock_state）
    final v8Tables = sqliteDb
        .select(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name IN ('t_entity_stamp', 't_hlc_clock_state')",
        )
        .toList()
        .map((r) => r[0])
        .toSet();
    expect(v8Tables, containsAll(['t_entity_stamp', 't_hlc_clock_state']),
        reason: 'v8 迁移必须建出 t_entity_stamp 与 t_hlc_clock_state，实际: $v8Tables');
  });

  test('backfilled_peer_id_matches_firestore_gateway_literal', () async {
    // 跨包比对：回填值必须与 firebase 的 PeerId('firestore') 逐字一致。
    final container = _locateContainerDir(
      probe: const ['drift', 'firebase'],
      start: Directory.current,
    );
    expect(container, isNotNull,
        reason: '无法定位容器目录（搜索起点: ${Directory.current.path}）');

    final src = File(
      '${container!.path}/firebase/lib/persistence_firebase.dart',
    ).readAsStringSync();

    final match = RegExp(r"PeerId\('([^']+)'\)").firstMatch(src);
    expect(match, isNotNull,
        reason: 'firebase/lib/persistence_firebase.dart 里找不到 PeerId(\'...\') 字面量');
    final literal = match!.group(1);
    expect(literal, 'firestore',
        reason: '跨包比对失败：firebase 字面量为 "$literal"，迁移回填值必须逐字一致');

    // 迁移文件里的回填常量也必须等于 'firestore'
    final driftSrc = File('lib/persistence_drift.dart').readAsStringSync();
    expect(driftSrc, contains("Constant('firestore')"),
        reason: '迁移文件缺少回填常量 Constant(\'firestore\')');
  });

  test('fresh_database_creates_v7_shape_directly', () async {
    final sqliteDb = sqlite3.openInMemory();
    final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
    addTearDown(db.close);

    // 触发惰性建表（drift 不会在构造时创建 v7 表结构）
    await db.select(db.syncStates).get();

    // t_outbox_peer_ack 存在且主键 (operation_id, peer_id)
    final ackPk = _primaryKeyColumns(sqliteDb, 't_outbox_peer_ack');
    expect(ackPk, ['operation_id', 'peer_id'],
        reason: 't_outbox_peer_ack 主键错误: $ackPk');

    // t_sync_state 主键三元组
    final syncPk = _primaryKeyColumns(sqliteDb, 't_sync_state');
    expect(syncPk, ['scope_uid', 'peer_id', 'entity_type'],
        reason: 't_sync_state 主键错误: $syncPk');

    // 两条索引就位
    final idx = sqliteDb
        .select('PRAGMA index_list("t_outbox_peer_ack")')
        .toList()
        .map((r) => r[1])
        .toSet();
    expect(idx, contains('idx_outbox_peer_ack_peer_status'));
    expect(idx, contains('idx_outbox_peer_ack_operation'));

    expect(sqliteDb.userVersion, 8);

    // v8 表已建（fresh 库直接建到 v8）
    final v8Tables = sqliteDb
        .select(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name IN ('t_entity_stamp', 't_hlc_clock_state')",
        )
        .toList()
        .map((r) => r[0])
        .toSet();
    expect(v8Tables, containsAll(['t_entity_stamp', 't_hlc_clock_state']),
        reason: 'fresh 库必须建出 v8 两张表，实际: $v8Tables');
  });

  test('sync_state_pk_allows_same_entity_for_two_peers', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.syncStates).insert(SyncStateRow(
      scopeUid: 'scope-1',
      peerId: 'firestore',
      entityType: 'record',
      cursorType: 'TimestampCursor',
      revision: 1,
      serverUpdatedAtUtc: null,
      tieBreaker: null,
      cursorUpdatedAtUtc: DateTime.utc(2026, 1, 1),
      lastPulledAtUtc: null,
      lastPushedAtUtc: null,
    ));
    await db.into(db.syncStates).insert(SyncStateRow(
      scopeUid: 'scope-1',
      peerId: 'lan',
      entityType: 'record',
      cursorType: 'TimestampCursor',
      revision: 2,
      serverUpdatedAtUtc: null,
      tieBreaker: null,
      cursorUpdatedAtUtc: DateTime.utc(2026, 1, 2),
      lastPulledAtUtc: null,
      lastPushedAtUtc: null,
    ));

    // 两个 peer 各一行，都在（二元组主键下第二行会覆盖第一行）
    final rows = await db.select(db.syncStates).get();
    expect(rows.length, 2, reason: '同一实体对两个 peer 应该各占一行');

    // 重复插入 (scope-1, firestore, record) 应抛主键冲突
    expect(
      () => db.into(db.syncStates).insert(SyncStateRow(
        scopeUid: 'scope-1',
        peerId: 'firestore',
        entityType: 'record',
        cursorType: 'TimestampCursor',
        revision: 9,
        serverUpdatedAtUtc: null,
        tieBreaker: null,
        cursorUpdatedAtUtc: DateTime.utc(2026, 1, 3),
        lastPulledAtUtc: null,
        lastPushedAtUtc: null,
      )),
      throwsA(isA<SqliteException>()),
    );
  });

  test('peer_ack_primary_key_rejects_duplicate_pair', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.outboxPeerAcks).insert(OutboxPeerAckRow(
      operationId: 'op-1',
      peerId: 'cloud',
      status: 'pending',
      attempt: 0,
      lastErrorCode: null,
      lastErrorMessage: null,
      ackedAtUtc: null,
    ));
    await db.into(db.outboxPeerAcks).insert(OutboxPeerAckRow(
      operationId: 'op-1',
      peerId: 'lan',
      status: 'pending',
      attempt: 0,
      lastErrorCode: null,
      lastErrorMessage: null,
      ackedAtUtc: null,
    ));

    final rows = await db.select(db.outboxPeerAcks).get();
    expect(rows.length, 2, reason: '同一操作对不同对端各一行，这是本表存在的意义');

    expect(
      () => db.into(db.outboxPeerAcks).insert(OutboxPeerAckRow(
        operationId: 'op-1',
        peerId: 'cloud',
        status: 'success',
        attempt: 1,
        lastErrorCode: null,
        lastErrorMessage: null,
        ackedAtUtc: null,
      )),
      throwsA(isA<SqliteException>()),
    );
  });

  test('t_outbox_table_shape_unchanged', () async {
    final sqliteDb = sqlite3.openInMemory();
    final db = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
    addTearDown(db.close);

    // 触发惰性建表，t_outbox 才会以 v7 形状存在
    await db.select(db.outboxRecords).get();

    final columns = sqliteDb
        .select('PRAGMA table_info("t_outbox")')
        .toList()
        .map((r) => r[1])
        .toList();
    expect(columns.contains('peer_id'), isFalse,
        reason: 't_outbox 不得加 peer_id 列');

    final pk = _primaryKeyColumns(sqliteDb, 't_outbox');
    expect(pk, ['operation_id'], reason: 't_outbox 主键必须是 {operation_id}');
  });

  test('old_migration_branches_untouched', () async {
    final src = File('lib/persistence_drift.dart').readAsStringSync();
    for (final n in [2, 3, 4, 5, 6]) {
      expect(src.contains('if (from < $n)'), isTrue,
          reason: '历史迁移分支 if (from < $n) 丢失');
    }
    expect('if (from < 7)'.allMatches(src).length, 1,
        reason: 'if (from < 7) 必须恰好出现 1 次');
  });

  test('whole_drift_package_stays_green', () async {
    // 定义性质：本 ACT 只加表/加列/改主键，端口与 DAO/Store 一字不动，
    // 因此 drift 整包必须编译通过。此条不要求"先红后绿"。
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    await db.close();
    expect(true, isTrue);
  });
}

/// 读取某张表的主键列（按 PRAGMA table_info 的 pk 序号排序）。
List<String> _primaryKeyColumns(Database db, String table) {
  final rows = db.select('PRAGMA table_info("$table")').toList();
  final cols = <(int, String)>[];
  for (final r in rows) {
    final pkOrd = r[5] as int;
    if (pkOrd > 0) cols.add((pkOrd, r[1] as String));
  }
  cols.sort((a, b) => a.$1.compareTo(b.$1));
  return cols.map((c) => c.$2).toList();
}

/// 从 [start] 逐级向上找同时包含 [probe] 全部子目录的那一级（容器目录）。
Directory? _locateContainerDir({
  required List<String> probe,
  required Directory start,
}) {
  var dir = start;
  while (true) {
    final found = probe.every((p) => Directory('${dir.path}/$p').existsSync());
    if (found) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}
