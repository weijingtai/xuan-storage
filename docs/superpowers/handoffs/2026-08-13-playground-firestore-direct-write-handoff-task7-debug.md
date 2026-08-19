# Handoff Envelope — Playground Firestore Direct Write (Task 7 debug WIP, Task 8-10 REMAIN)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> 交接时刻: 2026-08-13

## 一句话状态

**Task 6 完成（storage `b7dff05`、shell `f2f88d4`）。Task 7 主体已提交（`451c628`）+ 本轮 debug 提交（`d6c6877`）。
`direct_write_schema_fixture.test.ts` 8 条 deny 全过；**唯一 RED 是 allow-valid-post-create，
已定位为 `identityReady()` 内 `get()` 在 create 上下文的取值异常**（先 "exists undefined"，
改 `.data != null` 后变 "Null value error"）。**

## 已诊断（allow-post-create RED）

- error 指向 rules L176 `identityReady()`。
- 初版 `identityDoc().exists` → **"Property exists is undefined on object"**。
- 改为 `let data = identityDoc().data; data != null && ...` → **"Null value error"**（仍在 identityReady）。
- 同一 fixture 下 `identity readable by self`（普通认证读）**通过** → 文档存在、读规则 OK。
- 结论：`get(/databases/$(database)/documents/identity_map/$(request.auth.uid))` 在 **create 规则上下文**
  里取不到文档（.data 为 null）。可能原因：
  1. 该 emulator 版本 `get()` 在写规则中受**读规则**约束，且 identity_map 读规则
     `request.auth.uid == providerUserId` 判定未命中（create 的 auth 上下文与普通读不同？）；
  2. `$(request.auth.uid)` 拼接路径在此引擎有 quirk；
  3. 需要 `getAfter()` 或改用 `existsAfter()`（但 post create 的 identity 是**读**非写，不能 getAfter）。

### 下个 agent 调试建议（按此顺序）
1. **先证实 get() 是否被读规则阻断**：临时把 `identity_map` 的 `allow read` 改为 `if true`
   （仅本地验证）重跑 allow-post-create；若通过 → 是 get() 被读规则拦截，需调整策略
   （如放宽 identity_map 读规则到认证用户可读——Design §3.1 本意是"只允许本人读"，
   但规则内 get() 需要能读；或改用 getAfter/existsAfter 语义）。
2. 若放宽后仍失败，试 `get(...).data.public_presentation_id` 直接访问（去掉 hasAll/keys 前置），
   定位是不是 `keys().hasAll` 在 data=null 时的报错。
3. 可用临时诊断测试逐条剥除 identityReady 的子条件定位。
- 复现命令：
  ```bash
  cd /tmp/rulescheck && nohup firebase emulators:start --project playground-test > /tmp/emulator.log 2>&1 &
  # 等 8082/9099 LISTEN
  cd xuan-storage/.worktrees/playground-firebase-repairs/firebase/infrastructure/functions
  FIRESTORE_EMULATOR_HOST=localhost:8082 FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
    npx jest --runInBand direct_write_schema_fixture.test.ts
  ```

## 已完成：Task 7（`451c628` + `d6c6877`）
- `firestore.rules`：v1 direct-write Rules（exact keys、atomic getAfter、presentation 校验、
  tombstone、verify/feedback 状态机、depth 0/1、identity self-read）。
- `firestore.indexes.json`：6 条 current-phase composite；删旧 likes/author indexes。
- `firestore_index_contract_test.dart`（Dart 3 GREEN）、`firestore.indexes.test.ts`（新合同）。
- `direct_write_schema_fixture.test.ts`：8 deny 全过；allow-post-create 1 RED（见上）。

## 未完成
- Task 7：allow-post-create 修绿；**变异验证**（旧 likes composite 加回必须红；access budget
  post create ≤4 / one-time reply ≤8 断言；注入冗余访问变异必须红）；旧 `firestore.rules.test.ts`
  （771 行）按新矩阵重写/拆分。
- Task 8：单一 Rules 源（`emulator/firebase.json` → `../firestore.rules`，删 emulator/firestore.rules）
  + `scripts/run_playground_emulator_gate.sh` + `firestore_rules_source_contract_test.dart`。
- Task 9：`playground.dart` 导出 direct adapters + Shell bootstrap 装配（isOwner 已提前修复）。
- Task 10：全量门禁 + production-Rules Emulator 真实主链路 + Shell feed_viewmodel loadMore 修复归属确认。

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
- Shell 有用户 dirty：只 stage 精确 Task 文件；`macos/GeneratedPluginRegistrant.swift`、
  `pubspec.lock` 勿提交。
