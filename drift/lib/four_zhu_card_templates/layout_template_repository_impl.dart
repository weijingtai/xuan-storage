import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:persistence_core/persistence_core.dart' hide XuanError;
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'models/layout_template.dart';
import 'layout_template_local_data_source.dart';

/// [LayoutTemplateRepository] 的 Drift L0 切片实现。
///
/// 内部经 [LayoutTemplateLocalDataSource] 完成持久化与 outbox 入队，
/// 自身负责 LayoutTemplate ↔ LayoutTemplateContract 的编解码与
/// Result/Page 语义包装。
class LayoutTemplateRepositoryImpl implements LayoutTemplateRepository {
  LayoutTemplateRepositoryImpl(
    this._localDataSource, {
    required AuthScopeProvider authScopeProvider,
  }) : _authScopeProvider = authScopeProvider;

  final LayoutTemplateLocalDataSource _localDataSource;
  final AuthScopeProvider _authScopeProvider;

  static const _defaultModuleType = 'four_zhu';

  LayoutTemplateContract _toContract(LayoutTemplate t) {
    return LayoutTemplateContract(
      uuid: t.id,
      name: t.name,
      description: t.description,
      moduleType: _defaultModuleType,
      collectionId: t.collectionId,
      version: t.version,
      templateJson: jsonEncode(t.toJson()),
      format: 'json',
      createdAt: t.updatedAt,
      updatedAt: t.updatedAt,
    );
  }

  LayoutTemplate _toDomain(LayoutTemplateContract c) {
    final decoded = jsonDecode(c.templateJson) as Map<String, dynamic>;
    return LayoutTemplate.fromJson(decoded).copyWith(
      id: c.uuid,
      name: c.name,
      description: c.description ?? '',
      collectionId: c.collectionId,
      version: c.version,
      updatedAt: c.updatedAt,
    );
  }

  Future<List<LayoutTemplateContract>> _loadContracts({
    bool includeDeleted = false,
    String? collectionId,
  }) async {
    if (collectionId != null) {
      final dtos = await _localDataSource.loadTemplates(collectionId);
      return dtos.map((dto) => _toContract(dto.toDomain())).toList();
    }
    final allDtos = await _localDataSource.loadAllTemplates(
      includeDeleted: includeDeleted,
    );
    return allDtos.map((dto) => _toContract(dto.toDomain())).toList();
  }

  // ── L0 Readable ──

