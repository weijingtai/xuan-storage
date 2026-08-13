/// RED: Firestore 直写回复命令仓库（Task 4）。
///
/// Design §3.3/§4.4/§6.2：
/// - root/discussion 两层回复；depth 0/1 语义；
/// - 跨帖、跨 root、负 depth、第三层、墓碑目标全部拒绝；
/// - 公开 reply + reply owner + revision 同批写入，公开字段零内部 UID；
/// - one-time anonymous 首次回复 transaction 创建私有 thread presentation
///   mapping（`{postId}__{providerUid}` 随机 128-bit），后续回复复用；
///   伪造、跨 actor 复用、重复创建 mapping 失败；
/// - edit 追加 revision；tombstone 清空 body/chart/media/techniques。
library;

import 'dart:convert';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firestore_direct_playground_reply_command_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const fixturePath = 'test/playground/fixtures/direct_write_schema_v1.json';

  const aliceUid = 'alice-uid';
  const aliceApp = 'app-alice';
  const alicePresentation = 'pub_alice_pres_128bit';
  const aliceAlias = '玄友0001';

  const bobUid = 'bob-uid';
  const bobApp = 'app-bob';
  const bobPresentation = 'pub_bob_pres_128bit';
  const bobAlias = '玄友0002';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late FirestoreDirectPlaygroundReplyCommandRepository repo;
  late Map<String, dynamic> schema;
  late List<String> replyRequiredKeys;

  Future<void> seedIdentity(String uid, String app, String pres, String alias) {
    return firestore.collection('identity_map').doc(uid).set({
      'app_user_id': app,
      'provider_uid': uid,
      'provider_id': 'firebase',
      'public_presentation_id': pres,
      'public_display_alias': alias,
    });
  }

  /// 预置一个 active 帖子（直写，status=active）。
  Future<String> seedPost({
    String postId = 'post-1',
    String ownerUid = aliceUid,
  }) async {
    await firestore.collection('playground_posts').doc(postId).set({
      'id': postId,
      'text': '母帖',
      'presentation_mode': 'stableAlias',
      'presentation_identity_id': alicePresentation,
      'presentation_display_alias': aliceAlias,
      'presentation_avatar_url': null,
      'public_profile_ref': null,
      'status': 'active',
      'allowed_chart_technique_ids': <String>[],
      'attachments': <dynamic>[],
      'has_chart': false,
      'revision_no': 1,
      'current_revision_id': 'r0000000001',
      'idempotency_key': 'seed',
      'payload_hash': 'seed',
      'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updated_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    await firestore.collection('playground_post_owners').doc(postId).set({
      'content_id': postId,
      'provider_uid': ownerUid,
      'app_user_id': aliceApp,
      'public_presentation_id': alicePresentation,
      'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    return postId;
  }

  setUpAll(() {
    schema =
        jsonDecode(File(fixturePath).readAsStringSync()) as Map<String, dynamic>;
    replyRequiredKeys = ((schema['collections']['playground_replies']
            as Map<String, dynamic>)['required'] as List<dynamic>)
        .cast<String>();
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final mockUser = MockUser(uid: bobUid, isAnonymous: false);
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    repo = FirestoreDirectPlaygroundReplyCommandRepository(
      firestore: firestore,
      auth: mockAuth,
    );
    await seedIdentity(bobUid, bobApp, bobPresentation, bobAlias);
    await seedIdentity(aliceUid, aliceApp, alicePresentation, aliceAlias);
  });

  group('createRootReply（§6.2）', () {
    test('创建 reply + owner + revision 1，公开字段零内部 UID', () async {
      final postId = await seedPost();
      final reply = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postId),
        body: '根回复',
        idempotencyKey: 'idem-root-1',
      ));

      final replyId = reply.publicReplyId.value;

      final replyData = (await firestore
              .collection('playground_replies')
              .doc(replyId)
              .get())
          .data()!;
      expect(replyData.keys.toSet(), replyRequiredKeys.toSet());

      // 公开 reply 零内部 UID。
      for (final key in replyData.keys) {
        if (key == 'created_at' || key == 'updated_at') continue;
        expect(replyData[key], isNot(equals(bobUid)),
            reason: '公开 reply 字段 $key 不得等于 provider UID');
        expect(replyData[key], isNot(equals(bobApp)),
            reason: '公开 reply 字段 $key 不得等于 canonical appUserId');
      }
      expect(
          replyData.keys.any((k) =>
              k.contains('provider_uid') ||
              k.contains('app_user_id') ||
              k.startsWith('author_')),
          isFalse);

      expect(replyData['post_id'], postId);
      expect(replyData['depth'], 0);
      expect(replyData['root_reply_id'], isNull);
      expect(replyData['reply_to_reply_id'], isNull);
      expect(replyData['is_tombstoned'], isFalse);
      expect(replyData['body'], '根回复');
      expect(replyData['revision_no'], 1);
      expect(replyData['current_revision_id'], 'r0000000001');
      expect(replyData['presentation_mode'], 'stableAlias');
      expect(replyData['presentation_identity_id'], bobPresentation);
      expect(replyData['presentation_display_alias'], bobAlias);

      // owner 文档。
      final owner = (await firestore
              .collection('playground_reply_owners')
              .doc(replyId)
              .get())
          .data()!;
      expect(owner['content_id'], replyId);
      expect(owner['provider_uid'], bobUid);
      expect(owner['app_user_id'], bobApp);

      // revision 1。
      final rev = (await firestore
              .collection('playground_replies')
              .doc(replyId)
              .collection('revisions')
              .doc('r0000000001')
              .get())
          .data()!;
      expect(rev['revision_no'], 1);
      expect(rev['body'], '根回复');
    });

    test('one-time anonymous 首次回复创建 thread presentation mapping 并复用',
        () async {
      final postId = await seedPost();

      final first = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postId),
        body: '匿名根回复1',
        presentationMode: PlaygroundPresentationMode.oneTimeAnonymous,
        idempotencyKey: 'idem-anon-root-1',
      ));
      final firstId = first.publicReplyId.value;

      // mapping 文档已创建：`{postId}__{providerUid}`。
      final mappingDoc = await firestore
          .collection('playground_thread_presentations')
          .doc('${postId}__$bobUid')
          .get();
      expect(mappingDoc.exists, isTrue);
      final mapping = mappingDoc.data()!;
      expect(mapping['post_id'], postId);
      expect(mapping['provider_uid'], bobUid);
      expect(mapping['presentation_identity_id'], isNotEmpty);
      expect(mapping['presentation_identity_id'], hasLength(32),
          reason: '128-bit 随机 ID 应为 32 位 hex');

      final presentationId = mapping['presentation_identity_id'];
      final firstData = (await firestore
              .collection('playground_replies')
              .doc(firstId)
              .get())
          .data()!;
      expect(firstData['presentation_mode'], 'oneTimeAnonymous');
      expect(firstData['presentation_identity_id'], presentationId);
      expect(firstData['presentation_display_alias'], '匿名用户');

      // 后续回复复用同一 mapping（不重复创建）。
      final second = await repo.createDiscussionReply(CreateDiscussionReplyCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: PlaygroundReplyId(firstId),
        body: '匿名讨论回复',
        presentationMode: PlaygroundPresentationMode.oneTimeAnonymous,
        idempotencyKey: 'idem-anon-disc-1',
      ));
      final secondData = (await firestore
              .collection('playground_replies')
              .doc(second.publicReplyId.value)
              .get())
          .data()!;
      expect(secondData['presentation_identity_id'], presentationId);

      // 同帖内稳定，跨帖不同。
      final post2 = await seedPost(postId: 'post-2');
      final other = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(post2),
        body: '另一帖匿名',
        presentationMode: PlaygroundPresentationMode.oneTimeAnonymous,
        idempotencyKey: 'idem-anon-post2',
      ));
      final otherMapping = (await firestore
              .collection('playground_thread_presentations')
              .doc('${post2}__$bobUid')
              .get())
          .data()!;
      expect(otherMapping['presentation_identity_id'], isNot(presentationId),
          reason: '跨帖不可关联，必须使用不同随机 ID');
      final otherData = (await firestore
              .collection('playground_replies')
              .doc(other.publicReplyId.value)
              .get())
          .data()!;
      expect(otherData['presentation_identity_id'],
          otherMapping['presentation_identity_id']);
    });
  });

  group('createDiscussionReply（§6.2）', () {
    test('depth=1，root 必须存在且同帖、depth=0、未墓碑', () async {
      final postId = await seedPost();
      final root = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postId),
        body: '根',
        idempotencyKey: 'idem-disc-root-1',
      ));

      final disc = await repo.createDiscussionReply(CreateDiscussionReplyCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: root.publicReplyId,
        body: '讨论',
        idempotencyKey: 'idem-disc-1',
      ));

      final discData = (await firestore
              .collection('playground_replies')
              .doc(disc.publicReplyId.value)
              .get())
          .data()!;
      expect(discData['depth'], 1);
      expect(discData['root_reply_id'], root.publicReplyId.value);
    });

    test('root 不存在 → notFound', () async {
      final postId = await seedPost();
      expect(
        () => repo.createDiscussionReply(CreateDiscussionReplyCommand(
          postId: PlaygroundPostId(postId),
          rootReplyId: PlaygroundReplyId('missing-root'),
          body: '讨论',
          idempotencyKey: 'idem-disc-missing',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.notFound)
            .having((e) => e.machineCode, 'machineCode', 'content/not-found')),
      );
    });

    test('跨帖 root → invalidArgument', () async {
      final postA = await seedPost(postId: 'post-a');
      final postB = await seedPost(postId: 'post-b');
      final rootB = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postB),
        body: 'B 的根',
        idempotencyKey: 'idem-root-b',
      ));

      expect(
        () => repo.createDiscussionReply(CreateDiscussionReplyCommand(
          postId: PlaygroundPostId(postA),
          rootReplyId: rootB.publicReplyId,
          body: '跨帖讨论',
          idempotencyKey: 'idem-disc-cross',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)),
      );
    });

    test('reply-to 指向 depth=1 回复 → 第三层拒绝', () async {
      final postId = await seedPost();
      final root = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postId),
        body: '根',
        idempotencyKey: 'idem-root-3',
      ));
      final disc = await repo.createDiscussionReply(CreateDiscussionReplyCommand(
        postId: PlaygroundPostId(postId),
        rootReplyId: root.publicReplyId,
        body: '讨论1',
        idempotencyKey: 'idem-disc-3a',
      ));

      expect(
        () => repo.createDiscussionReply(CreateDiscussionReplyCommand(
          postId: PlaygroundPostId(postId),
          rootReplyId: root.publicReplyId,
          replyToReplyId: disc.publicReplyId,
          body: '第三层',
          idempotencyKey: 'idem-disc-3b',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
            .having((e) => e.machineCode, 'machineCode',
                'validation/invalid-payload')),
      );
    });

    test('reply-to 指向墓碑目标 → 拒绝', () async {
      final postId = await seedPost();
      final root = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postId),
        body: '根',
        idempotencyKey: 'idem-root-tb',
      ));
      // 将 root 直接标记墓碑（模拟目标已删）。
      await firestore.collection('playground_replies').doc(root.publicReplyId.value).update({
        'is_tombstoned': true,
      });

      expect(
        () => repo.createDiscussionReply(CreateDiscussionReplyCommand(
          postId: PlaygroundPostId(postId),
          rootReplyId: root.publicReplyId,
          body: '回复墓碑',
          idempotencyKey: 'idem-disc-tb',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.tombstoned)),
      );
    });
  });

  group('editReply / tombstoneReply（§4.3）', () {
    test('edit 追加连续 revision', () async {
      final postId = await seedPost();
      final reply = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postId),
        body: 'v1',
        idempotencyKey: 'idem-edit-root',
      ));

      final edited = await repo.editReply(EditReplyCommand(
        replyId: reply.publicReplyId,
        body: 'v2',
        idempotencyKey: 'idem-edit-root-2',
      ));
      expect(edited.body, 'v2');

      final data = (await firestore
              .collection('playground_replies')
              .doc(reply.publicReplyId.value)
              .get())
          .data()!;
      expect(data['body'], 'v2');
      expect(data['revision_no'], 2);
      expect(data['current_revision_id'], 'r0000000002');

      final rev2 = (await firestore
              .collection('playground_replies')
              .doc(reply.publicReplyId.value)
              .collection('revisions')
              .doc('r0000000002')
              .get())
          .data()!;
      expect(rev2['body'], 'v2');
      expect(rev2['parent_id'], 'r0000000001');
    });

    test('tombstone 清空 body/chart/media/techniques，公开读不泄漏', () async {
      final postId = await seedPost();
      final reply = await repo.createRootReply(CreateRootReplyCommand(
        postId: PlaygroundPostId(postId),
        body: '要删除的回复',
        techniqueTags: ['六爻'],
        idempotencyKey: 'idem-tb-root',
      ));

      await repo.tombstoneReply(DeleteReplyCommand(
        replyId: reply.publicReplyId,
        idempotencyKey: 'idem-tb-root-2',
      ));

      final data = (await firestore
              .collection('playground_replies')
              .doc(reply.publicReplyId.value)
              .get())
          .data()!;
      expect(data['is_tombstoned'], isTrue);
      expect(data['body'], '');
      expect(data['technique_tags'], isEmpty);
      expect(data['chart_attachment'], isNull);
      expect(data['media_attachments'], isEmpty);
      expect(data['revision_no'], 2);
    });
  });
}
