import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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

    await repo.put(record, RequestContext(scopeUid: repo.scopeUid));
    final retrieved = (await repo.get('rec-1', RequestContext(scopeUid: repo.scopeUid)) as Ok<BaziRecordContract?>).value;
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
      createdAt: DateTime(2023, 1, 3),
    );

    await repo.put(record1, RequestContext(scopeUid: repo.scopeUid));
    await repo.put(record2, RequestContext(scopeUid: repo.scopeUid));
    await repo.put(record3, RequestContext(scopeUid: repo.scopeUid));

    var qr = await repo.query({'caseUuid': 'case-1'}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    var records = (qr as Ok<Page<BaziRecordContract>>).value.items;
    expect(records.length, 2);
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

    await repo.put(record, RequestContext(scopeUid: repo.scopeUid));
    await repo.softDelete('rec-1', RequestContext(scopeUid: repo.scopeUid));
    final retrieved = (await repo.get('rec-1', RequestContext(scopeUid: repo.scopeUid)) as Ok<BaziRecordContract?>).value;
    expect(retrieved, isNull);
  });

  test('legacy "{}" restore', () async {
    await prefs.setString('bazi.test-scope.records', '{}');
    var qr = await repo.query({'caseUuid': 'case-1'}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    var records = (qr as Ok<Page<BaziRecordContract>>).value.items;
    expect(records.isEmpty, true);

    await prefs.setString('bazi.test-scope.records', 'invalid json');
    qr = await repo.query({'caseUuid': 'case-1'}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    records = (qr as Ok<Page<BaziRecordContract>>).value.items;
    expect(records.isEmpty, true);
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

    await repoA.put(record1, RequestContext(scopeUid: repoA.scopeUid));

    var qrB = await repoB.query({'caseUuid': 'case-1'}, PageRequest(limit: 200), RequestContext(scopeUid: repoB.scopeUid));
    var recordsB = (qrB as Ok<Page<BaziRecordContract>>).value.items;
    expect(recordsB.isEmpty, true);

    var qrA = await repoA.query({'caseUuid': 'case-1'}, PageRequest(limit: 200), RequestContext(scopeUid: repoA.scopeUid));
    var recordsA = (qrA as Ok<Page<BaziRecordContract>>).value.items;
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
    await anonRepo.put(record1, RequestContext(scopeUid: anonRepo.scopeUid));

    final userRepo = SharedPreferencesBaziRecordRepository(prefs, 'user-a');
    var qrU = await userRepo.query({'caseUuid': 'case-1'}, PageRequest(limit: 200), RequestContext(scopeUid: userRepo.scopeUid));
    var userRecords = (qrU as Ok<Page<BaziRecordContract>>).value.items;
    expect(userRecords.isEmpty, true);

    var qrAn = await anonRepo.query({'caseUuid': 'case-1'}, PageRequest(limit: 200), RequestContext(scopeUid: anonRepo.scopeUid));
    var anonRecords = (qrAn as Ok<Page<BaziRecordContract>>).value.items;
    expect(anonRecords.length, 1);
    expect(anonRecords[0].uuid, 'rec-1');
  });
}
