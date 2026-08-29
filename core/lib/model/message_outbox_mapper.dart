import 'package:persistence_core/model/im_models.dart';
import 'package:persistence_core/model/types.dart';

/// Generic mapper interface from domain entity to OutboxRecord.
abstract interface class OutboxMapper<T> {
  OutboxRecord map({
    required T entity,
    required String operationId,
    required String opType,
  });
}

/// Specialized mapper for IM messages into stable OutboxRecord format.
final class MessageOutboxMapper implements OutboxMapper<TIMMessage> {
  static const entityType = 'im_message_v1';

  @override
  OutboxRecord map({
    required TIMMessage entity,
    required String operationId,
    required String opType,
  }) {
    return OutboxRecord(
      operationId: operationId,
      scopeUid: entity.scopeUid,
      entityType: entityType,
      entityId: entity.messageId,
      opType: opType,
      payloadJson: entity.toCanonicalJson(),
      createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
        entity.createdAtUtcMs,
        isUtc: true,
      ),
      attempt: 0,
    );
  }
}
