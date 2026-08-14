# Task 7 — 匿名 ID 改为内容派生 `post_{postId}`（消除 thread-presentation mapping）

> 状态：ACTIVE（2026-08-14）—— Step 1-3 已 GREEN 并提交 `dbcb3c4`；Step 4（docs）进行中。
> 目标：消除 Task 7 唯一 RED（one-time anonymous discussion reply），用零状态的
>       内容派生匿名 ID 替换私有 thread-presentation mapping，不触碰账号层。
> 权威基线：`docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
>         + `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md` Task 7
> 分支：`fix/playground-firebase-repairs`（本 worktree）
> 单句启动语：按本文件执行：把 reply 的 oneTimeAnonymous 匿名 ID 从 thread mapping
>            随机 ID 改为内容派生 `post_{postId}`，同步删 mapping 相关代码/规则/测试/文档，
>            以 165 emulator 的 Rules 测试 10/10 GREEN + Dart 测试全绿验收。

## 0. 真根因（2026-08-14 实验推翻 handoff 假设）

通过三组最小实验（experiment1/2/3，均已删）确定：**Task 7 唯一 RED 的根因不是匿名
mapping**，而是 reply create 规则 `validReplyDepthOne` 里对 `replyTo` 文档字段解引用时，
当 `reply_to_reply_id != null` 且目标是 depth-0 root（其 `root_reply_id` 为 null）或
不存在时，emulator 报 `Null value error`/类型不可比（evaluation error）。mapping 只是
被连带怀疑的对象。
修复：用**三元短路** `(x.data == null ? false : ...)` 包裹 owner/revision/replyTo 的字段
访问，并对 `replyTo.data.root_reply_id` 加 `!= null` 保护。验证：真实 batch 路径
（reply+owner+revision，reply_to=depth-0 root）GREEN；单 set / 跨集合 reply_to 的 error
是真实业务不走的路径（adapter 永远 batch 写 owner+revision；reply_to 恒指向同集合存在的
reply），不影响验收。
**本 emulator 特性**：`&&` 不保证短路（对 null 字段访问仍求值），必须用三元短路。


---

## 1. 背景与动机（为何必须改）

Task 7 唯一 RED：`access budget · one-time anonymous discussion reply create succeeds（7 访问）`
在 165 emulator 上 `PERMISSION_DENIED`（evaluation error at rules L416/L155/L452）。
根因：为“同帖内多个匿名作者可区分”引入了私有
`playground_thread_presentations/{postId}__{providerUid}` 映射文档，要求 reply + owner +
revision + mapping 同批原子写、Rules 用 `getAfter()` 比对，叠加 emulator 对 batch 中
getAfter 的语义坑与 1000 表达式上限，导致空转。

**方案：匿名 ID 由“内容”派生而非“账号”派生。**
- post oneTimeAnonymous：已是 `post_{postId}`（Rules 可验证、确定性、零状态，已 GREEN）。
- reply oneTimeAnonymous：**同样改为 `post_{postId}`**（alias 仍固定“匿名用户”）。
- 效果：同帖内所有匿名作者共享该帖 persona（同帖稳定 ✓、跨帖不可关联 ✓、不泄漏真实
  身份 ✓、Rules 可验证 ✓、零新状态 ✓、不再需要 mapping 文档/规则/测试）。

**唯一取舍**：同一帖子内无法区分多个不同的匿名作者（贴吧“匿名用户”、知乎匿名同款展示）。
这是纯 UX 细节，不是安全/数据风险。若产品未来明确要求 per-thread persona，另开独立任务。

**为什么不做“两个 ID（正常 + 匿名）”**：那要改 identity_map/账号层/升级/backfill，
牵连全部 stableAlias 已完成的规则与适配器，且一个全局匿名 ID 会把用户全部匿名行为
关联到同一伪名，可关联性更差。

## 2. 禁止项（NEVER）

- 不改 `identity_map` 结构、不动账号层、不改 `public_presentation_id` 语义。
- 不改 stableAlias 分支与已完成逻辑（post/owner/revision/like/bookmark/verify/feedback）。
- 不物理删除帖子/回复；不动 indexes（本任务与 composite 无关）。
- 不在 165 emulator 上做任何写入（那是共享 dev/test 环境，禁改禁删）；只读运行测试。
- 不 `git add -A`；只 stage 本任务精确文件。
- 不 commit/merge main；不部署。
- `direct adapter 禁止 import cloud_functions`（维持）。
- 不伪造“GREEN”（Emulator 不可达/依赖失败不算 RED/GREEN，须如实报告）。

## 3. 顺序化任务与门禁

### Step 0 —— 基线确认（必须已满足）
- [ ] `FIRESTORE_EMULATOR_HOST=192.168.0.165:8080 FIREBASE_AUTH_EMULATOR_HOST=192.168.0.165:9099
      npx jest --runInBand direct_write_schema_fixture.test.ts` → **9/10，唯一 RED 为 one-time
      anonymous discussion reply**（已确认，2026-08-14）。

### Step 1 —— 写 RED（先证明新行为缺失）
- [ ] 修改 `firebase/infrastructure/functions/test/direct_write_schema_fixture.test.ts`：
  - one-time anonymous discussion reply 测试：**删除 batch 中的
    `playground_thread_presentations` mapping 文档**；reply `presentation_identity_id`
    从 `anon_thread_128bit` 改为 `post_{postId}`；断言展示 ID == `post_${postId}`、
    alias == `匿名用户`；描述从「7 访问」改为「6 访问」（去 mapping 少 1 次 getAfter）。
  - 此时 rules 仍是旧 mapping 校验 → 该测试应 **RED**（mapping.data==null 导致拒绝，
    且 `presentation_identity_id` 不再是随机 ID，`mapping.data.presentation_identity_id
    == post_{postId}` 不成立）。

### Step 2 —— 改 Rules（实现 GREEN 主体）
- [ ] 修改 `firebase/infrastructure/firestore.rules`：
  - `validReplyCreateData`：oneTimeAnonymous 分支改为
    `data.presentation_identity_id == 'post_' + postId &&
     data.presentation_display_alias == '匿名用户'`；**删除** `let mapping = getAfter(...)`
    与 mapping.data 相关校验（L354、L387-390、L398-405）。
  - **删除** `playground_thread_presentations` 整块 match 规则（L189-207）。
    （保留 deny-by-default 默认行为；集合不再出现在 rules 中。）

### Step 3 —— 改 Dart 适配器与 support（去 mapping）
- [ ] `firebase/lib/playground/firestore_direct_playground_reply_command_repository.dart`：
  - 删除 `_resolvePresentation` 的 mapping 逻辑与 `_randomPresentationId`；
  - `_resolvePresentation` 改名为 `_resolveReplyPresentation`（或直接内联）：
    `mode == oneTimeAnonymous → actor.oneTimeAnonymousPresentationPayload(identityId: 'post_$postId')`
    （镜像 post repository `_postPresentation` 的既有写法）；stableAlias 不变。
  - 删除 `dart:math` Random 相关（如仅此处使用）。
  - 更新文件头注释（去掉 §3.3 mapping 描述）。
- [ ] `firebase/lib/playground/firebase_playground_schema.dart`：删除
  `threadPresentations` 常量（如无其他引用）。
- [ ] `firebase/test/playground/firestore_direct_playground_reply_command_repository_test.dart`：
  - 重写 `one-time anonymous` 测试：断言 `presentation_identity_id == 'post_$postId'`、
    alias `匿名用户`；同帖多次回复 ID 稳定且都等于 `post_{postId}`；跨帖（post2）ID 为
    `post_{post2}`（不同）→ 不可关联；**删除** 对 `playground_thread_presentations`
    集合的所有读取断言。
- [ ] `firebase/test/playground/firestore_direct_playground_command_support_test.dart`：
  - `schema 包含 owner/thread-presentation/revision 集合` 测试：删去
    `contains('playground_thread_presentations')` 断言。
- [ ] `firebase/test/playground/fixtures/direct_write_schema_v1.json`：删除
  `"playground_thread_presentations": {...}` 条目（该集合不再写入任何新文档）。

### Step 4 —— 更新设计/计划/交接文档
- [ ] `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`：
  - §3.2：oneTimeAnonymous 回复展示 ID 改为 `post_{postId}`（与帖子一致），删除
    “thread presentation mapping 首次生成 128-bit 随机 ID”描述。
  - §3.3：删除 `playground_thread_presentations` 集合条目与相关说明；保留
    post_owners/reply_owners/like_owners 的 deny-by-default。
  - §6.2：删除回复 create 对 mapping 的引用；写明匿名回复 ID == `post_{postId}`。
- [ ] `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`：
  - Task 4（4.1/4.2）、Task 7（7.1/7.2/7.3）、Task 10 完成标准、Task 7 Files 描述中所有
    thread-presentation / mapping 表述改为内容派生；访问预算目标 7 → 6。
  - 不需要改动 plan 的 files 列表里其它项。
- [ ] 更新/新增 handoff：在 `docs/superpowers/handoffs/` 写一份新的
  `2026-08-14-playground-firestore-direct-write-task7-anon-content-derived.md`，记录
  决策、改动文件、验收结果、遗留（同帖多匿名作者不可区分=后续任务）。

### Step 5 —— GREEN 验收
```bash
cd firebase/infrastructure/functions
FIRESTORE_EMULATOR_HOST=192.168.0.165:8080 FIREBASE_AUTH_EMULATOR_HOST=192.168.0.165:9099 \
  npx jest --runInBand direct_write_schema_fixture.test.ts
