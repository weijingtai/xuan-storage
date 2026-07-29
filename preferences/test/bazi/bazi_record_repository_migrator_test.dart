import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import 'package:persistence_preferences/bazi/bazi_record_repository_migrator.dart';

class _InMemoryBaziRecordRepository implements BaziRecordRepository {
  final Map<String, BaziRecordContract> _records = {};
  bool _failNextSave = false;
  bool _failNextGet = false;
  String _corruptedUuid = '';
  int _saveCount = 0;
  int? failOnSaveIndex;
  final Map<String, Map<String, dynamic>> _getRecordOverrides = {};

  void setFailNextSave(bool v) => _failNextSave = v;
  void setFailNextGet(String uuid) {
    _failNextGet = true;
    _corruptedUuid = uuid;
  }

  void setGetRecordOverride(String uuid, Map<String, dynamic> overrides) {
    _getRecordOverrides[uuid] = overrides;
  }

  Future<List<BaziRecordContract>> _all() async => _records.values.toList();

  @override
  Future<List<BaziRecordContract>> listRecords(String caseUuid) async {
    return _records.values.where((r) => r.caseUuid == caseUuid).toList();
  }

  @override
  Future<BaziRecordContract?> getRecord(String uuid) async {
    if (_failNextGet && uuid == _corruptedUuid) {
      throw Exception('simulated read failure');
    }
    final stored = _records[uuid];
    if (stored == null) return null;
    final overrides = _getRecordOverrides[uuid];
    if (overrides != null) {
      return BaziRecordContract(
        uuid: (overrides['uuid'] as String?) ?? stored.uuid,
        caseUuid: (overrides['caseUuid'] as String?) ?? stored.caseUuid,
        recordDate: (overrides['recordDate'] as DateTime?) ?? stored.recordDate,
        chartSnapshotJson: overrides.containsKey('chartSnapshotJson')
            ? overrides['chartSnapshotJson'] as String?
            : stored.chartSnapshotJson,
        snapshotSchemaVersion:
            (overrides['snapshotSchemaVersion'] as int?) ??
            stored.snapshotSchemaVersion,
        legacyEightCharsJson: overrides.containsKey('legacyEightCharsJson')
            ? overrides['legacyEightCharsJson'] as String?
            : stored.legacyEightCharsJson,
        daYunJson: overrides.containsKey('daYunJson')
            ? overrides['daYunJson'] as String?
            : stored.daYunJson,
        note: overrides.containsKey('note')
            ? overrides['note'] as String?
            : stored.note,
        createdAt: (overrides['createdAt'] as DateTime?) ?? stored.createdAt,
      );
    }
    return stored;
  }

  @override
  Future<void> saveRecord(BaziRecordContract record) async {
    _saveCount++;
    if (_failNextSave) throw Exception('simulated save failure');
    if (failOnSaveIndex != null && _saveCount == failOnSaveIndex) {
      throw Exception('simulated partial save failure at index $_saveCount');
    }
    _records[record.uuid] = record;
  }

  @override
  Future<void> deleteRecord(String uuid) async {
    _records.remove(uuid);
  }
}

BaziRecordContract _makeRecord({
  String uuid = 'rec-1',
  String caseUuid = 'case-1',
  DateTime? recordDate,
  String? chartSnapshotJson,
  int snapshotSchemaVersion = 1,
  String? legacyEightCharsJson,
  String? daYunJson,
  String? note,
  DateTime? createdAt,
}) {
  return BaziRecordContract(
    uuid: uuid,
    caseUuid: caseUuid,
    recordDate: recordDate ?? DateTime(2024, 1, 15),
    chartSnapshotJson: chartSnapshotJson,
    snapshotSchemaVersion: snapshotSchemaVersion,
    legacyEightCharsJson: legacyEightCharsJson,
    daYunJson: daYunJson,
    note: note,
    createdAt: createdAt ?? DateTime(2024, 1, 15, 12, 0),
  );
}

