import 'package:test/test.dart';
import 'package:repository_interface_account/repository_interface_account_fakes.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:persistence_drift/scope/scope_alias_entry.dart';
import 'package:persistence_drift/scope/scope_bootstrap_store.dart';
import 'package:persistence_drift/scope/scope_ledger.dart';
import 'package:persistence_drift/scope/scope_resolver.dart';

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

class InMemoryScopeLedger implements ScopeLedger {
  final ScopeBootstrapStore _bootstrap;
  InMemoryScopeLedger(this._bootstrap);

  final List<ScopeAliasEntry> _bindings = [];
  int _mintCounter = 0;

  @override
  Future<String?> scopeForIdentity(String authId, ScopeAuthKind authKind) async {
    for (final e in _bindings) {
      if (e.authId == authId && e.authKind == authKind) {
        return e.scopeUid;
      }
    }
    return null;
  }

  @override
  Future<String> deviceScope() => _bootstrap.getOrCreate();

  @override
  Future<List<ScopeAliasEntry>> entriesForScope(String scopeUid) async {
    return _bindings.where((e) => e.scopeUid == scopeUid).toList();
  }

  @override
  Future<void> bind(String authId, ScopeAuthKind authKind, String scopeUid) async {
    _bindings.add(ScopeAliasEntry(
      authKind: authKind,
      authId: authId,
      scopeUid: scopeUid,
      linkedAt: DateTime.now(),
    ));
  }

  @override
  Future<String> mintAndBind(String authId, ScopeAuthKind authKind) async {
    _mintCounter++;
    final newScope = 'minted-scope-uuid-$_mintCounter';
    await bind(authId, authKind, newScope);
    return newScope;
  }
}

void main() {
  group('ScopeResolver', () {
    late InMemoryAccountSessionRepository sessionRepo;
    late InMemoryAccountIdentityLinkRepository linkRepo;
    late InMemoryScopeBootstrapStore bootstrapStore;
    late InMemoryScopeLedger ledger;
    late ScopeResolver resolver;

    setUp(() {
      sessionRepo = InMemoryAccountSessionRepository();
      linkRepo = InMemoryAccountIdentityLinkRepository();
      bootstrapStore = InMemoryScopeBootstrapStore();
      ledger = InMemoryScopeLedger(bootstrapStore);
      resolver = ScopeResolver(
        sessionRepository: sessionRepo,
        identityLinkRepository: linkRepo,
        ledger: ledger,
      );
    });

    test('1. session == null -> returns device scope', () async {
      final res = await resolver.resolve();
      expect(res.scopeUid, 'device-scope-uuid-123');
      expect(res.isUpgrade, isFalse);
      expect(res.isConflict, isFalse);
    });

    test('2. session has appUserId, has alias -> returns existing scope', () async {
      await ledger.bind('user-1', ScopeAuthKind.registered, 'custom-scope-456');
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('user-1'),
        providerUserId: const ProviderUserId('p-1'),
        kind: AccountKind.registered,
        providerId: 'fake',
        issuedAt: DateTime.now(),
      ));

      final res = await resolver.resolve();
      expect(res.scopeUid, 'custom-scope-456');
      expect(res.isUpgrade, isFalse);
      expect(res.isConflict, isFalse);
    });

    test('3. session has appUserId, no alias, device scope free -> binds device scope', () async {
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('user-1'),
        providerUserId: const ProviderUserId('p-1'),
        kind: AccountKind.registered,
        providerId: 'fake',
        issuedAt: DateTime.now(),
      ));

      final res = await resolver.resolve();
      expect(res.scopeUid, 'device-scope-uuid-123');
      expect(res.isUpgrade, isFalse);
      expect(res.isConflict, isFalse);

      final mapped = await ledger.scopeForIdentity('user-1', ScopeAuthKind.registered);
      expect(mapped, 'device-scope-uuid-123');
    });

    test('4. session has appUserId, no alias, device scope busy, has link -> upgrade reuse', () async {
      // device scope bound to anonymous user 'anon-1'
      await ledger.bind('anon-1', ScopeAuthKind.anonymous, 'device-scope-uuid-123');
      
      // link exists: anon-1 belongs to registered user 'user-1'
      await linkRepo.saveLink(AccountIdentityLink(
        anonymousAppUserId: const AccountUserId('anon-1'),
        registeredAppUserId: const AccountUserId('user-1'),
        providerId: 'fake',
        linkedAt: DateTime.now(),
      ));

      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('user-1'),
        providerUserId: const ProviderUserId('p-1'),
        kind: AccountKind.registered,
        providerId: 'fake',
        issuedAt: DateTime.now(),
      ));

      final res = await resolver.resolve();
      expect(res.scopeUid, 'device-scope-uuid-123');
      expect(res.isUpgrade, isTrue);
      expect(res.isConflict, isFalse);
    });

    test('5. session has appUserId, no alias, device scope busy, no link -> mint new scope (conflict)', () async {
      // device scope bound to anonymous user 'anon-1'
      await ledger.bind('anon-1', ScopeAuthKind.anonymous, 'device-scope-uuid-123');

      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('user-1'),
        providerUserId: const ProviderUserId('p-1'),
        kind: AccountKind.registered,
        providerId: 'fake',
        issuedAt: DateTime.now(),
      ));

      final res = await resolver.resolve();
      expect(res.scopeUid, 'minted-scope-uuid-1');
      expect(res.isUpgrade, isFalse);
      expect(res.isConflict, isTrue);
    });

    test('6. empty appUserId -> throws StateError', () async {
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId(''),
        providerUserId: const ProviderUserId('p-1'),
        kind: AccountKind.registered,
        providerId: 'fake',
        issuedAt: DateTime.now(),
      ));

      expect(() => resolver.resolve(), throwsStateError);
    });
  });
}
