import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';

enum BaziMigrationResult { success, failure }

class BaziRecordRepositoryMigrator {
  final SharedPreferences prefs;
  final BaziRecordRepository target;
  final String scopeUid;

  BaziRecordRepositoryMigrator({
    required this.prefs,
    required this.target,
    required this.scopeUid,
  });

  String get markerKey => 'bazi.$scopeUid.records.migrated_to_drift.v1';

  String get _recordsKey => 'bazi.$scopeUid.records';

  Future<BaziMigrationResult> migrate() async {
    // 1. If success marker exists, skip migration.
    if (prefs.getBool(markerKey) == true) {
      return BaziMigrationResult.success;
    }

    try {
      // 2. Enumerate legacy records.
      final legacyRecords = _readLegacyRecords();
      if (legacyRecords.isEmpty) {
        // 3. Write success marker for empty source.
        final wrote = await _writeMarker();
        return wrote ? BaziMigrationResult.success : BaziMigrationResult.failure;
      }

      // 4. Save each record through the target repository.
      for (final record in legacyRecords) {
        await target.saveRecord(record);
      }

      // 5. Read back every record and verify field-for-field.
      for (final source in legacyRecords) {
        final verified = await target.getRecord(source.uuid);
        if (verified == null) return BaziMigrationResult.failure;
        if (!_fieldsEqual(source, verified)) return BaziMigrationResult.failure;
      }

      // 6. Write success marker only after all verifications pass.
      final wrote = await _writeMarker();
      return wrote ? BaziMigrationResult.success : BaziMigrationResult.failure;
    } catch (_) {
      return BaziMigrationResult.failure;
    }
  }

  List<BaziRecordContract> _readLegacyRecords() {
    final String? jsonStr = prefs.getString(_recordsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return [];
      return decoded.values.map((e) => _fromLegacyJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  BaziRecordContract _fromLegacyJson(Map<String, dynamic> json) {
    return BaziRecordContract(
      uuid: json['uuid'] as String,
      caseUuid: json['caseUuid'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      chartSnapshotJson: json['chartSnapshotJson'] as String?,
      snapshotSchemaVersion: json['snapshotSchemaVersion'] as int? ?? 1,
      legacyEightCharsJson:
          (json['legacyEightCharsJson'] ?? json['eightCharsJson']) as String?,
      daYunJson: json['daYunJson'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool _fieldsEqual(BaziRecordContract a, BaziRecordContract b) {
    return a.uuid == b.uuid &&
        a.caseUuid == b.caseUuid &&
        a.recordDate.toIso8601String() == b.recordDate.toIso8601String() &&
        a.chartSnapshotJson == b.chartSnapshotJson &&
        a.snapshotSchemaVersion == b.snapshotSchemaVersion &&
        a.legacyEightCharsJson == b.legacyEightCharsJson &&
        a.daYunJson == b.daYunJson &&
        a.note == b.note &&
        a.createdAt.toIso8601String() == b.createdAt.toIso8601String();
  }

  Future<bool> _writeMarker() async {
    try {
      return await prefs.setBool(markerKey, true);
    } catch (_) {
      return false;
    }
  }
}