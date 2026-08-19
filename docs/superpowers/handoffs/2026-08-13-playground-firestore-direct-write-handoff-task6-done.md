# Handoff Envelope — Playground Firestore Direct Write (Task 6 storage DONE, Shell T6 + Task 7-10 REMAIN)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage worktree: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> Shell worktree: `xuan-shell/.worktrees/playground-shell-repairs` on `fix/playground-shell-repairs`
> 交接时刻: 2026-08-13

## 一句话状态

**Task 6 Storage 侧已完成并提交（`b7dff05`，23 tests GREEN / analyze clean / 无新回归）；
Task 6 Shell 侧两个 widget 测试尚未创建；Task 7-10 未开始。**

## 已完成：Task 6（Storage）

### 修改文件
- `firebase/lib/playground/firebase_playground_feed_query_repository.dart`
  - v1 单 query（`status==active, order created_at desc`）；Feed 占位恒 0（不逐帖聚合）；
  - `getPendingDivinationFeed` 不访问 Firestore → `invalidArgument` + `filter/not-supported-in-direct-phase`；
  - 推荐明确降级为最新（不读 recommendation_score）；
  - reply/feedback 状态 filter 只接受 `all`，否则同上错误；技法 arrayContains 保留。
- `firebase/lib/playground/firebase_playground_thread_query_repository.dart`
  - 移除 `cloud_functions` 依赖（构造不再需要 FirebaseFunctions）；
  - `getGuestRepresentativeReplies` → `unavailable`（游客代表性回复后移，§1）；
  - `getThreadReplies`：v1 `post_id==, is_tombstoned==false, order created_at asc`；
  - `getRegisteredThreadDetail`：固定组合（1 post get + 1 owner get + 1 replies page +
    每 10 root IDs 1 次 verification 分块 + 3 个 count() + 1 feedback doc get +
    viewer like/bookmark direct gets），`aggregateReadCount=3`；
  - viewer state：owner 文档 `provider_uid==auth.uid` → isOwner/canEdit/canDelete/
    canSetFeedback；非 owner/未认证/owner 缺失 fail closed false。
- `firebase/test/playground/firestore_direct_read_contract_test.dart`（新建，12 tests）
- `firebase/test/playground/firebase_playground_feed_query_repository_test.dart`（重写 v1 语义）
- `firebase/test/playground/firebase_playground_thread_query_repository_test.dart`（重写 v1 语义）

### 测试证据
- `cd firebase && flutter test test/playground` → **+241 ~1 -3**（基线 +228 之上新增 13 条，
  3 个失败为既有 legacy：stale resolver callable 测试 + 旧 callable like repo 需 Firebase App）。
- `dart analyze lib/playground test/playground` 两修改文件 clean（脚本未跑全量）。

## 下一个 agent 起点

### Task 6 剩余（Shell 侧，plan 6.2/6.3 的 widget 部分）
在 `xuan-shell/.worktrees/playground-shell-repairs`（分支 `fix/playground-shell-repairs`，
**有用户 dirty 文件，禁止 `git add -A`，只 stage 精确 Task 文件**）：
- Create `test/playground/feed_count_visibility_test.dart`：用 `InMemoryPlaygroundRepositories`
  造 feed，widget/VM 断言 Feed 不渲染 “0赞/0回复/0应验/已反馈” 占位。
- Create `test/playground/post_detail_viewer_capability_test.dart`：断言
  `PostDetailViewModel.isOwner` 只读 `detail.viewerState.isOwner`（当前 viewmodel 的 isOwner
  比较 publicPresentationUserId 是 Task 9 必改点，本 Task 先建测试文件或按 plan 先写 widget 断言）。

### Task 7（Storage）
- `firebase/infrastructure/firestore.rules`（production，exact keys / deny / access budget：
  post create 3、one-time reply 7）
- `firebase/infrastructure/firestore.indexes.json`（删旧 likes composite；6 条 current-phase
  composite：posts×2(有/无 technique)、replies×1、verifications×2、bookmarks×1；post-target
  likes 用 equality index merge 不新增 composite）
- rules/fixture tests + `firestore_index_contract_test.dart` + 变异验证。

### Task 8（Storage）
- 单一 Rules 源：`emulator/firebase.json` → `../firestore.rules`，删旧 emulator rules；
- `scripts/run_playground_emulator_gate.sh`；`firestore_rules_source_contract_test.dart`。

### Task 9（Storage + Shell）
- `playground.dart` 导出 direct adapters；Shell bootstrap 装配；
- `PostDetailViewModel.isOwner` 改为 `detail.viewerState.isOwner`（当前实现比较
  publicPresentationUserId，违反 §12.2，Task 9 必须改）。

### Task 10
- 全量门禁：storage test/analyze、shell focused、resolved-ref 一致、production-Rules
  Emulator 真实主链路、零 skip/allow-all。

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 错误稳定 machineCode；隐私字段非空 → `privacy/storage-unavailable` 于任何 Firestore 调用前。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
