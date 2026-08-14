# Handoff Envelope — R1 Playground Rework (P0-4 investigation; P1-5..9 REMAIN)

> Status: **IN PROGRESS — 主代理 tool-iteration budget 用尽（40/50），已做 P0-4 调查但未改代码。**
> Rework: `tasks/REWORK-R1-PLAYGROUND-ACCEPTANCE.md` + `docs/superpowers/reviews/2026-08-13-playground-direct-write-acceptance-rework.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` @ `fix/playground-firebase-repairs`
> Shell 协作: `xuan-shell/.worktrees/playground-shell-repairs` @ `fix/playground-shell-repairs`
> 交接时刻: 2026-08-14

## 一句话状态

**P0-1/2/3 已完成并提交（`c79196a` + `d2ec2df`，77/77 全绿）。P0-4 只做了调查未改码：当前
`main_path.test.ts` 仍用 `withSecurityRulesDisabled` seed 帖子/根回复/墓碑（评审点名假覆盖），
`run_playground_emulator_gate.sh` 未运行真实 direct adapter。P1-5..9 未开始。**
上一 agent 留下的 P0-4 WIP（`web_emulator_probe_test.dart` Chrome 方案）**已实测失败（hang）**，不要沿用。

## 本会话已确认的事实基线（供下个 agent 直接使用）

### 环境
- **165 emulator 可达**：`192.168.0.165:8080`(Firestore) + `:9099`(Auth) 均 OPEN，HTTP 探活 200。
- 本地 emulator（8082/9099）未起。Flutter 3.44.6，Chrome 可用（`--platform=chrome` 可跑但 hang）。
- 直接给结果：`bash firebase/scripts/run_playground_emulator_gate.sh` **当前已通过**（单一源 + 165 可达 + fixture 11/11 + source contract 3/3），但**没跑 main_path / 没跑 direct adapter**——这正是 P0-4 缺口。

### 已验证的测试基线
- `direct_write_schema_fixture.test.ts` 11/11 GREEN（165）。
- `main_path.test.ts` 3/3 GREEN（165），**但 post/root/tombstone 用 withSecurityRulesDisabled seed**（`main_path.test.ts:93-121` seedPost/seedRootReply、`:263-275` tombstone）——评审点名要改成认证客户端经 production Rules 创建 + 真实调 direct adapter edit/tombstone/unlike/revoke/re-publish。
- `state_machine.test.ts` 18/18 GREEN（165，c79196a/d2ec2df 新增的负例）。
- `flutter test --no-pub test/playground`（VM）：+247 ~1 -3——3 个 legacy 失败（callable_command_adapter identity、playground_contract_suite 点赞 C4 两个）+ 1 skip（emulator integration VM 下 skip）+ `web_emulator_probe_test.dart` VM 下 error（需 chrome，且 chrome 也 hang）。
- `npm test -- --runInBand firestore.rules.test.ts`（771 行旧 callable 套件）**未跑**，评审明确要求 Task 10 前重写/拆分。

### P0-4 方案调查结论（重要）
1. **Chrome 方案失败**：上一 agent 的 `firebase/test/playground/web_emulator_probe_test.dart`（`--platform=chrome`）hang 到 "did not complete"，日志无任何 error detail。165 emulator HTTP 健康（/ 返回 Ok），问题在 web SDK 连接/初始化或 CORS。**不要沿用此 WIP**（该文件是 untracked WIP，建议删除或修复）。
2. 参考 `test/account/firebase_account_auth_gateway_emulator_test.dart`（同模式，`--platform=chrome` + markTestSkipped fallback）——本会话已启动其 chrome 复测但被 budget 截断，结果未知（`/tmp/accountprobe.log`）。
3. **更可行的路径待验证**：Dart direct adapter 需要真实 platform channels。可选：(a) `flutter test --platform=chrome` 修好连接（需排查 hang 根因，可能是 Firebase.initializeApp options/authDomain 缺失或 firestore Settings host 配置）；(b) 在 TS `main_path.test.ts` 内**直接用 @firebase/rules-unit-testing 认证客户端**把 seedPost/seedRootReply 改成 production-Rules 下创建（TS 已证明能连 165），再补 direct adapter 等价操作——评审核心是"认证客户端经 production Rules 创建 + 真实状态机"，TS 认证上下文已满足此语义。**下个 agent 应优先评估 (b)**：把 `main_path.test.ts` 的 rules-disabled seed 改为 authenticated client 经 Rules create（post+owner+revision 同批），并新增"经 Rules 创建后 edit/tombstone/unlike/revoke/re-publish 真实调用"断言。若评审接受 TS 层覆盖，gate 里加跑 main_path + state_machine 即可满足 P0-4"零 skip"。
4. **注意 WIP 文件归属**：`infrastructure/firebase.json` 有未提交修改（加 emulators 8082/9099 + firestore port 8081，配 `firebase.json.bak`）——这是上一 agent 尝试本地 emulator 的 WIP，**与已提交的 emulator/firebase.json 单一源配置冲突**，评审 P1-9 要求收口。除非确认有意保留，否则应 revert 回 HEAD（`git show HEAD:firebase/infrastructure/firebase.json` 是纯生产 config，无 emulators 段）。
   `firebase/scripts/run_local_emulator_tests.sh` 是跑 4 个 TS 套件的本地脚本（本地 8082，当前未起）——可选归档或删。

