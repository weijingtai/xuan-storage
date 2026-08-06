# S2 云端公开分享 —— 开发计划

> 2026-08-06 ｜ 基线 main = `62a1e4c` ｜ 基于派工单 `DISPATCH-S2.md` 制定

---

## 一、现状总结

| 维度 | 现状 |
|---|---|
| **接口层** | `repository-interface-playground` 包定义了 13 个 `PlaygroundXxxRepository` 抽象接口，及 734 行的 `InMemoryPlaygroundRepositories` 全量内存 fake |
| **实现层** | `firebase/lib/playground/` 下 15+ 个文件，每个 `FirebasePlaygroundXxxRepository` 直接实现对应接口，内部直接调 Firestore（无抽象层） |
| **已有契约测试** | `repository-interface-playground/lib/src/contracts/` 下有 9 个 `verifyXxxRepositoryContract()` 函数，但它们是**端口级契约**（验证接口行为），不是**RemoteDataSource 级契约**（不验证缓存分层、不验证缓存裁定） |
| **缓存层** | **零**。drift 包目前没有 playground 相关的表/DAO/Store |
| **BlobGateway** | `core/lib/model/blob_gateway.dart` 已定义端口（两阶段上传 + 签名 URL），但 **firebase 实现为零**（只有内存 fake） |
| **媒体上传** | `firebase_playground_media_repository.dart` 已存在，但只是 Firestore 文档登记，没有真正的字节上传管线 |
| **审核** | `firebase_playground_moderation_repository.dart` 只有 `reportContent` 一个方法（1.6K），缺人工下架/紧急下架接口 |
| **契约测试套件模式** | `core/lib/test_support/signaling_contract_suite.dart` 已建立可复用模式（`runXxxContractSuite` 函数 + factory 注入 + 拓扑参数） |

---

## 二、业务层接线逻辑（最关键的部分）

S2 改造后，业务层（UI/use-case）与持久层的接线关系不变，但内部实现变为三层：

```
┌─────────────────────────────────────────────────┐
│  业务层（UI / UseCase）                          │
│  依赖：PlaygroundPostRepository（接口不变）       │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  CachedPlaygroundPostRepository  （NEW）         │
│  实现 PlaygroundPostRepository                  │
│  ┌──────────────────┐  ┌──────────────────────┐ │
│  │ _remote:          │  │ _cache:              │ │
│  │ RemoteDataSource  │  │ PlaygroundCacheStore │ │
│  │ (core 端口)       │  │ (drift 实现)         │ │
│  └────────┬─────────┘  └──────────┬───────────┘ │
└───────────┼───────────────────────┼─────────────┘
            │                       │
┌───────────▼─────────┐  ┌──────────▼─────────────┐
│ firebase/lib/       │  │ drift/lib/              │
│ FirebaseXxxRemoteDS │  │ PlaygroundXxxCacheStore │
│ (现有代码降级)      │  │ (新表 + DAO)            │
└─────────────────────┘  └────────────────────────┘
```

**关键约束**：业务层可见的接口类型（`PlaygroundPostRepository` 等）**不新增、不改名、不改签名**。改动全在接口**背后**的实现类替换。

### 接线点清单

| 业务交互 | 当前接线 | S2 后接线 | 缓存裁定 |
|---|---|---|---|
| 发帖/读帖正文 | `FirebasePlaygroundPostRepository` | `CachedPlaygroundPostRepository` → `FirebasePostRemoteDataSource` | ✅ 缓存 |
| Feed 列表翻页 | `FirebasePlaygroundFeedRepository` | `CachedPlaygroundFeedRepository` → `FirebaseFeedRemoteDataSource` | ✅ 缓存帖子正文 |
| 点赞/取赞 | `FirebasePlaygroundLikeRepository` | `CachedPlaygroundLikeRepository` → `FirebaseLikeRemoteDataSource` | ❌ **不缓存** |
| 收藏/取消收藏 | `FirebasePlaygroundBookmarkRepository` | `CachedPlaygroundBookmarkRepository` → `FirebaseBookmarkRemoteDataSource` | ❌ **不缓存** |
| 评论（回复） | `FirebasePlaygroundReplyRepository` | `CachedPlaygroundReplyRepository` → `FirebaseReplyRemoteDataSource` | ✅ 缓存评论正文 |
| 媒体上传（入口 B） | `FirebasePlaygroundMediaRepository` | `CachedPlaygroundMediaRepository` → `FirebaseMediaRemoteDataSource` + **EXIF 剥离 + 客户端转码 + BlobGateway** | ✅ 媒体缓存 |
| 举报 | `FirebasePlaygroundModerationRepository` | 不变（补齐 `quarantinePost` / `emergencyTakeDown`） | ❌ 不缓存 |

