import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:repository_interface_yanqinshu/repository_interface_yanqinshu.dart';

class AssetsYanqinshuSchoolDataRepository implements YanqinshuSchoolDataRepository {
  const AssetsYanqinshuSchoolDataRepository();

  static const String _prefix = 'packages/persistence_assets/lib/yanqinshu/assets/dataset/schools/';

  @override
  Future<List<YanqinshuSchoolEntryContract>> schoolCatalog() async {
    // Return known catalog entries
    final yantongzuanMeta = await loadMeta('yantongzuan');
    final List<YanqinshuSchoolEntryContract> list = [];

    if (yantongzuanMeta != null) {
      final json = jsonDecode(yantongzuanMeta) as Map<String, dynamic>;
      list.add(YanqinshuSchoolEntryContract.fromJson(json));
    }

    return list;
  }

  @override
  Future<String?> loadRuleTables(String schoolId) async {
    try {
      return await rootBundle.loadString('$_prefix$schoolId/rule_tables.json');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> loadConclusions(String schoolId) async {
    try {
      return await rootBundle.loadString('$_prefix$schoolId/conclusions.json');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> loadMeta(String schoolId) async {
    try {
      return await rootBundle.loadString('$_prefix$schoolId/meta.json');
    } catch (_) {
      return null;
    }
  }
}
