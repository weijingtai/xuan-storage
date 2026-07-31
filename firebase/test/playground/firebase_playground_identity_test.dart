import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebasePlaygroundIdentityResolver', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('无用户 → 抛出 unauthenticated', () async {
      final mockAuth = MockFirebaseAuth(signedIn: false);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      expect(
        () async => await resolver.resolveActor(),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.unauthenticated)),
      );
    });

    test('有用户 → 解析出 actor', () async {
      final mockUser = MockUser(
        uid: 'test-provider-uid-123',
        isAnonymous: false,
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      expect(mockAuth.currentUser, isNotNull);
      final actor = await resolver.resolveActor();
      expect(actor.value, isNotEmpty);
      expect(actor.value, startsWith('app-'));
    });

    test('同一用户两次调用 → 返回相同 appUserId', () async {
      final mockUser = MockUser(
        uid: 'repeat-user-uid',
        isAnonymous: false,
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      final actor1 = await resolver.resolveActor();
      final actor2 = await resolver.resolveActor();

      expect(actor1.value, actor2.value);
    });

    test('isActor 逻辑验证', () {
      final mockUser = MockUser(
        uid: 'session-uid',
        isAnonymous: false,
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      expect(resolver.isActor(const PlaygroundUserId('session-uid')), isTrue);
      expect(resolver.isActor(const PlaygroundUserId('different')), isFalse);
    });
  });
}
