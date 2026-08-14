# Rework — Playground Firestore Direct-Write 验收返工（R1）

> 状态：IN PROGRESS — 按 `docs/superpowers/reviews/2026-08-13-playground-direct-write-acceptance-rework.md` 返工。
> 起始：2026-08-14。分支：`xuan-storage/.worktrees/playground-firebase-repairs` @ `fix/playground-firebase-repairs`
> 协作 worktree：`xuan-shell/.worktrees/playground-shell-repairs` @ `fix/playground-shell-repairs`
> 最终验收命令见评审文档「最终验收命令」节。**165 emulator 当前可达（8080/9099 OPEN）。**

## 范围（只修验收缺口，不得扩展 Functions/Profile/通知/私信/H5/小程序）

### P0（必须全部关闭）
1. **Rules update 误判 partial patch**：`request.resource.data.keys().hasOnly(变更字段)` 用于 update
   （完整 future doc）→ 帖子/回复编辑与墓碑、应验撤回/重验、反馈编辑/撤回/再发布全 PERMISSION_DENIED。
   → 改用 `request.resource.data.diff(resource.data).affectedKeys().hasOnly(...)`；继续校验完整 schema、
   不变量、合法状态迁移；`getAfter()` 指向 `request.resource.data.current_revision_id` 并核验 parent/
   编号/内容与当前事实一致，不得只查 `r0000000001`。
2. **取消点赞必失败**：`firestore_direct_playground_engagement_repository.dart:69-72` 同批删 like+owner，
   但 `firestore.rules:173-186` 禁 owner delete → 仅允许 owner 原子删除匹配公开 like+私有 owner；单删任一侧/
   删他人/target 不一致拒绝。
3. **反馈 revision 注入**：`firestore.rules:593-607` 允许任意 identity-ready 用户给任意 feedback 建 revision
   → 只允许 post owner 创建；校验 feedback/post 对应、连续编号、parent、当前 revision 指针和快照一致；
   revision 保持 update/delete=false。
4. **重建真实主链路验收，删假覆盖**：`main_path.test.ts` 的 `withSecurityRulesDisabled` seed 帖子/根回复/墓碑
   → 认证客户端经 production Rules 创建 post/root/discussion，真实调 direct adapter edit/tombstone/unlike/
   revoke/re-publish；初始化失败或 Emulator 不可达 exit!=0，零 skip。

### P1（P0 后修）
5. **Feed Filter**：`firebase_playground_feed_query_repository.dart:83-151` 只做 technique，忽略 content/time，
   `take(10)` 静默丢条件 → 实现 content/time；多技法超 Firestore 限制给明确 validation error 或按 Design
   扫描分页；cursor 绑定 filter hash + 最后扫描文档推进，禁止漏帖/重帖。
   → **DONE（commit 4ce33a6）**：content/time 扫描后过滤 + scanLimit + cursor filter-hash 绑定 + >10 技法报错。
   新增 6 测试，feed 15/15 + cursor 6/6 全绿。
6. **详情 viewer/count**：`firebase_playground_thread_query_repository.dart:254-264` 用不存在的 like 文档 ID +
   额外 bookmark query；`:221-224` 把当前页 verified root 数当全帖总数 → like/bookmark 用与写端完全一致的
   deterministic direct-get ID；verified count 用已执行 verification aggregation。
7. **Shell capability 与门禁**：`post_detail_page.dart` 未提供 canDelete/canEdit 控件，反馈按 isOwner 而非
   canSetFeedback；`playground_navigation_contract_test.dart:107-115` 失败；bootstrap test skip →
   每控件只读对应 capability；Poster 对他人 root 显示应验按钮，对自己的 root 由 Rules 拒绝并显示错误；
   composition factory 抽成可注入无平台通道合同测试 + 另设真实平台/Emulator 门禁。
8. **延后入口必须真正关闭**：Shell 仍生产装配 Profile/通知/私信 → 保留源码和 RI，本期 production
   route/dependencies 不暴露、不触发读写；加"未注册/未装配"测试。
9. **收口工作树**：Shell 未提交 Playground VM/test 改动，Storage 9 个未跟踪 handoff；`git diff --check
   main...HEAD` 报两处 trailing whitespace → 确认归属、只提交精确文件、禁 `git add -A`、修 whitespace。

## 顺序
P0(1→2→3→4) → P1(5→6→7→8→9) → 最终验收命令全绿。

## 禁止
- 禁 `git add -A`；禁 push/merge main/部署；165 只读。
- 不扩展 Functions/Profile/通知/私信/H5/小程序；不删未来代码。
- direct adapter 禁 import cloud_functions。
