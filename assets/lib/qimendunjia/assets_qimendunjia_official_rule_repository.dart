import 'package:flutter/services.dart' show rootBundle;
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';

/// Asset-backed implementation of [QimendunjiaOfficialRuleRepository].
///
/// Reads the official immutable rule JSON shipped inside the `qimendunjia`
/// product package's asset bundle. Read-only; no migration, no sync.
///
/// Asset keys are prefixed with `packages/qimendunjia/` because the JSON files
/// are declared as assets of the `qimendunjia` package (see its pubspec
/// `flutter: assets:`), so they resolve under the package asset namespace when
/// loaded by the host app.
class AssetsQimendunjiaOfficialRuleRepository
    implements QimendunjiaOfficialRuleRepository {
  const AssetsQimendunjiaOfficialRuleRepository();

  static const String _tenGanKeYingPath =
      'packages/qimendunjia/assets/qi_men_dun_jia/ten_gan_ke_ying_v1.json';
  static const String _tenGanKeYingGeJuPath =
      'packages/qimendunjia/assets/qi_men_dun_jia/ten_gan_ke_ying_final.json';
  static const String _doorGanKeYingPath =
      'packages/qimendunjia/assets/qi_men_dun_jia/door_gan_ke_ying.json';
  static const String _officialJuRulesPath =
      'packages/qimendunjia/assets/qi_men_dun_jia/official_ju_rules.json';

  Future<String> _load(String assetKey) async {
    try {
      return await rootBundle.loadString(assetKey);
    } catch (e) {
      throw StorageError('Failed to load asset "$assetKey": $e');
    }
  }

  @override
  Future<Result<String?>> get(String key, RequestContext ctx) async {
    try {
      switch (key) {
        case 'ten_gan_ke_ying':
          return Ok(await _load(_tenGanKeYingPath));
        case 'ten_gan_ge_ju':
          return Ok(await _load(_tenGanKeYingGeJuPath));
        case 'door_gan_ke_ying':
          return Ok(await _load(_doorGanKeYingPath));
        case 'official_ju_rules':
          return Ok(await _load(_officialJuRulesPath));
        default:
          return const Ok(null);
      }
    } catch (_) {
      return const Ok(null);
    }
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final result = await get(id, ctx);
    return result.map((v) => v != null);
  }

  @override
  Future<Result<Page<String>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final key = spec['key'] as String? ?? 'ten_gan_ke_ying';
    final result = await get(key, ctx);
    return result.map((v) {
      final items = v != null ? [v] : <String>[];
      return Page(items: items);
    });
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final result = await query(spec, PageRequest(limit: 100), ctx);
    return result.map((page) => page.items.length);
  }
}
