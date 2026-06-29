import 'package:repository_interface_record/repository_interface_record.dart';
import '../meihuayishu/meihua_module_registry.dart';
import '../liuyao/liuyao_module_registry.dart';
import '../qizhengsiyu/qizheng_module_registry.dart';
import '../daliuren/daliuren_module_registry.dart';
import '../qimendunjia/qimendunjia_module_registry.dart';
import '../taiyishenshu/taiyishenshu_module_registry.dart';
import '../tiebanshenshu/tiebanshenshu_module_registry.dart';
import '../ziweidoushu/ziweidoushu_module_registry.dart';

/// 中央记录模块注册表 — 聚合全部 8 个占测模块。
class RecordModuleRegistry {
  /// 返回全部 8 个模块的 SearchTagExtractor 提取器。
  static List<RecordSearchTagExtractor> allExtractors() {
    return [
      MeiHuaModuleRegistry.codec(scopeUid: ''),
      LiuYaoModuleRegistry.codec(),
      QiZhengModuleRegistry.codec(),
      DaliurenModuleRegistry.codec(),
      QimendunjiaModuleRegistry.codec(),
      TaiyishenshuModuleRegistry.codec(),
      TiebanshenshuModuleRegistry.codec(),
      ZiweidoushuModuleRegistry.codec(),
    ];
  }

  /// 根据模块标识动态生产对应 Repository。
  static Object repositoryFor({
    required String module,
    required ScopedRecordStore store,
    String? scopeUid,
  }) {
    switch (module) {
      case 'meihua':
        return MeiHuaModuleRegistry.repository(store: store, scopeUid: scopeUid ?? store.scopeUid);
      case 'liuyao':
        return LiuYaoModuleRegistry.repository(store: store);
      case 'qizhengsiyu':
        return QiZhengModuleRegistry.repository(store: store);
      case 'daliuren':
        return DaliurenModuleRegistry.repository(store: store);
      case 'qimendunjia':
        return QimendunjiaModuleRegistry.repository(store: store);
      case 'taiyishenshu':
        return TaiyishenshuModuleRegistry.repository(store: store);
      case 'tiebanshenshu':
        return TiebanshenshuModuleRegistry.repository(store: store);
      case 'ziweidoushu':
        return ZiweidoushuModuleRegistry.repository(store: store);
      default:
        throw ArgumentError('Unknown module: $module');
    }
  }
}
