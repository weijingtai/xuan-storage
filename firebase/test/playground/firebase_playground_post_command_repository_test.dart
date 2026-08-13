/// Phase 7B：PostCommand adapter（FirebasePlaygroundPostCommandRepository）
/// 契约测试 —— RED → GREEN。
///
/// 断言：
/// 1. payload 契约：createPost 写字段集恰好等于 post Rules allowlist，
///    含 `text`/`status`，不含 `author_app_user_id`；idempotency_key 条件写；
/// 2. DTO 映射：createPost/editPost 返回安全 [PublicPost]
///    （publicPostId/body/author/presentation），公开 DTO 零敏感字段
///    （provider uid / presentation_identity_id 不得出现）；
/// 3. 读路径：getPublicPost 单文档读，tombstone → body 置空且
///    displayStatus=tombstoned，missing → null。
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_schema.dart';
import 'package:persistence_firebase/playground/firebase_playground_post_command_repository.dart';

/// post 字段 allowlist（firestore.rules postCreateFieldsOk 全量，客户端不写
/// author_app_user_id）。
const postCommandAllowlist = <String>{
  'text',
  'allowed_chart_technique_ids',
  'attachments',
  'author_provider_uid',
  'status',
  'idempotency_key',
  'created_at',
  'updated_at',
  'revisions',
  'has_outcome_feedback',
};

/// 公开 DTO 敏感字段黑名单：公开投影绝不能含 provider uid /
/// presentation_identity_id / canonical appUserId。
const sensitiveBlacklist = <String>[
  'author_provider_uid',
  'presentation_identity_id',
  'author_app_user_id',
  'user_provider_uid',
];

