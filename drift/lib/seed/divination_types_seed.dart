import 'package:drift/drift.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_domain/vocabulary/divination_type_registry.dart';

/// Seeds the 8 built-in divination types into [db].
Future<void> seedDivinationTypes(PersistenceDriftDatabase db) async {
  final now = DateTime.now();
  for (final key in DivinationTypeRegistry.all) {
    await db.into(db.divinationTypes).insertOnConflictUpdate(
      DivinationTypesCompanion(
        uuid: Value(key),
        createdAt: Value(now),
        lastUpdatedAt: Value(now),
        name: Value(DivinationTypeRegistry.labelOf(key)),
        description: Value(DivinationTypeRegistry.labelOf(key)),
        isCustomized: const Value(false),
        isAvailable: const Value(true),
      ),
    );
  }
}
