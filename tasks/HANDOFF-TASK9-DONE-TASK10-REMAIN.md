# Handoff — Task 9 Shell 装配（DONE both repos）；Task 10 未开始

> Status: **Task 9 DONE（storage `7db4ce6` + shell `8d014f2`）；Task 10 未开始。**
> 交接时刻: 2026-08-14
> Task doc: `tasks/TASK9-SHELL-ASSEMBLY.md`（storage 仓）

## 一句话状态

**Task 9 完成：storage 导出 5 个 FirestoreDirect* adapter（`7db4ce6`）；shell bootstrap 8 端口
装配 direct/read adapter + 新增装配契约测试（`8d014f2`）。capability 测试已 GREEN（Task 6 完成）。
Task 10（全量门禁 + 真实主链路）未开始。**

## 已完成

### storage `7db4ce6`
- `firebase/lib/playground/playground.dart`：追加 export
  FirestoreDirectPlayground{PostCommand,ReplyCommand,Engagement,Verification,
  OutcomeFeedback}Repository。`dart analyze` 无错误。

### shell `8d014f2`
- `lib/playground/shell_playground_bootstrap.dart`：8 端口装配
  - post/reply/engagement/verification/outcomeFeedback → FirestoreDirect*（生产直写）
  - feedQuery/threadQuery/report → 保持 Firebase*（read/直写）
  - profile/notification/conversation/moderation/media/realtime → 保持现状
- `test/playground/shell_playground_bootstrap_test.dart`（新建）：8 端口装配契约 +
  playgroundEnabled=false → null。VM 下平台通道缺 → markTestSkipped（与 emulator 集成测试
  同约定）。
- 验收：`flutter test shell_playground_bootstrap_test + post_detail_viewer_capability_test`
  → 全 GREEN；`dart analyze` 干净。

## 未完成 / 下一步（Task 10）

1. **Task 10.1 Storage 门禁**：
   ```bash
   cd xuan-storage/.worktrees/playground-firebase-repairs/firebase
   flutter test test/playground
   dart analyze lib/playground test/playground
   cd infrastructure/functions
   npm test -- --runInBand firestore.rules.test.ts direct_write_schema_fixture.test.ts
   ```
   注意：`firestore.rules.test.ts`（771 行）断言旧 callable 行为，与 v1 direct-write Rules
   不匹配，**Task 10 前需重写/拆分**（handoff 已标注遗留）。
2. **Task 10.2 Shell 与依赖门禁**：两仓 `resolved-ref` 相同；production composition 零
   `httpsCallable`；Feed 不显示假 0；详情真实计数；所有测试零 skip；两仓 `git diff --check`。
3. **Task 10.3 真实主链路**：production Rules Emulator（165:8080/9099）Alice 发帖 → Bob
   根/二级回复 → Alice 点赞/收藏/应验/反馈 → Bob 越权失败 → 匿名 alias 同帖稳定跨帖不同 →
   墓碑不泄漏 → Functions/outbox/notification 未调用。

## 遗留 / 已知问题（记录，非本 Task 责任）

1. **shell `playground_navigation_contract_test.dart` "signed-in owner sees delete/feedback but
   not verification" RED**：经验证，**有无 Task 9 改动都失败**（pre-existing），与 owner
   verification 图标可见性相关。Task 6/9 范围外；怀疑与页面渲染 `canVerify` 逻辑有关，
   需 Task 10 排查或交产品确认（owner 是否应隐藏应验按钮——Design §12.2 说页面级 canVerify
   只表示 owner，点击后 Rules 拒绝自己的 root，UI 回滚。测试期望 owner **看不到** verify
   图标，而实现可能仍显示）。
2. **shell worktree 有用户 dirty 文件**（conversation/feed/notification/profile viewmodels、
   pubspec.lock、macos/GeneratedPluginRegistrant.swift、error_observability_test、
   feed_viewmodel_async_state_test）——**未触碰**，Task 9 只 stage 了 bootstrap + 新测试。
3. **storage 旧 `firestore.rules.test.ts`** 断言旧行为，Task 10 前重写。
4. rules L546 verifications WARNING（类型不可比）待修。

## 关键约束（维持）

- 禁 `git add -A`（shell 有用户 dirty）；只 stage Task 精确文件。
- 不 push / 不 merge main / 不部署。165 emulator 只读。
- direct adapter 禁 import `cloud_functions`；callable 源码保留不装配。
- 下一 agent：先读 `tasks/TASK9-SHELL-ASSEMBLY.md` 与 plan Task 10，再动 Task 10。
