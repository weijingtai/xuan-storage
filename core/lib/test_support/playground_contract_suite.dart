/// playground 云端公开分享契约套件（S2 Phase 7）。
///
/// 【为什么存在】`repository-interface-playground` 的
/// `verifyXxxRepositoryContract` 是**端口级契约**（验证接口行为），不验证
/// S2 的缓存分层 / 缓存裁定 / EXIF 剥离。本套件是 **RemoteDataSource 级
/// 契约**：工厂注入 + 拓扑参数（沿用 `signaling_contract_suite.dart` 模式），
/// 任何实现组合（firebase 真实现 / 内存 fake）都跑同一套断言。
///
/// 【消费方式】套件在 core 的 `test_support`，不走 barrel（沿用 D3 决定）。
/// 消费方 `import 'package:persistence_core/test_support/playground_contract_suite.dart'`，
/// 在**实现包**（如 firebase）的测试里注入工厂跑。
///
/// 【缓存裁定断言（A3/A5/A6）】
/// - C3 帖子正文缓存命中：缓存预置后 getPost 必须返回缓存内容（不依赖远端）。
/// - C4 点赞数不缓存：直接改远端后立刻读，必须拿到新值（缓存实现会红）。
/// - C5 收藏态不缓存：直接改远端后立刻读，必须拿到新值（缓存实现会红）。
/// - C6 EXIF 剥离：喂含 GPS 的 JPEG，剥离后字节流查不到 GPS 标签。
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/playground_remote_data_source.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 运行帖子契约（C1 帖子 CRUD + C3 缓存命中）。
///
/// 参数说明：
/// - [topologyName]: 拓扑名，仅用于测试分组展示。
/// - [makeRepository]: 构造组合 Repository（Cached 层）。
/// - [makeRemote]: 构造远端（Firebase 实现或内存 fake）。
/// - [makeCacheStore]: 构造缓存 store；**必须与 makeRepository 共享同一
///   实例**（否则 C3 的「预置缓存」断言无从谈起）。
FutureOr<void> runPlaygroundPostContractSuite({
  required String topologyName,
  required FutureOr<PlaygroundPostRepository> Function() makeRepository,
  required FutureOr<PlaygroundPostRemoteDataSource> Function() makeRemote,
  required FutureOr<PlaygroundPostCacheStore> Function() makeCacheStore,
}) {
  group('契约 · 帖子 · $topologyName', () {
    test('C1 帖子 CRUD 全流程', () async {
      final repo = await makeRepository();

      final created = await repo.createPost(
        const CreatePostCommand(text: '契约测试帖文'),
      );
      expect(created.text, equals('契约测试帖文'));

      final fetched = await repo.getPost(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.text, equals('契约测试帖文'));

      final edited = await repo.editPost(
        EditPostCommand(postId: created.id, text: '已编辑正文'),
      );
      expect(edited.text, equals('已编辑正文'));

      final reread = await repo.getPost(created.id);
      expect(reread!.text, equals('已编辑正文'));

      final deleted = await repo.deletePost(DeletePostCommand(postId: created.id));
      expect(deleted.isTombstoned, isTrue);
    });

    test('C3 缓存命中：帖子正文从缓存读（远端无此帖也能返回）', () async {
      final cache = await makeCacheStore();
      final repo = await makeRepository();

      // 预置缓存（不经过远端 createPost）。
      final seeded = PlaygroundPost(
        id: PlaygroundPostId('c3-cached-post'),
        text: '缓存中的正文',
        authorUserId: const PlaygroundUserId('u-c3'),
        createdAt: DateTime(2026, 8, 6),
      );
      await cache.upsertPost(seeded);

      // 远端从未见过该帖，getPost 必须命中缓存。
      final got = await repo.getPost(seeded.id);
      expect(got, isNotNull, reason: 'C3: 缓存预置后 getPost 必须命中缓存');
      expect(got!.text, equals('缓存中的正文'));
      expect(got.id, equals(seeded.id));
    });

    test('C3 缓存未命中：远端读取后回写缓存', () async {
      final remote = await makeRemote();
      final repo = await makeRepository();

      // 远端创建（不经 repo），缓存为空 → repo.getPost 应走远端并回写。
      final remotePost = await remote.createPost(
        const CreatePostCommand(text: '远端直建帖子'),
      );
      final got = await repo.getPost(remotePost.id);
      expect(got, isNotNull);
      expect(got!.text, equals('远端直建帖子'));

      // 回写断言：远端删帖后，缓存仍能提供正文。
      await remote.deletePost(DeletePostCommand(postId: remotePost.id));
      final fromCache = await repo.getPost(remotePost.id);
      expect(fromCache, isNotNull, reason: 'C3: 远端删除后应命中缓存');
    });
  });
}

