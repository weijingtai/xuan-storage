/// Phase 7B：ReplyCommand adapter（FirebasePlaygroundReplyCommandRepository）
/// 契约测试 —— RED → GREEN。
///
/// 断言：
/// 1. payload 契约：createRootReply/createDiscussionReply 写字段集恰好等于
///    reply Rules allowlist（body/is_tombstoned 唯一权威），零
///    status/is_root/author_app_user_id/text；idempotency_key 条件写；
/// 2. tombstoneReply 只写 is_tombstoned:true（无 status）；
/// 3. editReply 只更新 body（+可选字段）；
/// 4. DTO 映射：返回安全 [PublicReply]，公开 DTO 零敏感字段。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_schema.dart';
import 'package:persistence_firebase/playground/firebase_playground_reply_command_repository.dart';

/// reply 字段 allowlist（firestore.rules replyCreateFieldsOk 全量）。
const replyCommandAllowlist = <String>{
  'body',
  'post_id',
  'root_reply_id',
  'reply_to_reply_id',
  'depth',
  'technique_tags',
  'chart_attachment',
  'media_attachments',
  'author_provider_uid',
  'presentation_identity_id',
  'is_tombstoned',
  'revisions',
  'created_at',
  'updated_at',
  'idempotency_key',
};

const sensitiveBlacklist = <String>[
  'author_provider_uid',
  'presentation_identity_id',
  'author_app_user_id',
  'user_provider_uid',
];

