# storage-s1b-multipeer 全量执行 Prompt

> 用法：在下列 worktree 根目录启动具备终端与文件编辑能力的强模型 Agent，然后一次性投喂本文件中 `---` 之间的全文。
>
> ```bash
> cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/mimo-storage-s1b-multipeer
> ```

---

你是本任务的实现执行者。请在当前 worktree 中连续完成
`storage-s1b-multipeer` 的全部实现，从 ACT 01 一直执行到 ACT 11。

不要只给计划、摘要或建议；直接读取文件、编写代码、运行测试、修复问题并提交成果。
本 Prompt 是一次性授权你开始全部 11 个 ACT，但不授权切换分支、合并、推送或扩大任务范围。

## 唯一工作目录

`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/mimo-storage-s1b-multipeer`

只能在该 worktree 内工作，不得进入或修改其他 worktree。

## 启动顺序

开始编码前必须依次完整读取：

1. `AGENTS.md`
2. `docs/storage-s1b-multipeer/HANDOFF.md`
3. `tasks/mimo-storage-s1b-multipeer.md`，重点读取：踩坑墓地、当前状态、计划、决定记录；不得修改 A1–A14 验收标准
4. `docs/storage-s1b-multipeer/REACT-R6-CODEX.md`
5. `docs/storage-s1b-multipeer/act/01.yaml` 至 `11.yaml`

然后检查：

```bash
git branch --show-current
git status --short
git log --oneline -10
```

当前应处于 `agent/mimo/storage-s1b-multipeer`。如果实际是 `main`/`master`，立即停止；不得自行切换分支。

若工作树已有改动，不得覆盖或丢弃。先查明是否为前一次执行留下的半成品；有价值的半成品按项目规则提交为 `wip:`，再从对应 ACT 断点继续。

## 执行总规则

- 严格按 `01 → 02 → ... → 11` 顺序执行，`DEPENDS_ON` 是单链；不得跳过、并行或重新排序。
- 每次只打开当前 ACT 的写权限。严格遵守该 ACT 的 `SCOPE`、`READ`、`WRITE`、`MODIFY`、`FORBIDDEN` 和依赖白名单。
- ACT 03、04、07、08、09 标记为 `STRONG_MODEL_ONLY`，必须由当前强模型亲自完成，不得转交便宜模型。
- 不得自行修改 ACT、规格、A1–A14 或降低验证口径。若 ACT 与真实源码存在无法调和的冲突，按 `ON_FAIL` 停止并提供具体文件、行号和证据。
- 修改任何函数、类或方法前，遵守 `AGENTS.md`：先运行 GitNexus upstream impact analysis，报告影响范围；HIGH/CRITICAL 风险必须先向用户警告。
- 每个 ACT 提交前运行 GitNexus `detect_changes`，确认只影响预期符号与流程。若 GitNexus 不可用，记录准确错误，但不得伪称已运行。
- 禁止切换分支、merge、rebase、push、force push、reset hard、clean、破坏性 checkout、删除 `.git`。
- 不要修改不属于本任务的现有改动。

## 每个 ACT 的机械循环

对每个 `NN.yaml`，严格执行以下循环：

1. 在开始时记录当前 HEAD 到 `.act-base`（按 ACT 指令要求操作），并确认依赖 ACT 已完成。
2. 逐条实现 `TESTS_FIRST`：先写测试并运行 `RED_COMMAND`，确认失败原因与 `RED_EXPECT` 一致。
3. 若测试未红、红在无关原因或被 catch-all 吞掉，立即按 `ON_FAIL` 修正测试；不得带着假红继续实现。
4. 实现当前 ACT 的生产代码，直到该 ACT 的所有测试转绿。
5. 逐条运行全部 `VERIFICATION`，同时核对 `EXPECT_EXIT` 和 `EXPECT_STDOUT`；不得只看屏幕上出现 PASS。
6. 逐条实做全部 `SELF_CHECK` mutation：临时改坏、确认点名测试或门禁变红、恢复、再确认正常验证转绿。
7. 确认 `DONE_WHEN` 每一项均有证据。
8. 运行 `git diff --check` 和 GitNexus `detect_changes`。
9. 更新任务纪要的当前状态、计划勾选、决定记录/踩坑墓地，以及 `HANDOFF.md`；绝对不得修改 A1–A14 文本。
10. 立即提交当前 ACT，commit message 使用 `feat:` / `fix:` / `test:` 前缀，并在正文或 subject 标明 `ACT NN`。
11. 确认提交成功且工作树没有该 ACT 遗留的未提交半成品，再自动进入下一个 ACT，无需等待用户逐个批准。

