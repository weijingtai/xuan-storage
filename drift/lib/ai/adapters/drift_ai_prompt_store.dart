import 'package:repository_interface_ai/repository_interface_ai.dart';
import 'package:drift/drift.dart';

import '../ai_database.dart';

/// Drift-backed AiPromptStore over the relocated AiDatabase.
class DriftAiPromptStore implements AiPromptStore {
  DriftAiPromptStore(this._db);

  final AiDatabase _db;

  AiPromptTemplateContract _toContract(PromptTemplate t) =>
      AiPromptTemplateContract(
        uuid: t.uuid,
        name: t.name,
        description: t.description,
        templateType: t.templateType,
        content: t.content,
        variablesJson: t.variablesJson,
        currentVersion: t.currentVersion,
        isBuiltin: t.isBuiltin,
        isEnabled: t.isEnabled,
      );

  @override
  Future<List<AiPromptTemplateContract>> listTemplates() async =>
      (await _db.promptTemplatesDao.getAllEnabled()).map(_toContract).toList();

  @override
  Future<AiPromptTemplateContract?> getTemplate(String uuid) async {
    final t = await _db.promptTemplatesDao.getByUuid(uuid);
    return t == null ? null : _toContract(t);
  }

  @override
  Future<void> insertTemplate(AiPromptTemplateContract template) =>
      _db.promptTemplatesDao.insertTemplate(
        PromptTemplatesCompanion.insert(
          uuid: template.uuid,
          name: template.name,
          templateType: template.templateType,
          content: template.content,
          description: Value(template.description),
          variablesJson: Value(template.variablesJson),
          currentVersion: Value(template.currentVersion),
          isBuiltin: Value(template.isBuiltin),
          isEnabled: Value(template.isEnabled),
          createdAt: DateTime.now(),
        ),
      );

  @override
  Future<void> updateTemplateContent(String uuid, String content) =>
      _db.promptTemplatesDao.updateContent(uuid, content);

  @override
  Future<void> softDeleteTemplate(String uuid) =>
      _db.promptTemplatesDao.softDelete(uuid);
}
