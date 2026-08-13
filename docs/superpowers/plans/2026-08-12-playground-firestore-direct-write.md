# Playground Firestore Direct Write Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将广场列表、发帖和帖子详情的写操作切换为受 Rules 保护的 Firestore 直写，保留但停用 callable adapters。

**Architecture:** Repository Interface 不变；新增当前端口对应的 `FirestoreDirectPlayground*Repository`。客户端从既有 identity map 解析当前 actor，以确定性文档 ID、事务和 batch 实现重试收敛；生产 Rules 是唯一规则事实源。

**Tech Stack:** Flutter/Dart、Cloud Firestore、Firebase Auth、Firestore Security Rules；TypeScript 仅用于 `@firebase/rules-unit-testing` 安全规则测试，不新增 Functions 业务逻辑。

---

## 执行边界

- Storage worktree：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs`
- Shell worktree：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs`
- Shell 当前有其他未提交 ViewModel 改动；禁止清理、stash、覆盖或提交这些文件。
- 不修改 Repository Interface、通知、私信、个人主页、Functions 源码或 REST 设计。
- 不删除 callable adapters；只从 Shell 当前装配中替换五个写端口。

## Task 1：直写公共身份与幂等原语

**Files:**
- Create: `firebase/lib/playground/firestore_direct_playground_command_support.dart`
- Create: `firebase/test/playground/firestore_direct_playground_command_support_test.dart`
- Modify: `firebase/test/playground/firebase_playground_idempotency_test.dart`

- [ ] **1.1 运行 GitNexus impact**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs
node .gitnexus/run.cjs impact FirebasePlaygroundIdentityResolver upstream
```

Expected: 记录影响范围；若 runner 不存在，记录阻断但不得伪造结果。

- [ ] **1.2 写 RED 测试**

覆盖以下精确合同：

```dart
expect(actor.providerUid, 'alice');
expect(actor.appUserId.value, 'app-alice');
expect(commandDocumentId('createPost', 'alice', 'key-1'), hasLength(64));
expect(commandDocumentId('createPost', 'alice', 'key-1'),
    commandDocumentId('createPost', 'alice', 'key-1'));
expect(canonicalPayloadHash({'b': 2, 'a': 1}),
    canonicalPayloadHash({'a': 1, 'b': 2}));
```

另测：未登录、identity map 缺失、空 idempotency key 均返回既有 `PlaygroundError`；旧 idempotency 测试改为“同 key 同 payload 同文档、同 key 不同 payload conflict、发帖/回复缺 key失败”。

- [ ] **1.3 运行 RED**

```bash
cd firebase
flutter test test/playground/firestore_direct_playground_command_support_test.dart test/playground/firebase_playground_idempotency_test.dart
```

Expected: FAIL，support API 和真实 direct adapter 尚不存在；不能红在依赖解析错误。

- [ ] **1.4 最小实现并运行 GREEN**

实现固定 API：

```dart
final class FirestoreDirectActor {
  final String providerUid;
  final PlaygroundUserId appUserId;
}

Future<FirestoreDirectActor> requireDirectActor(
  FirebaseAuth auth,
  FirebaseFirestore firestore,
);

