# Handoff Envelope — Playground Firestore Direct Write (Task 6 onward)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage worktree: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> Shell worktree: `xuan-shell/.worktrees/playground-shell-repairs` on `fix/playground-shell-repairs`
> 交接时刻: 2026-08-13 16:05

## 一句话状态

**Task 0-5 已完成并提交（storage 最新 `4ad1569`）；Task 6 尚未开始（无 read contract 测试、feed/thread
query repos 仍是 Phase 7B 旧 schema）。本 Session 只做了基线核查与读取，未改任何代码。**

## 权威基线（本 Session 已核实）

- 分支正确：storage `fix/playground-firebase-repairs`（干净，仅 `docs/superpowers/handoffs/` 未跟踪）。
- git log（storage，由新到旧）：
  - `4ad1569` Task 5 engagement/verification/feedback repos
  - `8a118ee` Task 4 reply command repo
  - `3304093` Task 3 post command repo
  - `f1fc2d5` Task 2 command support
  - `3d8281d` Task 1 cleanup（4 个 legacy 测试修复）
  - `98bc856` Task 1 identity schema convergence
  - `989832d` Task 0 RI pin 0841e19
- RI：`repository-interface-playground/.worktrees/playground-ri-completion`，分支
  `feat/playground-ri-completion`；`PlaygroundPostViewerState` 已含
  `isOwner/canEdit/canDelete/canSetFeedback`（默认 false，Task 0 已合并）。
- Shell：`xuan-shell/.worktrees/playground-shell-repairs`，分支 `fix/playground-shell-repairs`，
  有用户 dirty 文件（viewmodels/conversation/feed/notification/post_detail/profile +
  error_observability_test + 未跟踪 feed_viewmodel_async_state_test）。**禁止 `git add -A`，
  只能 stage 精确 Task 文件。**

## 基线测试结果（Task 6 前）

`cd firebase && flutter test test/playground` → **+228 ~1 -3**（3 个既有失败，非 Task 6 回归）：
1. `callable_command_adapter_test.dart`：`identity resolveActor → httpsCallable("resolveMyIdentity")`
   —— Task 1 已把 resolver 改为直读 Firestore，此测试过期（stale），断言 callable 不再成立。
2. `playground_contract_suite_test.dart`：C4 点赞态/点赞数不缓存 —— `FirebasePlaygroundLikeRepository`
   构造时 `FirebaseFunctions.instance` 需要 Firebase App，测试环境未初始化。旧 callable like repo 问题。

> 以上 3 个属 legacy 遗留，Task 6 范围外；如需在 Task 10 全量门禁前清理，需单独评估（旧 callable
> repo 保留不装配，契约测试或需改用 direct adapter 或 mock）。

## 下一个 agent 起点：Task 6（读取 DTO、真实详情计数、Feed 占位策略）

严格按 plan Task 6（TDD RED→GREEN），分仓提交：

**Storage（firebase/）：**
- Modify `firebase/lib/playground/firebase_playground_feed_query_repository.dart`：
  - 读 v1 公开 schema（`presentation_identity_id/presentation_display_alias/status`，不再读
    `author_provider_uid/post_id-likes/reply_status/content_type/has_outcome_feedback`）；
  - **Feed 只允许单 query，不逐帖聚合 counts**：`PlaygroundFeedItem.replyCount/likeCount/
    verificationCount=0`、`hasOutcomeFeedback=false`、内部 `PublicPost` 三 count=0；
  - `getRecommendedFeed` 明确降级为最新（同 latest query，不读 `recommendation_score`）；
  - `getPendingDivinationFeed` **不访问 Firestore**，返回
    `invalidArgument` + `filter/not-supported-in-direct-phase`；
  - 仅接受 `feedback==all && reply==all`（其他 filter 值返回上述 error）；technique arrayContains 保留；
  - cursor 语义保留（`[created_at,docId]`，orderBy created_at desc）。