String _dump(Object? value) {
  final buffer = StringBuffer();
  if (value is Iterable) {
    for (final e in value) {
      buffer.write(_dump(e));
    }
  } else if (value is Map) {
    for (final e in value.entries) {
      buffer.write(_dump(e.value));
    }
  } else {
    buffer.write('$value');
  }
  return buffer.toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = 'reply-cmd-uid';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebasePlaygroundReplyCommandRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: uid, isAnonymous: false),
      signedIn: true,
    );
    repo = FirebasePlaygroundReplyCommandRepository(
      firestore: firestore,
      auth: auth,
    );
  });

  Future<Map<String, dynamic>> singleReplyDoc() async {
    final snaps =
        await firestore.collection(PlaygroundFirestoreSchema.replies).get();
    expect(snaps.docs, hasLength(1), reason: '应恰好写入一条 reply');
    return snaps.docs.single.data();
  }

  group('ReplyCommand payload 契约', () {
    test('createRootReply 写字段恰好等于 reply allowlist（零 status/is_root/author_app_user_id/text）',
        () async {
      await repo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('post-1'),
        body: '根回复正文',
        techniqueTags: ['liuyao'],
        idempotencyKey: 'root-key-1',
      ));

      final doc = await singleReplyDoc();
      final keys = doc.keys.toSet();
      expect(keys, replyCommandAllowlist,
          reason: 'createRootReply 写字段必须恰好等于 reply Rules allowlist');

      expect(doc['body'], '根回复正文');
      expect(doc['is_tombstoned'], isFalse);
      expect(doc['depth'], 0);

      expect(doc.containsKey('status'), isFalse,
          reason: 'reply 写路径零 status（tombstone 唯一语义为 is_tombstoned）');
      expect(doc.containsKey('is_root'), isFalse,
          reason: 'is_root 已移除，root/discussion 判别改用 depth');
      expect(doc.containsKey('author_app_user_id'), isFalse,
          reason: '命令 payload 零 author_app_user_id');
      expect(doc.containsKey('text'), isFalse,
          reason: 'reply 正文字段唯一为 body，不写 text');
    });

    test('createDiscussionReply 写字段恰好等于 reply allowlist（depth=1）', () async {
      await repo.createDiscussionReply(const CreateDiscussionReplyCommand(
        postId: PlaygroundPostId('post-1'),
        rootReplyId: PlaygroundReplyId('root-1'),
        replyToReplyId: PlaygroundReplyId('root-1'),
        body: '讨论正文',
        idempotencyKey: 'disc-key-1',
      ));

      final doc = await singleReplyDoc();
      expect(doc.keys.toSet(), replyCommandAllowlist);
      expect(doc['body'], '讨论正文');
      expect(doc['is_tombstoned'], isFalse);
      expect(doc['depth'], 1);
      expect(doc['root_reply_id'], 'root-1');
      expect(doc['reply_to_reply_id'], 'root-1');
      expect(doc.containsKey('status'), isFalse);
      expect(doc.containsKey('is_root'), isFalse);
      expect(doc.containsKey('author_app_user_id'), isFalse);
    });

    test('createRootReply 无 idempotencyKey 时键集合 = allowlist 减去 idempotency_key',
        () async {
      await repo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('post-2'),
        body: '无幂等键',
      ));
      final doc = await singleReplyDoc();
      final expected = Set<String>.from(replyCommandAllowlist)
        ..remove('idempotency_key');
      expect(doc.keys.toSet(), expected);
    });

    test('tombstoneReply 只写 is_tombstoned:true（无 status）', () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc('reply-t')
          .set({
        'body': '待删',
        'post_id': 'post-1',
        'depth': 0,
        'author_provider_uid': uid,
        'is_tombstoned': false,
      });

      await repo.tombstoneReply(const DeleteReplyCommand(
        replyId: PlaygroundReplyId('reply-t'),
        idempotencyKey: 'tomb-key-1',
      ));

      final snap = await firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc('reply-t')
          .get();
      final doc = snap.data()!;
      expect(doc['is_tombstoned'], isTrue,
          reason: 'tombstoneReply 必须写 is_tombstoned:true');
      expect(doc.containsKey('status'), isFalse,
          reason: 'tombstoneReply 不得写 status');
    });
  });

  group('ReplyCommand DTO 映射', () {
    test('createRootReply 返回安全 PublicReply（depth 0 / rootReplyId null）', () async {
      final reply = await repo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('post-1'),
        body: '根回复',
        techniqueTags: ['qimen'],
      ));

      expect(reply.publicReplyId.value, isNotEmpty);
      expect(reply.postId.value, 'post-1');
      expect(reply.body, '根回复');
      expect(reply.depth, 0);
      expect(reply.rootReplyId, isNull);
      expect(reply.replyToReplyId, isNull);
      expect(reply.isTombstoned, isFalse);
      expect(reply.author.publicPresentationUserId.value, isNotEmpty);
      expect(reply.author.displayAlias, isNotEmpty);
      expect(reply.techniqueTags, ['qimen']);
    });

    test('createDiscussionReply 返回安全 PublicReply（depth 1 / rootReplyId）', () async {
      final reply = await repo.createDiscussionReply(
          const CreateDiscussionReplyCommand(
        postId: PlaygroundPostId('post-1'),
        rootReplyId: PlaygroundReplyId('root-1'),
        body: '讨论',
      ));

      expect(reply.depth, 1);
      expect(reply.rootReplyId?.value, 'root-1');
      expect(reply.body, '讨论');
      expect(reply.isTombstoned, isFalse);
    });

    test('editReply 更新 body 并返回新 DTO', () async {
      final reply = await repo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('post-1'),
        body: '原始',
      ));
      final edited = await repo.editReply(EditReplyCommand(
        replyId: reply.publicReplyId,
        body: '已编辑',
      ));
      expect(edited.body, '已编辑');
      expect(edited.updatedAt, isNotNull);
    });
  });

  group('公开 DTO 敏感字段扫描', () {
    test('createRootReply 返回的 PublicReply 不含 provider uid / presentation_identity_id',
        () async {
      final reply = await repo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('post-1'),
        body: '敏感扫描',
      ));
      final dump = _dump(reply);
      for (final key in sensitiveBlacklist) {
        expect(dump, isNot(contains(key)),
            reason: '公开 DTO 不得含敏感键 $key');
      }
      expect(dump, isNot(contains(uid)),
          reason: '公开 DTO 不得含 provider uid 原文');
    });
  });
}
