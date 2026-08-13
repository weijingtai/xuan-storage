library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_firebase/playground/firebase_playground_post_command_repository.dart';

import 'fake_callable_functions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PostCommand writes exclusively through callable Functions without actor fields', () async {
    final functions = FakeFirebaseFunctions()
      ..responses['createPost'] = <String, dynamic>{
        'id': 'post-1', 'text': '正文', 'status': 'active',
        'attachments': <dynamic>[], 'revisions': <dynamic>[],
        'created_at': DateTime.utc(2026), 'author_provider_uid': 'server-uid',
      }
      ..responses['editPost'] = <String, dynamic>{
        'id': 'post-1', 'text': '改后', 'status': 'active',
        'attachments': <dynamic>[], 'revisions': <dynamic>[],
        'created_at': DateTime.utc(2026), 'author_provider_uid': 'server-uid',
      };
    final repo = FirebasePlaygroundPostCommandRepository(
      firestore: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(mockUser: MockUser(uid: 'client-uid'), signedIn: true),
      functions: functions,
    );

    await repo.createPost(const CreatePostCommand(text: '正文', idempotencyKey: 'k1'));
    await repo.editPost(const EditPostCommand(postId: PlaygroundPostId('post-1'), text: '改后', idempotencyKey: 'k2'));
    await repo.tombstonePost(const DeletePostCommand(postId: PlaygroundPostId('post-1'), idempotencyKey: 'k3'));

    expect(functions.calledNames, ['createPost', 'editPost', 'tombstonePost']);
    for (final params in functions.calledParameters.whereType<Map<String, dynamic>>()) {
      expect(params.containsKey('author_provider_uid'), isFalse);
      expect(params.containsKey('author_app_user_id'), isFalse);
      expect(params.containsKey('presentation_identity_id'), isFalse);
    }
    expect(functions.calledParameters.first!['idempotency_key'], 'k1');
  });
}
