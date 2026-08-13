/// RED: Firestore 直写 command support 单元契约（Task 2）。
///
/// 覆盖 Design §4.4 schema fixture 合同、§8 幂等 ID 约定、§9 可观察错误映射，
/// 以及 §3 身份与公开/私有 payload 分离。
library;

import 'dart:convert';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firestore_direct_playground_command_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const fixturePath = 'test/playground/fixtures/direct_write_schema_v1.json';

  group('direct_write_schema_v1 fixture 合同（§4.4/§5）', () {
    late Map<String, dynamic> schema;

    setUpAll(() {
      final raw = File(fixturePath).readAsStringSync();
      schema = jsonDecode(raw) as Map<String, dynamic>;
    });

    test('public post 不含 author_* 内部身份字段', () {
      final post = schema['collections']['playground_posts'] as Map<String, dynamic>;
      final postKeys = (post['required'] as List<dynamic>).cast<String>();
      expect(postKeys.where((key) => key.startsWith('author_')), isEmpty,
          reason: '公开帖子不得保存 provider/canonical author 字段');
      expect(schema, contains('collections'));
      expect(postKeys, contains('presentation_mode'));
      expect(postKeys, contains('presentation_identity_id'));
      expect(postKeys, contains('presentation_display_alias'));
      expect(postKeys, contains('revision_no'));
      expect(postKeys, contains('current_revision_id'));
      expect(postKeys, contains('idempotency_key'));
      expect(postKeys, contains('payload_hash'));
    });

    test('schema 包含 owner/thread-presentation/revision 集合', () {
      final collections = schema['collections'] as Map<String, dynamic>;
      expect(collections, contains('playground_post_owners'));
      expect(collections, contains('playground_reply_owners'));
      expect(collections, contains('playground_like_owners'));
      expect(collections, contains('playground_thread_presentations'));
      expect(collections, contains('playground_likes'));
      expect(collections, contains('playground_bookmarks'));
      expect(collections, contains('playground_verifications'));
      expect(collections, contains('playground_outcome_feedback'));
      expect(collections, contains('revisions'));
    });

    test('revision_no / public_presentation_id 在 schema 中出现', () {
      final raw = schema.toString();
      expect(raw, contains('revision_no'));
      expect(raw, contains('public_presentation_id'));
    });

    test('machine_error_codes 全部可映射为合法 PlaygroundErrorCode', () {
      final codes = schema['machine_error_codes'] as Map<String, dynamic>;
      expect(codes, isNotEmpty);
      for (final entry in codes.entries) {
        expect(entry.key, isNotEmpty, reason: 'machine code 必须非空');
        final value = entry.value as String;
        final enumName = value.replaceFirst('PlaygroundErrorCode.', '');
        expect(PlaygroundErrorCode.values.map((e) => e.name), contains(enumName),
            reason: 'fixture 引用了不存在的枚举值 $value');
      }
    });
  });

  group('requireDirectActor（§3）', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;

    const providerUid = 'alice';
    const appUserId = 'app-alice';
    const publicPresentationId = 'pub_alice_128bit';
    const publicDisplayAlias = '玄友0001';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      final mockUser = MockUser(uid: providerUid, isAnonymous: false);
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    });

    test('解析完整 actor：内部 app ID + 公开 ID/alias 分离', () async {
      await firestore.collection('identity_map').doc(providerUid).set({
        'app_user_id': appUserId,
        'provider_uid': providerUid,
        'provider_id': 'firebase',
        'public_presentation_id': publicPresentationId,
        'public_display_alias': publicDisplayAlias,
      });

      final actor = await requireDirectActor(
        firestore: firestore,
        auth: mockAuth,
      );

      expect(actor.appUserId, appUserId);
      expect(actor.providerUid, providerUid);
      expect(actor.publicPresentationId, publicPresentationId);
      expect(actor.publicDisplayAlias, publicDisplayAlias);

      // private owner payload 与 public presentation payload 必须分开。
      final owner = actor.ownerPayload(contentId: 'post-1');
      expect(owner['provider_uid'], providerUid);
      expect(owner['app_user_id'], appUserId);
      expect(owner['content_id'], 'post-1');
      expect(owner.containsKey('presentation_display_alias'), isFalse,
          reason: 'owner payload 不得携带公开展示 alias');

      final presentation = actor.presentationPayload();
      expect(presentation['presentation_identity_id'], publicPresentationId);
      expect(presentation['presentation_display_alias'], publicDisplayAlias);
      expect(presentation.containsKey('provider_uid'), isFalse,
          reason: 'public presentation payload 不得携带 provider UID');
      expect(presentation.containsKey('app_user_id'), isFalse,
          reason: 'public presentation payload 不得携带 canonical appUserId');
    });

    test('缺 public_presentation_id → unavailable + identity/not-ready', () async {
      await firestore.collection('identity_map').doc(providerUid).set({
        'app_user_id': appUserId,
        'provider_uid': providerUid,
      });

      expect(
        () => requireDirectActor(firestore: firestore, auth: mockAuth),
        throwsA(
          isA<PlaygroundError>()
              .having((e) => e.code, 'code', PlaygroundErrorCode.unavailable)
              .having((e) => e.machineCode, 'machineCode', 'identity/not-ready'),
        ),
      );
    });

    test('identity_map 不存在 → unavailable + identity/not-ready', () async {
      expect(
        () => requireDirectActor(firestore: firestore, auth: mockAuth),
        throwsA(isA<PlaygroundError>()
            .having((e) => e.code, 'code', PlaygroundErrorCode.unavailable)
            .having((e) => e.machineCode, 'machineCode', 'identity/not-ready')),
      );
    });

    test('未认证 → unauthenticated + auth/unauthenticated', () async {
      mockAuth = MockFirebaseAuth(mockUser: null, signedIn: false);
      expect(
        () => requireDirectActor(firestore: firestore, auth: mockAuth),
        throwsA(
          isA<PlaygroundError>()
              .having((e) => e.code, 'code', PlaygroundErrorCode.unauthenticated)
              .having((e) => e.machineCode, 'machineCode', 'auth/unauthenticated'),
        ),
      );
    });
  });

  group('canonical JSON hash 与确定性文档 ID（§8）', () {
    test('canonical JSON hash 与 key 顺序无关', () {
      final a = canonicalJsonHash({'a': 1, 'b': 'x', 'c': [1, 2]});
      final b = canonicalJsonHash({'c': [1, 2], 'b': 'x', 'a': 1});
      expect(a, equals(b));
      expect(a, hasLength(64), reason: 'SHA-256 hex');
    });

    test('deterministic create ID 固定为 sha256(v1|op|authUid|key)', () {
      const authUid = 'alice';
      const key = 'idem-123';
      const op = 'post-create';
      final id = deterministicCreateId(
        operation: op,
        authUid: authUid,
        idempotencyKey: key,
      );
      final expected = sha256Hex('v1|$op|$authUid|$key');
      expect(id, equals(expected));
      expect(id, hasLength(64));

      // 同 key 同 payload → 稳定；换 key → 不同 ID。
      expect(
        deterministicCreateId(operation: op, authUid: authUid, idempotencyKey: key),
        equals(id),
      );
      expect(
        deterministicCreateId(
            operation: op, authUid: authUid, idempotencyKey: 'idem-456'),
        isNot(equals(id)),
      );
    });
  });

  group('PlaygroundError(code, machineCode) 映射（§9）', () {
    test('machineCode → 合法 PlaygroundErrorCode', () {
      final e = directPlaygroundError(
        code: PlaygroundErrorCode.conflict,
        machineCode: 'idempotency/payload-conflict',
      );
      expect(e.code, PlaygroundErrorCode.conflict);
      expect(e.machineCode, 'idempotency/payload-conflict');
      expect(e.message, isNotEmpty);

      final f = directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'idempotency/invalid-key',
      );
      expect(f.code, PlaygroundErrorCode.invalidArgument);
      expect(f.machineCode, 'idempotency/invalid-key');
    });
  });
}