---

## 三、分阶段计划

### Phase 0：审计 —— 产出「已有 / 缺失 / 需降级」三张表

**产出物**：`docs/superpowers/specs/S2-audit.md`

**内容**：
1. 通读 `firebase/lib/playground/` 全部 15+ 文件
2. 对每个 Repository 标注：
   - **已有**：方法完整、可直接提取为 RemoteDataSource
   - **缺失**：接口定义的方法未实现
   - **需降级**：实现完整，但需要把 Firestore 调用抽成 RemoteDataSource 端口方法
3. 对 `repository-interface-playground` 的 13 个端口逐一对照
4. 标注 `BlobGateway` firebase 实现是否存在（若不存在，媒体部分只能做到「接口接通 + fake 全绿」）
5. 标注 `firebase_playground_moderation_repository.dart` 是否缺 `quarantinePost` / `emergencyTakeDown` 方法

**只读，不写代码。完成后上报人类确认。**

---

### Phase 1：RemoteDataSource 端口定义（core）

**产出物**：
- `core/lib/model/playground_remote_data_source.dart`（**新文件**）

**内容**：定义 6 个 RemoteDataSource 抽象接口（仅 S2 范围）：

| 接口 | 对应现有实现 | 方法 |
|---|---|---|
| `PlaygroundPostRemoteDataSource` | `FirebasePlaygroundPostRepository` | `createPost`, `editPost`, `deletePost`, `getPost` |
| `PlaygroundFeedRemoteDataSource` | `FirebasePlaygroundFeedRepository` | `getFeed`, `getRecommendedFeed`, `getPendingDivinationFeed`, `getLatestFeed` |
| `PlaygroundLikeRemoteDataSource` | `FirebasePlaygroundLikeRepository` | `setLike`, `isLiked`, `getLikeCount` |
| `PlaygroundBookmarkRemoteDataSource` | `FirebasePlaygroundBookmarkRepository` | `setBookmark`, `isBookmarked`, `getBookmarkedPosts` |
| `PlaygroundReplyRemoteDataSource` | `FirebasePlaygroundReplyRepository` | `createRootReply`, `createDiscussionReply`, `editRootReply`, `editDiscussionReply`, `deleteReply`, `getReplies` |
| `PlaygroundMediaRemoteDataSource` | `FirebasePlaygroundMediaRepository` | `beginUpload`, `getMediaInfo`, `getDownloadUrl`, `deleteMedia` |

**推荐方案**：RemoteDataSource 的方法签名与 `PlaygroundXxxRepository` 接口**完全一致**（复用 command/return 类型），这样现有 Firebase 实现类只需改 `implements` 声明即可降级。`repository-interface-playground` 的 DTO 已与 Firestore 解耦。

---

### Phase 2：Firebase 实现降级（firebase）

**产出物**：修改 `firebase/lib/playground/` 下 6 个文件

**操作**：
1. 每个 `FirebasePlaygroundXxxRepository` 的 `implements` 声明改为 `implements PlaygroundXxxRemoteDataSource`（当 RemoteDataSource 接口与 Repository 接口签名一致时，只需改 `implements` 声明）
2. 如果 RemoteDataSource 接口签名不同（如返回 Map），则重构方法体
3. 更新 `playground.dart` barrel 导出
4. 更新 `firebase_playground_import_boundary_test.dart` 中的逻辑（如有需要）

**不碰的文件**（不在 S2 范围）：
- `firebase_playground_conversation_repository.dart`
- `firebase_playground_notification_repository.dart`
- `firebase_playground_profile_repository.dart`
- `firebase_playground_outcome_feedback_repository.dart`
- `firebase_playground_verification_repository.dart`
- `firebase_playground_realtime_repository.dart`

---

### Phase 3：缓存层（drift）

**产出物**：
- `drift/lib/playground/playground_post_cache.drift`（表定义）
- `drift/lib/playground/playground_post_cache_store.dart`（DriftAccessor）
- 在 `drift/lib/persistence_drift.dart` 中注册新表

**表设计**：

