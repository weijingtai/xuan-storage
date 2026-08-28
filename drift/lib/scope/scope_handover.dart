import 'dart:io';

import 'package:meta/meta.dart' show visibleForTesting;
import '../persistence_drift.dart';

/// scope 交接（handover）服务。
///
/// 职责：把 [fromScope] 名下所有数据 owner 改为 [toScope]，并腾空
/// [fromScope] 的 ledger 绑定（槽位回收），使匿名槽位可被下一任设备
/// 主人复用。
///
/// 铁律：
/// - 数据搬迁必须是【单个事务】内的多条 UPDATE，中途失败整体回滚，
///   绝不出现"一半数据换了 owner、一半没换"。
/// - 搬迁【之前】必须先备份 SQLite 文件；备份失败必须中止搬迁。
/// - 绝不删除用户数据（搬迁 = 改 owner，不是删了重建）。
abstract interface class ScopeHandoverService {
  /// 执行一次 scope 交接。
  ///
  /// [fromScope]：当前数据所在 scope（通常为匿名槽位 device scope）。
  /// [toScope]：数据新归属 scope（通常为刚铸的注册用户 scope）。
  ///
  /// 实现必须保证：任何失败路径都不产生半搬迁状态，也不残留脏数据。
  Future<void> handover({required String fromScope, required String toScope});
}

/// 分文件独立数据库的 handover 参与描述符。
///
/// 描述一个按 scope 分物理文件的独立 Drift 数据库（如 TaiYiDatabase、AiDatabase）。
/// [DriftScopeHandoverService] 在交接时把该库从 [fromScope] 的物理文件（含 -wal / -shm 等伴随文件）
/// 搬迁到 [toScope]。
class ScopedDatabaseDescriptor {
  const ScopedDatabaseDescriptor({
    required this.name,
    required this.databaseDirectory,
    this.onBeforeHandover,
  });

  /// 数据库基础名（如 'taiyi_database'、'ai_database'）。
  /// 对应的文件名为 `${name}_${scopeUid}.sqlite`。
  final String name;

  /// 获取数据库文件所在目录。
  final Future<Directory> Function() databaseDirectory;

  /// 在改名前执行的操作（如关闭连接、清除缓存）。
  final Future<void> Function(String fromScope)? onBeforeHandover;
}

final class _CopiedScopedDbEntry {
  const _CopiedScopedDbEntry({
    required this.dir,
    required this.name,
    required this.fromScope,
    required this.toScope,
    required this.extensions,
  });

  final Directory dir;
  final String name;
  final String fromScope;
  final String toScope;
  final List<String> extensions;
}

/// 主库有 scope_uid 列的表（t_xxx 见各个 data table 定义）。
///
/// 这些表参与 handover 搬迁：把 fromScope 下的记录 UPDATE 为 toScope。
///
/// 说明：
/// - 独立库（AiDatabase、TaiYiDatabase 等）：根据裁决一，采用按 scope 分物理文件
///   （`<name>_<scopeUid>.sqlite`）的隔离方案，不加 scope_uid 列，通过
///   [DriftScopeHandoverService.scopedDatabases] 注册并执行物理文件搬迁。
/// - 主库明细表（t_divination_cases 等 6 张案卷创建流表）：根据裁决二，已在 schema v11
///   添加 scope_uid 列并回填，纳入 [kScopeMigratableTables]。
/// - 已退场表（Seekers、SeekerDivinationMappers 等）：数据已在 t_record_meta，不加 scope_uid。
/// - 纯字典/全局库（DictionaryDatabase、ThemeDatabase、AccountDatabase）：全局共享或内存库，不分 scope。
const List<String> kScopeMigratableTables = [
  't_outbox', // OutboxRecords
  't_sync_state', // SyncStates
  't_entity_stamp', // EntityStamps
  't_record_meta', // TRecordMeta
  't_record_search_index', // TRecordSearchIndex
  't_decision_links', // DecisionLinks
  't_divination_tags', // DivinationTags
  't_blob_meta', // BlobMetas
  't_divination_cases', // DivinationCases（SW1-T1）
  't_divination_work_items', // DivinationWorkItems（SW1-T1）
  't_case_participants', // CaseParticipants（SW1-T1）
  't_panel_refs', // PanelRefs（SW1-T1）
  't_work_item_panel_refs', // WorkItemPanelRefs（SW1-T1）
  't_creation_audit_logs', // CreationAuditLogs（SW1-T1）
  't_timing_divinations', // TimingDivinations（SW2）
  't_seekers', // Seekers（SW2）
  't_skill_classes', // SkillClasses（SW2）
];

