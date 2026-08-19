# Handoff Envelope — Playground Firestore Direct Write (Task 7 anon-ID content-derived DONE; Task 8-10 REMAIN)

> Status: **DONE（Task 7 剩余项）—— Rules 10/10 GREEN + Dart 29/29 GREEN + docs 已更新。**
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`
> 交接时刻: 2026-08-14

## 一句话状态

**Task 7 唯一 RED（one-time anonymous discussion reply）已消除。匿名 ID 改为内容派生
`post_{postId}`（reply 与 post 一致），thread-presentation 私有映射全链路删除。
Rules fixture 10/10 GREEN、Dart 29/29 GREEN、analyze 干净。代码提交 `dbcb3c4`，
文档提交见后。Task 8-10 未开始。**

## 关键决策：匿名 ID 内容派生（用户已批准）

- **不再需要“两个 ID（正常 + 匿名）”**（那要改 identity_map/账号层/backfill，且一个
  全局匿名 ID 会跨帖关联所有匿名行为）。
- 匿名 ID 随机性来源是**内容（postId）**而非账号：`presentation_identity_id = post_{postId}`
  对 post 和 reply 统一。同帖稳定 ✓、跨帖不可关联 ✓、Rules 可验证 ✓、零新状态 ✓。
- **唯一取舍**：同帖内多个匿名作者共用一个 persona（贴吧“匿名用户”同款）。纯 UX 细节，
  非安全/数据风险。若未来要求 per-thread persona，另开独立任务（design §3.3 已注明）。

## 真根因（本轮实验推翻 handoff 假设）

Task 7 唯一 RED 根因**不是 thread mapping**（handoff 误判为 getAfter/batch 语义）。
三组最小实验（已删）定位：reply create 规则 `validReplyDepthOne` 对 `replyTo` 文档字段
解引用，当 `reply_to_reply_id != null` 且目标是 depth-0 root（`root_reply_id` 为 null）
或不存在时，emulator 报 `Null value error`/类型不可比。修复：owner/revision/replyTo
字段访问全部用**三元短路** `(x.data == null ? false : ...)`，`replyTo.data.root_reply_id`
加 `!= null` 保护。
**emulator 特性**：`&&` 不保证短路（对 null 字段访问仍求值），必须用三元短路。

## 已完成并提交

### 代码提交 `dbcb3c4`（7 文件，Rules 10/10 + Dart 29/29 GREEN）
- `firebase/infrastructure/firestore.rules`：reply oneTimeAnonymous ID=`post_{postId}`；
  删 `playground_thread_presentations` 块；validReplyDepthOne/validReplyCreateData 三元短路。
- `firebase/infrastructure/functions/test/direct_write_schema_fixture.test.ts`：one-time
  reply 去 mapping、ID=`post_{postId}`、6 访问。165 emulator 10/10 GREEN。
- `firebase/lib/playground/firestore_direct_playground_reply_command_repository.dart`：
  `_resolveReplyPresentation`（内容派生）；删 `_resolvePresentation`/`_randomPresentationId`/
  `dart:math`/`Random`。
- `firebase/lib/playground/firebase_playground_schema.dart`：删 `threadPresentations` 常量。
- `firebase/test/playground/firestore_direct_playground_reply_command_repository_test.dart`：
  重写匿名测试（同帖稳定、跨帖不同）。
- `firebase/test/playground/firestore_direct_playground_command_support_test.dart`：删
  thread_presentations 集合断言。
- `firebase/test/playground/fixtures/direct_write_schema_v1.json`：删 thread_presentations 条目。

### 文档提交（Step 4，含本 handoff）
- `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`：
  §3.2（匿名 ID 统一内容派生）、§3.3（删 thread_presentations、加 per-thread persona 说明）、
  §4.4 数据模型清单、§10.4 访问预算表（reply 7→6）。
- `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`：Architecture、
  Task 2.1 fixture、Task 4 标题与 4.1、Task 7.1/7.2、Task 10 完成标准（访问预算 7→6）。

## 复现/验收命令

```bash
cd xuan-storage/.worktrees/playground-firebase-repairs/firebase/infrastructure/functions
FIRESTORE_EMULATOR_HOST=192.168.0.165:8080 FIREBASE_AUTH_EMULATOR_HOST=192.168.0.165:9099 \
  npx jest --runInBand direct_write_schema_fixture.test.ts   # 10/10 GREEN

cd firebase
flutter test test/playground/firestore_direct_playground_reply_command_repository_test.dart \
  test/playground/firestore_direct_playground_post_command_repository_test.dart \
  test/playground/firestore_direct_playground_command_support_test.dart   # 29/29 GREEN
```

> 注意：165 的 Firestore=8080、Auth=9099（`firebase/infrastructure/environments/README.md`）。
> handoff 里曾写的 `localhost:8082` 是本机另一套（当前未起）。
> `@firebase/rules-unit-testing` 会把本机 rules 编译下发到 165 的 `playground-test` namespace，
> 不改 165 挂载的 `/opt/podman/firebase/config/firestore.rules`。

## 遗留（不阻塞）

1. **rules L546 附近 WARNING**：verifications create 里 `depth == 0` 或类似“sub-expressions
   not comparable, always true”——本轮未动，Task 7 收尾或 Task 10 前修。
2. **旧 `firebase/infrastructure/functions/test/firestore.rules.test.ts`（771 行）** 断言旧
   callable 行为，与 v1 direct-write Rules 不匹配——Task 10 前重写/拆分。
3. Task 8：单一 Rules 源（emulator/firebase.json → `../firestore.rules`，删
   `emulator/firestore.rules`）+ `run_playground_emulator_gate.sh` + source contract test。
4. Task 9：Shell bootstrap 装配 direct adapters。Task 10：全量门禁 + 真实主链路。
5. 上一轮遗留 handoff `tasks/HANDOFF-TASK7-ANON-EVALERROR.md` 与任务文档
   `tasks/TASK7-ANON-ID-CONTENT-DERIVED.md` 保留（任务指令文档），可标注已完成。

## 关键约束（全程维持）

- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 165 emulator 只读运行测试，不写/改共享数据。
- 每 repo 独立提交；禁 merge/push main/部署；不在 main 改代码；禁 `git add -A`。
