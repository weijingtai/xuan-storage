import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_bazi/repository_interface_bazi.dart';
import '../../lib/bazi/shared_preferences_bazi_case_repository.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPreferencesBaziCaseRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = SharedPreferencesBaziCaseRepository(prefs, 'test-scope');
  });

  test('save and get case', () async {
    final case_ = BaziCaseContract(
      uuid: 'case-1',
      title: 'Test Case',
      birthDate: DateTime(1990, 1, 1),
      gender: 'male',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repo.put(case_, RequestContext(scopeUid: repo.scopeUid));
    final retrieved = (await repo.get('case-1', RequestContext(scopeUid: repo.scopeUid)) as Ok<BaziCaseContract?>).value;
    expect(retrieved, equals(case_));
  });

  test('list cases excludes deleted', () async {
    final case1 = BaziCaseContract(
      uuid: 'case-1',
      title: 'Test Case 1',
      birthDate: DateTime(1990, 1, 1),
      gender: 'male',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );
    final case2 = BaziCaseContract(
      uuid: 'case-2',
      title: 'Test Case 2',
      birthDate: DateTime(1995, 1, 1),
      gender: 'female',
      createdAt: DateTime(2023, 1, 2),
      updatedAt: DateTime(2023, 1, 2),
    );

    await repo.put(case1, RequestContext(scopeUid: repo.scopeUid));
    await repo.put(case2, RequestContext(scopeUid: repo.scopeUid));

    var qr = await repo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    var cases = (qr as Ok<Page<BaziCaseContract>>).value.items;
    expect(cases.length, 2);
    expect(cases[0].uuid, 'case-2');
    expect(cases[1].uuid, 'case-1');

    await repo.softDelete('case-1', RequestContext(scopeUid: repo.scopeUid));
    qr = await repo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    cases = (qr as Ok<Page<BaziCaseContract>>).value.items;
    expect(cases.length, 1);
    expect(cases[0].uuid, 'case-2');
  });

  test('restore case', () async {
    final case1 = BaziCaseContract(
      uuid: 'case-1',
      title: 'Test Case 1',
      birthDate: DateTime(1990, 1, 1),
      gender: 'male',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );
    await repo.put(case1, RequestContext(scopeUid: repo.scopeUid));
    await repo.softDelete('case-1', RequestContext(scopeUid: repo.scopeUid));
    var qr = await repo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    var cases = (qr as Ok<Page<BaziCaseContract>>).value.items;
    expect(cases.isEmpty, true);

    await repo.restore('case-1', RequestContext(scopeUid: repo.scopeUid));
    qr = await repo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    cases = (qr as Ok<Page<BaziCaseContract>>).value.items;
    expect(cases.length, 1);
    expect(cases[0].uuid, 'case-1');
  });

  test('legacy "{}" restore', () async {
    await prefs.setString('bazi.test-scope.cases', '{}');
    var qr = await repo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    var cases = (qr as Ok<Page<BaziCaseContract>>).value.items;
    expect(cases.isEmpty, true);

    await prefs.setString('bazi.test-scope.cases', 'invalid json');
    qr = await repo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repo.scopeUid));
    cases = (qr as Ok<Page<BaziCaseContract>>).value.items;
    expect(cases.isEmpty, true);
  });

  test('scope isolation', () async {
    final repoA = SharedPreferencesBaziCaseRepository(prefs, 'scope-a');
    final repoB = SharedPreferencesBaziCaseRepository(prefs, 'scope-b');

    final case1 = BaziCaseContract(
      uuid: 'case-1',
      title: 'Test Case 1',
      birthDate: DateTime(1990, 1, 1),
      gender: 'male',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repoA.put(case1, RequestContext(scopeUid: repoA.scopeUid));

    var qrB = await repoB.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repoB.scopeUid));
    var casesB = (qrB as Ok<Page<BaziCaseContract>>).value.items;
    expect(casesB.isEmpty, true);

    var qrA = await repoA.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: repoA.scopeUid));
    var casesA = (qrA as Ok<Page<BaziCaseContract>>).value.items;
    expect(casesA.length, 1);
    expect(casesA[0].uuid, 'case-1');
  });

  test('does not auto migrate anonymous data when scopeUid changes', () async {
    final anonRepo = SharedPreferencesBaziCaseRepository(prefs, 'local-anonymous');
    final case1 = BaziCaseContract(
      uuid: 'case-1',
      title: 'Test Case 1',
      birthDate: DateTime(1990, 1, 1),
      gender: 'male',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await anonRepo.put(case1, RequestContext(scopeUid: anonRepo.scopeUid));

    final userRepo = SharedPreferencesBaziCaseRepository(prefs, 'user-a');
    var qrU = await userRepo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: userRepo.scopeUid));
    var userCases = (qrU as Ok<Page<BaziCaseContract>>).value.items;
    expect(userCases.isEmpty, true);

    var qrAn = await anonRepo.query(const {}, PageRequest(limit: 200), RequestContext(scopeUid: anonRepo.scopeUid));
    var anonCases = (qrAn as Ok<Page<BaziCaseContract>>).value.items;
    expect(anonCases.length, 1);
    expect(anonCases[0].uuid, 'case-1');
  });
}
