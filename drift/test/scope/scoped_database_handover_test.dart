import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/taiyishenshu/taiyi_database.dart';
import 'package:persistence_drift/ai/ai_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('ScopedDatabaseHandover 分文件库搬迁与 TaiYi 回归测试', () {
    late Directory baseDir;
    late Directory backupDir;
    late Directory blobBase;
    late PersistenceDriftDatabase persistenceDb;
    late DriftScopeBootstrapStore bootstrapStore;
    late DriftScopeLedger ledger;

    Future<Directory> dbDir() async => baseDir;

    setUp(() async {
      baseDir = await Directory.systemTemp.createTemp('scoped-db-handover-test');
      backupDir = await Directory.systemTemp.createTemp('scoped-db-backup-test');
      blobBase = await Directory.systemTemp.createTemp('scoped-db-blob-test');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async {
          if (call.method == 'getTemporaryDirectory') return baseDir.path;
          if (call.method == 'getApplicationSupportDirectory') return baseDir.path;
          if (call.method == 'getApplicationDocumentsDirectory') return baseDir.path;
          return null;
        },
      );

      final persistenceFile = File('${baseDir.path}/persistence.sqlite');
      persistenceDb = PersistenceDriftDatabase(NativeDatabase(persistenceFile));
      bootstrapStore = DriftScopeBootstrapStore(persistenceDb);
      ledger = DriftScopeLedger(db: persistenceDb, bootstrapStore: bootstrapStore);
    });

    tearDown(() async {
      TaiYiDatabase.resetScopeCache();
      AiDatabase.resetScopeCache();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      await persistenceDb.close();
      if (await baseDir.exists()) await baseDir.delete(recursive: true);
      if (await backupDir.exists()) await backupDir.delete(recursive: true);
      if (await blobBase.exists()) await blobBase.delete(recursive: true);
    });

    DriftScopeHandoverService buildHandover({
      Future<void> Function(int)? beforeTable,
      List<ScopedDatabaseDescriptor>? scopedDbs,
    }) {
      return DriftScopeHandoverService(
        db: persistenceDb,
        ledger: ledger,
        blobDirForScope: (scope) => '${blobBase.path}/$scope',
        backupService: DriftSqliteFileBackupService(
          db: persistenceDb,
          backupDirectory: backupDir,
        ),
        scopedDatabases: scopedDbs ?? [
          ScopedDatabaseDescriptor(
            name: 'taiyi_database',
            databaseDirectory: dbDir,
            onBeforeHandover: (fromScope) => TaiYiDatabase.closeScope(fromScope),
          ),
          ScopedDatabaseDescriptor(
            name: 'ai_database',
            databaseDirectory: dbDir,
            onBeforeHandover: (fromScope) => AiDatabase.closeScope(fromScope),
          ),
        ],
        backupDirectory: backupDir,
        beforeEachTableUpdate: beforeTable,
      );
    }

    Future<void> insertTaiYiSchool(TaiYiDatabase db, String id, String name) async {
      await db.into(db.userSchools).insert(
            UserSchoolsCompanion.insert(
              id: id,
              name: name,
              contentJson: '{"name": "$name"}',
            ),
          );
    }

    test('1. 回归复现：scope A 下写 TaiYi 数据 → handover(A→B) → 断言 B 能读到这些数据', () async {
      // 1. scope A 下写入 TaiYi 数据
      final dbA = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      await insertTaiYiSchool(dbA, 'school-1', '太乙流派A');
      final rowsBefore = await dbA.select(dbA.userSchools).get();
      expect(rowsBefore, hasLength(1));
      expect(rowsBefore.single.name, '太乙流派A');

      // 2. 执行 handover（接好分文件搬迁）
      final handover = buildHandover();
      await handover.handover(fromScope: 'scope-A', toScope: 'scope-B');

      // 3. 断言 B 能读到 scope A 写入的数据
      final dbB = await TaiYiDatabase.forScope('scope-B', databaseDirectory: dbDir);
      final rowsB = await dbB.select(dbB.userSchools).get();
      expect(rowsB, hasLength(1), reason: 'handover 后 scope B 必须能读到原 scope A 的数据');
      expect(rowsB.single.name, '太乙流派A');
    });

    test('2. 搬迁后文件状态：taiyi_database_A.sqlite 不再存在，taiyi_database_B.sqlite 存在且内容完整', () async {
      final dbA = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      await insertTaiYiSchool(dbA, 'school-1', '太乙流派A');
      await insertTaiYiSchool(dbA, 'school-2', '太乙流派A-2');

      final fileA = File('${baseDir.path}/taiyi_database_scope-A.sqlite');
      final fileB = File('${baseDir.path}/taiyi_database_scope-B.sqlite');
      expect(await fileA.exists(), isTrue);
      expect(await fileB.exists(), isFalse);

      final handover = buildHandover();
      await handover.handover(fromScope: 'scope-A', toScope: 'scope-B');

      // 搬迁后：旧文件不存在，新文件存在
      expect(await fileA.exists(), isFalse, reason: '旧 scope 文件必须被清理');
      expect(await fileB.exists(), isTrue, reason: '新 scope 文件必须存在');

      // 新文件可正常读取且数据完整
      final dbB = await TaiYiDatabase.forScope('scope-B', databaseDirectory: dbDir);
      final rows = await dbB.select(dbB.userSchools).get();
      expect(rows, hasLength(2));
      expect(rows.map((r) => r.name), containsAll(['太乙流派A', '太乙流派A-2']));
    });

    test('3. -wal / -shm 伴随文件被正确处理，搬迁后数据库能正常打开读写', () async {
      final dbA = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      await insertTaiYiSchool(dbA, 'school-wal', 'WAL模式测试');

      // 模拟 SQLite 产生 -wal / -shm 伴随文件
      final walFile = File('${baseDir.path}/taiyi_database_scope-A.sqlite-wal');
      final shmFile = File('${baseDir.path}/taiyi_database_scope-A.sqlite-shm');
      await walFile.writeAsBytes([0x57, 0x41, 0x4c, 0x01]); // 写入 mock wal 字节
      await shmFile.writeAsBytes([0x01, 0x02, 0x03, 0x04]);

      expect(await walFile.exists(), isTrue);
      expect(await shmFile.exists(), isTrue);

      final handover = buildHandover();
      await handover.handover(fromScope: 'scope-A', toScope: 'scope-B');

      // 旧伴随文件被删除
      expect(await walFile.exists(), isFalse);
      expect(await shmFile.exists(), isFalse);

      // 新 scope 数据库能正常打开并继续读写
      final dbB = await TaiYiDatabase.forScope('scope-B', databaseDirectory: dbDir);
      final rows = await dbB.select(dbB.userSchools).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'WAL模式测试');

      await insertTaiYiSchool(dbB, 'school-b-new', '新写入测试');
      final rowsAfter = await dbB.select(dbB.userSchools).get();
      expect(rowsAfter, hasLength(2));
    });

    test('4. 目标文件已存在 → 抛异常中止，且【原文件未被破坏】', () async {
      final dbA = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      await insertTaiYiSchool(dbA, 'school-A', 'A数据');

      // 提前造一个已经存在的目标 scope 文件
      final fileB = File('${baseDir.path}/taiyi_database_scope-B.sqlite');
      await fileB.writeAsString('EXISTING_DESTINATION_FILE_CONTENT');

      final fileA = File('${baseDir.path}/taiyi_database_scope-A.sqlite');
      final fileAContentBefore = await fileA.readAsBytes();

      final handover = buildHandover();

      // 必须抛异常中止
      await expectLater(
        handover.handover(fromScope: 'scope-A', toScope: 'scope-B'),
        throwsStateError,
      );

      // 断言：原文件未被破坏，目标文件未被覆盖
      expect(await fileA.exists(), isTrue);
      expect(await fileA.readAsBytes(), fileAContentBefore);
      expect(await fileB.readAsString(), 'EXISTING_DESTINATION_FILE_CONTENT');
    });

    test('5. 事务失败 → 文件状态回到搬迁前，数据不丢', () async {
      final dbA = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      await insertTaiYiSchool(dbA, 'school-fail-test', '未完成事务数据');

      final fileA = File('${baseDir.path}/taiyi_database_scope-A.sqlite');
      final fileB = File('${baseDir.path}/taiyi_database_scope-B.sqlite');
      expect(await fileA.exists(), isTrue);

      // 模拟主库事务中途失败
      final handover = buildHandover(
        beforeTable: (idx) async {
          if (idx == 2) {
            throw StateError('模拟主库事务失败');
          }
        },
      );

      await expectLater(
        handover.handover(fromScope: 'scope-A', toScope: 'scope-B'),
        throwsStateError,
      );

      // 断言：新文件已清理，原文件依然存在且内容完好
      expect(await fileB.exists(), isFalse, reason: '失败路径下新文件必须被清理');
      expect(await fileA.exists(), isTrue, reason: '原文件必须保留');

      // 重新打开 scope A 验证数据未丢
      final dbAReopened = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      final rows = await dbAReopened.select(dbAReopened.userSchools).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, '未完成事务数据');
    });

    test('6. 搬迁后旧的 scope 连接缓存已失效（不会读到已改名的旧句柄）', () async {
      final dbA = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      await insertTaiYiSchool(dbA, 'school-handle', '句柄测试');

      final handover = buildHandover();
      await handover.handover(fromScope: 'scope-A', toScope: 'scope-B');

      // 此时旧文件已被改名/删除，且 _scopeFutures 已经清除 scope-A
      // 若再次打开 scope-A，会重新创建全新的 scope-A（或空库），绝不会读到旧句柄
      final dbAFresh = await TaiYiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      final rowsA = await dbAFresh.select(dbAFresh.userSchools).get();
      expect(rowsA, isEmpty, reason: '旧 scope 重新打开应为全新空库，句柄已解绑');

      final dbB = await TaiYiDatabase.forScope('scope-B', databaseDirectory: dbDir);
      final rowsB = await dbB.select(dbB.userSchools).get();
      expect(rowsB, hasLength(1), reason: '新 scope 应持有原数据');
      expect(rowsB.single.name, '句柄测试');
    });

    test('7. AiDatabase 搬迁验证：AiDatabase 注册进 handover 并在交接后在新 scope 可读', () async {
      const personaUuid = '11111111-1111-1111-1111-111111111111';
      final aiA = await AiDatabase.forScope('scope-A', databaseDirectory: dbDir);
      await aiA.aiPersonasDao.insertPersona(
        AiPersonasCompanion.insert(
          uuid: personaUuid,
          name: '自定义人设A',
          modelUuid: 'deepseek-chat',
          createdAt: DateTime.utc(2026),
        ),
      );
      final personaBefore = await aiA.aiPersonasDao.getByUuid(personaUuid);
      expect(personaBefore?.name, '自定义人设A');

      final handover = buildHandover();
      await handover.handover(fromScope: 'scope-A', toScope: 'scope-B');

      final aiB = await AiDatabase.forScope('scope-B', databaseDirectory: dbDir);
      final personaB = await aiB.aiPersonasDao.getByUuid(personaUuid);
      expect(personaB, isNotNull);
      expect(personaB?.name, '自定义人设A');
    });
  });
}
