# S2 云端公开分享 —— Phase 0 审计报告

> 2026-08-06 ｜ 基线 main = `62a1e4c` ｜ 分支 `feature/s2-cloud-public-sharing`
> 依据 `S2-development-plan.md` Phase 0 要求，只读审计，未写任何业务代码。

---

## 一、审计对象与结论速览

| 项 | 结论 |
|---|---|
| `firebase/lib/playground/` | 19 个文件（S2 范围 7 个 + 范围外 6 个 + 工具 6 个） |
| S2 范围 6 个 Repository | **全部方法实现完整，签名与端口一致 → 均「需降级」**（只改 `implements` 声明） |
| `FirebasePlaygroundModerationRepository` | **缺 `quarantinePost` / `emergencyTakeDown`**（仅 `reportContent`，48 行） |
| `BlobGateway` | **firebase 实现为零**，仅有内存 fake（`drift/lib/blob/in_memory_blob_gateway.dart`） |
| 媒体上传 | `beginUpload` 仅做 Firestore 文档登记，**无字节上传管线**；`getDownloadUrl` 兜底返回 `/media/{id}` 假路径 |
| drift 缓存层 | **零**：`drift/lib/` 无任何 playground 表/DAO/Store |
| 契约测试 | 端口级契约已有（`playground_repository_contracts.dart`，254 行）；`signaling_contract_suite.dart`（413 行）模式可复用 |
| 范围外 6 个文件 | conversation / notification / profile / outcome_feedback / verification / realtime —— 不动 |

---

## 二、13 个端口逐一对照

端口来源：`repository-interface-playground/lib/src/ports/`（13 个文件，共 452 行）。
内存 fake：`InMemoryPlaygroundRepositories`（`lib/src/fakes/in_memory_playground_repositories.dart`，734 行，全量覆盖 13 端口）。

| # | 端口接口 | 方法 | Firebase 实现文件 | 审计结论 |
|---|---|---|---|---|
| 1 | `PlaygroundPostRepository` | `createPost` / `editPost` / `deletePost` / `getPost` | `firebase_playground_post_repository.dart`（229 行） | **需降级**：4/4 已实现，签名一致（复用 `CreatePostCommand` 等 DTO） |
| 2 | `PlaygroundFeedRepository` | `getFeed` / `getRecommendedFeed` / `getPendingDivinationFeed` / `getLatestFeed` | `firebase_playground_feed_repository.dart`（131 行） | **需降级**：4/4 已实现，签名一致（`GetFeedQuery` / `PlaygroundPage`） |
| 3 | `PlaygroundLikeRepository` | `setLike` / `isLiked` / `getLikeCount` | `firebase_playground_like_repository.dart`（89 行） | **需降级**：3/3 已实现，签名一致 |
| 4 | `PlaygroundBookmarkRepository` | `setBookmark` / `isBookmarked` / `getBookmarkedPosts` | `firebase_playground_bookmark_repository.dart`（148 行） | **需降级**：3/3 已实现，签名一致 |
| 5 | `PlaygroundReplyRepository` | `createRootReply` / `createDiscussionReply` / `editRootReply` / `editDiscussionReply` / `deleteReply` / `getReplies` | `firebase_playground_reply_repository.dart`（344 行） | **需降级**：6/6 已实现，签名一致 |
| 6 | `PlaygroundMediaRepository` | `beginUpload` / `getMediaInfo` / `getDownloadUrl` / `deleteMedia` | `firebase_playground_media_repository.dart`（122 行） | **需降级 + 功能缺口**：4/4 已实现，签名一致，但见下「媒体上传缺口」 |
| 7 | `PlaygroundModerationRepository` | `reportContent` | `firebase_playground_moderation_repository.dart`（48 行） | **缺失**：仅 `reportContent`（1/1 已实现），缺 `quarantinePost` / `emergencyTakeDown` |
| 8 | `PlaygroundConversationRepository` | 私信相关 | `firebase_playground_conversation_repository.dart`（283 行） | 范围外，不动 |
| 9 | `PlaygroundNotificationRepository` | 通知相关 | `firebase_playground_notification_repository.dart`（188 行） | 范围外，不动 |
| 10 | `PlaygroundProfileRepository` | 个人资料 | `firebase_playground_profile_repository.dart`（92 行） | 范围外，不动 |
| 11 | `PlaygroundOutcomeFeedbackRepository` | 反馈相关 | `firebase_playground_outcome_feedback_repository.dart`（130 行） | 范围外，不动 |
| 12 | `PlaygroundVerificationRepository` | 验证相关 | `firebase_playground_verification_repository.dart`（176 行） | 范围外，不动 |
| 13 | `PlaygroundRealtimeRepository` | 实时事件 | `firebase_playground_realtime_repository.dart`（107 行） | 范围外，不动 |

---

## 三、三张表

### 表 A：已有（实现完整，可直接复用）