/// Drift 实现的 scope 交接服务。
///
/// 搬迁顺序：
/// 1. 备份 SQLite 文件（主库 + 分文件库，失败即中止，绝不继续）。
/// 2. 检查分文件库目标文件是否存在（存在则抛异常中止，禁止覆盖/合并）。
/// 3. 复制 blob 目录 from → to（若存在）。
/// 4. 复制分文件库物理文件（含 -wal / -shm）from → to（若存在）。
/// 5. 主库【单事务】内：UPDATE 全部有 scope 列的表 + 腾空 fromScope 槽位。
/// 6. 事务成功 → 删除旧 blob 目录与旧分文件库 from 文件。
/// 7. 事务失败 → 清理新复制的 blob 目录与新分文件库 to 文件，重抛。
class DriftScopeHandoverService implements ScopeHandoverService {
  DriftScopeHandoverService({
    required PersistenceDriftDatabase db,
    required ScopeLedger ledger,
    required this.blobDirForScope,
    required ScopeBackupService backupService,
    this.scopedDatabases = const [],
    this.backupDirectory,
    @visibleForTesting this.beforeEachTableUpdate,
  }) : _db = db,
       _ledger = ledger,
       _backupService = backupService;

  /// 返回某个 scope 的 blob 根目录（不存在返回 null）。
  final String? Function(String scopeUid) blobDirForScope;

  final ScopeBackupService _backupService;

  final PersistenceDriftDatabase _db;
  final ScopeLedger _ledger;

  /// 分文件独立数据库列表（如 TaiYiDatabase、AiDatabase）。
  final List<ScopedDatabaseDescriptor> scopedDatabases;

  /// 备份目录。若为 null，则尝试从 [_backupService] 获取或回退到各 DB 目录下的 `backups/`。
  final Directory? backupDirectory;

  /// 仅测试用：每张表 UPDATE 前回调。抛异常用于模拟"搬迁中途失败"，
  /// 验证事务整体回滚。生产代码不传。
  final Future<void> Function(int tableIndex)? beforeEachTableUpdate;

