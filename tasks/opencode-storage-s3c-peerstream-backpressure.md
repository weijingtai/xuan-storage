# 任务: storage-s3c-peerstream-backpressure（返工）
负责: opencode ｜ 分支: agent/opencode/storage-s3c-peerstream-backpressure ｜ 开工: 2026-08-05
状态: 返工进行中

## 目标
对 S3c-c-pre `PeerStream` 背压契约做返工（`REWORK-S3c-c-pre.md` R1-R10）：
重建两个 fake 的真实对端边界、Fake B 换 credit/window 骨架、订正 `bufferedAmount`
契约定义（去掉「对端消费确认」）、`overflowPolicy` 定性（禁运行时切换）、补并发
`send` 越界语义、A6 断言带 reason、补红在 A6 核心断言的变异自检、A7 守卫扩全仓、
订正决定记录、成果推到共享仓库。基线 main = `3e2f464`，起点 = cherry-pick `3375cc7`。

## 计划
- [x] R1 重建两个 fake 真实对端边界（openStream 创建独立接收流，套件加 `identical(sender, receiver)` 为假断言）
- [x] R2 Fake B 换 credit/window 骨架（不是只换 overflow 分支），决定记录附归一化结构 diff 输出
- [x] R3 `bufferedAmount` dartdoc 去掉「对端消费确认」，改「尚未离开本地发送缓冲」，写明两后端取值方式与间接传导
- [x] R4 `overflowPolicy` 定性：选 (b) 保留枚举 + 删「可运行时切换」+ 契约测试 R4（生命周期内不得改变）
- [x] R5 并发 `send` 越界语义：dartdoc 写死界 + 契约测试 R5（并发 K 条断言越界 ≤ 一个在途批次）
- [x] R6 A6 核心断言换带 reason 的 `expectLater(..., completes, ...)`
- [x] R7 补红在 A6 核心断言的变异自检（会话级共享预算真饿死），D9 补记录
- [x] R8 A7 守卫扫描范围扩到全仓各包 lib/，并用 p2p/lib 空实现验证红
- [x] R9 订正 DESIGN-DECISION.md（D6 重写真实形态、D9 补 R7、D2 补取值方式、新增 R4 决定）
- [ ] R10 每子任务 /wjt-handoff 落盘；成果推到 `agent/opencode/storage-s3c-peerstream-backpressure` 并确认 `git ls-remote` 可见

## 验收标准
- [ ] 返工书 R1-R10 完成判据逐条满足
- [ ] `bash scripts/run_s1a_analyze_gate.sh` 检查 1 零 issue、检查 3 = 57
- [ ] `bash scripts/run_monorepo_convention_check.sh` 全绿
- [ ] core / drift / p2p 各包测试全绿；S1b 门禁在 **main 位置**复跑（副本里跑出 drift 149 是环境假象，见返工书 §四）
- [ ] 变异自检：红在 A6 核心断言，复原后全绿
验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test)

## 当前状态
- R1-R9 全部完成；`transport_contract_test.dart` 24 条全绿；S1a 57=57、S1b 全绿（副本 drift 146=146、firebase 20=20）、monorepo、dartdoc、drift +391、p2p +18~1 全过。
- 第一次落盘 `ae4984a`（R1-R8 + fake-structure-diff.txt + 任务纪要）；本次提交为 R9 决定记录订正 + R6 断言修法。
- R7 变异（会话级共享预算真饿死）：A6 红在核心断言、失败信息含契约 reason，已复原；D9 补 V6 批注。
- R6 修正：`expectLater(future.timeout(), completes, reason)` 的 reason 会丢，改 `_expectCompletesWithin` 捕获后交给 `expect(failure, isNull, reason)`。
- 剩余：R10 推送 gitea + ls-remote 确认（S1b 已在副本复跑通过；返工书 §四 的 main 位置复跑属基线确认，main 目录第 1 会话已验证 145/146 全绿）。

## 决定记录
2026-08-05: 返工 R4 选 (b)：保留 `OverflowPolicy` 枚举但 dartdoc 改为「同一条流生命周期内不得改变」，并加契约测试 R4。理由：(a) 钉死单一策略与派工 §五.3「两个 fake 各展示一种行为（wait/fail）」冲突，两个 fake 会退化为同策略；(b) 保留枚举 + 禁运行时切换，既消除 TOCTOU 又保住两种行为的展示。
2026-08-05: 返工 R5 越界上限写死为「最多超出 maxBufferedAmount 一个在途批次」，契约允许并发 send（blob 管线必须流水线化，不可能串行）。
2026-08-05: 返工 R6 断言形态：放弃 `expectLater(future.timeout(), completes, reason)` —— flutter_test 在 future 以异常完成时把原始 TimeoutException 原样抛出、reason 丢失；改 `_expectCompletesWithin`（捕获后 `expect(failure, isNull, reason)`），让「一条流的背压不得饿死另一条流」进失败信息。

## 踩坑墓地
2026-08-05: 新 worktree 在 `xuan-storage/.worktrees/`（比旧 `xuan-migration-worktrees/` 深一层），pubspec_overrides 的 path 需 `../../../../` 而非 `../../../`。教训：先数深度再复制 overrides，别照抄旧 worktree。
2026-08-05: bash 里相对 cwd 的 rm/mkdir 两次误写路径（探针注入到 core/p2p、删除时又漏删），教训：worktree 根的操作必须先确认 cwd，避免在 core/ 下操作仓库级路径。
2026-08-05: flutter_test 的 `expectLater(future.timeout(), completes, reason)` 在 future error 完成时 reason 不出现（原始异常直接抛出）。教训：要「契约语言进失败信息」得自己捕获再 expect，不能依赖 matcher 的 reason 透传。