String commandDocumentId(String operation, String uid, String key);
String canonicalPayloadHash(Map<String, Object?> payload);
```

`commandDocumentId` 使用 `sha256('v1|$operation|$uid|$key')`；canonical hash 递归排序 map keys，排除时间与 `idempotency_key`。`requireDirectActor` 只读 `identity_map/{uid}`，不得 fallback callable。

```bash
flutter test test/playground/firestore_direct_playground_command_support_test.dart
git add lib/playground/firestore_direct_playground_command_support.dart test/playground/firestore_direct_playground_command_support_test.dart
git commit -m "feat: add direct Firestore command support"
```

## Task 2：帖子直写

**Files:**
- Create: `firebase/lib/playground/firestore_direct_playground_post_command_repository.dart`
- Create: `firebase/test/playground/firestore_direct_playground_post_command_repository_test.dart`
- Modify: `firebase/test/playground/firebase_playground_reply_post_payload_contract_test.dart`

- [ ] **2.1 写 RED 测试**

创建测试断言 Design §6 的全部 post 字段；稳定别名为 `user_{appUserId}`，一次匿名为 `post_{postId}`。重复命令返回相同 ID，不同 payload conflict。`privacyContext != null` 或 `privacyConfirmations.isNotEmpty` 时 fail closed。编辑只改 allowlist 字段；删除只执行 `active -> tombstoned`；创建后 profiles/outbox 保持为空。

```dart
expect(data.keys.toSet(), equals(expectedPostCreateKeys));
expect(data['author_provider_uid'], 'alice');
expect(data['author_app_user_id'], 'app-alice');
expect(data['presentation_identity_id'], 'post_${post.publicPostId.value}');
```

- [ ] **2.2 运行 RED**

```bash
cd firebase
flutter test test/playground/firestore_direct_playground_post_command_repository_test.dart test/playground/firebase_playground_reply_post_payload_contract_test.dart
```

Expected: FAIL，direct post class 不存在或 direct payload 合同缺失。

- [ ] **2.3 实现并运行 GREEN**

类签名固定为：

```dart
final class FirestoreDirectPlaygroundPostCommandRepository
    implements PlaygroundPostCommandRepository {
  FirestoreDirectPlaygroundPostCommandRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  });
}
```

create 使用 `runTransaction`：读取确定性 doc；同 actor/key/hash 返回原文档；冲突抛 `PlaygroundErrorCode.conflict`；不存在时写字段矩阵。edit/tombstone 事务检查 owner/status。不得 import `cloud_functions`。

```bash
flutter test test/playground/firestore_direct_playground_post_command_repository_test.dart test/playground/firebase_playground_reply_post_payload_contract_test.dart
git add lib/playground/firestore_direct_playground_post_command_repository.dart test/playground/firestore_direct_playground_post_command_repository_test.dart test/playground/firebase_playground_reply_post_payload_contract_test.dart
git commit -m "feat: add direct Firestore post commands"
```

## Task 3：回复直写

**Files:**
- Create: `firebase/lib/playground/firestore_direct_playground_reply_command_repository.dart`
- Create: `firebase/test/playground/firestore_direct_playground_reply_command_repository_test.dart`
- Modify: `firebase/test/playground/firebase_playground_reply_post_payload_contract_test.dart`

- [ ] **3.1 写 RED 测试**

根回复必须写 `depth=0/root_reply_id=null/reply_to_reply_id=null`；讨论回复必须写 `depth=1` 和传入 root/reply-to；两者写完整作者及 presentation 字段。重复 key 合并、不同 payload conflict、缺 key失败。编辑/墓碑不得改 post、作者、depth 或 root linkage。

- [ ] **3.2 运行 RED**

```bash
cd firebase
flutter test test/playground/firestore_direct_playground_reply_command_repository_test.dart test/playground/firebase_playground_reply_post_payload_contract_test.dart
```

Expected: FAIL，direct reply class 不存在。

- [ ] **3.3 实现并运行 GREEN**

```dart
final class FirestoreDirectPlaygroundReplyCommandRepository
    implements PlaygroundReplyCommandRepository {
  FirestoreDirectPlaygroundReplyCommandRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  });
}
```

create 使用 Task 1 的确定性 ID/事务；presentation identity 为 `user_{appUserId}` 或 `reply_{replyId}`；edit/tombstone 事务校验 owner。不得 import `cloud_functions`。

```bash
flutter test test/playground/firestore_direct_playground_reply_command_repository_test.dart test/playground/firebase_playground_reply_post_payload_contract_test.dart test/playground/firebase_playground_idempotency_test.dart
git add lib/playground/firestore_direct_playground_reply_command_repository.dart test/playground/firestore_direct_playground_reply_command_repository_test.dart test/playground/firebase_playground_reply_post_payload_contract_test.dart test/playground/firebase_playground_idempotency_test.dart
git commit -m "feat: add direct Firestore reply commands"
```

## Task 4：点赞、收藏、应验与最终反馈

**Files:**
- Create: `firebase/lib/playground/firestore_direct_playground_engagement_repository.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_verification_repository.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_outcome_feedback_repository.dart`
- Create: `firebase/test/playground/firestore_direct_playground_engagement_repository_test.dart`
- Create: `firebase/test/playground/firestore_direct_playground_verification_repository_test.dart`
- Create: `firebase/test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart`

- [ ] **4.1 写 RED 测试**

断言确定性 ID 与字段矩阵。应验必须用单一 batch 同时写 `verify_{postId}_{rootReplyId}` 和 root reply 的 `verification`；撤回同时写 `revoked_at` 并清空 reply 标记。反馈 batch 同时写 `feedback_{postId}` 和 post 的 `has_outcome_feedback`。所有实现零 outbox、零 notification、零 callable。

```dart
expect(verificationSnap.exists, isTrue);
expect(rootReplySnap['verification'], isNotNull);
expect(outboxSnap.docs, isEmpty);
expect(postSnap['has_outcome_feedback'], isTrue);
```

- [ ] **4.2 运行 RED**

```bash
cd firebase
flutter test test/playground/firestore_direct_playground_engagement_repository_test.dart test/playground/firestore_direct_playground_verification_repository_test.dart test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart
```

Expected: FAIL，三个 direct classes 不存在。

- [ ] **4.3 实现并运行 GREEN**

engagement 复用现有 read 方法但写入确定性 like/bookmark docs；verification/outcome 先读取 post/root 验证业务前置条件，再提交 batch。所有 actor 字段来自 Task 1 support。

```bash
flutter test test/playground/firestore_direct_playground_engagement_repository_test.dart test/playground/firestore_direct_playground_verification_repository_test.dart test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart
git add lib/playground/firestore_direct_playground_engagement_repository.dart lib/playground/firestore_direct_playground_verification_repository.dart lib/playground/firestore_direct_playground_outcome_feedback_repository.dart test/playground/firestore_direct_playground_engagement_repository_test.dart test/playground/firestore_direct_playground_verification_repository_test.dart test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart
git commit -m "feat: add direct Firestore interactions"
```

## Task 5：生产 Firestore Rules

**Files:**
- Modify: `firebase/infrastructure/functions/test/firestore.rules.test.ts`
- Modify: `firebase/infrastructure/firestore.rules`

- [ ] **5.1 写 Rules RED 测试（TS 仅用于 Rules）**

每项必须有 allow/deny 对照：post create/edit/tombstone；root/discussion reply；第三层和跨帖拒绝；like/bookmark 本人成功及冒充拒绝；Poster 应验成功、非 Poster失败、自验失败；重复应验仍只有一个确定性文档；Poster feedback 成功、非 Poster失败；reply verification-only 成功且混入 body 修改失败；identity/outbox/profile/notification/conversation/message 仍拒绝写。

```typescript
await assertSucceeds(alice.collection('playground_posts').doc(postId).set(validPost));
await assertFails(bob.collection('playground_posts').doc(postId).update({text: 'forged'}));
await assertSucceeds(alice.collection('playground_replies').doc(rootId).update({
  verification: validVerificationMarker,
  updated_at: new Date(),
}));
```

- [ ] **5.2 运行 RED**

```bash
cd firebase/infrastructure/functions
npm test -- --runInBand firestore.rules.test.ts
```

Expected: 新增合法直写用例 FAIL；不能把 Emulator 连接失败当 RED。

- [ ] **5.3 实现 Rules 并运行 GREEN**

按 Design §7 编写 helper 与 match。字段必须使用完整 `hasOnly`；不可变字段用 `diff().affectedKeys()`；reply root/reply-to、Poster 权限和 identity map 用 `get/exists`；reply verification-only 必须用 `getAfter` 证明同 batch 的确定性 verification 文档一致；post 的 `has_outcome_feedback` 变更必须用 `getAfter` 证明同 batch feedback 文档一致；客户端永远不能写 outbox。

```bash
npm test -- --runInBand firestore.rules.test.ts
git add ../firestore.rules test/firestore.rules.test.ts
git commit -m "feat: guard direct Firestore playground writes"
```

## Task 6：Rules 单一来源与 fail-closed Emulator gate

**Files:**
- Modify: `firebase/infrastructure/emulator/firebase.json`
- Delete: `firebase/infrastructure/emulator/firestore.rules`
- Create: `firebase/scripts/run_playground_emulator_gate.sh`
- Create: `firebase/test/playground/firestore_rules_source_contract_test.dart`
- Modify: `firebase/test/playground/firebase_playground_emulator_integration_test.dart`

- [ ] **6.1 写 RED 合同测试**

断言 emulator config 的 rules 精确等于 `../firestore.rules`，第二份 rules 文件不存在；集成测试缺 host、连接失败或平台不支持时必须 fail，不得 `markTestSkipped` 或 early return。

- [ ] **6.2 运行 RED**

```bash
cd firebase
flutter test test/playground/firestore_rules_source_contract_test.dart
```

Expected: FAIL，当前 emulator config 仍加载漂移文件。

- [ ] **6.3 实现 gate**

脚本固定行为：检查 `192.168.0.165:8080` 和 `:9099`；不可达 exit 1；执行 integration test；输出含 skip 标记或非零退出均 exit 1。不得修改远端环境或部署 Rules。

```bash
flutter test test/playground/firestore_rules_source_contract_test.dart
bash scripts/run_playground_emulator_gate.sh
```

Expected: source contract PASS；LAN 不可达则 gate 明确 FAIL，不得改用 Fake。

- [ ] **6.4 提交**

```bash
git add infrastructure/emulator/firebase.json infrastructure/emulator/firestore.rules scripts/run_playground_emulator_gate.sh test/playground/firestore_rules_source_contract_test.dart test/playground/firebase_playground_emulator_integration_test.dart
git commit -m "test: fail closed on playground emulator drift"
```

## Task 7：导出与 Shell 装配

**Files:**
- Modify: `firebase/lib/playground/playground.dart`
- Modify: `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs/lib/playground/shell_playground_bootstrap.dart`
- Create: `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs/test/playground/shell_playground_bootstrap_test.dart`

- [ ] **7.1 写 Shell RED 测试**

验证 post/reply/engagement/verification/outcome 五个端口为 direct 类型；profile/notification/conversation 仍是原类型；旧 `RemoteDataSource` 直写类型和 callable 类型均未被这五个端口装配。另 grep production composition root 的五个端口不得引用 callable 类型。

- [ ] **7.2 运行 RED**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground/shell_playground_bootstrap_test.dart
```

