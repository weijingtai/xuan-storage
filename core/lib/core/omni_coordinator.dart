import '../model/omni_entity.dart';
import '../model/omni_op.dart';

/// Port for local persistence operations used by [OmniCoordinator].
///
/// Implementations handle the actual database writes (Drift/SQLite).
/// The coordinator orchestrates the write sequence; the driver
/// executes the physical persistence.
///
/// Write order (enforced by coordinator):
/// 1. saveTags — EAV index update
/// 2. save — entity payload
/// 3. (outbox enqueue happens at coordinator level)
abstract interface class OmniLocalDriver {
  /// Persists an entity to local storage.
  Future<void> save(OmniEntity entity);

  /// Removes an entity from local storage by ID.
  Future<void> delete(String id);

  /// Writes searchable feature tags for the EAV index.
  ///
  /// Parameters:
  /// - [id]: Entity UUID.
  /// - [domain]: Domain namespace (e.g. 'taiyi').
  /// - [tags]: Key-value pairs to index.
  Future<void> saveTags(
    String id,
    String domain,
    Map<String, String> tags,
  );
}

/// Port for enqueuing operations into the outbox.
///
/// This is a minimal interface; the full outbox implementation
/// lives in [OutboxStore] (ports.dart) and handles persistence,
/// retry logic, and dead-letter management.
abstract interface class OmniOutboxPort {
  /// Enqueues an operation for remote sync.
  Future<void> enqueue(OmniOp op);
}

/// Orchestrates hybrid storage writes across local DB, EAV tags, and outbox.
///
/// This is the Level 2 implementation from the Storage v2 architecture.
/// It ensures:
/// 1. Tags are written first (for queryability).
/// 2. Entity payload is written locally.
/// 3. An outbox record is enqueued for remote sync.
///
/// All three steps happen in sequence; if any step fails, the caller
/// receives the error and can retry. In production with Drift, these
/// would be wrapped in a single database transaction.
class OmniCoordinator {
  final OmniLocalDriver _local;
  final OmniOutboxPort _outbox;

  OmniCoordinator({
    required OmniLocalDriver local,
    required OmniOutboxPort outbox,
  })  : _local = local,
        _outbox = outbox;

  /// Saves an entity through the full hybrid storage pipeline.
  ///
  /// Write order:
  /// 1. Feature tags → EAV index (for cross-domain querying)
  /// 2. Entity payload → local DB
  /// 3. Outbox op → sync queue
  Future<void> save(OmniEntity entity) async {
    await _local.saveTags(entity.id, entity.domain, entity.searchableTags);
    await _local.save(entity);
    await _outbox.enqueue(OmniOp(entityId: entity.id, type: 'SAVE'));
  }

  /// Deletes an entity and enqueues a tombstone for remote sync.
  Future<void> delete(String id) async {
    await _local.delete(id);
    await _outbox.enqueue(OmniOp(entityId: id, type: 'DELETE'));
  }
}
