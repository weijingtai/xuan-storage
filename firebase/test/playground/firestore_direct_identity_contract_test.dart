import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Direct identity contract', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;

    const providerUid = 'alice';
    const appUserId = 'app-alice';
    const publicPresentationId = 'pub_random_128bit';
    const publicDisplayAlias = '玄友0001';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      final mockUser = MockUser(uid: providerUid, isAnonymous: false);
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    });

    Future<void> seedFullIdentity() async {
      await firestore.collection('identity_map').doc(providerUid).set({
        'app_user_id': appUserId,
        'provider_uid': providerUid,
        'provider_id': 'firebase',
        'public_presentation_id': publicPresentationId,
        'public_display_alias': publicDisplayAlias,
      });
    }

    Future<void> seedCamelCaseCompat() async {
      await firestore.collection('identity_map').doc(providerUid).set({
        'appUserId': appUserId,
        'provider_uid': providerUid,
        'provider_id': 'firebase',
        'public_presentation_id': publicPresentationId,
        'public_display_alias': publicDisplayAlias,
      });
    }

    Future<void> seedNoPresentation() async {
      await firestore.collection('identity_map').doc(providerUid).set({
        'app_user_id': appUserId,
        'provider_uid': providerUid,
        'provider_id': 'firebase',
      });
    }

    test('新 reader 优先读 app_user_id 并返回公开身份', () async {
      await seedFullIdentity();
      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      final actor = await resolver.resolveActor();
      expect(actor.value, equals(appUserId));
    });

    test('新 reader 兼容旧 appUserId', () async {
      await seedCamelCaseCompat();
      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      final actor = await resolver.resolveActor();
      expect(actor.value, equals(appUserId));
    });

    test('缺 public_presentation_id → PlaygroundErrorCode.unavailable + identity/not-ready', () async {
      await seedNoPresentation();
      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
      );

      expect(
        () async => await resolver.resolveActor(),
        throwsA(
          isA<PlaygroundError>()
              .having((e) => e.code, 'code', PlaygroundErrorCode.unavailable)
              .having((e) => e.machineCode, 'machineCode', 'identity/not-ready'),
        ),
      );
    });

    test('identity_map 不存在 → unavailable', () async {
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
