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
  Future<void> handover({
    required String fromScope,
    required String toScope,
  });
}

/// 主库有 scope_uid 列的表（t_xxx 见各个 data table 定义）。
///
/// 这些表参与 handover 搬迁：把 fromScope 下的记录 UPDATE 为 toScope。
///
/// 注意：以下表【没有】scope_uid 列，无法按 owner 隔离，也无法参与搬迁
/// （见任务纪要技术点 4，仅列清单 + TODO，不做 schema 变更）：
/// - AiChatSessions / AiChatMessages / AiPersonas / AiUsageAudits
///   （ai/tables/tables.dart，AiDatabase 独立库）
/// - MeiHuaGuaInfos（meihuayishu/meihua_gua_infos.dart）
/// - TimingDivinations（tables/timing_divinations_table.dart）
/// - Seekers（tables/seekers_table.dart）
/// - SkillClasses（tables/skill_classes_table.dart）
/// - UserSchools / UserDeities（taiyishenshu/taiyi_database.dart）
///
/// TODO(scope-migration): 依赖这些表的迁移方案落地后（如 ai 库加 scope_uid、
/// taiyi 库加 scope_uid），再把对应表加入本清单并接入 handover。
const List<String> kScopeMigratableTables = [
  't_outbox', // OutboxRecords
  't_sync_state', // SyncStates
  't_entity_stamp', // EntityStamps
  't_record_meta', // TRecordMeta
  't_record_search_index', // TRecordSearchIndex
  't_decision_links', // DecisionLinks
  't_divination_tags', // DivinationTags
  't_blob_meta', // BlobMetas
];

/// Drift 实现的 scope 交接服务。
///
/// 搬迁顺序（见任务纪要技术点 1/3）：
/// 1. 备份 SQLite 文件（失败即中止，绝不继续）。
/// 2. 复制 blob 目录 from → to（若存在）。
/// 3. 主库【单事务】内：UPDATE 全部有 scope 列的表 + 腾空 fromScope 槽位。
/// 4. 事务成功 → 删除旧 blob 目录 from。
/// 5. 事务失败 → 清理新复制的 blob 目录 to，重抛。
class DriftScopeHandoverService implements ScopeHandoverService {
  DriftScopeHandoverService({
    required PersistenceDriftDatabase db,
    required ScopeLedger ledger,
    required this.blobDirForScope,
    required ScopeBackupService backupService,
    @visibleForTesting
    this.beforeEachTableUpdate,
  })  : _db = db,
        _ledger = ledger,
        _backupService = backupService;

  /// 返回某个 scope 的 blob 根目录（不存在返回 null）。
  final String? Function(String scopeUid) blobDirForScope;

  final ScopeBackupService _backupService;

  final PersistenceDriftDatabase _db;
  final ScopeLedger _ledger;

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

    // 1. 备份（失败即中止）
    await _backupService.backup(fromScope: fromScope, toScope: toScope);

    // 2. 复制 blob 目录 from → to（若存在）
    final fromBlob = blobDirForScope(fromScope);
    final toBlob = blobDirForScope(toScope);
    var blobCopied = false;
    if (fromBlob != null && toBlob != null) {
      blobCopied = await _copyDirectory(fromBlob, toBlob);
    }

    try {
      // 3. 主库单事务：UPDATE + 槽位腾空
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
      // 5. 事务失败 → 清理新复制的 blob 目录
      if (blobCopied && toBlob != null) {
        await _deleteDirectory(toBlob);
      }
      rethrow;
    }

    // 4. 事务成功 → 删除旧 blob 目录 from
    if (blobCopied && fromBlob != null) {
      await _deleteDirectory(fromBlob);
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