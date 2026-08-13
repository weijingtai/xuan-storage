# Playground Firestore Direct Write Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将广场列表、发帖和帖子详情使用的写操作切换为 Firestore 客户端直写，同时保留但停用现有 Functions 写入 adapter。

**Architecture:** Repository Interface 不变。新增 `FirestoreDirect*Repository`，Shell composition root 只为当前三个页面注入这些实现；Functions adapter 原文件不改。Rules 用认证、所有权、字段白名单和跨文档关系保护直写。

**Tech Stack:** Flutter/Dart、Cloud Firestore、Firebase Auth、Firestore Security Rules、Firebase Emulator。

---

## 文件结构

- 新建五个 `firebase/lib/playground/firestore_direct_playground_*_repository.dart`，分别负责帖子、回复、互动、应验和最终反馈。
- 修改 `firebase/lib/playground/playground.dart` 导出直写实现，保留 Functions 实现。
- 修改 `firebase/infrastructure/firestore.rules` 开放受约束写路径。
- 修改 `xuan-shell/lib/playground/shell_playground_bootstrap.dart` 切换当前三个页面的依赖。

### Task 1：帖子与回复直写 adapter

**Files:**
- Create: `firebase/test/playground/firestore_direct_playground_post_command_repository_test.dart`
- Create: `firebase/test/playground/firestore_direct_playground_reply_command_repository_test.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_post_command_repository.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_reply_command_repository.dart`

- [ ] **Step 1: 写 RED 测试**

验证创建 payload 使用当前 `auth.uid`；帖子写 canonical `text/status/presentation_mode/attachments/timestamps`；根回复 `depth=0`；讨论回复 `depth=1/root_reply_id/reply_to_reply_id`；编辑只改可变字段；删除只写 tombstone。

```dart
expect(saved['author_provider_uid'], 'alice');
expect(saved['status'], 'active');
expect(saved['presentation_mode'], command.presentationMode.name);
```

- [ ] **Step 2: 运行 RED**

```bash
cd firebase
flutter test test/playground/firestore_direct_playground_post_command_repository_test.dart test/playground/firestore_direct_playground_reply_command_repository_test.dart
```

Expected: FAIL，两个直写类尚不存在。

- [ ] **Step 3: 最小实现**

构造函数只接收 `FirebaseFirestore`、`FirebaseAuth`。未登录映射为既有 unauthenticated 错误；异常统一走 `FirebasePlaygroundErrorMapper.map`；时间使用 `FieldValue.serverTimestamp()`；不得引用 `FirebaseFunctions`。

- [ ] **Step 4: 运行 GREEN 并提交**

```bash
flutter test test/playground/firestore_direct_playground_post_command_repository_test.dart test/playground/firestore_direct_playground_reply_command_repository_test.dart
git add firebase/lib/playground/firestore_direct_playground_post_command_repository.dart firebase/lib/playground/firestore_direct_playground_reply_command_repository.dart firebase/test/playground/firestore_direct_playground_post_command_repository_test.dart firebase/test/playground/firestore_direct_playground_reply_command_repository_test.dart
git commit -m "feat: add direct Firestore post and reply writes"
```

### Task 2：互动、应验和最终反馈直写 adapter

**Files:**
- Create: `firebase/test/playground/firestore_direct_playground_engagement_repository_test.dart`
- Create: `firebase/test/playground/firestore_direct_playground_verification_repository_test.dart`
- Create: `firebase/test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_engagement_repository.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_verification_repository.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_outcome_feedback_repository.dart`

- [ ] **Step 1: 写 RED 测试**

确定性文档 ID：like=`{uid}__{targetType}__{targetId}`、bookmark=`{uid}__{postId}`、verification=`{postId}__{rootReplyId}`、feedback=`{postId}`。验证 set/delete、应验撤回和反馈撤回；actor 字段只能来自当前 `auth.uid`。

- [ ] **Step 2: 运行 RED**

```bash
cd firebase
flutter test test/playground/firestore_direct_playground_engagement_repository_test.dart test/playground/firestore_direct_playground_verification_repository_test.dart test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart
```

Expected: FAIL，三个直写类尚不存在。

- [ ] **Step 3: 最小实现**

使用确定性 ID 和 `set/delete/update`；应验撤回写 `revoked_at`，最终反馈撤回写 `deleted_at`。不写客户端可信计数、不生成通知、不调用 Functions。

- [ ] **Step 4: 运行 GREEN 并提交**

