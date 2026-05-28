import 'dart:async';

/// A shared query executor that wraps Drift/SQLite configuration.
///
/// In production, this would hold a Drift [QueryExecutor] with
/// WAL mode and busy timeout pre-configured.
///
/// When multiple apps share the same vault (via App Groups / Shared Storage),
/// a single [SharedQueryExecutor] instance per database path ensures
/// no connection conflicts.
class SharedQueryExecutor {
  /// The SQLite journal mode (always 'WAL' for shared vault).
  final String journalMode;

  /// Busy timeout in milliseconds for SQLITE_BUSY handling.
  final int busyTimeout;

  SharedQueryExecutor({
    this.journalMode = 'WAL',
    this.busyTimeout = 5000,
  });
}

/// Abstract interface for building shared query executors.
///
/// Implementations must:
/// - Apply WAL journal mode for concurrent multi-app access.
/// - Set busy timeout to handle SQLITE_BUSY gracefully.
/// - Cache and reuse executors for the same database path within
///   a single process to avoid redundant connections.
abstract interface class IConnectionFactory {
  /// PRAGMA statements that any implementation MUST apply to the connection
  /// before returning it. Required for cross-process safety (mode 3 in v2 design).
  static const List<String> requiredPragmas = [
    'journal_mode = WAL',
    'busy_timeout = 5000',
    'foreign_keys = ON',
  ];

  /// Builds or retrieves a cached [SharedQueryExecutor].
  ///
  /// Parameters:
  /// - [dbName]: Database file name (e.g. 'xuan.db').
  /// - [path]: Directory path to the database file.
  ///
  /// Returns a [SharedQueryExecutor] with WAL mode and busy timeout applied.
  Future<SharedQueryExecutor> buildSharedExecutor({
    required String dbName,
    required String path,
  });
}

/// Default in-process implementation of [IConnectionFactory].
///
/// Maintains a per-process connection pool keyed by full database path.
/// Returns the cached executor when the same path is requested again.
class ConnectionFactory implements IConnectionFactory {
  final Map<String, SharedQueryExecutor> _pool = {};

  @override
  Future<SharedQueryExecutor> buildSharedExecutor({
    required String dbName,
    required String path,
  }) async {
    final fullPath = '$path$dbName';
    return _pool.putIfAbsent(fullPath, () => SharedQueryExecutor());
  }
}
