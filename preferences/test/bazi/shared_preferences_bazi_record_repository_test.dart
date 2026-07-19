import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import '../../lib/bazi/shared_preferences_bazi_record_repository.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPreferencesBaziRecordRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = SharedPreferencesBaziRecordRepository(prefs, 'test-scope');
  });

  test('save and get record', () async {
    final record = BaziRecordContract(
      uuid: 'rec-1',
      caseUuid: 'case-1',
      recordDate: DateTime.now(),
      legacyEightCharsJson: '{"bazi": "data"}',
      createdAt: DateTime.now(),
    );

    await repo.saveRecord(record);
    final retrieved = await repo.getRecord('rec-1');
    expect(retrieved, equals(record));
  });

  test('list records by case uuid', () async {
    final record1 = BaziRecordContract(
      uuid: 'rec-1',
      caseUuid: 'case-1',
      recordDate: DateTime.now(),
      legacyEightCharsJson: '{}',
      createdAt: DateTime(2023, 1, 2),
    );
    final record2 = BaziRecordContract(
      uuid: 'rec-2',
      caseUuid: 'case-2',
      recordDate: DateTime.now(),
      legacyEightCharsJson: '{}',
      createdAt: DateTime(2023, 1, 1),
    );
    final record3 = BaziRecordContract(
      uuid: 'rec-3',
      caseUuid: 'case-1',
      recordDate: DateTime.now(),
      legacyEightCharsJson: '{}',
      createdAt: DateTime(2023, 1, 3), // Most recent
    );

    await repo.saveRecord(record1);
    await repo.saveRecord(record2);
    await repo.saveRecord(record3);

    final records = await repo.listRecords('case-1');
    expect(records.length, 2);
    // Ordered by createdAt desc
    expect(records[0].uuid, 'rec-3');
    expect(records[1].uuid, 'rec-1');
  });

  test('delete record', () async {
    final record = BaziRecordContract(
      uuid: 'rec-1',
      caseUuid: 'case-1',
      recordDate: DateTime.now(),
      legacyEightCharsJson: '{"bazi": "data"}',
      createdAt: DateTime.now(),
    );

    await repo.saveRecord(record);
    await repo.deleteRecord('rec-1');
    final retrieved = await repo.getRecord('rec-1');
    expect(retrieved, isNull);
  });

  test('legacy "{}" restore', () async {
    await prefs.setString('bazi.test-scope.records', '{}');
    final records = await repo.listRecords('case-1');
    expect(records.isEmpty, true);
    
    await prefs.setString('bazi.test-scope.records', 'invalid json');
    final records2 = await repo.listRecords('case-1');
    expect(records2.isEmpty, true);
  });

  test('scope isolation', () async {
    final repoA = SharedPreferencesBaziRecordRepository(prefs, 'scope-a');
    final repoB = SharedPreferencesBaziRecordRepository(prefs, 'scope-b');

    final record1 = BaziRecordContract(
      uuid: 'rec-1',
      caseUuid: 'case-1',
      recordDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await repoA.saveRecord(record1);

    final recordsB = await repoB.listRecords('case-1');
    expect(recordsB.isEmpty, true);

    final recordsA = await repoA.listRecords('case-1');
    expect(recordsA.length, 1);
    expect(recordsA[0].uuid, 'rec-1');
  });

  test('does not auto migrate anonymous data when scopeUid changes', () async {
    final anonRepo = SharedPreferencesBaziRecordRepository(prefs, 'local-anonymous');
    final record1 = BaziRecordContract(
      uuid: 'rec-1',
      caseUuid: 'case-1',
      recordDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await anonRepo.saveRecord(record1);

    final userRepo = SharedPreferencesBaziRecordRepository(prefs, 'user-a');
    final userRecords = await userRepo.listRecords('case-1');
    expect(userRecords.isEmpty, true);

    final anonRecords = await anonRepo.listRecords('case-1');
    expect(anonRecords.length, 1);
    expect(anonRecords[0].uuid, 'rec-1');
  });
}
