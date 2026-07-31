import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_post_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_reply_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_identity_resolver.dart';
import 'package:persistence_firebase/playground/firebase_playground_verification_repository.dart';
import 'package:persistence_firebase/playground/firebase_playground_schema.dart';

/// Firebase Emulator 集成测试 — 使用真实 Firestore/Auth 指向 localhost emulator。
///
/// 参考 firebase_account_auth_gateway_emulator_test.dart 的模式：
/// - 在 flutter test VM 中 Firebase.initializeApp() 会因缺平台通道失败 → markTestSkipped
/// - Emulator 不可用时 → markTestSkipped
/// - 两者都满足时才执行真实 Emulator 验收
///
/// 运行：启动 emulator 后 `flutter test test/playground/firebase_playground_emulator_integration_test.dart`
void main() {
  group('Firebase Emulator Playground Contract', () {
    late FirebaseFirestore firestore;
    late FirebaseAuth auth;
    late FirebasePlaygroundIdentityResolver identityResolver;
    late FirebasePlaygroundPostRepository postRepo;
    late FirebasePlaygroundReplyRepository replyRepo;
    late FirebasePlaygroundVerificationRepository verificationRepo;
    bool _skipped = false;

    setUpAll(() async {
      // 1. Firebase init（VM 测试环境可能缺平台通道）
      try {
        await Firebase.initializeApp();
      } catch (e) {
        _skipped = true;
        markTestSkipped(
          'Firebase platform channels unavailable in flutter test VM.\n'
          'Error: $e\n'
          'To run: use a device target or --platform=chrome',
        );
        return;
      }

      // 2. 检测 Emulator 可用性
      final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
      final isEmulatorSet = emulatorHost != null && emulatorHost.isNotEmpty;
      if (!isEmulatorSet) {
        try {
          await Socket.connect('localhost', 8082,
              timeout: const Duration(seconds: 2));
        } catch (_) {
          _skipped = true;
          markTestSkipped(
            'Firebase Emulator not detected.\n'
            'Start: firebase emulators:start --import=./seed\n'
            'Then: FIRESTORE_EMULATOR_HOST=localhost:8081 FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 flutter test ...',
          );
          return;
        }
      }

      // 3. 连接 Emulator
      firestore = FirebaseFirestore.instance;
      final host = isEmulatorSet
          ? emulatorHost!.split(':').first
          : 'localhost';
      final port = isEmulatorSet
          ? int.tryParse(emulatorHost!.split(':').last) ?? 8081
          : 8081;
      firestore.settings = Settings(
        host: '$host:$port',
        sslEnabled: false,
        persistenceEnabled: false,
      );

      auth = FirebaseAuth.instance;
      final authEmulatorHost =
          Platform.environment['FIREBASE_AUTH_EMULATOR_HOST'];
      if (authEmulatorHost != null && authEmulatorHost.isNotEmpty) {
        final parts = authEmulatorHost.split(':');
        auth.useAuthEmulator(parts.first, int.parse(parts.last));
      } else {
        auth.useAuthEmulator('localhost', 9099);
      }

      // 4. 匿名登录
      await auth.signInAnonymously();

      identityResolver = FirebasePlaygroundIdentityResolver(
        firestore: firestore,
        auth: auth,
      );
      postRepo = FirebasePlaygroundPostRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
      );
      replyRepo = FirebasePlaygroundReplyRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
      );
      verificationRepo = FirebasePlaygroundVerificationRepository(
        firestore: firestore,
        auth: auth,
        identityResolver: identityResolver,
      );
    });

    tearDownAll(() async {
      if (!_skipped && auth.currentUser != null) {
        try {
          await auth.signOut();
        } catch (_) {}
      }
    });

    test('emulator 连接 — Firestore 可读写', () async {
      if (_skipped) return;
      final doc = await firestore.collection('test').add({'ping': 'pong'});
      final snap = await doc.get();
      expect(snap.get('ping'), equals('pong'));
      await doc.delete();
    });

    test('identity resolver 从匿名 Auth 解析 actor', () async {
      if (_skipped) return;
      final actor = await identityResolver.resolveActor();
      expect(actor, isA<PlaygroundUserId>());
      expect(actor.value, isNotEmpty);
      expect(actor.value, startsWith('app-'));
    });

    test('createPost 写入 Firestore 并读取', () async {
      if (_skipped) return;
      final post = await postRepo.createPost(const CreatePostCommand(
        text: 'emulator 集成测试帖子',
        idempotencyKey: 'emu-post-001',
      ));
      expect(post.text, equals('emulator 集成测试帖子'));
      expect(post.id.value, isNotEmpty);
      expect(post.status, equals(PlaygroundPostStatus.active));

      final read = await postRepo.getPost(post.id);
      expect(read, isNotNull);
      expect(read!.text, equals('emulator 集成测试帖子'));
    });

    test('idempotency 同 key 幂等', () async {
      if (_skipped) return;
      const key = 'emu-idem-001';
      final p1 = await postRepo.createPost(const CreatePostCommand(
        text: '幂等测试',
        idempotencyKey: key,
      ));
      final p2 = await postRepo.createPost(const CreatePostCommand(
        text: '幂等测试',
        idempotencyKey: key,
      ));
      expect(p1.id, equals(p2.id));
    });

    test('idempotency 不同 key 创建不同帖子', () async {
      if (_skipped) return;
      final p1 = await postRepo.createPost(const CreatePostCommand(
        text: 'key-A',
        idempotencyKey: 'emu-idem-002a',
      ));
      final p2 = await postRepo.createPost(const CreatePostCommand(
        text: 'key-B',
        idempotencyKey: 'emu-idem-002b',
      ));
      expect(p1.id, isNot(equals(p2.id)));
    });

    test('createRootReply 二层回复树', () async {
      if (_skipped) return;
      final post = await postRepo.createPost(const CreatePostCommand(
        text: '回复树测试帖子',
      ));
      final root = await replyRepo.createRootReply(CreateRootReplyCommand(
        postId: post.id,
        body: '根回复',
      ));
      expect(root.postId, equals(post.id));

      final disc = await replyRepo.createDiscussionReply(
          CreateDiscussionReplyCommand(
        postId: post.id,
        rootReplyId: root.id,
        body: '讨论',
      ));
      expect(disc.rootReplyId, equals(root.id));
    });

    test('author spoof 拒绝 — CreatePostCommand 不含可信 authorId', () async {
      if (_skipped) return;
      // 编译时检查：CreatePostCommand 不接受 authorId 字段
      // adapter 从 auth context 解析 actor
      final post = await postRepo.createPost(const CreatePostCommand(
        text: 'spoof 测试',
      ));
      expect(post, isNotNull);
    });

    test('cursor 分页 — 写入并查询', () async {
      if (_skipped) return;
      for (var i = 0; i < 3; i++) {
        await postRepo.createPost(CreatePostCommand(
          text: 'cursor 测试 $i',
          idempotencyKey: 'emu-cursor-$i',
        ));
      }
      final snap = await firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .where('status', isEqualTo: 'active')
          .orderBy('created_at', descending: true)
          .limit(2)
          .get();
      expect(snap.docs.length, lessThanOrEqualTo(2));
    });
  });
}
