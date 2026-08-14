# Handoff Envelope — R1 Playground Rework (P1-5/6/7 DONE committed; P1-8/9 REMAIN)

> Status: **IN PROGRESS — 主代理 tool-iteration budget 用尽（~43/50）。P1-5/6/7 已完成并提交。**
> Rework: `tasks/REWORK-R1-PLAYGROUND-ACCEPTANCE.md` + `docs/superpowers/reviews/2026-08-13-playground-direct-write-acceptance-rework.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` @ `fix/playground-firebase-repairs`
> Shell 协作: `xuan-shell/.worktrees/playground-shell-repairs` @ `fix/playground-shell-repairs`
> 交接时刻: 2026-08-14

## 一句话状态

**用户已确认 P0-4 通过（本地手动跑过 165 emulator）→ 跳过。P1-5（storage `4ce33a6`）、P1-6（storage
`01d23ec`）、P1-7（shell `7e58edd`+`c60a5c1`）均完成并提交。P1-8（延后入口关闭）、P1-9（收口工作树）未完成。**

## 本会话已完成（已提交）

### P1-5 Feed Filter（storage commit `4ce33a6`）
- `firebase_playground_feed_query_repository.dart`：content（withChart/textOnly 读 has_chart）+ timeRange
  （today/week/month/year 读 created_at）扫描后过滤；`scanLimit=min(limit*5,100)`；cursor 推进规则（命中
  limit → 最后返回项；未命中 → 最后扫描文档）；cursor filter-hash 绑定（换 filter → `filter/cursor-filter-mismatch`）；
  技法 >10 → `filter/technique-count-exceeded`。
- `firebase_playground_cursor.dart`：`fromQueryDocumentWithOrderBy` 加 `filterHash` 可选参数 + `filterHashOf()`。
- 测试：feed 15/15 + cursor 6/6 全绿。
- ⚠ 关键坑：fake_cloud_firestore `startAfter(values)` 返回空（desc+values 模式不可靠），必须
  `startAfterDocument` 优先。cursor payload 用 `'filterHash': ?filterHash`（null-aware **value**）。

### P1-6 详情 viewer/count（storage commit `01d23ec`）
- `firebase_playground_thread_query_repository.dart`：`_viewerStateForPost` like/bookmark 改
  `deterministicCreateId(operation:'like'/'bookmark', authUid, idempotencyKey: postId)`（与写端
  `firestore_direct_playground_engagement_repository.dart` 完全一致）；删除额外 bookmark query；
  `verifiedRootReplyCount` 用全帖 `verifications post_id==+revoked_at==null count()`（不再当前页 root 数）；
  去掉逐 10 个 root ID verification 分块查询。
- 测试：thread 5/5 全绿（写后即 liked/bookmarked、旧错误 ID 不可匹配、>50 回复准确）。

### P1-7 Shell capability/门禁（shell commits `7e58edd`+`c60a5c1`）
- `PostDetailViewModel`：新增 `canEdit/canDelete/canSetFeedback/canVerify` 能力读端口（fail closed，非 isOwner）
  + `editPost`/`deletePost` 方法（use case **可选注入**，旧调用方不破坏）。
- `post_detail_page.dart`：反馈改 `canSetFeedback` 门控（撤销+添加）；header 新增 `canEdit` 编辑控件
  （`Icons.edit_outlined`）。
- `playground_module_entry.dart`：AppBar 删除按钮改 `_detailViewModel.canDelete`（原 `_isOwner`，已删 `_isOwner`）。
- 新增 `edit_post_usecase.dart`/`delete_post_usecase.dart`（EditPostCommand/DeletePostCommand 直连 adapter）。
- navigation contract 测试 `_RecordingRepositories` owner case viewerState 补
  `isOwner/canEdit/canDelete/canSetFeedback`。
- 验证：`flutter test --no-pub test/modules/playground_navigation_contract_test.dart` 13/13 全绿；
  `flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart` +116 全绿；
  `dart analyze lib/playground lib/modules/playground_module_entry.dart` clean。
- ⚠ 关键：module entry host 的 AppBar 原本就有 delete_outline（isOwner 门控）→ 我 header 加的 delete 会重复
  （测试 findsOneWidget）→ **已回退 header delete，只保留 edit_outlined**；AppBar delete 改 canDelete。

## 未完成

### P1-8 延后入口真正关闭（Shell）
- Shell production 仍装配 Profile/通知/私信（`playground_module_entry.dart` 注册了 notifications/conversations/
  profile 路由，`ShellPlaygroundBootstrap.create` 装配了 Notification/Conversation/Profile 仓库）。
- 指导：保留源码和 RI，但本期 production route/dependencies **不暴露、不触发读写**；加"未注册/未装配"测试。
- Shell 已有上一 agent 的 WIP 改动可能相关：`conversation_viewmodel.dart`、`notification_viewmodel.dart`、
  `profile_viewmodel.dart`、`feed_viewmodel.dart`、`test/playground/viewmodel/error_observability_test.dart`、
  `test/playground/viewmodel/feed_viewmodel_async_state_test.dart`（**均未提交**，需确认归属后处理）。

### P1-9 收口工作树
- **Storage**：未提交的 `firebase/infrastructure/firebase.json`（加 emulators 8082/9099 + firestore port 8081，
  上一 agent 本地 emulator WIP，与单一源冲突，**倾向 revert 回 HEAD**）；`firebase.json.bak`、
  `firebase/scripts/run_local_emulator_tests.sh`、`firebase/test/playground/web_emulator_probe_test.dart`
  （已实测 hang 失败）；9 个旧 handoff md + 我的 2 个新 handoff md → 确认证据价值后清理/归档。
- **Shell**：未提交 viewmodel 改动（见 P1-8）；`macos/GeneratedPluginRegistrant.swift`、`pubspec.lock` 勿提交。
- `git diff --check main...HEAD` 两仓需 exit 0。

## 测试基线（本会话验证）
- Storage: feed 15/15 + cursor 6/6 + thread 5/5 全绿；P1-5/6 analyze clean。
- Shell: navigation 13/13 + test/playground +116 全绿；analyze clean。
- P0 基线（此前会话）：rules 45/45 + fixture 11/11 + main_path 3/3 + state_machine 18/18 = 77/77（165 emulator）。

## 复现/验收命令
```bash
# Storage P1-5/6
cd xuan-storage/.worktrees/playground-firebase-repairs/firebase
flutter test --no-pub test/playground/firebase_playground_feed_query_repository_test.dart \
  test/playground/firebase_playground_cursor_test.dart \
  test/playground/firebase_playground_thread_query_repository_test.dart

# Shell P1-7
cd xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart
dart analyze lib/playground lib/modules/playground_module_entry.dart

# 最终验收（评审 §最终验收命令）三仓全绿 exit 0、零 skip 才可改判 PASS。
```

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 165 emulator 只读运行测试；Emulator 不可达不算业务 RED/GREEN。
- 每 repo 独立提交；禁 merge/push main/部署；不在 main 改代码；禁 `git add -A`。
- 只 stage 本 Task 精确文件；Shell `macos/GeneratedPluginRegistrant.swift`、`pubspec.lock` 勿提交。
