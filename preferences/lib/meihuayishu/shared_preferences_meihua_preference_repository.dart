import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';

class SharedPreferencesMeiHuaPreferenceRepository implements MeiHuaPreferenceRepository {
  static const String _key = 'meihua_preferences';
  final SharedPreferences prefs;

  SharedPreferencesMeiHuaPreferenceRepository(this.prefs);

  @override
  Future<int> loadLongTextThreshold() async {
    final Map<String, dynamic> map = await _loadMap();
    return map['long_text_threshold'] as int? ?? 10;
  }

  @override
  Future<void> saveLongTextThreshold(int value) async {
    final Map<String, dynamic> map = await _loadMap();
    map['long_text_threshold'] = value;
    await prefs.setString(_key, jsonEncode(map));
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
