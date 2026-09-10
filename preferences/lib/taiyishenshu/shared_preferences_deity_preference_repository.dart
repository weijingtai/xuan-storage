import 'dart:convert';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDeityPreferenceRepository
    implements DeityPreferenceRepository {
  static const String _key = 'taiyi_deity_preferences';
  final SharedPreferences prefs;

  SharedPreferencesDeityPreferenceRepository(this.prefs);

  @override
  Future<Result<bool?>> get(String id, RequestContext ctx) async {
    final enabled = await isEnabled(id);
    return Ok(enabled);
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final map = await loadEnabledMap();
    return Ok(map.containsKey(id));
  }

  @override
  Future<Result<Rev>> put(
    bool entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    return Ok(Rev(DateTime.now().millisecondsSinceEpoch.toString()));
  }

  // 本后端无事务能力，异常时不回滚已发生的写入
  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final r = await body();
      return Ok(r);
    } on XuanError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(XuanError(code: ErrorCode.internal, message: '$e'));
    }
  }

  Future<bool> isEnabled(String deityId) async {
    final Map<String, bool> map = await loadEnabledMap();
    return map[deityId] ?? true;
  }

  Future<void> setEnabled(String deityId, bool enabled) async {
    final Map<String, bool> map = await loadEnabledMap();
    map[deityId] = enabled;
    await prefs.setString(_key, jsonEncode(map));
  }

  Future<Map<String, bool>> loadEnabledMap() async {
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      return {};
    }
  }
}
