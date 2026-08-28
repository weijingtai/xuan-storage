/// XRAP 版 tiebanshenshu 领域 Repository（照 xrap_geo_location_repository.dart）。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [TiebanshenshuDatabase]，查询走 SQLite。
///
/// 实现 `repository-interface-tiebanshenshu` 的端口（consuming side）：
/// - [TiaoWenRepository]（tiebanshenshu.tiao_wen，11 方法，方案 A 完整 SQL 实现）
///
/// kao_ke / shaozishu / formulas 无 repository-interface 端口（人类裁定不擅自加接口），
/// 数据集已注册 + 落 drift 文档表，通过 [TiebanshenshuDocumentStore] 按文件名整取。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import 'drift/tiebanshenshu_database.dart';

/// 单个数据集安装的幂等守卫封装。
///
/// 首次调用走 ensureInstalled，之后空操作（照 geo/qizhengsiyu 的 _ensure 模式）。
class _DatasetEnsurer {
  _DatasetEnsurer(this._installer, this._datasetId);

  final DatasetInstaller _installer;
  final String _datasetId;
  bool _ensured = false;

  Future<void> ensure() async {
    if (_ensured) return;
    await _installer.ensureInstalled(_datasetId);
    _ensured = true;
  }
}

/// XRAP 版条文 Repository（方案 A：完整 SQL 查询实现 11 方法）。
///
/// 差分对照旧桩 `AssetsTiaoWenRepository`：
/// - getById / getByIdRange / getByIdList / getCount / listAll 走 SQL 主键/范围查询
/// - search 的 DiZhi 解析与旧桩一致（name == setNameStr || toString().contains）
/// - getByIntervalAroundId 交替搜索算法与旧桩一致（SQL 取行 + 内存筛选）
class XrapTiaoWenRepository implements TiaoWenRepository {
  XrapTiaoWenRepository({
    required this.db,
    required this.installer,
  }) : _ensure = _DatasetEnsurer(installer, 'tiebanshenshu.tiao_wen');

  final TiebanshenshuDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _ensure;

  TiaoWenDataModel _toModel(TiaoWenEntry row) {
    final ageSet1Json = row.ageSet1Json;
    return TiaoWenDataModel(
      id: row.id,
      setName: _parseDiZhi(row.setName),
      content1: row.content1,
      content2: null, // CSV 无 content2
      ageSet1: ageSet1Json == null
          ? null
          : (jsonDecode(ageSet1Json) as List<dynamic>).cast<int>(),
      ageSet2: null, // CSV 无 ageSet2
    );
  }

  /// 与旧桩 _parseCsvLine 的 DiZhi 解析一致：
  /// `DiZhi.values.firstWhere((d) => d.name == s || d.toString().contains(s))`。
  DiZhi _parseDiZhi(String setNameStr) {
    try {
      return DiZhi.values.firstWhere(
        (diZhi) =>
            diZhi.name == setNameStr || diZhi.toString().contains(setNameStr),
      );
    } catch (e) {
      throw FormatException('Unknown DiZhi: $setNameStr');
    }
  }

