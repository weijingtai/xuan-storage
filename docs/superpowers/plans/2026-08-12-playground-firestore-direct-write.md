# Playground Firestore Direct Write Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 Flutter 广场列表、发帖、帖子详情接通受 production Rules 保护的 Firestore 直写，同时保留但不装配 callable adapters。

**Architecture:** UI 只调用 ViewModel/UseCase/provider-neutral Repository Interface。公开 post/reply 与私有 owner/identity 分离，内容版本使用 append-only revisions；one-time anonymous 匿名 ID 内容派生为 `post_{postId}`；应验、反馈、点赞和收藏各自保留单一关系事实。当前 Phase 不交付 Functions、通知、私信、Profile、待断/可信推荐或声望投影。

**Tech Stack:** Flutter/Dart、Firebase Auth、Cloud Firestore、Firestore Security Rules、Firebase Emulator；TypeScript 只用于 `@firebase/rules-unit-testing`，不新增 Functions 业务逻辑。

---

## 权威输入与禁止事项

- Design：`docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`。
- Storage worktree：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs`。
- RI worktree：`/Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-playground/.worktrees/playground-ri-completion`。
- Shell worktree：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs`。
- Shell 有用户未提交改动：禁止 clean、stash、覆盖或顺手提交无关文件。
- 禁止公开文档出现 provider UID、canonical `appUserId`、真实姓名或可推导稳定 ID。
- 禁止修改/删除 callable Functions；禁止将旧 callable 作为回滚。
- 禁止用 Fake、skip、allow-all 或默认 0 冒充 production contract。
- 每个仓库独立提交；禁止 Agent merge main、push main 或部署。

## TDD 增补协议（保留现有计划，逐 vertical slice 执行）

测试 seam 固定为三层，禁止测试 private helper 代替公共行为：

1. **Provider-neutral seam**：Repository Interface 命令/查询及 `PlaygroundError`；验证 provider
   替换不影响 UseCase。
2. **Firebase security seam**：真实 adapter + Emulator production Rules + raw Firestore get；
   验证授权、原子事实、公开隐私和 query shape。
3. **Product seam**：Shell ViewModel/widget；验证 capability、错误、Feed 不显示假计数和详情真实计数。

每个 Task 内按“一条行为 RED → 最小 GREEN → 下一条行为”执行，禁止先批量写完全部测试或实现。
每个 RED 证据必须记录：命令、exit code、失败的目标断言；依赖解析、Emulator 不可达或编译环境
错误不算业务 RED。每个 GREEN 只运行当前 slice + 已完成 slice 回归。Task 7 的索引删除和 Rules
访问预算必须额外执行变异验证，证明测试会因目标缺陷变红。

## Task 0：RI 远端合并与依赖冻结（P0，未通过不得执行 Task 1）

**Files:**
- Modify: `repository-interface-playground/lib/src/models/playground_viewer_state.dart`
- Modify: `repository-interface-playground/lib/src/contracts/playground_repository_contracts.dart`
- Modify: `xuan-storage/firebase/pubspec.yaml`
- Modify: `xuan-shell/pubspec.yaml`
- Verify: both generated `pubspec.lock`

- [ ] **0.1 写 RI RED 合同测试**

在合同测试中构造四态并断言新增字段：

```dart
const owner = PlaygroundPostViewerState(
  isOwner: true,
  canEdit: true,
  canDelete: true,
  canSetFeedback: true,
  canVerify: true,
);
expect(owner.props, containsAll([true, true, true, true]));
expect(const PlaygroundPostViewerState().isOwner, isFalse);
expect(const PlaygroundPostViewerState().canEdit, isFalse);
expect(const PlaygroundPostViewerState().canDelete, isFalse);
expect(const PlaygroundPostViewerState().canSetFeedback, isFalse);
```

另测 owner、非 owner、未认证、owner 文档缺失全部 fail closed，只有 owner 为 true。

