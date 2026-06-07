/// persistence_drift — ai module subtree barrel.
///
/// Relocated verbatim from xuan-ai/lib/database. Owns the standalone
/// `AiDatabase` (drift, schema v3, 14 tables/DAOs) plus the port adapters.
library;

export 'ai_database.dart';
export 'ai_schema.dart';
export 'adapters/drift_ai_chat_history_repository.dart';
export 'adapters/drift_ai_config_repository.dart';
export 'adapters/drift_ai_prompt_store.dart';