  @override
  Future<void> handover({
    required String fromScope,
    required String toScope,
  }) async {
    // 0. 前置检查：fromScope 与 toScope 不得相同
    if (fromScope == toScope) {
      throw ArgumentError(
        'ScopeHandover: fromScope == toScope ($fromScope) — '
        'refusing no-op handover.',
      );
    }

    // 1. 目标文件冲突预检（Point B：目标文件已存在则抛异常中止，禁止覆盖或合并）
    for (final desc in scopedDatabases) {
      final dir = await desc.databaseDirectory();
      for (final ext in const ['', '-wal', '-shm', '-journal']) {
        final targetFile = File('${dir.path}/${desc.name}_$toScope.sqlite$ext');
        if (await targetFile.exists()) {
          throw StateError(
            'ScopeHandover: target scoped database file already exists: '
            '${targetFile.path} — refusing to overwrite.',
          );
        }
      }
    }

    // 2. 准备与备份（Point A & 备份纪律）
    // 2.1 主库备份（失败即中止）
    await _backupService.backup(fromScope: fromScope, toScope: toScope);

    // 2.2 分文件库备份与连接释放
    final resolvedBackupDir =
        backupDirectory ??
        (_backupService is DriftSqliteFileBackupService
            ? (_backupService as DriftSqliteFileBackupService).backupDirectory
            : null);

    for (final desc in scopedDatabases) {
      final dir = await desc.databaseDirectory();
      final srcMain = File('${dir.path}/${desc.name}_$fromScope.sqlite');
      if (await srcMain.exists()) {
        // 关闭连接并让缓存失效（Point A）
        if (desc.onBeforeHandover != null) {
          await desc.onBeforeHandover!(fromScope);
        }

        // 执行分文件库物理备份
        final bDir = resolvedBackupDir ?? Directory('${dir.path}/backups');
        if (!await bDir.exists()) {
          await bDir.create(recursive: true);
        }
        final stamp = DateTime.now().millisecondsSinceEpoch;
        for (final ext in const ['', '-wal', '-shm', '-journal']) {
          final srcFile = File(
            '${dir.path}/${desc.name}_$fromScope.sqlite$ext',
          );
          if (await srcFile.exists()) {
            final bPath =
                '${bDir.path}/${desc.name}_scope_handover_${fromScope}_to_${toScope}_$stamp.sqlite$ext';
            await srcFile.copy(bPath);
          }
        }
      }
    }

    // 3. 复制 blob 目录 from → to（若存在）
    final fromBlob = blobDirForScope(fromScope);
    final toBlob = blobDirForScope(toScope);
    var blobCopied = false;
    if (fromBlob != null && toBlob != null) {
      blobCopied = await _copyDirectory(fromBlob, toBlob);
    }

    // 4. 复制分文件库物理文件（Point C 原子性：先复制后删，含伴随文件）
    final copiedScopedDbs = <_CopiedScopedDbEntry>[];
    for (final desc in scopedDatabases) {
      final dir = await desc.databaseDirectory();
      final srcMain = File('${dir.path}/${desc.name}_$fromScope.sqlite');
      if (await srcMain.exists()) {
        final copiedExts = <String>[];
        for (final ext in const ['', '-wal', '-shm', '-journal']) {
          final srcFile = File(
            '${dir.path}/${desc.name}_$fromScope.sqlite$ext',
          );
          if (await srcFile.exists()) {
            final dstFile = File(
              '${dir.path}/${desc.name}_$toScope.sqlite$ext',
            );
            await srcFile.copy(dstFile.path);
            copiedExts.add(ext);
          }
        }
        copiedScopedDbs.add(
          _CopiedScopedDbEntry(
            dir: dir,
            name: desc.name,
            fromScope: fromScope,
            toScope: toScope,
            extensions: copiedExts,
          ),
        );
      }
    }

    try {
      // 5. 主库单事务：UPDATE + 槽位腾空
      await _db.transaction(() async {
        for (var i = 0; i < kScopeMigratableTables.length; i++) {
          final table = kScopeMigratableTables[i];
          final hook = beforeEachTableUpdate;
          if (hook != null) {
            await hook(i);
          }
          await _db.customStatement(
            'UPDATE $table SET scope_uid = ? WHERE scope_uid = ?',
            [toScope, fromScope],
          );
        }
        // 腾空 fromScope 槽位（ledger 负责保留 device bootstrap 记录）
        await _ledger.clearScope(fromScope);
      });
    } catch (e) {
      // 7. 事务失败 → 清理新复制的 blob 目录与新分文件库 to 文件，保证数据不丢
      if (blobCopied && toBlob != null) {
        await _deleteDirectory(toBlob);
      }
      for (final entry in copiedScopedDbs) {
        for (final ext in entry.extensions) {
          final dstFile = File(
            '${entry.dir.path}/${entry.name}_${entry.toScope}.sqlite$ext',
          );
          if (await dstFile.exists()) {
            await dstFile.delete();
          }
        }
      }
      rethrow;
    }

    // 6. 事务成功 → 删除旧 blob 目录与旧分文件库 from 文件
    if (blobCopied && fromBlob != null) {
      await _deleteDirectory(fromBlob);
    }
    for (final entry in copiedScopedDbs) {
      for (final ext in entry.extensions) {
        final srcFile = File(
          '${entry.dir.path}/${entry.name}_${entry.fromScope}.sqlite$ext',
        );
        if (await srcFile.exists()) {
          await srcFile.delete();
        }
      }
    }
  }

  /// 递归复制目录。返回是否实际发生复制（源目录存在）。
  Future<bool> _copyDirectory(String src, String dest) async {
    final srcDir = Directory(src);
    if (!await srcDir.exists()) return false;
    await _recursiveCopy(srcDir, Directory(dest));
    return true;
  }

  Future<void> _recursiveCopy(Directory src, Directory dest) async {
    await for (final entity in src.list(recursive: false)) {
      final target = '${dest.path}/${entity.uri.pathSegments.last}';
      if (entity is Directory) {
        await _recursiveCopy(entity, Directory(target));
      } else if (entity is File) {
        await File(target).create(recursive: true);
        await entity.copy(target);
      }
    }
  }

  Future<void> _deleteDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
