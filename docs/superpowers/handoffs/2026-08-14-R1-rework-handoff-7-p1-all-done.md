# Handoff Envelope — R1 Playground Rework (P1-5..9 ALL DONE; Functions callable 按用户指示不处理)

> Status: **P1 全部完成并提交。** 交接时刻 2026-08-14。
> Rework: `tasks/REWORK-R1-PLAYGROUND-ACCEPTANCE.md`（P0-1..4 + P1-5..9 均标 DONE）
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` @ `fix/playground-firebase-repairs`
> Shell 协作: `xuan-shell/.worktrees/playground-shell-repairs` @ `fix/playground-shell-repairs`

## 一句话状态

**P1 全部完成：P1-5 Feed Filter（storage `4ce33a6`）、P1-6 详情 viewer/count（storage `01d23ec`）、
P1-7 Shell capability（shell `7e58edd`+`c60a5c1`）、P1-8 延后入口关闭（shell 提交）、P1-9 收口
（storage `ca1c062`+`09ae281`+`8fd55f0`，shell `20916fb`）。两仓 `git diff --check main...HEAD` 均 exit 0。
用户明确：**Functions callable 写入那条不处理**。P0 已由用户本地手动验证通过。**

## 最终状态验证（本会话）
- **Storage**：`git status --short` 空；`git diff --check main...HEAD` exit 0；analyze clean（lib/playground+test）。
- **Shell**：`git status --short` 仅剩 `pubspec.lock` + `macos/GeneratedPluginRegistrant.swift`（规定不提交）；
  `git diff --check main...HEAD` exit 0；`flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart`
  **+119 ~1 全绿**；analyze lib/playground lib/modules/playground_module_entry.dart clean。
- **~1 skip** = `shell_playground_bootstrap_test.dart`（VM 缺 Firebase 平台通道，平台固有 skip）；
  P1-8 的 phase_gate_test 3/3 不 skip 覆盖了 fail-closed 语义。

## 各 P1 项提交与要点
### P1-5 Feed Filter（storage `4ce33a6`）
content/time 扫描后过滤 + scanLimit + cursor filter-hash 绑定 + >10 技法报错。feed 15/15 + cursor 6/6 全绿。

### P1-6 详情 viewer/count（storage `01d23ec`）
like/bookmark 改 deterministicCreateId 与写端一致；verifiedRootReplyCount 用全帖 verification count。
thread 5/5 全绿。

### P1-7 Shell capability（shell `7e58edd`+`c60a5c1`）
capability 读端口（canEdit/canDelete/canSetFeedback/canVerify，fail closed）+ editPost/deletePost +
canSetFeedback 门控 + canEdit 控件 + AppBar delete 用 canDelete。navigation 13/13 全绿。
⚠ 关键：module entry host 的 AppBar 原本就有 delete（isOwner）→ header 加 delete 会重复（测试 findsOneWidget）
→ 已回退 header delete，只保留 edit_outlined；AppBar 改 canDelete。

### P1-8 延后入口关闭（shell 提交）
`ShellPlaygroundBootstrap` 新增 `deferredFeaturesAssembled=false`（默认不装配 Profile/通知/私信），注入
`UnavailablePlayground{Notification,Conversation,ProfileQuery}Repository` fail-closed 存根（仅 import RI，
零 Firebase 访问，抛 `unavailable` + `playground/deferred-feature-not-assembled`）；保留 Firebase 源码与 RI。
新增 `test/playground/phase_gate/phase_gate_test.dart` 3/3 全绿（不依赖 Firebase，不 skip）。
`import_boundary_test.dart` 放行 `package:xuan_shell/playground/phase_gate`（composition root 子模块）。
⚠ 注意：bootstrap 内 import 必须用 **package: 形式**（相对路径会被 import boundary 测试拦）。

### P1-9 收口工作树
- **Storage**：`ca1c062` 修 playground_contract_suite_test L156/163 trailing whitespace；
  `09ae281` 提交全部 task handoff 文档 + 删除 P0-4 失败 WIP（web_emulator_probe_test.dart [实测 hang]、
  run_local_emulator_tests.sh、firebase.json.bak）；`8fd55f0` rework doc 标 P1-8/9 DONE。
  `firebase/infrastructure/firebase.json` WIP 已 revert 回 HEAD（单一源配置不受污染）。
- **Shell**：`20916fb` 提交上一 agent error-observability + Feed async-state 工作（feed_viewmodel/
  conversation/notification/profile viewmodel + error_observability_test + feed_viewmodel_async_state_test）；
  排除 pubspec.lock / GeneratedPluginRegistrant.swift。

## 遗留 / 需人工决定
1. **Functions callable 写入**（用户明确不处理）：旧 `functions/test/firestore.rules.test.ts`（771 行）断言旧
   callable 行为，与 v1 direct-write Rules 不匹配，Task 10 门禁未包含它。按用户指示跳过。
2. **shell `~1` skip**（bootstrap test 平台固有）——如需"零 skip"最终证据，需在 device/chrome 跑一次
   `shell_playground_bootstrap_test.dart`（本机有 Chrome，但 165 CORS 需用户本地处理）。
3. **最终验收命令**（评审 §最终验收命令）需用户人工跑三仓（RI/Storage/Shell）确认 exit 0。Storage
   `run_playground_emulator_gate.sh` 依赖 165 emulator（用户已本地验证 P0-4 通过）。

## 复现命令
```bash
# Storage
cd xuan-storage/.worktrees/playground-firebase-repairs/firebase
flutter test --no-pub test/playground          # 基线 +247 ~1 -3（3 legacy callable RED + 1 skip + 无 probe）
dart analyze lib/playground test/playground     # clean
cd .. && git diff --check main...HEAD            # exit 0

# Shell
cd xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart  # +119 ~1
dart analyze lib/playground lib/modules/playground_module_entry.dart   # clean
git diff --check main...HEAD                     # exit 0
```

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁 import cloud_functions；callable 源码保留不装配（用户已确认不处理）。
- 165 emulator 只读；禁 merge/push main/部署；不在 main 改代码；禁 `git add -A`。
- Shell `pubspec.lock`/`GeneratedPluginRegistrant.swift` 永不提交。
