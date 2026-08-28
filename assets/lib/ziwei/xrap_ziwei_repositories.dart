/// XRAP 版 ziwei 领域 Repository（照 xrap_taiyishenshu_repositories.dart）。
///
/// 走 XRAP 协议 + drift 持久化：数据是预构建的 *.sql，启动时由
/// [DatasetInstaller.ensureInstalled] 灌进 [ZiweiDatabase]，查询走 SQLite。
///
/// 实现 `repository-interface-ziweidoushu` 的端口（consuming side）：
/// - [ZiweiStarRepository]（ziwei.star_catalog + ziwei.star_metadata
///   + ziwei.four_transformations）
///
/// 契约模型为手写 Equatable（无 fromJson），本实现直接读文档表
/// payload_json 再手写映射 JSON 字段到契约枚举/模型，
/// 保持 storage 包零模型耦合（不依赖 `package:ziwei`）。
library;

import 'dart:convert';

import 'package:persistence_core/persistence_core.dart' hide StorageError, XuanError;
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';

import 'drift/ziwei_database.dart';

/// 单个数据集安装的幂等守卫封装。
///
/// 首次调用走 ensureInstalled，之后空操作（照 geo/qizhengsiyu/daliuren/taiyishenshu
/// 的 _ensure 模式）。
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

/// 天干字表（tianGanIndex 0=甲 … 9=癸，契约约定）。
const _kTianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

/// 四化类型映射（JSON 键 -> 契约枚举）。
const _kTransformationTypeMap = <String, TransformationType>{
  '化禄': TransformationType.lu,
  '化权': TransformationType.quan,
  '化科': TransformationType.ke,
  '化忌': TransformationType.ji,
};

/// JSON category -> 契约 [StarCategory]。
StarCategory _categoryOf(String category) {
  switch (category) {
    case 'main':
      return StarCategory.mainStar;
    case 'minor_auspicious':
    case 'baleful':
      return StarCategory.auxiliaryStar;
    default:
      return StarCategory.miscellaneousStar;
  }
}

/// JSON five_elements（中文五行）-> 契约 [StarElement]。
StarElement? _elementOf(String? fiveElements) {
  switch (fiveElements) {
    case '金':
      return StarElement.metal;
    case '木':
      return StarElement.wood;
    case '水':
      return StarElement.water;
    case '火':
      return StarElement.fire;
    case '土':
      return StarElement.earth;
    default:
      return null;
  }
}

/// JSON yin_yang（阴/阳）-> 契约 [StarYinYang]。
StarYinYang? _yinYangOf(String? yinYang) {
  switch (yinYang) {
    case '阴':
      return StarYinYang.yin;
    case '阳':
      return StarYinYang.yang;
    default:
      return null;
  }
}

/// 单个星 JSON -> 契约 [ZiweiStar]。
///
/// 契约 [ZiweiStar.brightness] 为单值 String?，源数据 brightness_map 是
/// 2D 表（星曜×十二地支），无单值源（D4 裁定），保持 null。
ZiweiStar _mapStar(Map<String, dynamic> json) {
  return ZiweiStar(
    name: json['name'] as String,
    category: _categoryOf(json['category'] as String),
    element: _elementOf(json['five_elements'] as String?),
    yinYang: _yinYangOf(json['yin_yang'] as String?),
    brightness: null,
  );
}

/// XRAP 版星曜数据 Repository（ziwei.star_catalog / star_metadata / four_transformations）。
class XrapZiweiStarRepository implements ZiweiStarRepository {
  XrapZiweiStarRepository({
    required this.db,
    required this.installer,
  })  : _catalogEnsure = _DatasetEnsurer(installer, 'ziwei.star_catalog'),
        _metadataEnsure = _DatasetEnsurer(installer, 'ziwei.star_metadata'),
        _fourTransEnsure =
            _DatasetEnsurer(installer, 'ziwei.four_transformations');

  final ZiweiDatabase db;
  final DatasetInstaller installer;
  final _DatasetEnsurer _catalogEnsure;
  final _DatasetEnsurer _metadataEnsure;
  final _DatasetEnsurer _fourTransEnsure;

