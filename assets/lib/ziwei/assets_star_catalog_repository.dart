import 'package:flutter/services.dart' show rootBundle;

/// 紫微斗数星表只读资产仓库。
///
/// 从 Flutter AssetBundle 加载 `stars.csv`，返回原始 CSV 内容。
/// 解析为 [StarCatalog] 由上层（shell / ziwei 模块）负责。
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