```sql
CREATE TABLE playground_post_cache (
  post_id TEXT PRIMARY KEY,
  author_user_id TEXT NOT NULL,
  text_content TEXT NOT NULL,
  allowed_chart_technique_ids TEXT NOT NULL,  -- JSON array
  attachment_json TEXT,                        -- JSON，附件元数据
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL,                 -- epoch millis
  updated_at INTEGER,
  cached_at INTEGER NOT NULL,                  -- 缓存写入时间
  reply_count INTEGER NOT NULL DEFAULT 0,
  like_count INTEGER NOT NULL DEFAULT 0        -- 注：仅用于展示，不用于读取
);

CREATE TABLE playground_reply_cache (
  reply_id TEXT PRIMARY KEY,
  post_id TEXT NOT NULL,
  author_user_id TEXT NOT NULL,
  body TEXT NOT NULL,
  depth INTEGER NOT NULL,
  is_root INTEGER NOT NULL,
  root_reply_id TEXT,
  reply_to_reply_id TEXT,
  created_at INTEGER NOT NULL,
  cached_at INTEGER NOT NULL
);
```

**关键裁定**：
- **点赞数不从缓存读**：`like_count` 字段仅用于缓存中的帖子展示（骨架屏），业务层读点赞数必须走 `LikeRemoteDataSource.isLiked` / `getLikeCount`（实时远端查询）
- **收藏态不从缓存读**：`isBookmarked` 必须走远端实时查询

---

### Phase 4：组合 Repository（firebase）

**产出物**：
- `firebase/lib/cached_playground_post_repository.dart`
- `firebase/lib/cached_playground_feed_repository.dart`
- `firebase/lib/cached_playground_like_repository.dart`
- `firebase/lib/cached_playground_bookmark_repository.dart`
- `firebase/lib/cached_playground_reply_repository.dart`
- `firebase/lib/cached_playground_media_repository.dart`

**缓存读写模式**（参照设计稿 §4.3.2 示例）：

```dart
final class CachedPlaygroundPostRepository implements PlaygroundPostRepository {
  final PlaygroundPostRemoteDataSource _remote;
  final PlaygroundPostCacheStore _cache;

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    // 1. 先查缓存
    final cached = await _cache.getPost(postId);
    if (cached != null) return cached;

    // 2. 缓存未命中，走远端
    final remote = await _remote.getPost(postId);
    if (remote == null) return null;

    // 3. 回写缓存
    await _cache.upsertPost(remote);
    return remote;
  }

  @override
  Future<PlaygroundPost> createPost(CreatePostCommand command) async {
    final post = await _remote.createPost(command);
    await _cache.upsertPost(post); // 写穿透
    return post;
  }
}
```

**CachedPlaygroundLikeRepository 关键差异**（不缓存，直接透传）：

```dart
final class CachedPlaygroundLikeRepository implements PlaygroundLikeRepository {
  final PlaygroundLikeRemoteDataSource _remote;

  @override
  Future<bool> isLiked({PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    return _remote.isLiked(postId: postId, replyId: replyId); // 不查缓存
  }

  @override
  Future<int> getLikeCount({PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    return _remote.getLikeCount(postId: postId, replyId: replyId); // 不查缓存
  }
}
```

---

### Phase 5：媒体入口 B（firebase + 新文件）

**产出物**：
- `firebase/lib/media/exif_stripper.dart`（EXIF 剥离工具）
- `firebase/lib/media/client_transcoder.dart`（客户端转码，先做 stub）
- `firebase/lib/media/blob_gateway_firebase.dart`（**若 BlobGateway firebase 实现未交付**，则做一个 fake 实现，标 `@visibleForTesting`）
- 修改 `CachedPlaygroundMediaRepository` 的 `beginUpload` 流程

**媒体上传管线（入口 B）**：

```
系统相册选图
  → ExifStripper.strip(bytes)  // 剥离 EXIF（硬要求）
  → ClientTranscoder.transcode(bytes)  // 转码压缩（先 stub）
  → BlobGateway.beginUpload(visibility: public)  // 登记公开对象
  → 分 chunk 上传
  → BlobGateway.completeUpload()
  → 返回 PlaygroundAttachment（含 mediaObjectId）
```

**EXIF 剥离实现要点**：
- 输入：JPEG/PNG 字节流
- 输出：剥离 EXIF 后的字节流
- 对 JPEG：移除 APP1 标记段（EXIF 数据所在）
- 对 PNG：移除 tEXt/iTXt/zTXt 块（元数据所在）
- 对 HEIC：跳过（iOS 相册已自动转 JPEG）
- 纯 Dart 实现，不依赖原生插件（测试可在 VM 中跑）

