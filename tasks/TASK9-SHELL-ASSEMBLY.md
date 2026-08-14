# Task 9 — 导出、Shell 装配与 ViewModel capability

> 状态：ACTIVE（2026-08-14）
> 目标：按 Design §12 装配 8 个 direct/read adapter；profile/notification/conversation 保持
>       未完成现状；PostDetailViewModel.isOwner 只读 viewerState.isOwner（已部分完成）。
> 权威基线：`docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md` §12
>         + `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md` Task 9
> 跨仓：storage `playground-firebase-repairs`（firebase adapter）+ shell `playground-shell-repairs`
> 单句启动语：按本文件执行：storage 导出 direct adapters，shell bootstrap 8 端口装配 direct
>            adapter，补 bootstrap 测试，以两仓 focused test/analyze 全绿验收。

## 1. 装配目标（Design §12 冻结表）

| RI port | adapter（本期生产装配） | 现状 |
|---|---|---|
| postCommandRepository | `FirestoreDirectPlaygroundPostCommandRepository` | storage 已有，未导出 |
| replyCommandRepository | `FirestoreDirectPlaygroundReplyCommandRepository` | storage 已有，未导出 |
| engagementRepository | `FirestoreDirectPlaygroundEngagementRepository` | storage 已有，未导出 |
| verificationRepository | `FirestoreDirectPlaygroundVerificationRepository` | storage 已有，未导出 |
| outcomeFeedbackRepository | `FirestoreDirectPlaygroundOutcomeFeedbackRepository` | storage 已有，未导出 |
| feedQueryRepository | 更新现有 `FirebasePlaygroundFeedQueryRepository` | shell 现有 |
| threadQueryRepository | 更新现有 `FirebasePlaygroundThreadQueryRepository` | shell 现有 |
| reportRepository | 现有直写 adapter | shell 现有 |

profile/notification/conversation/moderation/media/realtime 继续注入现有 adapter（构造兼容），
页面与 UseCase 不属本期验收。

## 2. Files

### storage 仓（`xuan-storage/.worktrees/playground-firebase-repairs`）
- Modify: `firebase/lib/playground/playground.dart` — export 5 个 direct adapter：
  `firestore_direct_playground_post_command_repository.dart`、
  `firestore_direct_playground_reply_command_repository.dart`、
  `firestore_direct_playground_engagement_repository.dart`、
  `firestore_direct_playground_verification_repository.dart`、
  `firestore_direct_playground_outcome_feedback_repository.dart`。

### shell 仓（`xuan-shell/.worktrees/playground-shell-repairs`）
- Modify: `lib/playground/shell_playground_bootstrap.dart` — 8 端口换 direct/read adapter。
- Modify: `lib/playground/viewmodels/post_detail_viewmodel.dart` — 已满足（Task 6 已改），
  仅复核 `isOwner` 只读 `viewerState.isOwner`。
- Create: `test/playground/shell_playground_bootstrap_test.dart` — 断言 create() 装配
  direct/read adapter 实例类型（post/reply/engagement/verification/outcomeFeedback =
  FirestoreDirect*；feedQuery/threadQuery/report = 现有 Firebase*）。
- Modify: `test/playground/post_detail_viewer_capability_test.dart` — 已 GREEN，不追加。

## 3. 禁止项（NEVER）

- 不改 storage `firestore.rules` / indexes（Task 7 已验收）。
- 不把 `ref:` / path override 写进出库 pubspec；依赖解析只通过 gitignored
  `pubspec_overrides.yaml`（shell worktree 已有，勿动其结构）。
- 不复活 deprecated facade（`FirebasePlaygroundPostRepository/ReplyRepository`）。
- 不删 callable 源码；只是不装配。
- 只 stage 本 Task 精确文件；禁 `git add -A`（shell 有用户 dirty）。
- 不 push / 不 merge main / 不部署。

## 4. 顺序化任务与门禁

### Step 1 —— storage 导出（先做，shell 依赖它）
- [ ] `firebase/lib/playground/playground.dart` 追加 5 个 direct adapter export。
- [ ] `cd firebase && dart analyze lib/playground` → no issues。

### Step 2 —— shell bootstrap 装配
- [ ] import `package:persistence_firebase/playground/playground.dart` 追加
  `FirestoreDirectPlaygroundPostCommandRepository` 等 5 个符号。
- [ ] `PlaygroundDependencies.create()` 中 8 端口换 direct/read adapter：
  - postCommand → FirestoreDirectPlaygroundPostCommandRepository
  - replyCommand → FirestoreDirectPlaygroundReplyCommandRepository
  - engagement → FirestoreDirectPlaygroundEngagementRepository
  - verification → FirestoreDirectPlaygroundVerificationRepository
  - outcomeFeedback → FirestoreDirectPlaygroundOutcomeFeedbackRepository
  - feedQuery / threadQuery / report → 保持现有 Firebase* adapter
  - profile/notification/conversation/moderation/media/realtime 保持现状。
- [ ] `dart analyze lib/playground` → no issues。

### Step 3 —— 写 RED + GREEN（bootstrap 测试）
- [ ] Create `test/playground/shell_playground_bootstrap_test.dart`：
  - 用 `MockFirebaseAuth`/`FakeFirebaseFirestore`（或最小 stub）调 `create()`，
    断言返回的 dependencies 各字段是期望 adapter 类型。
  - `playgroundEnabled=false` → `create()` 返回 null（停写开关）。
  - RED：先断言期望 direct 类型，跑出失败（当前装配还是 callable）→ 再修 Step 2 → GREEN。
- [ ] `flutter test --no-pub test/playground/shell_playground_bootstrap_test.dart
      test/playground/post_detail_viewer_capability_test.dart
      test/modules/playground_navigation_contract_test.dart` → 全绿。
- [ ] `dart analyze lib/playground lib/modules/playground_module_entry.dart` → 无问题。

### Step 4 —— 分仓提交
- [ ] storage 仓：只 stage `firebase/lib/playground/playground.dart` + 任务文档；
  commit `feat(playground): export direct adapters for Shell assembly (Task 9)`。
- [ ] shell 仓：只 stage bootstrap + 新测试；commit
  `feat(playground): assemble direct adapters in Shell bootstrap (Task 9)`。

## 5. 停止条件 / 上报

- 任一步 RED 2 次内无法修 → 停止、回退本 Task 改动、报告主代理。
- 依赖解析失败（stale lock / path override）→ 按 AGENTS.md 依赖排查表处理（rm lock +
  pub get），不算业务 RED。
- 发现 Task 9 外问题（如旧 callable 测试断言）→ 只记录不顺手修。

## 6. 证据产物

- 两仓 analyze/test 输出（全绿）。
- 两仓 `git log -1` 与 `git diff --stat`。
