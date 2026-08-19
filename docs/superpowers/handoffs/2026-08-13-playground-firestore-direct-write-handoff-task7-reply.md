# Handoff Envelope — Playground Firestore Direct Write (Task 7 9/10; one-time-reply RED rules-logic; Task 8-10 REMAIN)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> 交接时刻: 2026-08-14

## 一句话状态

**Task 6 完成。Task 7 Rules fixture 9/10 GREEN。1000-表达式超限已通过 let-binding helper 重构解决。
唯一 RED：one-time anonymous discussion reply（泛 evaluation error）。Task 8-10 未开始。**

## 本轮关键进展（commit `6a1e507`）
- reply allow-create 重构为 `validReplyCreateData(request, replyId)` + `validReplyDepthOne(request, postId)`，
  用 `let` 复用 get/getAfter（post/root/reply-to/mapping/owner/revision）→ **消除 1000-表达式超限**。
- 结果：`direct_write_schema_fixture.test.ts` 9/10 GREEN；one-time reply 现在 51ms 干净拒绝（非挂起）。
- rules parse OK（emulator 干净加载）。

## 未解决：one-time anonymous discussion reply（1 RED）
- 现象：batch 写 reply+reply_owner+revision 被拒，泛 "evaluation error @ L406 / L155 / L442"
  （reply / reply_owners / revision create 三处）。非 1000-limit，是运行时求值异常。
- 已排除：identity（Bob seeded）、owner getAfter 配对、post 存在、depth-1 结构。
- 待查（下个 agent）：
  1. **`getAfter` on 不在 batch 的文档**：`let mapping = getAfter(...thread_presentations/$(postId__uid))` 的
     mapping 是 admin 预 seed（不在 Bob 的 batch 内）。某些 emulator 版本对 batch 中 getAfter 的
     语义：对"不在 batch 但父集合有同批写"的路径可能返回 null 或抛错。→ 试把 mapping 也放进 Bob 的
     batch（若 Rules 语义是 mapping 必须同批创建，则测试要改成在 batch 内写 mapping，且
     thread-presentation 的 match 规则要允许 create —— 当前是 `allow write: if false`！）。
  2. **thread_presentations 的 match 规则是 `allow write: if false`**（Design：首次 one-time 回复时
     adapter 在同一 transaction 创建 mapping）。这跟 post_owners 一样的问题：batch 里写 mapping 会被
     自己的 match 规则拒绝。**很可能需要给 thread_presentations 加 `allow create`（校验 post_id/
     provider_uid/presentation_identity_id 与 reply 配对），并在测试 batch 里包含 mapping 文档。**
     这可能是根因 —— 但当前测试是 admin 预 seed mapping（不在 batch），走的是"复用已有 mapping"
     路径，不该触发 mapping create。
  3. 若 2 不是根因，用最小化：先测 depth-0 stableAlias reply 的 ALLOW（若 depth-0 也 RED → 是 reply
     通用问题，如 validStringList/validAttachments 对空数组的判定或 revision rule）；再逐条剥除
     validReplyCreateData 的 `&&` 条件定位。

## 已完成：Task 7（累计 commits `451c628`、`4e06045`、`5472aa6`、`6a1e507`）
- firestore.rules（v1 direct-write，原子 create + deny + let helper）
- firestore.indexes.json（6 current-phase，删旧 likes/author composite）+ Dart/TS index 合同
- direct_write_schema_fixture.test.ts：9/10（post create、7 deny、like atomic）
- index 变异验证闭环（旧 likes composite 加回→RED→撤销→GREEN）

## 待办（含规则 WARNING）
1. 修 one-time reply RED（见上）。
2. **规则 WARNING**：firestore.rules L536（verifications create 里
   `get(...root_reply_id).data.depth == 0` 或类似 "sub-expressions not comparable, always true"）
   需修——可能 `depth == 0` 一侧类型不可比。查看 L528-540 区域修正。
3. 旧 `functions/test/firestore.rules.test.ts`（771 行）断言旧行为，Task 10 前重写/拆分。
4. Task 8：单一 Rules 源（emulator/firebase.json → ../firestore.rules，删 emulator/firestore.rules）
   + `scripts/run_playground_emulator_gate.sh` + `firestore_rules_source_contract_test.dart`。
5. Task 9：Shell bootstrap 装配 direct adapters（isOwner 已提前修复）。
6. Task 10：全量门禁 + production-Rules Emulator 真实主链路 + Shell feed_viewmodel loadMore 归属确认。

## 复现命令
```bash
cd /tmp/rulescheck && nohup firebase emulators:start --project playground-test > /tmp/emulator.log 2>&1 &
# 等 8082/9099 LISTEN
cd xuan-storage/.worktrees/playground-firebase-repairs/firebase/infrastructure/functions
FIRESTORE_EMULATOR_HOST=localhost:8082 FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
  npx jest --runInBand direct_write_schema_fixture.test.ts
```

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 本 emulator：`get()/getAfter()` 不支持 `.exists`（用 `.data != null`）；batch 每文档独立按各自 match 规则校验。
- Emulator 不可达 / 依赖解析失败不算业务 RED/GREEN。
- 每 repo 独立提交；禁止 merge main / push main / 部署；不在 main 改代码。
- Shell 有用户 dirty：只 stage 精确 Task 文件；`macos/GeneratedPluginRegistrant.swift`、`pubspec.lock` 勿提交。
