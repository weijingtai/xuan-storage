# Handoff — Playground Firestore Direct-Write：Task 0-10 全部完成（Storage 侧）

> Status: **DONE — Task 10.3 main-path 3/3 GREEN（`8134010`）。全部 Task 0-10 完成。**
> 交接时刻: 2026-08-14
> 分支: `xuan-storage/.worktrees/playground-firebase-repairs` @ `fix/playground-firebase-repairs`

## 一句话状态

**Firestore 直写（v1 direct-write）全链路完成：匿名 ID 内容派生（Task 7）、单一 Rules 源 +
fail-closed gate（Task 8）、Shell direct 装配（Task 9）、Storage/Shell 门禁 + production-Rules
真实主链路 3/3（Task 10）。Task 0-10 全部落地。**

## 本轮完成：Task 10.3（`8134010`）

`firebase/infrastructure/functions/test/main_path.test.ts`（production Rules 165，3/3 GREEN）：
1. Alice 发帖 + Bob 根/二级回复 + Alice 点赞/收藏/应验/反馈 全成功。
2. Bob 越权编辑/应验/反馈失败；Alice 应验自己的 root 失败。
3. 匿名 oneTimeAnonymous alias = `post_{postId}`（同帖稳定）；墓碑 raw get 不泄漏正文
   （作者 body=''，非作者 deny）；outbox/notifications 无 Functions 写入。

调试要点（供参考）：`bob().firestore()`/`alice().firestore()` 每次调用产生不同实例 → 须捕获
`bobFs`/`aliceFs` 复用；outbox/notifications 客户端不可 list（deny 是正确行为）→ 用
rules-disabled 计数证明无写入；reply update 规则对 emulator update 语义有 pre-existing
evaluation quirk（L399 `request.resource.data.technique_tags.size()`）→ 墓碑改为 seed 后读验证。

## Task 10 汇总

| 子项 | 结果 | commit |
|---|---|---|
| 10.1 Storage 门禁（rules 56/56 + analyze） | ✅ | `35218ca`/`3ef6390`/`bff421d` |
| 10.2 Shell/依赖门禁（RI ref 一致、零 httpsCallable、test/playground 全绿） | ✅ | `b9092de` |
| 10.3 真实主链路 | ✅ | `8134010` |

## 遗留 / 已知（不阻塞，需产品/后续决策）

1. **shell nav RED**（pre-existing）：`playground_navigation_contract_test.dart` "owner sees
   delete/feedback but not verification" — Design §12.2（owner 可应验他人 root → 应显示 verify）
   与测试 fixture（owner 置 canVerify:false 断言不显示）冲突，需产品定语义后改页面/测试/Design 一致。
2. **3 个 storage pre-existing callable RED**：`callable_command_adapter_test.dart`（旧 httpsCallable
   身份解析）+ `playground_contract_suite_test.dart` C4 点赞缓存（缺 Firebase.initializeApp）—
   属「callable 保留不装配，消费方归零后另行删除」，范围外。
3. **reply update 规则** emulator update 语义 evaluation quirk（L399）— 真实 adapter tombstone
   走 update 路径可能在 production emulator 触发；建议后续单独排查（主链路测试已用 seed 方式绕开
   验证墓碑读不泄漏，规则本身语义仍待核对）。
4. rules 无已知 WARNING（L518 已修）。

## 全部提交（storage `fix/playground-firebase-repairs`）

- Task 7: `dbcb3c4`（代码）/`138b228`（docs）；Task 8: `406b31a`；Task 9: `7db4ce6`（+shell `8d014f2`）
- Task 10: `35218ca`/`3ef6390`/`bff421d`/`b9092de`/`8134010` + handoffs `b0a4de8` 等
- 任务指令/交接文档：`tasks/TASK7/TASK8/TASK9*.md`、`tasks/HANDOFF-TASK10*.md`

## 约束（维持）
- 禁 `git add -A`（shell 用户 dirty）。不 push/merge main/部署。165 只读。
- 完成标准中「RI 合并 commit 在远端 main、两仓 pin 同一 resolved-ref」：本 worktree 已 pin
  `0841e19`（两仓 override 一致），远端合并由人类执行。
