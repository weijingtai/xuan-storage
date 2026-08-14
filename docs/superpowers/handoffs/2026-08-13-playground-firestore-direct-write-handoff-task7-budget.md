# Handoff Envelope — Playground Firestore Direct Write (Task 7 9/10; one-time-reply RED = 1000-expr limit; Task 8-10 REMAIN)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> 交接时刻: 2026-08-14

## 一句话状态

**Task 6 完成。Task 7 Rules fixture 现 9/10 GREEN（含 post create、7 deny、like atomic、post like+owner）。
唯一 RED：one-time anonymous discussion reply —— 原因已定位为 reply create 规则超过 Firestore
1000 表达式求值上限。变异验证（index）已完成。**

## Task 7 当前状态

### 已验证通过（9/10）
- allow: stableAlias valid post create（post+owner+revision atomic）
- deny ×7（author_provider_uid 泄漏 / oneTime 伪造 ID / owner 冒充 / 未认证 / depth=2 / 负 depth / reply 泄漏 appUserId）
- like + like_owner atomic create（target_type/target_id）
- index 变异验证：旧 likes composite 加回 → index contract RED（精确断言）；撤销 → GREEN。

### ⚠ 唯一 RED：one-time anonymous discussion reply
- error：`Unable to evaluate the expression as the maximum of 1000 expressions to evaluate has been reached for 'create' @ L330`（reply create 规则）。
- 根因：reply create 规则过长（`keys().hasOnly` 22 键 + `validStringList` 16 槽 + `validAttachments` 9 槽 + 多次 `get()`/`getAfter()` + 展示身份三元表达式），子表达式总数超 1000。
- **修复方向（下个 agent）**：
  1. **抽取 helper 函数**把 reply create 校验拆成 `validReplyCreateData(request, replyId)` 等函数（Firestore 表达式上限按"请求求值总数"计，抽函数可减少同层展开——实测验证）；
  2. **降低固定槽 validator 开销**：`validStringList`/`validAttachments` 每槽 2+ 表达式 ×16/9 槽很重。可把 technique_tags 槽数压到 8（Design 允许最多 16，但可先限 8 槽实测）或合并条件；
  3. 把展示身份三元（stableAlias vs oneTimeAnonymous）抽成独立函数 `validReplyPresentation(request)`；
  4. 目标 post/root/reply-to 存在性 get 合并（如先 `let post = get(...); let root = get(...)` 复用）。
- 复现：`cd /tmp/rulescheck && nohup firebase emulators:start --project playground-test > /tmp/emulator.log 2>&1 &`，等 8082/9099 LISTEN，然后
  `cd .../functions && FIRESTORE_EMULATOR_HOST=localhost:8082 FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 npx jest --runInBand direct_write_schema_fixture.test.ts -t "one-time anonymous"`。
- 经验：本 emulator 规则引擎**不支持 `get()/getAfter().exists`**（须用 `.data != null`）；
  batch 每个文档按各自 match 规则独立校验（owner 必须有自己的 allow create）。

## 已完成提交
- `4e06045`：owner/like_owners 原子 create + `.data != null`（allow-post-create 修绿，8/8）。
- `5472aa6`：access-budget 测试（like atomic 通过；one-time reply 待修）。

## 未完成
### Task 7 剩余
1. 修复 one-time reply RED（1000-expr，见上）。
2. access budget 断言完成：heavy one-time reply 成功后即证明 7 访问在 8/20 内；
   若要"注入冗余访问变异必须红"，需在规则里临时加冗余 get() 验证。
3. 旧 `functions/test/firestore.rules.test.ts`（771 行）断言旧行为，与 v1 冲突，Task 10 前重写/拆分。

### Task 8（Storage）
- 单一 Rules 源：`infrastructure/emulator/firebase.json` 的 firestore.rules 改引用 `../firestore.rules`；
  删 `infrastructure/emulator/firestore.rules`。
- 新建 `firebase/scripts/run_playground_emulator_gate.sh`（LAN 不可达/skip/allow-all 任一 → exit 1）。
- 新建 `firebase/test/playground/firestore_rules_source_contract_test.dart`。

### Task 9（Storage + Shell）
- `playground.dart` 导出 direct adapters（feed/thread query 已 v1）；Shell `shell_playground_bootstrap.dart`
  装配 direct adapters（isOwner 已提前修复）。

### Task 10
- 全量门禁 + production-Rules Emulator 真实主链路（Alice 发帖/Bob 回复/点赞/应验/反馈/越权失败/
  墓碑不泄漏/Functions 零调用）+ 零 skip/allow-all + Shell feed_viewmodel loadMore 修复归属确认。

## 测试证据（本 Session）
- `direct_write_schema_fixture.test.ts`：9/10（emulator 8082 + 新 rules）。
- index 合同：3/3 GREEN；变异验证 RED→GREEN 闭环。
- storage 基线 +241 ~1 -3（3 个 legacy 失败）；shell +101 全绿。

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
- Shell 有用户 dirty：只 stage 精确 Task 文件；`macos/GeneratedPluginRegistrant.swift`、`pubspec.lock` 勿提交。