Expected: FAIL，当前装配 callable adapters。

- [ ] **7.3 导出并切换**

Storage barrel 新增五个 direct exports，原 exports 保留。Shell 仅改 import show-list 和五个 constructor；不得触碰当前未提交 ViewModel 文件。

- [ ] **7.4 分仓提交**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs
git add firebase/lib/playground/playground.dart
git commit -m "feat: export direct Firestore adapters"

cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground/shell_playground_bootstrap_test.dart
git add lib/playground/shell_playground_bootstrap.dart test/playground/shell_playground_bootstrap_test.dart
git commit -m "feat: wire direct Firestore playground writes"
```

## Task 8：完整验收

- [ ] **8.1 Storage 回归**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs/firebase
flutter test test/playground
dart analyze lib/playground test/playground
cd ..
npm --prefix firebase/infrastructure/functions test -- --runInBand firestore.rules.test.ts
git diff --check
node .gitnexus/run.cjs detect_changes
```

Expected: tests/analyze/diff PASS；GitNexus 缺失须如实记录。

- [ ] **8.2 Shell 回归**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart
dart analyze lib/playground lib/modules/playground_module_entry.dart
git diff --check
```

Expected: PASS；不得提交或修改原有六个 dirty ViewModel/test 文件。

- [ ] **8.3 真实主链路**

Alice 发帖；列表和详情可读；Bob 根回复和二级回复；Alice 点赞、收藏、应验和反馈；Bob 的越权编辑/应验/反馈全部失败。必须使用生产 Rules，零 skip，零 allow-all。

## 完成标准

- 当前三个页面写路径零 `httpsCallable`；Functions 代码仍保留。
- 同 key/同 payload 不重复，同 key/不同 payload conflict。
- direct payload 与读取模型、匿名展示字段完全一致。
- 应验和反馈 batch 不产生半写；客户端不能写 outbox。
- Rules allow/deny 成对通过，Emulator gate fail closed。
- 通知、私信、个人主页和 Repository Interface 无变化。
