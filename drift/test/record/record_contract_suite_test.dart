import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:test/test.dart';

/// M1 T5：把 record 切片（RecordStorageDriver + EntityDescriptor）注入
/// RepositoryRig，跑 L0 契约套件 C1–C10。
void main() {
  late PersistenceDriftDatabase db;
  late DriftRecordDataSource ds;
  late LocalRecordRepository store;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    ds = DriftRecordDataSource(db, scopeUid: 'scope_A');
    store = LocalRecordRepository(ds, RecordAdapterRegistry(const []));
  });

  tearDown(() => db.close());

  Map<String, Object?> makeRow(String id, int seed) => {
        'id': id,
        'module': 'meihua',
        'category': 'divination',
        'divination_type': 'mei_hua',
        'question': 'q$seed',
        'detail': null,
        'tag': null,
        'module_data': '{"seed":$seed}',
        'created_at':
            DateTime(2026, 1, 1, 0, seed, 0).toUtc().toIso8601String(),
        'updated_at': null,
        'deleted_at': null,
      };

  runRepositoryContractSuite<Map<String, Object?>, String>(
    RepositoryRig<Map<String, Object?>, String>(
      name: 'record-slice · meihua 试点',
      reset: () async {
        await db.close();
        db = PersistenceDriftDatabase(NativeDatabase.memory());
        ds = DriftRecordDataSource(db, scopeUid: 'scope_A');
        store = LocalRecordRepository(ds, RecordAdapterRegistry(const []));
      },
      makeRepository: () => CrudBaseRepository<Map<String, Object?>, String>(
        descriptor: recordEntityDescriptor(module: 'meihua'),
        driver: RecordStorageDriver(store: store, dataSource: ds),
      ),
      makeEntity: (id, seed) => makeRow(id, seed),
      idOf: (row) => row['id'] as String,
      makeId: (seed) => seed,
    ),
  );
}