Map<String, dynamic> _toLegacyJson(BaziRecordContract r) {
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

void main() {
  late SharedPreferences prefs;
  late _InMemoryBaziRecordRepository target;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    target = _InMemoryBaziRecordRepository();
  });

  BaziRecordRepositoryMigrator makeMigrator(String scope) =>
      BaziRecordRepositoryMigrator(
        prefs: prefs,
        target: target,
        scopeUid: scope,
      );

  // ── 1. empty legacy source ──
  test('empty legacy source completes and writes success marker', () async {
    final m = makeMigrator('scope-a');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.success);
    expect(prefs.getBool(m.markerKey), isTrue);
    final all = await target._all();
    expect(all, isEmpty);
  });

  // ── 2. full field preservation ──
  test('full field preservation', () async {
    final record = _makeRecord(
      uuid: 'rec-1',
      caseUuid: 'case-abc',
      recordDate: DateTime(2024, 6, 15, 8, 30),
      chartSnapshotJson: '{"snap":1}',
      snapshotSchemaVersion: 2,
      legacyEightCharsJson: '{"legacy":"data"}',
      daYunJson: '{"dayun":"payload"}',
      note: 'test note',
      createdAt: DateTime(2024, 6, 15, 9, 0),
    );

    final legacyMap = {record.uuid: _toLegacyJson(record)};
    await prefs.setString('bazi.scope-a.records', jsonEncode(legacyMap));

    final m = makeMigrator('scope-a');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.success);

    final migrated = await target.getRecord('rec-1');
    expect(migrated, isNotNull);
    expect(migrated!.uuid, record.uuid);
    expect(migrated.caseUuid, record.caseUuid);
    expect(migrated.recordDate, record.recordDate);
    expect(migrated.chartSnapshotJson, record.chartSnapshotJson);
    expect(migrated.snapshotSchemaVersion, record.snapshotSchemaVersion);
    expect(migrated.legacyEightCharsJson, record.legacyEightCharsJson);
    expect(migrated.daYunJson, record.daYunJson);
    expect(migrated.note, record.note);
    expect(migrated.createdAt, record.createdAt);
  });

  // ── 3. scope isolation ──
  test('scope A and scope B are isolated', () async {
    final recordA = _makeRecord(uuid: 'rec-a', caseUuid: 'case-a');
    final recordB = _makeRecord(uuid: 'rec-b', caseUuid: 'case-b');

    await prefs.setString(
      'bazi.scope-a.records',
      jsonEncode({recordA.uuid: _toLegacyJson(recordA)}),
    );
    await prefs.setString(
      'bazi.scope-b.records',
      jsonEncode({recordB.uuid: _toLegacyJson(recordB)}),
    );

    final mA = makeMigrator('scope-a');
    final resultA = await mA.migrate();
    expect(resultA, BaziMigrationResult.success);

    final inA = await target.getRecord('rec-a');
    expect(inA, isNotNull);
    expect(inA!.uuid, 'rec-a');

    final inB = await target.getRecord('rec-b');
    // scope B not yet migrated, so rec-b should not be in the target
    expect(inB, isNull);

    // scope B marker should not exist
    final mB = makeMigrator('scope-b');
    expect(prefs.getBool(mB.markerKey), isNull);

    // now migrate scope B
    final resultB = await mB.migrate();
    expect(resultB, BaziMigrationResult.success);
    final inB2 = await target.getRecord('rec-b');
    expect(inB2, isNotNull);
    expect(inB2!.uuid, 'rec-b');
  });

  // ── 4. idempotent repeated startup ──
  test('repeated startup does not create duplicates', () async {
    final record = _makeRecord(uuid: 'rec-1', caseUuid: 'case-1');
    await prefs.setString(
      'bazi.scope-dup.records',
      jsonEncode({record.uuid: _toLegacyJson(record)}),
    );

    final m = makeMigrator('scope-dup');
    final r1 = await m.migrate();
    expect(r1, BaziMigrationResult.success);

    final allAfterFirst = await target._all();
    expect(allAfterFirst.length, 1);

    // second migration
    final r2 = await m.migrate();
    expect(r2, BaziMigrationResult.success);
    final allAfterSecond = await target._all();
    expect(allAfterSecond.length, 1);
    expect(allAfterSecond[0].uuid, 'rec-1');
  });

  // ── 5. historical eightCharsJson compatibility ──
  test('historical eightCharsJson becomes legacyEightCharsJson', () async {
    final legacyJson = {
      'rec-old': {
        'uuid': 'rec-old',
        'caseUuid': 'case-old',
        'recordDate': '2023-05-10T10:00:00.000',
        'eightCharsJson': '{"old":"format"}',
        'createdAt': '2023-05-10T10:00:00.000',
      },
    };
    await prefs.setString('bazi.scope-legacy.records', jsonEncode(legacyJson));

    final m = makeMigrator('scope-legacy');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.success);

    final migrated = await target.getRecord('rec-old');
    expect(migrated, isNotNull);
    expect(migrated!.legacyEightCharsJson, '{"old":"format"}');
  });

  // ── 6. target save failure ──
  test('target save failure does not write success marker', () async {
    final record = _makeRecord(uuid: 'rec-1', caseUuid: 'case-1');
    await prefs.setString(
      'bazi.scope-fail.records',
      jsonEncode({record.uuid: _toLegacyJson(record)}),
    );

    target.setFailNextSave(true);
    final m = makeMigrator('scope-fail');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);

    // legacy data untouched
    final raw = prefs.getString('bazi.scope-fail.records');
    expect(raw, isNotNull);
  });

  // ── 7. read-back mismatch ──
  test('verification mismatch fails migration', () async {
    final record = _makeRecord(
      uuid: 'rec-1',
      caseUuid: 'case-1',
      legacyEightCharsJson: '{"original":"payload"}',
    );
    await prefs.setString(
      'bazi.scope-mismatch.records',
      jsonEncode({record.uuid: _toLegacyJson(record)}),
    );

    final corruptedTarget = _InMemoryBaziRecordRepository();
    corruptedTarget.setGetRecordOverride('rec-1', {
      'legacyEightCharsJson': 'corrupted',
    });
    final m = BaziRecordRepositoryMigrator(
      prefs: prefs,
      target: corruptedTarget,
      scopeUid: 'scope-mismatch',
    );

    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);
  });

  // ── 7b. key field mismatches fail migration ──
  test('key field mismatches all fail migration', () async {
    final mismatches = <String, Map<String, dynamic>>{
      'uuid': {'uuid': 'different-uuid'},
      'caseUuid': {'caseUuid': 'different-case'},
      'recordDate': {'recordDate': DateTime(2020, 1, 1)},
      'chartSnapshotJson': {'chartSnapshotJson': '{"corrupted":true}'},
      'snapshotSchemaVersion': {'snapshotSchemaVersion': 99},
      'legacyEightCharsJson': {'legacyEightCharsJson': 'wrong'},
      'daYunJson': {'daYunJson': 'wrong_dayun'},
      'note': {'note': 'different note'},
      'createdAt': {'createdAt': DateTime(2020, 6, 1)},
    };

    for (final entry in mismatches.entries) {
      final scope = 'scope-mismatch-${entry.key}';
      final record = _makeRecord(
        uuid: 'rec-mm',
        caseUuid: 'case-mm',
        legacyEightCharsJson: '{"original":"payload"}',
        daYunJson: '{"dayun":"original"}',
        note: 'original note',
        chartSnapshotJson: '{"snap":"original"}',
      );
      await prefs.setString(
        'bazi.$scope.records',
        jsonEncode({record.uuid: _toLegacyJson(record)}),
      );

      final fakeTarget = _InMemoryBaziRecordRepository();
      fakeTarget.setGetRecordOverride('rec-mm', entry.value);
      final m = BaziRecordRepositoryMigrator(
        prefs: prefs,
        target: fakeTarget,
        scopeUid: scope,
      );

      final result = await m.migrate();
      expect(
        result,
        BaziMigrationResult.failure,
        reason: 'field ${entry.key} mismatch should fail migration',
      );
      expect(
        prefs.getBool(m.markerKey),
        isNull,
        reason: 'field ${entry.key} mismatch should not write marker',
      );
    }
  });

  // ── 7b. target read failure ──
  test('target read failure fails migration', () async {
    final record = _makeRecord(uuid: 'rec-1', caseUuid: 'case-1');
    await prefs.setString(
      'bazi.scope-readfail.records',
      jsonEncode({record.uuid: _toLegacyJson(record)}),
    );

    target.setFailNextGet('rec-1');
    final m = makeMigrator('scope-readfail');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);
  });

  // ── 8a. marker write returns false ──
  test('marker write returning false is migration failure', () async {
    final m = BaziRecordRepositoryMigrator(
      prefs: prefs,
      target: target,
      scopeUid: 'scope-marker-false',
      writeMarker: () async => false,
    );
    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);
  });

  // ── 8b. marker write throws is migration failure ──
  test('marker write throwing is migration failure', () async {
    final m = BaziRecordRepositoryMigrator(
      prefs: prefs,
      target: target,
      scopeUid: 'scope-marker-throw',
      writeMarker: () async =>
          throw Exception('simulated marker write failure'),
    );
    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);
  });

  // ── 8c. retry after marker write fails ──
  test(
    'retry after marker write failure does not use success shortcut',
    () async {
      final record = _makeRecord(uuid: 'rec-1', caseUuid: 'case-1');
      await prefs.setString(
        'bazi.scope-marker-retry.records',
        jsonEncode({record.uuid: _toLegacyJson(record)}),
      );

      var markerAttempts = 0;
      final m = BaziRecordRepositoryMigrator(
        prefs: prefs,
        target: target,
        scopeUid: 'scope-marker-retry',
        writeMarker: () async {
          markerAttempts++;
          if (markerAttempts == 1) return false;
          return true;
        },
      );

      final r1 = await m.migrate();
      expect(r1, BaziMigrationResult.failure);
      expect(prefs.getBool(m.markerKey), isNull);

      final r2 = await m.migrate();
      expect(r2, BaziMigrationResult.success);

      final all = await target._all();
      expect(all.length, 1);
      expect(all[0].uuid, 'rec-1');
    },
  );

  // ── 9. retry after partial failure ──
  test('retry after partial failure converges', () async {
    final r1 = _makeRecord(uuid: 'rec-1', caseUuid: 'case-1');
    final r2 = _makeRecord(uuid: 'rec-2', caseUuid: 'case-1');
    final r3 = _makeRecord(uuid: 'rec-3', caseUuid: 'case-1');
    final legacyMap = {
      r1.uuid: _toLegacyJson(r1),
      r2.uuid: _toLegacyJson(r2),
      r3.uuid: _toLegacyJson(r3),
    };
    await prefs.setString('bazi.scope-retry.records', jsonEncode(legacyMap));

    target.failOnSaveIndex = 3;

    final m = makeMigrator('scope-retry');
    final r = await m.migrate();
    expect(r, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);

    target.failOnSaveIndex = null;

    final r2result = await m.migrate();
    expect(r2result, BaziMigrationResult.success);

    final all = await target._all();
    expect(all.length, 3);
    expect(all.map((e) => e.uuid).toSet(), {'rec-1', 'rec-2', 'rec-3'});
  });

  // ── 10. multiple records ──
  test('multiple records all migrated correctly', () async {
    final records = List.generate(
      5,
      (i) => _makeRecord(
        uuid: 'rec-$i',
        caseUuid: 'case-multi',
        legacyEightCharsJson: '{"payload":$i}',
        note: 'note $i',
      ),
    );
    final legacyMap = {for (final r in records) r.uuid: _toLegacyJson(r)};
    await prefs.setString('bazi.scope-multi.records', jsonEncode(legacyMap));

    final m = makeMigrator('scope-multi');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.success);

    final all = await target._all();
    expect(all.length, 5);
    for (final r in records) {
      final migrated = await target.getRecord(r.uuid);
      expect(migrated, isNotNull);
      expect(migrated!.legacyEightCharsJson, r.legacyEightCharsJson);
      expect(migrated.note, r.note);
    }
  });

  // ── 11. null fields are preserved ──
  test('null optional fields are preserved as null', () async {
    final record = _makeRecord(
      uuid: 'rec-null',
      caseUuid: 'case-null',
      chartSnapshotJson: null,
      legacyEightCharsJson: null,
      daYunJson: null,
      note: null,
    );
    await prefs.setString(
      'bazi.scope-null.records',
      jsonEncode({record.uuid: _toLegacyJson(record)}),
    );

    final m = makeMigrator('scope-null');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.success);

    final migrated = await target.getRecord('rec-null');
    expect(migrated, isNotNull);
    expect(migrated!.chartSnapshotJson, isNull);
    expect(migrated.legacyEightCharsJson, isNull);
    expect(migrated.daYunJson, isNull);
    expect(migrated.note, isNull);
  });

  // ── 12. malformed JSON fails migration ──
  test('malformed JSON fails migration', () async {
    await prefs.setString(
      'bazi.scope-malformed.records',
      '{this is not valid json',
    );
    final m = makeMigrator('scope-malformed');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);
  });

  // ── 13. non-Map top level fails migration ──
  test('non-Map top level JSON fails migration', () async {
    await prefs.setString('bazi.scope-arraysrc.records', '[1,2,3]');
    final m = makeMigrator('scope-arraysrc');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);
  });

  // ── 14. non-Map entry fails migration ──
  test('non-Map entry in legacy data fails migration', () async {
    await prefs.setString(
      'bazi.scope-badentry.records',
      jsonEncode({'rec-1': 'not-a-map'}),
    );
    final m = makeMigrator('scope-badentry');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.failure);
    expect(prefs.getBool(m.markerKey), isNull);
  });

  // ── 15. delete not resurrected ──
  test('deleted record not resurrected on second migration', () async {
    final r1 = _makeRecord(uuid: 'rec-1', caseUuid: 'case-1');
    final r2 = _makeRecord(uuid: 'rec-2', caseUuid: 'case-1');
    final legacyMap = {r1.uuid: _toLegacyJson(r1), r2.uuid: _toLegacyJson(r2)};
    await prefs.setString('bazi.scope-deleted.records', jsonEncode(legacyMap));

    final m = makeMigrator('scope-deleted');
    final r = await m.migrate();
    expect(r, BaziMigrationResult.success);
    expect(prefs.getBool(m.markerKey), isTrue);

    final allAfterMigration = await target._all();
    expect(allAfterMigration.length, 2);

    await target.deleteRecord('rec-1');
    final afterDelete = await target._all();
    expect(afterDelete.length, 1);

    final secondMigrationResult = await m.migrate();
    expect(secondMigrationResult, BaziMigrationResult.success);

    final allAfterSecondMigration = await target._all();
    expect(allAfterSecondMigration.length, 1);
    expect(allAfterSecondMigration[0].uuid, 'rec-2');

    final deleted = await target.getRecord('rec-1');
    expect(deleted, isNull);
  });

  // ── 16. marker key uses correct format ──
  test('marker key has correct format', () {
    final m = makeMigrator('my-scope');
    expect(m.markerKey, 'bazi.my-scope.records.migrated_to_drift.v1');
  });

  // ── 17. non-empty legacy data but empty string after trimming ──
  // null or empty string treated as truly empty source → success with marker
  test('empty string legacy source completes and writes marker', () async {
    await prefs.setString('bazi.scope-empty-str.records', '');
    final m = makeMigrator('scope-empty-str');
    final result = await m.migrate();
    expect(result, BaziMigrationResult.success);
    expect(prefs.getBool(m.markerKey), isTrue);
  });
}