  @override
  Future<Result<LayoutTemplateContract?>> get(
    String id,
    RequestContext ctx,
  ) async {
    try {
      final all = await _loadContracts();
      final target = all.firstWhereOrNull((t) => t.uuid == id);
      return Ok(target);
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'layout template get failed: $e',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final r = await get(id, ctx);
    return switch (r) {
      Ok(:final value) => Ok(value != null),
      Err(:final error) => Err(error),
    };
  }

  // ── L0 Writable ──

  @override
  Future<Result<Rev>> put(
    LayoutTemplateContract template,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    try {
      final domain = _toDomain(template);
      final collectionId = domain.collectionId;
      final existingDtos = await _localDataSource.loadTemplates(collectionId);
      final index = existingDtos.indexWhere(
        (dto) => dto.template.id == domain.id,
      );
      final originalVersion = index >= 0
          ? existingDtos[index].template.version
          : 0;
      final updatedTemplate = domain.copyWith(
        version: originalVersion + 1,
        updatedAt: DateTime.now(),
      );

      final scopeUid = await _authScopeProvider.getScopeUid();

      await _localDataSource.upsertTemplate(
        updatedTemplate,
        enqueueOutbox: true,
        scopeUid: scopeUid,
      );
      return Ok(Rev(template.uuid));
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'layout template put failed: $e',
        ),
      );
    }
  }

  // ── L0 SoftDeletable ──

  @override
  Future<Result<void>> softDelete(
    String id,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    try {
      final allDtos = await _localDataSource.loadAllTemplates();
      final target = allDtos.firstWhereOrNull((dto) => dto.template.id == id);
      if (target == null) {
        return Err(
          const XuanError(
            code: ErrorCode.notFound,
            message: 'layout template not found',
          ),
        );
      }
      final scopeUid = await _authScopeProvider.getScopeUid();
      await _localDataSource.softDeleteTemplate(
        target.template.collectionId,
        id,
        enqueueOutbox: true,
        scopeUid: scopeUid,
      );
      return const Ok(null);
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'layout template softDelete failed: $e',
        ),
      );
    }
  }

  /// 本后端暂不支持恢复（软删行无唯一键回收语义），显式返回 invalid_argument。
  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async {
    return const Err(
      XuanError(
        code: ErrorCode.invalidArgument,
        message: 'restore not supported for layout templates',
      ),
    );
  }

  // ── L0 SoftDeleteReadable ──

  @override
  Future<Result<LayoutTemplateContract?>> getIncludingDeleted(
    String id,
    RequestContext ctx,
  ) async {
    try {
      final all = await _loadContracts(includeDeleted: true);
      final target = all.firstWhereOrNull((t) => t.uuid == id);
      return Ok(target);
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'layout template getIncludingDeleted failed: $e',
        ),
      );
    }
  }

  // ── L0 Queryable ──

  @override
  Future<Result<Page<LayoutTemplateContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    try {
      final collectionId = spec['collectionId'] as String?;
      var list = await _loadContracts(collectionId: collectionId);
      list = list.where((t) {
        if (spec case {'moduleType': final String v}) {
          return t.moduleType == v;
        }
        return true;
      }).toList();
      final start = page.cursor == null ? 0 : int.tryParse(page.cursor!) ?? 0;
      final end = (start + page.limit).clamp(0, list.length);
      final items = list.sublist(start, end);
      final hasMore = end < list.length;
      return Ok(
        Page<LayoutTemplateContract>(
          items: items,
          nextCursor: hasMore ? '$end' : null,
        ),
      );
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'layout template query failed: $e',
        ),
      );
    }
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final r = await query(spec, PageRequest(limit: 1 << 31), ctx);
    return switch (r) {
      Ok(:final value) => Ok(value.items.length),
      Err(:final error) => Err(error),
    };
  }

  // ── L0 Watchable ──
  //
  // 本数据源暂无变更推送，先提供「快照单发」流；接入 drift 表级 watch 后升级。

  @override
  Stream<Result<List<LayoutTemplateContract>>> watch(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async* {
    try {
      final collectionId = spec['collectionId'] as String?;
      final list = await _loadContracts(collectionId: collectionId);
      yield Ok(list);
    } catch (e) {
      yield Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'layout template watch failed: $e',
        ),
      );
    }
  }

  // ── L0 BatchWritable ──

  @override
  Future<Result<BatchOutcome<String>>> putAll(
    List<LayoutTemplateContract> entities,
    RequestContext ctx,
  ) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      results.add((id: e.uuid, result: await put(e, ctx)));
    }
    return Ok(BatchOutcome<String>(results));
  }

  // ── L0 Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final result = await body();
      return Ok(result);
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'layout template transaction failed: $e',
        ),
      );
    }
  }

  // ── 遗留别名（旧调用方与既有测试的过渡层，M4 随适配层一并退场） ──

  Future<RequestContext> _legacyCtx() async =>
      RequestContext(scopeUid: await _authScopeProvider.getScopeUid());

  @override
  Future<List<LayoutTemplateContract>> getAllTemplates(String collectionId) =>
      _loadContracts(collectionId: collectionId);

  @override
  Future<LayoutTemplateContract?> getTemplateById(
    String collectionId,
    String templateId,
  ) async {
    final list = await _loadContracts(collectionId: collectionId);
    return list.firstWhereOrNull((c) => c.uuid == templateId);
  }

  @override
  Future<void> saveTemplate(LayoutTemplateContract template) async {
    final r = await put(template, await _legacyCtx());
    if (r case Err(error: final e)) throw e;
  }

  @override
  Future<void> deleteTemplate(String collectionId, String templateId) async {
    final r = await softDelete(templateId, await _legacyCtx());
    if (r case Err(error: final e)) throw e;
  }
}
