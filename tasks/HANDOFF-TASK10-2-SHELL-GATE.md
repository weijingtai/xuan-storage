# Handoff — Task 10.2 Shell 门禁（主体通过）；10.3 主链路 REMAIN

> Status: **Task 10.2 主体通过；1 pre-existing nav RED 需语义决策；10.3 未开始。**
> 交接时刻: 2026-08-14
> 总览: `tasks/HANDOFF-TASK10-INPROGRESS.md`

## 10.2 Shell/依赖门禁结果

| 检查 | 结果 |
|---|---|
| 两仓 RI `ref:` | ✅ 均 `0841e19d78df93fded5764bfdf86633a05333a0c`（storage pubspec + shell override） |
| Shell lib 零 httpsCallable/cloud_functions | ✅（Task 9 direct 装配后 grep 0） |
| `flutter test --no-pub test/playground` | ✅ +103 ~1 全绿（~1 = emulator 集成测试平台通道 skip，惯例） |
| `dart analyze lib/playground lib/modules/playground_module_entry.dart` | ✅ no issues |
| `test/modules/playground_navigation_contract_test.dart` | ⚠ 1 RED（pre-existing，见下） |
| Feed 不显示假 0 / 详情真实计数 | ✅（`feed_count_visibility_test` 等已含在 test/playground 全绿） |

## ⚠ nav RED —— 需语义决策（非机械修复）

`playground_navigation_contract_test.dart` "signed-in owner sees delete/feedback but not verification"：
- **测试** `_RecordingRepositories(owner: true)` → `viewerState: PlaygroundPostViewerState(canVerify: false)`（owner 只置 owner:true，canVerify 走默认 false）→ 断言 owner **不显示** verified 图标。
- **页面** `post_detail_page.dart` L108 按 `detail.viewerState.canVerify` 渲染 verified 图标。
- **Design §12.2**：页面级 `canVerify` 只表示 viewer 是 owner；所有未墓碑 root 可显示应验动作（owner 可以应验**他人**的 root 回复，只是不能应验自己的）。→ 按此语义 **owner 应显示** verify 图标，测试断言方向可能反了。
- **无 Task 9 改动也失败**（已验证），属 pre-existing。
- **建议**：交产品/主代理确认 Design 语义后，二选一：
  a. 测试 fixture owner 时置 `canVerify: true`（owner 显示 verify），断言改为 findsOneWidget；
  b. 若产品要求 owner 隐藏 verify 图标，则页面逻辑改「非 owner 才显示」，并更新 Design §12.2 措辞。
  本 agent 不擅自改（涉及 Design 语义 + 页面 + 测试三处一致性）。

## 剩余：Task 10.3 真实主链路（未开始）

165 emulator production Rules 全链路：
Alice 发帖 → Bob 根/二级回复 → Alice 点赞/收藏/应验/反馈 → Bob 越权编辑/应验/反馈失败 →
匿名 alias 同帖稳定跨帖不同 → 墓碑 raw Firestore get 不泄漏正文 → Functions/outbox/notification
均未调用或写入。

**关键障碍**：production Rules `identity_map write:false`，客户端（Dart direct adapter）无法 seed
identity。方案：用 `@firebase/rules-unit-testing` 的 `withSecurityRulesDisabled`（TS）在
`playground-test` namespace 预置 identity_map，再跑真实 adapter；或复用
`firestore.rules.test.ts` 已建的 seed 模式扩展一个主链路集成测试（TS）。
若走 Dart 集成测试则受平台通道限制（VM skip），建议用 TS rules-testing 写主链路。

## 提交（storage `fix/playground-firebase-repairs`）
- Task 10.1: `35218ca`（rules 56/56）、`3ef6390`（analyze）、`bff421d`（handoff）
- 之前: Task 9 `7db4ce6`/`8d014f2`/`17a908e`；Task 8 `406b31a`；Task 7 `dbcb3c4`/`138b228`。

## 关键约束（维持）
- 禁 `git add -A`（shell 用户 dirty）。不 push/merge main/部署。165 只读。