- [ ] **0.2 运行 RED、最小扩展 RI、运行 GREEN**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-playground/.worktrees/playground-ri-completion
dart test
```

RED 必须因四个 getter/constructor 参数不存在；实现后全部 PASS。不得更名或删除现有
`isLiked/isBookmarked/canVerify`。

- [ ] **0.3 提交 RI feature branch，交给人类合并**

```bash
git add lib/src/models/playground_viewer_state.dart lib/src/contracts/playground_repository_contracts.dart
git commit -m "feat: expose playground viewer capabilities"
```

停止并报告 RI commit。只有人类完成 PR 合并后才能继续；Agent 不得 merge main。

- [ ] **0.4 验证远端 main 并冻结依赖**

先运行负对照，证明不能把 `ls-remote` 的退出码当作“分支存在”：

```bash
MISSING_REF_OUTPUT="$(git ls-remote --heads origin refs/heads/__playground_missing_gate__)"
test -z "$MISSING_REF_OUTPUT"
```

Expected：PASS 且输出为空；这就是旧命令会假绿的 RED 证据。随后运行真正 fail-closed gate：

```bash
git fetch origin
RI_VIEWER_COMMIT="$(git rev-parse feat/playground-ri-completion)"
RI_REMOTE_MAIN="$(git ls-remote --heads origin refs/heads/main | awk 'NR == 1 {print $1}')"
test -n "$RI_REMOTE_MAIN"
test "$RI_REMOTE_MAIN" = "$(git rev-parse origin/main)"
git merge-base --is-ancestor 756121b233c494093b2e1130163e93a5cdc57839 origin/main
git merge-base --is-ancestor "$RI_VIEWER_COMMIT" origin/main
RI_MERGED_COMMIT="$(git rev-parse origin/main)"
```

在 RI 尚未合并时，最后一条 ancestor check 必须 RED；人类合并且再次 `git fetch origin` 后才
GREEN。空 `ls-remote`、陈旧 remote-tracking ref、只在 feature branch 三种情况全部失败。
把 `RI_MERGED_COMMIT` 的 40 字符输出逐字记录；随后在
storage/firebase 和 shell 两个 `pubspec.yaml` 的同一 git dependency 下把 `ref:` 写为该
40 字符值，执行各自
`flutter pub get`，再验证：

```bash
rg -n "repository_interface_playground|ref:|resolved-ref:" pubspec.yaml pubspec.lock
```

两仓 `resolved-ref` 必须是同一已合并 commit；path override 不能入库。分别提交依赖冻结。

## Task 1：Identity schema convergence

**Files:**
- Modify: `firebase/lib/account/firestore_app_user_id_resolver.dart`
- Modify: `firebase/infrastructure/functions/src/identity.ts`
- Create: `firebase/test/playground/firestore_direct_identity_contract_test.dart`
- Create: `firebase/infrastructure/functions/test/identity_schema.test.ts`

- [ ] **1.1 写 RED**

fixture 必须产生：

```json
{
  "app_user_id": "app-alice",
  "provider_uid": "alice",
  "provider_id": "firebase",
  "public_presentation_id": "pub_random_128bit",
  "public_display_alias": "玄友0001"
}
```

断言新 reader 优先读 `app_user_id`、临时兼容旧 `appUserId`；缺公开 ID/alias 返回
`PlaygroundErrorCode.unavailable` + `identity/not-ready`；Playground 不创建 identity_map。

- [ ] **1.2 RED/GREEN 与提交**

```bash
cd firebase
flutter test test/playground/firestore_direct_identity_contract_test.dart
cd infrastructure/functions
npm test -- --runInBand identity_schema.test.ts
npm run build
```

不得删除旧字段兼容读；新写只写 snake_case。dev/test backfill 使用幂等测试 fixture，不触碰远端。
GREEN 后只提交上述四个文件。

## Task 2：Schema fixture、错误与直写 support

**Files:**
- Create: `firebase/test/playground/fixtures/direct_write_schema_v1.json`
- Create: `firebase/lib/playground/firestore_direct_playground_command_support.dart`
- Create: `firebase/test/playground/firestore_direct_playground_command_support_test.dart`
- Modify: `firebase/test/playground/firebase_playground_idempotency_test.dart`

- [ ] **2.1 创建 schema RED fixture 测试**

fixture 必须列出 Design §4.4 每个 public/owner/relation/revision 文档的 required/nullable keys、
enum、长度、附件判别联合和机器错误码。测试必须明确断言：

```dart
expect(postKeys.where((key) => key.startsWith('author_')), isEmpty);
expect(schema, contains('playground_post_owners'));
expect(schema, contains('revision_no'));
expect(schema, contains('public_presentation_id'));
```

- [ ] **2.2 实现 support 并 GREEN**

实现 `requireDirectActor`、canonical JSON hash、create command deterministic ID、
`PlaygroundError(code,machineCode)` 映射。actor 同时携带内部 app ID、公开 ID/alias，但 mapper
必须分开提供 private owner payload 与 public presentation payload。

```bash
flutter test test/playground/firestore_direct_playground_command_support_test.dart \
  test/playground/firebase_playground_idempotency_test.dart
