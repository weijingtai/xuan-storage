import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/logging/sync_logger.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/sync/drift_sync_state_store.dart';

void main() {
  late PersistenceDriftDatabase db;
  late SyncStateStore store;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    store = DriftSyncStateStore(dao: db.syncStatesDao);
  });

  tearDown(() async => await db.close());

  group('DriftSyncStateStore', () {
    test('getCursor returns null initially', () async {
      final cursor = await store.getCursor(
        scopeUid: 'user-x',
        entityType: 'seeker',
      );
      expect(cursor, isNull);
    });

    test('setCursorIfNewer + getCursor roundtrip with TimestampCursor',
        () async {
      final cursor = TimestampCursor(
        serverUpdatedAtUtc: DateTime.utc(2026, 1, 1),
        tieBreaker: 'op-1',
      );
      await store.setCursorIfNewer(
        scopeUid: 'user-x',
        entityType: 'seeker',
        cursor: cursor,
        atUtc: DateTime.utc(2026, 1, 1),
      );
      final got = await store.getCursor(
        scopeUid: 'user-x',
        entityType: 'seeker',
      );
      expect(got, isA<TimestampCursor>());
      final ts = got as TimestampCursor;
      expect(ts.serverUpdatedAtUtc, equals(DateTime.utc(2026, 1, 1)));
      expect(ts.tieBreaker, equals('op-1'));
    });

    test('setCursorIfNewer + getCursor roundtrip with RevisionCursor',
        () async {
      final cursor = RevisionCursor(revision: 42);
      await store.setCursorIfNewer(
        scopeUid: 'user-x',
        entityType: 'divination',
        cursor: cursor,
        atUtc: DateTime.utc(2026, 1, 1),
      );
      final got = await store.getCursor(
        scopeUid: 'user-x',
        entityType: 'divination',
      );
      expect(got, isA<RevisionCursor>());
      final rev = got as RevisionCursor;
      expect(rev.revision, equals(42));
    });

    test('setCursorIfNewer rejects older cursor', () async {
      await store.setCursorIfNewer(
        scopeUid: 'user-x',
        entityType: 'seeker',
        cursor: TimestampCursor(
          serverUpdatedAtUtc: DateTime.utc(2026, 6, 1),
          tieBreaker: 'newer',
        ),
        atUtc: DateTime.utc(2026, 6, 1),
      );

      // Attempt to set an older cursor — should be rejected
      await store.setCursorIfNewer(
        scopeUid: 'user-x',
        entityType: 'seeker',
        cursor: TimestampCursor(
          serverUpdatedAtUtc: DateTime.utc(2026, 1, 1),
          tieBreaker: 'older',
        ),
        atUtc: DateTime.utc(2026, 6, 2),
      );

      final got = await store.getCursor(
        scopeUid: 'user-x',
        entityType: 'seeker',
      );
      final ts = got as TimestampCursor;
      expect(ts.serverUpdatedAtUtc, equals(DateTime.utc(2026, 6, 1)));
      expect(ts.tieBreaker, equals('newer'));
    });

    test('clear removes cursor', () async {
      await store.setCursorIfNewer(
        scopeUid: 'user-x',
        entityType: 'seeker',
        cursor: TimestampCursor(
          serverUpdatedAtUtc: DateTime.utc(2026, 1, 1),
          tieBreaker: 'op-1',
        ),
        atUtc: DateTime.utc(2026, 1, 1),
      );
      await store.clear(scopeUid: 'user-x', entityType: 'seeker');
      expect(
        await store.getCursor(scopeUid: 'user-x', entityType: 'seeker'),
        isNull,
      );
    });

    test('markPulledAt updates timestamp', () async {
      // Must create a row first so markPulledAt has something to update
      await store.setCursorIfNewer(
        scopeUid: 'user-x',
        entityType: 'seeker',
        cursor: RevisionCursor(revision: 1),
        atUtc: DateTime.utc(2026, 1, 1),
      );

      // markPulledAt should not throw
      await store.markPulledAt(
        scopeUid: 'user-x',
        entityType: 'seeker',
        atUtc: DateTime.utc(2026, 6, 15),
      );
    });

    test('markPushedAt updates timestamp', () async {
      // Must create a row first so markPushedAt has something to update
      await store.setCursorIfNewer(
        scopeUid: 'user-x',
        entityType: 'seeker',
        cursor: RevisionCursor(revision: 1),
        atUtc: DateTime.utc(2026, 1, 1),
      );

      // markPushedAt should not throw
      await store.markPushedAt(
        scopeUid: 'user-x',
        atUtc: DateTime.utc(2026, 6, 15),
      );
    });

    test('cursors are isolated by (scopeUid, entityType)', () async {
      await store.setCursorIfNewer(
        scopeUid: 'user-a',
        entityType: 'seeker',
        cursor: RevisionCursor(revision: 10),
        atUtc: DateTime.utc(2026, 1, 1),
      );
      await store.setCursorIfNewer(
        scopeUid: 'user-b',
        entityType: 'divination',
        cursor: TimestampCursor(
          serverUpdatedAtUtc: DateTime.utc(2026, 3, 1),
          tieBreaker: 'tb',
        ),
        atUtc: DateTime.utc(2026, 3, 1),
      );

      // user-a/seeker should have revision cursor
      final curA = await store.getCursor(
        scopeUid: 'user-a',
        entityType: 'seeker',
      );
      expect(curA, isA<RevisionCursor>());

      // user-b/divination should have timestamp cursor
      final curB = await store.getCursor(
        scopeUid: 'user-b',
        entityType: 'divination',
      );
      expect(curB, isA<TimestampCursor>());

      // user-a/divination should be null
      final curC = await store.getCursor(
        scopeUid: 'user-a',
        entityType: 'divination',
      );
      expect(curC, isNull);
    });

    test('clear does not affect other scopes', () async {
      await store.setCursorIfNewer(
        scopeUid: 'user-a',
        entityType: 'seeker',
        cursor: RevisionCursor(revision: 1),
        atUtc: DateTime.utc(2026, 1, 1),
      );
      await store.setCursorIfNewer(
        scopeUid: 'user-b',
        entityType: 'seeker',
        cursor: RevisionCursor(revision: 2),
        atUtc: DateTime.utc(2026, 1, 1),
      );

      await store.clear(scopeUid: 'user-a', entityType: 'seeker');

      expect(
        await store.getCursor(scopeUid: 'user-a', entityType: 'seeker'),
        isNull,
      );
      expect(
        await store.getCursor(scopeUid: 'user-b', entityType: 'seeker'),
        isNotNull,
      );
    });
  });
}
