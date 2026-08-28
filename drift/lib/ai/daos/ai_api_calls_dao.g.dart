// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_api_calls_dao.dart';

// ignore_for_file: type=lint
mixin _$AiApiCallsDaoMixin on DatabaseAccessor<AiDatabase> {
  $AiApiCallsTable get aiApiCalls => attachedDatabase.aiApiCalls;
  $AiChatSessionsTable get aiChatSessions => attachedDatabase.aiChatSessions;
  $LlmModelsTable get llmModels => attachedDatabase.llmModels;
  AiApiCallsDaoManager get managers => AiApiCallsDaoManager(this);
}

class AiApiCallsDaoManager {
  final _$AiApiCallsDaoMixin _db;
  AiApiCallsDaoManager(this._db);
  $$AiApiCallsTableTableManager get aiApiCalls =>
      $$AiApiCallsTableTableManager(_db.attachedDatabase, _db.aiApiCalls);
  $$AiChatSessionsTableTableManager get aiChatSessions =>
      $$AiChatSessionsTableTableManager(
        _db.attachedDatabase,
        _db.aiChatSessions,
      );
  $$LlmModelsTableTableManager get llmModels =>
      $$LlmModelsTableTableManager(_db.attachedDatabase, _db.llmModels);
}