- Modify `firebase/lib/playground/firebase_playground_thread_query_repository.dart`：
  - `getThreadReplies`：v1 查询 `post_id==id, is_tombstoned==false, order created_at asc`；
  - `getRegisteredThreadDetail`：固定组合 —— 1 post get + 1 post owner get（viewer
    `isOwner/canEdit/canDelete/canSetFeedback` 由 owner 文档 `provider_uid==auth.uid` 填充）+ 1 replies
    page + 每 10 个当前页 root IDs 1 次 verification query + **3 个 `count()`**（replies /
    post-target likes / verifications）+ 1 feedback get（`feedback_{postId}` doc）+ viewer like/bookmark
    direct gets；
  - `aggregateReadCount` **固定为 3**（三个 aggregation 查询，非浏览量）；
  - `detail.counts.verifiedRootReplyCount` 来自当前 reply page verification 分块查询；
  - 公开 DTO 零内部身份；owner 文档只 get、禁止 list。
  - `getGuestRepresentativeReplies` 当前应返回明确 `unavailable`（不伪造可信限制，一期不交付游客
    代表性回复）；可保留 Functions JSON 映射代码但该路径不装配。
- Create `firebase/test/playground/firestore_direct_read_contract_test.dart`（plan 6.1/6.3）：
  - seed 2 replies、3 post likes（v1 `target_type==post,target_id==postId`）、1 active verification、
    feedback；断言 detail.post.replyCount=2、likeCount=3、verificationCount=1、counts.replyCount=2、
    counts.verifiedRootReplyCount=1、aggregateReadCount=3、outcomeFeedback 非空；
  - viewer state 四态（owner / 非 owner / 未认证 / owner 文档缺失）→ isOwner 等 fail closed false；
  - Feed 占位恒定 0；recording/query-shape 断言（likes count 用 equality index merge 不新增
    composite、无逐帖/逐回复 owner N+1、getPendingDivinationFeed 零 Firestore 访问）。
- 更新既有 `firebase_playground_feed_query_repository_test.dart` 与
  `firebase_playground_thread_query_repository_test.dart`（旧 schema seed → v1 seed；
  Feed 测试从"聚合真实 counts"改为"占位 0 + 不渲染"）。

**Shell（xuan-shell/，注意 dirty 文件）：**
- Create `test/playground/feed_count_visibility_test.dart`：widget 断言 Feed 不渲染
  “0赞/0回复/0应验/已反馈”（Feed mapper 强制 0）。
- Create `test/playground/post_detail_viewer_capability_test.dart`：`PostDetailViewModel.isOwner`
  只读 `detail.viewerState.isOwner`，不得比较 appUserId/publicPresentationUserId；按钮由
  canEdit/canDelete/canSetFeedback/canVerify 控制（Task 9 才改 viewmodel，本 Task 先写 Shell 测试
  或按 plan 仅建测试文件）。

## 关键约束（全程维持）

- 公开 post/reply 文档零 `provider_uid/app_user_id/author_*`；owner/thread-presentation deny-by-default。
- revision ID `r0000000001`+ append-only；tombstone 先追加最后 revision 再清空公开正文。
- create ID `sha256(v1|op|authUid|key)`；payload hash canonical、无时间字段。
- 错误稳定 machineCode（§9 表）；隐私字段非空 → `privacy/storage-unavailable` 于任何 Firestore 调用前。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每个 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
- Shell 有用户 dirty：只 stage 精确 Task 文件。

## Task 7-10 速览（后续）

- Task 7：`firestore.rules` + `firestore.indexes.json`（删旧 likes composite；6 条 current-phase
  composite）+ rules/fixture tests + 变异验证（access budget：post create 3、one-time reply 7）。
- Task 8：单一 Rules 源（emulator firebase.json → ../firestore.rules，删旧 emulator rules）+
  `run_playground_emulator_gate.sh` + rules-source contract test。
- Task 9：`playground.dart` 导出 direct adapters；Shell bootstrap 装配 + `PostDetailViewModel`
  用 viewerState.isOwner（当前 viewmodel 的 `isOwner` 比较 publicPresentationUserId 是 Task 9 必改点）。
- Task 10：全量门禁（storage test/analyze、shell focused、resolved-ref 一致、production-Rules
  Emulator 真实主链路、零 skip/allow-all）。
