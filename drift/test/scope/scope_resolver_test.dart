import 'package:test/test.dart';
import 'package:repository_interface_account/repository_interface_account_fakes.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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
  Future<String?> scopeForIdentity(
    String authId,
    ScopeAuthKind authKind,
  ) async {
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
  Future<void> bind(
    String authId,
    ScopeAuthKind authKind,
    String scopeUid,
  ) async {
    _bindings.add(
      ScopeAliasEntry(
        authKind: authKind,
        authId: authId,
        scopeUid: scopeUid,
        linkedAt: DateTime.now(),
      ),
    );
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

class _CapturingSessionRepository implements AccountSessionRepository {
  _CapturingSessionRepository(this.delegate);
  final InMemoryAccountSessionRepository delegate;
  final contexts = <RequestContext>[];

  @override
  Future<Result<AccountSession?>> get(String id, RequestContext ctx) async {
    contexts.add(ctx);
    return delegate.get(id, ctx);
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) =>
      delegate.exists(id, ctx);

  @override
  Future<Result<Rev>> put(
    AccountSession entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) => delegate.put(entity, ctx, pre: pre);

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) =>
      delegate.inTransaction(body);

  @override
  Future<Result<void>> purge(String id, RequestContext ctx) =>
      delegate.purge(id, ctx);
}

class _FailingIdentityLinkRepository implements AccountIdentityLinkRepository {
  final contexts = <RequestContext>[];

  @override
  Future<Result<AccountIdentityLink?>> get(
    String id,
    RequestContext ctx,
  ) async {
    contexts.add(ctx);
    return const Err(
      XuanError(code: ErrorCode.internal, message: 'identity link unavailable'),
    );
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) =>
      get(id, ctx).then(
        (r) => switch (r) {
          Ok(:final value) => Ok(value != null),
          Err(:final error) => Err(error),
        },
      );

  @override
  Future<Result<Rev>> put(
    AccountIdentityLink entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) => throw UnimplementedError();

  @override
  Future<Result<Page<AccountIdentityLink>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) => throw UnimplementedError();

  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) =>
      throw UnimplementedError();

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) =>
      throw UnimplementedError();
}