dart analyze lib/playground/firestore_direct_playground_command_support.dart
```

RED 不能红在依赖解析；GREEN 后小提交。

## Task 3：帖子、owner 与 append-only revision

**Files:**
- Create: `firebase/lib/playground/firestore_direct_playground_post_command_repository.dart`
- Create: `firebase/test/playground/firestore_direct_playground_post_command_repository_test.dart`
- Modify: `firebase/test/playground/firebase_playground_reply_post_payload_contract_test.dart`

- [ ] **3.1 写 RED**

同一 transaction 创建 `playground_posts/{id}`、`playground_post_owners/{id}`、
`revisions/r0000000001`。公开 post exact keys 来自 fixture，内部 UID 命中数为 0；stable alias
来自 identity_map，one-time post ID 为 `post_{postId}`。edit 追加连续 revision；tombstone 先保存
最后 revision，再清空 text/attachments/techniques。

- [ ] **3.2 实现、GREEN、提交**

```bash
flutter test test/playground/firestore_direct_playground_post_command_repository_test.dart \
  test/playground/firebase_playground_reply_post_payload_contract_test.dart
```

另测同 key/同 payload replay、同 key/不同 payload conflict、隐私字段 fail closed。不得 import
`cloud_functions`。GREEN 后提交 repository 与测试。

## Task 4：两层回复、owner 与 revision

**Files:**
- Create: `firebase/lib/playground/firestore_direct_playground_reply_command_repository.dart`
- Create: `firebase/test/playground/firestore_direct_playground_reply_command_repository_test.dart`

- [ ] **4.1 写 RED**

覆盖 root/discussion、跨帖、跨 root、负 depth、第三层和墓碑目标。stable alias 来自 identity；
one-time anonymous 匿名 ID 内容派生为 `post_{postId}`（同帖稳定、跨帖不同，无私有状态）。
公开 reply/owner/revision 同批写入，公开字段零内部 UID。

- [ ] **4.2 实现、GREEN、提交**

```bash
flutter test test/playground/firestore_direct_playground_reply_command_repository_test.dart \
  test/playground/firebase_playground_idempotency_test.dart
```

edit 追加 revision；tombstone 清空 body/chart/media/techniques。GREEN 后小提交。

## Task 5：点赞、收藏、应验、反馈和举报

**Files:**
- Create: `firebase/lib/playground/firestore_direct_playground_engagement_repository.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_verification_repository.dart`
- Create: `firebase/lib/playground/firestore_direct_playground_outcome_feedback_repository.dart`
- Create: corresponding three `firebase/test/playground/firestore_direct_*_test.dart`
- Modify: `firebase/test/playground/firebase_playground_report_repository_test.dart`

- [ ] **5.1 写 RED**

like public fact + private `like_owner` 同批；bookmark 继续使用既有
`user_provider_uid/user_app_user_id` 命名。verification 只写独立
`verify_{postId}_{rootReplyId}`，不改 reply；feedback 只写自身和 append-only revision，不改 post。
覆盖 verify→revoke→reverify、feedback publish→edit→revoke→republish、非 Poster、自验、二级
回复、跨帖和 tombstone 拒绝。所有路径零 outbox/notification/callable。

- [ ] **5.2 实现、GREEN、提交**

```bash
flutter test test/playground/firestore_direct_playground_engagement_repository_test.dart \
  test/playground/firestore_direct_playground_verification_repository_test.dart \
  test/playground/firestore_direct_playground_outcome_feedback_repository_test.dart \
  test/playground/firebase_playground_report_repository_test.dart