/// 递归 dump 对象所有标量值，用于敏感字段扫描。
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

  const uid = 'post-cmd-uid';
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebasePlaygroundPostCommandRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: uid, isAnonymous: false),
      signedIn: true,
    );
    repo = FirebasePlaygroundPostCommandRepository(
      firestore: firestore,
      auth: auth,
    );
  });

  Future<Map<String, dynamic>> singlePostDoc() async {
    final snaps =
        await firestore.collection(PlaygroundFirestoreSchema.posts).get();
    expect(snaps.docs, hasLength(1), reason: '应恰好写入一条 post');
    return snaps.docs.single.data();
  }

  group('PostCommand payload 契约', () {
    test('createPost 写字段恰好等于 post allowlist（无 author_app_user_id）',
        () async {
      await repo.createPost(const CreatePostCommand(
        text: '求测帖',
        allowedChartTechniqueIds: ['liuyao'],
        idempotencyKey: 'post-key-1',
      ));

      final doc = await singlePostDoc();
      final keys = doc.keys.toSet();
      expect(keys, postCommandAllowlist,
          reason: 'createPost 写字段必须恰好等于 post Rules allowlist');

      expect(doc['text'], '求测帖');
      expect(doc['status'], PlaygroundPostStatus.active.name);
      expect(doc['author_provider_uid'], uid);
      expect(doc.containsKey('author_app_user_id'), isFalse,
          reason: '命令 payload 零 author_app_user_id');
    });

    test('createPost 无 idempotencyKey 时键集合 = allowlist 减去 idempotency_key',
        () async {
      await repo.createPost(const CreatePostCommand(text: '无幂等键'));
      final doc = await singlePostDoc();
      final expected = Set<String>.from(postCommandAllowlist)
        ..remove('idempotency_key');
      expect(doc.keys.toSet(), expected);
    });

    test('tombstonePost 只写 status=tombstoned（无 author_app_user_id）', () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc('post-t')
          .set({
        'text': '待删',
        'author_provider_uid': uid,
        'status': 'active',
        'created_at': DateTime.utc(2026, 1, 1),
      });

      await repo.tombstonePost(const DeletePostCommand(
        postId: PlaygroundPostId('post-t'),
        idempotencyKey: 'tomb-key-1',
      ));

      final snap = await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc('post-t')
          .get();
      final doc = snap.data()!;
      expect(doc['status'], PlaygroundPostStatus.tombstoned.name);
      expect(doc.containsKey('author_app_user_id'), isFalse);
    });
  });

  group('PostCommand DTO 映射', () {
    test('createPost 返回安全 PublicPost（含 presentation 与 author）', () async {
      final post = await repo.createPost(const CreatePostCommand(
        text: '求测帖',
        allowedChartTechniqueIds: ['qimen'],
        presentationMode: PlaygroundPresentationMode.stableAlias,
      ));

      expect(post.publicPostId.value, isNotEmpty);
      expect(post.body, '求测帖');
      expect(post.displayStatus, PublicPostDisplayStatus.active);
      expect(post.presentation?.mode, PlaygroundPresentationMode.stableAlias);
      expect(post.author.publicPresentationUserId.value, isNotEmpty);
      expect(post.author.displayAlias, isNotEmpty);
      expect(post.replyCount, 0);
      expect(post.likeCount, 0);
      expect(post.verificationCount, 0);
      expect(post.viewerState.isLiked, isFalse);
      expect(post.viewerState.isBookmarked, isFalse);
    });

    test('getPublicPost 读单文档：active 正文可见', () async {
      await repo.createPost(const CreatePostCommand(text: '正文'));
      final postId = (await firestore
              .collection(PlaygroundFirestoreSchema.posts)
              .get())
          .docs
          .single
          .id;

      final fetched = await repo.getPublicPost(PlaygroundPostId(postId));
      expect(fetched, isNotNull);
      expect(fetched!.body, '正文');
      expect(fetched.displayStatus, PublicPostDisplayStatus.active);
    });

    test('getPublicPost：不存在的帖子 → null', () async {
      final fetched =
          await repo.getPublicPost(const PlaygroundPostId('missing'));
      expect(fetched, isNull);
    });

    test('getPublicPost：tombstone 作者视角 → body 置空、displayStatus=tombstoned',
        () async {
      await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc('tomb-1')
          .set({
        'text': '已删正文',
        'author_provider_uid': uid,
        'status': 'tombstoned',
        'allowed_chart_technique_ids': <String>[],
        'attachments': <dynamic>[],
        'revisions': <dynamic>[],
        'has_outcome_feedback': false,
        'created_at': DateTime.utc(2026, 1, 1),
      });

      final fetched = await repo.getPublicPost(const PlaygroundPostId('tomb-1'));
      expect(fetched, isNotNull);
      expect(fetched!.body, isNull, reason: '墓碑后正文从公开面消失');
      expect(fetched.displayStatus, PublicPostDisplayStatus.tombstoned);
    });

    test('editPost 更新 text 并返回新 DTO', () async {
      final post = await repo.createPost(const CreatePostCommand(text: '原文'));
      final edited = await repo.editPost(EditPostCommand(
        postId: post.publicPostId,
        text: '已编辑',
      ));
      expect(edited.body, '已编辑');
      expect(edited.updatedAt, isNotNull);
    });
  });

  group('公开 DTO 敏感字段扫描', () {
    test('createPost 返回的 PublicPost 不含 provider uid / presentation_identity_id',
        () async {
      final post = await repo.createPost(const CreatePostCommand(
        text: '敏感扫描帖',
        allowedChartTechniqueIds: ['liuyao'],
      ));
      final dump = _dump(post);
      for (final key in sensitiveBlacklist) {
        expect(dump, isNot(contains(key)),
            reason: '公开 DTO 不得含敏感键 $key');
      }
      expect(dump, isNot(contains(uid)),
          reason: '公开 DTO 不得含 provider uid 原文');
    });

    test('getPublicPost 读回 DTO 同样零敏感字段', () async {
      await repo.createPost(const CreatePostCommand(text: '读回帖'));
      final docId = (await firestore
              .collection(PlaygroundFirestoreSchema.posts)
              .get())
          .docs
          .single
          .id;
      final fetched =
          await repo.getPublicPost(PlaygroundPostId(docId));
      final dump = _dump(fetched);
      for (final key in sensitiveBlacklist) {
        expect(dump, isNot(contains(key)),
            reason: '公开 DTO 不得含敏感键 $key');
      }
    });
  });
}
