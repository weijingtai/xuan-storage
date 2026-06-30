import 'package:persistence_core/persistence_core.dart';

class RecordSyncConfig {
  static const entityType = 'record_meta';
  static const cursorType = 'timestamp';

  static Future<void> ensureInitialized(SyncStateStore store, String scopeUid) async {
    final existing = await store.getCursor(scopeUid: scopeUid, entityType: entityType);
    if (existing != null) return;

    await store.setCursorIfNewer(
      scopeUid: scopeUid, entityType: entityType,
      cursor: TimestampCursor(
        serverUpdatedAtUtc: DateTime.utc(1970, 1, 1),
        tieBreaker: '',
      ),
      atUtc: DateTime.now().toUtc(),
    );
  }
}
