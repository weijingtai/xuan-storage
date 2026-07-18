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
    repo = SharedPreferencesBaziRecordRepository(prefs);
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
    await prefs.setString('bazi_records', '{}');
    final records = await repo.listRecords('case-1');
    expect(records.isEmpty, true);
    
    await prefs.setString('bazi_records', 'invalid json');
    final records2 = await repo.listRecords('case-1');
    expect(records2.isEmpty, true);
  });
}
