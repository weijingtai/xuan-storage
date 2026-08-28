import 'dart:io';

import '../persistence_drift.dart';

/// 备份服务：handover 搬迁【之前】必须执行的物理备份。
///
/// 备份失败必须抛异常，调用方（DriftScopeHandoverService）据此中止搬迁。
abstract interface class ScopeBackupService {
  /// 执行一次物理备份，返回备份文件绝对路径。
  ///
  /// 命名必须能识别是哪次搬迁（含 from → to scope 标识）。
  /// 失败抛异常，绝不静默返回。
  Future<String> backup({required String fromScope, required String toScope});
}

/// SQLite 文件物理复制备份实现。
///
/// 通过 `PRAGMA database_list` 拿主库文件路径（不依赖 drift 的
/// QueryExecutor.filePath，因为该 API 未暴露），把文件整体复制到
/// [backupDirectory]，文件名形如
/// `scope_handover_<from>_to_<to>_<epochMs>.sqlite`。
///
/// 注意：内存库（NativeDatabase.memory()）的 main 文件路径为空，
/// 无法物理备份 → 抛 [StateError]，由调用方中止搬迁。
class DriftSqliteFileBackupService implements ScopeBackupService {
  DriftSqliteFileBackupService({
    required PersistenceDriftDatabase db,
    required Directory backupDirectory,
  }) : _db = db,
       _backupDirectory = backupDirectory;

  final PersistenceDriftDatabase _db;
  final Directory _backupDirectory;

  /// 备份文件存放目录。
  Directory get backupDirectory => _backupDirectory;

  @override
  Future<String> backup({
    required String fromScope,
    required String toScope,
  }) async {
    // 1. 拿主库文件路径
    final mainPath = await _mainDatabaseFilePath();
    if (mainPath == null || mainPath.isEmpty) {
      throw StateError(
        'ScopeHandover: cannot backup — main database is in-memory '
        '(PRAGMA database_list returned empty file for main). '
        'Aborting handover $fromScope -> $toScope.',
      );
    }

    // 2. 构造备份文件路径（可识别是哪次搬迁）
    if (!await _backupDirectory.exists()) {
      await _backupDirectory.create(recursive: true);
    }
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'scope_handover_${fromScope}_to_${toScope}_$stamp.sqlite';
    final backupPath = '${_backupDirectory.path}/$fileName';

    // 3. 物理复制（整体文件复制，非 SQL 导出）
    await File(mainPath).copy(backupPath);

    return backupPath;
  }

  /// 通过 PRAGMA database_list 获取 main 库文件路径。
  Future<String?> _mainDatabaseFilePath() async {
    try {
      final rows = await _db
          .customSelect(
            "SELECT file FROM pragma_database_list WHERE name = 'main'",
          )
          .get();
      if (rows.isEmpty) return null;
      final file = rows.first.read<String>('file');
      return file == '' ? null : file;
    } catch (_) {
      // PRAGMA 查询异常也按"无法备份"处理，交给调用方中止。
      return null;
    }
  }
}
