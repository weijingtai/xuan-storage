# Handoff Envelope — Playground Firestore Direct Write (Task 7 partial, Task 8-10 REMAIN)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> Shell: `xuan-shell/.worktrees/playground-shell-repairs` on `fix/playground-shell-repairs`
> 交接时刻: 2026-08-13

## 一句话状态

**Task 6 两仓完成（storage `b7dff05`、shell `f2f88d4`）。Task 7 主体已提交（`451c628`）：
production Rules + indexes + index 合同测试 + rules fixture 测试（7/8 GREEN；allow-valid-post-create
1 条 RED 待调试）。Task 8-10 未开始。**

## 已完成：Task 6（两仓）
- storage `b7dff05`：feed/thread query repos v1 + 占位计数 + aggregateReadCount=3 + viewer 四态 + 游客回复 unavailable；`firestore_direct_read_contract_test.dart`（12 tests）。
- shell `f2f88d4`：`feed_count_visibility_test.dart` + `post_detail_viewer_capability_test.dart`（4 tests GREEN）；顺带修复 `PostDetailViewModel.isOwner`（读 viewerState，§12.2），只 stage 本 hunk，用户同文件其它 dirty 未提交。
- 证据：storage `+241 ~1 -3`（3 个 legacy 失败非回归）；shell `+101 全绿`。

## 已完成：Task 7（commit `451c628`，主体）
- `firebase/infrastructure/firestore.rules`：全新 v1 direct-write Rules（~530 行）。posts/replies/owners/thread-presentations/likes+like_owners/bookmarks/verifications/feedback + append-only revisions；exact keys（零内部身份）；atomic create via getAfter；presentation 与 identity_map 比对；tombstone 清空；verify/feedback 状态机；depth 0/1；跨帖/墓碑拒绝；identity_map 仅本人读。
- `firebase/infrastructure/firestore.indexes.json`：6 条 current-phase composite（posts×2、replies×1、verifications×2、bookmarks×1）；删旧 likes composite（post_id+user_provider_uid）与旧 author_app_user_id profile 索引。
- `firebase/test/playground/firestore_index_contract_test.dart`（Dart 静态，3 tests GREEN）。
- `functions/test/firestore.indexes.test.ts`：更新为新 6 索引合同。
- `functions/test/direct_write_schema_fixture.test.ts`（新建）：rules-unit-testing fixture —— **7/8 GREEN**。
- rules 语法：emulator 8082 干净启动加载新 rules（无 parse error）。

## 未完成：Task 7 剩余
### ⚠ 调试：`allow: stableAlias 合法 post create` RED（1 条）
- 现象：`batch.commit()` 被拒，error 指向 `firestore.rules` **L175:24**（post create 的 `identityReady()` 求值 false）。7 条 deny 全过（rules 可解析、拒绝路径正确）。
- 排查建议（二分）：
  1. `identityReady()`：fixture 已 seed `identity_map/alice-uid`（含 app_user_id/provider_uid/public_presentation_id/public_display_alias 5 键）；rules 内 `get()` 绕过 read allow。建议先单独断言 identityReady，再逐条剥除后续条件。
  2. `created_at == updated_at`：batch 内同 `new Date()`，理论相等；不行改用 request.time 语义。
  3. ownerAfter/revision getAfter 依赖同批写入（batch 已含 owner+revision）。
  4. `has_chart is bool`、`attachments: []`（validAttachments size 0 应 true）可排除。
- 复现：先起 emulator（/tmp/rulescheck/firebase.json 指向新 rules，auth 9099/firestore 8082），再 `FIRESTORE_EMULATOR_HOST=localhost:8082 FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 npx jest --runInBand direct_write_schema_fixture.test.ts`。

### 必做：变异验证（plan 7.3）
- 临时把旧 likes composite 加回 `firestore.indexes.json` → `firestore_index_contract_test.dart` 必须红在 "unexpected playground_likes composite"；撤销后复跑 GREEN。
- Rules access budget：post create 唯一访问=3（identity、owner-after、revision-after）；one-time discussion reply=7。需在 fixture 断言 ≤4/≤8；注入冗余访问的变异 fixture 必须红。（当前 fixture 未做预算断言 —— 下个 agent 补。）

### 旧 rules 测试需更新
- `functions/test/firestore.rules.test.ts`（771 行）断言旧行为（"客户端不能创建帖子"等），与新 v1 direct-write allow 冲突；Task 10 前需按新矩阵重写或拆分。

## 下一步：Task 8-10
- Task 8：单一 Rules 源（`emulator/firebase.json` → `../firestore.rules`，删 `emulator/firestore.rules`）+ `scripts/run_playground_emulator_gate.sh` + `firestore_rules_source_contract_test.dart`。
- Task 9：`playground.dart` 导出 direct adapters + Shell bootstrap 装配（isOwner 已提前修复）。
- Task 10：全量门禁 + production-Rules Emulator 真实主链路（Alice 发帖/Bob 回复/点赞/应验/反馈/越权失败/墓碑不泄漏/Functions 零调用）+ 确认 Shell feed_viewmodel loadMore 修复归属（我在工作区做了 1 行 `_posts = [..._posts, ...page.items]` 未提交）。

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 错误稳定 machineCode；隐私字段非空 → `privacy/storage-unavailable` 于任何 Firestore 调用前。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
- Shell 有用户 dirty（viewmodels/error_observability_test/feed_viewmodel_async_state_test 等）：只 stage 精确 Task 文件，禁止 `git add -A`；`macos/GeneratedPluginRegistrant.swift`、`pubspec.lock` 勿提交。