  @override
  Future<TiaoWenDataModel?> getById(int id) async {
    await _ensure.ensure();
    final row = await (db.select(db.tiaoWenEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  }) async {
    await _ensure.ensure();

    if (pageRange.length != 2) {
      throw ArgumentError(
        'pageRange must contain exactly 2 elements [startIndex, endIndex]',
      );
    }
    final int startIndex = pageRange[0];
    final int endIndex = pageRange[1];
    if (startIndex < 0 || endIndex < startIndex) {
      throw ArgumentError(
        'Invalid page range: startIndex must be >= 0 and endIndex must be >= startIndex',
      );
    }
    if (steps <= 0) {
      throw ArgumentError('steps must be greater than 0');
    }

    // 与旧桩一致：按索引范围 + 步长筛选 ID，再按筛选顺序取数。
    final List<int> filteredIds = [];
    for (int i = startIndex; i <= endIndex && i < ids.length; i += steps) {
      filteredIds.add(ids[i]);
    }
    if (filteredIds.isEmpty) return [];

    final rows = await _getByIdsInOrder(filteredIds);
    return rows;
  }

  @override
  Future<List<TiaoWenDataModel>> listAll() async {
    await _ensure.ensure();
    final rows = await (db.select(db.tiaoWenEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) async {
    await _ensure.ensure();

    // 与旧桩一致：先解析 setName 为 DiZhi（找不到返回空列表），
    // 再按 set_name 与 content1 模糊匹配。
    String? targetSetName;
    if (setName != null && setName.isNotEmpty) {
      try {
        final DiZhi targetDiZhi = _parseDiZhi(setName);
        targetSetName = targetDiZhi.name;
      } catch (e) {
        return [];
      }
    }

    final String? keyword = contentKeyword;
    final String setNameFilter = targetSetName ?? '';

    final query = db.select(db.tiaoWenEntries);
    if (setNameFilter.isNotEmpty) {
      query.where((t) => t.setName.equals(setNameFilter));
    }
    if (keyword != null && keyword.isNotEmpty) {
      query.where((t) => t.content1.contains(keyword));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.id)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<int> getCount() async {
    await _ensure.ensure();
    return db.tiaoWenEntries.count().getSingle();
  }

  @override
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  }) async {
    await _ensure.ensure();

    if (beforeCount < 0 || afterCount < 0) {
      throw ArgumentError('beforeCount and afterCount must be >= 0');
    }

    final int startId = centerId - beforeCount;
    final int endId = centerId + afterCount;
    final rows = await (db.select(db.tiaoWenEntries)
          ..where((t) => t.id.isBetweenValues(startId, endId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    final result = rows.map(_toModel).toList();
    if (!includeCenterItem) {
      result.removeWhere((t) => t.id == centerId);
    }
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  }) async {
    await _ensure.ensure();

    if (interval <= 0) {
      throw ArgumentError('interval must be > 0');
    }
    if (minCount <= 0) {
      throw ArgumentError('minCount must be > 0');
    }

    final List<TiaoWenDataModel> result = [];
    final Set<int> addedIds = <int>{};

    if (includeCenterItem) {
      final centerTiaoWen = await getById(centerId);
      if (centerTiaoWen != null) {
        result.add(centerTiaoWen);
        addedIds.add(centerId);
      }
    }

    final int searchRange = maxRange ?? 1000;
    int forwardStep = 1;
    int backwardStep = 1;

    while (result.length < minCount &&
        (forwardStep * interval <= searchRange ||
            backwardStep * interval <= searchRange)) {
      if (forwardStep * interval <= searchRange) {
        final int forwardId = centerId + (forwardStep * interval);
        if (!addedIds.contains(forwardId)) {
          final tiaoWen = await getById(forwardId);
          if (tiaoWen != null) {
            result.add(tiaoWen);
            addedIds.add(forwardId);
          }
        }
        forwardStep++;
      }

      if (result.length < minCount && backwardStep * interval <= searchRange) {
        final int backwardId = centerId - (backwardStep * interval);
        if (!addedIds.contains(backwardId)) {
          final tiaoWen = await getById(backwardId);
          if (tiaoWen != null) {
            result.add(tiaoWen);
            addedIds.add(backwardId);
          }
        }
        backwardStep++;
      }
    }

    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  }) async {
    await _ensure.ensure();

    if (startId > endId) {
      throw ArgumentError('startId must be <= endId');
    }

    final rows = await (db.select(db.tiaoWenEntries)
          ..where((t) => t.id.isBetweenValues(startId, endId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  }) async {
    await _ensure.ensure();

    if (queryList.isEmpty) {
      return [];
    }

    final List<TiaoWenDataModel> result = [];
    final List<int> notFoundIds = [];

    if (preserveOrder) {
      final map = await _getByIdMap(queryList);
      for (int id in queryList) {
        final tiaoWen = map[id];
        if (tiaoWen != null) {
          result.add(tiaoWen);
        } else {
          notFoundIds.add(id);
        }
      }
    } else {
      // 与旧桩一致：去重 + 按 ID 升序。
      final Set<int> uniqueIds = queryList.toSet();
      final List<int> sortedIds = uniqueIds.toList()..sort();
      final map = await _getByIdMap(sortedIds);
      for (int id in sortedIds) {
        final tiaoWen = map[id];
        if (tiaoWen != null) {
          result.add(tiaoWen);
        } else {
          notFoundIds.add(id);
        }
      }
    }

    if (!skipNotFound && notFoundIds.isNotEmpty) {
      throw ArgumentError(
        'The following IDs were not found: ${notFoundIds.join(', ')}',
      );
    }

    return result;
  }

  @override
  Future<Map<int, String>> getTiaoWenContentByNumbers(
      List<int> numbers) async {
    await _ensure.ensure();

    if (numbers.isEmpty) {
      return {};
    }

    final rows = await _getByIdMap(numbers);
    return {
      for (final e in rows.entries) e.key: e.value.content1,
    };
  }

  @override
  Future<String?> getTiaoWenContentByNumber(int number) async {
    await _ensure.ensure();

    final row = await (db.select(db.tiaoWenEntries)
          ..where((t) => t.id.equals(number)))
        .getSingleOrNull();
    return row?.content1;
  }

  /// 按给定 ID 顺序批量取数（保持输入顺序，跳过不存在的）。
  Future<List<TiaoWenDataModel>> _getByIdsInOrder(List<int> ids) async {
    final map = await _getByIdMap(ids);
    return [
      for (final id in ids)
        if (map[id] != null) map[id]!,
    ];
  }

  /// 按 ID 列表批量查询（返回 Map，保留存在的条目）。
  Future<Map<int, TiaoWenDataModel>> _getByIdMap(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (db.select(db.tiaoWenEntries)
          ..where((t) => t.id.isIn(ids)))
        .get();
    return {for (final r in rows) r.id: _toModel(r)};
  }

  @override
  Future<Result<TiaoWenDataModel?>> get(int id, RequestContext ctx) async {
    try {
      await _ensure.ensure();
      final row = await (db.select(db.tiaoWenEntries)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Ok(row != null ? _toModel(row) : null);
    } catch (_) {
      return const Ok(null);
    }
  }

  @override
  Future<Result<bool>> exists(int id, RequestContext ctx) async {
    final result = await get(id, ctx);
    return result.map((v) => v != null);
  }

  @override
  Future<Result<Page<TiaoWenDataModel>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    try {
      await _ensure.ensure();
      final query = db.select(db.tiaoWenEntries);
      final setName = spec['setName'] as String?;
      if (setName != null) {
        query.where((t) => t.setName.equals(setName));
      }
      final contentKeyword = spec['contentKeyword'] as String?;
      if (contentKeyword != null && contentKeyword.isNotEmpty) {
        query.where((t) => t.content1.like('%$contentKeyword%'));
      }
      final rows = await query.get();
      final items = rows.map((r) => _toModel(r)).toList();
      final paged = items.take(page.limit).toList();
      return Ok(Page(
        items: paged,
        nextCursor: paged.length < items.length ? 'cursor' : null,
      ));
    } catch (_) {
      return const Ok(Page(items: []));
    }
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final result = await query(spec, PageRequest(limit: 100000), ctx);
    return result.map((page) => page.items.length);
  }
}

/// 无端口数据集的通用文档表访问（kao_ke / shaozishu / formulas）。
///
/// 数据集已注册 + 落 drift 文档表，但 repository-interface-tiebanshenshu
/// 无对应端口（人类裁定不擅自加接口），故提供按文件名整取的通用读取类，
/// 消费方切换到 XRAP 链路时使用；待接口补全后再接入正式 Repository。
class TiebanshenshuDocumentStore {
  TiebanshenshuDocumentStore({
    required this.db,
    required this.installer,
  });

  final TiebanshenshuDatabase db;
  final DatasetInstaller installer;

  final _ensurers = <String, _DatasetEnsurer>{};

  _DatasetEnsurer _ensureFor(String datasetId) {
    return _ensurers.putIfAbsent(datasetId, () => _DatasetEnsurer(installer, datasetId));
  }

  /// 读取考课 JSON 文档（tiebanshenshu.kao_ke）。
  Future<String> loadKaoKe(String fileName) async {
    await _ensureFor('tiebanshenshu.kao_ke').ensure();
    final row = await (db.select(db.kaoKeDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw StorageError('考课资源不存在: $fileName');
    }
    return row.payloadJson;
  }

  /// 读取少子术 TXT 文档（tiebanshenshu.shaozishu）。
  Future<String> loadShaoZiShu(String fileName) async {
    await _ensureFor('tiebanshenshu.shaozishu').ensure();
    final row = await (db.select(db.shaoZiShuDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw StorageError('少子术资源不存在: $fileName');
    }
    return row.payloadText;
  }

  /// 读取皇极公式 JSON 文档（tiebanshenshu.formulas）。
  Future<String> loadFormula(String fileName) async {
    await _ensureFor('tiebanshenshu.formulas').ensure();
    final row = await (db.select(db.formulaDocuments)
          ..where((t) => t.fileName.equals(fileName)))
        .getSingleOrNull();
    if (row == null) {
      throw StorageError('公式资源不存在: $fileName');
    }
    return row.payloadJson;
  }
}
