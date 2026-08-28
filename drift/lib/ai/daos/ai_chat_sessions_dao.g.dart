// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_sessions_dao.dart';

// ignore_for_file: type=lint
mixin _$AiChatSessionsDaoMixin on DatabaseAccessor<AiDatabase> {
  $AiChatSessionsTable get aiChatSessions => attachedDatabase.aiChatSessions;
  $AiPersonasTable get aiPersonas => attachedDatabase.aiPersonas;
  AiChatSessionsDaoManager get managers => AiChatSessionsDaoManager(this);
}

class AiChatSessionsDaoManager {
  final _$AiChatSessionsDaoMixin _db;
  AiChatSessionsDaoManager(this._db);
  $$AiChatSessionsTableTableManager get aiChatSessions =>
      $$AiChatSessionsTableTableManager(
        _db.attachedDatabase,
        _db.aiChatSessions,
      );
  $$AiPersonasTableTableManager get aiPersonas =>
      $$AiPersonasTableTableManager(_db.attachedDatabase, _db.aiPersonas);
}
