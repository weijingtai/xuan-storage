import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';

class SharedPreferencesMeiHuaPreferenceRepository
    implements MeiHuaPreferenceRepository {
  static const String _key = 'meihua_preferences';
  final SharedPreferences prefs;

  SharedPreferencesMeiHuaPreferenceRepository(this.prefs);

  @override
  Future<int> loadLongTextThreshold() async {
    final res = await get('', RequestContext(scopeUid: 'system'));
    return switch (res) {
      Ok(:final value) => value ?? 10,
      Err() => 10,
    };
  }

  @override
  Future<void> saveLongTextThreshold(int value) async {
    await put(value, RequestContext(scopeUid: 'system'));
  }

  @override
  Future<Result<int?>> get(String id, RequestContext ctx) async {
    final Map<String, dynamic> map = await _loadMap();
    final value = map['long_text_threshold'] as int?;
    return Ok(value);
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final Map<String, dynamic> map = await _loadMap();
    return Ok(map.containsKey('long_text_threshold'));
  }

  @override
  Future<Result<Rev>> put(
    int entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    final Map<String, dynamic> map = await _loadMap();
    map['long_text_threshold'] = entity;
    await prefs.setString(_key, jsonEncode(map));
    return const Ok(Rev('0'));
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final result = await body();
      return Ok(result);
    } catch (e) {
      return Err(XuanError(
        code: ErrorCode.internal,
        message: 'Transaction failed: $e',
      ));
    }
  }

  Future<Map<String, dynamic>> _loadMap() async {
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
