import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';

import 'fake_callable_functions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebasePlaygroundIdentityResolver', () {
    late FakeFirebaseFirestore firestore;
    late FakeFirebaseFunctions functions;

    const appUserId = 'app-resolver-user';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = FakeFirebaseFunctions()
        ..responses['resolveMyIdentity'] = <String, dynamic>{
          'appUserId': appUserId,
        };
    });

    test('无用户 → 抛出 unauthenticated', () async {
      final mockAuth = MockFirebaseAuth(signedIn: false);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
        functions: functions,
      );

      expect(
        () async => await resolver.resolveActor(),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.unauthenticated)),
      );
    });

    test('有用户 → 通过 callable 解析出 actor', () async {
      final mockUser = MockUser(
        uid: 'test-provider-uid-123',
        isAnonymous: false,
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
        functions: functions,
      );

      expect(mockAuth.currentUser, isNotNull);
      final actor = await resolver.resolveActor();
      expect(actor.value, appUserId);
      expect(functions.calledNames, contains('resolveMyIdentity'));
    });

    test('同一用户两次调用 → 返回相同 appUserId（callable 响应一致）', () async {
      final mockUser = MockUser(
        uid: 'repeat-user-uid',
        isAnonymous: false,
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
        functions: functions,
      );

      final actor1 = await resolver.resolveActor();
      final actor2 = await resolver.resolveActor();

      expect(actor1.value, actor2.value);
      expect(actor1.value, appUserId);
    });

    test('callable 异常 → 映射为 PlaygroundError', () async {
      final mockUser = MockUser(
        uid: 'error-uid',
        isAnonymous: false,
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      functions
        ..shouldThrow = true
        ..throwCode = 'permission-denied';

      final resolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: mockAuth,
        functions: functions,
      );

      expect(
        () async => await resolver.resolveActor(),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.forbidden)),
      );
    });
  });
}
