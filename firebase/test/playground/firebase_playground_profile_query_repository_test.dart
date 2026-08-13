/// Firebase adapter contract for the current-actor ProfileQuery port.
///
/// The port deliberately exposes no caller-supplied user ID for private
/// mutations or technique statistics. Public profile content is projected as
/// safe DTOs and one-time-anonymous posts never enter a public profile page.
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_profile_query_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late FirebasePlaygroundProfileQueryRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirebasePlaygroundProfileQueryRepository(
      firestore: firestore,
      auth: MockFirebaseAuth(
        mockUser: MockUser(uid: 'provider-session', isAnonymous: false),
        signedIn: true,
      ),
      resolveCurrentActor: () async => const PlaygroundUserId('session-user'),
    );
  });

  test(
    'public profile content returns safe posts and excludes one-time anonymous',
    () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc('profile-owner')
          .set({'display_name': '公开盘友', 'public_post_count': 2});
      await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc('visible')
          .set({
            'author_app_user_id': 'profile-owner',
            'author_provider_uid': 'provider-owner',
            'text': '公开帖子',
            'status': 'active',
            'presentation_mode': 'stableAlias',
            'attachments': <dynamic>[],
            'revisions': <dynamic>[],
            'created_at': DateTime.utc(2026, 8, 1),
          });
      await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc('anonymous')
          .set({
            'author_app_user_id': 'profile-owner',
            'author_provider_uid': 'provider-owner',
            'text': '不应公开在主页',
            'status': 'active',
            'presentation_mode': 'oneTimeAnonymous',
            'attachments': <dynamic>[],
            'revisions': <dynamic>[],
            'created_at': DateTime.utc(2026, 8, 2),
          });

      final profile = await repository.getPublicProfile(
        const PlaygroundUserId('profile-owner'),
      );
      final page = await repository.getPublicProfilePosts(
        const GetPublicProfilePostsQuery(
          userId: PlaygroundUserId('profile-owner'),
        ),
      );

      expect(profile.displayName, '公开盘友');
      expect(page.items.map((post) => post.publicPostId.value), ['visible']);
      expect(
        page.items.single.author.publicPresentationUserId.value,
        isNotEmpty,
      );
      expect(
        page.items.single.toString(),
        isNot(contains('provider-owner')),
        reason: 'public projection must not expose the provider UID',
      );
    },
  );

  test(
    'updateMyProfile and private stats resolve the current actor internally',
    () async {
      await repository.updateMyProfile(
        const UpdateMyProfileCommand(
          displayName: '本人',
          commonTechniques: ['liuyao'],
        ),
      );

      final profile = await repository.getPublicProfile(
        const PlaygroundUserId('session-user'),
      );
      final stats = await repository.getMyPrivateTechniqueStats();

      expect(profile.displayName, '本人');
      expect(stats.single.userId, const PlaygroundUserId('session-user'));
      expect(stats.single.techniqueId, 'liuyao');
    },
  );
}
