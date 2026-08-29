import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 本文件保留仅为消费方（xuan-shell）切换过渡期兼容，
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRen*）。新代码不得引用本文件。
@Deprecated('用 XrapDaLiuRenOfficialDataRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenOfficialDataRepository
    implements DaLiuRenOfficialDataRepository {
  const AssetsDaLiuRenOfficialDataRepository();

  static const String _prefix = 'packages/daliuren/assets/da_liu_ren/';

  @override
  Future<Result<dynamic>> get(String id, RequestContext ctx) async {
    try {
      switch (id) {
        case 'yuding':
          final raw = await rootBundle.loadString('${_prefix}御定大六壬.json');
          return Ok(json.decode(raw) as List<dynamic>);
        case 'jumapper':
          final raw = await rootBundle.loadString('${_prefix}ju_mapper.json');
          return Ok(json.decode(raw) as Map<String, dynamic>);
        case 'yangpan':
          final raw = await rootBundle.loadString('${_prefix}甲午庚牛羊_阳.json');
          final list = json.decode(raw) as List<dynamic>;
          return Ok(list.cast<Map<String, dynamic>>());
        case 'yinpan':
          final raw = await rootBundle.loadString('${_prefix}甲午庚牛羊_阴.json');
          final list = json.decode(raw) as List<dynamic>;
          return Ok(list.cast<Map<String, dynamic>>());
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
  Future<Result<Page<dynamic>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final type = spec['type'] as String? ?? 'yuding';
    final result = await get(type, ctx);
    return result.map((v) {
      final list = v as List<dynamic>? ?? [];
      final paged = list.take(page.limit).toList();
      return Page(
        items: paged,
        nextCursor: paged.length < list.length ? 'cursor' : null,
      );
    });
  }

  @override
  Future<List<dynamic>> loadYuDingData() async {
    final res = await get('yuding', RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => (value as List<dynamic>?) ?? [],
      Err() => [],
    };
  }

  @override
  Future<Map<String, dynamic>> loadJuMapperData() async {
    final res = await get('jumapper', RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => (value as Map<String, dynamic>?) ?? {},
      Err() => {},
    };
  }

  @override
  Future<List<Map<String, dynamic>>> loadYangPanData() async {
    final res = await get('yangpan', RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => (value as List<Map<String, dynamic>>?) ?? [],
      Err() => [],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> loadYinPanData() async {
    final res = await get('yinpan', RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => (value as List<Map<String, dynamic>>?) ?? [],
      Err() => [],
    };
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final type = spec['type'] as String? ?? 'yuding';
    final result = await get(type, ctx);
    return result.map((v) => (v as List<dynamic>?)?.length ?? 0);
  }
}

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRenKetiRepository）。
@Deprecated('用 XrapDaLiuRenKetiRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenKetiRepository implements DaLiuRenKetiRepository {
  const AssetsDaLiuRenKetiRepository();

  static const String _prefix = 'packages/daliuren/assets/da_liu_ren/';

  @override
  Future<List<dynamic>> loadKetiData() async {
    final res = await get('', RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => (value as List<dynamic>?) ?? [],
      Err() => [],
    };
  }

  @override
  Future<Result<dynamic>> get(String id, RequestContext ctx) async {
    try {
      final raw = await rootBundle.loadString('${_prefix}keti_data.json');
      return Ok(json.decode(raw));
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
  Future<Result<Page<dynamic>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final result = await get('', ctx);
    return result.map((v) {
      final list = v as List<dynamic>? ?? [];
      final paged = list.take(page.limit).toList();
      return Page(
        items: paged,
        nextCursor: paged.length < list.length ? 'cursor' : null,
      );
    });
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final result = await get('', ctx);
    return result.map((v) => (v as List<dynamic>?)?.length ?? 0);
  }
}

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRenShenShaDataRepository）。
@Deprecated('用 XrapDaLiuRenShenShaDataRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenShenShaDataRepository
    implements DaLiuRenShenShaDataRepository {
  const AssetsDaLiuRenShenShaDataRepository();

  static const String _prefix = 'packages/daliuren/assets/shen_sha/';

  Future<List<dynamic>> loadGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_gan.json');

  Future<List<dynamic>> loadYearShenShaRaw() async =>
      _load('${_prefix}6_shensha_year.json');

  Future<List<dynamic>> loadMonthShenShaRaw() async =>
      _load('${_prefix}6_shensha_month.json');

  Future<List<dynamic>> loadZhiShenShaRaw() async =>
      _load('${_prefix}6_shensha_zhi.json');

  Future<List<dynamic>> loadJiShenShaRaw() async =>
      _load('${_prefix}6_shensha_ji.json');

  Future<List<dynamic>> loadXunShenShaRaw() async =>
      _load('${_prefix}6_shensha_xun.json');

  Future<List<dynamic>> loadYearGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_year_gan.json');

  Future<List<dynamic>> loadMonthGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_month_gan.json');

  Future<List<dynamic>> loadMonthZhiGanShenShaRaw() async =>
      _load('${_prefix}6_shensha_month_zhi_gan.json');

  @override
  Future<Result<dynamic>> get(String id, RequestContext ctx) async {
    try {
      final raw = await rootBundle.loadString('${_prefix}$id.json');
      return Ok(json.decode(raw));
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
  Future<Result<Page<dynamic>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final result = await get('', ctx);
    return result.map((v) {
      final list = v as List<dynamic>? ?? [];
      final paged = list.take(page.limit).toList();
      return Page(
        items: paged,
        nextCursor: paged.length < list.length ? 'cursor' : null,
      );
    });
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final result = await get('', ctx);
    return result.map((v) => (v as List<dynamic>?)?.length ?? 0);
  }

  Future<List<dynamic>> _load(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      return json.decode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }
}

/// ⚠️ 旧实现（deprecated）：直接 rootBundle 直读 asset JSON，不走 XRAP。
///
/// 大六壬数据资源已迁入 persistence_assets 并按 XRAP 协议注册
/// （见 `daliuren_datasets.dart` + `xrap_daliuren_repositories.dart`）。
/// 消费方应改用 XRAP 版 Repository（XrapDaLiuRenSchoolDataRepository）。
@Deprecated('用 XrapDaLiuRenSchoolDataRepository（XRAP 协议链路）替代，见 daliuren_datasets.dart')
class AssetsDaLiuRenSchoolDataRepository
    implements DaLiuRenSchoolDataRepository {
  const AssetsDaLiuRenSchoolDataRepository();

  @override
  Future<List<SchoolEntryContract>> loadEntries(String schoolId) async {
    final res = await query({'schoolId': schoolId}, PageRequest(limit: 10000), RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => value.items,
      Err() => const [],
    };
  }

  @override
  Future<Result<SchoolEntryContract?>> get(String id, RequestContext ctx) async {
    try {
      final raw = await rootBundle.loadString(
        'packages/daliuren/assets/dataset/daliuren_dataset.json',
      );
      final list = json.decode(raw) as List<dynamic>;
      for (final e in list) {
        final entry = _parseEntry(e as Map<String, dynamic>);
        if (entry.schoolId == id) return Ok(entry);
      }
      return const Ok(null);
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
  Future<Result<Page<SchoolEntryContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    try {
      final raw = await rootBundle.loadString(
        'packages/daliuren/assets/dataset/daliuren_dataset.json',
      );
      final list = json.decode(raw) as List<dynamic>;
      final items = list
          .map((e) => _parseEntry(e as Map<String, dynamic>))
          .toList();
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
    try {
      final raw = await rootBundle.loadString(
        'packages/daliuren/assets/dataset/daliuren_dataset.json',
      );
      final list = json.decode(raw) as List<dynamic>;
      return Ok(list.length);
    } catch (_) {
      return const Ok(0);
    }
  }

  SchoolEntryContract _parseEntry(Map<String, dynamic> json) {
    return SchoolEntryContract(
      schoolId: json['schoolId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dayJiaZi: json['dayJiaZi'] as String? ?? '',
      juName: json['juName'] as String? ?? '',
      juNumber: json['juNumber'] as int? ?? 0,
      keTiNames: (json['keTiNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      meaning: json['meaning'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      prediction: json['prediction'] as String? ?? '',
      details: (json['details'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      bookReferences: (json['bookReferences'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
    );
  }
}