**⚠ 若 BlobGateway firebase 实现未交付**：
- 媒体上传只做到 `BlobGateway` 接口接通 + fake 实现全绿
- 在纪要中写明「真云端上传待 BlobGateway 落地」
- 不阻塞 S2-row 的交付

---

### Phase 6：审核补齐（firebase）

**产出物**：修改 `firebase_playground_moderation_repository.dart`

**补齐方法**：
- `quarantinePost(PlaygroundPostId)` —— 人工下架（status → `quarantined`）
- `emergencyTakeDown(PlaygroundPostId)` —— 紧急下架（status → `tombstoned`，直接删除/标记，不经过软删除）

**接口扩展**：需要在 `repository-interface-playground` 的 `PlaygroundModerationRepository` 接口（或 `CachedPlaygroundModerationRepository`）中新增方法。如果该仓库不允许随意增方法，则在 `CachedPlaygroundModerationRepository` 中直接实现（不经过端口）。

---

### Phase 7：契约测试套件（core）

**产出物**：
- `core/lib/test_support/playground_contract_suite.dart`（参照 `signaling_contract_suite.dart` 模式）

**套件包含**：

| 编号 | 测试 | 对应验收 |
|---|---|---|
| C1 | 帖子 CRUD 全流程 | A2 |
| C2 | Feed 翻页（含边界：空页/最后一页/游标失效） | A7 |
| C3 | **缓存命中**：帖子正文从缓存读 | A3 |
| C4 | **点赞数不缓存**：改远端值后立刻读，必须拿到新值 | A3 |
| C5 | **收藏态不缓存**：改远端值后立刻读，必须拿到新值 | A3 |
| C6 | **EXIF 剥离**：喂 GPS 图片，上传前字节流查不到 GPS 标签 | A4 |
| C7 | **EXIF 变异**：删掉剥离步骤，测试必须红 | A5 |
| C8 | **点赞缓存变异**：把点赞数改成走缓存，测试必须红 | A6 |
| C9 | 评论 CRUD 全流程 | A2 |
| C10 | 举报 + 下架 + 紧急下架 | — |

**套件签名**（参照 signaling 模式）：

```dart
FutureOr<void> runPlaygroundPostContractSuite({
  required String topologyName,
  required FutureOr<PlaygroundPostRepository> Function() makeRepository,
  required FutureOr<PlaygroundPostCacheStore> Function() makeCacheStore,
  Duration negativeAssertionGrace = const Duration(milliseconds: 50),
});
```

---

### Phase 8：变异自检

对每条新测试，逐一执行变异注入，记录：

| 测试 | 注入变异 | 预期红在 | 实际红在 |
|---|---|---|---|
| C6 EXIF 剥离 | 删除 `stripExif()` 调用 | 断言：字节流不含 GPS | — |
| C4 点赞数不缓存 | 改为从 `_cache.getLikeCount()` 读取 | 断言：必须拿到新值 | — |

---

## 四、不做的明确边界

| 项目 | 原因 |
|---|---|
| 媒体入口 A（从私有档案发布） | 依赖 S6 + E2EE 密钥 |
| BlobGateway 的 firebase 真云端实现 | 若未交付，另立任务 |
| 私信/通知/个人资料 | 不在 S2 范围 |
| `p2p/` 包 | 明确禁止 |
| `core/lib/model/` 下 S1a 契约 | 明确禁止 |
| 修改 `repository-interface-playground` 端口接口 | 有异议写决定记录上报 |

---

## 五、文件清单

### 新增文件

| 文件 | 包 | 说明 |
|---|---|---|
| `core/lib/model/playground_remote_data_source.dart` | core | 6 个 RemoteDataSource 抽象接口 |
| `core/lib/test_support/playground_contract_suite.dart` | core | 可复用契约测试套件 |
| `drift/lib/playground/playground_post_cache.drift` | drift | 缓存表定义 |
| `drift/lib/playground/playground_post_cache_store.dart` | drift | DriftAccessor 帖子缓存读写 |
| `drift/lib/playground/playground_reply_cache_store.dart` | drift | DriftAccessor 评论缓存 |
| `firebase/lib/cached_playground_post_repository.dart` | firebase | 组合 Repository |
| `firebase/lib/cached_playground_feed_repository.dart` | firebase | 组合 Repository |
| `firebase/lib/cached_playground_like_repository.dart` | firebase | 组合 Repository（不缓存） |
| `firebase/lib/cached_playground_bookmark_repository.dart` | firebase | 组合 Repository（不缓存） |
| `firebase/lib/cached_playground_reply_repository.dart` | firebase | 组合 Repository |
| `firebase/lib/cached_playground_media_repository.dart` | firebase | 组合 Repository |
| `firebase/lib/media/exif_stripper.dart` | firebase | EXIF 剥离 |
| `firebase/lib/media/client_transcoder.dart` | firebase | 客户端转码（stub） |
| `firebase/lib/media/blob_gateway_firebase.dart` | firebase | BlobGateway fake 实现 |
| `docs/superpowers/specs/S2-audit.md` | — | Phase 0 审计三张表 |