/// 运行 Feed 契约（C2 Feed 翻页边界）。
FutureOr<void> runPlaygroundFeedContractSuite({
  required String topologyName,
  required FutureOr<PlaygroundFeedRepository> Function() makeFeedRepository,
  required FutureOr<PlaygroundPostRemoteDataSource> Function() makePostRemote,
  required FutureOr<PlaygroundPostCacheStore> Function() makeCacheStore,
}) {
  group('契约 · Feed · $topologyName', () {
    test('C2 Feed 空页：无帖子时返回空列表', () async {
      final repo = await makeFeedRepository();
      final page = await repo.getLatestFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.latest),
      );
      expect(page.items, isEmpty);
    });

    test('C2 Feed 翻页：多帖分页返回 + 正文回写缓存', () async {
      final remote = await makePostRemote();
      final cache = await makeCacheStore();
      final repo = await makeFeedRepository();

      // 造 3 帖（绕过 Feed 层直接写远端）。
      for (var i = 0; i < 3; i++) {
        await remote.createPost(CreatePostCommand(text: 'feed-$i'));
      }

      final page = await repo.getLatestFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.latest, limit: 2),
      );
      expect(page.items, hasLength(2));

      // 不变量：hasMore 与 nextCursor 必须一致。
      expect(page.hasMore, equals(page.nextCursor != null),
          reason: 'C2: hasMore 必须与 nextCursor 存在性一致');

      // 无条件续翻：只要实现返回了游标就必须可继续（同值 created_at 时
      // 实现可能返回空续页，但不得抛异常、不得与首页重复）。
      final nextCursor = page.nextCursor;
      if (nextCursor != null) {
        final next = await repo.getLatestFeed(
          GetFeedQuery(
            tab: PlaygroundFeedTab.latest,
            limit: 2,
            cursor: nextCursor,
          ),
        );
        final firstPageIds = page.items.map((p) => p.id).toSet();
        for (final post in next.items) {
          expect(firstPageIds.contains(post.id), isFalse,
              reason: 'C2: 续页不得与首页重复');
        }
      }

      // 翻页结果逐条回写帖子缓存。
      for (final post in page.items) {
        final cached = await cache.getPost(post.id);
        expect(cached, isNotNull, reason: 'C2: Feed 翻页必须回写帖子正文缓存');
      }
    });

    test('C2 Feed 最后一页：取完后 hasMore=false 且 nextCursor=null', () async {
      final remote = await makePostRemote();
      final repo = await makeFeedRepository();

      // 造 3 帖，limit 10 一次取完 → 命中最后一页语义。
      for (var i = 0; i < 3; i++) {
        await remote.createPost(CreatePostCommand(text: 'last-$i'));
      }

      final page = await repo.getLatestFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.latest, limit: 10),
      );
      expect(page.items, hasLength(3));
      expect(page.hasMore, isFalse,
          reason: 'C2: 取完最后一页后 hasMore 必须为 false');
      expect(page.nextCursor, isNull,
          reason: 'C2: 取完最后一页后 nextCursor 必须为 null');
    });

    test('C2 Feed 游标失效：伪造/过期 cursor 回退首页或返回空页', () async {
      final repo = await makeFeedRepository();

      // 无 cursor 首页（可观测基准）。
      final baseline = await repo.getLatestFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.latest, limit: 5),
      );

      // 伪造 cursor（base64 解码失败 / 路径不存在）。实现二选一：
      // 回退首页（本仓 Firebase 实现）或返回空页 —— 两者都不得抛未识别异常。
      final fakeCursor = PlaygroundCursor('not-a-real-cursor-%%%');
      final page = await repo.getLatestFeed(
        GetFeedQuery(
          tab: PlaygroundFeedTab.latest,
          limit: 5,
          cursor: fakeCursor,
        ),
      );

      final baselineIds = baseline.items.map((p) => p.id).toSet();
      final sameAsHome =
          page.items.length == baseline.items.length &&
          page.items.every((p) => baselineIds.contains(p.id));
      expect(page.items.isEmpty || sameAsHome, isTrue,
          reason: 'C2: 游标失效必须回退首页或返回空页（不得返回错乱页）');
    });

    test('C2 Feed tab 路由语义：各 tab 返回符合其过滤语义的集合', () async {
      final remote = await makePostRemote();
      final repo = await makeFeedRepository();

      // 造 3 帖：createPost 不写 reply_status / recommendation_score。
      // 语义：pendingDivination 要求 reply_status=pending（缺字段不匹配 → 空）；
      // latest 返回全部 active 帖；recommended 按 score 排序（缺省兜底）。
      for (var i = 0; i < 3; i++) {
        await remote.createPost(CreatePostCommand(text: 'tab-$i'));
      }

      final pending = await repo.getPendingDivinationFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.pendingDivination, limit: 5),
      );
      expect(pending.items, isEmpty,
          reason: 'C2: 无 reply_status=pending 的帖子时待占卜 tab 必须为空'
              '（若路由错到 latest 会返回 3 帖）');

      final latest = await repo.getLatestFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.latest, limit: 5),
      );
      expect(latest.items, hasLength(3),
          reason: 'C2: latest tab 必须返回全部 active 帖');

      final recommended = await repo.getRecommendedFeed(
        const GetFeedQuery(tab: PlaygroundFeedTab.recommended, limit: 5),
      );
      expect(recommended.items, hasLength(3),
          reason: 'C2: recommended tab 必须返回全部 active 帖（按 score 兜底排序）');
    });
  });
}

