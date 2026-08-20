import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/ai/ai_database.dart';
import 'package:persistence_drift/ai/tables/tables.dart';
import 'package:persistence_drift/scope/prescope_legacy_archiver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('AiDatabase scope 分文件', () {
    late Directory base;
    late Directory backup;

    Future<Directory> dir() async => base;

    setUp(() async {
      base = await Directory.systemTemp.createTemp('ai-scope');
      backup = await Directory.systemTemp.createTemp('ai-scope-backup');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async {
          if (call.method == 'getTemporaryDirectory') return base.path;
          if (call.method == 'getApplicationSupportDirectory') return base.path;
          if (call.method == 'getApplicationDocumentsDirectory') {
            return base.path;
          }
          return null;
        },
      );
    });

    tearDown(() async {
      AiDatabase.resetScopeCache();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      await base.delete(recursive: true);
      await backup.delete(recursive: true);
    });

    Future<void> insertProvider(
      AiDatabase db,
      String uuid,
      String name,
    ) async {
      await db.llmProvidersDao.upsert(
        LlmProvidersCompanion(
          uuid: drift.Value(uuid),
          name: drift.Value(name),
          baseUrl: const drift.Value('https://api.example.com'),
          encryptedApiKey: const drift.Value('test-key'),
          configJson: const drift.Value('{}'),
          isEnabled: const drift.Value(true),
          isDefault: const drift.Value(false),
          createdAt: drift.Value(DateTime.now()),
          lastUpdatedAt: drift.Value(DateTime.now()),
        ),
      );
    }

    test('scope A 与 scope B 打开不同物理文件，数据互不可见', () async {
      final dbA = await AiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup);
      final dbB = await AiDatabase.forScope('B', databaseDirectory: dir, backupDirectory: backup);

      const uuidA = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      const uuidB = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

      await insertProvider(dbA, uuidA, 'Provider A');
      await insertProvider(dbB, uuidB, 'Provider B');

      final providerA = await dbA.llmProvidersDao.getByUuid(uuidA);
      final providerBOnA = await dbA.llmProvidersDao.getByUuid(uuidB);
      final providerB = await dbB.llmProvidersDao.getByUuid(uuidB);
      final providerAOnB = await dbB.llmProvidersDao.getByUuid(uuidA);

      expect(providerA, isNotNull);
      expect(providerA!.name, 'Provider A');
      expect(providerBOnA, isNull, reason: 'Scope A 不应看见 Scope B 的数据');

      expect(providerB, isNotNull);
      expect(providerB!.name, 'Provider B');
      expect(providerAOnB, isNull, reason: 'Scope B 不应看见 Scope A 的数据');

      await dbA.close();
      await dbB.close();

      final fileA = File('${base.path}/ai_database_A.sqlite');
      final fileB = File('${base.path}/ai_database_B.sqlite');
      expect(fileA.existsSync(), isTrue);
      expect(fileB.existsSync(), isTrue);
      expect(fileA.path, isNot(fileB.path));
    });

    test('同一 scope 重复打开命中同一物理文件（数据持久）', () async {
      const uuid1 = '11111111-1111-1111-1111-111111111111';
      final db1 = await AiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup);
      await insertProvider(db1, uuid1, 'Provider 1');
      await db1.close();
      AiDatabase.resetScopeCache();

      final db2 = await AiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup);
      final provider = await db2.llmProvidersDao.getByUuid(uuid1);
      expect(provider, isNotNull, reason: '同一 scope 应命中同一物理文件并保留数据');
      expect(provider!.name, 'Provider 1');
      await db2.close();
    });

    test('存量归档：旧无 scope 文件启动后数据可读 + 备份文件存在', () async {
      final legacyFile = File('${base.path}/ai_database.sqlite');
      await legacyFile.writeAsString('mock legacy sqlite header content');
      expect(legacyFile.existsSync(), isTrue);

      final archiver = PrescopeLegacyArchiver(
        databaseDirectory: dir,
        backupDirectory: backup,
      );
      await archiver.archive(dbName: 'ai_database', scopeUid: 'A');

      expect(legacyFile.existsSync(), isFalse, reason: '旧文件应已被改名归档');
      expect(
        File('${base.path}/ai_database_A.sqlite').existsSync(),
        isTrue,
        reason: '归档后旧文件应重命名为 scope A 的文件',
      );
      final backups = backup
          .listSync()
          .where((e) => e.path.endsWith('.sqlite'))
          .toList();
      expect(backups, hasLength(1), reason: '改名前必须有物理备份');
    });

    test('AiDatabase 竞态：并发两次 forScope 返回同一单例实例', () async {
      final results = await Future.wait([
        AiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup),
        AiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup),
      ]);
      expect(results[0], same(results[1]), reason: '同一 scope 并发调用必须返回相同单例实例');
      await results[0].close();
    });
  });
}
