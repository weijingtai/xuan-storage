import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/scope/drift_scope_ledger.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:repository_interface_account/repository_interface_account_fakes.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

void main() {
  group('Scope E2E and DriftScopeBootstrapStore', () {
    late PersistenceDriftDatabase db;
    late DriftScopeBootstrapStore bootstrapStore;
    late DriftScopeLedger ledger;
    late InMemoryAccountSessionRepository sessionRepo;
    late InMemoryAccountIdentityLinkRepository linkRepo;
    late ScopeResolver resolver;

    setUp(() {
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      bootstrapStore = DriftScopeBootstrapStore(db);
      ledger = DriftScopeLedger(db: db, bootstrapStore: bootstrapStore);
      sessionRepo = InMemoryAccountSessionRepository();
      linkRepo = InMemoryAccountIdentityLinkRepository();
      resolver = ScopeResolver(
        sessionRepository: sessionRepo,
        identityLinkRepository: linkRepo,
        ledger: ledger,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('DriftScopeBootstrapStore persists ghost scope and returns same value on restart', () async {
      // First call generates a ghost scope UID
      final scope1 = await bootstrapStore.getOrCreate();
      expect(scope1, isNotEmpty);

      // Re-instantiate store with the same DB to simulate restart
      final newStore = DriftScopeBootstrapStore(db);
      final scope2 = await newStore.getOrCreate();
      expect(scope2, equals(scope1));
    });

    test('E2E Anonymous session -> saves record with correct scope', () async {
      // 1. Setup anonymous session
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('anon-1'),
        providerUserId: const ProviderUserId('p-anon'),
        kind: AccountKind.anonymous,
        providerId: 'guest',
        issuedAt: DateTime.utc(2026),
      ));

      final resolved = await resolver.resolve();
      final ds = DriftRecordDataSource(db, scopeUid: resolved.scopeUid);
      expect(resolved.scopeUid, isNotEmpty);

      // 2. Save record
      await ds.saveRecord(RecordMeta(
        uuid: 'r1',
        scopeUid: resolved.scopeUid,
        module: 'meihua',
        category: 'divination',
        divinationType: 'mei_hua',
        createdAt: DateTime.utc(2026),
      ), const []);

      // 3. Query record
      final records = await ds.listRecords(module: 'meihua', limit: 10);
      expect(records, hasLength(1));
      expect(records.first.uuid, 'r1');
      expect(records.first.scopeUid, resolved.scopeUid);
    });

    test('E2E Anonymous to Registered Upgrade -> Reuses same scope and can see old records', () async {
      // 1. Start with anonymous session
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('anon-1'),
        providerUserId: const ProviderUserId('p-anon'),
        kind: AccountKind.anonymous,
        providerId: 'guest',
        issuedAt: DateTime.utc(2026),
      ));

      final anonResolved = await resolver.resolve();
      final anonScope = anonResolved.scopeUid;

      // Save record under anonymous scope
      final dsAnon = DriftRecordDataSource(db, scopeUid: anonScope);
      await dsAnon.saveRecord(RecordMeta(
        uuid: 'r-anon',
        scopeUid: anonScope,
        module: 'meihua',
        category: 'divination',
        divinationType: 'mei_hua',
        createdAt: DateTime.utc(2026),
      ), const []);

      // 2. Create Identity Link linking anon-1 to registered user user-1
      await linkRepo.saveLink(AccountIdentityLink(
        anonymousAppUserId: const AccountUserId('anon-1'),
        registeredAppUserId: const AccountUserId('user-1'),
        providerId: 'email',
        linkedAt: DateTime.utc(2026),
      ));

      // 3. Switch session to user-1
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('user-1'),
        providerUserId: const ProviderUserId('p-user'),
        kind: AccountKind.registered,
        providerId: 'email',
        issuedAt: DateTime.utc(2026),
      ));

      final regResolved = await resolver.resolve();
      expect(regResolved.isUpgrade, isTrue);
      expect(regResolved.scopeUid, equals(anonScope));

      // 4. Query record under registered scope
      final dsReg = DriftRecordDataSource(db, scopeUid: regResolved.scopeUid);
      final records = await dsReg.listRecords(module: 'meihua', limit: 10);
      expect(records, hasLength(1));
      expect(records.first.uuid, 'r-anon');
    });

    test('E2E No Session -> scope = persistent device ghost scope, restarts same', () async {
      // 1. Session is null
      await sessionRepo.clearCurrentSession();
      final resolved = await resolver.resolve();
      final deviceScope = resolved.scopeUid;
      expect(deviceScope, isNotEmpty);

      // Save a record
      final dsDevice = DriftRecordDataSource(db, scopeUid: deviceScope);
      await dsDevice.saveRecord(RecordMeta(
        uuid: 'r-device',
        scopeUid: deviceScope,
        module: 'meihua',
        category: 'divination',
        divinationType: 'mei_hua',
        createdAt: DateTime.utc(2026),
      ), const []);

      // Restarting the app
      final newStore = DriftScopeBootstrapStore(db);
      final newLedger = DriftScopeLedger(db: db, bootstrapStore: newStore);
      final newResolver = ScopeResolver(
        sessionRepository: sessionRepo,
        identityLinkRepository: linkRepo,
        ledger: newLedger,
      );

      final resolved2 = await newResolver.resolve();
      expect(resolved2.scopeUid, equals(deviceScope));

      final dsDevice2 = DriftRecordDataSource(db, scopeUid: resolved2.scopeUid);
      final records = await dsDevice2.listRecords(module: 'meihua', limit: 10);
      expect(records, hasLength(1));
      expect(records.first.uuid, 'r-device');
    });

    test('E2E Isolation -> Two different users cannot see each other records', () async {
      // 1. User 1
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('user-1'),
        providerUserId: const ProviderUserId('p-1'),
        kind: AccountKind.registered,
        providerId: 'email',
        issuedAt: DateTime.utc(2026),
      ));
      final scope1 = (await resolver.resolve()).scopeUid;
      final ds1 = DriftRecordDataSource(db, scopeUid: scope1);
      await ds1.saveRecord(RecordMeta(
        uuid: 'r-user1',
        scopeUid: scope1,
        module: 'meihua',
        category: 'divination',
        divinationType: 'mei_hua',
        createdAt: DateTime.utc(2026),
      ), const []);

      // Verify User 1 sees their record
      expect(await ds1.listRecords(module: 'meihua', limit: 10), hasLength(1));

      // 2. User 2 (Login on same device/db, will mint new scope due to conflict)
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: const AccountUserId('user-2'),
        providerUserId: const ProviderUserId('p-2'),
        kind: AccountKind.registered,
        providerId: 'email',
        issuedAt: DateTime.utc(2026),
      ));
      final scope2 = (await resolver.resolve()).scopeUid;
      expect(scope2, isNot(equals(scope1)));

      final ds2 = DriftRecordDataSource(db, scopeUid: scope2);
      await ds2.saveRecord(RecordMeta(
        uuid: 'r-user2',
        scopeUid: scope2,
        module: 'meihua',
        category: 'divination',
        divinationType: 'mei_hua',
        createdAt: DateTime.utc(2026),
      ), const []);

      // Verify User 2 sees only User 2's record
      final records2 = await ds2.listRecords(module: 'meihua', limit: 10);
      expect(records2, hasLength(1));
      expect(records2.first.uuid, 'r-user2');

      // Verify User 1 still sees only User 1's record
      final records1 = await ds1.listRecords(module: 'meihua', limit: 10);
      expect(records1, hasLength(1));
      expect(records1.first.uuid, 'r-user1');
    });
  });
}
