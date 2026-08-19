# Handoff — Task 10 进行中（rules gate 完成 `35218ca`；10.1 Dart/10.2 Shell/10.3 主链路 REMAIN）

> Status: **IN PROGRESS — Task 10.1 rules 部分完成（56/56 GREEN，`35218ca`）。**
> 交接时刻: 2026-08-14
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md` Task 10

## 一句话状态

**Task 10 rules 门禁已通：`firestore.rules.test.ts`（45）+ `direct_write_schema_fixture.test.ts`
（11）= 56/56 GREEN，提交 `35218ca`。期间修复两个真实 rules bug（replies 缺 read 规则、
verification 自己的回复检查恒真）。剩余：10.1 Storage Dart 门禁、10.2 Shell/依赖门禁、
10.3 真实主链路。**

## 本轮完成（`35218ca`）

1. **rules：`playground_replies` 补 `allow read`**（此前缺失 → 回复不可读，4 个旧测试红）。
   规则 = active（is_tombstoned != true）任何认证用户可读；tombstone 仅作者（ownerAfter 校验），
   镜像 posts read 规则。
2. **rules：修 verification create "非 Poster 自己回复" 恒真 bug**
   `!get(...).data != null`（恒 true + WARNING）→
   `get(...).data == null || provider_uid != auth.uid`。消除 L518 WARNING，
   并新增 fixture deny 测试「Poster 应验自己的 root 回复」（11/11 GREEN）。
3. **firestore.rules.test.ts**：tombstone 读写测试补 seed `playground_reply_owners`
   （生产 owner 原子创建，读 tombstone 须 owner 文档存在）。45/45 GREEN。

## 剩余（下一 agent 起点）

### Task 10.1 Storage 门禁（rules 已通，剩 Dart）
```bash
cd xuan-storage/.worktrees/playground-firebase-repairs/firebase
flutter test test/playground
dart analyze lib/playground test/playground
cd infrastructure/functions
npm test -- --runInBand firestore.rules.test.ts direct_write_schema_fixture.test.ts   # 已 56/56
```
注意：`flutter test test/playground` 全量可能含预置/平台相关 skip，逐条核对。

### Task 10.2 Shell 与依赖门禁
- 两仓 `resolved-ref` 相同；production composition 零 `httpsCallable`；Feed 不显示假 0；
  详情真实 2/3/1 计数；所有测试零 skip；两仓 `git diff --check`。
- **已知 pre-existing RED**：shell `playground_navigation_contract_test.dart`
  "signed-in owner sees delete/feedback but not verification"（无 Task9 改动也失败；
  owner verification 图标可见性与 Design §12.2 语义冲突，需排查/产品确认）。

### Task 10.3 真实主链路（165 emulator，production Rules）
Alice 发帖 → Bob 根/二级回复 → Alice 点赞/收藏/应验/反馈 → Bob 越权编辑/应验/反馈失败 →
匿名 alias 同帖稳定跨帖不同 → 墓碑 raw Firestore get 不泄漏正文 →
Functions/outbox/notification 均未调用或写入。
（身份预置：production Rules `identity_map write:false`，客户端无法 seed；需经
`withSecurityRulesDisabled`/seed 机制预置 identity，或复用 `firestore.rules.test.ts`
的 seed 模式。）

## 关键约束（维持）

- 禁 `git add -A`（shell 有用户 dirty）。不 push / 不 merge main / 不部署。
- 165 emulator 只读运行测试。direct adapter 禁 import `cloud_functions`。
- 遗留：rules 无其他已知 WARNING（本轮已消 L518）；`playground_navigation_contract_test`
  的 pre-existing RED 单独记录。

## 提交记录（storage `fix/playground-firebase-repairs`）
- `35218ca` Task 10 rules 门禁（replies read + verification own-reply fix + 测试）
- `7db4ce6`/`8d014f2`/`17a908e` Task 9（storage 导出 + shell 装配 + handoff）
- `406b31a` Task 8（单一源 + gate）；`138b228`/`dbcb3c4` Task 7（匿名 ID 内容派生）
