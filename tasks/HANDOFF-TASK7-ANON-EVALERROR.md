# DEPRECATED — 已被 `docs/superpowers/handoffs/2026-08-14-playground-firestore-direct-write-task7-anon-content-derived.md` 取代（Task 7 已完成）。
> 保留此文件仅记录中间态；新 agent 以新 handoff 为准。
# Handoff — Task 7 匿名 ID 内容派生改造（Step 1-3 DONE + GREEN，Step 4 docs 未完成）

> Status: **IN PROGRESS — code GREEN & committed (`dbcb3c4`); Step 4 (design/plan docs) remains.**
> Branch: `fix/playground-firebase-repairs`（worktree `xuan-storage/.worktrees/playground-firebase-repairs`）
> Task doc: `tasks/TASK7-ANON-ID-CONTENT-DERIVED.md`（已更新含真根因）
> 交接时刻: 2026-08-14

## 一句话状态

**Task 7 唯一 RED 已消除。匿名 ID 改为内容派生 `post_{postId}`（reply 与 post 一致），
mapping 全链路删除。Rules fixture 10/10 GREEN、Dart 29/29 GREEN、analyze 干净，已提交
`dbcb3c4`（7 文件）。唯一未完成：Step 4 文档更新（design §3.2/§3.3/§6.2、plan Task 4/7/10）。**

## 真根因（推翻 handoff 假设，重要）

Task 7 唯一 RED 的根因**不是匿名 mapping**（handoff 误判为 thread_presentations 的
getAfter/batch 语义）。三组最小实验定位：reply create 规则 `validReplyDepthOne` 里对
`replyTo` 文档的字段解引用，当 `reply_to_reply_id != null` 且目标是 depth-0 root
（`root_reply_id` 为 null）或不存在时，emulator 报 **`Null value error`/类型不可比**。
修复：owner/revision/replyTo 的字段访问全部用**三元短路** `(x.data == null ? false : ...)`，
`replyTo.data.root_reply_id` 加 `!= null` 保护。
**emulator 特性**：`&&` 不保证短路（对 null 字段访问仍求值），必须用三元短路。
真实 batch 路径（reply+owner+revision，reply_to=depth-0 root）GREEN。单 set / 跨集合
reply_to 的 error 是真实业务不走的路径（adapter 永远 batch 写 owner+revision；reply_to
恒指向同集合存在的 reply）。

## 已完成并提交（`dbcb3c4`，7 文件）

- `firebase/infrastructure/firestore.rules`：reply oneTimeAnonymous ID = `post_{postId}`；
  删 `playground_thread_presentations` 块；validReplyDepthOne/validReplyCreateData 三元短路。
- `firebase/infrastructure/functions/test/direct_write_schema_fixture.test.ts`：one-time
  reply 去 mapping、ID=`post_{postId}`、6 访问。**165 emulator 10/10 GREEN。**
- `firebase/lib/playground/firestore_direct_playground_reply_command_repository.dart`：
  `_resolveReplyPresentation`（内容派生），删 `_resolvePresentation`/`_randomPresentationId`/
  `dart:math`/`Random`。
- `firebase/lib/playground/firebase_playground_schema.dart`：删 `threadPresentations` 常量。
- `firebase/test/playground/firestore_direct_playground_reply_command_repository_test.dart`：
  重写匿名测试（同帖稳定 `post_{postId}`、跨帖 `post_{post2}` 不同）。
- `firebase/test/playground/firestore_direct_playground_command_support_test.dart`：删
  thread_presentations 集合断言。
- `firebase/test/playground/fixtures/direct_write_schema_v1.json`：删 thread_presentations 条目。

残留引用检查：lib/test/rules/functions-test 中 `thread_presentations`/`threadPresentations`/
`thread-presentation`/`_randomPresentationId` 命中 **0**。

## 未完成（下一 agent 起点）

1. **Step 4 —— 更新文档**（`docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
   §3.2/§3.3/§6.2；`docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
   Task 4/7/10 完成标准与访问预算 7→6；写一份 handoff 到 `docs/superpowers/handoffs/`）。
   这是唯一剩余的代码外工作，不影响 GREEN。
2. **Step 6 —— 提交文档**（单独 commit，精确文件，禁 `-A`）。
3. 可选：跑一遍 `firebase/infrastructure/functions` 全量 rules 测试确认无回归
   （`firestore.rules.test.ts` 旧断言 Task 10 前重写，已知不匹配新规则——记录勿修）。

## 验收命令（已通过，供复核）

```bash
cd firebase/infrastructure/functions
FIRESTORE_EMULATOR_HOST=192.168.0.165:8080 FIREBASE_AUTH_EMULATOR_HOST=192.168.0.165:9099 \
  npx jest --runInBand direct_write_schema_fixture.test.ts   # 10/10 GREEN

cd firebase
flutter test test/playground/firestore_direct_playground_reply_command_repository_test.dart \
  test/playground/firestore_direct_playground_post_command_repository_test.dart \
  test/playground/firestore_direct_playground_command_support_test.dart        # 29/29 GREEN
dart analyze lib/playground/firebase_playground_schema.dart \
  lib/playground/firestore_direct_playground_reply_command_repository.dart     # no issues
```

## 关键约束（维持）

- 165 只读运行测试（Firestore=165:8080、Auth=165:9099；`localhost:8082` 是本机另一套当前未起）。
- 禁 `git add -A`；不 push/merge main/部署；direct adapter 禁 import `cloud_functions`。
- 遗留：rules L546 附近 verifications 的 WARNING（类型不可比）与旧 `firestore.rules.test.ts`
  断言旧行为——Task 10 前处理，本轮只记录不修。
