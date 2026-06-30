import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import '../../lib/sync/record_sync_config.dart';

void main() {
  late PersistenceDriftDatabase db;
  late SyncStatesDao dao;
  late DriftSyncStateStore store;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = SyncStatesDao(db);
    store = DriftSyncStateStore(dao: dao);
  });

  tearDown(() async => await db.close());

  test('entityType and cursorType are defined', () {
    expect(RecordSyncConfig.entityType, 'record_meta');
    expect(RecordSyncConfig.cursorType, 'timestamp');
  });

  test('getCursor returns null for uninitialized record_meta', () async {
    final cursor = await store.getCursor(
      scopeUid: 's1', entityType: 'record_meta',
    );
    expect(cursor, isNull);
  });

  test('ensureInitialized creates cursor for record_meta', () async {
    await RecordSyncConfig.ensureInitialized(store, 's1');

    final cursor = await store.getCursor(
      scopeUid: 's1', entityType: 'record_meta',
    );
    expect(cursor, isNotNull);
  });

  test('setCursorIfNewer advances the cursor', () async {
    await RecordSyncConfig.ensureInitialized(store, 's1');

    await store.setCursorIfNewer(
      scopeUid: 's1', entityType: 'record_meta',
      cursor: TimestampCursor(
        serverUpdatedAtUtc: DateTime.utc(2026, 6, 29),
        tieBreaker: 'op-advance',
      ),
      atUtc: DateTime.utc(2026, 6, 29, 12),
    );

    final cursor = await store.getCursor(
      scopeUid: 's1', entityType: 'record_meta',
    );
    expect(cursor, isA<TimestampCursor>());
    final ts = cursor as TimestampCursor;
    expect(ts.serverUpdatedAtUtc, DateTime.utc(2026, 6, 29));
  });

  test('cursor is scoped by scopeUid', () async {
    await RecordSyncConfig.ensureInitialized(store, 's1');
    await RecordSyncConfig.ensureInitialized(store, 's2');

    await store.setCursorIfNewer(
      scopeUid: 's1', entityType: 'record_meta',
      cursor: TimestampCursor(
        serverUpdatedAtUtc: DateTime.utc(2026, 6, 29),
        tieBreaker: 'op-s1',
      ),
      atUtc: DateTime.utc(2026, 6, 29, 12),
    );

    final cursorS2 = await store.getCursor(
      scopeUid: 's2', entityType: 'record_meta',
    );
    expect(cursorS2, isNotNull);
    // Should have the minimal/default cursor from ensureInitialized,
    // NOT the advanced cursor from s1.
    final ts2 = cursorS2 as TimestampCursor;
    expect(ts2.serverUpdatedAtUtc, DateTime.utc(1970, 1, 1));
  });
}
