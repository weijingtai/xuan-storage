// Re-export of DriftSyncStateStore for import discoverability.
//
// The canonical implementation lives in persistence_drift.dart
// (alongside the DAOs and table definitions). This barrel file
// exists so consumers can import
// 'package:persistence_drift/sync/drift_sync_state_store.dart'
// without depending on the monolithic file name.
export '../persistence_drift.dart' show DriftSyncStateStore;
