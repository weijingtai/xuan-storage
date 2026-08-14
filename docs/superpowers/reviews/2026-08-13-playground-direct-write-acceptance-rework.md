# Playground Firestore Direct-Write 验收返工单（R1）

结论：**FAIL，禁止合并/部署。**

## 不得修改的产品决定

- one-time anonymous 继续使用已批准的简化方案：`post_{postId}`。
- 禁止恢复 thread-presentation mapping、哈希匿名身份或其他复杂匿名模型。
- 本轮只修验收缺口；不得扩展 Functions、Profile、通知、私信、H5/小程序。

## P0（必须全部关闭）

- [ ] 修复 production Rules 对 update 的错误判断：
  `firebase/infrastructure/firestore.rules:254-277,399-419,529-534,568-586` 把
  `request.resource.data`（完整 future document）误当成 partial patch，使用
  `keys().hasOnly(变更字段)`，导致帖子/回复编辑与墓碑、应验撤回/重验、反馈编辑/撤回/再发布
  全部 `PERMISSION_DENIED`。
  ｜指导：改用 `request.resource.data.diff(resource.data).affectedKeys().hasOnly(...)`；继续校验完整
  schema、不变量和合法状态迁移；`getAfter()` 必须指向
  `request.resource.data.current_revision_id`，并核验 revision 的 parent、编号、内容与当前事实一致，
  不得继续只检查 `r0000000001`。
  ｜通过标准：production Rules 下，真实认证客户端完成上述全部正常状态机；非 owner、跨帖、跳号、
  缺 revision、伪造 revision 全部拒绝。

- [ ] 修复取消点赞必失败：
  `firebase/lib/playground/firestore_direct_playground_engagement_repository.dart:69-72` 同批删除 like 与
  like owner，但 `firestore.rules:173-186` 禁止 owner delete。
  ｜指导：仅允许 owner 本人把匹配的公开 like 与私有 owner 同一 atomic write 删除；单删任一侧、
  删除他人关系、target 不一致均拒绝。
  ｜通过标准：Emulator 中 like→unlike 成功，四个越权/非原子负例失败。

- [ ] 修复反馈 revision 注入：
  `firestore.rules:593-607` 允许任何 identity-ready 用户给任意 feedback 创建 revision，未绑定 Poster、
  parent feedback 与同批事实更新。
  ｜指导：只允许 post owner 创建；校验 feedback/post 对应关系、连续编号、parent、当前 revision 指针
  和快照一致；revision 仍保持 update/delete=false。
  ｜通过标准：Poster 正常发布/编辑/撤回/再发布通过；他人注入、孤儿 revision、跳号 revision 拒绝。

- [ ] 重建“真实主链路”验收，删除假覆盖：
  `firebase/infrastructure/functions/test/main_path.test.ts:93-120,263-275` 用
  `withSecurityRulesDisabled` seed 帖子、根回复和墓碑；
  `firebase/test/playground/firebase_playground_emulator_integration_test.dart:19-62` 可 skip 且仍是旧
  callable 路径；`firebase/scripts/run_playground_emulator_gate.sh` 未运行真实 direct adapter。
  ｜指导：认证客户端必须经 production Rules 创建 post/root/discussion，并真实调用 direct adapter 的
  edit/tombstone/unlike/revoke/re-publish；初始化失败或 Emulator 不可达必须 exit!=0，零 skip。
  ｜通过标准：`bash firebase/scripts/run_playground_emulator_gate.sh` 全绿，输出零 `skip/~`；临时恢复任一
  上述缺陷时门禁必须变红。当前验收机 `192.168.0.165:8080` 不可达，故本轮未取得远端通过证据。

## P1（P0 后修）

- [ ] 补齐 Feed Filter：
  `firebase_playground_feed_query_repository.dart:83-151` 仅执行 technique filter，忽略 content/time，
  且 `take(10)` 静默丢条件。
  ｜指导：实现 content/time，多技法超过 Firestore 限制时明确 validation error 或按 Design 的扫描分页
  方案处理；cursor 必须绑定 filter hash，并以最后扫描文档推进，禁止漏帖/重帖。
  ｜通过标准：content/time/multi-technique、换 filter 复用 cursor、跨页过滤测试全绿。

- [ ] 修正详情 viewer/count：
  `firebase_playground_thread_query_repository.dart:254-264` 使用不存在的 like 文档 ID，并用额外 bookmark
  query；`:221-224` 把当前回复页内 verified root 数当全帖总数。
  ｜指导：like/bookmark 使用与写端完全相同的 deterministic direct-get ID；verified count 使用已执行的
  verification aggregation。
  ｜通过标准：写后详情立刻显示 liked/bookmarked；验证数超过 50 条回复仍准确；索引契约匹配查询。

- [ ] 修复 Shell capability 与门禁：
  `post_detail_page.dart` 未提供 canDelete/canEdit 控件，反馈仍按 `isOwner` 而非 `canSetFeedback`；
  `playground_navigation_contract_test.dart:107-115` 当前失败；bootstrap test 会 skip。
  ｜指导：每个控件只读对应 capability；Poster 对他人 root 显示应验按钮，对自己的 root 由 Rules 拒绝并
  显示错误；把 composition factory 抽成可注入的无平台通道合同测试，另设真实平台/Emulator 门禁。
  ｜通过标准：
  `flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart` 零失败零 skip。

- [ ] 延后入口必须真正关闭：Shell 当前仍生产装配 Profile/通知/私信。
  ｜指导：保留源码和 RI，但本期 production route/dependencies 不暴露、不触发读写；加“未注册/未装配”
  测试。不得顺手删除未来代码。

- [ ] 收口工作树：Shell 当前有未提交 Playground VM/test 改动，Storage 有 9 个未跟踪 handoff；
  `git diff --check main...HEAD` 还报两处 trailing whitespace。
  ｜指导：先确认改动归属；只提交本任务精确文件，禁止 `git add -A`、禁止捕获 lock/生成文件或用户改动；
  删除/归档重复 handoff 前需确认其是否仍有证据价值。
  ｜通过标准：三个 worktree `git status --short` 均无本任务未提交项，两个实现仓
  `git diff --check main...HEAD` exit 0。

## 最终验收命令

```bash
# RI
cd /Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-playground/.worktrees/playground-ri-completion
dart test

# Storage（必须连接 production-Rules Emulator，零 skip）
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/playground-firebase-repairs/firebase
flutter test --no-pub test/playground
bash scripts/run_playground_emulator_gate.sh
dart analyze lib/playground test/playground

# Shell
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell/.worktrees/playground-shell-repairs
flutter test --no-pub test/playground test/modules/playground_navigation_contract_test.dart
dart analyze lib/playground lib/modules/playground_module_entry.dart
```

全部命令 exit 0、零 skip、真实状态机/越权负例均被 production Rules 覆盖，才可改判 PASS。
