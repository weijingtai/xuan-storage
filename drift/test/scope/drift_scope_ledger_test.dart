import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/scope/scope_bootstrap_store.dart';
import 'package:persistence_drift/scope/drift_scope_ledger.dart';
import 'package:persistence_drift/scope/scope_ledger.dart';
import 'package:persistence_drift/scope/scope_alias_entry.dart';

class InMemoryScopeBootstrapStore implements ScopeBootstrapStore {
  String? _uid;
  @override
  Future<String> getOrCreate() async {
    return _uid ??= 'device-scope-uuid-123';
  }

  @override
  Future<void> resetForTest() async {
    _uid = null;
  }
}

void main() {
  group('DriftScopeLedger', () {
    late PersistenceDriftDatabase db;
    late InMemoryScopeBootstrapStore bootstrapStore;
    late DriftScopeLedger ledger;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      bootstrapStore = InMemoryScopeBootstrapStore();
      ledger = DriftScopeLedger(db: db, bootstrapStore: bootstrapStore);
    });

    tearDown(() async {
      await db.close();
    });

    test('1. bind -> scopeForIdentity returns correct value', () async {
      await ledger.bind('user-1', ScopeAuthKind.registered, 'scope-abc');
      final scope = await ledger.scopeForIdentity('user-1', ScopeAuthKind.registered);
      expect(scope, 'scope-abc');
    });

    test('2. mintAndBind -> mints and binds new scope', () async {
      final newScope = await ledger.mintAndBind('user-2', ScopeAuthKind.registered);
      expect(newScope, isNotEmpty);
      expect(newScope, isNot('device-scope-uuid-123'));
      
      final scope = await ledger.scopeForIdentity('user-2', ScopeAuthKind.registered);
      expect(scope, newScope);
    });

    test('3. entriesForScope -> returns scope entries', () async {
      await ledger.bind('user-1', ScopeAuthKind.registered, 'scope-abc');
      await ledger.bind('anon-1', ScopeAuthKind.anonymous, 'scope-abc');

      final entries = await ledger.entriesForScope('scope-abc');
      expect(entries.length, 2);
      expect(entries.any((e) => e.authId == 'user-1' && e.authKind == ScopeAuthKind.registered), isTrue);
      expect(entries.any((e) => e.authId == 'anon-1' && e.authKind == ScopeAuthKind.anonymous), isTrue);
    });

    test('4. duplicate bind -> does not throw error and updates', () async {
      await ledger.bind('user-1', ScopeAuthKind.registered, 'scope-abc');
      // Binds the same identity to another scope
      await ledger.bind('user-1', ScopeAuthKind.registered, 'scope-def');

      final scope = await ledger.scopeForIdentity('user-1', ScopeAuthKind.registered);
      expect(scope, 'scope-def');
    });

    test('5. deviceScope -> returns bootstrap value', () async {
      final scope = await ledger.deviceScope();
      expect(scope, 'device-scope-uuid-123');
    });
  });
}
