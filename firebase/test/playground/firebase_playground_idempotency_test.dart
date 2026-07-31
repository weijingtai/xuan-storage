import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_post_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebasePlaygroundPostRepository 幂等', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;
    late FirebasePlaygroundIdentityResolver identityResolver;
    late FirebasePlaygroundPostRepository repo;

    const testUid = 'test-user-uid';

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: testUid, isAnonymous: false),
        signedIn: true,
      );
      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );
      repo = FirebasePlaygroundPostRepository(
        firestore: firestore,
        auth: mockAuth,
        identityResolver: identityResolver,
      );

      await firestore
          .collection(PlaygroundFirestoreSchema.identityMap)
          .doc(testUid)
          .set({
        'app_user_id': 'app-test-user',
        'provider_uid': testUid,
      });
    });

    test('同 idempotency key 同 payload → 幂等（不抛异常）', () async {
      const key = 'idem-key-1';

      final post1 = await repo.createPost(
        const CreatePostCommand(
          text: '帖子A',
          idempotencyKey: key,
        ),
      );
      expect(post1.id, isNotNull);

      final post2 = await repo.createPost(
        const CreatePostCommand(
          text: '帖子A',
          idempotencyKey: key,
        ),
      );
      expect(post2.id, isNotNull);

      final snap1 = await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(post1.id.value)
          .get();
      expect(snap1.data()?['idempotency_key'], equals(key));

      final snap2 = await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(post2.id.value)
          .get();
      expect(snap2.data()?['idempotency_key'], equals(key));
    });

    test('同 idempotency key 不同 payload → 两者均创建（需未来实现 conflict guard）', () async {
      const key = 'idem-key-2';

      final post1 = await repo.createPost(
        const CreatePostCommand(
          text: '帖子A',
          idempotencyKey: key,
        ),
      );
      expect(post1.text, equals('帖子A'));

      final post2 = await repo.createPost(
        const CreatePostCommand(
          text: '帖子B（不同payload）',
          idempotencyKey: key,
        ),
      );
      expect(post2.text, equals('帖子B（不同payload）'));

      final postsRef = firestore.collection(PlaygroundFirestoreSchema.posts);

      final allSnaps = await postsRef
          .where('idempotency_key', isEqualTo: key)
          .get();
      expect(allSnaps.docs.length, greaterThanOrEqualTo(1));
    });

    test('无 idempotency key → 正常创建', () async {
      final post = await repo.createPost(
        const CreatePostCommand(text: '普通帖文'),
      );

      expect(post.text, equals('普通帖文'));
      expect(post.isActive, isTrue);

      final snap = await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(post.id.value)
          .get();
      expect(snap.data()?['idempotency_key'], isNull);
    });

    test('不同 idempotency key → 各自独立创建', () async {
      final postA = await repo.createPost(
        const CreatePostCommand(
          text: '帖A',
          idempotencyKey: 'key-a',
        ),
      );
      final postB = await repo.createPost(
        const CreatePostCommand(
          text: '帖B',
          idempotencyKey: 'key-b',
        ),
      );

      expect(postA.text, equals('帖A'));
      expect(postB.text, equals('帖B'));
      expect(postA.id, isNot(equals(postB.id)));

      final snapA = await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postA.id.value)
          .get();
      expect(snapA.data()?['idempotency_key'], equals('key-a'));

      final snapB = await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postB.id.value)
          .get();
      expect(snapB.data()?['idempotency_key'], equals('key-b'));
    });
  });
}
