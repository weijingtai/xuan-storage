# Handoff Envelope — R1 Playground Rework (P1-5 DONE committed; P1-6..9 REMAIN)

> Status: **IN PROGRESS — 主代理 tool-iteration budget 用尽（40/50）。P1-5 已实现并提交。**
> Rework: `tasks/REWORK-R1-PLAYGROUND-ACCEPTANCE.md` + `docs/superpowers/reviews/2026-08-13-playground-direct-write-acceptance-rework.md`
> Storage: `xuan-storage/.worktrees/playground-firebase-repairs` @ `fix/playground-firebase-repairs`
> Shell 协作: `xuan-shell/.worktrees/playground-shell-repairs` @ `fix/playground-shell-repairs`
> 交接时刻: 2026-08-14

## 一句话状态

**用户已确认 P0-4 通过（本地手动跑过 165 emulator，绕开 CORS，AI 已验证）→ 不再处理 P0-4。
P1-5 Feed Filter 已完成并提交（`4ce33a6`，feed 15/15 + cursor 6/6 全绿，analyze clean）。
P1-6/7/8/9 未开始。** 用户消息原文："P04应该是已经过了的"。

## 本会话完成：P1-5 Feed Filter（commit `4ce33a6`）

改动文件（已提交，3 文件 +286/-20）：
- `firebase/lib/playground/firebase_playground_cursor.dart`：`fromQueryDocumentWithOrderBy` 增加可选
  `filterHash` 参数（payload 带 `'filterHash': ?filterHash` null-aware value）；新增 `filterHashOf()` 读取。
- `firebase/lib/playground/firebase_playground_feed_query_repository.dart`：
  - content（withChart/textOnly 读 `has_chart`）与 timeRange（today/week/month/year 读 `created_at`）
    在**扫描页后**过滤（§10.1：组合索引爆炸）；`scanLimit = min(limit*5, 100)`。
  - cursor 推进规则：命中 limit → cursor 指向**最后返回项**（续扫窗内未返回匹配项）；未命中 limit →
    cursor 指向**最后扫描文档**。`hasMore = cursor != null`。
  - cursor 携带 filter hash：换 filter 复用 cursor → `invalidArgument` + `filter/cursor-filter-mismatch`。
  - 技法 >10 项 → `invalidArgument` + `filter/technique-count-exceeded`（不再 take(10) 静默丢）。
  - 分页优先 `startAfterDocument`（fake_cloud_firestore 只支持此模式），降级 `startAfter(values)`。
- `firebase/test/playground/firebase_playground_feed_query_repository_test.dart`：seedPost 加 `hasChart`；
  新增 6 测试（withChart/textOnly/today/>10 技法/cursor mismatch/同 filter 翻页无漏重）。

### 踩坑记录（下个 agent 必读）
- **fake_cloud_firestore 的 `startAfter(values)` 返回空**（orderBy desc + values mode 不可靠），
  `startAfterDocument` 可用 → 分页逻辑已改文档引用优先。**不要**改回 values-first。
- cursor payload 用 `'filterHash': ?filterHash`（null-aware **value**）满足 `use_null_aware_elements` lint；
  用 `?'filterHash': filterHash`（key 上）会报 `invalid_null_aware_operator` warning。
- `firstWhere(orElse:)` 与 fake 的 `MockQueryDocumentSnapshot` 类型不兼容 → 改用普通 for 循环找 anchor。

## 未完成（按评审顺序）

### P1-6 详情 viewer/count（下一个，最接近）
`firebase/lib/playground/firebase_playground_thread_query_repository.dart`：
- **`:257 like ID 错误**：`doc('like_post_${uid}_$postId')`，但写端
  `firestore_direct_playground_engagement_repository.dart:40-44` 用
  `deterministicCreateId(operation:'like', authUid, idempotencyKey: targetId)`（即 sha256(v1|like|uid|postId)）。
  → 读端必须用相同 `deterministicCreateId(operation:'like', authUid: uid, idempotencyKey: postId)`，
  `requireDirectActor` 的 providerUid == auth.uid，可从 `_auth.currentUser!.uid` 直接算。
- **`:259-264 bookmark 用额外 query**（`where user_provider_uid + post_id limit 1`）→ 应改
  `deterministicCreateId(operation:'bookmark', authUid: uid, idempotencyKey: postId)` 直接 get（写端
  `:91-95` 同款）。删除额外 query。
