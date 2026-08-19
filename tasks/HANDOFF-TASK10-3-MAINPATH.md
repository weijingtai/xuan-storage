# Handoff — Task 10.3 真实主链路（WIP：新测试已建，2/3 绿，1 处机械修复待做）

> Status: **IN PROGRESS — Task 10.1/10.2 完成；10.3 main-path 测试已建，3 条用例：1 过 2 待修。**
> 交接时刻: 2026-08-14
> 文件: `firebase/infrastructure/functions/test/main_path.test.ts`（**未提交**，working tree WIP）

## 一句话状态

**Task 10.3 主链路测试 `main_path.test.ts` 已写（production Rules 165 上跑）：**
- ✅「Bob 越权编辑/应验/反馈失败；Alice 应验自己的 root 失败」— GREEN
- ✕「Alice 发帖 + Bob 根/二级 + Alice 点赞/收藏/应验/反馈 全成功」
- ✕「匿名 alias 同帖稳定 + 墓碑不泄漏 + outbox/notification 未写入」

**唯一根因（已定位，机械修复）**：`FirebaseError: Provided document reference is from a
different Firestore instance` — 测试里反复调用 `bob().firestore()` / `alice().firestore()`
产生不同 Firestore 实例。test 1 已修（捕获 `bobFs`/`aliceFs` 复用，python 替换完成）；
**test 2 与 test 3 仍待同样修复**（test 2 当前误绿——assertFails 把跨实例错误当 deny；test 3 红）。

## 剩余机械修复（下一 agent，约 10 分钟）

1. 在 `main_path.test.ts` 的 test 2「Bob 越权…」开头捕获实例：
   `const bobFs = bob().firestore(); const aliceFs = alice().firestore();`
   把该 test 内所有 `bob().firestore()` → `bobFs`、`alice().firestore()` → `aliceFs`
   （含 post update、verifications、feedback、seed 后的 aliceRoot 部分）。
2. test 3「匿名 alias…」同样：开头 `const bobFs = bob().firestore(); const aliceFs = alice().firestore();`
   （anon batch 用 bobFs；墓碑 update/get 用 aliceFs；outbox/notif 读用 bobFs）。
3. 跑：
   ```bash
   cd firebase/infrastructure/functions
   FIRESTORE_EMULATOR_HOST=192.168.0.165:8080 FIREBASE_AUTH_EMULATOR_HOST=192.168.0.165:9099 \
     npx jest --runInBand main_path.test.ts   # 期望 3/3 GREEN
   ```
4. 提交：`test(playground): production-Rules main-path integration (Task 10.3)`
   （只 stage `main_path.test.ts`）。

## 已覆盖的 10.3 验收点（测试内）

- Alice 发帖（seed）+ Bob 根/二级回复（production Rules create）✅ 待修后绿
- Alice 点赞（likes+like_owners batch）、收藏（bookmarks）、应验 Bob root（verifications）、
  最终反馈（feedback+revision batch）✅ 待修后绿
- Bob 越权编辑 post / 越权应验 / 越权反馈 → deny ✅ 已绿
- Alice 应验自己的 root → deny ✅ 已绿
- 匿名 oneTimeAnonymous 回复 ID = post_{postId}（同帖稳定）✅ 待修后绿
- 墓碑：Alice 墓碑化 root → body 清空；Bob（非作者）raw get → deny；作者 get → body='' ✅ 待修后绿
- outbox/notifications 集合为空（Functions 未调用）✅ 待修后绿

## 已完成的 Task 10.1/10.2（提交在 storage `fix/playground-firebase-repairs`）

- 10.1：`35218ca`（rules 56/56：replies read + verification own-reply fix）、`3ef6390`（analyze）、
  `bff421d`（handoff）。3 pre-existing 旧 callable RED 已记录不修（范围外）。
- 10.2：`b9092de`（handoff）。两仓 RI ref 一致、零 httpsCallable、test/playground +103 全绿、
  analyze 干净。nav RED（owner verify 图标可见性）pre-existing，需产品定语义（Design §12.2
  说 owner 可应验他人 root → 应显示 verify；测试 fixture owner 置 canVerify:false 断言不显示）。

## 关键约束（维持）
- 禁 `git add -A`（shell 用户 dirty）。不 push/merge main/部署。165 只读。
- direct adapter 禁 import cloud_functions。