```

每个关系 repository 单独小提交，禁止顺手修改 Functions。

## Task 6：读取 DTO、真实详情计数与 Feed 占位策略

**Files:**
- Modify: `firebase/lib/playground/firebase_playground_feed_query_repository.dart`
- Modify: `firebase/lib/playground/firebase_playground_thread_query_repository.dart`
- Create: `firebase/test/playground/firestore_direct_read_contract_test.dart`
- Create: `xuan-shell/test/playground/feed_count_visibility_test.dart`
- Create: `xuan-shell/test/playground/post_detail_viewer_capability_test.dart`

- [ ] **6.1 写 RED：详情真实数据**

seed 2 replies、3 post likes、1 active verification 和 feedback。断言：

```dart
expect(detail.post.replyCount, 2);
expect(detail.post.likeCount, 3);
expect(detail.post.verificationCount, 1);
expect(detail.counts.replyCount, 2);
expect(detail.counts.verifiedRootReplyCount, 1);
expect(detail.aggregateReadCount, 3); // replies/likes/verifications count(), 不是浏览量
expect(detail.outcomeFeedback, isNotNull);
```

viewer state 必须填 `isOwner/canEdit/canDelete/canSetFeedback/canVerify`，并覆盖 owner、非 owner、
未认证、owner 文档缺失四态；不得比较 appUserId 和 public presentation ID。

- [ ] **6.2 写 RED：Feed 明确不展示假计数**

Feed mapper 强制返回 count=0/hasOutcomeFeedback=false，但 widget 测试必须断言 Feed 不渲染
“0赞/0回复/0应验/已反馈”。`getPendingDivinationFeed` 不访问 Firestore并返回
`invalidArgument + filter/not-supported-in-direct-phase`；推荐明确降级为最新。

- [ ] **6.3 实现、GREEN、提交**

详情执行 3 个 `count()`、feedback get、当前 reply page 的 verification 分块查询；Feed 仅单 query。
recording 测试断言无逐帖/逐回复 owner N+1。分别提交 storage read adapter 和 Shell widget改动，
不得夹带 Shell 原有 dirty 文件。

## Task 7：Production Rules、索引和访问预算

**Files:**
- Modify: `firebase/infrastructure/firestore.rules`
- Modify: `firebase/infrastructure/firestore.indexes.json`
- Modify: `firebase/infrastructure/functions/test/firestore.rules.test.ts`
- Create: `firebase/infrastructure/functions/test/direct_write_schema_fixture.test.ts`
- Create: `firebase/test/playground/firestore_index_contract_test.dart`

- [ ] **7.1 写 Rules RED**

每个 allow 必有 deny：公开/internal 字段、owner get/list、revision create/update/delete、
两层关系、墓碑清空、like/bookmark、Poster verification/feedback、self verify、outbox/notification。
fixture 与 Rules exact keys/enums/nullable 字段漂移必须红。

- [ ] **7.2 写访问预算 RED**

合法 post create 的唯一 access 为 identity/owner-after/revision-after，目标 3、门禁 4/10；最重
one-time discussion reply 为 identity/post/root/reply-to/owner-after/revision-after，目标
6、门禁 8/20。两条生产 payload 在 Emulator 必须成功；注入额外访问的变异 fixture 必须因预算红。

- [ ] **7.3 实现 Rules/indexes 并 GREEN**

索引字段必须与 Design §10.2 完全一致，bookmark 使用 `user_provider_uid`；旧 profile indexes 标记
后续但不得被当前 query 使用。删除 `playground_likes` 的旧
`post_id ASC + user_provider_uid ASC` composite；当前 likes 的两个 equality filter 依赖单字段
index merge，因此 current-phase likes composite 数必须为 0，总 composite 总数仍为 6。

先写静态 RED：读取 `firestore.indexes.json`，断言旧 likes composite 不存在、6 个 current-phase
签名逐字匹配；在删除旧条目前必须失败。再用 recording adapter 断言 likes count query 恰为
`target_type==post` + `target_id==postId`，没有旧字段。实现 JSON 后运行 GREEN：

```bash
cd firebase
flutter test test/playground/firestore_index_contract_test.dart \
  test/playground/firestore_direct_read_contract_test.dart
