import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/l0/firestore_storage_driver.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreStorageDriver driver;
  final descriptor = playgroundPostEntityDescriptor();

  setUp(() {
    firestore = FakeFirebaseFirestore();
    driver = FirestoreStorageDriver(
      firestore: firestore,
      scopeUid: 'scope_A',
    );
  });

  PlaygroundPost makePost(String id, int seed) {
    return PlaygroundPost(
      id: PlaygroundPostId(id),
      text: 'Post text $seed',
      authorUserId: PlaygroundUserId('user_$seed'),
      status: PlaygroundPostStatus.active,
      allowedChartTechniqueIds: const ['liuyao', 'meihua'],
      attachments: const [],
      revisions: const [],
      createdAt: DateTime.utc(2026, 1, 1, 0, seed, 0),
      updatedAt: DateTime.utc(2026, 1, 1, 0, seed, 0),
    );
  }

  runRepositoryContractSuite<PlaygroundPost, String>(
    RepositoryRig<PlaygroundPost, String>(
      name: 'playground · L0 契约套件 · firestore',
      reset: () async {
        firestore = FakeFirebaseFirestore();
        driver = FirestoreStorageDriver(
          firestore: firestore,
          scopeUid: 'scope_A',
        );
      },
      makeRepository: () => CrudBaseRepository<PlaygroundPost, String>(
        descriptor: descriptor,
        driver: driver,
      ),
      makeEntity: (id, seed) => makePost(id, seed),
      idOf: (e) => e.id.value,
      makeId: (seed) => seed,
      indexedField: 'author_user_id',
      indexedValueOf: (e) => e.authorUserId.value,
      supportsPurge: true,
    ),
  );
}
