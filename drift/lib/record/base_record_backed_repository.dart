import 'dart:async';

import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';

import 'record_entity_descriptor.dart';
import 'record_row_mapper.dart';
import 'record_storage_driver.dart';

/// Type-safe reusable record-storage base.
///
/// M1 起该基类降级为**适配层**：既有九个方法保留原签名，内部改为切片
/// 组合——读/删路径委托 L0 契约内核（[CrudBaseRepository] +
/// [RecordStorageDriver] + [recordEntityDescriptor]）；save / watchAll /
/// 索引查询因 record 独有能力（encode/outbox/搜索标签/drift watch 时序）
/// 与 L0 能力边界（暂无索引 API）保留 [ScopedRecordStore] 端口直连。
/// 保证八个模块的 record_backed_* 仓储**零改动**继续可用。
/// M4 将整体退场，调用方直接使用 L0 切片。
///
/// 依赖仅限 [ScopedRecordStore] 与 [RecordModuleCodec<TContract>] 端口，
/// 不 import Drift 表类或数据源内部。
abstract class BaseRecordBackedRepository<TContract> {
  BaseRecordBackedRepository({
    required ScopedRecordStore store,
    required RecordModuleCodec<TContract> codec,
    Uuid? uuid,
  })  : _store = store,
        _codec = codec,
        _uuid = uuid ?? const Uuid(),
        _l0 = CrudBaseRepository<Map<String, Object?>, String>(
          descriptor: recordEntityDescriptor(module: codec.module),
          driver: RecordStorageDriver(store: store),
        );

  final ScopedRecordStore _store;
  final RecordModuleCodec<TContract> _codec;
  final Uuid _uuid;

  /// L0 契约内核仓储（切片组合：CrudBaseRepository + RecordStorageDriver）。
  final CrudBaseRepository<Map<String, Object?>, String> _l0;

  String get module => _codec.module;

  RequestContext get _ctx => RequestContext(scopeUid: _store.scopeUid);

  /// 行 → 契约实体：RecordMeta + moduleData 一起交给 codec decode。
  TContract _decodeRow(Map<String, Object?> row) => _codec.decode(
        RecordRowMapper.rowToMeta(row),
        RecordRowMapper.moduleDataOf(row),
      );

  // ── save ──
  // M1 试点保留 store 端口直写：record 的 encode / outbox / 搜索索引
  // 语义是 ScopedRecordStore 独有能力，L0 put 的行形态无法等价表达；
  // 且直写路径与既有 watch 流时序保持一致（避免订阅竞争回归）。
  @Deprecated('M4 退场，改用 L0 切片')
  Future<String> save(TContract contract) async {
    final currentUuid = _codec.uuidOf(contract);
    final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
    final fixed =
        currentUuid.isNotEmpty ? contract : _codec.withUuid(contract, effectiveUuid);
    final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);
    _validateEncodedMeta(encoded.meta, effectiveUuid);
    await _store.saveRecord(encoded.meta, moduleData: encoded.moduleData);
    return effectiveUuid;
  }

  // ── read ──
  // M1 试点保留 store 端口直连：既有语义允许读取已软删记录
  // （返回带 deletedAt 的实体），而 L0 get 一律排除软删，语义不等价。
  @Deprecated('M4 退场，改用 L0 切片')
  Future<TContract?> getByUuid(String uuid) async {
    final meta = await _store.getRecord(uuid, module: module);
    return meta == null ? null : _codec.decode(meta, null);
  }

  @Deprecated('M4 退场，改用 L0 切片')
  Future<List<TContract>> getAll({int pageSize = 200}) async {
    final results = <TContract>[];
    String? cursor;
    while (true) {
      final r = await _l0.query(
        const {},
        PageRequest(limit: pageSize, cursor: cursor),
        _ctx,
      );
      final page = (r as Ok<Page<Map<String, Object?>>>).value;
      results.addAll(page.items.map(_decodeRow));
      if (!page.hasMore) break;
      cursor = page.nextCursor;
    }
    return results;
  }

  // ── watch ──
  // M1 试点保留 store 端口直连：drift watch 的 category SQL 过滤与
  // 订阅即发初始快照的时序语义，经 L0 watch（通用 equals 内存过滤）
  // 无法等价，直接走 store 与基线行为一致。
  @Deprecated('M4 退场，改用 L0 切片')
  Stream<List<TContract>> watchAll() => _store
      .watchRecords(module: module, category: _codec.category)
      .map((metas) => metas.map((m) => _codec.decode(m, null)).toList());

  @Deprecated('M4 退场，改用 L0 切片')
  Future<List<TContract>> getLatest({int limit = 10}) async {
    final r = await _l0.query(const {}, PageRequest(limit: limit), _ctx);
    return ((r as Ok<Page<Map<String, Object?>>>).value)
        .items
        .map(_decodeRow)
        .toList();
  }

  // ── delete ──
  @Deprecated('M4 退场，改用 L0 切片')
  Future<bool> softDelete(String uuid) async {
    final r = await _l0.softDelete(uuid, _ctx);
    return r is Ok;
  }

  // ── index queries ──
  // L0 契约内核暂无索引 API（RecordSearchTagExtractor 标签体系是 record
  // 独有能力），这三个方法保持直连 store 的标签索引，M4 随适配层一起退场。
  @Deprecated('M4 退场，改用 L0 切片')
  Future<TContract?> getFirstByIndex(String indexKey, String indexValue) async {
    final metas = await _store.findByIndex(
        module: module, indexKey: indexKey, indexValue: indexValue, limit: 1);
    return metas.isEmpty ? null : _codec.decode(metas.first, null);
  }

  @Deprecated('M4 退场，改用 L0 切片')
  Future<List<TContract>> getAllByIndex(String indexKey, String indexValue,
      {int limit = 200}) async {
    final metas = await _store.findByIndex(
        module: module, indexKey: indexKey, indexValue: indexValue, limit: limit);
    return metas.map((m) => _codec.decode(m, null)).toList();
  }

  @Deprecated('M4 退场，改用 L0 切片')
  Stream<TContract?> watchFirstByIndex(String indexKey, String indexValue) =>
      _store
          .watchByIndex(module: module, indexKey: indexKey, indexValue: indexValue)
          .map((metas) => metas.isEmpty ? null : _codec.decode(metas.first, null));

  void _validateEncodedMeta(RecordMeta meta, String expectedUuid) {
    if (meta.uuid != expectedUuid) {
      throw RecordCodecMismatch(message: 'uuid mismatch');
    }
    if (meta.module != _codec.module) {
      throw RecordCodecMismatch(message: 'module mismatch');
    }
    if (meta.scopeUid != _store.scopeUid) {
      throw RecordCodecMismatch(message: 'scope mismatch');
    }
  }
}