```bash
flutter test test/playground/firestore_direct_playground_engagement_repository_test.dart test/playground/firestore_direct_playground_verification_repository_test.dart test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart
git add firebase/lib/playground/firestore_direct_playground_engagement_repository.dart firebase/lib/playground/firestore_direct_playground_verification_repository.dart firebase/lib/playground/firestore_direct_playground_outcome_feedback_repository.dart firebase/test/playground/firestore_direct_playground_engagement_repository_test.dart firebase/test/playground/firestore_direct_playground_verification_repository_test.dart firebase/test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart
git commit -m "feat: add direct Firestore playground interactions"
```

### Task 3：Firestore Rules

**Files:**
- Modify: `firebase/infrastructure/functions/test/firestore.rules.test.ts`
- Modify: `firebase/infrastructure/firestore.rules`

- [ ] **Step 1: 写直写安全合同并运行 RED**

成对覆盖：本人合法创建成功；未登录失败；冒充作者失败；额外计数字段失败；非作者编辑/删除失败；第三层回复失败；跨帖 root/reply-to 失败；非 Poster 应验/反馈失败；用户只能写自己的 like/bookmark。

```bash
cd firebase/infrastructure/functions
npm test -- --runInBand firestore.rules.test.ts
```

Expected: 合法直写用例 FAIL，因为当前 Rules 为 `allow write: if false`。

- [ ] **Step 2: 最小 Rules 实现**

- create 校验 `request.auth.uid` 等于 actor 字段；update 校验资源 owner 且不可变字段未变化。
- 使用 `keys().hasOnly(...)` 和 `diff().affectedKeys().hasOnly(...)`。
- reply 仅允许 depth 0/1，并用 `get/exists` 验证同帖 root/reply-to。
- verification/outcome 用 `get(post)` 验证当前用户是帖子作者。
- 继续禁止 `identity_map/outbox/notifications/conversations/messages/profiles` 客户端写入。

- [ ] **Step 3: 运行 GREEN 并提交**

```bash
npm test -- --runInBand firestore.rules.test.ts
git add ../firestore.rules test/firestore.rules.test.ts
git commit -m "feat: allow guarded direct playground writes"
```

### Task 4：导出并切换 Shell 装配

**Files:**
- Modify: `firebase/lib/playground/playground.dart`
- Modify: `xuan-shell/lib/playground/shell_playground_bootstrap.dart`
- Create/Modify: `xuan-shell/test/playground/shell_playground_bootstrap_test.dart`

- [ ] **Step 1: 写 RED 装配测试**

验证 post/reply/engagement/verification/outcome 均为 `FirestoreDirect*`；通知、私信、个人主页保持原实现。

- [ ] **Step 2: 运行 RED**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground/shell_playground_bootstrap_test.dart
```

Expected: FAIL，当前仍装配 Functions adapter。

- [ ] **Step 3: 导出并切换五个依赖**

只修改 composition root；不得修改 ViewModel、UseCase、Repository Interface 或删除 Functions adapter。

- [ ] **Step 4: 运行 GREEN 并分别提交两个仓库**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs
git add firebase/lib/playground/playground.dart
git commit -m "feat: export direct Firestore playground adapters"

cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground/shell_playground_bootstrap_test.dart
git add lib/playground/shell_playground_bootstrap.dart test/playground/shell_playground_bootstrap_test.dart
git commit -m "feat: wire playground direct Firestore writes"
```

### Task 5：真实 Emulator 验收

**Files:**
- Modify: `firebase/test/playground/firebase_playground_emulator_integration_test.dart`

- [ ] **Step 1: 写端到端 RED 场景**

Alice 发帖；列表和详情可读；Bob 根回复和二级回复；Alice 点赞、收藏、应验和反馈；Bob 冒充编辑、应验和反馈全部失败。

- [ ] **Step 2: 运行真实 Emulator**

```bash
cd firebase
FIRESTORE_EMULATOR_HOST=192.168.0.165:8080 FIREBASE_AUTH_EMULATOR_HOST=192.168.0.165:9099 flutter test test/playground/firebase_playground_emulator_integration_test.dart
```

Expected: PASS 且零 skip。局域网 Emulator 不可达时报告环境阻断，不得用 Fake 冒充。

- [ ] **Step 3: 回归并提交**

```bash
flutter test test/playground
dart analyze lib/playground test/playground
git diff --check
git add test/playground/firebase_playground_emulator_integration_test.dart
git commit -m "test: verify direct Firestore playground flow"
```

## 完成标准

- 三个页面现用写操作零 `httpsCallable`。
- Functions adapter 和源码保留但不被 Shell 注入。
- 通知、私信、个人主页无代码变化。
- 真实 Rules/Emulator 主链路通过，越权被拒绝，测试无 skip、Fake 冒充或 allow-all。