final ctx = RequestContext(scopeUid: 'test');

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

    test(
      '2. session has appUserId, has alias -> returns existing scope',
      () async {
        await ledger.bind(
          'user-1',
          ScopeAuthKind.registered,
          'custom-scope-456',
        );
        await sessionRepo.put(
          AccountSession(
            appUserId: const AccountUserId('user-1'),
            providerUserId: const ProviderUserId('p-1'),
            kind: AccountKind.registered,
            providerId: 'fake',
            issuedAt: DateTime.now(),
          ),
          ctx,
        );

        final res = await resolver.resolve();
        expect(res.scopeUid, 'custom-scope-456');
        expect(res.isUpgrade, isFalse);
        expect(res.isConflict, isFalse);
      },
    );

    test(
      '3. session has appUserId, no alias, device scope free -> binds device scope',
      () async {
        await sessionRepo.put(
          AccountSession(
            appUserId: const AccountUserId('user-1'),
            providerUserId: const ProviderUserId('p-1'),
            kind: AccountKind.registered,
            providerId: 'fake',
            issuedAt: DateTime.now(),
          ),
          ctx,
        );

        final res = await resolver.resolve();
        expect(res.scopeUid, 'device-scope-uuid-123');
        expect(res.isUpgrade, isFalse);
        expect(res.isConflict, isFalse);

        final mapped = await ledger.scopeForIdentity(
          'user-1',
          ScopeAuthKind.registered,
        );
        expect(mapped, 'device-scope-uuid-123');
      },
    );

    test(
      '4. upgrade -> mints new scope + handover (not reuse device scope)',
      () async {
        // device scope bound to anonymous user 'anon-1'
        await ledger.bind(
          'anon-1',
          ScopeAuthKind.anonymous,
          'device-scope-uuid-123',
        );

        // link exists: anon-1 belongs to registered user 'user-1'
        await linkRepo.put(
          AccountIdentityLink(
            anonymousAppUserId: const AccountUserId('anon-1'),
            registeredAppUserId: const AccountUserId('user-1'),
            providerId: 'fake',
            linkedAt: DateTime.now(),
          ),
          RequestContext(scopeUid: 'test'),
        );

        await sessionRepo.put(
          AccountSession(
            appUserId: const AccountUserId('user-1'),
            providerUserId: const ProviderUserId('p-1'),
            kind: AccountKind.registered,
            providerId: 'fake',
            issuedAt: DateTime.now(),
          ),
          ctx,
        );

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
      },
    );

    test(
      '4b. upgrade when handover fails -> resolve throws, no binding reused',
      () async {
        await ledger.bind(
          'anon-1',
          ScopeAuthKind.anonymous,
          'device-scope-uuid-123',
        );
        await linkRepo.put(
          AccountIdentityLink(
            anonymousAppUserId: const AccountUserId('anon-1'),
            registeredAppUserId: const AccountUserId('user-1'),
            providerId: 'fake',
            linkedAt: DateTime.now(),
          ),
          RequestContext(scopeUid: 'test'),
        );
        await sessionRepo.put(
          AccountSession(
            appUserId: const AccountUserId('user-1'),
            providerUserId: const ProviderUserId('p-1'),
            kind: AccountKind.registered,
            providerId: 'fake',
            issuedAt: DateTime.now(),
          ),
          ctx,
        );

        handover.fail = true;
        await expectLater(resolver.resolve(), throwsStateError);

        // 1. handover 失败后，ledger 里不存在 appUserId → 新 scope 的残留绑定
        //    （缺陷 1 未修时这里会留下 user-1 → minted-scope 的绑定）
        expect(
          await ledger.scopeForIdentity('user-1', ScopeAuthKind.registered),
          isNull,
        );

        // 2. device scope 的绑定仍然完好（未被提前腾空）
        expect(
          await ledger.scopeForIdentity('anon-1', ScopeAuthKind.anonymous),
          'device-scope-uuid-123',
        );
        expect(
          await ledger.entriesForScope('device-scope-uuid-123'),
          hasLength(1),
        );

        // 3. 再次 resolve() 不会因残留绑定走错分支。
        //    有残留绑定时会走「有 alias → 直接返回已有 scope」路径，返回一个
        //    isUpgrade=false 的空数据 scope（用户看到空白）。
        //    修复后应仍走升级路径（再次铸新 scope）并再次抛异常。
        await expectLater(resolver.resolve(), throwsStateError);
      },
    );

    test(
      '5. session has appUserId, no alias, device scope busy, no link -> mint new scope (conflict)',
      () async {
        // device scope bound to anonymous user 'anon-1'
        await ledger.bind(
          'anon-1',
          ScopeAuthKind.anonymous,
          'device-scope-uuid-123',
        );

        await sessionRepo.put(
          AccountSession(
            appUserId: const AccountUserId('user-1'),
            providerUserId: const ProviderUserId('p-1'),
            kind: AccountKind.registered,
            providerId: 'fake',
            issuedAt: DateTime.now(),
          ),
          ctx,
        );

        final res = await resolver.resolve();
        expect(res.scopeUid, 'minted-scope-uuid-1');
        expect(res.isUpgrade, isFalse);
        expect(res.isConflict, isTrue);
      },
    );

    test('6. empty appUserId -> throws StateError', () async {
      await sessionRepo.put(
        AccountSession(
          appUserId: const AccountUserId(''),
          providerUserId: const ProviderUserId('p-1'),
          kind: AccountKind.registered,
          providerId: 'fake',
          issuedAt: DateTime.now(),
        ),
        ctx,
      );

      expect(() => resolver.resolve(), throwsStateError);
    });

    test(
      'session lookup uses the real device scope, never local-anonymous',
      () async {
        final capturing = _CapturingSessionRepository(sessionRepo);
        resolver = ScopeResolver(
          sessionRepository: capturing,
          identityLinkRepository: linkRepo,
          ledger: ledger,
          handoverService: handover,
        );

        final result = await resolver.resolve();

        expect(result.scopeUid, 'device-scope-uuid-123');
        expect(capturing.contexts.single.scopeUid, 'device-scope-uuid-123');
        expect(capturing.contexts.single.scopeUid, isNot('local-anonymous'));
      },
    );

    test(
      'identity-link repository Err is propagated during upgrade lookup',
      () async {
        await ledger.bind(
          'anonymous-account',
          ScopeAuthKind.anonymous,
          'device-scope-uuid-123',
        );
        await sessionRepo.put(
          AccountSession(
            appUserId: const AccountUserId('registered-account'),
            providerUserId: const ProviderUserId('provider'),
            kind: AccountKind.registered,
            providerId: 'fake',
            issuedAt: DateTime.now(),
          ),
          ctx,
        );

        final failingLinks = _FailingIdentityLinkRepository();
        resolver = ScopeResolver(
          sessionRepository: sessionRepo,
          identityLinkRepository: failingLinks,
          ledger: ledger,
          handoverService: handover,
        );

        await expectLater(resolver.resolve(), throwsStateError);
        expect(failingLinks.contexts.single.scopeUid, 'device-scope-uuid-123');
      },
    );

    test('two account aliases resolve to their distinct scopes', () async {
      await ledger.bind('account-a', ScopeAuthKind.registered, 'scope-a');
      await ledger.bind('account-b', ScopeAuthKind.registered, 'scope-b');

      await sessionRepo.put(
        AccountSession(
          appUserId: const AccountUserId('account-a'),
          providerUserId: const ProviderUserId('provider-a'),
          kind: AccountKind.registered,
          providerId: 'fake',
          issuedAt: DateTime.now(),
        ),
        ctx,
      );
      expect((await resolver.resolve()).scopeUid, 'scope-a');

      await sessionRepo.put(
        AccountSession(
          appUserId: const AccountUserId('account-b'),
          providerUserId: const ProviderUserId('provider-b'),
          kind: AccountKind.registered,
          providerId: 'fake',
          issuedAt: DateTime.now(),
        ),
        ctx,
      );
      expect((await resolver.resolve()).scopeUid, 'scope-b');
    });
  });
}
