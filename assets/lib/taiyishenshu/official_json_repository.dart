import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart' show TaiYiSchool, DeityDefinition;
import 'official_json_mapper.dart';

class OfficialJsonSchoolRepository implements SchoolRepository {
  final List<String> schoolIds;
  final List<String> deityIds;
  final AssetBundle bundle;

  OfficialJsonSchoolRepository({
    required this.schoolIds,
    required this.deityIds,
    AssetBundle? bundle,
  }) : bundle = bundle ?? rootBundle;

  final Map<String, TaiYiSchool> _schools = {};
  final Map<String, DeityDefinition> _deities = {};
  bool _loaded = false;

  String _toKebabCase(String input) {
    // Manual overrides for specific IDs if any (none needed yet as regex covers verified assets)
    final result = input.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (Match m) => '${m.group(1)}-${m.group(2)!.toLowerCase()}',
    ).toLowerCase();
    return result;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    for (final id in schoolIds) {
      final filename = _toKebabCase(id);
      final path = 'packages/taiyishenshu/assets/schools/$filename.json';
      try {
        final jsonStr = await bundle.loadString(path);
        final json = jsonDecode(jsonStr);
        _schools[id] = TaiYiSchool.fromJson(json);
      } catch (e) {
        debugPrint('Warning: school asset not found for ID "$id" at path: $path');
      }
    }

    for (final id in deityIds) {
      final filename = _toKebabCase(id);
      final path = 'packages/taiyishenshu/assets/deities/$filename.json';
      try {
        final jsonStr = await bundle.loadString(path);
        final json = jsonDecode(jsonStr);
        _deities[id] = DeityDefinition.fromJson(json);
      } catch (e) {
        debugPrint('Warning: deity asset not found for ID "$id" at path: $path');
      }
    }

    _loaded = true;
  }


  @override
  Future<List<TaiYiSchoolContract>> loadAllSchools() async {
    await _ensureLoaded();
    return _schools.values.map((s) => s.toContract()).toList();
  }

  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async {
    await _ensureLoaded();
    return _schools[id]?.toContract();
  }

  @override
  Future<List<DeityDefinitionContract>> loadAllDeities() async {
    await _ensureLoaded();
    return _deities.values.map((d) => d.toContract()).toList();
  }

  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    await _ensureLoaded();
    return _deities[id]?.toContract();
  }

  @override
  Future<void> saveSchool(TaiYiSchoolContract school) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> saveDeity(DeityDefinitionContract deity) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteSchool(String id) =>
      throw UnsupportedError('Official repository is read-only');

  @override
  Future<void> deleteDeity(String id) =>
      throw UnsupportedError('Official repository is read-only');
}
