import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../persistence_drift.dart';
import 'scope_alias_entry.dart';
import 'scope_bootstrap_store.dart';
import 'scope_ledger.dart';

/// ScopeLedger 的 Drift 实现。
class DriftScopeLedger implements ScopeLedger {
  DriftScopeLedger({
    required PersistenceDriftDatabase db,
    required ScopeBootstrapStore bootstrapStore,
  }) : _db = db,
       _bootstrapStore = bootstrapStore;

  final PersistenceDriftDatabase _db;
  final ScopeBootstrapStore _bootstrapStore;
  static final _uuid = Uuid();

  @override
  Future<String> deviceScope() => _bootstrapStore.getOrCreate();

  @override
  Future<String?> scopeForIdentity(
    String authId,
    ScopeAuthKind authKind,
  ) async {
    final row = await (_db.select(_db.tScopeAlias)
          ..where((t) =>
              t.authKind.equals(authKind.name) &
              t.authId.equals(authId)))
        .getSingleOrNull();
    return row?.scopeUid;
  }

  @override
  Future<void> bind(
    String authId,
    ScopeAuthKind authKind,
    String scopeUid,
  ) async {
    await _db.into(_db.tScopeAlias).insertOnConflictUpdate(
          TScopeAliasCompanion.insert(
            authKind: authKind.name,
            authId: authId,
            scopeUid: scopeUid,
            linkedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<String> mintAndBind(String authId, ScopeAuthKind authKind) async {
    final newScope = _uuid.v7();
    await bind(authId, authKind, newScope);
    return newScope;
  }

  @override
  Future<List<ScopeAliasEntry>> entriesForScope(String scopeUid) async {
    final rows = await (_db.select(_db.tScopeAlias)
          ..where((t) => t.scopeUid.equals(scopeUid) & t.authKind.equals('device').not()))
        .get();
    return rows
        .map((r) => ScopeAliasEntry(
              authKind: ScopeAuthKind.values.byName(r.authKind),
              authId: r.authId,
              scopeUid: r.scopeUid,
              linkedAt: r.linkedAt,
            ))
        .toList();
  }
}
