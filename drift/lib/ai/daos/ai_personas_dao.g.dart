// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_personas_dao.dart';

// ignore_for_file: type=lint
mixin _$AiPersonasDaoMixin on DatabaseAccessor<AiDatabase> {
  $AiPersonasTable get aiPersonas => attachedDatabase.aiPersonas;
  $LlmModelsTable get llmModels => attachedDatabase.llmModels;
  $PromptTemplatesTable get promptTemplates => attachedDatabase.promptTemplates;
  AiPersonasDaoManager get managers => AiPersonasDaoManager(this);
}

class AiPersonasDaoManager {
  final _$AiPersonasDaoMixin _db;
  AiPersonasDaoManager(this._db);
  $$AiPersonasTableTableManager get aiPersonas =>
      $$AiPersonasTableTableManager(_db.attachedDatabase, _db.aiPersonas);
  $$LlmModelsTableTableManager get llmModels =>
      $$LlmModelsTableTableManager(_db.attachedDatabase, _db.llmModels);
  $$PromptTemplatesTableTableManager get promptTemplates =>
      $$PromptTemplatesTableTableManager(
        _db.attachedDatabase,
        _db.promptTemplates,
      );
}
