import 'dart:io';

/// 存量数据一次性归档：把"无 scope 时代的旧库文件"备份后改名为带 scope 文件。
///
/// 背景：scope 分文件改造前，`taiyi_database.sqlite` / `ai_database.sqlite`
/// 是设备级单文件，改造后按 scope 拆成 `<name>_<scopeUid>.sqlite`。
/// 首次启动（某个 scope 第一次打开）时必须把旧文件归入当前 scope，
/// 否则旧用户数据会"消失"。改名前必须物理备份，备份失败必须抛异常中止，
/// 绝不带着风险继续（与 [DriftSqliteFileBackupService] 同一纪律）。
///
/// 幂等：只处理一次。旧文件改名后即不存在；目标 scope 文件已存在则跳过。
class PrescopeLegacyArchiver {
  PrescopeLegacyArchiver({
    required Future<Directory> Function() databaseDirectory,
    required Directory backupDirectory,
  }) : _databaseDirectory = databaseDirectory,
       _backupDirectory = backupDirectory;

  final Future<Directory> Function() _databaseDirectory;
  final Directory _backupDirectory;

  /// 若旧文件 `<name>.sqlite` 存在且目标 `<name>_<scopeUid>.sqlite` 不存在：
  /// 1. 先备份旧文件到 [backupDirectory]（命名含 dbName / scope / 时间戳）
  /// 2. 备份成功后才改名旧文件为目标文件
  ///
  /// 备份失败（copy 抛异常）→ 本方法抛异常，调用方据此中止后续打开。
  Future<void> archive({
    required String dbName,
    required String scopeUid,
  }) async {
    final dir = await _databaseDirectory();
    final legacyFile = File('${dir.path}/$dbName.sqlite');
    final scopedFile = File('${dir.path}/${dbName}_$scopeUid.sqlite');

    // 无旧文件：首次改造前没有存量，无事可做
    if (!await legacyFile.exists()) return;
    // 目标 scope 文件已存在：该 scope 已打开过（或已归档），不覆盖
    if (await scopedFile.exists()) return;

    // 1. 备份（必须先成功）
    if (!await _backupDirectory.exists()) {
      await _backupDirectory.create(recursive: true);
    }
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath =
        '${_backupDirectory.path}/${dbName}_prescope_${scopeUid}_$stamp.sqlite';
    await legacyFile.copy(backupPath);

    // 2. 改名（备份成功后才执行；rename 失败同样抛异常中止）
    await legacyFile.rename(scopedFile.path);
  }
}
