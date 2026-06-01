import 'package:divination_case/divination_case.dart';
import 'package:test/test.dart';

import '../lib/divination_case/synced_divination_case_repository.dart';

class _FakeCaseRepository implements DivinationCaseRepository {
  final Map<String, DivinationCaseModel> store = {};
  bool failOnWrite = false;

  @override
  Future<DivinationCaseModel?> getCase(String uuid) async => store[uuid];

  @override
  Future<List<DivinationCaseModel>> listCases({bool includeDeleted = false}) async {
    return store.values.where((m) => includeDeleted || m.deletedAt == null).toList();
  }

  @override
  Future<void> saveCase(DivinationCaseModel model) async {
    if (failOnWrite) throw Exception('remote unavailable');
    store[model.uuid] = model;
  }
}

void main() {
  test('save case then list cases contains the case', () async {
    final local = _FakeCaseRepository();
    final remote = _FakeCaseRepository();
    final repo = SyncedDivinationCaseRepository(local: local, remote: remote);

    final model = DivinationCaseModel(
      uuid: 'case-1',
      title: 'Test',
      mainQuestion: 'Q?',
      status: DivinationCaseStatus.open,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    await repo.saveCase(model);
    final cases = await repo.listCases();
    expect(cases, contains(model));
  });

  test('remote failure does not block local write', () async {
    final local = _FakeCaseRepository();
    final remote = _FakeCaseRepository()..failOnWrite = true;
    final repo = SyncedDivinationCaseRepository(local: local, remote: remote);

    final model = DivinationCaseModel(
      uuid: 'case-2',
      title: 'Test2',
      mainQuestion: 'Q2?',
      status: DivinationCaseStatus.open,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    await repo.saveCase(model);
    final cases = await repo.listCases();
    expect(cases, contains(model));
  });
}
