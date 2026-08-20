import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/taiyishenshu/taiyi_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 测试 2 故意构造两个实例验证文件级持久性（生产用 forScope 单例，无此情形）。
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('TaiYiDatabase scope 分文件', () {
    late Directory base;
    late Directory backup;

    Future<Directory> dir() async => base;

    setUp(() async {
      base = await Directory.systemTemp.createTemp('taiyi-scope');
      backup = await Directory.systemTemp.createTemp('taiyi-scope-backup');
      // drift_flutter 的 driftDatabase 会调用 path_provider 取临时目录，
      // 测试环境无平台通道 → mock 指向临时目录。
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
      TaiYiDatabase.resetScopeCache();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      await base.delete(recursive: true);
      await backup.delete(recursive: true);
    });

    Future<void> insertSchool(
      TaiYiDatabase db,
      String id,
      String name,
    ) async {
      await db.into(db.userSchools).insert(
            UserSchoolsCompanion.insert(
              id: id,
              name: name,
              contentJson: '{"name": "$name"}',
            ),
          );
    }

    test('scope A 与 scope B 打开不同物理文件，数据互不可见', () async {
      final dbA = TaiYiDatabase(scopeUid: 'A', databaseDirectory: dir);
      final dbB = TaiYiDatabase(scopeUid: 'B', databaseDirectory: dir);

      await insertSchool(dbA, 'a-1', 'A学校');
      await insertSchool(dbB, 'b-1', 'B学校');

      final rowsA = await dbA.select(dbA.userSchools).get();
      final rowsB = await dbB.select(dbB.userSchools).get();
      expect(rowsA, hasLength(1));
      expect(rowsB, hasLength(1));
      expect(rowsA.single.name, 'A学校');
      expect(rowsB.single.name, 'B学校');

      await dbA.close();
      await dbB.close();

      final fileA = File('${base.path}/taiyi_database_A.sqlite');
      final fileB = File('${base.path}/taiyi_database_B.sqlite');
      expect(fileA.existsSync(), isTrue);
      expect(fileB.existsSync(), isTrue);
      expect(fileA.path, isNot(fileB.path));
    });

    test('同一 scope 重复打开命中同一物理文件（数据持久）', () async {
      final db1 = TaiYiDatabase(scopeUid: 'A', databaseDirectory: dir);
      await insertSchool(db1, 'a-1', '学校');
      await db1.close();

      final db2 = TaiYiDatabase(scopeUid: 'A', databaseDirectory: dir);
      final rows = await db2.select(db2.userSchools).get();
      expect(rows, hasLength(1), reason: '同一 scope 应命中同一物理文件');
      expect(rows.single.name, '学校');
      await db2.close();
    });

    test('存量归档：旧无 scope 文件启动后数据可读 + 备份文件存在', () async {
      // 1. 造旧的无 scope 库文件并写入存量数据
      final legacy = TaiYiDatabase(databaseDirectory: dir);
      await insertSchool(legacy, 'legacy-1', '旧数据');
      await legacy.close();
      final legacyFile = File('${base.path}/taiyi_database.sqlite');
      expect(legacyFile.existsSync(), isTrue);

      // 2. 启动：forScope 打开前执行归档
      final dbA =
          await TaiYiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup);
      final rows = await dbA.select(dbA.userSchools).get();
      expect(rows, hasLength(1), reason: '归档后旧数据必须仍可读');
      expect(rows.single.name, '旧数据');

      // 3. 旧文件已改名为带 scope 文件，备份存在
      expect(legacyFile.existsSync(), isFalse, reason: '旧文件应已被改名归档');
      expect(
        File('${base.path}/taiyi_database_A.sqlite').existsSync(),
        isTrue,
        reason: '归档后旧数据应落在 scope A 的文件里',
      );
      final backups = backup
          .listSync()
          .where((e) => e.path.endsWith('.sqlite'))
          .toList();
      expect(backups, hasLength(1), reason: '改名前必须有备份');
      await dbA.close();
    });

    test('TaiYi 竞态：并发两次 forScope 不产生两个指向不同文件的实例', () async {
      final results = await Future.wait([
        TaiYiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup),
        TaiYiDatabase.forScope('A', databaseDirectory: dir, backupDirectory: backup),
      ]);
      expect(results[0], same(results[1]), reason: '同一 scope 并发必须命中同一实例');
      await results[0].close();
    });
  });
}