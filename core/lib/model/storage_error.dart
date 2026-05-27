/// Base abstract error type for all Xuan storage operations.
///
/// Every storage error carries a machine-readable [code], a human-readable
/// [message], a [reason] explaining the root cause, and a [suggestion]
/// for how to resolve the issue.
abstract class XuanError {
  /// Machine-readable error code (e.g. 'storage.sync_conflict').
  String get code;

  /// Human-readable error description.
  String get message;

  /// Root cause explanation.
  String get reason;

  /// Suggested fix or next step.
  String get suggestion;
}

/// Generic storage error for unexpected or unclassified failures.
///
/// Use specialized subclasses ([SyncConflictError], [VaultAccessError], etc.)
/// when the failure mode is known.
class StorageError implements XuanError {
  @override
  final String code;

  @override
  final String message;

  @override
  final String reason;

  @override
  final String suggestion;

  const StorageError({
    required this.code,
    required this.message,
    required this.reason,
    required this.suggestion,
  });

  @override
  String toString() => '[$code] $message';
}

/// Error raised when local and remote data versions conflict during sync.
///
/// Carries both [serverVersion] and [localVersion] snapshots so the caller
/// can present a merge UI or auto-resolve.
class SyncConflictError extends StorageError {
  final Map<String, dynamic> serverVersion;
  final Map<String, dynamic> localVersion;

  SyncConflictError({
    required this.serverVersion,
    required this.localVersion,
  }) : super(
          code: 'storage.sync_conflict',
          message: 'Conflict detected during sync',
          reason: 'Remote version is newer than local version',
          suggestion: '请进行手动合并 (Manual Merge Required)',
        );
}

/// Error raised when the shared vault path is inaccessible.
///
/// Typically caused by missing platform permissions (iOS App Groups or
/// Android Shared Storage).
class VaultAccessError extends StorageError {
  final String path;

  VaultAccessError({required this.path})
      : super(
          code: 'storage.vault_access_denied',
          message: 'Cannot access shared vault at $path',
          reason:
              'Missing platform permissions (App Groups or Shared Storage)',
          suggestion: '请检查应用权限设置',
        );
}
