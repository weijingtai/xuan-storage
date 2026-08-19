import 'package:test/test.dart';
import 'package:repository_interface_account/repository_interface_account_fakes.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:persistence_drift/scope/scope_alias_entry.dart';
import 'package:persistence_drift/scope/scope_bootstrap_store.dart';
import 'package:persistence_drift/scope/scope_handover.dart';
import 'package:persistence_drift/scope/scope_ledger.dart';
import 'package:persistence_drift/scope/scope_resolver.dart';

/// 记录 handover 调用的 fake，供 resolver 单测使用。
class RecordingScopeHandoverService implements ScopeHandoverService {
  final calls = <({String fromScope, String toScope})>[];
  bool fail = false;

  @override
  Future<void> handover({
    required String fromScope,
    required String toScope,
  }) async {
    if (fail) {
      throw StateError('RecordingScopeHandoverService: simulated failure');
    }
    calls.add((fromScope: fromScope, toScope: toScope));
  }
}

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

  @override
  Future<void> clearScope(String scopeUid) async {
    _bindings.removeWhere((e) => e.scopeUid == scopeUid);
  }
}

void main() {
  group('ScopeResolver', () {
    late InMemoryAccountSessionRepository sessionRepo;
    late InMemoryAccountIdentityLinkRepository linkRepo;
    late InMemoryScopeBootstrapStore bootstrapStore;
    late InMemoryScopeLedger ledger;
    late RecordingScopeHandoverService handover;
    late ScopeResolver resolver;

    setUp(() {
      sessionRepo = InMemoryAccountSessionRepository();
      linkRepo = InMemoryAccountIdentityLinkRepository();
      bootstrapStore = InMemoryScopeBootstrapStore();
      ledger = InMemoryScopeLedger(bootstrapStore);
      handover = RecordingScopeHandoverService();
      resolver = ScopeResolver(
        sessionRepository: sessionRepo,
        identityLinkRepository: linkRepo,
        ledger: ledger,
        handoverService: handover,
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

    test('4. upgrade -> mints new scope + handover (not reuse device scope)', () async {
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
      // 升级不再复用 device scope，而是铸新 scope
      expect(res.scopeUid, isNot('device-scope-uuid-123'));
      expect(res.scopeUid, 'minted-scope-uuid-1');
      expect(res.isUpgrade, isTrue);
      expect(res.isConflict, isFalse);

      // handover 从 device scope → 新 scope
      expect(handover.calls, hasLength(1));
      expect(handover.calls.first.fromScope, 'device-scope-uuid-123');
      expect(handover.calls.first.toScope, 'minted-scope-uuid-1');

      // 注册身份已绑定到新 scope，不再占用 device scope
      expect(
        await ledger.scopeForIdentity('user-1', ScopeAuthKind.registered),
        'minted-scope-uuid-1',
      );
      // 匿名身份仍占着 device scope（真实数据搬迁由 handover 完成）
      expect(
        await ledger.scopeForIdentity('anon-1', ScopeAuthKind.anonymous),
        'device-scope-uuid-123',
      );
    });

    test('4b. upgrade when handover fails -> resolve throws, no binding reused', () async {
      await ledger.bind('anon-1', ScopeAuthKind.anonymous, 'device-scope-uuid-123');
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

      handover.fail = true;
      await expectLater(resolver.resolve(), throwsStateError);
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
