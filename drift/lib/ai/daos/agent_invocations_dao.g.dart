// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_invocations_dao.dart';

// ignore_for_file: type=lint
mixin _$AgentInvocationsDaoMixin on DatabaseAccessor<AiDatabase> {
  $AgentInvocationsTable get agentInvocations =>
      attachedDatabase.agentInvocations;
  $AiPersonasTable get aiPersonas => attachedDatabase.aiPersonas;
  $AiChatSessionsTable get aiChatSessions => attachedDatabase.aiChatSessions;
  AgentInvocationsDaoManager get managers => AgentInvocationsDaoManager(this);
}

class AgentInvocationsDaoManager {
  final _$AgentInvocationsDaoMixin _db;
  AgentInvocationsDaoManager(this._db);
  $$AgentInvocationsTableTableManager get agentInvocations =>
      $$AgentInvocationsTableTableManager(
        _db.attachedDatabase,
        _db.agentInvocations,
      );
  $$AiPersonasTableTableManager get aiPersonas =>
      $$AiPersonasTableTableManager(_db.attachedDatabase, _db.aiPersonas);
  $$AiChatSessionsTableTableManager get aiChatSessions =>
      $$AiChatSessionsTableTableManager(
        _db.attachedDatabase,
        _db.aiChatSessions,
      );
}