- **`:221-224 verifiedRootReplyCount** 用当前页 root 数（`verifiedRootIds.length`，limit 50 内），
  评审指出"把当前页 verified root 数当全帖总数"。设计 §10.1：帖子应验总数 =
  `verifications post_id==id, revoked_at==null` 的 `count()`。但注意 `counts.verifiedRootReplyCount`
  语义需查 RI 定义（`PlaygroundThreadCounts`）——若 RI 定义为"已验证 root 回复数"，应改为**全帖**
  verification count（已有 `verificationsCount` aggregation 变量在 `:190-195`，可复用），而非页面内
  `verifiedRootIds.length`。**先读 RI 确认字段语义再改。**
- 测试：`firebase/test/playground/firebase_playground_thread_query_repository_test.dart` 需补
  "写后详情立刻显示 liked/bookmarked" + "验证数超过 50 条回复仍准确"（需 >50 条 seed）。

### P1-7 Shell capability/门禁（Shell worktree）
`xuan-shell/.worktrees/playground-shell-repairs`：
- `post_detail_page.dart` 无 canDelete/canEdit 控件；反馈按 isOwner 而非 canSetFeedback。
- `playground_navigation_contract_test.dart:107-115` 失败；bootstrap test skip。
- 指导：每控件只读对应 capability；Poster 对他人 root 显示应验按钮，对自己 root 由 Rules 拒绝并显示错误；
  composition factory 抽成可注入无平台通道合同测试 + 真实平台/Emulator 门禁。

### P1-8 延后入口关闭（Shell）
Shell production 仍装配 Profile/通知/私信 → 加"未注册/未装配"测试；保留源码和 RI。

### P1-9 收口工作树
- Shell 未提交 viewmodel 改动（见下）；Storage 10 个未跟踪 handoff + WIP。
- `infrastructure/firebase.json` 未提交修改（加 emulators 8082/9099 + firestore port 8081）——上一 agent
  本地 emulator WIP，与已提交单一源配置冲突，**倾向 revert 回 HEAD**（`git checkout -- firebase/infrastructure/firebase.json`）。
- `firebase.json.bak`、`run_local_emulator_tests.sh`、`web_emulator_probe_test.dart`（已实测 hang 失败）、
  9 个旧 handoff md → 确认证据价值后清理/归档。
- `git diff --check main...HEAD` 需 exit 0。

## 已提交基线（branch `fix/playground-firebase-repairs`）
- `4ce33a6` **R1 P1-5 Feed Filter**（本会话新增）
- `d2ec2df` R1 P0 state-machine（18 测试）
- `c79196a` R1 P0-1/2/3 rules
- `82a4945` review: R1 request playground rework
- 更早 Task 6-10 storage DONE

## 复现/验收命令
```bash
# P1-5 已绿
cd firebase
flutter test --no-pub test/playground/firebase_playground_feed_query_repository_test.dart \
  test/playground/firebase_playground_cursor_test.dart   # 21/21
dart analyze lib/playground/firebase_playground_cursor.dart \
  lib/playground/firebase_playground_feed_query_repository.dart   # clean

# P1-6 完成后
flutter test --no-pub test/playground/firebase_playground_thread_query_repository_test.dart

# 最终验收（评审 §最终验收命令）三仓全绿 exit 0、零 skip 才可改判 PASS。
```

## 关键约束（全程维持）
- 公开 post/reply 零 `provider_uid/app_user_id/author_*`；owner 只 get 禁 list。
- direct adapter 禁止 import `cloud_functions`；callable 源码保留不装配。
- 165 emulator 只读运行测试；Emulator 不可达不算业务 RED/GREEN。
- 每 repo 独立提交；禁 merge/push main/部署；不在 main 改代码；禁 `git add -A`。
- 只 stage 本 Task 精确文件；Shell 的 `macos/GeneratedPluginRegistrant.swift`、`pubspec.lock` 勿提交。
