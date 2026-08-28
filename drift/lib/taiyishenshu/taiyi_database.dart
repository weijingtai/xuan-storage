import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../scope/prescope_legacy_archiver.dart';
import 'taiyi_database_memory_stub.dart'
    if (dart.library.ffi) 'taiyi_database_memory_native.dart';

part 'taiyi_database.g.dart';

class UserSchools extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get source => text().withDefault(const Constant('user'))();
  TextColumn get contentJson => text()();
  TextColumn get scopeUid => text().named('scope_uid').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserDeities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get source => text().withDefault(const Constant('user'))();
  TextColumn get contentJson => text()();
  TextColumn get scopeUid => text().named('scope_uid').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [UserSchools, UserDeities])
class TaiYiDatabase extends _$TaiYiDatabase {
  /// 进程级 per-scope 单例缓存：同一 scope 在同一进程内只构造一个实例。
  ///
  /// 配合 [forScope] 的 in-flight 去重，从根源杜绝"同一 scope 并发触发
  /// 两次 rebuildForScope 导致两个 TaiYiDatabase 指向不同物理文件"的竞态
  /// （xuan_shell_dependencies.dart 的 _onAccountChanged 注释所述）。
  static final Map<String, Future<TaiYiDatabase>> _scopeFutures = {};

  /// 按 scope 打开（懒加载 + 单例）数据库实例。
  ///
  /// 首次打开该 scope 前会先执行存量数据一次性归档（备份 → 改名），
  /// 把无 scope 时代的旧文件 `<name>.sqlite` 归入当前 scope。
  /// 并发调用返回同一个 Future，保证只构造一个实例。
  static Future<TaiYiDatabase> forScope(
    String scopeUid, {
    Future<Directory> Function()? databaseDirectory,
    Directory? backupDirectory,
  }) {
    final existing = _scopeFutures[scopeUid];
    if (existing != null) return existing;
    final future = _createScoped(scopeUid, databaseDirectory, backupDirectory);
    _scopeFutures[scopeUid] = future;
    return future;
  }

  static Future<TaiYiDatabase> _createScoped(
    String scopeUid,
    Future<Directory> Function()? databaseDirectory,
    Directory? backupDirectory,
  ) async {
    try {
      final dirFn = databaseDirectory ?? getApplicationSupportDirectory;
      // 存量归档：备份失败抛异常，中止（不进入构造）。
      await PrescopeLegacyArchiver(
        databaseDirectory: dirFn,
        backupDirectory:
            backupDirectory ?? Directory('${(await dirFn()).path}/backups'),
      ).archive(dbName: 'taiyi_database', scopeUid: scopeUid);
      return TaiYiDatabase(
        scopeUid: scopeUid,
        databaseDirectory: databaseDirectory,
      );
    } catch (_) {
      // 创建失败时清空，允许下次重建（否则 failed Future 会被永久复用）。
      _scopeFutures.remove(scopeUid);
      rethrow;
    }
  }

  /// 关闭指定 scope 的数据库连接并从单例缓存中移除。
  ///
  /// 用于 handover 搬迁前释放文件句柄并使缓存失效，
  /// 防止后续读写指向已被改名的文件句柄。
  static Future<void> closeScope(String scopeUid) async {
    final future = _scopeFutures.remove(scopeUid);
    if (future != null) {
      try {
        final db = await future;
        await db.close();
      } catch (_) {}
    }
  }

  /// 清空进程级 scope 单例缓存（测试隔离用）。
  static void resetScopeCache() {
    _scopeFutures.clear();
  }

  TaiYiDatabase({
    String? scopeUid,
    Future<Directory> Function()? databaseDirectory,
  }) : super(
         driftDatabase(
           name: scopeUid == null
               ? 'taiyi_database'
               : 'taiyi_database_$scopeUid',
           native: DriftNativeOptions(
             databaseDirectory:
                 databaseDirectory ?? getApplicationSupportDirectory,
           ),
           web: DriftWebOptions(
             sqlite3Wasm: Uri.parse('sqlite3.wasm'),
             driftWorker: Uri.parse('drift_worker.js'),
             onResult: (result) {
               debugPrint(
                 '[TaiYiDatabase] Web storage: ${result.chosenImplementation}',
               );
               if (result.missingFeatures.isNotEmpty) {
                 debugPrint(
                   '[TaiYiDatabase] Missing features: ${result.missingFeatures}',
                 );
               }
             },
           ),
         ),
       );

  /// In-memory test executor. Native-only — on web this throws
  /// UnsupportedError. Used by the integration tests in
  /// `test/integration/zt30_*.dart`.
  TaiYiDatabase.memory() : super(createMemoryExecutor());

  TaiYiDatabase.withExecutor(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndices();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        final schoolCols = await customSelect(
          'SELECT name FROM pragma_table_info("user_schools")',
        ).get();
        if (!schoolCols.any((r) => r.read<String>('name') == 'scope_uid')) {
          await m.addColumn(userSchools, userSchools.scopeUid);
        }
        final deityCols = await customSelect(
          'SELECT name FROM pragma_table_info("user_deities")',
        ).get();
        if (!deityCols.any((r) => r.read<String>('name') == 'scope_uid')) {
          await m.addColumn(userDeities, userDeities.scopeUid);
        }
        await _createIndices();
      }
    },
  );

  Future<void> _createIndices() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_user_schools_scope ON user_schools(scope_uid)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_user_deities_scope ON user_deities(scope_uid)',
    );
  }
}
