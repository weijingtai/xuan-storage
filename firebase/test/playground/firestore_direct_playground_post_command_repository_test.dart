/// RED: Firestore 直写帖子命令仓库（Task 3）。
///
/// Design §3.2/§3.3/§4.1/§4.3/§4.4/§6.1/§8：
/// - 同一 transaction 创建公开 post + 私有 owner + 首个 append-only revision；
/// - 公开 post 不含任何内部 UID（provider_uid/app_user_id/author_* 命中 0）；
/// - stableAlias 展示身份来自 identity_map；oneTimeAnonymous 帖子展示 ID 为
///   `post_{postId}`；
/// - edit 追加连续 revision；tombstone 先保存最后 revision 再清空公开正文；
/// - 幂等 replay / conflict / 隐私 fail-closed。
library;

import 'dart:convert';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firestore_direct_playground_post_command_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const fixturePath = 'test/playground/fixtures/direct_write_schema_v1.json';

  const providerUid = 'alice';
  const appUserId = 'app-alice';
  const publicPresentationId = 'pub_alice_128bit';
  const publicDisplayAlias = '玄友0001';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late FirestoreDirectPlaygroundPostCommandRepository repo;
  late Map<String, dynamic> schema;
  late List<String> postRequiredKeys;

  setUpAll(() {
    schema =
        jsonDecode(File(fixturePath).readAsStringSync()) as Map<String, dynamic>;
    postRequiredKeys = ((schema['collections']['playground_posts']
            as Map<String, dynamic>)['required'] as List<dynamic>)
        .cast<String>();
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final mockUser = MockUser(uid: providerUid, isAnonymous: false);
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    repo = FirestoreDirectPlaygroundPostCommandRepository(
      firestore: firestore,
      auth: mockAuth,
    );
    await firestore.collection('identity_map').doc(providerUid).set({
      'app_user_id': appUserId,
      'provider_uid': providerUid,
      'provider_id': 'firebase',
      'public_presentation_id': publicPresentationId,
      'public_display_alias': publicDisplayAlias,
    });
  });

  group('createPost（§3.2/§6.1/§8）', () {
    test('同一 transaction 创建 post + owner + revision r0000000001', () async {
      const key = 'idem-post-1';
      final post = await repo.createPost(const CreatePostCommand(
        text: '首帖',
        allowedChartTechniqueIds: ['六爻'],
        idempotencyKey: key,
      ));

      final postId = post.publicPostId.value;

      // post 文档 exact keys == fixture required。
      final postSnap = await firestore
          .collection('playground_posts')
          .doc(postId)
          .get();
      final postData = postSnap.data()!;
      expect(postData.keys.toSet(), postRequiredKeys.toSet());

      // 公开 post 内部 UID 命中 0：逐字段检查，不因展示 ID 与 provider UID
      // 共享子串产生误报（如 pub_alice_128bit 含 "alice"）。
      for (final key in postData.keys) {
        if (key == 'created_at' || key == 'updated_at') continue;
        final value = postData[key];
        // 内部 UID 是精确的独立字段值或字段键，不做子串匹配。
        expect(value, isNot(equals(providerUid)),
            reason: '公开 post 字段 $key 不得等于 provider UID');
        expect(value, isNot(equals(appUserId)),
            reason: '公开 post 字段 $key 不得等于 canonical appUserId');
      }
      expect(postData.keys.any((k) => k.contains('provider_uid') ||
          k.contains('app_user_id') ||
          k.startsWith('author_')), isFalse,
          reason: '公开 post 不得含内部身份字段名');
      expect(postData['presentation_identity_id'], isNot(equals(providerUid)));
      expect(postData['presentation_identity_id'], isNot(equals(appUserId)));

      expect(postData['text'], '首帖');
      expect(postData['status'], 'active');
      expect(postData['revision_no'], 1);
      expect(postData['current_revision_id'], 'r0000000001');
      expect(postData['idempotency_key'], key);
      expect(postData['payload_hash'], isNotEmpty);
      expect(postData['presentation_mode'], 'stableAlias');
      expect(postData['presentation_identity_id'], publicPresentationId);
      expect(postData['presentation_display_alias'], publicDisplayAlias);
      expect(postData['has_chart'], isTrue);

      // owner 文档。
      final ownerSnap = await firestore
          .collection('playground_post_owners')
          .doc(postId)
          .get();
      final owner = ownerSnap.data()!;
      expect(owner['content_id'], postId);
      expect(owner['provider_uid'], providerUid);
      expect(owner['app_user_id'], appUserId);
      expect(owner['public_presentation_id'], publicPresentationId);

      // revision 1。
      final revSnap = await firestore
          .collection('playground_posts')
          .doc(postId)
          .collection('revisions')
          .doc('r0000000001')
          .get();
      expect(revSnap.exists, isTrue);
      final rev = revSnap.data()!;
      expect(rev['revision_no'], 1);
      expect(rev['parent_id'], '');
      expect(rev['body'], '首帖');
      expect(rev['presentation_identity_id'], publicPresentationId);
    });

    test('oneTimeAnonymous 帖子展示 ID 为 post_{postId}，alias 匿名用户', () async {
      final post = await repo.createPost(const CreatePostCommand(
        text: '匿名帖',
        presentationMode: PlaygroundPresentationMode.oneTimeAnonymous,
        idempotencyKey: 'idem-anon-1',
      ));
      final postId = post.publicPostId.value;

      final postData = (await firestore
              .collection('playground_posts')
              .doc(postId)
              .get())
          .data()!;
      expect(postData['presentation_mode'], 'oneTimeAnonymous');
      expect(postData['presentation_identity_id'], 'post_$postId');
      expect(postData['presentation_display_alias'], '匿名用户');
      expect(postData['presentation_avatar_url'], isNull);
      expect(postData['public_profile_ref'], isNull);
    });

    test('同 key 同 payload replay → 幂等返回同一文档', () async {
      const key = 'idem-replay-1';
      final first = await repo.createPost(const CreatePostCommand(
        text: '幂等帖',
        idempotencyKey: key,
      ));
      final second = await repo.createPost(const CreatePostCommand(
        text: '幂等帖',
        idempotencyKey: key,
      ));

      expect(second.publicPostId, first.publicPostId);

      final posts = await firestore.collection('playground_posts').get();
      expect(posts.docs, hasLength(1));
    });

    test('同 key 不同 payload → conflict + idempotency/payload-conflict', () async {
      const key = 'idem-conflict-1';
      await repo.createPost(const CreatePostCommand(
        text: '原文',
        idempotencyKey: key,
      ));

      expect(
        () => repo.createPost(const CreatePostCommand(
          text: '不同内容',
          idempotencyKey: key,
        )),
        throwsA(
          isA<PlaygroundError>()
              .having((e) => e.code, 'code', PlaygroundErrorCode.conflict)
              .having(
                  (e) => e.machineCode, 'machineCode', 'idempotency/payload-conflict'),
        ),
      );
    });

    test('缺 idempotency key → invalid-idempotency-key', () async {
      expect(
        () => repo.createPost(const CreatePostCommand(text: '无 key')),
        throwsA(
          isA<PlaygroundError>()
              .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
              .having((e) => e.machineCode, 'machineCode', 'idempotency/invalid-key'),
        ),
      );
    });

    test('隐私字段非空 → privacy/storage-unavailable，任何 Firestore 调用前拒绝', () async {
      expect(
        () => repo.createPost(const CreatePostCommand(
          text: '带隐私',
          privacyContext: PlaygroundPrivacyContext(gender: 'male'),
          idempotencyKey: 'idem-privacy-1',
        )),
        throwsA(
          isA<PlaygroundError>()
              .having((e) => e.code, 'code', PlaygroundErrorCode.invalidArgument)
              .having((e) => e.machineCode, 'machineCode',
                  'privacy/storage-unavailable'),
        ),
      );
      // 未写入任何文档。
      expect(await firestore.collection('playground_posts').get(), isNotNull);
      expect((await firestore.collection('playground_posts').get()).docs, isEmpty);
    });

    test('identity_map 缺失 → identity/not-ready（fail closed）', () async {
      final freshFirestore = FakeFirebaseFirestore();
      final freshAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: providerUid, isAnonymous: false),
        signedIn: true,
      );
      final freshRepo = FirestoreDirectPlaygroundPostCommandRepository(
        firestore: freshFirestore,
        auth: freshAuth,
      );

      expect(
        () => freshRepo.createPost(const CreatePostCommand(
          text: '无身份',
          idempotencyKey: 'idem-noid-1',
        )),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.unavailable)
            .having((e) => e.machineCode, 'machineCode', 'identity/not-ready')),
      );
    });
  });

  group('editPost（§4.3 append-only revision）', () {
    test('edit 追加连续 revision 并推进 revision_no/current_revision_id', () async {
      final post = await repo.createPost(const CreatePostCommand(
        text: '版本1',
        idempotencyKey: 'idem-edit-1',
      ));
      final postId = post.publicPostId.value;

      final edited = await repo.editPost(EditPostCommand(
        postId: PlaygroundPostId(postId),
        text: '版本2',
        idempotencyKey: 'idem-edit-1b',
      ));
      expect(edited.body, '版本2');

      final postData = (await firestore
              .collection('playground_posts')
              .doc(postId)
              .get())
          .data()!;
      expect(postData['text'], '版本2');
      expect(postData['revision_no'], 2);
      expect(postData['current_revision_id'], 'r0000000002');

      final rev2 = (await firestore
              .collection('playground_posts')
              .doc(postId)
              .collection('revisions')
              .doc('r0000000002')
              .get())
          .data()!;
      expect(rev2['revision_no'], 2);
      expect(rev2['parent_id'], 'r0000000001');
      expect(rev2['body'], '版本2');

      // revision 1 保持不可变。
      final rev1 = (await firestore
              .collection('playground_posts')
              .doc(postId)
              .collection('revisions')
              .doc('r0000000001')
              .get())
          .data()!;
      expect(rev1['body'], '版本1');
    });
  });

  group('tombstonePost（§4.3）', () {
    test('先保存最后 revision 再清空 text/attachments/techniques', () async {
      final post = await repo.createPost(const CreatePostCommand(
        text: '要删除',
        allowedChartTechniqueIds: ['六爻'],
        idempotencyKey: 'idem-del-1',
      ));
      final postId = post.publicPostId.value;

      await repo.tombstonePost(DeletePostCommand(
        postId: PlaygroundPostId(postId),
        idempotencyKey: 'idem-del-1b',
      ));

      final postData = (await firestore
              .collection('playground_posts')
              .doc(postId)
              .get())
          .data()!;
      expect(postData['status'], 'tombstoned');
      expect(postData['text'], '');
      expect(postData['attachments'], isEmpty);
      expect(postData['allowed_chart_technique_ids'], isEmpty);
      expect(postData['revision_no'], 2);

      // 墓碑 revision 保存最后正文快照。
      final rev2 = (await firestore
              .collection('playground_posts')
              .doc(postId)
              .collection('revisions')
              .doc('r0000000002')
              .get())
          .data()!;
      expect(rev2['body'], '要删除');
      expect(rev2['revision_no'], 2);

      // 公开读不泄漏已删除正文。
      final public = await repo.getPublicPost(PlaygroundPostId(postId));
      expect(public, isNotNull);
      expect(public!.body, isNull);
      expect(public.displayStatus, PublicPostDisplayStatus.tombstoned);
    });
  });
}
