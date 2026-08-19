# Handoff Envelope — Playground Firestore Direct Write (Task 6 DONE both repos, Task 7 START)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> Shell: `xuan-shell/.worktrees/playground-shell-repairs` on `fix/playground-shell-repairs`
> 交接时刻: 2026-08-13

## 一句话状态

**Task 6 已在两仓完成并提交（storage `b7dff05`、shell `f2f88d4`）。Task 7 尚未开始（production
Rules/indexes 未改，index contract 测试未建）。**

## 已完成：Task 6（两仓）

### Storage（commit `b7dff05`）
- feed/thread query repos v1 读取 + 占位计数 + aggregateReadCount=3 + viewer 四态 fail closed；
  getGuestRepresentativeReplies → unavailable；移除 cloud_functions 依赖。
- `firestore_direct_read_contract_test.dart`（12 tests）+ feed/thread query tests 重写 v1。
- 证据：`flutter test test/playground` → **+241 ~1 -3**（3 个失败为既有 legacy，非本次回归）：
  1. `callable_command_adapter_test.dart` resolveActor → httpsCallable（Task 1 改直读后 stale）
  2/3. `playground_contract_suite_test.dart` C4 点赞态/点赞数（旧 callable like repo 需 Firebase App）

### Shell（commit `f2f88d4`）
- `test/playground/feed_count_visibility_test.dart`：Feed 不渲染计数/已反馈标记（GREEN）。
- `test/playground/post_detail_viewer_capability_test.dart`：isOwner 读 viewerState（GREEN）。
- `post_detail_viewmodel.dart`：`isOwner` 改为读 `_detail?.viewerState.isOwner ?? false`
  （修复 §12.2 违例——原来比较 publicPresentationUserId）。仅 stage 本 hunk，
  用户对同文件的其它 dirty 改动未提交。
- 证据：`flutter test test/playground` → **+101 全绿**。

### ⚠ Shell 用户 dirty 文件（未提交，勿动）
- `conversation_viewmodel / feed_viewmodel / notification_viewmodel / profile_viewmodel /
  post_detail_viewmodel（MM，剩余未 stage）/ error_observability_test / 未跟踪
  feed_viewmodel_async_state_test`。
- 我在 feed_viewmodel.dart 内做了 **1 行** loadMore 修复（`_posts = [..._posts, ...page.items]`，
  解决用户异步重构引入的 "Cannot add to an unmodifiable list"），该修复留在工作区未提交
  （与用户 dirty 混杂）；Task 10 门禁前需确认如何提交。
- `macos/Flutter/GeneratedPluginRegistrant.swift`、`pubspec.lock` 因 `pub get` 变更，**勿提交**。
- worktree `pubspec_overrides.yaml` 已补 `firebase_ai: ^3.14.0` + `vibration: ^3.2.0`（gitignored，
  主仓 override 整体取代规则）。

## 下一个 agent 起点：Task 7（Production Rules、索引、访问预算）

严格按 plan Task 7（先写静态/预算 RED → 改 JSON/rules → GREEN → 变异验证）。

### 目标文件
- `firebase/infrastructure/firestore.rules`（现 179 行，旧 schema 公开字段 + author_*）
- `firebase/infrastructure/firestore.indexes.json`（现含旧 likes composite `post_id+user_provider_uid`、
  旧 author_app_user_id 索引、旧 replies `post_id+depth/root_reply_id` 索引）
- `firebase/infrastructure/functions/test/firestore.rules.test.ts`
- 新建 `firebase/infrastructure/functions/test/direct_write_schema_fixture.test.ts`
- 新建 `firebase/test/playground/firestore_index_contract_test.dart`

### 关键要求（Design §10.2/§10.4、plan 7.1-7.3）
- **索引**：删旧 likes composite（`post_id+user_provider_uid`）；6 条 current-phase composite：
  - posts: `status ASC, created_at DESC` ×2（无/含 `allowed_chart_technique_ids CONTAINS`）
  - replies: `post_id ASC, is_tombstoned ASC, created_at ASC`
  - verifications: `post_id ASC, root_reply_id ASC, revoked_at ASC, created_at ASC`
  - verifications: `post_id ASC, revoked_at ASC`
  - bookmarks: `user_provider_uid ASC, created_at DESC`
  - post-target likes count 用 `target_type==post + target_id==postId` equality index merge，
    **不新增 composite**；旧 author_app_user_id profile 索引标记后续、当前 query 不依赖。
- **Rules**：每个 allow 必有 deny；exact keys（`keys().hasOnly`）；public/private 分离；
  owner/thread-presentation/revision create/update/delete 约束；tombstone 清空；
  verify/feedback 状态机；两层关系；预算 4/10 与 8/20。
- **访问预算**：post create 唯一访问 3（identity_map、owner-after、revision-after）；
  one-time discussion reply 唯一访问 7。变异 fixture 增冗余访问必须 RED。
- **静态 RED 先行**：读 `firestore.indexes.json` 断言旧 likes composite 不存在、6 个
  current-phase 签名逐字匹配；删除前必须失败。
- **变异验证**：临时加回旧 likes composite → index contract 必须红在
  "unexpected playground_likes composite"；撤销后复跑 GREEN。
- 命令：
  - `cd firebase && flutter test test/playground/firestore_index_contract_test.dart test/playground/firestore_direct_read_contract_test.dart`
  - `cd firebase/infrastructure/functions && npm test -- --runInBand firestore.rules.test.ts direct_write_schema_fixture.test.ts`
- Emulator 不可达不算 RED/GREEN。

### Task 8-10 速览
- Task 8：单一 Rules 源（emulator/firebase.json → ../firestore.rules，删旧 emulator rules）+
  `scripts/run_playground_emulator_gate.sh` + `firestore_rules_source_contract_test.dart`。
- Task 9：`playground.dart` 导出 direct adapters；Shell bootstrap 装配；isOwner 已提前修复。
- Task 10：全量门禁 + production-Rules Emulator 真实主链路 + 零 skip/allow-all；
  需确认 feed_viewmodel loadMore 修复的提交归属。

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 错误稳定 machineCode；隐私字段非空 → `privacy/storage-unavailable` 于任何 Firestore 调用前。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
- Shell 有用户 dirty：只 stage 精确 Task 文件，禁止 `git add -A`。
