import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'package:repository_interface_account/repository_interface_account_fakes.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:test/test.dart';

/// 任务剧本 T1~T6 + 事务回滚 + blob 目录顺序 + 备份失败即中止。
///
/// 场景：两位设备主人 A、B 先后使用同一台设备（同一 SQLite 文件）：
/// - A 匿名期写 10 条 → A 注册 → A 应看到全部 20 条，且都在 A 的正式 scope 下
/// - A 注册后匿名槽位被腾空
/// - B 匿名期应复用腾空的槽位（不是第三个 scope）
/// - B 注册后 B 应看到自己的全部 20 条（直接验证被修复的 bug）
/// - 隐私红线：任何时刻 B 都读不到 A 的数据，反之亦然
/// - A 的 20 条在 B 的整个流程中数量/内容不变
void main() {
  group('ScopeHandover 任务剧本 T1~T6', () {
    late PersistenceDriftDatabase db;
    late DriftScopeBootstrapStore bootstrapStore;
    late DriftScopeLedger ledger;
    late InMemoryAccountSessionRepository sessionRepo;
    late InMemoryAccountIdentityLinkRepository linkRepo;
    late ScopeResolver resolver;
    late Directory blobBase;
    late Directory backupDir;
    late File dbFile;
    late String deviceScope;
    late String aOfficialScope;
    late String bOfficialScope;

    DriftScopeHandoverService buildHandover() => DriftScopeHandoverService(
          db: db,
          ledger: ledger,
          blobDirForScope: (scope) => '${blobBase.path}/$scope',
          backupService: DriftSqliteFileBackupService(
            db: db,
            backupDirectory: backupDir,
          ),
        );

    ScopeResolver buildResolver() => ScopeResolver(
          sessionRepository: sessionRepo,
          identityLinkRepository: linkRepo,
          ledger: ledger,
          handoverService: buildHandover(),
        );

    /// 以 [scopeUid] 身份写入 [count] 条记录，uuid 前缀 [prefix]。
    Future<void> writeRecords(String scopeUid, String prefix, int count) async {
      final ds = DriftRecordDataSource(db, scopeUid: scopeUid);
      for (var i = 0; i < count; i++) {
        await ds.saveRecord(RecordMeta(
          uuid: '$prefix-$i',
          scopeUid: scopeUid,
          module: 'meihua',
          category: 'divination',
          divinationType: 'mei_hua',
          createdAt: DateTime.utc(2026, 1, 1 + i),
        ), const []);
      }
    }

    Future<List<RecordMeta>> listUnder(String scopeUid) async {
      return DriftRecordDataSource(db, scopeUid: scopeUid)
          .listRecords(module: 'meihua', limit: 100);
    }

    setUp(() async {
      blobBase = await Directory.systemTemp.createTemp('handover-blob');
      backupDir = await Directory.systemTemp.createTemp('handover-backup');
      dbFile = File('${blobBase.path}/persistence.sqlite');
      db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      bootstrapStore = DriftScopeBootstrapStore(db);
      ledger = DriftScopeLedger(db: db, bootstrapStore: bootstrapStore);
      sessionRepo = InMemoryAccountSessionRepository();
      linkRepo = InMemoryAccountIdentityLinkRepository();
      resolver = buildResolver();
      deviceScope = await ledger.deviceScope();
    });

    tearDown(() async {
      await db.close();
      await blobBase.delete(recursive: true);
      await backupDir.delete(recursive: true);
    });

    Future<void> setSession(String appUserId, String providerId, AccountKind kind) async {
      await sessionRepo.saveCurrentSession(AccountSession(
        appUserId: AccountUserId(appUserId),
        providerUserId: ProviderUserId(providerId),
        kind: kind,
        providerId: kind == AccountKind.anonymous ? 'guest' : 'email',
        issuedAt: DateTime.utc(2026),
      ));
    }

    Future<void> linkAnonToRegistered(String anonId, String regId) async {
      await linkRepo.saveLink(AccountIdentityLink(
        anonymousAppUserId: AccountUserId(anonId),
        registeredAppUserId: AccountUserId(regId),
        providerId: 'email',
        linkedAt: DateTime.utc(2026),
      ));
    }

    test('T1+T2+T3+T4+T5+T6 完整剧本', () async {
      // ========== 阶段 1：A 匿名期写 10 条 ==========
      await setSession('anon-A', 'p-anon-A', AccountKind.anonymous);
      final aAnonResolve = await resolver.resolve();
      expect(aAnonResolve.scopeUid, deviceScope); // 匿名槽位
      await writeRecords(deviceScope, 'A-anon', 10);

      // ========== T5-a：A 注册前，匿名期数据都在匿名槽位 ==========
      expect(await listUnder(deviceScope), hasLength(10));

      // ========== 阶段 2：A 注册（link anon-A → user-A） ==========
      await linkAnonToRegistered('anon-A', 'user-A');
      await setSession('user-A', 'p-user-A', AccountKind.registered);
      final aRegResolve = await resolver.resolve();
      expect(aRegResolve.isUpgrade, isTrue);
      expect(aRegResolve.isConflict, isFalse);
      aOfficialScope = aRegResolve.scopeUid;
      expect(aOfficialScope, isNot(deviceScope)); // 铸了新 scope

      // A 注册后再写 10 条（此时身份已绑定正式 scope）
      await writeRecords(aOfficialScope, 'A-reg', 10);

      // ========== T1：A 注册后看到全部 20 条，都在 A 的正式 scope ==========
      final aRegRecords = await listUnder(aOfficialScope);
      expect(aRegRecords, hasLength(20));
      final aUuids = aRegRecords.map((r) => r.uuid).toSet();
      expect(aUuids, containsAll(['A-anon-0', 'A-anon-9', 'A-reg-0', 'A-reg-9']));
      // 每条记录实际 owner 都是 A 的正式 scope（搬迁 UPDATE 生效）
      expect(
        aRegRecords.map((r) => r.scopeUid).toSet(),
        {aOfficialScope},
      );

      // ========== T2：A 注册后匿名槽位被腾空 ==========
      final deviceEntriesAfterA = await ledger.entriesForScope(deviceScope);
      expect(deviceEntriesAfterA, isEmpty);
      expect(await listUnder(deviceScope), isEmpty); // 数据都搬走了

      // ========== 阶段 3：B 匿名（新主人，同设备） ==========
      await setSession('anon-B', 'p-anon-B', AccountKind.anonymous);
      final bAnonResolve = await resolver.resolve();
      expect(bAnonResolve.scopeUid, deviceScope); // T3：复用腾空槽位，不是第三个 scope
      await writeRecords(deviceScope, 'B-anon', 10);
      expect(await listUnder(deviceScope), hasLength(10));

      // ========== T5-b：B 匿名期读不到 A 的数据 ==========
      expect(await listUnder(aOfficialScope), hasLength(20));

      // ========== 阶段 4：B 注册（link anon-B → user-B） ==========
      await linkAnonToRegistered('anon-B', 'user-B');
      await setSession('user-B', 'p-user-B', AccountKind.registered);
      final bRegResolve = await resolver.resolve();
      expect(bRegResolve.isUpgrade, isTrue);
      bOfficialScope = bRegResolve.scopeUid;
      expect(bOfficialScope, isNot(deviceScope));
      expect(bOfficialScope, isNot(aOfficialScope)); // B 有自己的 scope

      // ========== T4：B 注册后看到自己的全部 20 条（直接验证被修复的 bug） ==========
      await writeRecords(bOfficialScope, 'B-reg', 10);
      final bRecords = await listUnder(bOfficialScope);
      expect(bRecords, hasLength(20));
      final bUuids = bRecords.map((r) => r.uuid).toSet();
      expect(bUuids, containsAll(['B-anon-0', 'B-anon-9', 'B-reg-0', 'B-reg-9']));
      expect(bUuids, isNot(contains('A-anon-0'))); // 没有 A 的数据混进来
      expect(bRecords.map((r) => r.scopeUid).toSet(), {bOfficialScope});

      // ========== T6：A 的 20 条在 B 的整个流程中数量/内容不变 ==========
      final aRecordsFinal = await listUnder(aOfficialScope);
      expect(aRecordsFinal, hasLength(20));
      expect(aRecordsFinal.map((r) => r.uuid).toSet(), aUuids);

      // ========== T5-c：最终隔离 ==========
      expect(await listUnder(bOfficialScope), hasLength(20));
      expect(await listUnder(aOfficialScope), hasLength(20));
      // 双向读不到对方
      final aCanReadB = await DriftRecordDataSource(db, scopeUid: aOfficialScope)
          .getRecord('B-anon-0');
      expect(aCanReadB, isNull);
      final bCanReadA = await DriftRecordDataSource(db, scopeUid: bOfficialScope)
          .getRecord('A-anon-0');
      expect(bCanReadA, isNull);
    });

    test('槽位回收后下一任直接复用同一匿名 scope（不新增 scope）', () async {
      // A 完整流程
      await setSession('anon-A', 'p-anon-A', AccountKind.anonymous);
      final aAnon = await resolver.resolve();
      expect(aAnon.scopeUid, deviceScope);
      await writeRecords(deviceScope, 'A-anon', 3);
      await linkAnonToRegistered('anon-A', 'user-A');
      await setSession('user-A', 'p-user-A', AccountKind.registered);
      final aReg = await resolver.resolve();
      aOfficialScope = aReg.scopeUid;

      // 槽位已腾空
      expect(await ledger.entriesForScope(deviceScope), isEmpty);

      // B 匿名：应拿到 deviceScope（腾空后的槽位），不是新铸的
      await setSession('anon-B', 'p-anon-B', AccountKind.anonymous);
      final bAnon = await resolver.resolve();
      expect(bAnon.scopeUid, deviceScope);
    });
  });

  group('ScopeHandover 可靠性', () {
    late PersistenceDriftDatabase db;
    late DriftScopeBootstrapStore bootstrapStore;
    late DriftScopeLedger ledger;
    late Directory blobBase;
    late Directory backupDir;
    late File dbFile;
    late String deviceScope;

    setUp(() async {
      blobBase = await Directory.systemTemp.createTemp('handover-rel-blob');
      backupDir = await Directory.systemTemp.createTemp('handover-rel-backup');
      dbFile = File('${blobBase.path}/persistence.sqlite');
      db = PersistenceDriftDatabase(NativeDatabase(dbFile));
      bootstrapStore = DriftScopeBootstrapStore(db);
      ledger = DriftScopeLedger(db: db, bootstrapStore: bootstrapStore);
      deviceScope = await ledger.deviceScope();
    });

    tearDown(() async {
      await db.close();
      await blobBase.delete(recursive: true);
      await backupDir.delete(recursive: true);
    });

    DriftScopeHandoverService buildHandover({Future<void> Function(int)? beforeTable}) =>
        DriftScopeHandoverService(
          db: db,
          ledger: ledger,
          blobDirForScope: (scope) => '${blobBase.path}/$scope',
          backupService: DriftSqliteFileBackupService(
            db: db,
            backupDirectory: backupDir,
          ),
          beforeEachTableUpdate: beforeTable,
        );

    Future<void> writeRecords(String scopeUid, String prefix, int count) async {
      final ds = DriftRecordDataSource(db, scopeUid: scopeUid);
      for (var i = 0; i < count; i++) {
        await ds.saveRecord(RecordMeta(
          uuid: '$prefix-$i',
          scopeUid: scopeUid,
          module: 'meihua',
          category: 'divination',
          divinationType: 'mei_hua',
          createdAt: DateTime.utc(2026, 1, 1 + i),
        ), const []);
      }
    }

    Future<int> countInScope(String table, String scopeUid) async {
      final rows = await db.customSelect(
        'SELECT COUNT(*) AS c FROM $table WHERE scope_uid = ?',
        variables: [Variable.withString(scopeUid)],
      ).get();
      return rows.single.read<int>('c');
    }

    test('事务回滚：搬迁中途注入异常，所有表 scope_uid 保持原值', () async {
      // 匿名身份先占用槽位（验证事务回滚后槽位绑定也原样保留）
      await ledger.bind('anon-X', ScopeAuthKind.anonymous, deviceScope);

      // 在四张有 scope 列的表写入数据
      await writeRecords(deviceScope, 'R', 3);
      await db.into(db.blobMetas).insert(BlobMetasCompanion.insert(
            cipherManifestId: 'm-1',
            scopeUid: deviceScope,
            plaintextSha256: 'sha256:abc',
            cipherId: 'cipher-1',
            keyVersion: 1,
            totalBytes: 10,
            chunkCount: 1,
            mimeType: 'image/png',
            tier: 0,
            visibility: 0,
            stagedAtUtc: DateTime.utc(2026),
            lastAccessAtUtc: DateTime.utc(2026),
          ));
      await db.into(db.outboxRecords).insert(OutboxRecordsCompanion.insert(
            operationId: 'op-1',
            scopeUid: deviceScope,
            entityType: 'record',
            entityId: 'r-1',
            opType: 'record.save',
            payloadJson: '{}',
            createdAtUtc: DateTime.utc(2026),
          ));
      // t_sync_state
      await db.into(db.syncStates).insert(SyncStatesCompanion.insert(
            scopeUid: deviceScope,
            entityType: 'record',
            cursorType: 'full',
            cursorUpdatedAtUtc: DateTime.utc(2026),
          ));

      final from = deviceScope;
      final to = 'minted-official-scope';

      // 第 3 张表（t_record_meta）UPDATE 后注入异常 → 事务回滚
      var callCount = 0;
      Future<void> injectFailure(int index) async {
        callCount++;
        if (callCount == 3) {
          throw StateError('模拟搬迁中途失败');
        }
      }

      final handover = buildHandover(beforeTable: injectFailure);
      await expectLater(
        handover.handover(fromScope: from, toScope: to),
        throwsStateError,
      );

      // 断言：所有表 scope_uid 保持原值（from 下数量不变，to 下为 0）
      expect(await countInScope('t_record_meta', from), 3);
      expect(await countInScope('t_record_meta', to), 0);
      expect(await countInScope('t_blob_meta', from), 1);
      expect(await countInScope('t_blob_meta', to), 0);
      expect(await countInScope('t_outbox', from), 1);
      expect(await countInScope('t_outbox', to), 0);
      expect(await countInScope('t_sync_state', from), 1);
      expect(await countInScope('t_sync_state', to), 0);
      // 槽位绑定未被腾空（事务整体回滚）
      expect(await ledger.entriesForScope(from), isNotEmpty);
    });

    test('blob 目录搬迁顺序：复制先于事务，成功后删旧目录', () async {
      // 在 from scope 的 blob 目录放一个文件
      final fromBlob = Directory('${blobBase.path}/$deviceScope');
      await fromBlob.create(recursive: true);
      await File('${fromBlob.path}/payload.bin').writeAsBytes([1, 2, 3]);
      final to = 'minted-official-scope';

      final events = <String>[];
      final handover = DriftScopeHandoverService(
        db: db,
        ledger: ledger,
        blobDirForScope: (scope) {
          events.add('resolve:$scope');
          return '${blobBase.path}/$scope';
        },
        backupService: DriftSqliteFileBackupService(
          db: db,
          backupDirectory: backupDir,
        ),
        beforeEachTableUpdate: (i) async => events.add('table:$i'),
      );

      await handover.handover(fromScope: deviceScope, toScope: to);

      // 顺序：先复制 blob（resolve from/to）→ 事务（table:...）→ 成功后删旧目录
      final copyIdx = events.indexOf('resolve:$deviceScope');
      final tableStartIdx = events.indexWhere((e) => e.startsWith('table:'));
      expect(copyIdx, lessThan(tableStartIdx), reason: 'blob 复制必须先于事务');

      // 旧目录已删除，新目录存在且内容一致
      expect(await fromBlob.exists(), isFalse);
      final toBlob = Directory('${blobBase.path}/$to');
      expect(await toBlob.exists(), isTrue);
      expect(
        await File('${toBlob.path}/payload.bin').readAsBytes(),
        [1, 2, 3],
      );
    });

    test('blob 目录搬迁顺序：事务失败时清理新目录，保留旧目录', () async {
      final fromBlob = Directory('${blobBase.path}/$deviceScope');
      await fromBlob.create(recursive: true);
      await File('${fromBlob.path}/payload.bin').writeAsBytes([1, 2, 3]);
      final to = 'minted-official-scope';

      // 第 1 张表就注入异常
      final handover = buildHandover(
        beforeTable: (_) async => throw StateError('模拟失败'),
      );
      await expectLater(
        handover.handover(fromScope: deviceScope, toScope: to),
        throwsStateError,
      );

      // 旧目录保留（数据没被破坏）
      expect(await fromBlob.exists(), isTrue);
      // 新目录被清理（不残留脏数据）
      expect(await Directory('${blobBase.path}/$to').exists(), isFalse);
    });

    test('备份失败即中止：不执行任何搬迁', () async {
      // 用内存库的备份服务会失败（main 无文件路径）
      final failingBackup = DriftSqliteFileBackupService(
        db: PersistenceDriftDatabase(NativeDatabase.memory()),
        backupDirectory: backupDir,
      );

      // 匿名身份先占用槽位
      await ledger.bind('anon-X', ScopeAuthKind.anonymous, deviceScope);
      await writeRecords(deviceScope, 'R', 2);
      final to = 'minted-official-scope';

      final handover = DriftScopeHandoverService(
        db: db,
        ledger: ledger,
        blobDirForScope: (scope) => '${blobBase.path}/$scope',
        backupService: failingBackup,
      );

      await expectLater(
        handover.handover(fromScope: deviceScope, toScope: to),
        throwsStateError,
      );

      // 数据未搬走，槽位未腾空
      expect(await countInScope('t_record_meta', deviceScope), 2);
      expect(await countInScope('t_record_meta', to), 0);
      expect(await ledger.entriesForScope(deviceScope), hasLength(1));
    });

    test('备份机制：真实复制 SQLite 文件，命名含搬迁标识', () async {
      // 真实文件库 + 真实备份服务 → 应复制出一个备份文件
      final backup = DriftSqliteFileBackupService(db: db, backupDirectory: backupDir);
      final path = await backup.backup(
        fromScope: deviceScope,
        toScope: 'minted-official-scope',
      );

      expect(path, startsWith(backupDir.path));
      expect(path, contains('scope_handover'));
      expect(path, contains(deviceScope));
      expect(path, contains('minted-official-scope'));
      expect(path, endsWith('.sqlite'));
      expect(await File(path).exists(), isTrue);
      expect(await File(path).length(), greaterThan(0));
    });
  });
}