library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_firebase/playground/firebase_playground_reply_command_repository.dart';

import 'fake_callable_functions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ReplyCommand uses callable Functions and sends only structural intent', () async {
    final response = <String, dynamic>{
      'id': 'reply-1', 'post_id': 'post-1', 'body': '正文', 'depth': 0,
      'root_reply_id': null, 'reply_to_reply_id': null, 'is_tombstoned': false,
      'author_provider_uid': 'server-uid', 'created_at': DateTime.utc(2026),
    };
    final functions = FakeFirebaseFunctions()
      ..responses['createRootReply'] = response
      ..responses['createDiscussionReply'] = {...response, 'depth': 1, 'root_reply_id': 'root-1'}
      ..responses['editReply'] = {...response, 'body': '改后'};
    final repo = FirebasePlaygroundReplyCommandRepository(
      firestore: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(mockUser: MockUser(uid: 'client-uid'), signedIn: true),
      functions: functions,
    );

    await repo.createRootReply(const CreateRootReplyCommand(postId: PlaygroundPostId('post-1'), body: '正文', idempotencyKey: 'k1'));
    await repo.createDiscussionReply(const CreateDiscussionReplyCommand(postId: PlaygroundPostId('post-1'), rootReplyId: PlaygroundReplyId('root-1'), body: '正文', idempotencyKey: 'k2'));
    await repo.editReply(const EditReplyCommand(replyId: PlaygroundReplyId('reply-1'), body: '改后', idempotencyKey: 'k3'));
    await repo.tombstoneReply(const DeleteReplyCommand(replyId: PlaygroundReplyId('reply-1'), idempotencyKey: 'k4'));

    expect(functions.calledNames, ['createRootReply', 'createDiscussionReply', 'editReply', 'deleteReply']);
    for (final params in functions.calledParameters.whereType<Map<String, dynamic>>()) {
      expect(params.containsKey('author_provider_uid'), isFalse);
      expect(params.containsKey('author_app_user_id'), isFalse);
      expect(params.containsKey('parent_reply_id'), isFalse);
      expect(params.containsKey('depth'), isFalse);
    }
  });
}
