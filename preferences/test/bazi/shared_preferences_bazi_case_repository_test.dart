import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    await repo.saveCase(case_);
    final retrieved = await repo.getCase('case-1');
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

    await repo.saveCase(case1);
    await repo.saveCase(case2);

    var cases = await repo.listCases();
    expect(cases.length, 2);
    // ordered by updatedAt desc
    expect(cases[0].uuid, 'case-2');
    expect(cases[1].uuid, 'case-1');

    await repo.deleteCase('case-1');
    cases = await repo.listCases();
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
    await repo.saveCase(case1);
    await repo.deleteCase('case-1');
    var cases = await repo.listCases();
    expect(cases.isEmpty, true);

    await repo.restoreCase('case-1');
    cases = await repo.listCases();
    expect(cases.length, 1);
    expect(cases[0].uuid, 'case-1');
  });

  test('legacy "{}" restore', () async {
    await prefs.setString('bazi.test-scope.cases', '{}');
    final cases = await repo.listCases();
    expect(cases.isEmpty, true);
    
    await prefs.setString('bazi.test-scope.cases', 'invalid json');
    final cases2 = await repo.listCases();
    expect(cases2.isEmpty, true);
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

    await repoA.saveCase(case1);

    final casesB = await repoB.listCases();
    expect(casesB.isEmpty, true);

    final casesA = await repoA.listCases();
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
    await anonRepo.saveCase(case1);

    final userRepo = SharedPreferencesBaziCaseRepository(prefs, 'user-a');
    final userCases = await userRepo.listCases();
    expect(userCases.isEmpty, true);

    final anonCases = await anonRepo.listCases();
    expect(anonCases.length, 1);
    expect(anonCases[0].uuid, 'case-1');
  });
}
