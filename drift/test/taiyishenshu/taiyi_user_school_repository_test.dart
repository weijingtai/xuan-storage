import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:persistence_drift/taiyishenshu/taiyishenshu_drift.dart';
import 'package:persistence_drift/taiyishenshu/drift_user_repository.dart';

void main() {
  late TaiYiDatabase db;
  late DriftUserRepository repository;

  setUp(() {
    db = TaiYiDatabase.memory();
    repository = DriftUserRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('DriftUserRepository CRUD user schools and user deities', () async {
    final school = const TaiYiSchoolContract(
      id: 'custom-1',
      name: 'Custom School',
      source: 'user',
      epoch: SchoolEpochConfigContract(
        ancientBase: 0,
        epochYear: 2026,
        correction: 10,
        tropicalYear: 365.2422,
      ),
      deityIds: ['taiYi'],
    );

    // Save and load
    await repository.saveSchool(school);
    final fetched = await repository.loadSchool('custom-1');
    expect(fetched, isNotNull);
    expect(fetched!.id, equals('custom-1'));
    expect(fetched.name, equals('Custom School'));

    final list = await repository.loadUserSchools();
    expect(list, hasLength(1));
    expect(list.first.id, equals('custom-1'));

    // Deity
    final deity = const DeityDefinitionContract(
      id: 'deity-custom',
      name: 'Custom Deity',
      layer: 'tianPan',
      algorithm: DeityAlgorithmSpecContract(
        templateId: 'steppedCycle',
      ),
    );

    await repository.saveDeity(deity);
    final fetchedDeity = await repository.loadDeity('deity-custom');
    expect(fetchedDeity, isNotNull);
    expect(fetchedDeity!.id, equals('deity-custom'));

    final deityList = await repository.loadUserDeities();
    expect(deityList, hasLength(1));
    expect(deityList.first.id, equals('deity-custom'));

    // Delete
    await repository.deleteSchool('custom-1');
    expect(await repository.loadSchool('custom-1'), isNull);

    await repository.deleteDeity('deity-custom');
    expect(await repository.loadDeity('deity-custom'), isNull);
  });
}