“SELF_CHECK 没做”视为 ACT 未完成。一个只能证明自己会绿、不能证明自己会红的门禁无效。

## 已知环境与基线

- `drift/pubspec_overrides.yaml` 与 `firebase/pubspec_overrides.yaml` 是 gitignored 环境文件；遵守 HANDOFF 中的完整配置，不得把绝对路径写入仓库。
- `dependency_overrides` 是整块替换，不是合并；不得只保留 5 条而丢掉 drift 原有条目。
- firebase 使用本地 core 后会暴露既有的真实错误；以各 ACT 写明的收紧基线为准，不得通过降低 analyzer/test 口径绕过。
- ACT 03 的 schema-first 方案已经 R6 闸门确认成立。
- ACT 04 超过常规粒度是人类接受的设计代价；必须按其四阶段推进，可分多个小提交，但不得拆成产生不可编译永久中间态的独立 ACT。
- macOS `/bin/bash` 为 3.2.57，不使用 `declare -A`、`mapfile` 或 `readarray`。

## 必须停止并汇报的情况

只有以下情况允许暂停，而不是继续猜：

- 当前分支是 main/master。
- 需要修改当前 ACT SCOPE 之外的业务文件，且 ACT 没有授权。
- 会改变 A1–A14、决定记录里的已裁定公开接口或方案 A。
- GitNexus 报 HIGH/CRITICAL 且用户尚未确认风险。
- 同一问题连续两次修复失败，达到 ACT 的 `ON_FAIL` 停止条件。
- 需要网络、推送、合并、删除数据或其他新的外部权限。
- 发现会导致数据泄漏、跨 scope 串读、静默丢变更或验收恒绿的新 P0 问题。

暂停时必须报告：当前 ACT、完成到哪一步、失败命令和完整关键错误、已排除的可能、工作树状态、最近提交。不要只说“遇到问题”。

## 全部完成后的总验收

ACT 11 完成后，除 ACT 自身 VERIFICATION 外，还要执行并记录：

```bash
bash scripts/run_s1b_analyze_gate.sh
bash scripts/test_s1b_analyze_gate.sh
bash scripts/test_s1b_analyze_gate_trap.sh
cd core && flutter test
cd ../drift && flutter test
cd ../firebase && flutter test
```

同时确认：

- A1–A14 与基线提交 `cd064c6` 逐字一致。
- 11 个 ACT 全部在任务纪要中标记完成。
- 每个 ACT 都有独立提交和验证证据。
- `git diff --check` 通过。
- `git status --short` 为空。
- 不执行 push 或 merge，等待人类最终验收。

最终答复必须包含：

- 11 个 ACT 的完成状态与对应 commit；
- 各包测试/analyze 的实际通过数量与退出码；
- SELF_CHECK/mutation 的执行摘要；
- GitNexus detect_changes 的最终影响摘要；
- 已知残余风险或明确写“无新增已知阻断项”；
- 当前分支和最终 HEAD。

现在开始执行。除非命中上述停止条件，否则不要在 ACT 之间等待我的回复，连续推进直到 ACT 11 和总验收全部完成。

---

## 一行启动版

如果执行者已经位于正确 worktree，可只投喂：

> 完整读取并严格执行 `docs/storage-s1b-multipeer/EXECUTION-PROMPT.md` 中 `---` 之间的执行合同；从 ACT 01 连续做到 ACT 11，每个 ACT 测试先红、实现转绿、逐条 SELF_CHECK、验证、更新交接并独立提交。除非命中合同中的停止条件，否则不要等待逐 ACT 批准；不得切分支、merge、push、修改 A1–A14 或越出当前 ACT SCOPE。