| 文件 | 方法 | 备注 |
|---|---|---|
| `firebase_playground_post_repository.dart` | 4 个 | 附私有 `_docToPost` / `_parseAttachments` / `_attachmentToMap` 映射逻辑，降级时原样保留 |
| `firebase_playground_feed_repository.dart` | 4 个 | 附私有 `_queryFeed` 游标分页；`_docToPost` 与 post 版重复（attachments/revisions 置空） |
| `firebase_playground_like_repository.dart` | 3 个 | 附私有 `_likeDocId`（`uid_targetType_targetId` 复合文档 id） |
| `firebase_playground_bookmark_repository.dart` | 3 个 | 附私有 `_bookmarkDocId`；`getBookmarkedPosts` 逐帖 N+1 查询 |
| `firebase_playground_reply_repository.dart` | 6 个 | 附私有 root/discussion 两套反序列化 + 附件映射 |
| `firebase_playground_media_repository.dart` | 4 个 | 签名完整，但字节上传缺失（见下） |

### 表 B：缺失（接口定义了但实现没有）

| 缺口 | 位置 | 说明 |
|---|---|---|
| `quarantinePost(PlaygroundPostId)` | `firebase_playground_moderation_repository.dart` | 人工下架（status → `quarantined`），**端口接口未定义**（`PlaygroundModerationRepository` 只有 `reportContent`） |
| `emergencyTakeDown(PlaygroundPostId)` | 同上 | 紧急下架（status → `tombstoned`），端口接口同样未定义 |
| 媒体真实上传管线 | `firebase_playground_media_repository.dart` | `beginUpload` 只写 Firestore 文档（status=pending），**无 uploadUrl 生成、无 chunk 上传、无 completeUpload**；`getDownloadUrl` 无签名 URL，兜底 `/media/{id}` 假路径 |

### 表 C：需降级（实现完整，需把 Firestore 调用抽为 RemoteDataSource 端口方法）

6 个 Repository（post/feed/like/bookmark/reply/media）全部属于此类。
**降级方式**：RemoteDataSource 接口签名与 `PlaygroundXxxRepository` **完全一致**（复用 DTO），
现有 Firebase 实现类只需把 `implements PlaygroundXxxRepository` 改为 `implements PlaygroundXxxRemoteDataSource`，
方法体与私有映射函数**零改动**。已在 Phase 1 推荐方案中采纳该路径。

---

## 四、专项标注

### 4.1 BlobGateway firebase 实现 —— **不存在**

- 端口：`core/lib/model/blob_gateway.dart`（文件头明确标注「本文件零实现，只有值类型与端口签名」）
- 内存 fake：`drift/lib/blob/in_memory_blob_gateway.dart`（含测试 `drift/test/blob/in_memory_blob_gateway_test.dart`）
- 全仓库无 firebase/supabase/其他真云端实现
- **结论**：按计划 Phase 5 红线，媒体入口 B 只能做到「BlobGateway 接口接通 + fake 实现全绿」，
  真云端上传待 BlobGateway 落地后另立任务。不阻塞 S2-row 交付。

### 4.2 Moderation 接口扩展 —— **端口接口无方法，需决策**

`PlaygroundModerationRepository` 端口只有 `reportContent`。
`quarantinePost` / `emergencyTakeDown` 需要决策放哪里（见「关键决策」第 3 项）。

### 4.3 契约测试现状

- **端口级契约**（已有）：`repository-interface-playground/lib/src/contracts/playground_repository_contracts.dart`（254 行）
  含 `verifyPostRepositoryContract` / `verifyReplyRepositoryContract` 等 9 个函数，验证**接口行为**。
- **RemoteDataSource 级契约**（缺失）：无任何缓存分层 / 缓存裁定 / EXIF 剥离验证 —— 这正是 Phase 7 要建的。
- **可复用模式**（已有）：`core/lib/test_support/signaling_contract_suite.dart`（413 行），
  `runXxxContractSuite` 函数 + factory 注入 + 拓扑参数模式可直接照搬。

### 4.4 其他观察（供后续 Phase 参考，非阻塞）

- `firebase_playground_feed_repository.dart` 与 `bookmark` 的 `_docToPost` 是 post 仓库的**重复实现**（attachments/revisions 置空）。
  降级时不强求合并（不在 S2 范围），保持现状。
- `firebase/lib/` 目前**没有 `media/` 目录**，Phase 5 新增文件需新建目录。
- import 边界测试 `firebase_playground_import_boundary_test.dart` 只扫描 `lib/playground/` 目录；
  Phase 4/5 新文件在 `firebase/lib/` 根或 `firebase/lib/media/`，**不受该边界约束**，但若放 `lib/playground/` 内则受约束。
- drift 包已有 `blob/` 模块（`drift_local_blob_store.dart` 等），Phase 3 新增 playground 缓存表与既有表无命名冲突。

---

## 五、对「关键决策待确认」的审计口径

| 决策 | 审计后的建议 |
|---|---|
| 1. RemoteDataSource 签名 | **复用 DTO，与端口完全一致**。6 个目标实现全部签名一致，只改 `implements` 即可降级，成本最低 |
| 2. BlobGateway firebase 实现 | **不存在**。媒体入口 B 按 fake 全绿交付，真云端另立任务 |
| 3. Moderation 接口扩展 | `repository-interface-playground` 是独立 git 仓库（`repository-interface-*` 家族），增方法会牵动该仓库版本；
   建议**在 firebase 侧新增 `CachedPlaygroundModerationRepository` 直接实现**（不经过端口），或按派工单要求先沟通该仓库维护者 |
| 4. 缓存失效策略 | 帖子编辑频率低，**写穿透直接更新缓存**（符合计划推荐），评论同理 |
