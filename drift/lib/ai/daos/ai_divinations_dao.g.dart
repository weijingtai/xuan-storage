// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_divinations_dao.dart';

// ignore_for_file: type=lint
mixin _$AiDivinationsDaoMixin on DatabaseAccessor<AiDatabase> {
  $AiDivinationsTable get aiDivinations => attachedDatabase.aiDivinations;
  $AiPersonasTable get aiPersonas => attachedDatabase.aiPersonas;
  $AiChatSessionsTable get aiChatSessions => attachedDatabase.aiChatSessions;
  AiDivinationsDaoManager get managers => AiDivinationsDaoManager(this);
}

class AiDivinationsDaoManager {
  final _$AiDivinationsDaoMixin _db;
  AiDivinationsDaoManager(this._db);
  $$AiDivinationsTableTableManager get aiDivinations =>
      $$AiDivinationsTableTableManager(_db.attachedDatabase, _db.aiDivinations);
  $$AiPersonasTableTableManager get aiPersonas =>
      $$AiPersonasTableTableManager(_db.attachedDatabase, _db.aiPersonas);
  $$AiChatSessionsTableTableManager get aiChatSessions =>
      $$AiChatSessionsTableTableManager(
        _db.attachedDatabase,
        _db.aiChatSessions,
      );
}
