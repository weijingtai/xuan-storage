import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';

class SharedPreferencesBaziRecordRepository implements BaziRecordRepository {
  static const String _key = 'bazi_records';
  final SharedPreferences prefs;

  SharedPreferencesBaziRecordRepository(this.prefs);

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

  BaziRecordContract _fromJson(Map<String, dynamic> json) {
    return BaziRecordContract(
      uuid: json['uuid'] as String,
      caseUuid: json['caseUuid'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      chartSnapshotJson: json['chartSnapshotJson'] as String?,
      snapshotSchemaVersion: json['snapshotSchemaVersion'] as int? ?? 1,
      legacyEightCharsJson: json['legacyEightCharsJson'] as String?,
      daYunJson: json['daYunJson'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> _toJson(BaziRecordContract r) {
    return {
      'uuid': r.uuid,
      'caseUuid': r.caseUuid,
      'recordDate': r.recordDate.toIso8601String(),
      'chartSnapshotJson': r.chartSnapshotJson,
      'snapshotSchemaVersion': r.snapshotSchemaVersion,
      'legacyEightCharsJson': r.legacyEightCharsJson,
      'daYunJson': r.daYunJson,
      'note': r.note,
      'createdAt': r.createdAt.toIso8601String(),
    };
  }

  @override
  Future<List<BaziRecordContract>> listRecords(String caseUuid) async {
    final map = await _loadMap();
    final records = map.values
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .where((r) => r.caseUuid == caseUuid)
        .toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  @override
  Future<BaziRecordContract?> getRecord(String uuid) async {
    final map = await _loadMap();
    if (map.containsKey(uuid)) {
      return _fromJson(map[uuid] as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<void> saveRecord(BaziRecordContract record) async {
    final map = await _loadMap();
    map[record.uuid] = _toJson(record);
    await _saveMap(map);
  }

  @override
  Future<void> deleteRecord(String uuid) async {
    final map = await _loadMap();
    if (map.containsKey(uuid)) {
      map.remove(uuid);
      await _saveMap(map);
    }
  }
}
