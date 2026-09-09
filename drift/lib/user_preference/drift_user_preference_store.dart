import 'package:drift/drift.dart';
import '../persistence_drift.dart';

/// 用户通用偏好存储接口（强 scope 隔离）。
abstract interface class UserPreferenceStore {
  /// 读取偏好（未设置返回 null）。必须带 [scopeUid]。
  Future<String?> getPreference({
    required String scopeUid,
    required String key,
  });

  /// 设置/更新偏好（Upsert）。必须带 [scopeUid]。
  Future<void> setPreference({
    required String scopeUid,
    required String key,
    required String value,
    DateTime? updatedAt,
  });

  /// 删除偏好。必须带 [scopeUid]。
  Future<void> removePreference({
    required String scopeUid,
    required String key,
  });

  /// 列出指定 scope 下所有偏好。必须带 [scopeUid]。
  Future<Map<String, String>> getAllPreferences({
    required String scopeUid,
  });
}

/// 基于 Drift 实现的生产通用偏好存储访问层。
class DriftUserPreferenceStore implements UserPreferenceStore {
  const DriftUserPreferenceStore(this.db);

  final PersistenceDriftDatabase db;

  @override
  Future<String?> getPreference({
    required String scopeUid,
    required String key,
  }) async {
    final row = await (db.select(db.userPreferences)
          ..where((t) => t.scopeUid.equals(scopeUid) & t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setPreference({
    required String scopeUid,
    required String key,
    required String value,
    DateTime? updatedAt,
  }) async {
    await db.into(db.userPreferences).insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            scopeUid: scopeUid,
            key: key,
            value: value,
            updatedAt: updatedAt ?? DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> removePreference({
    required String scopeUid,
    required String key,
  }) async {
    await (db.delete(db.userPreferences)
          ..where((t) => t.scopeUid.equals(scopeUid) & t.key.equals(key)))
        .go();
  }

  @override
  Future<Map<String, String>> getAllPreferences({
    required String scopeUid,
  }) async {
    final rows = await (db.select(db.userPreferences)
          ..where((t) => t.scopeUid.equals(scopeUid)))
        .get();
    return {for (final r in rows) r.key: r.value};
  }
}

/// 用于测试与离线运行的内存实现。
class InMemoryUserPreferenceStore implements UserPreferenceStore {
  InMemoryUserPreferenceStore([Map<String, Map<String, String>>? initialData])
      : _store = initialData != null
            ? {for (final e in initialData.entries) e.key: Map.from(e.value)}
            : {};

  final Map<String, Map<String, String>> _store;

  @override
  Future<String?> getPreference({
    required String scopeUid,
    required String key,
  }) async {
    return _store[scopeUid]?[key];
  }

  @override
  Future<void> setPreference({
    required String scopeUid,
    required String key,
    required String value,
    DateTime? updatedAt,
  }) async {
    _store.putIfAbsent(scopeUid, () => {})[key] = value;
  }

  @override
  Future<void> removePreference({
    required String scopeUid,
    required String key,
  }) async {
    _store[scopeUid]?.remove(key);
  }

  @override
  Future<Map<String, String>> getAllPreferences({
    required String scopeUid,
  }) async {
    final map = _store[scopeUid];
    return map != null ? Map.unmodifiable(map) : const {};
  }
}