  /// stars.csv 原文（文档表 payload_json，逐字节等于源 CSV）。
  ///
  /// 供 shell 保持 `ziweiStarCatalogCsv: String` 接口（StarCatalog.parse 消费）。
  Future<String> loadStarCatalogCsv() async {
    await _catalogEnsure.ensure();
    final row = await (db.select(db.ziweiStarCatalogDocuments)
          ..where((t) => t.fileName.equals('stars.csv')))
        .getSingleOrNull();
    if (row == null) {
      throw const ZiweiRepositoryError(
        code: ZiweiErrorCode.starNotFound,
        message: 'stars.csv 未安装（ziwei.star_catalog）',
      );
    }
    return row.payloadJson;
  }

  /// 全部星（main + minor 两行文档表合并）。
  Future<List<Map<String, dynamic>>> _allStarJson() async {
    await _metadataEnsure.ensure();
    final rows = await db.select(db.ziweiStarMetadataDocuments).get();
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      final stars = json['stars'] as List<dynamic>;
      for (final star in stars) {
        result.add(star as Map<String, dynamic>);
      }
    }
    return result;
  }

  // ── Readable ──

  @override
  Future<Result<ZiweiStar?>> get(String name, RequestContext ctx) async {
    try {
      final stars = await _allStarJson();
      for (final s in stars) {
        if (s['name'] == name) return Ok(_mapStar(s));
      }
      return const Ok(null);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '$e'));
    }
  }

  @override
  Future<Result<bool>> exists(String name, RequestContext ctx) async {
    final stars = await _allStarJson();
    return Ok(stars.any((s) => s['name'] == name));
  }

  // ── Queryable ──

  @override
  Future<Result<Page<ZiweiStar>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    try {
      final all = await _queryAll(spec);
      final start = 0;
      final end = page.limit.clamp(0, all.length);
      final items = all.sublist(start, end);
      final hasMore = all.length > page.limit;
      return Ok(Page(
        items: items,
        nextCursor: hasMore ? 'offset:${page.limit}' : null,
      ));
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '$e'));
    }
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    try {
      final all = await _queryAll(spec);
      return Ok(all.length);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '$e'));
    }
  }

  /// 按 spec 条件查询全量星曜（内部辅助）。
  Future<List<ZiweiStar>> _queryAll(Map<String, Object?> spec) async {
    final stars = await _allStarJson();
    final type = spec['type'] as String?;
    if (type == 'main') {
      return stars
          .where((s) => s['category'] == 'main')
          .map(_mapStar)
          .toList(growable: false);
    } else if (type == 'auxiliary') {
      return stars
          .where((s) =>
              s['category'] == 'minor_auspicious' || s['category'] == 'baleful')
          .map(_mapStar)
          .toList(growable: false);
    } else if (type == 'si_hua') {
      final tianGanIndex = spec['tian_gan'] as int?;
      if (tianGanIndex == null) return [];
      return _queryFourTransformations(tianGanIndex);
    }
    return stars.map(_mapStar).toList(growable: false);
  }

  Future<List<ZiweiFourTransformations>> _queryFourTransformations(
    int tianGanIndex,
  ) async {
    if (tianGanIndex < 0 || tianGanIndex >= _kTianGan.length) return [];
    await _fourTransEnsure.ensure();
    final row = await (db.select(db.ziweiFourTransformationsDocuments)
          ..where((t) => t.fileName.equals('ziwei_four_transformations.json')))
        .getSingleOrNull();
    if (row == null) return [];

    final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final schools = json['schools'] as Map<String, dynamic>;
    final sanhe = schools['sanhe'] as Map<String, dynamic>;
    final table = sanhe['table'] as Map<String, dynamic>;
    final ganEntry = table[_kTianGan[tianGanIndex]] as Map<String, dynamic>;

    final entries = <FourTransformationEntry>[];
    for (final MapEntry(key: key, value: value) in ganEntry.entries) {
      final type = _kTransformationTypeMap[key];
      if (type == null) continue;
      entries.add(FourTransformationEntry(
        starName: value as String,
        type: type,
      ));
    }
    return [ZiweiFourTransformations(
      tianGanIndex: tianGanIndex,
      entries: List.unmodifiable(entries),
    )];
  }
}
