import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebasePlaygroundIdentityResolver', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;

    const providerUid = 'test-provider-uid-123';
    const appUserId = 'app-resolver-user';

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    Future<void> seedIdentity() async {
      await firestore.collection('identity_map').doc(providerUid).set({
        'app_user_id': appUserId,
        'provider_uid': providerUid,
        'provider_id': 'firebase',
        'public_presentation_id': 'pub_test_128bit',
        'public_display_alias': '测试用户',
      });
    }

    test('无用户 → 抛出 unauthenticated', () async {
      final mockAuthUnsigned = MockFirebaseAuth(signedIn: false);
      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuthUnsigned,
      );

      expect(
        () async => await resolver.resolveActor(),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.unauthenticated)),
      );
    });

    test('有用户且 identity 完整 → 解析出 actor', () async {
      await seedIdentity();
      final mockUser = MockUser(uid: providerUid, isAnonymous: false);
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      final actor = await resolver.resolveActor();
      expect(actor.value, appUserId);
    });

    test('同一用户两次调用 → 返回相同 appUserId', () async {
      await seedIdentity();
      final mockUser = MockUser(uid: 'repeat-user-uid', isAnonymous: false);
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      await firestore.collection('identity_map').doc('repeat-user-uid').set({
        'app_user_id': 'app-repeat',
        'provider_uid': 'repeat-user-uid',
        'provider_id': 'firebase',
        'public_presentation_id': 'pub_repeat',
        'public_display_alias': '重复用户',
      });

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      final actor1 = await resolver.resolveActor();
      final actor2 = await resolver.resolveActor();

      expect(actor1.value, actor2.value);
      expect(actor1.value, 'app-repeat');
    });

    test('identity 缺失 presentation 字段 → unavailable', () async {
      await firestore.collection('identity_map').doc('error-uid').set({
        'app_user_id': 'app-error',
        'provider_uid': 'error-uid',
        'provider_id': 'firebase',
      });

      final mockUser = MockUser(uid: 'error-uid', isAnonymous: false);
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      expect(
        () async => await resolver.resolveActor(),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.unavailable)),
      );
    });
  });
}