/// 运行点赞契约（C4 点赞数/点赞态不缓存）。
///
/// 关键：通过 [makeLikeRemote] **直接改远端值**，再经 Repository 立刻读，
/// 必须拿到新值 —— 若实现把点赞态/计数缓存，本测试红（变异 C8 的靶点）。
FutureOr<void> runPlaygroundLikeContractSuite({
  required String topologyName,
  required FutureOr<PlaygroundLikeRepository> Function() makeLikeRepository,
  required FutureOr<PlaygroundLikeRemoteDataSource> Function() makeLikeRemote,
}) {
  group('契约 · 点赞 · $topologyName', () {
    test('C4 点赞态不缓存：改远端后立刻读必须拿到新值', () async {
      final remote = await makeLikeRemote();
      final repo = await makeLikeRepository();
      const postId = PlaygroundPostId('c4-post');

      await remote.setLike(const SetLikeCommand(postId: postId, liked: true));
      final liked = await repo.isLiked(postId: postId);
      expect(liked, isTrue, reason: 'C4: 远端已点赞，立刻读必须为 true（不缓存）');

      await remote.setLike(const SetLikeCommand(postId: postId, liked: false));
      final unliked = await repo.isLiked(postId: postId);
      expect(unliked, isFalse,
          reason: 'C4: 远端已取赞，立刻读必须为 false（不缓存）');
    });

    test('C4 点赞数不缓存：改远端后立刻读必须拿到新值', () async {
      final remote = await makeLikeRemote();
      final repo = await makeLikeRepository();
      const postId = PlaygroundPostId('c4-count-post');

      final count0 = await repo.getLikeCount(postId: postId);
      expect(count0, 0);

      await remote.setLike(const SetLikeCommand(postId: postId, liked: true));
      final count1 = await repo.getLikeCount(postId: postId);
      expect(count1, 1, reason: 'C4: 点赞后立刻读计数必须为 1（不缓存）');
    });
  });
}