## 已完成（提交于本 worktree 分支）
- `82a4945` review: R1 request playground rework
- `c79196a` P0-1/2/3 rules —— update 用 diff().affectedKeys()、revision 同批核验、like unlike 原子删除、feedback revision 仅 owner（146 行 rules 改动，77 全绿）
- `d2ec2df` P0 state-machine —— feedback revoke 旧快照/update 守卫、like owner-only delete + 18 状态机测试
- 更早 Task 6-10 storage 全部 DONE（f7e7581 等）

## 未完成（按评审顺序）
### P0-4（本轮焦点）
- [ ] 重建真实主链路验收：`main_path.test.ts` 去掉 withSecurityRulesDisabled seed post/root/tombstone；认证客户端经 production Rules 创建 post/root/discussion；真实调 direct adapter edit/tombstone/unlike/revoke/re-publish；初始化失败/Emulator 不可达 exit!=0，零 skip。优先评估 TS 认证上下文方案（见上 3b）。
- [ ] `run_playground_emulator_gate.sh` 补跑 main_path + state_machine（当前只跑 fixture + source contract）。
- [ ] `firebase_playground_emulator_integration_test.dart:19-62` 仍旧 callable 路径 + 可 skip —— 需改 direct adapter 或明确由 TS 主链路替代并注释。
- [ ] 旧 `functions/test/firestore.rules.test.ts`（771 行 callable 断言）Task 10 前重写/拆分（当前跑会大量失败，勿当回归）。

### P1（P0 后）
- [ ] **5 Feed Filter**：`firebase_playground_feed_query_repository.dart:83-151` 只 technique 忽略 content/time，`take(10)` 静默丢条件；cursor 绑定 filter hash + 最后扫描文档推进。
- [ ] **6 详情 viewer/count**：`firebase_playground_thread_query_repository.dart:254-264` 用不存在的 like 文档 ID + 额外 bookmark query；`:221-224` 把当前页 verified root 数当全帖总数。like/bookmark 用与写端一致 deterministic direct-get ID；verified count 用已执行 aggregation。
- [ ] **7 Shell capability/门禁**：`post_detail_page.dart` 无 canDelete/canEdit 控件、反馈按 isOwner 非 canSetFeedback；`playground_navigation_contract_test.dart:107-115` 失败；bootstrap test skip。Shell worktree 有未提交 viewmodel 改动（见下）。
- [ ] **8 延后入口关闭**：Shell production 仍装配 Profile/通知/私信 → 加"未注册/未装配"测试。
- [ ] **9 收口工作树**：Shell 未提交 VM/test 改动；Storage 9 个未跟踪 handoff + 本 WIP；`git diff --check main...HEAD` 报 trailing whitespace。只提交精确文件，禁 `git add -A`。

### Shell 协作 worktree 状态
`xuan-shell/.worktrees/playground-shell-repairs` @ `fix/playground-shell-repairs`，有未提交：
- M: conversation/feed/notification/post_detail/profile viewmodel、error_observability_test、`macos/GeneratedPluginRegistrant.swift`、`pubspec.lock`
- ??: `test/playground/viewmodel/feed_viewmodel_async_state_test.dart`
（`macos/GeneratedPluginRegistrant.swift`、`pubspec.lock` 勿提交；只 stage 精确 Task 文件）

## 复现/验收命令
```bash
# TS 套件（165）
cd firebase/infrastructure/functions
FIRESTORE_EMULATOR_HOST=192.168.0.165:8080 FIREBASE_AUTH_EMULATOR_HOST=192.168.0.165:9099 \
  npx jest --runInBand direct_write_schema_fixture.test.ts main_path.test.ts state_machine.test.ts

# Storage 门禁
cd firebase
flutter test --no-pub test/playground          # 基线 +247 ~1 -3（3 legacy + 1 skip + probe error）
dart analyze lib/playground test/playground
bash scripts/run_playground_emulator_gate.sh    # 当前绿但未覆盖 main_path/direct adapter

# 最终验收（评审 §最终验收命令）
# RI / Storage / Shell 三仓命令见评审文档 §最终验收命令，全部 exit 0、零 skip 才可改判 PASS。
```

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 165 emulator 只读运行测试，不写/改共享数据；Emulator 不可达不算业务 RED/GREEN。
- 每 repo 独立提交；禁 merge/push main/部署；不在 main 改代码；禁 `git add -A`。
- 本 worktree 未提交的 `infrastructure/firebase.json` WIP 修改需确认归属（倾向 revert 回 HEAD）。