cd infrastructure/functions
npm test -- --runInBand firestore.rules.test.ts direct_write_schema_fixture.test.ts
```

最后做变异验证：临时把旧 likes composite 加回 fixture，index contract 必须红在“unexpected
playground_likes composite”；撤销该临时变异后复跑 GREEN。Emulator 不可达不能算
RED/GREEN。通过后提交 Rules、indexes、测试。

## Task 8：单一 Rules 源和 fail-closed Emulator gate

**Files:**
- Modify: `firebase/infrastructure/emulator/firebase.json`
- Delete: `firebase/infrastructure/emulator/firestore.rules`
- Create: `firebase/scripts/run_playground_emulator_gate.sh`
- Create: `firebase/test/playground/firestore_rules_source_contract_test.dart`
- Modify: `firebase/test/playground/firebase_playground_emulator_integration_test.dart`

- [ ] **8.1 RED/GREEN**

config 必须引用 `../firestore.rules`，第二份文件不存在；LAN `192.168.0.165` Auth/Firestore 不可达、
skip、early return、allow-all 任一出现 exit 1。集成测试使用生产 payload、真实 Rules 和真实 adapter。

```bash
cd firebase
flutter test test/playground/firestore_rules_source_contract_test.dart
bash scripts/run_playground_emulator_gate.sh
```

不得自动 fallback Fake/云端。通过后提交。

## Task 9：导出、Shell 装配与 ViewModel capability

**Files:**
- Modify: `firebase/lib/playground/playground.dart`
- Modify: `xuan-shell/lib/playground/shell_playground_bootstrap.dart`
- Modify: `xuan-shell/lib/playground/viewmodels/post_detail_viewmodel.dart`
- Create: `xuan-shell/test/playground/shell_playground_bootstrap_test.dart`
- Modify: `xuan-shell/test/playground/post_detail_viewer_capability_test.dart`

- [ ] **9.1 写 RED**

八个端口按 Design §12 装配 direct/read adapter；profile/notification/conversation 保持未完成现状。
`PostDetailViewModel.isOwner` 只能读取 `detail.viewerState.isOwner`，不得比较
`publicPresentationUserId`。按钮由 canEdit/canDelete/canSetFeedback/canVerify 控制；Poster 自己
root 的 verify 写被 Rules 拒绝后 UI 回滚并显示错误。

- [ ] **9.2 实现、GREEN、分仓提交**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart
dart analyze lib/playground lib/modules/playground_module_entry.dart
```

只 stage 本 Task 精确文件；禁止 `git add -A` 捕获用户 dirty 改动。

## Task 10：完整验收与发布阻断报告

- [ ] **10.1 Storage 门禁**

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs/firebase
flutter test test/playground
dart analyze lib/playground test/playground
cd infrastructure/functions
npm test -- --runInBand firestore.rules.test.ts direct_write_schema_fixture.test.ts
```

- [ ] **10.2 Shell 与依赖门禁**

两仓 `resolved-ref` 相同；production composition 零 `httpsCallable`；Feed 不显示假 0；详情显示
真实 2/3/1 fixture 计数；所有测试零 skip。运行 Shell focused test/analyze 和两仓
`git diff --check`。

- [ ] **10.3 真实主链路**

在 production Rules Emulator：Alice 发帖；Bob 根回复/二级回复；Alice 点赞、收藏、应验、反馈；
Bob 越权编辑/应验/反馈失败；匿名 thread alias 同帖稳定跨帖不同；墓碑 raw Firestore get 不泄漏
正文；Functions/outbox/notification 均未调用或写入。

## 完成标准

- RI 合并 commit 在远端 main，storage/shell pin 同一 ref/resolved-ref。
- 公开 payload 中 provider/canonical author UID keys 命中 0；原始 Firestore 合同测试同样为 0。
- owner、revision、schema fixture 全部实现并通过 production Rules；one-time anonymous
  匿名 ID 内容派生为 `post_{postId}`（无 thread-presentation 私有映射）。
- 详情计数真实；Feed 占位计数不渲染；`aggregateReadCount=3` 明确是聚合查询次数。
- Rules 最重路径在 10/20 访问预算内；Emulator gate 零 skip、零 allow-all。
- callable 源码保留但未装配；通知、私信、Profile、待断/可信推荐未被误报完成。
