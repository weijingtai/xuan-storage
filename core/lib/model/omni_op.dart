/// A lightweight outbox operation record for the OmniCoordinator.
///
/// Represents a pending write operation (SAVE or DELETE) that needs
/// to be synchronized to the remote backend via the outbox pattern.
///
/// This is distinct from the full [OutboxRecord] used by SyncCoordinator;
/// [OmniOp] is the coordinator-level abstraction before the operation
/// is expanded into a full outbox record.
class OmniOp {
  /// The entity ID affected by this operation.
  final String entityId;

  /// Operation type: 'SAVE' or 'DELETE'.
  final String type;

  const OmniOp({required this.entityId, required this.type});
}
