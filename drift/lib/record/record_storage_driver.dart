import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

import 'drift_record_data_source.dart';
import 'record_cursor.dart';
import 'record_row_mapper.dart';

/// 把既有 [ScopedRecordStore] 适配成 L0 的 [StorageDriver]。
///
/// - 写路径走 [ScopedRecordStore]（saveRecord / softDeleteRecord），
///   保留既有 outbox 与搜索索引语义；
/// - 读路径走 [DriftRecordDataSource]（getRecord / listRecords /
///   findByIndex / watchRecords / watchByIndex / countRecords）；
/// - **scope 一律取自入参 [RawFilter.scopeUid]（或写路径行的
///   `scope_uid`），禁止从 store 隐式取**——store 的 scopeUid 仅作为
///   一致性校验基准，不匹配时读侧返回空、写侧抛 [StorageRevMismatch]。
class RecordStorageDriver implements StorageDriver {
  RecordStorageDriver({
    required ScopedRecordStore store,
    required DriftRecordDataSource dataSource,
  })  : _store = store,
        _ds = dataSource;

  final ScopedRecordStore _store;
  final DriftRecordDataSource _ds;

  bool _scopeOk(String scopeUid) => scopeUid == _store.scopeUid;

  /// 解释 L0 Base 生成的游标（`id:<uuid>`）。
  static String? _cursorIdOf(String cursor) =>
      cursor.startsWith('id:') ? cursor.substring(3) : null;

  /// equals 等值匹配：按扁平行键取值比较。
  static bool _matchesEquals(RecordMeta m, Map<String, Object?> equals) {
    final row = RecordRowMapper.metaToRow(m);
    return equals.entries.every((e) => '${row[e.key]}' == '${e.value}');
  }

  @override
  Future<Map<String, Object?>?> readOne(
      String resource, Object id, RawFilter filter) async {
    if (!_scopeOk(filter.scopeUid)) return null;
    final meta = await _ds.getRecord('$id');
    if (meta == null) return null;
    if (!filter.includeSoftDeleted && meta.deletedAt != null) return null;
    return RecordRowMapper.metaToRow(meta);
  }

  @override
  Future<List<Map<String, Object?>>> readMany(
      String resource, RawFilter filter, RawPage page) async {
    if (!_scopeOk(filter.scopeUid)) return const [];
    List<RecordMeta> metas;
    if (filter.equals.isNotEmpty) {
      // equals 是通用字段等值语义，与 record 的搜索索引（moduleData 标签）
      // 不是同一体系，这里用「全量 + 内存过滤 + id 游标续页」实现。
      final all = await _ds.listRecords(module: resource, limit: 10000);
      final filtered = all
          .where((m) =>
              filter.includeSoftDeleted || m.deletedAt == null)
          .where((m) => _matchesEquals(m, filter.equals))
          .toList();
      final cursorId = page.cursor == null ? null : _cursorIdOf(page.cursor!);
      final start = cursorId == null
          ? 0
          : filtered.indexWhere((m) => m.uuid == cursorId) + 1;
      final end = start + page.limit;
      return filtered
          .sublist(start.clamp(0, filtered.length), end.clamp(0, filtered.length))
          .map(RecordRowMapper.metaToRow)
          .toList();
    }
    String? cursor;
    if (page.cursor != null) {
      final cid = _cursorIdOf(page.cursor!);
      final anchor = cid == null ? null : await _ds.getRecord(cid);
      if (anchor != null) {
        cursor = RecordCursor(anchor.createdAt, anchor.uuid).encode();
      }
    }
    metas = await _ds.listRecords(
      module: resource,
      limit: page.limit,
      cursor: cursor,
    );
    return metas
        .where((m) => filter.includeSoftDeleted || m.deletedAt == null)
        .map(RecordRowMapper.metaToRow)
        .toList();
  }

  @override
  Future<int> count(String resource, RawFilter filter) async {
    if (!_scopeOk(filter.scopeUid)) return 0;
    if (filter.equals.isNotEmpty) {
      final metas = await _ds.listRecords(module: resource, limit: 10000);
      return metas
          .where((m) =>
              filter.includeSoftDeleted || m.deletedAt == null)
          .where((m) => _matchesEquals(m, filter.equals))
          .length;
    }
    return _ds.countRecords(module: resource);
  }

  @override
  Future<String> write(
    String resource,
    Object id,
    Map<String, Object?> data, {
    String? expectedRev,
  }) async {
    final row = {...data, 'id': id};
    final scopeUid = row['scope_uid'] as String?;
    if (scopeUid == null || !_scopeOk(scopeUid)) {
      throw const StorageRevMismatch('scope-mismatch');
    }

    final existing = await _ds.getRecord('$id');
    if (expectedRev != null && '${existing?.rev}' != expectedRev) {
      throw StorageRevMismatch('${existing?.rev}');
    }
    final newRev = (existing?.rev ?? 0) + 1;

    if (row['deleted_at'] != null) {
      // 软删：走既有语义（清索引 + outbox 删除事件）。
      await _store.softDeleteRecord('$id', module: resource);
      return '$newRev';
    }

    final meta = RecordRowMapper.rowToMeta(row, fallbackRev: newRev);
    await _store.saveRecord(
      meta,
      moduleData: RecordRowMapper.moduleDataOf(row),
    );
    return '$newRev';
  }

  @override
  Future<void> deleteOne(String resource, Object id, RawFilter filter) async {
    if (!_scopeOk(filter.scopeUid)) return;
    await _ds.deleteRecord('$id');
  }

  @override
  Stream<List<Map<String, Object?>>> watchMany(
      String resource, RawFilter filter, RawPage page) async* {
    if (!_scopeOk(filter.scopeUid)) {
      yield const <Map<String, Object?>>[];
      return;
    }
    final Stream<List<RecordMeta>> source = _ds.watchRecords(module: resource);
    yield* source.map((metas) {
      var visible = metas
          .where((m) => filter.includeSoftDeleted || m.deletedAt == null);
      if (filter.equals.isNotEmpty) {
        visible = visible.where((m) => _matchesEquals(m, filter.equals));
      }
      return visible.map(RecordRowMapper.metaToRow).toList();
    });
  }

  @override
  bool get supportsTransaction => false;

  @override
  Future<R> inTransaction<R>(Future<R> Function() body) => body();
}