# 期望：10/10 GREEN（含 one-time reply create，访问 6）

cd firebase
flutter test test/playground/firestore_direct_playground_reply_command_repository_test.dart \
  test/playground/firestore_direct_playground_post_command_repository_test.dart \
  test/playground/firestore_direct_playground_command_support_test.dart
# 期望：全绿（无 thread_presentations 引用残留）

dart analyze lib/playground/firestore_direct_playground_reply_command_repository.dart \
  lib/playground/firebase_playground_schema.dart
# 期望：no issues（删除后无残留引用）

# 残留引用检查（除 node_modules / .dart_tool / 文档与历史 handoff 外应为 0）
grep -rn "thread_presentations\|threadPresentations\|thread-presentation\|_randomPresentationId" \
  firebase/lib firebase/test --include="*.dart" --include="*.json" | grep -v node_modules
grep -rn "thread_presentations\|_randomPresentationId" \
  firebase/infrastructure/firestore.rules firebase/infrastructure/functions/test --include="*.rules" --include="*.ts"
```

### Step 6 —— 提交（单独 commit，精确文件）
- [ ] 只 stage 本任务文件；`git add` 明确列出，禁止 `-A`。
- [ ] commit message 示例：
  `refactor(playground): content-derived anon ID post_{postId}; drop thread-presentation mapping (Task 7)`
- [ ] 不 push（遵守分支铁律；如需 PR 由用户发起）。

## 4. 停止条件 / 上报

- 任何一步 RED 无法在 2 次尝试内修复 → 停止，记录现象与 emulator 日志，回退本任务改动，
  报告主代理，不自行改方案。
- 165 不可达 / 测试基建失败 → 不算业务 RED，如实上报，不伪造结果。
- 发现与本任务无关的问题（如 rules L546 WARNING、旧 `firestore.rules.test.ts` 断言旧行为）
  → 只记录不“顺手修”（除非阻塞本任务且改动极小，仍须先报主代理）。

## 5. 证据产物

- 验收命令输出（Rules 10/10、Dart 全绿、analyze 干净）。
- `git diff --stat` 与 `git log -1`。
- handoff 文档（Step 4）。
