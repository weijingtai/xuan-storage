import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';

class SharedPreferencesBaziCaseRepository implements BaziCaseRepository {
  static const String _key = 'bazi_cases';
  final SharedPreferences prefs;

  SharedPreferencesBaziCaseRepository(this.prefs);

  Future<Map<String, dynamic>> _loadMap() async {
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return {};
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

  Future<void> _saveMap(Map<String, dynamic> map) async {
    await prefs.setString(_key, jsonEncode(map));
  }

  BaziCaseContract _fromJson(Map<String, dynamic> json) {
    return BaziCaseContract(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      mainQuestion: json['mainQuestion'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthLocationJson: json['birthLocationJson'] as String?,
      gender: json['gender'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      finalSummary: json['finalSummary'] as String?,
    );
  }

  Map<String, dynamic> _toJson(BaziCaseContract c) {
    return {
      'uuid': c.uuid,
      'title': c.title,
      'mainQuestion': c.mainQuestion,
      'birthDate': c.birthDate.toIso8601String(),
      'birthLocationJson': c.birthLocationJson,
      'gender': c.gender,
      'createdAt': c.createdAt.toIso8601String(),
      'updatedAt': c.updatedAt.toIso8601String(),
      'deletedAt': c.deletedAt?.toIso8601String(),
      'finalSummary': c.finalSummary,
    };
  }

  @override
  Future<BaziCaseContract?> getCase(String uuid) async {
    final map = await _loadMap();
    if (map.containsKey(uuid)) {
      return _fromJson(map[uuid] as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<List<BaziCaseContract>> listCases() async {
    final map = await _loadMap();
    final cases = map.values
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .where((c) => c.deletedAt == null)
        .toList();
    cases.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return cases;
  }

  @override
  Future<void> saveCase(BaziCaseContract case_) async {
    final map = await _loadMap();
    map[case_.uuid] = _toJson(case_);
    await _saveMap(map);
  }

  @override
  Future<void> deleteCase(String uuid) async {
    final map = await _loadMap();
    if (map.containsKey(uuid)) {
      final json = map[uuid] as Map<String, dynamic>;
      json['deletedAt'] = DateTime.now().toIso8601String();
      await _saveMap(map);
    }
  }

  @override
  Future<void> restoreCase(String uuid) async {
    final map = await _loadMap();
    if (map.containsKey(uuid)) {
      final json = map[uuid] as Map<String, dynamic>;
      json['deletedAt'] = null;
      await _saveMap(map);
    }
  }
}