/// 运行收藏契约（C5 收藏态不缓存）。
FutureOr<void> runPlaygroundBookmarkContractSuite({
  required String topologyName,
  required FutureOr<PlaygroundBookmarkRepository> Function()
      makeBookmarkRepository,
  required FutureOr<PlaygroundBookmarkRemoteDataSource> Function()
      makeBookmarkRemote,
}) {
  group('契约 · 收藏 · $topologyName', () {
    test('C5 收藏态不缓存：改远端后立刻读必须拿到新值', () async {
      final remote = await makeBookmarkRemote();
      final repo = await makeBookmarkRepository();
      const postId = PlaygroundPostId('c5-post');

      await remote.setBookmark(
        const SetBookmarkCommand(postId: postId, bookmarked: true),
      );
      final bookmarked = await repo.isBookmarked(postId);
      expect(bookmarked, isTrue,
          reason: 'C5: 远端已收藏，立刻读必须为 true（不缓存）');

      await remote.setBookmark(
        const SetBookmarkCommand(postId: postId, bookmarked: false),
      );
      final unbookmarked = await repo.isBookmarked(postId);
      expect(unbookmarked, isFalse,
          reason: 'C5: 远端已取消收藏，立刻读必须为 false（不缓存）');
    });
  });
}

/// 运行媒体契约（C6 EXIF 剥离）。
///
/// [makeStripExif] 注入实际的剥离函数（firebase 的 `stripExif`），
/// 断言剥离后字节流不含 GPS 标签（A4）。变异自检 C7 在实现包内做：
/// 临时删除剥离调用 → 本测试必须红。
FutureOr<void> runPlaygroundMediaContractSuite({
  required String topologyName,
  required FutureOr<Uint8List> Function(Uint8List bytes) makeStripExif,
}) {
  group('契约 · 媒体 · $topologyName', () {
    test('C6 EXIF 剥离：喂 GPS 图片，输出查不到 GPS 标签', () async {
      final strip = makeStripExif;

      // 手工构造 JPEG：SOI + EXIF APP1（含 GPS 标签）+ 普通 APP0 + EOI。
      final gpsTag = [0x47, 0x50, 0x53]; // "GPS"
      final exifPayload = <int>[
        0x45, 0x78, 0x69, 0x66, 0x00, 0x00, // "Exif\0\0"
        ...gpsTag,
      ];
      final app1Length = exifPayload.length + 2;
      final jpeg = <int>[
        0xFF, 0xD8, // SOI
        0xFF, 0xE1, // APP1
        (app1Length >> 8) & 0xFF, app1Length & 0xFF,
        ...exifPayload,
        0xFF, 0xE0, // APP0（JFIF，应保留）
        0x00, 0x04, 0x4A, 0x46, 0x49, 0x46, // "JFIF"
        0xFF, 0xD9, // EOI
      ];

      final input = Uint8List.fromList(jpeg);
      final stripped = await strip(input);

      // 断言 1：剥离前后字节不同（EXIF 确实被移除）。
      expect(stripped.length, isNot(equals(input.length)),
          reason: 'C6: 含 EXIF 的输入剥离后必须变小');

      // 断言 2：输出中查不到 GPS 标签字节序列。
      final hasGps = _containsSequence(stripped, gpsTag);
      expect(hasGps, isFalse, reason: 'C6: 剥离后字节流不得含 GPS 标签');

      // 断言 3：非 EXIF 段（JFIF/APP0）保留。
      final hasJfif = _containsSequence(stripped, [
        0x4A, 0x46, 0x49, 0x46, // "JFIF"
      ]);
      expect(hasJfif, isTrue, reason: 'C6: 非 EXIF 段必须保留');
    });

    test('C6 EXIF 剥离：无 EXIF 的 JPEG 原样保留', () async {
      final strip = makeStripExif;
      final cleanJpeg = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x04, 0x4A, 0x46, 0x49, 0x46, 0xFF, 0xD9,
      ]);
      final out = await strip(cleanJpeg);
      expect(out, equals(cleanJpeg),
          reason: 'C6: 无 EXIF 的输入应原样返回');
    });
  });
}

