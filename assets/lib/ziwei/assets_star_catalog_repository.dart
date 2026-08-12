import 'package:flutter/services.dart' show rootBundle;

/// 紫微斗数星表只读资产仓库（**已废弃**，过渡保留）。
///
/// @Deprecated：ziwei 资源已迁入 xuan-storage（M4，2026-08-11），
/// 本类默认路径 `packages/ziwei/assets/stars.csv` 在源仓已删文件后失效。
/// 新链路用 [XrapZiweiStarRepository.loadStarCatalogCsv]（读
/// `ziwei.star_catalog` 文档表，payload_json 为 CSV 原文，逐字节相等）。
///
/// 从 Flutter AssetBundle 加载 `stars.csv`，返回原始 CSV 内容。
/// 解析为 [StarCatalog] 由上层（shell / ziwei 模块）负责。
@Deprecated('ziwei 资源已迁移 xuan-storage，改用 XrapZiweiStarRepository')
class AssetsStarCatalogRepository {
  final String _assetPath;

  const AssetsStarCatalogRepository({
    String assetPath = 'packages/ziwei/assets/stars.csv',
  }) : _assetPath = assetPath;

  /// 加载星表 CSV 原始内容。
  Future<String> loadStarCatalogCsv() async {
    try {
      return await rootBundle.loadString(_assetPath);
    } catch (e) {
      throw Exception('Failed to load star catalog from $_assetPath: $e');
    }
  }
}