### 修改文件

| 文件 | 改动 |
|---|---|
| `firebase/lib/playground/firebase_playground_post_repository.dart` | 改 `implements` 为 RemoteDataSource |
| `firebase/lib/playground/firebase_playground_feed_repository.dart` | 同上 |
| `firebase/lib/playground/firebase_playground_like_repository.dart` | 同上 |
| `firebase/lib/playground/firebase_playground_bookmark_repository.dart` | 同上 |
| `firebase/lib/playground/firebase_playground_reply_repository.dart` | 同上 |
| `firebase/lib/playground/firebase_playground_media_repository.dart` | 同上 |
| `firebase/lib/playground/firebase_playground_moderation_repository.dart` | 补齐 quarantinePost / emergencyTakeDown |
| `firebase/lib/playground/playground.dart` | 更新 barrel 导出 |
| `firebase/test/playground/firebase_playground_import_boundary_test.dart` | 更新文件路径（如有需要） |
| `drift/lib/persistence_drift.dart` | 注册新表 |
| `firebase/pubspec.yaml` | 如有新依赖 |
| `drift/pubspec.yaml` | 如有新依赖 |

### 不修改的文件

| 文件 | 原因 |
|---|---|
| `firebase/lib/playground/firebase_playground_conversation_repository.dart` | 不在 S2 范围 |
| `firebase/lib/playground/firebase_playground_notification_repository.dart` | 不在 S2 范围 |
| `firebase/lib/playground/firebase_playground_profile_repository.dart` | 不在 S2 范围 |
| `firebase/lib/playground/firebase_playground_outcome_feedback_repository.dart` | 不在 S2 范围 |
| `firebase/lib/playground/firebase_playground_verification_repository.dart` | 不在 S2 范围 |
| `firebase/lib/playground/firebase_playground_realtime_repository.dart` | 不在 S2 范围 |
| `firebase/lib/playground/firebase_playground_schema.dart` | 无改动 |
| `firebase/lib/playground/firebase_playground_cursor.dart` | 无改动 |
| `firebase/lib/playground/firebase_playground_error_mapper.dart` | 无改动 |
| `firebase/lib/playground/firebase_playground_identity_resolver.dart` | 无改动 |
| `firebase/lib/playground/firebase_playground_event_mapper.dart` | 无改动 |
| `core/lib/model/` 下所有 S1a 契约文件 | 明确禁止 |
| `p2p/` 下所有文件 | 明确禁止 |

---

## 六、关键决策待确认

1. **RemoteDataSource 接口签名**：是与 `PlaygroundXxxRepository` 接口完全一致（复用 DTO），还是独立定义返回 `Map<String, dynamic>`？推荐前者（复用 DTO），因为 `repository-interface-playground` 的 DTO 已与 Firestore 解耦。

2. **`BlobGateway` firebase 实现**：Phase 0 审计时需确认是否已存在。若不存在，媒体入口 B 只能做到 fake 全绿。

3. **`ModerationRepository` 接口扩展**：`quarantinePost` / `emergencyTakeDown` 是否需要加到 `repository-interface-playground` 的端口接口中？如果该仓库不允许随意增方法，则需在 `CachedPlaygroundModerationRepository` 中直接实现（不经过端口）。

4. **缓存失效策略**：帖子编辑后，是直接更新缓存还是标记失效？推荐直接更新（写穿透），因为帖子编辑频率低。

---

## 七、执行顺序

```
Phase 0（审计，只读）→ 上报确认
  → Phase 1（RemoteDataSource 端口定义，core）
    → Phase 2（Firebase 实现降级，firebase）
      → Phase 3（缓存层，drift）
        → Phase 4（组合 Repository，firebase）
          → Phase 5（媒体入口 B，firebase）
            → Phase 6（审核补齐，firebase）
              → Phase 7（契约测试套件，core）
                → Phase 8（变异自检）
```

每个 Phase 完成后 `/wjt-handoff` 落盘一次。Phase 0 完成后必须上报人类确认范围。