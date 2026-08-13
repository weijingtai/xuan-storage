/// RED-A：BLOCK-02 reply/post payload 契约测试（生产 adapter 直写路径）。
///
/// 断言真实 production adapter（FirebasePlaygroundReplyRepository /
/// FirebasePlaygroundPostRepository）写入 Firestore 的 payload 字段集
/// **恰好等于** production Rules allowlist（矩阵 §2.1 / PHASE-4 §3.1）：
///
/// - `createRootReply`/`createDiscussionReply`：
///   键集合 == reply allowlist；含 `is_tombstoned:false`、`body`；
///   不含 `status` / `is_root` / `author_app_user_id` / `text`；
/// - `deleteReply`：只写 `is_tombstoned:true`（无 `status`）；
/// - `getReplies`：查询条件为 `where('is_tombstoned', ==false)`
///   （无 `status` where）；
/// - `createPost`：键集合 == post allowlist（不含 `author_app_user_id`）。
///
/// 使用 `FakeFirebaseFirestore` 捕获 write payload；生产 Rules 双证据
/// 由 RED-B（firestore.rules.test.ts + 真 emulator）覆盖。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_post_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_reply_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

/// reply 字段 allowlist（覆盖矩阵 §2.1，Rules `replyCreateFieldsOk` 全量）。
const replyAllowlist = <String>{
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

/// post 字段 allowlist（Rules `postCreateFieldsOk` 全量，客户端不写
/// `author_app_user_id`）。
const postAllowlist = <String>{
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = 'payload-test-uid';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebasePlaygroundIdentityResolver identityResolver;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: uid, isAnonymous: false),
      signedIn: true,
    );
    identityResolver = FirebasePlaygroundIdentityResolver(
      firestore: firestore,
      auth: auth,
    );
  });

  FirebasePlaygroundReplyRepository makeReplyRepo() {
    return FirebasePlaygroundReplyRepository(
      firestore: firestore,
      auth: auth,
      identityResolver: identityResolver,
    );
  }

  FirebasePlaygroundPostRepository makePostRepo() {
    return FirebasePlaygroundPostRepository(
      firestore: firestore,
      auth: auth,
      identityResolver: identityResolver,
    );
  }

  Future<Map<String, dynamic>> singleReplyDoc() async {
    final snaps =
        await firestore.collection(PlaygroundFirestoreSchema.replies).get();
    expect(snaps.docs, hasLength(1), reason: '应恰好写入一条 reply');
    return snaps.docs.single.data();
  }

  Future<Map<String, dynamic>> singlePostDoc() async {
    final snaps =
        await firestore.collection(PlaygroundFirestoreSchema.posts).get();
    expect(snaps.docs, hasLength(1), reason: '应恰好写入一条 post');
    return snaps.docs.single.data();
  }

  group('reply payload 契约（RED-A）', () {
    test('createRootReply 写字段恰好等于 reply allowlist，含 is_tombstoned:false 与 body',
        () async {
      final repo = makeReplyRepo();

      await repo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('post-1'),
        body: '根回复正文',
        techniqueTags: ['六爻'],
        mediaAttachments: [],
        idempotencyKey: 'root-key-1',
      ));

      final doc = await singleReplyDoc();
      final keys = doc.keys.toSet();

      // 键集合恰好等于 allowlist（含 idempotency_key）。
      expect(keys, replyAllowlist,
          reason: 'createRootReply 写字段必须恰好等于 reply allowlist');

      expect(doc['body'], '根回复正文');
      expect(doc['is_tombstoned'], isFalse);
      expect(doc['depth'], 0);

      // 禁止字段：不得写 status / is_root / author_app_user_id / text。
      expect(doc.containsKey('status'), isFalse,
          reason: 'reply 写路径零 status（tombstone 唯一语义为 is_tombstoned）');
      expect(doc.containsKey('is_root'), isFalse,
          reason: 'is_root 已移除，root/discussion 判别改用 depth');
      expect(doc.containsKey('author_app_user_id'), isFalse,
          reason: '客户端不再写 author_app_user_id');
      expect(doc.containsKey('text'), isFalse,
          reason: 'reply 正文字段唯一为 body，不写 text');
    });

    test('createDiscussionReply 写字段恰好等于 reply allowlist（depth=1）',
        () async {
      final repo = makeReplyRepo();

      await repo.createDiscussionReply(const CreateDiscussionReplyCommand(
        postId: PlaygroundPostId('post-1'),
        rootReplyId: PlaygroundReplyId('root-1'),
        replyToReplyId: PlaygroundReplyId('root-1'),
        body: '讨论回复正文',
        idempotencyKey: 'disc-key-1',
      ));

      final doc = await singleReplyDoc();
      final keys = doc.keys.toSet();

      expect(keys, replyAllowlist,
          reason: 'createDiscussionReply 写字段必须恰好等于 reply allowlist');

      expect(doc['body'], '讨论回复正文');
      expect(doc['is_tombstoned'], isFalse);
      expect(doc['depth'], 1);
      expect(doc['root_reply_id'], 'root-1');
      expect(doc['reply_to_reply_id'], 'root-1');

      expect(doc.containsKey('status'), isFalse);
      expect(doc.containsKey('is_root'), isFalse);
      expect(doc.containsKey('author_app_user_id'), isFalse);
      expect(doc.containsKey('text'), isFalse);
    });

    test('createRootReply 无 idempotencyKey 时键集合 = allowlist 减去 idempotency_key',
        () async {
      final repo = makeReplyRepo();

      await repo.createRootReply(const CreateRootReplyCommand(
        postId: PlaygroundPostId('post-2'),
        body: '无幂等键',
      ));

      final doc = await singleReplyDoc();
      final expected = Set<String>.from(replyAllowlist)
        ..remove('idempotency_key');
      expect(doc.keys.toSet(), expected);
    });

    test('deleteReply 只写 is_tombstoned:true（无 status）', () async {
      // seed 一条既有 reply 文档。
      await firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc('reply-delete-1')
          .set({
        'body': '待删除',
        'post_id': 'post-1',
        'depth': 0,
        'author_provider_uid': uid,
        'is_tombstoned': false,
      });

      final repo = makeReplyRepo();
      await repo.deleteReply(const DeleteReplyCommand(
        replyId: PlaygroundReplyId('reply-delete-1'),
      ));

      final snap = await firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .doc('reply-delete-1')
          .get();
      final doc = snap.data()!;

      expect(doc['is_tombstoned'], isTrue,
          reason: 'deleteReply 必须写 is_tombstoned:true');
      expect(doc.containsKey('status'), isFalse,
          reason: 'deleteReply 不得写 status（tombstone 唯一语义为 is_tombstoned）');
    });

    test('getReplies 查询 where(is_tombstoned == false)，不含 status where',
        () async {
      // seed 4 条 reply：r1/r2 存活、r3 tombstone、r4 旧 status 字段为
      // active 但 is_tombstoned=true —— 若 query 用 status where 会错误返回 r4。
      Future<void> seed(String id, Map<String, dynamic> data) =>
          firestore
              .collection(PlaygroundFirestoreSchema.replies)
              .doc(id)
              .set(data);

      await seed('r1', {
        'body': '根',
        'post_id': 'post-q',
        'depth': 0,
        'author_provider_uid': 'a',
        'is_tombstoned': false,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'technique_tags': <String>[],
        'media_attachments': <dynamic>[],
        'revisions': <dynamic>[],
      });
      await seed('r2', {
        'body': '讨论',
        'post_id': 'post-q',
        'depth': 1,
        'root_reply_id': 'r1',
        'author_provider_uid': 'b',
        'is_tombstoned': false,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 2)),
        'media_attachments': <dynamic>[],
        'revisions': <dynamic>[],
      });
      await seed('r3', {
        'body': '已删',
        'post_id': 'post-q',
        'depth': 0,
        'author_provider_uid': 'a',
        'is_tombstoned': true,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 3)),
        'technique_tags': <String>[],
        'media_attachments': <dynamic>[],
        'revisions': <dynamic>[],
      });
      await seed('r4', {
        'body': '旧 status active 但 tombstone',
        'post_id': 'post-q',
        'depth': 0,
        'author_provider_uid': 'c',
        'status': 'active', // 旧字段——is_tombstoned 才是权威
        'is_tombstoned': true,
        'created_at': Timestamp.fromDate(DateTime(2026, 1, 4)),
        'media_attachments': <dynamic>[],
        'revisions': <dynamic>[],
      });

      final repo = makeReplyRepo();
      final page = await repo.getReplies(
        const GetRepliesQuery(postId: PlaygroundPostId('post-q'), limit: 20),
      );

      final returnedIds =
          page.items.map((e) => (e as dynamic).id.value).toList();
      expect(returnedIds, containsAll(['r1', 'r2']));
      expect(returnedIds, isNot(contains('r3')),
          reason: 'is_tombstoned:true 不得返回');
      expect(returnedIds, isNot(contains('r4')),
          reason: '查询必须用 is_tombstoned 而非 status');
    });
  });

  group('post payload 契约（RED-A）', () {
    test('createPost 写字段恰好等于 post allowlist（无 author_app_user_id）',
        () async {
      final repo = makePostRepo();

      await repo.createPost(const CreatePostCommand(
        text: '帖子正文',
        allowedChartTechniqueIds: ['六爻'],
        idempotencyKey: 'post-key-1',
      ));

      final doc = await singlePostDoc();
      final keys = doc.keys.toSet();

      expect(keys, postAllowlist,
          reason: 'createPost 写字段必须恰好等于 post allowlist');

      expect(doc['text'], '帖子正文');
      expect(doc['status'], PlaygroundPostStatus.active.name);
      expect(doc['author_provider_uid'], uid);
      expect(doc.containsKey('author_app_user_id'), isFalse,
          reason: '客户端不写 author_app_user_id（decode 回退 author_provider_uid）');
    });

    test('createPost 无 idempotencyKey 时键集合 = allowlist 减去 idempotency_key',
        () async {
      final repo = makePostRepo();

      await repo.createPost(const CreatePostCommand(text: '无幂等键'));

      final doc = await singlePostDoc();
      final expected = Set<String>.from(postAllowlist)..remove('idempotency_key');
      expect(doc.keys.toSet(), expected);
    });
  });
}
