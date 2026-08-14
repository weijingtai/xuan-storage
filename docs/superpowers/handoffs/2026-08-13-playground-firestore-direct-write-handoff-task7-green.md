# Handoff Envelope — Playground Firestore Direct Write (Task 7 allow-post-create GREEN, mutation/budget + Task 8-10 REMAIN)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> 交接时刻: 2026-08-14

## 一句话状态

**Task 6 完成（`b7dff05`/`f2f88d4`）。Task 7 Rules 已修绿：`direct_write_schema_fixture.test.ts`
**8/8 GREEN**（allow valid post create + 7 deny）。剩余 Task 7 变异验证/access budget + Task 8-10 未做。**

## Task 7 关键修复（commit `4e06045`）—— 供下个 agent 参考，勿回退
- **根因1**：owner/reply/like_owners 的 match 规则是 `allow write: if false`，导致 batch 里的
  owner 文档写入被自己的 match 规则拒绝（每个 batch 文档独立按各自 match 规则校验）。
  → 为三个 owner 集合新增 `allow create`，校验 owner 身份
  （provider_uid==auth.uid、app_user_id/public_presentation_id==identity_map）+
  `getAfter` 配对公开文档存在。
- **根因2**：本 emulator 规则引擎的 `get()`/`getAfter()` 结果**不暴露 `.exists`**（会抛
  `Property exists is undefined on object`）。全部改用 `getAfter(...).data != null`。
  → 现在 firestore.rules **0 处 `.exists`**。
- 结果：`direct_write_schema_fixture.test.ts` 8/8 GREEN；rules 语法 emulator 加载无误。

## 已完成：Task 6-7
- Task 6 两仓（storage `b7dff05`、shell `f2f88d4`）。
- Task 7：`firestore.rules`（v1 direct-write，原子 create + deny）、`firestore.indexes.json`
  （6 current-phase，删旧 likes/author composite）、Dart index 合同（3 GREEN）、TS index 合同、
  `direct_write_schema_fixture.test.ts`（8/8 GREEN）。

## 未完成
### Task 7 剩余
1. **变异验证（plan 7.3）**：临时把旧 likes composite 加回 `firestore.indexes.json` →
   `firestore_index_contract_test.dart` 必须红；撤销后复跑 GREEN。
2. **access budget 断言（§10.4）**：在 fixture 内断言合法 post create 唯一文档访问=3
   （identity、owner-after、revision-after），one-time discussion reply=7；注入冗余访问的
   变异 fixture 必须红。当前 fixture 未做预算断言。
3. **旧 `functions/test/firestore.rules.test.ts`（771 行）**：断言旧行为（"客户端不能创建帖"），
   与新 v1 allow 冲突，Task 10 前需按新矩阵重写或拆分（当前跑会大量失败，勿当回归）。

### Task 8（Storage）
- 单一 Rules 源：`infrastructure/emulator/firebase.json` 的 firestore.rules 改引用
  `../firestore.rules`；删 `infrastructure/emulator/firestore.rules`。
- 新建 `firebase/scripts/run_playground_emulator_gate.sh`（LAN 不可达/skip/allow-all 任一 → exit 1）。
- 新建 `firebase/test/playground/firestore_rules_source_contract_test.dart`。

### Task 9（Storage + Shell）
- `playground.dart` 导出 direct adapters（feed/thread query 已改 v1，export 已含）；
  Shell `shell_playground_bootstrap.dart` 装配 direct adapters（isOwner 已提前修复）。

### Task 10
- 全量门禁：storage test/analyze、shell focused、resolved-ref 一致、production-Rules
  Emulator 真实主链路（Alice 发帖/Bob 回复/点赞/应验/反馈/越权失败/墓碑不泄漏/Functions 零调用）、
  零 skip/allow-all；确认 Shell feed_viewmodel loadMore 修复归属（工作区 1 行未提交）。

## 测试证据（本 Session）
- `direct_write_schema_fixture.test.ts`：**8/8 GREEN**（emulator 8082 + 新 rules）。
- Dart index 合同：3/3 GREEN。
- storage `flutter test test/playground` 基线 +241 ~1 -3（3 个 legacy 失败，非回归）。
- shell `flutter test test/playground` +101 全绿。

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 错误稳定 machineCode；隐私字段非空 → `privacy/storage-unavailable` 于任何 Firestore 调用前。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
- Shell 有用户 dirty：只 stage 精确 Task 文件；`macos/GeneratedPluginRegistrant.swift`、
  `pubspec.lock` 勿提交。
- Emulator 复现：`cd /tmp/rulescheck && nohup firebase emulators:start --project playground-test > /tmp/emulator.log 2>&1 &`
  （firestore 8082 / auth 9099，指向 `infrastructure/firestore.rules`）。