/// 运行评论契约（C9 评论 CRUD 全流程）。
FutureOr<void> runPlaygroundReplyContractSuite({
  required String topologyName,
  required FutureOr<PlaygroundReplyRepository> Function() makeReplyRepository,
  required FutureOr<PlaygroundReplyRemoteDataSource> Function() makeReplyRemote,
}) {
  group('契约 · 评论 · $topologyName', () {
    test('C9 评论 CRUD 全流程', () async {
      final repo = await makeReplyRepository();
      const postId = PlaygroundPostId('c9-post');

      final root = await repo.createRootReply(
        const CreateRootReplyCommand(postId: postId, body: '根回复正文'),
      );
      expect(root.body, equals('根回复正文'));

      final discussion = await repo.createDiscussionReply(
        CreateDiscussionReplyCommand(
          postId: postId,
          rootReplyId: root.id,
          body: '讨论回复正文',
        ),
      );
      expect(discussion.body, equals('讨论回复正文'));

      var page = await repo.getReplies(
        const GetRepliesQuery(postId: postId),
      );
      expect(page.items, hasLength(2));

      final editedRoot = await repo.editRootReply(
        EditReplyCommand(replyId: root.id, body: '根回复已编辑'),
      );
      expect(editedRoot.body, equals('根回复已编辑'));

      page = await repo.getReplies(const GetRepliesQuery(postId: postId));
      final editedInList = page.items.any(
        (r) => r is PlaygroundRootReply && r.body == '根回复已编辑',
      );
      expect(editedInList, isTrue);

      await repo.deleteReply(DeleteReplyCommand(replyId: discussion.id));
      page = await repo.getReplies(const GetRepliesQuery(postId: postId));
      expect(page.items, hasLength(1), reason: 'C9: 删除后列表只剩根回复');
    });
  });
}

/// 运行审核契约（C10 举报 + 人工下架 + 紧急下架）。
FutureOr<void> runPlaygroundModerationContractSuite({
  required String topologyName,
  required FutureOr<PlaygroundModerationRepository> Function()
      makeModerationRepository,
  required FutureOr<PlaygroundPostRemoteDataSource> Function() makePostRemote,
}) {
  group('契约 · 审核 · $topologyName', () {
    test('C10 举报 + 下架 + 紧急下架', () async {
      final remote = await makePostRemote();
      final moderation = await makeModerationRepository();

      final post = await remote.createPost(
        const CreatePostCommand(text: '待审核帖子'),
      );

      // 举报：必须针对真实帖子 id（验收 A2：不得硬编码）。
      await moderation.reportContent(
        ReportContentCommand(
          postId: post.id,
          reason: PlaygroundReportReason.spam,
          description: '契约测试举报',
        ),
      );

      // 人工下架 → quarantined。
      await moderation.quarantinePost(post.id);
      final quarantined = await remote.getPost(post.id);
      expect(quarantined?.status, PlaygroundPostStatus.quarantined,
          reason: 'C10: 人工下架后状态必须为 quarantined');

      // 紧急下架 → tombstoned。
      await moderation.emergencyTakeDown(post.id);
      final takenDown = await remote.getPost(post.id);
      expect(takenDown?.status, PlaygroundPostStatus.tombstoned,
          reason: 'C10: 紧急下架后状态必须为 tombstoned');
    });
  });
}

/// 字节序列包含检测。
bool _containsSequence(List<int> haystack, List<int> needle) {
  if (needle.isEmpty || haystack.length < needle.length) return false;
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}
