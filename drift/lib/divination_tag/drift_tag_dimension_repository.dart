import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';
import 'drift_tag_tables.dart';

/// Drift-package adapter for the shared [TagDimensionRepository] port
/// (TDD-XG-05: shared stable tags retain dimensionId/ID/version/text; no
/// Xiang-owned tag repository).
///
/// The port is synchronous, so this phase-one adapter serves the built-in
/// seed vocabulary (五行 / 吉凶, defined next to the Drift tables in
/// [drift_tag_tables.dart]) directly; the Drift table schemas are the future
/// persistence home for the same vocabulary.
class DriftTagDimensionRepository implements TagDimensionRepository {
  DriftTagDimensionRepository({
    List<TagDimension> dimensions = seedTagDimensions,
    List<DimensionTag> tags = seedDimensionTags,
  })  : _dimensions = List.unmodifiable(dimensions),
        _tags = List.unmodifiable(tags);

  final List<TagDimension> _dimensions;
  final List<DimensionTag> _tags;

  @override
  List<TagDimension> listDimensions() => List.unmodifiable(_dimensions);

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

  @override
  Future<TagDimension?> get(String id) async {
    try {
      return _dimensions.firstWhere((d) => d.dimensionId == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> exists(String id) async {
    return _dimensions.any((d) => d.dimensionId == id);
  }

  @override
  Future<String> put(TagDimension entity) async {
    // 内置种子数据为只读，put 在此阶段仅返回 ID
    return entity.dimensionId;
  }

  @override
  Future<List<TagDimension>> query([Map<String, Object?>? criteria]) async {
    if (criteria == null || criteria.isEmpty) {
      return List.unmodifiable(_dimensions);
    }
    return _dimensions.where((d) {
      for (final entry in criteria.entries) {
        if (entry.key == 'dimensionId' && d.dimensionId != entry.value) {
          return false;
        }
        if (entry.key == 'displayName' && d.displayName != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<int> count([Map<String, Object?>? criteria]) async {
    final list = await query(criteria);
    return list.length;
  }

  @override
  Future<bool> delete(String id) async {
    // 内置种子数据为只读，delete 在此阶段不生效
    return false;
  }

  @override
  Future<R> inTransaction<R>(Future<R> Function() action) async {
    return action();
  }
}
