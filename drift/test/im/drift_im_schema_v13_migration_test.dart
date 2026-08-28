import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Drift Schema v12 -> v13 Migration Contract', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('im-v13-migration-test-');
      dbFile = File('${tempDir.path}/test_v12.sqlite');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    void createV12SchemaWithData(Database sqliteDb) {
      sqliteDb.execute('PRAGMA user_version = 12;');
      sqliteDb.execute('''
        CREATE TABLE t_outbox (
          operation_id TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          op_type TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          payload_summary TEXT,
          payload_hash TEXT,
          created_at_utc INTEGER NOT NULL,
          attempt INTEGER NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'pending',
          last_error_code TEXT,
          last_error_message TEXT,
          last_attempt_at_utc INTEGER,
          succeeded_at_utc INTEGER
        );

        CREATE TABLE t_outbox_peer_ack (
          operation_id TEXT NOT NULL,
          peer_id TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          attempt INTEGER NOT NULL DEFAULT 0,
          last_error_code TEXT,
          last_error_message TEXT,
          acked_at_utc INTEGER,
          PRIMARY KEY (operation_id, peer_id)
        );

        CREATE TABLE t_sync_state (
          scope_uid TEXT NOT NULL,
          peer_id TEXT NOT NULL DEFAULT 'firestore',
          entity_type TEXT NOT NULL,
          cursor_type TEXT NOT NULL,
          revision INTEGER,
          server_updated_at_utc INTEGER,
          tie_breaker TEXT,
          cursor_updated_at_utc INTEGER NOT NULL,
          last_pulled_at_utc INTEGER,
          last_pushed_at_utc INTEGER,
          PRIMARY KEY (scope_uid, peer_id, entity_type)
        );

        CREATE TABLE t_entity_stamp (
          scope_uid TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          hlc_packed INTEGER NOT NULL,
          device_id TEXT NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY (scope_uid, entity_type, entity_id)
        );

        CREATE TABLE t_hlc_clock_state (
          id INTEGER NOT NULL PRIMARY KEY DEFAULT 0 CHECK (id = 0),
          hlc_packed INTEGER NOT NULL,
          device_id TEXT NOT NULL,
          saved_at_utc INTEGER NOT NULL
        );

        CREATE TABLE t_record_meta (
          uuid TEXT NOT NULL PRIMARY KEY,
          scope_uid TEXT NOT NULL,
          module TEXT NOT NULL,
          category TEXT NOT NULL,
          divination_type TEXT NOT NULL,
          seeker_uuid TEXT,
          case_uuid TEXT,
          work_item_uuid TEXT,
          created_at INTEGER NOT NULL,
          occurred_at_utc INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');

      // Populate pre-existing data into v12 database
      sqliteDb.execute('''
        INSERT INTO t_outbox (operation_id, scope_uid, entity_type, entity_id, op_type, payload_json, created_at_utc)
        VALUES ('op_pre_1', 'user_1', 'legacy_record', 'e_1', 'CREATE', '{"a":1}', 1724720400000);

        INSERT INTO t_outbox_peer_ack (operation_id, peer_id, status, attempt)
        VALUES ('op_pre_1', 'cloud', 'success', 0);

        INSERT INTO t_sync_state (scope_uid, peer_id, entity_type, cursor_type, cursor_updated_at_utc)
        VALUES ('user_1', 'cloud', 'legacy_record', 'timestamp', 1724720400000);

        INSERT INTO t_entity_stamp (scope_uid, entity_type, entity_id, hlc_packed, device_id, is_deleted)
        VALUES ('user_1', 'legacy_record', 'e_1', 12345678, 'dev_1', 0);

        INSERT INTO t_record_meta (uuid, scope_uid, module, category, divination_type, created_at, occurred_at_utc)
        VALUES ('rec_1', 'user_1', 'bazi', 'cat', 'div', 1724720400000, 1724720400000);
      ''');
    }

    test('ST-IM-001: migrates from v12 to v13, preserves all existing data, creates 8 IM tables and indices', () async {
      // 1. Setup real v12 database fixture
      final sqliteDb = sqlite3.open(dbFile.path);
      createV12SchemaWithData(sqliteDb);
      sqliteDb.dispose();

      // 2. Open via Drift and trigger onUpgrade
      final db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      expect(db.schemaVersion, 13);

      // Verify pre-existing data remained intact
      final outboxRows = await db.customSelect('SELECT * FROM t_outbox WHERE operation_id = ?', variables: [const Variable('op_pre_1')]).get();
      expect(outboxRows.length, 1);
      expect(outboxRows.first.read<String>('scope_uid'), 'user_1');

      final ackRows = await db.customSelect('SELECT * FROM t_outbox_peer_ack WHERE operation_id = ?', variables: [const Variable('op_pre_1')]).get();
      expect(ackRows.length, 1);
      expect(ackRows.first.read<String>('status'), 'success');

      final syncStateRows = await db.customSelect('SELECT * FROM t_sync_state WHERE scope_uid = ?', variables: [const Variable('user_1')]).get();
      expect(syncStateRows.length, 1);

      final stampRows = await db.customSelect('SELECT * FROM t_entity_stamp WHERE entity_id = ?', variables: [const Variable('e_1')]).get();
      expect(stampRows.length, 1);
      expect(stampRows.first.read<int>('hlc_packed'), 12345678);

      final metaRows = await db.customSelect('SELECT * FROM t_record_meta WHERE uuid = ?', variables: [const Variable('rec_1')]).get();
      expect(metaRows.length, 1);

      // 3. Verify all 8 IM tables exist in sqlite_master
      final tableNames = [
        't_im_message',
        't_im_message_tombstone',
        't_im_message_receipt',
        't_im_conversation',
        't_im_envelope_dedup',
        't_incoming_delivery',
        't_im_send_state',
        't_im_peer_authorization',
      ];

      for (final table in tableNames) {
        final res = await db.customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          variables: [Variable(table)],
        ).get();
        expect(res, isNotEmpty, reason: 'Table $table must exist after v13 migration');
      }

      // 4. Verify timeline index exists
      final indexRes = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_im_message_timeline'",
      ).get();
      expect(indexRes, isNotEmpty, reason: 'idx_im_message_timeline index must exist');

      await db.close();
    });
  });
}
