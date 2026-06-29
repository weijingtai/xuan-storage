import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../persistence_drift.dart';

/// Ghost scope_uid 的持久化端口。
///
/// 首次调用 [getOrCreate] 时铸造 UUIDv7 并持久化，
/// 后续调用返回已持久化的值——保证终生不变。
abstract interface class ScopeBootstrapStore {
  /// 返回本设备的稳定 scope_uid，绝不返回空字符串。
  Future<String> getOrCreate();

  /// 仅用于测试/重置场景。生产代码不应调用。
  Future<void> resetForTest();
}

/// InMemory 实现，供测试使用。
class InMemoryScopeBootstrapStore implements ScopeBootstrapStore {
  String? _cached;
  int _generatedCount = 0;

  @override
  Future<String> getOrCreate() async {
    if (_cached != null && _cached!.isNotEmpty) return _cached!;
    _generatedCount++;
    _cached = 'test-scope-$_generatedCount';
    return _cached!;
  }

  @override
  Future<void> resetForTest() async {
    _cached = null;
  }

  int get generatedCount => _generatedCount;
}

/// Drift/SQLite 实现，持久化到主库的 t_scope_alias 表中。
class DriftScopeBootstrapStore implements ScopeBootstrapStore {
  DriftScopeBootstrapStore(this._db);

  final PersistenceDriftDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<String> getOrCreate() async {
    final row = await (_db.select(_db.tScopeAlias)
          ..where((t) => t.authKind.equals('device') & t.authId.equals('ghost_scope')))
        .getSingleOrNull();
    if (row != null && row.scopeUid.isNotEmpty) {
      return row.scopeUid;
    }

    final newScope = _uuid.v7();
    await _db.into(_db.tScopeAlias).insertOnConflictUpdate(
          TScopeAliasCompanion.insert(
            authKind: 'device',
            authId: 'ghost_scope',
            scopeUid: newScope,
            linkedAt: DateTime.now(),
          ),
        );
    return newScope;
  }

  @override
  Future<void> resetForTest() async {
    await (_db.delete(_db.tScopeAlias)
          ..where((t) => t.authKind.equals('device') & t.authId.equals('ghost_scope')))
        .go();
  }
}

