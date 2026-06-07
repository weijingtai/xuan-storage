import 'package:repository_interface_ai/repository_interface_ai.dart';

import '../ai_database.dart';

/// Drift-backed AiConfigRepository (NON-SECRET). API keys are handled by
/// AiSecretStore — this adapter never reads/writes key material.
class DriftAiConfigRepository implements AiConfigRepository {
  DriftAiConfigRepository(this._db);

  final AiDatabase _db;

  AiProviderContract _providerToContract(LlmProvider p) => AiProviderContract(
        uuid: p.uuid,
        name: p.name,
        baseUrl: p.baseUrl,
        isDefault: p.isDefault,
        isEnabled: p.isEnabled,
        configJson: p.configJson,
      );

  AiModelContract _modelToContract(LlmModel m) => AiModelContract(
        uuid: m.uuid,
        providerUuid: m.providerUuid,
        modelId: m.modelId,
        displayName: m.displayName,
        modelType: m.modelType,
        maxContextLength: m.maxContextLength,
        maxOutputTokens: m.maxOutputTokens,
        supportsStreaming: m.supportsStreaming,
        supportsFunctionCalling: m.supportsFunctionCalling,
        isDefault: m.isDefault,
        isEnabled: m.isEnabled,
        configJson: m.configJson,
      );

  AiPersonaContract _personaToContract(AiPersona p) => AiPersonaContract(
        uuid: p.uuid,
        name: p.name,
        avatarUrl: p.avatarUrl,
        description: p.description,
        modelUuid: p.modelUuid,
        systemPromptUuid: p.systemPromptUuid,
        temperature: p.temperature,
        topP: p.topP,
        maxTokens: p.maxTokens,
        personalityJson: p.personalityJson,
        expertiseJson: p.expertiseJson,
        isDefault: p.isDefault,
        isEnabled: p.isEnabled,
      );

  @override
  Future<List<AiProviderContract>> listProviders() async =>
      (await _db.llmProvidersDao.getAllEnabled())
          .map(_providerToContract)
          .toList();

  @override
  Future<AiProviderContract?> getProvider(String uuid) async {
    final p = await _db.llmProvidersDao.getByUuid(uuid);
    return p == null ? null : _providerToContract(p);
  }

  @override
  Future<AiProviderContract?> getDefaultProvider() async {
    final p = await _db.llmProvidersDao.getDefault();
    return p == null ? null : _providerToContract(p);
  }

  @override
  Future<void> upsertProvider(AiProviderContract provider) =>
      _db.llmProvidersDao.upsert(
        LlmProvidersCompanion(
          uuid: Value(provider.uuid),
          name: Value(provider.name),
          baseUrl: Value(provider.baseUrl),
          isDefault: Value(provider.isDefault),
          isEnabled: Value(provider.isEnabled),
          configJson: Value(provider.configJson),
          createdAt: Value(DateTime.now()),
          lastUpdatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> setDefaultProvider(String uuid) =>
      _db.llmProvidersDao.setDefault(uuid);

  @override
  Future<List<AiModelContract>> listModels() async {
    // LlmModelsDao has no list-all; aggregate across enabled providers
    // using the existing getAllByProvider (verified on disk).
    final providers = await _db.llmProvidersDao.getAllEnabled();
    final out = <AiModelContract>[];
    for (final p in providers) {
      final models = await _db.llmModelsDao.getAllByProvider(p.uuid);
      out.addAll(models.map(_modelToContract));
    }
    return out;
  }

  @override
  Future<AiModelContract?> getModel(String uuid) async {
    final m = await _db.llmModelsDao.getByUuid(uuid);
    return m == null ? null : _modelToContract(m);
  }

  @override
  Future<AiModelContract?> getDefaultModel() async {
    final m = await _db.llmModelsDao.getDefault();
    return m == null ? null : _modelToContract(m);
  }

  @override
  Future<void> upsertModel(AiModelContract model) =>
      _db.llmModelsDao.upsert(
        LlmModelsCompanion(
          uuid: Value(model.uuid),
          providerUuid: Value(model.providerUuid),
          modelId: Value(model.modelId),
          displayName: Value(model.displayName),
          modelType: Value(model.modelType),
          maxContextLength: Value(model.maxContextLength),
          maxOutputTokens: Value(model.maxOutputTokens),
          supportsStreaming: Value(model.supportsStreaming),
          supportsFunctionCalling: Value(model.supportsFunctionCalling),
          isDefault: Value(model.isDefault),
          isEnabled: Value(model.isEnabled),
          configJson: Value(model.configJson),
          createdAt: Value(DateTime.now()),
          lastUpdatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> setDefaultModel(String uuid) =>
      _db.llmModelsDao.setDefault(uuid);

  @override
  Future<List<AiPersonaContract>> listPersonas() async =>
      (await _db.aiPersonasDao.getAllEnabled()).map(_personaToContract).toList();

  @override
  Future<AiPersonaContract?> getPersona(String uuid) async {
    final p = await _db.aiPersonasDao.getByUuid(uuid);
    return p == null ? null : _personaToContract(p);
  }

  @override
  Future<AiPersonaContract?> getDefaultPersona() async {
    final p = await _db.aiPersonasDao.getDefault();
    return p == null ? null : _personaToContract(p);
  }

  @override
  Future<void> upsertPersona(AiPersonaContract persona) =>
      _db.aiPersonasDao.insertPersona(
        AiPersonasCompanion(
          uuid: Value(persona.uuid),
          name: Value(persona.name),
          avatarUrl: Value(persona.avatarUrl),
          description: Value(persona.description),
          modelUuid: Value(persona.modelUuid),
          systemPromptUuid: Value(persona.systemPromptUuid),
          temperature: Value(persona.temperature),
          topP: Value(persona.topP),
          maxTokens: Value(persona.maxTokens),
          personalityJson: Value(persona.personalityJson),
          expertiseJson: Value(persona.expertiseJson),
          isDefault: Value(persona.isDefault),
          isEnabled: Value(persona.isEnabled),
          createdAt: Value(DateTime.now()),
          lastUpdatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> setDefaultPersona(String uuid) =>
      _db.aiPersonasDao.setDefault(uuid);
}
