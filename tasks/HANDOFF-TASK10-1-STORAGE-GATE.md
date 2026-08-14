# Handoff — Task 10.1 Storage 门禁（rules 56/56 ✅；Dart 全量 3 pre-existing callable RED 记录；analyze 已清 warning）

> Status: **Task 10.1 主体完成：rules 门禁 56/56 GREEN（`35218ca`）；Dart 全量 +247 ~1 -3
> （3 个 pre-existing 旧 callable 路径失败）；analyze 无 warning（`3ef6390` 修 1 个 unused var）。**
> 交接时刻: 2026-08-14
> 下一入口: `tasks/HANDOFF-TASK10-INPROGRESS.md`（Task 10 总览）

## 10.1 结果

### 命令
```bash
cd xuan-storage/.worktrees/playground-firebase-repairs/firebase
flutter test test/playground          # +247 ~1 -3（见下）
dart analyze lib/playground test/playground  # 无 warning（仅 deprecated info 于旧 callable 路径）
cd infrastructure/functions
npm test -- --runInBand firestore.rules.test.ts direct_write_schema_fixture.test.ts  # 56/56 ✅
```

### 3 个 pre-existing RED（均为废弃 callable 路径，非 direct-write 回归，范围外）
1. `callable_command_adapter_test.dart`：`resolveActor → httpsCallable("resolveMyIdentity")` —
   Task 1 已把 identity resolver 改为直读 Firestore，不再走 callable；该测试断言旧行为，stale。
2-3. `playground_contract_suite_test.dart` C4 点赞态/点赞数不缓存：
   `[core/no-app] No Firebase App '[DEFAULT]' has been created` — "firebase" 拓扑构造
   `FirebasePlaygroundLikeRepository`（callable）需 `Firebase.initializeApp()`，测试未调用。

以上属于「callable 保留但不装配，消费方归零后另行删除」范畴；Design §12 明确 callable 不装配。
**不修**（涉及废弃仓库，超 Task 10 直写范围）。

### analyze
- 修 1 个 warning：`firestore_direct_playground_verification_repository_test.dart` unused `v1`（`3ef6390`）。
- 其余 13 个均为 **info**（deprecated_member_use 于旧 callable/legacy repo、unnecessary_library_name），pre-existing。

## 剩余 Task 10

- **10.2 Shell 与依赖门禁**：两仓 `resolved-ref` 相同；production composition 零 `httpsCallable`；
  Feed 不显示假 0；详情真实计数；所有测试零 skip；两仓 `git diff --check`。
  ⚠ 已知 pre-existing：shell `playground_navigation_contract_test.dart` "owner sees delete/feedback
  but not verification" RED（owner verification 图标可见性，Design §12.2 语义待排查/产品确认）。
- **10.3 真实主链路**：165 emulator production Rules：Alice 发帖 → Bob 根/二级回复 → Alice
  点赞/收藏/应验/反馈 → Bob 越权失败 → 匿名 alias 同帖稳定跨帖不同 → 墓碑不泄漏 →
  Functions/outbox/notification 未调用。身份预置需 `withSecurityRulesDisabled`/seed（production
  Rules identity_map write:false）。

## 提交（storage `fix/playground-firebase-repairs`）
- `3ef6390` unused var 清理；`35218ca` replies read + verification own-reply fix（rules 56/56）；
- 之前：Task 9 `7db4ce6`/`8d014f2`/`17a908e`；Task 8 `406b31a`；Task 7 `dbcb3c4`/`138b228`。

## 关键约束（维持）
- 禁 `git add -A`（shell 用户 dirty）。不 push/merge main/部署。165 只读。
