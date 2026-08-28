// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_messages_dao.dart';

// ignore_for_file: type=lint
mixin _$AiChatMessagesDaoMixin on DatabaseAccessor<AiDatabase> {
  $AiChatMessagesTable get aiChatMessages => attachedDatabase.aiChatMessages;
  $AiChatSessionsTable get aiChatSessions => attachedDatabase.aiChatSessions;
  AiChatMessagesDaoManager get managers => AiChatMessagesDaoManager(this);
}

class AiChatMessagesDaoManager {
  final _$AiChatMessagesDaoMixin _db;
  AiChatMessagesDaoManager(this._db);
  $$AiChatMessagesTableTableManager get aiChatMessages =>
      $$AiChatMessagesTableTableManager(
        _db.attachedDatabase,
        _db.aiChatMessages,
      );
  $$AiChatSessionsTableTableManager get aiChatSessions =>
      $$AiChatSessionsTableTableManager(
        _db.attachedDatabase,
        _db.aiChatSessions,
      );
}
