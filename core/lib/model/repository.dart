import 'storage_error.dart';

/// Standard result wrapper for all storage operations.
///
/// Integrates with the XuanError system to provide suggested fixes.
class StorageResult<T> {
  final T? data;
  final XuanError? error;

  const StorageResult.success(this.data) : error = null;
  const StorageResult.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  /// Throws the error if this is a failure, otherwise returns data.
  T get orThrow {
    if (isFailure) throw error!;
    return data as T;
  }
}

/// Generic Repository Interface for all domain modules.
///
/// Callers (UI/Logic) use this to interact with data without knowing
/// if the backend is Drift, Firebase, or a simple Memory cache.
abstract interface class IRepository<T> {
  /// Retrieves a single entity by its unique identifier.
  Future<StorageResult<T>> getById(String id);

  /// Persists an entity. In Sync-enabled environments, this
  /// triggers the Outbox flow automatically.
  Future<StorageResult<void>> save(T entity);

  /// Marks an entity for deletion.
  Future<StorageResult<void>> delete(String id);

  /// Returns a stream that notifies when the underlying data changes.
  /// Automatically handles merges between local and remote updates.
  Stream<StorageResult<List<T>>> watch({
    int? limit,
    int? offset,
    dynamic filter,
  });
}
