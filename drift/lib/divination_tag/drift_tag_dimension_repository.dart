import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';
import 'drift_tag_tables.dart';

/// Drift-package adapter for the shared [TagDimensionRepository] port
/// (TDD-XG-05: shared stable tags retain dimensionId/ID/version/text; no
/// Xiang-owned tag repository).
///
/// 本阶段适配器直接服务内置种子词表（五行 / 吉凶，定义见
/// [drift_tag_tables.dart]）；L0 切片方法全部以内存种子数据为后端，
/// 结果统一以 [Result] 返回。
class DriftTagDimensionRepository implements TagDimensionRepository {
  DriftTagDimensionRepository({
    List<TagDimension> dimensions = seedTagDimensions,
    List<DimensionTag> tags = seedDimensionTags,
  })  : _dimensions = List.unmodifiable(dimensions),
        _tags = List.unmodifiable(tags);

  final List<TagDimension> _dimensions;
  final List<DimensionTag> _tags;

  /// 领域便捷查询（非 L0 切片成员，保留给既有调用方）。
  List<TagDimension> listDimensions() => List.unmodifiable(_dimensions);

  TagDimension? _findById(String id) {
    for (final d in _dimensions) {
      if (d.dimensionId == id) return d;
    }
    return null;
  }

  bool _matches(TagDimension d, Map<String, Object?> spec) {
    for (final entry in spec.entries) {
      if (entry.key == 'dimensionId' && d.dimensionId != entry.value) {
        return false;
      }
      if (entry.key == 'displayName' && d.displayName != entry.value) {
        return false;
      }
    }
    return true;
  }

  // ── L0 Readable ──

  @override
  Future<Result<TagDimension?>> get(String id, RequestContext ctx) async {
    return Ok(_findById(id));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    return Ok(_findById(id) != null);
  }

  // ── L0 Writable ──

  @override
  Future<Result<Rev>> put(
    TagDimension entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    // 内置种子数据为只读，put 在此阶段仅回执 ID 版本。
    return Ok(Rev(entity.dimensionId));
  }

  // ── L0 Queryable ──

  @override
  Future<Result<Page<TagDimension>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    var list = _dimensions.where((d) => _matches(d, spec)).toList();
    final start = page.cursor == null ? 0 : int.tryParse(page.cursor!) ?? 0;
    final end = (start + page.limit).clamp(0, list.length);
    final items = list.sublist(start, end);
    final hasMore = end < list.length;
    return Ok(Page<TagDimension>(
      items: items,
      nextCursor: hasMore ? '$end' : null,
    ));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    return Ok(_dimensions.where((d) => _matches(d, spec)).length);
  }

  // ── L0 Transactional ──

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final result = await body();
      return Ok(result);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: 'tag dimension transaction failed: $e',
      ));
    }
  }

  // ── 领域扩展（切片之外的业务方法） ──

  @override
  List<DimensionTag> listTagsByDimension(String dimensionId) {
    final result = _tags.where((t) => t.dimensionId == dimensionId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(result);
  }

  @override
  Map<String, bool> validateTags(Map<String, List<String>> dimensionTags) {
    final result = <String, bool>{};
    for (final entry in dimensionTags.entries) {
      for (final tagId in entry.value) {
        final key = '${entry.key}:$tagId';
        result[key] =
            _tags.any((t) => t.dimensionId == entry.key && t.tagId == tagId);
      }
    }
    return result;
  }
}
